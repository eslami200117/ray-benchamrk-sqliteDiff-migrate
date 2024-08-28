package main

import (
	"fmt"

	"gorm.io/driver/sqlite"
	"gorm.io/gorm"
)

func main() {
	db, err := gorm.Open(sqlite.Open("/database/databases/pointMaster_2"), &gorm.Config{})
	if err != nil {
		fmt.Println("error:", err)
	}
	db.Exec("some query")

}