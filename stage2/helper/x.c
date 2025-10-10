#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int main(int argc, char *argv[]) {
    char source_file[256];
    char exe_file[256] = "program_exec";
    char compile_cmd[512];
    char run_cmd[512];

    // Get source file
    if (argc > 1) {
        strncpy(source_file, argv[1], sizeof(source_file));
        source_file[sizeof(source_file) - 1] = '\0';
    } else {
        printf("Enter the .c source file name: ");
        if (scanf("%255s", source_file) != 1) {
            fprintf(stderr, "Invalid input.\n");
            return 1;
        }
    }

    // Prepare commands
    snprintf(compile_cmd, sizeof(compile_cmd), "gcc %s -o %s 2> compile.log", source_file, exe_file);
    snprintf(run_cmd, sizeof(run_cmd), "./%s > output.log 2>&1", exe_file);

    // Step 1: Compile
    int compile_status = system(compile_cmd);

    if (compile_status != 0) {
        // Compilation failed — show first 2 lines of error
        FILE *err = fopen("compile.log", "r");
        if (!err) {
            perror("Error opening compile.log");
            return 1;
        }

        char line[512];
        int count = 0;
        printf("Compilation failed:\n");
        while (fgets(line, sizeof(line), err) && count < 2) {
            printf("%s", line);
            count++;
        }
        fclose(err);
    } else {
        // Compilation succeeded — run the program silently
        system(run_cmd);
        printf("Program Parsed successfully\n");
        printf("Parsing complete");
    }

    system("rm -f compile.log output.log program_exec");
    //run ./main file_path(taken as input)
    snprintf(run_cmd, sizeof(run_cmd), "./%s %s", "main", source_file);
    system(run_cmd);

    return 0;
}
