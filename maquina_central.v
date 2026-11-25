
module maquina_central (
    input clk,
    input reset,
    input sel_d,
    input ovf_v1_in,
    input ovf_v2_in,
    input ovf_f1_in,
    input ovf_f2_in,
    input fim_x,

    output reg err_v1,
    output reg err_v2,
    output reg err_f1,
    output reg err_f2,
    output reg led_busy,
    output reg led_done
	);

    localparam [1:0]
        INICIO          = 2'b00,
        CALCULA_VERTICE = 2'b01,
        BUSY            = 2'b10,
        CONCLUIDO       = 2'b11;

    reg [1:0] estado_atual, proximo_estado;

    // Registrador de estado
    always @(posedge clk or posedge reset) begin
        if (reset) estado_atual <= INICIO;
        else       estado_atual <= proximo_estado;
    end

    // Próximo estado
    always @(*) begin
        proximo_estado = estado_atual;
        case (estado_atual)
            INICIO:          proximo_estado = (sel_d) ? CALCULA_VERTICE : INICIO;
            CALCULA_VERTICE: proximo_estado = BUSY;
            BUSY:            proximo_estado = (fim_x) ? CONCLUIDO : BUSY;
            CONCLUIDO:       proximo_estado = CONCLUIDO;
            default:         proximo_estado = INICIO;
        endcase
    end

    // Saídas
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            err_v1 <= 1'b0; err_v2 <= 1'b0;
            err_f1 <= 1'b0; err_f2 <= 1'b0;
            led_busy <= 1'b0; led_done <= 1'b0;
        end else begin
            // Flags de erro seguem as entradas fora do INICIO
            if (estado_atual != INICIO) begin
                err_v1 <= ovf_v1_in;
                err_v2 <= ovf_v2_in;
                err_f1 <= ovf_f1_in;
                err_f2 <= ovf_f2_in;
            end

            case (estado_atual)
                INICIO: begin
                    err_v1 <= 1'b0; err_v2 <= 1'b0;
                    err_f1 <= 1'b0; err_f2 <= 1'b0;
                    led_busy <= 1'b0;
                    led_done <= 1'b0;
                end
                CALCULA_VERTICE: led_busy <= 1'b1;
                BUSY:            led_busy <= 1'b1;
                CONCLUIDO: begin
                    led_busy <= 1'b0;
                    led_done <= 1'b1;
                end
            endcase
        end
    end

endmodule