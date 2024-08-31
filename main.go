package main

import (
	"fmt"
	"time"

	"github.com/eslami200117/sqliteDiff/sqliteDiff"
)

func main() {
	start := time.Now()

	name := sqliteDiff.GetDiff("database/databases/Empty", "database/databases/14030605")
	fmt.Println(name)
	duration := time.Since(start)
	fmt.Printf("get diff time: %v\n", duration)

	sqliteDiff.ModifySqlForMaster(name)
	duration = time.Since(start)
	fmt.Printf("modify script: %v\n", duration)

	sqliteDiff.ApplySql(name)
	duration = time.Since(start)
	fmt.Printf("total time: %v\n", duration)

}
