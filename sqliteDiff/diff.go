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