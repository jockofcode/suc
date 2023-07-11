#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <time.h>
#include <pwd.h>

#define PATH "/var/lib/suc/"

int main(int argc, char** argv) {
    FILE *fp;
    char filePath[256];
    struct passwd *pw;
    time_t t = time(NULL);
    struct tm tm = *localtime(&t);
    char timeString[256];
    char buffer[256];

    if (argc != 2) {
        fprintf(stderr, "Usage: %s <message_target>\n", argv[0]);
        return EXIT_FAILURE;
    }

    // Get username from UID
    uid_t uid = getuid();
    pw = getpwuid(uid);
    if (pw == NULL) {
        perror("getpwuid");
        exit(EXIT_FAILURE);
    }

    // Create formatted time string
    strftime(timeString, sizeof(timeString), "%Y-%m-%dT%H:%M:%S", &tm);

    // Create the file path
    snprintf(filePath, sizeof(filePath), "%s%s", PATH, argv[1]);

    // Open the file
    fp = fopen(filePath, "a");
    if (fp == NULL) {
        perror("Unable to open file");
        exit(EXIT_FAILURE);
    }

    while (fgets(buffer, sizeof(buffer), stdin)) {
        // Write time, username, and message to the file
        fprintf(fp, "%s %s %s", timeString, pw->pw_name, buffer);
    }

    fclose(fp);

    return 0;
}

