/* Copyright (c) 2022 Delacroix Louis */

#include <termios.h>
#include <unistd.h>
#include <stdlib.h>

#define STDIN_FILENO 0

static struct termios orig_termios;

void disableRawMode()
{
  tcsetattr(STDIN_FILENO, TCSANOW, &orig_termios);
}

void enableRawMode()
{
  tcgetattr(STDIN_FILENO, &orig_termios);
  atexit(disableRawMode);
  struct termios raw = orig_termios;
  raw.c_lflag &= ~(ECHO | ICANON);
  tcsetattr(STDIN_FILENO, TCSANOW, &raw);
}
