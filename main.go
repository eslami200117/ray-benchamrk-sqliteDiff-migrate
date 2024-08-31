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

	start2 := time.Now()
	sqliteDiff.ModifySqlForMaster(name)
	duration = time.Since(start2)
	fmt.Printf("modify script: %v\n", duration)

	start3 := time.Now()
	sqliteDiff.ApplySql(name)
	duration = time.Since(start3)
	total_duration := time.Since(start)
	fmt.Printf("apply sql time: %v\n", duration)
	fmt.Printf("total time: %v\n", total_duration)

}
