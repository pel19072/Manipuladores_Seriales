%%
Arduino = serial('COM5', 'BaudRate', 9600, 'Terminator', 'CR');
fopen(Arduino);
flushinput(Arduino);
flushoutput(Arduino);

%%
fprintf(Arduino, "Hola");

%%
fclose(Arduino);

%%
instrfind
delete(instrfind)
instrfind