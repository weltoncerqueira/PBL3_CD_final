// FSM que sincroniza a captura dos valores de y com o avanço do pixel da VGA.
// ESPERA  : ciclo em que p_tick = 0 (os cálculos combinacionais estabilizam)
// CAPTURA : ciclo em que p_tick = 1 (vga_x avança; os registradores carregam)
module captura_y_fsm (
    input  wire        clk,
    input  wire        rst,        // ativo em alto
    input  wire        p_tick,     // tick de pixel do vga_sync
    input  wire [29:0] y_func1_c,
    input  wire [19:0] y_deriv1_c,
    input  wire [29:0] y_func2_c,
    input  wire [19:0] y_deriv2_c,
    output reg  [29:0] y_func1,
    output reg  [19:0] y_deriv1,
    output reg  [29:0] y_func2,
    output reg  [19:0] y_deriv2,
    output wire        carrega     // útil para depuração/simulação
);

    localparam ESPERA  = 1'b0,
               CAPTURA = 1'b1;

    reg estado, proximo;

    // Registrador de estado
    always @(posedge clk or posedge rst) begin
        if (rst) estado <= ESPERA;
        else     estado <= proximo;
    end

    // Próximo estado: p_tick = 0 indica que o próximo ciclo terá p_tick = 1
    always @(*) begin
        case (estado)
            ESPERA:  proximo = (p_tick == 1'b0) ? CAPTURA : ESPERA;
            CAPTURA: proximo = ESPERA;
            default: proximo = ESPERA;
        endcase
    end

    // Saída de Moore
    assign carrega = (estado == CAPTURA);

    // Registradores de dados, carregados apenas em CAPTURA
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            y_func1  <= 30'd0;
            y_func2  <= 30'd0;
            y_deriv1 <= 20'd0;
            y_deriv2 <= 20'd0;
        end else if (carrega) begin
            y_func1  <= y_func1_c;
            y_func2  <= y_func2_c;
            y_deriv1 <= y_deriv1_c;
            y_deriv2 <= y_deriv2_c;
        end
    end

endmodule