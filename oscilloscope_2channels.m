%% MATLAB script to transfer acquired waveforms from Tektronix oscilloscope
% minimum working example, ready to add the reading from second channel
% Tektronix VISA is be used for communicating with instrument

% Clear MATLAB workspace of any previous instrument connections
NUM_SAMPLES = 1e5;

instrreset;

% change this to match oscilloscope address
visaAddress = 'USB::0x0699::0x0456::C010891::INSTR';

myScope = visa('tek', visaAddress);
myScope.InputBufferSize = 1e7;

% Set the |ByteOrder| to match the requirement of the instrument
myFgen.ByteOrder = 'littleEndian';

% Open the connection to the oscilloscope
fopen(myScope);

% Reset the oscilloscope to a known state
%fprintf(myScope, '*RST');
%fprintf(myScope, '*CLS');

% select channel
fprintf(myScope, 'DAT:SOU CH1');

fprintf(myScope, 'HOR:RECO 100000');

fprintf(myScope, 'HOR:SCA 0.1 ');

fprintf(myScope, 'DATA:START 1');

fprintf(myScope, 'DATA:STOP 100000');

yOffset = query(myScope, 'WFMO:YOFF?');

verticalScale  = query(myScope,'WFMOUTPRE:YMULT?');

fprintf(myScope, 'DATA:ENCDG RIBINARY');

fprintf(myScope, 'WIDTH 1');

fprintf(myScope, 'HEAD 0');

fprintf(myScope, 'CURVE?');

% Read the captured data as 8-bit integer data type
data = fread(myScope, NUM_SAMPLES, "int8");

data_ch1 = (str2double(verticalScale) * (data)' ); % + str2double(yOffset)

% SECOND CHANNEL --------------------------------------------------

fprintf(myScope, 'DAT:SOU CH2');

fprintf(myScope, 'DATA:START 1');

fprintf(myScope, 'DATA:STOP 100000');

yOffset = query(myScope, 'WFMO:YOFF?');

verticalScale  = query(myScope,'WFMOUTPRE:YMULT?');

fprintf(myScope, 'DATA:ENCDG RIBINARY');

fprintf(myScope, 'WIDTH 1');

fprintf(myScope, 'HEAD 0');

fprintf(myScope, 'CURVE?');

% Read the captured data as 8-bit integer data type
data = fread(myScope, NUM_SAMPLES, "int8");

data_ch2 = (str2double(verticalScale) * (data)' ); % + str2double(yOffset)

% Clean up Close the connection
fclose(myScope);
% Clear the variable
clear myScope;

% Plot the acquired data and add axis labels
%clf;
plot(data_ch1);
hold on
plot(data_ch2);
xlabel('Sample Index'); 
ylabel('Volts');
title('Waveform Acquired from Tektronix Oscilloscope');
grid on;
