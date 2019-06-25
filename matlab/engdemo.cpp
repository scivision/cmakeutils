/*
 *	engdemo.cpp
 *
 *	A simple program to illustrate how to call MATLAB
 *	Engine functions from a C++ program.
 *
 * Copyright 1984-2016 The MathWorks, Inc.
 * All rights reserved
 */
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include "engine.h"
#define  BUFSIZE 256

int main(void)

{
	Engine *ep;
	mxArray *result = NULL;
	char buffer[BUFSIZE+1];

	/*
	 * Call engOpen with a NULL string. This starts a MATLAB process
     * on the current host using the command "matlab".
	 */
	if (!(ep = engOpen(""))) {
		fprintf(stderr, "\nCan't start MATLAB engine\n");
		return EXIT_FAILURE;
	}

	/*
	 * str is a MATLAB string, which should define a variable X.  MATLAB
	 * will evaluate the string and create the variable.  We
	 * will then recover the variable, and determine its type.
	 */

	/*
	 * Use engOutputBuffer to capture MATLAB output, so we can
	 * echo it back.  Ensure first that the buffer is always NULL
	 * terminated.
	 */

	buffer[BUFSIZE] = '\0';
	engOutputBuffer(ep, buffer, BUFSIZE);

  char str[BUFSIZE+1] = "X = 1:5";

	    /*
	     * Evaluate input with engEvalString
	     */
	    engEvalString(ep, str);

	    /*
	     * Echo the output from the command.
	     */
	    printf("%s", buffer);

	    /*
	     * Get result of computation
	     */
	    printf("\nRetrieving X...\n");
	    if ((result = engGetVariable(ep,"X")) == NULL){
	      printf("Oops! You didn't create a variable X.\n\n");
        return EXIT_FAILURE;
      }
	    else {
        printf("X is class %s\t\n", mxGetClassName(result));
	    }


	/*
	 * We're done! Free memory, close MATLAB engine and exit.
	 */
	printf("Done!\n");
	mxDestroyArray(result);
	engClose(ep);

	return EXIT_SUCCESS;
}