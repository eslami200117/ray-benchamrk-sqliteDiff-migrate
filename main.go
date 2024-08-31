package main

import (
	"flag"
	"fmt"
	"time"

	"github.com/eslami200117/sqliteDiff/sqliteDiff"
)

func main() {
	db1 := flag.String("db1", "", "Path to the first database file")
	db2 := flag.String("db2", "", "Path to the second database file")

	// Parse the flags
	flag.Parse()

	if *db1 == "" || *db2 == "" {
		fmt.Println("Both db1 and db2 arguments are required")
		flag.Usage()
		return
	}

	start := time.Now()

	name := sqliteDiff.GetDiff(*db1, *db2)
	duration := time.Since(start)
	fmt.Printf("get diff time: %v\n", duration)

	sqliteDiff.ModifySqlForMaster(name)
	duration = time.Since(start)
	fmt.Printf("modify script: %v\n", duration)

	sqliteDiff.ApplySql(name)
	duration = time.Since(start)
	fmt.Printf("total time: %v\n", duration)
}
