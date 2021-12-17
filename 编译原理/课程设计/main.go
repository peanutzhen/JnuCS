package main

import (
	"bufio"
	"fmt"
	"os"
	"strings"
	"unicode"
)

func main() {
	lexicalAnalysis("data.txt")
}

var single_operators string = ";,(){}[]+-*#"

var special_operators string = "<>=!:"

var keywords []string = []string{
	"begin", "if", "then", "while", "do", "end",
	"int", "main", "return", "cout",
}

var token_type map[string]int = map[string]int{
	"!": -1, "#": 0, "begin": 1, "if": 2, "then": 3,
	"while": 4, "do": 5, "end": 6, "int": 7, "main": 8,
	"return": 12, "cout": 13, "=": 17, ":=": 18, "==": 21,
	"+": 22, "-": 23, "*": 24, "/": 25, "(": 26,
	")": 27, "[": 28, "]": 29, "{": 30, "}": 31,
	",": 32, ":": 33, ";": 34, ">": 35, "<": 36,
	">=": 37, "<=": 38, "!=": 40,
}

func displayToken(val int, token string) {
	fmt.Printf("(%d, \"%s\")\n", val, token)
}

func lexicalAnalysis(path string) {
	file, err := os.Open(path)
	if err != nil {
		fmt.Printf("[ERROR] File{'%s'} open failed.\n", path)
		return
	}

	fmt.Printf("[INFO] Analysising lexical from '%s'.\n", path)

	in := bufio.NewScanner(file)
	line := 1
	for in.Scan() {
		row := in.Text()
		length := len(row)

		for i := 0; i < length; i++ {
			var word rune = rune(row[i])
			if unicode.IsSpace(word) {
				// Skip whitespace
				continue
			} else if strings.ContainsRune(single_operators, word) {
				// 单字符运算符直接断定
				displayToken(token_type[string(word)], string(word))
			} else if strings.ContainsRune(special_operators, word) {
				// 特殊字符 后面可能跟等号
				if i+1 < length && row[i+1] == '=' {
					displayToken(token_type[string(word)+"="], string(word)+"=")
					i++
				} else {
					displayToken(token_type[string(word)], string(word))
				}
			} else if word == '/' {
				if i < length && row[i+1] == '/' {
					break // 跳过注释
				} else {
					displayToken(token_type[string(word)], string(word))
				}
			} else if word == '"' {
				// 字符串
				s, e := i, i+1
				for ; e < length && row[e] != '"'; e++ {
				}
				if e == length {
					panic("Non-terminated string quote!")
				}
				fmt.Printf("(T_STRING, '%s')\n", row[s:e])
				i = e - 1
			} else if unicode.IsLetter(word) || word == '_' {
				// 关键字或标识符
				s, e := i, i+1
				for ; e < length &&
					(unicode.IsLetter(rune(row[e])) ||
						unicode.IsDigit(rune(row[e])) ||
						row[e] == '_'); e++ {
				}
				isIdentifier := true
				for _, keyword := range keywords {
					if row[s:e] == keyword {
						displayToken(token_type[keyword], keyword)
						isIdentifier = false
					}
				}
				if isIdentifier {
					displayToken(10, row[s:e])
				}
				i = e - 1
			} else if unicode.IsDigit(word) {
				// 数字
				s, e := i, i+1
				for ; e < length && unicode.IsDigit(rune(row[e])); e++ {
				}
				displayToken(20, row[s:e])
				i = e - 1
			} else {
				panic(fmt.Sprintf("Unknown word '%c' at line %d.\n", word, line))
			}
		}

		line++
	}

	fmt.Println("[SUCCESS] Analysis completed!")
	file.Close()
}
