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

	log.Printf(wd)

	errs := printDirFiles("..")

	for _, err := range errs {
		t.Errorf("problem while reading file:\n %s", err.Error())
	}
}
