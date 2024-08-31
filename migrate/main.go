package main

import (
	"database/sql"
	"fmt"
	"log"
	"os"
	"time"

	"github.com/mattn/go-sqlite3"
)

func addColumn(filename string){
	db, err := sql.Open("sqlite3", fmt.Sprintf("./database/databases/%s", filename))
	if err != nil {
		log.Fatal(err)
	}
	defer db.Close()

	rows, err := db.Query("SELECT name FROM sqlite_master WHERE type='table';")
	if err != nil {
		log.Fatal(err)
	}
	defer rows.Close()

	var tables []string
	for rows.Next() {
		var tableName string
		if err := rows.Scan(&tableName); err != nil {
			log.Fatal(err)
		}
		tables = append(tables, tableName)
	}
	fmt.Println(tables)
	if err := rows.Close(); err != nil {
		log.Fatal(err)
	}

	for _, tableName := range tables {
		fmt.Println(tableName)
		if tableName == "sqlite_sequence" {
			log.Printf("Skipping table %s: it cannot be altered", tableName)
			continue
		}

		alterTableSQL := fmt.Sprintf("ALTER TABLE %s ADD COLUMN uuid TEXT;", tableName)

		for retries := 0; retries < 5; retries++ {
			_, err = db.Exec(alterTableSQL)
			if err != nil {
				if sqliteError, ok := err.(sqlite3.Error); ok && sqliteError.Code == sqlite3.ErrLocked {
					log.Printf("Database is locked, retrying... (attempt %d)", retries+1)
					time.Sleep(2 * time.Second) 
					continue
				} else {
					log.Printf("Error adding column to table %s: %v", tableName, err)
					break
				}
			} else {
				log.Printf("Added new column to table %s", tableName)
				break
			}
		}
	}

	if err := rows.Err(); err != nil {
		log.Fatal(err)
	}
}
func main() {
	entries, err := os.ReadDir("./database/databases")
	if err != nil {
		log.Fatal(err)
	}
	
	for _, e := range entries {
			addColumn(e.Name())
	}
}
