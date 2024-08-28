package main

import (
	"fmt"
	"time"

	"github.com/eslami200117/sqliteDiff/sqliteDiff"
)

func main() {
	start := time.Now()

	sqliteDiff.GetDiff("database/databases/pointsMaster", "database/databases/editedd")

	duration := time.Since(start)

	fmt.Printf("Execution time: %v\n", duration)
}
