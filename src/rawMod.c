#include <stdlib.h>
#include <termios.h>
#include <unistd.h>

void disableRawMod() 
{
    struct termios orig_termios;
    orig_termios.c_iflag= 17664;
    orig_termios.c_oflag= 5;
    orig_termios.c_lflag= 35387;
    orig_termios.c_cflag= 191;
    orig_termios.c_cc[0]=3;
    orig_termios.c_cc[1]=28;
    orig_termios.c_cc[2]=127;
    orig_termios.c_cc[3]=21;
    orig_termios.c_cc[4]=4;
    tcsetattr(STDIN_FILENO, TCSAFLUSH, &orig_termios);
}

void enableRawMod()
{
    struct termios termios_p;
    termios_p.c_iflag= 17664;
    termios_p.c_oflag= 5;
    termios_p.c_lflag= 35387;
    termios_p.c_cflag= 191;
    //termios_p.c_iflag &= ~(BRKINT | INPCK | IXON);
    //termios_p.c_lflag &= ~(ECHO | ICANON | ISIG | IEXTEN | VERASE );
    termios_p.c_lflag &= ~(ECHO | ICANON | ISIG );
    termios_p.c_cflag |= CS8;
    termios_p.c_cc[VMIN]=1;
    termios_p.c_cc[VTIME] = 0;
    tcsetattr(STDIN_FILENO, TCSAFLUSH, &termios_p);
}

