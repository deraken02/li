# li
A simple text editor in x86_64

## Features

|Name of the features| Status |
|---|---|
|Open the file in argument|✔|
|Write in the file in argument|✔|
|Append the text in an existing file|✔|
|Display the content of the file if he already exists|✔|
|Remove text in the file|❌|
|Replace text in the file|✔|
|Colorize the code|❌|
|Enable raw mod|✔|
|Erase the terminal in the launchement|✔|
|Manage the direction keys|❌|
|Manage the backspace|✔|
|Write the error message on the error output|✔|

## Issues

|Description of the issue | Status |
|-------|---|
|||

## CI coverage

|Coverage| Status |
|---|---|
|Build the text editor|✔|
|Write a text in a new file|✔|
|Write an error message if there are no arguments|✔|
|Append text in an existing file|✔|
|Replace text in the file|✔|
|Manage backspace|✔|

## Manual

### Build

Run the command:

```sh
make
```

The executable li was created

### Using

The programm take one argument (the name of the file):

```
./li <name_of_file>
```

To quit the programm press `Esc` then `q`
