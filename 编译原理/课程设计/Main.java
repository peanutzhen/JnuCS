import java.io.*;
import java.util.Arrays;
import java.util.HashMap;
import java.util.Map;

public class Main {
    public static void main(String[] args) throws Exception {
        LexicalAnalyzer.parser("data.txt");
    }
}

class LexicalAnalyzer {
    // 一字母操作符
    private static final String singleOperators = ";,(){}[]+-*#";
    // 1/2字母操作符
    private static final String specialOperators = "<>=!:";
    // 关键字
    private static final String[] keyWords = {
            "begin", "if", "then", "while", "do", "end",
            "int", "main", "return", "cout",
    };


    // 打印token二元组 (type, 'value')
    private static void printToken(String token) {
        // 类型映射
        final Map<String, Integer> TOKEN_TYPE = new HashMap<String, Integer>(){
            {
                put("!", -1); put("#", 0); put("begin", 1); put("if", 2); put("then", 3);
                put("while", 4); put("do", 5); put("end", 6); put("int", 7); put("main", 8);
                put("return", 12); put("cout", 13); put("=", 17); put(":=", 18); put("==", 21);
                put("+", 22); put("-", 23); put("*", 24); put("/", 25); put("(", 26);
                put(")", 27); put("[", 28); put("]", 29); put("{", 30); put("}", 31);
                put(",", 32); put(":", 33); put(";", 34); put(">", 35); put("<", 36);
                put(">=", 37); put("<=", 38); put("!=", 40); put("\0", 1000);
            }
        };
        System.out.printf("(%d, '%s')\n", TOKEN_TYPE.get(token), token);
    }

    // 词法分析函数，逐行分析代码文件
    public static void parser(String path) throws Exception{
        BufferedReader reader = new BufferedReader(new FileReader(path));;
        String line;
        int lineCount = 1;

        System.out.println("Starting parsing...");

        while ((line = reader.readLine()) != null) {
            char[] row = line.toCharArray();
            int len = line.length();
            for (int i = 0; i < len; i++) {
                char ch = row[i];
                // 跳过空白字符
                if (Character.isWhitespace(ch)) {
                }
                // 单字符运算符
                else if (singleOperators.indexOf(ch) != -1) {
                    printToken(String.valueOf(ch));
                }
                // 特殊运算符
                else if (specialOperators.indexOf(ch) != -1) {
                    if (i + 1 < len && row[i+1] == '=') {
                        printToken(ch+"=");
                        i++;
                    }
                    else {
                        printToken(String.valueOf(ch));
                    }
                }
                // / 符号 可能是运算符或注释
                else if (ch == '/') {
                    if (i + 1 < len && row[i+1] == '/')
                        break; // 跳过注释
                    else
                        printToken(String.valueOf(ch));
                }
                // " 字符串
                else if (ch == '\"') {
                    int beginIdx = i;
                    int endIdx;
                    for (endIdx = beginIdx + 1; endIdx < len && row[endIdx] != '"'; endIdx++) {
                    }
                    if (endIdx == len)
                        throw new Exception("Non-terminated string quote!");
                    System.out.printf("(T_STRING, '%s')\n", line.substring(beginIdx, endIdx));
                    i = endIdx - 1;
                }
                // 标识符or关键字
                else if (Character.isLetter(ch) || ch == '_') {
                    int beginIdx = i;
                    int endIdx;
                    for(endIdx = beginIdx + 1;
                        endIdx < len
                        && (Character.isLetter(row[endIdx])
                        || Character.isDigit(row[endIdx])
                        || row[endIdx] == '_');
                        endIdx++) {
                    }
                    if (Arrays.asList(keyWords).contains(line.substring(beginIdx, endIdx)))
                        printToken(line.substring(beginIdx, endIdx));
                    else
                        System.out.printf("(10, '%s')\n", line.substring(beginIdx, endIdx));
                    i = endIdx - 1;
                }
                // 数字
                else if (Character.isDigit(ch)) {
                    int beginIdx = i;
                    int endIdx;
                    for(endIdx = beginIdx + 1; endIdx < len && Character.isDigit(row[endIdx]);endIdx++) {
                    }
                    System.out.printf("(20, '%s')\n", line.substring(beginIdx, endIdx));
                    i = endIdx - 1;
                }
                else {
                    throw new Exception(String.format("Unknown char -> %c at line %d\n", ch, lineCount));
                }
            }
            lineCount++;
        }

        System.out.println("Lexical analysing completed!");
    }
}
