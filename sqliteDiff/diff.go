package sqliteDiff

import (
	"fmt"
	"math/rand"
	"os"
	"os/exec"
	"strconv"
)

func GetDiff(src, des string) string{
	randN := rand.Int()
	outFile, err := os.Create(fmt.Sprintf("script/diff_%s.sql", strconv.Itoa(randN)))
	if err != nil {
		fmt.Printf("Error: %v\n", err, )

	}
	cmd := exec.Command("/usr/bin/sqldiff", src, des)
	cmd.Stdout = outFile
	err = cmd.Run()
	if err != nil {
		fmt.Printf("Error: %v\n", err, )

	}
	return fmt.Sprintf("diff_%s.sql", strconv.Itoa(randN))
}

func ApplySql(name string) {
	inFile, err := os.Open(fmt.Sprintf("script/%s", name))
	if err != nil {
		fmt.Println(err)
	}
	cmd := exec.Command("sqlite3", "database/databases/Empty")
	cmd.Stdin = inFile 
	err = cmd.Run()
	if err != nil {
		fmt.Println(err)
	}
}