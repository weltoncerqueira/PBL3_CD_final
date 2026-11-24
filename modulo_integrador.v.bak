
module modulo_integrador (
    input [7:0] sw,
    input  chave,
    input botao,
    input clk,
    input reset,
    output [6:0] sel_abc,
    output led_busy,
    output led_done,
    // Saídas de vídeo físicas da placa
    output [3:0] VGA_R,
    output [3:0] VGA_G,
    output [3:0] VGA_B,
    output VGA_HS,
    output VGA_VS,
	 output [6:0] HEX0, HEX1, HEX2, 
	 output [6:0] HEX3, HEX4, HEX5
	);

    wire [7:0] reg_a1, reg_b1, reg_c1;
    wire [7:0] reg_a2, reg_b2, reg_c2;
    wire [2:0] count;
    
    wire botao_pulse; 
    wire rst_interno;
    
    not (rst_interno, reset);
     
    // Captura um pulso único do botão
    detector_de_borda borda_1 (
       .clk(clk),
       .rst(rst_interno),
       .sinal(botao),
       .pulso(botao_pulse)
    );
	 
    // Conta até 3, com base em cada pulso do botao
    contador_3b cont_3b(
       .clk(clk),
       .rst(rst_interno),
       .pulso(botao_pulse),
       .Q(count)
    );
	 
    // Decodifica o contador para escolher qual registrador receberá o valor das chaves
    decoder_abc decoder_abc(
       .count(count),
       .sel(sel_abc)
    );
	   
    // Registradores Função 1
    registrador_8b reg8_a11 (.D(sw), .enable(sel_abc[0]), .rst(rst_interno), .clk(clk), .S(reg_a1));
    registrador_8b reg8_b12 (.D(sw), .enable(sel_abc[1]), .rst(rst_interno), .clk(clk), .S(reg_b1));
    registrador_8b reg8_c13 (.D(sw), .enable(sel_abc[2]), .rst(rst_interno), .clk(clk), .S(reg_c1));
	 
    // Registradores Função 2
    registrador_8b reg8_a21 (.D(sw), .enable(sel_abc[3]), .rst(rst_interno), .clk(clk), .S(reg_a2));
    registrador_8b reg8_b22 (.D(sw), .enable(sel_abc[4]), .rst(rst_interno), .clk(clk), .S(reg_b2));
    registrador_8b reg8_c23 (.D(sw), .enable(sel_abc[5]), .rst(rst_interno), .clk(clk), .S(reg_c2));
	 
    //------------------------------------------------------------------
    // Fios e Controles para a Geração Sequencial (Contador X)
    //------------------------------------------------------------------
    wire [9:0] x_contador;
    wire fim_x_w;
    wire limpar_contador_w, habilitar_contagem_w;
    wire [9:0] vga_x, vga_y;
    wire video_on, p_tick;
    wire [9:0] x_cart;

    // 1. Instancia o controlador do contador X com base no estado da FSM
    controlador_contador_x u_ctrl_cont_x (
        .estado_atual(estado_atual_out),
        .reg_full(1'b0),
        .limpar_contador(limpar_contador_w),
        .habilitar_contagem(habilitar_contagem_w)
    );

    // 2. Instancia o contador X sequencial (0 a 639) controlado pela FSM
    contador_x u_cont_x (
        .clk(clk),
        .reset(rst_interno),
        .clear(limpar_contador_w),
        .en(habilitar_contagem_w),
        .x(x_contador),
        .fim_x(fim_x_w)
    );

	// Próxima coluna da varredura (H_MAX = 799)
	wire [9:0] x_prox = (vga_x == 10'd799) ? 10'd0 : (vga_x + 10'd1);

	transformador_coordenadas trans_coord_vga (
		 .x(x_prox),
		 .x_cart(x_cart)       // x_prox - 320
	);

	wire [10:0] x_cart_ext = {x_cart[9], x_cart};

    // 4. Instancia o controlador VGA (periférico de exibição)[cite: 3]
    vga_sync u_vga (
        .clk(clk),
        .reset(~reset),
        .hsync(VGA_HS),
        .vsync(VGA_VS),
        .video_on(video_on),
        .p_tick(p_tick),
        .x(vga_x),
        .y(vga_y)
    );

    // Fios de controle da FSM
    wire [2:0] estado_atual_out; 
    wire err_v1_w, err_v2_w, err_f1_w, err_f2_w;
    wire ativar_desenho_w, desenho_pronto_w;

    // 5. Instancia a Máquina de Estados Central (Apenas uma vez)
    maquina_central u_fsm_central (
        .clk(clk),
        .reset(rst_interno),
        .sel_d(chave),          
        .ovf_v1_in(ovf_v1),          
        .ovf_v2_in(ovf_v2),          
        .ovf_f1_in(ovf_f1),          
        .ovf_f2_in(ovf_f2),          
        .reg_full(1'b0),             
        .fim_x(fim_x_w),             // Conectado ao fim_x real do contador sequencial
        .err_v1(err_v1_w),
        .err_v2(err_v2_w),
        .err_f1(err_f1_w),
        .err_f2(err_f2_w),
        .ativar_desenho(ativar_desenho_w),
        .desenho_pronto(desenho_pronto_w),
        .led_busy(led_busy),
        .led_done(led_done),
        .estado_atual_out(estado_atual_out) 
    );
    
    wire [8:0]  Vx1, Vx2;
    wire [17:0] Vy1, Vy2;
	 wire [17:0] delta1, delta2;
    wire ovf_v1, ovf_f1;
    wire ovf_v2, ovf_f2;
	 
	 
	 
	 // MÓDULO QUE CALCULA  Δ = b² − 4ac
	 calculo_delta calc_delta_1 (
		.a(reg_a1),
		.b(reg_b1),
		.c(reg_c1),
		.delta(delta1),
		.overflow()
	 );
	 
	 // MÓDULO QUE CALCULA  Δ = b² − 4ac
	 calculo_delta calc_delta_2 (
		.a(reg_a2),
		.b(reg_b2),
		.c(reg_c2),
		.delta(delta2),
		.overflow()
	 );

    // Cálculo de Vértices Função 1
    calcula_vertices u_calc_vert1 (
        .a(reg_a1),
        .b(reg_b1),
        .delta(delta1), 
        .Vx(Vx1),
        .Vy(Vy1),
        .err_a0(ovf_f1),
        .err_v(ovf_v1)
    );

    // Cálculo de Vértices Função 2
    calcula_vertices u_calc_vert2 (
        .a(reg_a2),
        .b(reg_b2),
        .delta(delta2), 
        .Vx(Vx2),
        .Vy(Vy2),
        .err_a0(ovf_f2),
        .err_v(ovf_v2)
    );
	 
	wire [29:0] y_func1_c, y_func2_c;
	wire [19:0] y_deriv1_c, y_deriv2_c;

	calcula_y calcula_y1 (
		.x(x_cart_ext), 
		.a(reg_a1), 
		.b(reg_b1),
		.c(reg_c1),
		.overflow(), 
		.cout(), 
		.y(y_func1_c)
	);
	
	calcula_y calcula_y2 (
		.x(x_cart_ext), 
		.a(reg_a2), 
		.b(reg_b2), 
		.c(reg_c2),
		.overflow(), 
		.cout(), 
		.y(y_func2_c)
	);

	calcula_y_linha derivada_1 (
		.x(x_cart_ext), 
		.a(reg_a1), 
		.b(reg_b1), 
		.y_linha(y_deriv1_c)
	);
	
	calcula_y_linha derivada_2 (
		.x(x_cart_ext), 
		.a(reg_a2), 
		.b(reg_b2), 
		.y_linha(y_deriv2_c)
	);
	
	
	wire [29:0] y_func1, y_func2;
	wire [19:0] y_deriv1, y_deriv2;

	captura_y_fsm u_captura_y (
		 .clk(clk),
		 .rst(rst_interno),
		 .p_tick(p_tick),
		 .y_func1_c(y_func1_c),   .y_deriv1_c(y_deriv1_c),
		 .y_func2_c(y_func2_c),   .y_deriv2_c(y_deriv2_c),
		 .y_func1(y_func1),       .y_deriv1(y_deriv1),
		 .y_func2(y_func2),       .y_deriv2(y_deriv2),
		 .carrega()
	);
	
    // Fios para as cores do renderizador
    wire [3:0] r_out, g_out, b_out;
    
    assign VGA_R = r_out;
    assign VGA_G = g_out;
    assign VGA_B = b_out;

    // 6. Instancia o módulo de renderização gráfica (Restaurado)
	 renderizador_grafico u_render (
		 .clk(clk),
		 .rst(rst_interno),
		 .video_on(video_on),
		 .vga_x(vga_x),
		 .vga_y(vga_y),
		 .y_func1(y_func1),   .y_deriv1(y_deriv1),
		 .y_func2(y_func2),   .y_deriv2(y_deriv2),
		 .err_f1(err_f1_w),
		 .err_f2(err_f2_w),
		 .sistema_pronto(led_done),
		 .vga_r(r_out), .vga_g(g_out), .vga_b(b_out)
	 );
	 
	 //Mostra erro nos displays de 7 segmentos
	 display_erro_mux u_disp_erro (
		 .err_f1(err_f1_w), 
		 .err_f2(err_f2_w),
		 .err_v1(err_v1_w), 
		 .err_v2(err_v2_w),
		 .hex0(HEX0), 
		 .hex1(HEX1), 
		 .hex2(HEX2),
		 .hex3(HEX3),
		 .hex4(HEX4),
		 .hex5(HEX5)
	 );
	 
endmodule







