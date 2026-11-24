// fim_x = 1 quando vga_x = 639 (última coluna visível)
module detecta_fim_x (
    input  wire [9:0] x,
    output wire       fim_x
);
    wire n8, n7;
    not g_n8 (n8, x[8]);
    not g_n7 (n7, x[7]);
    and g_fim (fim_x, x[9], n8, n7, x[6], x[5], x[4], x[3], x[2], x[1], x[0]);
endmodule