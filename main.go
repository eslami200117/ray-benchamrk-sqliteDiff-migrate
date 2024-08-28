package main

import (
	"database/sql"
	"fmt"
	_ "github.com/mattn/go-sqlite3"
)

func main() {
	db, err := sql.Open("sqlite3", "/database/databases/pointsMaster")
	if err != nil {
		fmt.Println("error:", err)
	}

	defer db.Close()
}