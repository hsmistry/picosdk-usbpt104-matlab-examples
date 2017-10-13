%% USB PT-104 Platinum Resistance Temperature Data Logger Example
%
% This script demonstrates how to:
%
% * Enumerate devices connected to the PC
% * Open a connection to a USB PT-104 data logger
% * Display unit information
% * Set mains rejection
% * Configure a channel
% * Take readings
% * Plot data
% * Close the connection to the unit
%
% Please refer to the
% <https://www.picotech.com/download/manuals/usb-pt104-rtd-data-logger-programmers-guide.pdf PT-104 USB/Ethernet RTD Data Logger Programmer's Guide> for further information.
% This file can be edited to suit application requirements.
%
% *Copyright:* © 2016-2017 Pico Technology Ltd. See LICENSE file for terms.

%% Close any open figures, clear console window

close all;
clc;
clear;

disp('USB PT-104 Platinum Resistance Data Logger Example')

%% Load configuration information

USBPT104Config;

%% Load shared library

% Indentify architecture and obtain function handle for the correct
% prototype file.
    
archStr = computer('arch');

usbpt104MFile = str2func(strcat('usbpt104MFile_', archStr));

if (ismac())
    
    [usbpt104NotFound, usbpt104Warnings] = loadlibrary('libusbpt104.dylib', usbpt104MFile, 'alias', 'usbpt104');
    
    % Check if the library is loaded
    if ~libisloaded('usbpt104')
    
        error('USBPT104Example:LibaryNotLoaded', 'Library libusbpt104.dylib not loaded.');
    
    end
    
elseif (isunix())
    
    [usbpt104NotFound, usbpt104Warnings] = loadlibrary('libusbpt104.so', usbpt104MFile, 'alias', 'usbpt104');
    
    % Check if the library is loaded
    if ~libisloaded('usbpt104')
    
        error('USBPT104Example:LibaryNotLoaded', 'Library libusbpt104.so not loaded.');
    
    end

elseif (ispc())
    
    [usbpt104NotFound, usbpt104Warnings] = loadlibrary('usbpt104.dll', usbpt104MFile);

    if ~libisloaded('usbpt104')

        error('USBPT104Example:LibaryNotLoaded', 'Library usbpt104.dll not loaded.');

    end
    
else
    
    error('USBPT104Example:OSNotSupported', 'Operating system not supported, please contact support@picotech.com');

end

%% Enumerate units
% Identify any PT-104 units connected via USB and Ethernet

details             = blanks(100);
detailsLth          = length(details);
communicationType   = usbpt104Enuminfo.enCommunicationType.CT_ALL;

fprintf('\nEnumerating units...\n');

[status.enumerateUnits, details, detailsLth] = calllib('usbpt104', 'UsbPt104Enumerate', details, detailsLth, communicationType);

if (status.enumerateUnits == PicoStatus.PICO_OK)
   
    fprintf('Details: %s\n', details);
    
else
    
    error('USBPT104Example:EnumerateUnitsError', 'Enumerate units status code: %d', status.enumerateUnits);
    
end

%% Open communication
% In this example, a connection is opened via USB

handlePtr = libpointer('int16Ptr', 0);
serial    = [];

status.open = calllib('usbpt104', 'UsbPt104OpenUnit', handlePtr, serial);

if (status.open == PicoStatus.PICO_OK)

    handle = get(handlePtr, 'Value');
    
elseif (status.open == PicoStatus.PICO_NOT_FOUND)
   
    error('USBPT104Example:UnitNotFound', 'USB PT-104 Unit not found.');
    
else
    
    error('USBPT104Example:OpenUnitError', 'Open unit status code: %d', status.openUnit);
    
end

%% Display unit information

fprintf('\nUnit information:-\n\n');

information = {'Driver version: ', 'USB Version: ', 'Hardware version: ', 'Variant: ', 'Batch/Serial: ', 'Cal. date: ', 'Kernel driver version: '};

pRequiredSize = libpointer('int16Ptr', 0);

status.unitInfo = zeros(length(information), 1, 'uint32');

% Loop through each information type
for n = 1:length(information)
    
    infoLine = blanks(100);

    [status.unitInfo(n), infoLine1] = calllib('usbpt104', 'UsbPt104GetUnitInfo', handle, infoLine, length(infoLine), pRequiredSize, (n-1));
    
    if (status.unitInfo(n) == PicoStatus.PICO_OK)
    
        disp([information{n} infoLine1]);
    
    end
    
end

fprintf('\n');
    
%% Noise Rejection

status.setMains = calllib('usbpt104', 'UsbPt104SetMains', handle, 0); % 0 for 50 Hz, 1 for 60 Hz

%% Set channel
% Set channel 1 for a PT-100 sensor

channel1    = usbpt104Enuminfo.enUsbPt104Channels.USBPT104_CHANNEL_1;
dataType    = usbpt104Enuminfo.enUsbPt104DataType.USBPT104_PT100; 

status.setChannel = calllib('usbpt104', 'UsbPt104SetChannel', handle, channel1, dataType, 4); %handle, channel, data type, noOfWires

pause(2) % Wait for device to make conversion before going on to get value or no value will show.

%% Get value
% Retrieve filtered data value for channel 1.
% The data value returned will be a scaled value (refer to the function
% definition in the Programmer's Guide).

disp('Collecting data...');

% Define the number of samples to collect
numSamples = 30;
dataValues = zeros(numSamples,1);

for n = 1:numSamples

    valuePtr = libpointer('int32Ptr', 0);

    status.getValue = calllib('usbpt104', 'UsbPt104GetValue', handle, channel1, valuePtr, 1);

    dataValues(n,1) = get(valuePtr, 'Value');
    
    % Convert the data using the appropriate scale
    if (dataType == usbpt104Enuminfo.enUsbPt104DataType.USBPT104_PT100)
       
        dataValues(n,1) = dataValues(n,1) / 1000;
        
    end
    
    % Wait for one second
    pause(1);
    
end

disp('Data collection complete.');

%% Process the data
% In this example, the data is shown on a plot

% Plot the data
figure('Name','USB PT-104 Platinum Resistance Data Logger Example', ...
    'NumberTitle', 'off');

hold on;

plot(1:numSamples, dataValues);

title('Plot of Temperature vs. Sample');
xlabel('Sample')
ylabel('Temperature (°C)')

legend('Channel 1')
grid on;

hold off;

%% Close connection to device

calllib('usbpt104', 'UsbPt104CloseUnit', handle);

%% Unload library

unloadlibrary('usbpt104');