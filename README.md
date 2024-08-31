# Benchmark sqldiff and migrate

This Go project is a command-line tool designed to compare two SQLite3 databases, generate a SQL script to apply the differences, modify the script for application to a master database, and benchmark the entire process.

## Features

- **Database Comparison**: Compares two SQLite3 databases and generates a SQL script highlighting the differences.
- **Script Modification**: Modifies the generated SQL script to be applicable to the master database.
- **Script Application**: Applies the modified SQL script to the master database.
- **Benchmarking**: Measures and displays the time taken for each stage of the process.
