package tree

import (
	"log"
	"os"
	"testing"
)

func TestPrintFiles(t *testing.T) {
	wd, err := os.Getwd()
	if err != nil {
		t.Errorf("problem getting working directory:\n %s", err.Error())
	}

	log.Printf("Working Directory: %s\n", wd)

	errs := printDirFiles("test-data")

	for _, err := range errs {
		t.Errorf("problem while reading file:\n %s", err.Error())
	}
}

func TestPrintFilesRecursive(t *testing.T) {
	wd, err := os.Getwd()
	if err != nil {
		t.Errorf("problem getting working directory:\n %s", err.Error())
	}

	log.Printf("Working Directory: %s\n", wd)

	var walkErrors []error

	printDirFilesRecur("test-data", walkErrors)

	for _, err := range walkErrors {
		t.Errorf("problem while reading file:\n %s", err.Error())
	}
}
