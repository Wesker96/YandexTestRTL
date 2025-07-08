//========================================================================================================================
//                                                     Description
//========================================================================================================================
/*

Engineer   : HammerMeow
Date       : 07.07.2025 | 23:17

Description: test module for Yandex

На вход модуля непрерывно поступает поток данных, модуль обеспечивает приём и сортировку входных данных таким образом,
что выходные данные модуля содержат 4 последних различных числа, поступивших на вход.

Решение предоставьте в файле test_module.sv, в котором опишите модуль test_module с приведённым выше интерфейсом (интерфейс, имя модуля и имя файла менять нельзя).

Требования:
 - входные данные обновляются каждый такт;
 - сброс модуля синхронный, active high, длительностью не менее 1 такта;
 - в состоянии сброса все выходы модуля должны быть выставлены в 0;
 - входные данные должны быть приняты на первом такте после снятия сигнала сброса;
 - выходные данные должны обновляться на второй такт после изменения входных данных;
 - выходные данные должны быть отображены в порядке, обратном поступлению: на out_0 — самые новые данные, на out_3 — самые старые;
 - если выходные данные не валидны, то они должны быть выставлены в 0, как и соответствующие им сигналы валидности.
 - код должен быть синтезируемым.

Пример №1:
На вход после сброса поступила последовательность: 1 2 1 2 1 2 |1.
В момент приёма последнего числа модуль должен выдать на выходе:
out_0: 2, out_valid_0: 1;
out_1: 1, out_valid_1: 1;
out_2: 0, out_valid_2: 0;
out_3: 0, out_valid_3: 0.

Пример №2:
На вход после сброса поступила последовательность: 1 2 3 4 3 2 3 4 3 |4.
0. 0 0 0 1
1. 0 0 1 2
2. 0 1 2 3
3. 1 2 3 4
4. 1 2 4 3
5. 1 4 3 2
6. 1 4 2 3
7. 1 2 3 4
8. 1 2 4 3

В момент приёма последнего числа модуль должен выдать на выходе:
out_0: 3, out_valid_0: 1;
out_1: 4, out_valid_1: 1;
out_2: 2, out_valid_2: 1;
out_3: 1, out_valid_3: 1.

*/
//========================================================================================================================

module test_module
#(
    parameter DATA_W = 8
)(
    input logic                     clk_in,
    input logic                     reset_in,

    input logic [(DATA_W-1):0]      data_in,

    output logic [(DATA_W-1):0]     out_0,
    output logic                    out_valid_0,
    output logic [(DATA_W-1):0]     out_1,
    output logic                    out_valid_1,
    output logic [(DATA_W-1):0]     out_2,
    output logic                    out_valid_2,
    output logic [(DATA_W-1):0]     out_3,
    output logic                    out_valid_3
);

//========================================================================================================================
//                                                        Logic
//========================================================================================================================

logic [(DATA_W-1):0] data_in_buf = 0;

logic out_0_reg_en;
logic out_1_reg_en;
logic out_2_reg_en;
logic out_3_reg_en;

logic [(DATA_W-1):0] out_0_reg = 0;
logic [(DATA_W-1):0] out_1_reg = 0;
logic [(DATA_W-1):0] out_2_reg = 0;
logic [(DATA_W-1):0] out_3_reg = 0;

logic out_0_reg_latch = 0;
logic out_1_reg_latch = 0;
logic out_2_reg_latch = 0;
logic out_3_reg_latch = 0;

logic out_0_xor;
logic out_1_xor;
logic out_2_xor;
logic out_3_xor;

//========================================================================================================================
//                                                       Behavior
//========================================================================================================================

/*
Комментари к задаче (допущения):
 - явно не указано что такое "выходные данные не валидны" - допустил, что не валидные выходные данные:
   это состояние регистра (на котором после сброса логический 0), который еще ниразу не обновлялся.

 - явно не указано как обрабатывать 0 на входе на старте, является ли он для модуля валидными данными:
   допустил, что не является, т.е. мы ожидаем ненулевое число.

Результат синтеза:
+-------------------------+------+-------+------------+-----------+-------+
|        Site Type        | Used | Fixed | Prohibited | Available | Util% |
+-------------------------+------+-------+------------+-----------+-------+
| Slice LUTs*             |   20 |     0 |          0 |     53200 |  0.04 |
|   LUT as Logic          |   20 |     0 |          0 |     53200 |  0.04 |
|   LUT as Memory         |    0 |     0 |          0 |     17400 |  0.00 |
| Slice Registers         |   36 |     0 |          0 |    106400 |  0.03 |
|   Register as Flip Flop |   36 |     0 |          0 |    106400 |  0.03 |
|   Register as Latch     |    0 |     0 |          0 |    106400 |  0.00 |
| F7 Muxes                |    0 |     0 |          0 |     26600 |  0.00 |
| F8 Muxes                |    0 |     0 |          0 |     13300 |  0.00 |
+-------------------------+------+-------+------------+-----------+-------+

Подбор и расчетная оценка быстродействия схемы на этапе синтеза:
Constarins (for Device=7z020 Package=clg484 Speed=-2):
create_clock -period 3.55 [get_ports clk_in]

report_timing_summary
WNS:  0.036 ns
WHS:  0.147 ns
WPWS: 1.275 ns
*/

//========================================================================================================================

always_comb begin: proc_test_module_get_uniq
    out_0_xor = |(data_in^out_0_reg);
    out_1_xor = |(data_in^out_1_reg);
    out_2_xor = |(data_in^out_2_reg);
    out_3_xor = |(data_in^out_3_reg);
end

always_comb begin: proc_test_module_gen_enable
    out_0_reg_en = out_0_xor;
    out_1_reg_en = out_0_reg_latch&out_0_xor;
    out_2_reg_en = out_1_reg_latch&out_0_xor&out_1_xor;
    out_3_reg_en = out_2_reg_latch&out_0_xor&out_1_xor&out_2_xor;
end

//------------------------------------------------------------------------------------------------------------------------

always_ff @(posedge clk_in) begin : proc_test_module_gen_valid
    if(reset_in) begin
        out_0_reg_latch <= 0;
        out_1_reg_latch <= 0;
        out_2_reg_latch <= 0;
        out_3_reg_latch <= 0;
    end else begin
        out_0_reg_latch <= out_0_reg_latch|out_0_reg_en;
        out_1_reg_latch <= out_1_reg_latch|out_1_reg_en;
        out_2_reg_latch <= out_2_reg_latch|out_2_reg_en;
        out_3_reg_latch <= out_3_reg_latch|out_3_reg_en;
    end
end

//------------------------------------------------------------------------------------------------------------------------

always_ff @(posedge clk_in) begin: proc_test_module_data_out
    if(reset_in) begin
        out_0_reg <= 0;
        out_1_reg <= 0;
        out_2_reg <= 0;
        out_3_reg <= 0;
    end else begin
        if (out_0_reg_en) begin
            out_0_reg <= data_in;
        end

        if (out_1_reg_en) begin
            out_1_reg <= out_0_reg;
        end

        if (out_2_reg_en) begin
            out_2_reg <= out_1_reg;
        end

        if (out_3_reg_en) begin
            out_3_reg <= out_2_reg;
        end
    end
end

//------------------------------------------------------------------------------------------------------------------------

assign out_0       = out_0_reg;
assign out_valid_0 = out_0_reg_latch;
assign out_1       = out_1_reg;
assign out_valid_1 = out_1_reg_latch;
assign out_2       = out_2_reg;
assign out_valid_2 = out_2_reg_latch;
assign out_3       = out_3_reg;
assign out_valid_3 = out_3_reg_latch;

endmodule
