package main

import (
	"errors"
	"fmt"
)

type Queue struct {
	arr      []int
	front    int
	rear     int
	size     int
	capacity int
}

func NewQueue(size int) Queue {
	return Queue{arr: make([]int, size), front: size - 1, rear: size - 1, size: 0, capacity: size}
}

func (q *Queue) isEmpty() bool {
	if q.size <= 0 {
		return true
	} else {
		return false
	}
}

func (q *Queue) isFull() bool {
	if q.size >= q.capacity {
		return true
	} else {
		return false
	}
}

func (q *Queue) enqueue(item int) error {
	if q.isFull() {
		return errors.New("queue full")
	}
	q.rear = (q.rear + 1) % q.capacity
	q.arr[q.rear] = item
	q.size++
	return nil
}

func (q *Queue) dequeue() (int, error) {
	if q.isEmpty() {
		return 0, errors.New("Empty queue")
	}
	q.front = (q.front + 1) % q.capacity
	q.size--
	return q.arr[q.front], nil
}

type IntStack struct {
	stack [100]int
	index int // zero initialized
}

func (s *IntStack) push(value int) {
	s.index++
	s.stack[s.index] = value
}

func (s *IntStack) pop() int {
	out := s.stack[s.index]
	s.index--
	return out
}

type Number interface {
	int | uint8 | uint16 | uint32 | uint64 | int8 | int16 | int32 | int64 | float32 | float64
}

func swap[T any](a *T, b *T) {
	var tmp T
	tmp = *a
	*a = *b
	*b = tmp
}

func partition[T Number](arr []T) int {
	left := 0
	mid := len(arr) / 2
	right := len(arr) - 1
	final := right

	pivot := arr[mid]
	//fmt.Printf("Pivot: %v\n", pivot)

	for right > left {
		//fmt.Printf("Curr: %v    ", right)
		//fmt.Printf("%v < %v?", pivot, arr[right])
		if pivot < arr[right] {
			//fmt.Printf(" True")
			swap(&arr[right], &arr[final])
			final--
		} else {
			//fmt.Printf(" False")
		}
		right--
		//fmt.Printf(" %#v\n", arr)
	}

	if pivot < arr[left] {
		swap(&arr[left], &arr[final])
	}

	final--
	return final
}

func quickSort[T Number](arr []T) {
	if len(arr) < 2 {
		return
	}

	pivotIdx := partition(arr)

	quickSort(arr[0:pivotIdx])
	quickSort(arr[pivotIdx+1:])
}

func main() {
	fmt.Println("\nQuick Sort")
	x := []int{-99, 1, 7, 4, 8, 3, 2, 0, -1, -2, -3, -4}
	y := []float64{-99, 1, 7, 4, 8.3, 3, 2, 0, -1, -2, -3, -4}
	quickSort(x)
	quickSort(y)
	fmt.Printf("%#v\n", x)
	fmt.Printf("%#v\n", y)

	fmt.Println("\nQueue")
	items := []int{1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14}
	q := NewQueue(5)
	fmt.Printf("q: %v\n", q.arr)

	for _, item := range items {
		err := q.enqueue(item)

		if err != nil {
			fmt.Printf("%s\n", err.Error())
		} else {
			fmt.Printf("q: %v\n", q.arr)
		}
	}

	for range items {
		out, err := q.dequeue()

		if err != nil {
			fmt.Printf("%s\n", err.Error())
			err = nil
		} else {
			fmt.Printf("q: %v, out: %d\n", q.arr, out)
		}
	}

	q2 := NewQueue(20)

	for _, item := range items {
		err := q2.enqueue(item)

		if err != nil {
			fmt.Printf("%s\n", err.Error())
		} else {
			fmt.Printf("q2: %v\n", q2.arr)
		}
	}

	for range items {
		out, err := q2.dequeue()

		if err != nil {
			fmt.Printf("%s\n", err.Error())
			err = nil
		} else {
			fmt.Printf("q2: %v, out: %d\n", q2.arr, out)
		}
	}
}
