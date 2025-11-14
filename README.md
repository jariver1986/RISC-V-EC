🔥 1️⃣ OPCODE (bits 6:0)

👉 Dice el tipo general de instrucción.

Ejemplos:

opcode	Significa
0110011	R-type (ADD, SUB, AND…)
0010011	I-type (ADDI, ORI…)
0000011	LOAD
0100011	STORE
1100011	BEQ, BNE (branches)

💡 Es como decirle al CPU:
"Esto es una suma, un load, un salto, etc."

La Unidad de Control (CU) usa opcode para decidir:

si hay escritura en registros (wer)

si se usa la memoria (wem, men)

qué va a hacer la ALU (alu_op)

si se debe usar inmediato o un registro (alu_scr)

si se debe hacer un branch (ci_en)

🔥 2️⃣ RD (bits 11:7)

👉 Número del registro destino
Es donde se guardará el resultado.

Ejemplo:

ADDI x2, x0, 5
         ↑ rd = 2

🔥 3️⃣ func3 (bits 14:12)

👉 Selecciona la operación específica dentro del opcode.

Ejemplos:

func3	op	significado
000	ADD	suma
000	SUB	resta (si funct7 = 0100000)
111	AND	and bit-a-bit
110	OR	or bit-a-bit
100	XOR	xor bit-a-bit
010	SLT	signed less than
011	SLTU	unsigned less than

La CU lee func3 para decidir el opcode de la ALU.

🔥 4️⃣ RS1 (bits 19:15)

👉 Primer registro fuente

Ejemplo:

ADD x3, x1, x2
           ↑ rs1 = 1


Es el primer operando que va a leer el banco de registros (reg_b).

🔥 5️⃣ RS2 (bits 24:20)

👉 Segundo registro fuente

Ejemplo:

ADD x3, x1, x2
               ↑ rs2 = 2


Es el segundo operando para la ALU o para un STORE.

🔥 6️⃣ funct7 (bits 31:25)

👉 Distinguye instrucciones que tienen el mismo func3/opcode.

Ejemplo clásico:

Instrucción	funct7	func3	opcode
ADD	0000000	000	0110011
SUB	0100000	000	0110011

La ALU usa funct7 + func3 para decidir entre ADD y SUB.

🧩 En conjunto, estos campos permiten que el procesador:

sepa qué operación hacer (opcode + funct3 + funct7)

sepa qué registros leer (rs1, rs2)

sepa dónde guardar el resultado (rd)

sepa si debe usar inmediato

sepa si debe saltar (BEQ/BNE)

sepa si debe acceder a memoria

👉 En pocas palabras: reproducen completamente el funcionamiento del CPU.

⭐ RESUMEN EN UNA FRASE

Los 32 bits de la instrucción se dividen en campos que permiten al CPU saber qué operación realizar, con qué registros y dónde guardar el resultado.

¿Quieres un esquema visual tipo diagrama ASCII para imprimir o estudiar?

Puedo generártelo así:

31      25 24   20 19   15 14 12 11    7 6      0
+---------+-------+-------+-----+-------+---------+
| funct7  |  rs2  |  rs1  |funct3|  rd  |  opcode |
+---------+-------+-------+-----+-------+---------+
