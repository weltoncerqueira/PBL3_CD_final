
module transformador_coordenadas (
    input wire [9:0] x,
    output wire [9:0] x_cart
);
    // Declaração de alimentação de nível lógico fixo (Supply)
    supply1 vcc;
    supply0 gnd;

    wire [9:0] b_inv;
    wire [10:0] c; // Fios de transporte (carries)

    // Inversão fixa dos bits da constante 320 ('0101000000') -> '1010111111'
    // Utilizando apenas buffers (buf) conforme restrição
    buf g_b9 (b_inv[9], vcc);
    buf g_b8 (b_inv[8], gnd);
    buf g_b7 (b_inv[7], vcc);
    buf g_b6 (b_inv[6], gnd);
    buf g_b5 (b_inv[5], vcc);
    buf g_b4 (b_inv[4], vcc);
    buf g_b3 (b_inv[3], vcc);
    buf g_b2 (b_inv[2], vcc);
    buf g_b1 (b_inv[1], vcc);
    buf g_b0 (b_inv[0], vcc);

    // Carry-in inicial fixo em 1 para fechar o complemento de dois (-320)
    buf g_cin (c[0], vcc);

    // Instanciação em cadeia de 10 Full Adders (Ripple-Carry Subtractor)
	 somador_completo fa0  (.A(x[0]), .B(b_inv[0]), .cin(c[0]), .S(x_cart[0]), .cout(c[1]));
    somador_completo fa1  (.A(x[1]), .B(b_inv[1]), .cin(c[1]), .S(x_cart[1]), .cout(c[2]));
    somador_completo fa2  (.A(x[2]), .B(b_inv[2]), .cin(c[2]), .S(x_cart[2]), .cout(c[3]));
    somador_completo fa3  (.A(x[3]), .B(b_inv[3]), .cin(c[3]), .S(x_cart[3]), .cout(c[4]));
    somador_completo fa4  (.A(x[4]), .B(b_inv[4]), .cin(c[4]), .S(x_cart[4]), .cout(c[5]));
    somador_completo fa5  (.A(x[5]), .B(b_inv[5]), .cin(c[5]), .S(x_cart[5]), .cout(c[6]));
    somador_completo fa6  (.A(x[6]), .B(b_inv[6]), .cin(c[6]), .S(x_cart[6]), .cout(c[7]));
    somador_completo fa7  (.A(x[7]), .B(b_inv[7]), .cin(c[7]), .S(x_cart[7]), .cout(c[8]));
    somador_completo fa8  (.A(x[8]), .B(b_inv[8]), .cin(c[8]), .S(x_cart[8]), .cout(c[9]));
    somador_completo fa9  (.A(x[9]), .B(b_inv[9]), .cin(c[9]), .S(x_cart[9]), .cout(c[10]));

endmodule