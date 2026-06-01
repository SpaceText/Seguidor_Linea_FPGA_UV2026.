// ============================================================================
// Proyecto: Controlador Digital de Seguidor de Línea Competitivo (UV 2026)
// Módulo: filtro_arranque
//
// Descripción:
// Filtra la señal digital del sensor de luz (LDR) con histéresis de tiempo.
// Requiere que la luz sea detectada de forma continua durante al menos 10 ms
// (a 27 MHz) antes de activar la bandera de inicio (start_flag).
// Una vez activa, la bandera se enclava (queda en 1) hasta un reset físico.
// ============================================================================

module filtro_arranque (
    input  wire CLK,         // Reloj del sistema (27 MHz)
    input  wire RST,         // Reset activo en bajo
    input  wire LDR_IN,      // Entrada digital del comparador del LDR (1 = Luz detectada)
    output reg  start_flag   // Bandera de inicio habilitada (Enclavada en 1)
);

    // Parámetro para retardo de 10 ms a 27 MHz (10ms * 27,000,000 Hz = 270,000 ciclos)
    localparam [18:0] UMBRAL_FILTRO = 19'd270000;

    reg [18:0] contador;

    always @(posedge CLK or negedge RST) begin
        if (!RST) begin
            contador   <= 19'd0;
            start_flag <= 1'b0;
        end else begin
            if (start_flag) begin
                // Si ya inició la carrera, la bandera queda enclavada
                start_flag <= 1'b1;
            end else if (LDR_IN) begin
                // Incrementar el contador si detecta luz estable
                if (contador >= UMBRAL_FILTRO) begin
                    start_flag <= 1'b1; // Habilitar inicio definitivo
                end else begin
                    contador <= contador + 1'b1;
                end
            end else begin
                // Resetear contador ante cualquier caída (ruido o sombra momentánea)
                contador <= 19'd0;
            end
        end
    end

endmodule
