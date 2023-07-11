#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <time.h>
#include <pwd.h>

#define SUC_DIRECTORY_PATH "/var/lib/suc/"

void print_usage_and_exit(char *program_name) {
    fprintf(stderr, "Usage: %s <message_target>\n", program_name);
    exit(EXIT_FAILURE);
}

char* get_current_username() {
    uid_t uid = getuid();
    struct passwd *passwd_entry = getpwuid(uid);

    if (passwd_entry == NULL) {
        perror("getpwuid");
        exit(EXIT_FAILURE);
    }

    return passwd_entry->pw_name;
}

char* get_current_datetime() {
    time_t current_time = time(NULL);
    struct tm local_time = *localtime(&current_time);
    static char datetime_string[256];
    strftime(datetime_string, sizeof(datetime_string), "%Y-%m-%dT%H:%M:%S", &local_time);

    return datetime_string;
}

FILE* open_message_target_file(char *message_target) {
    char filepath[256];
    snprintf(filepath, sizeof(filepath), "%s%s", SUC_DIRECTORY_PATH, message_target);

    FILE *file = fopen(filepath, "a");
    if (file == NULL) {
        perror("Unable to open file");
        exit(EXIT_FAILURE);
    }

    return file;
}

void write_messages_to_file(FILE *file, char *username) {
    char buffer[256];
    while (fgets(buffer, sizeof(buffer), stdin)) {
        fprintf(file, "%s %s %s", get_current_datetime(), username, buffer);
    }
}

int main(int argc, char** argv) {
    if (argc != 2) {
        print_usage_and_exit(argv[0]);
    }

    char *username = get_current_username();
    FILE *message_target_file = open_message_target_file(argv[1]);

    write_messages_to_file(message_target_file, username);

    fclose(message_target_file);

    return 0;
}

