%% MATLAB script to transfer acquired waveforms from Tektronix MSO5000 series oscilloscope 
% This example illustrates the use of MATLAB to set up a Tektronix
% MSO5000 series oscilloscope to acquire a waveform and then transfer the
% acquired waveform to MATLAB. Tektronix VISA will be used for
% communicating with your instrument, please ensure that it is installed.
%
% This script was tested with a Tek MSO5034
% 
% Copyright 2014 The MathWorks, Inc.

% Clear MATLAB workspace of any previous instrument connections
instrreset;

% Provide the Resource name of the oscilloscope - Note you will have to
% change this to match your oscilloscope.
visaAddress = 'USB::0x0699::0x0456::C010891::INSTR';

% Create a VISA object and set the |InputBufferSize| to allow for transfer
% of waveform from oscilloscope to MATLAB. Tek VISA needs to be installed.
myScope = visa('tek', visaAddress);
myScope.InputBufferSize = 1e7;

%fprintf(myScope, '*IDN?');
%idn = fscanf(myScope)

% Set the |ByteOrder| to match the requirement of the instrument
myFgen.ByteOrder = 'littleEndian';

% Open the connection to the oscilloscope
fopen(myScope);

% Reset the oscilloscope to a known state
%fprintf(myScope, '*RST');
%fprintf(myScope, '*CLS');

% select channel
fprintf(myScope, 'DAT:SOU CH1');

fprintf(myScope, 'DATA:START 1');

fprintf(myScope, 'DATA:STOP 10000000');

yOffset = query(myScope, 'WFMO:YOFF?');

verticalScale  = query(myScope,'WFMOUTPRE:YMULT?');

fprintf(myScope, 'DATA:ENCDG RIBINARY');

fprintf(myScope, 'WIDTH 1');

fprintf(myScope, 'HEAD 0');

fprintf(myScope, 'CURVE?');

% Read the captured data as 8-bit integer data type
%data = (str2double(verticalScale) * (binblockread(myScope,'int8')))' + str2double(yOffset);

data = fread(myScope, 10000000, "int8");

data = (str2double(verticalScale) * (data)' ); % + str2double(yOffset)

%data = read(myScope,1000000,"int8");

% Clean up Close the connection
fclose(myScope);
% Clear the variable
clear myScope;

% Plot the acquired data and add axis labels
plot(data); 
xlabel('Sample Index'); 
ylabel('Volts');
title('Waveform Acquired from Tektronix Oscilloscope');
grid on;


% This script provides an example of communicating with Tektronix
% instruments using text based commands. To learn about other options to
% communicate with instruments from MATLAB visit the following page:
% https://www.mathworks.com/products/instrument
%
% To learn more about Tektronix instruments supported by MATLAB, visit the
% following links:
% https://www.mathworks.com/tektronix
% http://www.tek.com/technology/using-matlab-tektronix-instruments

