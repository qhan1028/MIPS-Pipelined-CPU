all:
    iverilog -o cpu *.v 
    vvp cpu

check: Fibonacci_output.txt Fibonacci_answer.txt
    diff -w Fibonacci_output.txt Fibonacci_answer.txt

clean:
    rm -rf cpu
