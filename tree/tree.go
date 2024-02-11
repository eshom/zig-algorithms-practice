package tree

import (
	"fmt"
	"io/fs"
	"os"
	"path/filepath"
)

func printDirFiles(startDir string) []error {
	var errors []error

	start, err := os.ReadDir(startDir)
	if err != nil {
		errors = append(errors, err)
	}

	var searchQueue []fs.DirEntry
	var searchNames []string

	fmt.Printf("%s\n", startDir)
	for _, file := range start {
		if file.IsDir() {
			path := filepath.Join(startDir, file.Name())
			searchQueue = append(searchQueue, file)
			searchNames = append(searchNames, path)
		} else {
			fmt.Printf("\t%s\n", file)
		}
	}

	for len(searchQueue) != 0 {
		dirname := searchNames[0]

		searchQueue = searchQueue[1:]
		searchNames = searchNames[1:]

		files, err := os.ReadDir(dirname)
		if err != nil {
			errors = append(errors, err)
		}

		fmt.Printf("%s\n", dirname)
		for _, file := range files {
			if file.IsDir() {
				path := filepath.Join(dirname, file.Name())
				searchQueue = append(searchQueue, file)
				searchNames = append(searchNames, path)
			} else {
				fmt.Printf("\t%s\n", file)
			}
		}
	}

	return errors
}

func printDirFilesRecur(startDir string, errorsCollect []error) {
	files, err := os.ReadDir(startDir)
	if err != nil {
		errorsCollect = append(errorsCollect, err)
	}

	if len(files) == 0 {
		return
	}

	fmt.Printf("%s\n", startDir)
	for _, file := range files {
		if file.IsDir() {
			printDirFilesRecur(filepath.Join(startDir, file.Name()), errorsCollect)
		} else {
			fmt.Printf("\t%s\n", file)
		}
	}
}
