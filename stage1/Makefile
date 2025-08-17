# Makefile for C Language Scanner

# Compiler and flags
CC = gcc
CFLAGS = -Wall -g
LEX = flex

# Target executable
TARGET = scanner

# Source files
LEX_FILE = scanner.l
C_FILE = lex.yy.c

# Default target
all: $(TARGET)

# Build the scanner
$(TARGET): $(C_FILE)
	$(CC) $(CFLAGS) -o $(TARGET) $(C_FILE) -lfl

# Generate C code from LEX file
$(C_FILE): $(LEX_FILE)
	$(LEX) $(LEX_FILE)

# Clean build files
clean:
	rm -f $(C_FILE) $(TARGET) lex.yy.c

# Test with sample files
test: $(TARGET)
	@echo "Testing with test1.c..."
	./$(TARGET) test1.c
	@echo "\n\nTesting with test2.c..."
	./$(TARGET) test2.c
	@echo "\n\nTesting with test3.c (error cases)..."
	./$(TARGET) test3.c

# Install flex if not present (Ubuntu/Debian)
install-deps:
	sudo apt-get update
	sudo apt-get install flex

.PHONY: all clean test install-deps