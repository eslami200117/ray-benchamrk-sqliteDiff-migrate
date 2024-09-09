package sqliteDiff

import (
	"bufio"
	"database/sql"
	"fmt"
	"log"
	"os"
	"os/exec"
	"time"

	_ "github.com/mattn/go-sqlite3"
)

func GetDiff(src, des string,) string{
	if des == "" {
		des = src
		src = "database/databases/master"
	}
	currentTime := time.Now()

	formattedTime := currentTime.Format("2006-01-02_15-04-05")


	outFile, err := os.Create(fmt.Sprintf("script/%s.sql", formattedTime))
	if err != nil {
		fmt.Printf("Error: %v\n", err, )

	}
	cmd := exec.Command("/usr/bin/sqldiff", src, des)
	cmd.Stdout = outFile
	err = cmd.Run()
	if err != nil {
		fmt.Printf("Error: %v\n", err, )

	}
	return fmt.Sprintf("%s.sql",formattedTime)
}

func ApplySql(sqlPath, dbPath string) {
	db, err := sql.Open("sqlite3", fmt.Sprintf("database/databases/%s", dbPath))
	if err != nil {
		log.Fatal(err)
	}
	defer db.Close()

	_, _ = db.Exec("PRAGMA synchronous = OFF")
	_, _ = db.Exec("PRAGMA journal_mode = MEMORY")
	_, _ = db.Exec("PRAGMA temp_store = MEMORY")

	path := fmt.Sprintf("script/%s", sqlPath)
	err = applySQLFromFile(db, path)
	if err != nil {
		log.Fatalf("Failed to apply SQL file: %v", err)
	}
	
	_, _ = db.Exec("PRAGMA synchronous = FULL") // Default is FULL
	_, _ = db.Exec("PRAGMA journal_mode = DELETE") // Default is DELETE
	_, _ = db.Exec("PRAGMA temp_store = DEFAULT") // Default is DEFAULT

}

func ModifySqlForMaster(name string, isMstr bool) {
	sqlSourcePath := fmt.Sprintf("script/%s", name)
	sqlDesPath := fmt.Sprintf("script/diff_%s", name); 
	flag := "diff"
	if isMstr {
		sqlDesPath = fmt.Sprintf("script/mstr_%s", name)
		flag = "master"
	}
	cmd := exec.Command("python3", "sqlProcessCommmand/scriptConvertor.py", sqlSourcePath, sqlDesPath, flag)
	err := cmd.Run()
	if err != nil {
		fmt.Printf("Error: %v\n", err, )

	}
}




func applySQLFromFile(db *sql.DB, filePath string) error {
	// Open the SQL file
	file, err := os.Open(filePath)
	if err != nil {
		return fmt.Errorf("error opening file: %v", err)
	}
	defer file.Close()

	// Start a transaction
	tx, err := db.Begin()
	if err != nil {
		return fmt.Errorf("error starting transaction: %v", err)
	}

	// Use a buffered reader for efficient file reading
	scanner := bufio.NewScanner(file)
	var sqlStmt string

	for scanner.Scan() {
		line := scanner.Text()
		sqlStmt += line

		// Check if the line ends with a semicolon, indicating the end of a statement
		if len(line) > 0 && line[len(line)-1] == ';' {
			_, err := tx.Exec(sqlStmt)
			if err != nil {
				tx.Rollback()
				return fmt.Errorf("error executing SQL statement: %v\nStatement: %s", err, sqlStmt)
			}
			sqlStmt = "" // Reset the statement after execution
		}
	}

	// Handle any errors encountered during scanning
	if err := scanner.Err(); err != nil {
		tx.Rollback()
		return fmt.Errorf("error reading file: %v", err)
	}

	// Commit the transaction
	if err := tx.Commit(); err != nil {
		return fmt.Errorf("error committing transaction: %v", err)
	}

	return nil
}

