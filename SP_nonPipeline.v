 module SP(
	// INPUT SIGNAL
	clk,
	rst_n,
	in_valid,
	inst,
	mem_dout,
	// OUTPUT SIGNAL
	out_valid,
	inst_addr,
	mem_wen,
	mem_addr,
	mem_din
);

//------------------------------------------------------------------------
//   INPUT AND OUTPUT DECLARATION                         
//------------------------------------------------------------------------

input                    clk, rst_n, in_valid;
input             [31:0] inst;
input  signed     [31:0] mem_dout;
output reg               out_valid;
output reg        [31:0] inst_addr;
output reg               mem_wen;
output reg        [11:0] mem_addr;
output reg signed [31:0] mem_din;

//------------------------------------------------------------------------
//   DECLARATION
//------------------------------------------------------------------------

// REGISTER FILE, DO NOT EDIT THE NAME.
reg signed [31:0] r [0:31]; 

// Instruction Fields
reg [5:0] opcode;
reg [4:0] rs;
reg [4:0] rt;
reg [4:0] rd;
reg [4:0] shamt;
reg [5:0] funct;
reg signed [15:0] immediate;
reg [25:0] jump_address;
//------------------------------------------------------------------------
//   DESIGN
//------------------------------------------------------------------------
integer i;
integer done;
integer wb;
localparam S_IDLE = 'd0;
localparam S_IN = 'd1;
localparam S_EXEC = 'd2;
localparam S_OUT = 'd3;
reg [1:0] current_state, next_state;
integer test;
reg [4:0] counter;  // Declare a 5-bit counter

