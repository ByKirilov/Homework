spaces = ['\n', '\t']
# source_file = 'qq.txt'
source_file = 'f.asm'
final_file = 'meat.txt'


def main():
    buffer = []
    empty_line = [0, 0]

    with open('font.fnt', 'rb') as f:
        font = f.read()
        with open(source_file, 'r') as file:
            line = file.readline().rstrip().replace(' \t', ' ')
            while line:
                for i in range(8):
                    bytes_line = [len(line)]
                    for j in range(len(line)):
                        sym = line[j]
                        if ord(line[j]) > 255 or line[j] in spaces:
                            sym = ' '
                        byte = font[ord(sym) * 8 + i]
                        bytes_line.append(byte)
                    bytes_line.append(len(line))
                    buffer.append(bytes_line)
                buffer.append(empty_line)
                line = file.readline()

    with open(final_file, 'wb') as file:
        file.write(bytes([(len(buffer) // 2) % 256]))
        if len(buffer) // 2 > 255:
            file.write(bytes([(len(buffer) // 2) // 256]))
        else:
            file.write(bytes([0]))

        last_byte_offset = 0
        for line in buffer:
            for byte in line:
                last_byte_offset += 1

        last_byte_offset -= 1

        # f_word = last_byte_offset % (256 * 256)
        # s_word = last_byte_offset // (256 * 256)
        #
        # file.write(bytes([f_word % 256]))
        # if f_word > 255:
        #     file.write(bytes([f_word // 256]))
        # else:
        #     file.write(bytes([0]))
        #
        # file.write(bytes([s_word % 256]))
        # if s_word > 255:
        #     file.write(bytes([s_word // 256]))
        # else:
        #     file.write(bytes([0]))

        file.write(bytes([last_byte_offset % 256]))
        if last_byte_offset > 255:
            file.write(bytes([last_byte_offset // 256]))
        else:
            file.write(bytes([0]))

        for line in buffer:
            for byte in line:
                if type(byte) == type(1):
                    file.write(bytes([byte]))
                else:
                    file.write(byte)


if __name__ == '__main__':
    main()
