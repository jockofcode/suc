#include <unistd.h>
/* #include <stdlib.h> */
#include <assert.h>
#include <stdio.h>

#define SUC_SH "/usr/bin/suc.sh"

char* bash_argv[] = {
  "suc.sh",  // arg0 is the name of the executable
  "-p",
  SUC_SH,
  "BITE_ME"
};

int main(int argc, char** argv)
{
  assert(argc == 2);
  bash_argv[3] = argv[1];
  /* printf("real uid: %d\n", getuid()); */
  /* printf("effective uid: %d\n", geteuid()); */
  execv("/bin/bash", bash_argv);
  return 0;
}
