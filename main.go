package main

import (
	"github.com/eslami200117/sqliteDiff/sqliteDiff"
)


func main(){
	sqliteDiff.GetDiff("database/databases/pointsMaster", "database/databases/editedd")
}