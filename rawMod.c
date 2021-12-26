#include <stdlib.h>
#include <termios.h>
#include <unistd.h>

struct termios *orig_termios;
void disableRawMod() 
{
  tcsetattr(STDIN_FILENO, TCSAFLUSH, orig_termios);
  free(orig_termios);
}

void enableRawMod()
{
    struct termios termios_p;
    orig_termios=calloc(1, sizeof(struct termios));  
    tcgetattr(0, orig_termios);
    termios_p=*orig_termios;
    termios_p.c_iflag &= ~(IGNBRK | BRKINT | PARMRK | ISTRIP| INLCR | IGNCR | ICRNL | IXON);
    termios_p.c_oflag &= ~OPOST;
    termios_p.c_lflag &= ~(ECHO | ECHONL | ICANON | ISIG | IEXTEN);
    termios_p.c_cflag &= ~(CSIZE | PARENB);
    termios_p.c_cflag |= CS8;
    tcsetattr(STDIN_FILENO, TCSAFLUSH, &termios_p);
}
