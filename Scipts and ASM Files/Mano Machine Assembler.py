pgm = []
symbols = {}


with open("asm.txt") as file:
    for line in file:
        pgm.append(line.split())

pgm = pgm[:-1]
start = int(pgm[0][1], 16)
for i in range(len(pgm)-1):
    pgm[i+1].append(hex(i+start))
    if "," in pgm[i+1][0]:
        symbol = pgm[i+1].pop(0)
        symbols[symbol[:-1]] = hex(i + start)

object_code = []

for instruction in pgm[1:]:
    hex_code = ""
    match instruction[0]:

        case "AND":
            if "I" in instruction:
                hex_code += "8"
            else:
                hex_code += "0"

            hex_code += f"{int(symbols[instruction[1]][2:], 16):03X}"


        case "ADD":
            if "I" in instruction:
                hex_code += "9"
            else:
                hex_code += "1"

            hex_code += f"{int(symbols[instruction[1]][2:], 16):03X}"


        case "LDA":
            if "I" in instruction:
                hex_code += "A"
            else:
                hex_code += "2"

            hex_code += f"{int(symbols[instruction[1]][2:], 16):03X}"

        
        case "STA":
            if "I" in instruction:
                hex_code += "B"
            else:
                hex_code += "3"

            hex_code += f"{int(symbols[instruction[1]][2:], 16):03X}"


        case "BUN":
            if "I" in instruction:
                hex_code += "C"
            else:
                hex_code += "4"

            hex_code += f"{int(symbols[instruction[1]][2:], 16):03X}"


        case "BSA":
            if "I" in instruction:
                hex_code += "D"
            else:
                hex_code += "5"

            hex_code += f"{int(symbols[instruction[1]][2:], 16):03X}"


        case "ISZ":
            if "I" in instruction:
                hex_code += "E"
            else:
                hex_code += "6"

            hex_code += f"{int(symbols[instruction[1]][2:], 16):03X}"


        case "CLA":
            hex_code += "7800"

        case "CLE":
            hex_code += "7400"

        case "CMA":
            hex_code += "7200"

        case "CME":
            hex_code += "7100"

        case "CIR":
            hex_code += "7080"

        case "CIL":
            hex_code += "7040"

        case "INC":
            hex_code += "7020"            

        case "SPA":
            hex_code += "7010"

        case "SNA":
            hex_code += "7008"

        case "SZA":
            hex_code += "7004"

        case "SZE":
            hex_code += "7002"

        case "HLT":
            hex_code += "7001"

        case "INP":
            hex_code += "F800"

        case "OUT":
            hex_code += "F400"

        case "SKI":
            hex_code += "F200"

        case "SKO":
            hex_code += "F100"

        case "ION":
            hex_code += "F080"

        case "IOF":
            hex_code += "F040"            

        case "DEC":
            value = int(instruction[1])
            signed_hex = f"{value & 0xFFFF:04X}"  
            hex_code += signed_hex

        case "HEX":
            hex_code += f"{int(instruction[1], 16) & 0xFFFF:04x}"

    object_code.append(hex_code)

for i in range(len(pgm)-1):
    print(f"pgm[{start+i}]  = 16'h{object_code[i]};")
input("Press Enter to exit...")
        







            






            
