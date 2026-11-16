module uart_rx(
    input               uart_clk,
    input               rst_n,
    input               rxd,
    
    output  reg         rx_data_flag,
    output  reg [23:0]  rx_data // Change to 24 bits to accommodate RGB888 data
);

    reg     [7:0]   cnt;
    reg             state;
    reg     [1:0]   byte_cnt; // Counter to keep track of received bytes

    parameter       s0  = 1'b0;
    parameter       s1  = 1'b1;
    
    `define         EP      153   // End point

    always  @   (posedge uart_clk, negedge rst_n)   begin
        if(rst_n == 1'b0) begin
            cnt <= 8'd0;
            state <= s0;
            byte_cnt <= 2'd0; // Initialize byte counter
        end
        else
            case(state)
                s0      :   if(rxd == 1'b0)
                                state <= s1;
                            else
                                state <= s0;
                                
                s1      :   if(cnt < `EP)
                                cnt <= cnt  +   1'd1;
                            else    begin
                                cnt <= 8'd0;
                                state <= s0;
                                byte_cnt <= (byte_cnt == 2'd2) ? 2'd0 : byte_cnt + 2'd1; // Increment byte counter and wrap around after 3 bytes
                            end
                                
                default :   state <= s0;
            endcase
    end
    
    
    always  @   (posedge uart_clk, negedge rst_n)   begin
        if(rst_n == 1'b0) begin
            rx_data <= 24'h0; // Initialize 24-bit data
            rx_data_flag <= 1'b0;
        end
        else
            case(cnt)
                7   +   1   *   16      :   begin
                    case(byte_cnt)
                        2'd0: rx_data[0] <= rxd;
                        2'd1: rx_data[8] <= rxd;
                        2'd2: rx_data[16] <= rxd;
                    endcase
                end
                7   +   2   *   16      :   begin
                    case(byte_cnt)
                        2'd0: rx_data[1] <= rxd;
                        2'd1: rx_data[9] <= rxd;
                        2'd2: rx_data[17] <= rxd;
                    endcase
                end
                7   +   3   *   16      :   begin
                    case(byte_cnt)
                        2'd0: rx_data[2] <= rxd;
                        2'd1: rx_data[10] <= rxd;
                        2'd2: rx_data[18] <= rxd;
                    endcase
                end
                7   +   4   *   16      :   begin
                    case(byte_cnt)
                        2'd0: rx_data[3] <= rxd;
                        2'd1: rx_data[11] <= rxd;
                        2'd2: rx_data[19] <= rxd;
                    endcase
                end
                7   +   5   *   16      :   begin
                    case(byte_cnt)
                        2'd0: rx_data[4] <= rxd;
                        2'd1: rx_data[12] <= rxd;
                        2'd2: rx_data[20] <= rxd;
                    endcase
                end
                7   +   6   *   16      :   begin
                    case(byte_cnt)
                        2'd0: rx_data[5] <= rxd;
                        2'd1: rx_data[13] <= rxd;
                        2'd2: rx_data[21] <= rxd;
                    endcase
                end
                7   +   7   *   16      :   begin
                    case(byte_cnt)
                        2'd0: rx_data[6] <= rxd;
                        2'd1: rx_data[14] <= rxd;
                        2'd2: rx_data[22] <= rxd;
                    endcase
                end
                7   +   8   *   16      :   begin
                    case(byte_cnt)
                        2'd0: rx_data[7] <= rxd;
                        2'd1: rx_data[15] <= rxd;
                        2'd2: rx_data[23] <= rxd;
                    endcase
                end
                7   +   9   *   16  + 1:   rx_data_flag <= (byte_cnt == 2'd2) ? 1'b1 : 1'b0;
                7   +   9   *   16  + 2:   rx_data_flag <= 1'b0;
            endcase

    end
    
    
endmodule