always @(posedge clk, negedge rst_n) begin
    if (!rst_n) begin
        // Reset signals after asynchronous active-low reset
        inst_addr <= 32'h0;
        out_valid <= 1'b0;
		mem_wen <= 1'b1;
		mem_addr <= 0;  
		mem_din <=0;	
        counter <= 5'b0;  // Reset the counter
        // Reset register file
        for (i = 0; i < 32; i = i + 1) begin
            r[i] <= 32'h0;
        end
        current_state <= S_IDLE;
    end else begin
        current_state <= next_state;
		// Decode instruction
		if(current_state==S_EXEC && done ==0) begin
			done <= 1;
			
			//$display("OPCODE:%h", opcode);
			case(opcode)
				// R-type instructions
				6'b000000: begin
					//$display("I am here");
					case(funct)
						6'b000000: begin
							r[rd] <= r[rs] & r[rt];  // AND instruction
							inst_addr <= inst_addr + 4;
						end
						6'b000001: begin
							r[rd] <= r[rs] | r[rt];  // OR instruction
							inst_addr <= inst_addr + 4;
						end
						6'b000010: begin
							r[rd] <= r[rs] + r[rt];  // ADD instruction
							inst_addr <= inst_addr + 4;
						end
						6'b000011: begin
							r[rd] <= r[rs] - r[rt];  // SUB instruction
							inst_addr <= inst_addr + 4;
						end
						6'b000100: begin
							r[rd] <= r[rs] < r[rt] ? 32'h1 : 32'h0;  // SLT instruction
							inst_addr <= inst_addr + 4;
						end
						6'b000101: begin
							r[rd] <= r[rs] << shamt;  // SLL instruction
							inst_addr <= inst_addr + 4;
						end
						6'b000110: begin
							r[rd] <= ~(r[rs] | r[rt]);  // NOR instruction
							inst_addr <= inst_addr + 4;
							//$display("Result: %h",~(r[rs] | r[rt]));
							//$display("rd:%h rs:%h rt:%h", rd,rs,rt );
							//$display("r[rd]:%h r[rs]:%h r[rt]:%h", r[rd],r[rs],r[rt]);
							//$display("IAMHERE!!!");
						end
						6'b000111: inst_addr <= r[rs];  // JR instruction
						default: begin
							//inst_addr <= inst_addr + 4;
						end
					endcase
				end
				// I-type instructions
				6'b000001: begin
					r[rt] <= r[rs] & $unsigned(immediate);  // ANDI instruction
					inst_addr <= inst_addr + 4;
				end
				6'b000010: begin
					r[rt] <= r[rs] | $unsigned(immediate);  // ORI instruction
					inst_addr <= inst_addr + 4;
				end
				6'b000011: begin
					r[rt] <= r[rs] + $signed(immediate);  // ADDI (with sign extension) instruction
					inst_addr <= inst_addr + 4;
				end
				6'b000100: begin
					r[rt] <= r[rs] - $signed(immediate);  // SUBI (with sign extension) instruction
					inst_addr <= inst_addr + 4;
				end
				6'b000101: begin
					// LW instruction
					mem_wen <= 1'b1; // When WEN is high, you can load data from memory.
					//mem_addr <= r[rs] + $signed(immediate);
					wb=1;
					//r[rt] <= mem_dout;
					inst_addr <= inst_addr + 4;
				end
				6'b000110: begin
					// SW instruction
					mem_wen <= 1'b0;// When WEN is low, you can load data into memory.
					//mem_addr <= r[rs] + $signed(immediate);
					mem_din <= r[rt];
					inst_addr <= inst_addr + 4;
				end
				6'b000111: begin
					// BEQ instruction
					if (r[rs] == r[rt]) begin
						inst_addr <= $signed(inst_addr) + 4 + $signed({immediate, 2'b00});
					end else begin
						inst_addr <= inst_addr + 4;
					end
				end
				6'b001000: begin
					// BNE instruction
					if (r[rs] != r[rt]) begin
						inst_addr <= $signed(inst_addr) + 4 + $signed({immediate, 2'b00});
					end else begin
						inst_addr <= inst_addr + 4;
					end
				end
				6'b001001: begin          
					// LUI instruction
					r[rt] <= {immediate, 16'h0000};
					inst_addr <= inst_addr + 4;
				end
				// J-type instructions
				// J instruction
				6'b001010: begin  
					inst_addr <= {inst_addr[31:28], jump_address << 2};
				end
				6'b001011: begin
					// JAL instruction
					r[31] <= inst_addr + 4;
					inst_addr <= {inst_addr[31:28], jump_address << 2};
				end
				default: begin
					//inst_addr <= inst_addr + 4;
				end
			endcase
		end

        // Determine when to raise out_valid
        if ((current_state == S_OUT && !in_valid) || counter == 5'b1010) begin
            out_valid <= 1'b1;
            counter <= 5'b0;  // Reset the counter when out_valid is set
        end else begin
            out_valid <= 1'b0;
            // Add logic to reset the counter immediately when it reaches 10
            if (counter == 5'b1010) begin
                counter <= 5'b0;
            end
        end

        // Add additional logic to check the 10-cycle requirement
        if (in_valid) begin
            counter <= 5'b0;  // Reset the counter when in_valid is high
        end else if (counter != 5'b1010) begin
            counter <= counter + 1'b1;  // Increment the counter otherwise
        end
    end
end



always @(*) begin
	//mem_wen = 1'b1;
    case (current_state)
        S_IDLE: begin
            if (in_valid)
                next_state = S_IN;
            else
                next_state = S_IDLE;
        end
        S_IN: begin
            if (in_valid) begin
                next_state = S_IN;
				// Default values
				opcode = inst[31:26];
				rs = inst[25:21];
				rt = inst[20:16];
				rd = inst[15:11];
				shamt = inst[10:6];
				funct = inst[5:0];
				immediate = inst[15:0];
				jump_address = inst[25:0];
				//mem_addr =  r[rs] + $signed(immediate);
            end else begin 
                next_state = S_EXEC;
				done=0;
			end 
        end
        S_EXEC: begin
			mem_addr =  r[rs] + $signed(immediate);
			if (done) begin
                next_state = S_OUT;
				done=1;
            end else begin
                next_state = S_EXEC;
			end
		end
        S_OUT:	begin
			next_state = S_IDLE;
			mem_wen = 1'b1;
			if(wb==1) begin	
				mem_addr =  r[rs] + $signed(immediate);
				r[rt] = mem_dout;
				wb=0;
			end
		end
		default: next_state = S_IDLE;
    endcase
end
endmodule
