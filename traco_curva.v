
module traco_curva (
    input  wire              clk,
    input  wire [9:0]        vga_x,
    input  wire [9:0]        vga_y,
    input  wire signed [31:0] ys,   // linha da tela da coluna atual (240 - y)
    input  wire              en,
    output wire              hit
);
    reg [9:0]         x_q;
    reg signed [31:0] ys_q, prev_hold;

    wire x_changed = (vga_x != x_q);

    always @(posedge clk) begin
        x_q   <= vga_x;
        ys_q  <= ys;
        if (x_changed) prev_hold <= ys_q;   // guarda o y da coluna anterior
    end

    // coluna 0: sem coluna anterior (evita traço do fim da linha anterior)
    wire signed [31:0] prev = (vga_x == 10'd0) ? ys :
                              (x_changed ? ys_q : prev_hold);

    // clipping: acima (<0) ou abaixo (>479) da tela
    wire cur_up  = (ys   < 32'sd0);
    wire cur_dn  = (ys   > 32'sd479);
    wire prv_up  = (prev < 32'sd0);
    wire prv_dn  = (prev > 32'sd479);

    wire [9:0] cur_c = cur_up ? 10'd0 : (cur_dn ? 10'd479 : ys[9:0]);
    wire [9:0] prv_c = prv_up ? 10'd0 : (prv_dn ? 10'd479 : prev[9:0]);

    wire [9:0] lo = (cur_c < prv_c) ? cur_c : prv_c;
    wire [9:0] hi = (cur_c < prv_c) ? prv_c : cur_c;

    // se as duas colunas estão fora do mesmo lado, não desenha nada
    wire fora = (cur_up && prv_up) || (cur_dn && prv_dn);

    assign hit = en && !fora && (vga_y >= lo) && (vga_y <= hi);
	 
endmodule