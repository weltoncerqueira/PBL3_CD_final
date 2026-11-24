
// Seleciona o erro e mostra "F1", "V1", "F2" ou "V2" (V desenhado como U)
// Índice dos segmentos: [0]=a ... [6]=g. Saídas ativas em baixo.
module display_erro_mux (
    input  err_f1, err_f2,        // a = 0
    input  err_v1, err_v2,        // vértice fora da tela
    output [6:0] hex0, hex1, hex2, hex3, hex4, hex5
);
    supply1 vcc;
    supply0 gnd;

    // ---------------- Filtro e prioridade ----------------
    wire n_f1, n_f2, e_v1, e_v2, n_ev1, f2_ou_v2, t_v2, v1_ou_t;
    wire any, s1, s0;

    not g_nf1 (n_f1, err_f1);
    not g_nf2 (n_f2, err_f2);

    and g_ev1 (e_v1, err_v1, n_f1);       // V1 só se a1 != 0
    and g_ev2 (e_v2, err_v2, n_f2);       // V2 só se a2 != 0

    or  g_any (any, err_f1, e_v1, err_f2, e_v2);

    not g_nev1 (n_ev1, e_v1);
    or  g_f2v2 (f2_ou_v2, err_f2, e_v2);
    and g_s1   (s1, n_f1, n_ev1, f2_ou_v2);

    and g_tv2  (t_v2, n_f2, e_v2);
    or  g_v1t  (v1_ou_t, e_v1, t_v2);
    and g_s0   (s0, n_f1, v1_ou_t);

    // ---------------- Padrões de segmentos (1 = aceso) ----------------
    wire [6:0] pat_F, pat_V, pat_1, pat_2;

    //            a    b    c    d    e    f    g
    buf (pat_F[0], vcc); buf (pat_F[1], gnd); buf (pat_F[2], gnd); buf (pat_F[3], gnd);
    buf (pat_F[4], vcc); buf (pat_F[5], vcc); buf (pat_F[6], vcc);

    buf (pat_V[0], gnd); buf (pat_V[1], vcc); buf (pat_V[2], vcc); buf (pat_V[3], vcc);
    buf (pat_V[4], vcc); buf (pat_V[5], vcc); buf (pat_V[6], gnd);

    buf (pat_1[0], gnd); buf (pat_1[1], vcc); buf (pat_1[2], vcc); buf (pat_1[3], gnd);
    buf (pat_1[4], gnd); buf (pat_1[5], gnd); buf (pat_1[6], gnd);

    buf (pat_2[0], vcc); buf (pat_2[1], vcc); buf (pat_2[2], gnd); buf (pat_2[3], vcc);
    buf (pat_2[4], vcc); buf (pat_2[5], gnd); buf (pat_2[6], vcc);

    // ---------------- Multiplexadores ----------------
    wire [6:0] letra, numero;

    mux2_7b mux_letra  (.s(s0), .d0(pat_F), .d1(pat_V), .y(letra));
    mux2_7b mux_numero (.s(s1), .d0(pat_1), .d1(pat_2), .y(numero));

    // ---------------- Habilitação e inversão (ativo em baixo) ----------------
    nand (hex1[0], letra[0], any);
    nand (hex1[1], letra[1], any);
    nand (hex1[2], letra[2], any);
    nand (hex1[3], letra[3], any);
    nand (hex1[4], letra[4], any);
    nand (hex1[5], letra[5], any);
    nand (hex1[6], letra[6], any);

    nand (hex0[0], numero[0], any);
    nand (hex0[1], numero[1], any);
    nand (hex0[2], numero[2], any);
    nand (hex0[3], numero[3], any);
    nand (hex0[4], numero[4], any);
    nand (hex0[5], numero[5], any);
    nand (hex0[6], numero[6], any);

    // ---------------- Displays não usados: apagados ----------------
    buf (hex2[0], hex2[1], hex2[2], hex2[3], hex2[4], hex2[5], hex2[6], vcc);
    buf (hex3[0], hex3[1], hex3[2], hex3[3], hex3[4], hex3[5], hex3[6], vcc);
    buf (hex4[0], hex4[1], hex4[2], hex4[3], hex4[4], hex4[5], hex4[6], vcc);
    buf (hex5[0], hex5[1], hex5[2], hex5[3], hex5[4], hex5[5], hex5[6], vcc);

endmodule

// Mux 2:1 de 1 bit: y = (~s & d0) | (s & d1)
module mux2_1b (
    input  s, d0, d1,
    output y
);
    wire ns, t0, t1;
    not g_ns (ns, s);
    and g_t0 (t0, ns, d0);
    and g_t1 (t1, s,  d1);
    or  g_y  (y, t0, t1);
endmodule


// Mux 2:1 de 7 bits (um por segmento)
module mux2_7b (
    input        s,
    input  [6:0] d0, d1,
    output [6:0] y
);
    mux2_1b m0 (.s(s), .d0(d0[0]), .d1(d1[0]), .y(y[0]));
    mux2_1b m1 (.s(s), .d0(d0[1]), .d1(d1[1]), .y(y[1]));
    mux2_1b m2 (.s(s), .d0(d0[2]), .d1(d1[2]), .y(y[2]));
    mux2_1b m3 (.s(s), .d0(d0[3]), .d1(d1[3]), .y(y[3]));
    mux2_1b m4 (.s(s), .d0(d0[4]), .d1(d1[4]), .y(y[4]));
    mux2_1b m5 (.s(s), .d0(d0[5]), .d1(d1[5]), .y(y[5]));
    mux2_1b m6 (.s(s), .d0(d0[6]), .d1(d1[6]), .y(y[6]));
endmodule
