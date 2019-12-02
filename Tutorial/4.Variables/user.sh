#!/bin/sh
echo "What is your name?"
read USER_NAME
echo "Hello $USER_NAME"
# echo "I will create you a file called $USER_NAME_file" #This won't work. the variable is not even defined.
# touch $USER_NAME_file

#To make the above command work, we imbrace the $USE_NAME in curly braces, to read it's value, and put the argument to touch inside quotes.
echo "I will create you a file called ${USER_NAME}_file"
touch "${USER_NAME}_file"
