
module renderizador_grafico (
    input  wire        clk,
    input  wire        rst,           // ativo em alto (ligar em rst_interno)
    input  wire        video_on,
    input  wire [9:0]  vga_x,
    input  wire [9:0]  vga_y,
    input  wire [29:0] y_func1,
    input  wire [19:0] y_deriv1,
    input  wire [29:0] y_func2,
    input  wire [19:0] y_deriv2,
    input  wire        err_f1,
    input  wire        err_f2,
    input  wire        habilita_f2,   // 1 = desenha a função 2 (sel_func)
    input  wire        sistema_pronto,
    output reg  [3:0]  vga_r,
    output reg  [3:0]  vga_g,
    output reg  [3:0]  vga_b
);

    // ------------------------------------------------------------------
    // Datapath: eixos, conversão y -> linha da tela (240 - y) e acertos
    // ------------------------------------------------------------------
    wire hit_eixos = (vga_x == 10'd320) || (vga_y == 10'd240);

    wire signed [31:0] y_f1_ext = {{2{y_func1[29]}},   y_func1};
    wire signed [31:0] y_d1_ext = {{12{y_deriv1[19]}}, y_deriv1};
    wire signed [31:0] y_f2_ext = {{2{y_func2[29]}},   y_func2};
    wire signed [31:0] y_d2_ext = {{12{y_deriv2[19]}}, y_deriv2};

    wire signed [31:0] ys_f1 = 32'sd240 - y_f1_ext;
    wire signed [31:0] ys_d1 = 32'sd240 - y_d1_ext;
    wire signed [31:0] ys_f2 = 32'sd240 - y_f2_ext;
    wire signed [31:0] ys_d2 = 32'sd240 - y_d2_ext;

    // Clipping: só desenha se a linha estiver em 0..479
    wire ok_f1 = (ys_f1 >= 32'sd0) && (ys_f1 < 32'sd480);
    wire ok_d1 = (ys_d1 >= 32'sd0) && (ys_d1 < 32'sd480);
    wire ok_f2 = (ys_f2 >= 32'sd0) && (ys_f2 < 32'sd480);
    wire ok_d2 = (ys_d2 >= 32'sd0) && (ys_d2 < 32'sd480);

    // Um pixel por valor de x. A função 2 só é desenhada se habilitada.
    wire hit_parabola1 = sistema_pronto && !err_f1 && ok_f1 && (vga_y == ys_f1[9:0]);
    wire hit_derivada1 = sistema_pronto && !err_f1 && ok_d1 && (vga_y == ys_d1[9:0]);
    wire hit_parabola2 = sistema_pronto && habilita_f2 && !err_f2 && ok_f2 && (vga_y == ys_f2[9:0]);
    wire hit_derivada2 = sistema_pronto && habilita_f2 && !err_f2 && ok_d2 && (vga_y == ys_d2[9:0]);

    // ------------------------------------------------------------------
    // FSM de cor (Moore): um estado por cor
    // ------------------------------------------------------------------
    localparam [2:0]
        ST_BLANK = 3'd0,   // fora da área visível -> preto
        ST_P1    = 3'd1,   // parábola 1  -> vermelho
        ST_D1    = 3'd2,   // derivada 1  -> amarelo
        ST_P2    = 3'd3,   // parábola 2  -> verde
        ST_D2    = 3'd4,   // derivada 2  -> ciano
        ST_EIXO  = 3'd5,   // eixos       -> preto
        ST_FUNDO = 3'd6;   // fundo       -> branco

    reg [2:0] estado, proximo;

    // Registrador de estado
    always @(posedge clk or posedge rst) begin
        if (rst) estado <= ST_BLANK;
        else     estado <= proximo;
    end

    // Próximo estado (prioridade: P1 > D1 > P2 > D2 > eixos > fundo)
    always @(*) begin
        if      (!video_on)      proximo = ST_BLANK;
        else if (hit_parabola1)  proximo = ST_P1;
        else if (hit_derivada1)  proximo = ST_D1;
        else if (hit_parabola2)  proximo = ST_P2;
        else if (hit_derivada2)  proximo = ST_D2;
        else if (hit_eixos)      proximo = ST_EIXO;
        else                     proximo = ST_FUNDO;
    end

    // Saídas (Moore): dependem apenas do estado
    always @(*) begin
        case (estado)
            ST_BLANK: begin vga_r = 4'h0; vga_g = 4'h0; vga_b = 4'h0; end // preto
            ST_P1:    begin vga_r = 4'hF; vga_g = 4'h0; vga_b = 4'h0; end // vermelho (parábola 1)
            ST_D1:    begin vga_r = 4'hF; vga_g = 4'hF; vga_b = 4'h0; end // amarelo (derivada 1)
            ST_P2:    begin vga_r = 4'h0; vga_g = 4'hF; vga_b = 4'h0; end // verde (parábola 2)
            ST_D2:    begin vga_r = 4'h0; vga_g = 4'hF; vga_b = 4'hF; end // ciano (derivada 2)
            ST_EIXO:  begin vga_r = 4'h0; vga_g = 4'h0; vga_b = 4'h0; end // eixos em preto
            ST_FUNDO: begin vga_r = 4'hF; vga_g = 4'hF; vga_b = 4'hF; end // fundo branco
            default:  begin vga_r = 4'h0; vga_g = 4'h0; vga_b = 4'h0; end
        endcase
    end

endmodule