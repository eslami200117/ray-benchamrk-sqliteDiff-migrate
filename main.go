package main

import (
	"flag"
	"fmt"
	"time"

	"github.com/eslami200117/sqliteDiff/sqliteDiff"
)

func main() {
	db1 := flag.String("db1", "", "Path to the first database file")
	db2 := flag.String("db2", "", "Path to the first database file")

	flag.Parse()

	if *db1 == "" {
		fmt.Println("Both db1 arguments are required")
		flag.Usage()
		return
	}


	start := time.Now()
	name := sqliteDiff.GetDiff(*db1, *db2)
	duration := time.Since(start)
	fmt.Printf("get diff time: %v\n", duration)

	start2 := time.Now()
	sqliteDiff.ModifySqlForMaster(name, false)
	sqliteDiff.ModifySqlForMaster(name, true)
	duration = time.Since(start2)
	fmt.Printf("modify script: %v\n", duration)

	start3 := time.Now()
	sqliteDiff.ApplySql(fmt.Sprintf("diff_%s", name), "Diff")
	sqliteDiff.ApplySql(fmt.Sprintf("mstr_%s", name), "master")
	duration = time.Since(start3)
	total_duration := time.Since(start)
	fmt.Printf("apply sql time: %v\n", duration)
	fmt.Printf("total time: %v\n", total_duration)

}
