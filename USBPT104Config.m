%% USBPT104Config Configure path information
% Configures paths according to platforms and loads information from
% prototype files for PT-104 USB/Ethernet RTD Data Loggers. The folder 
% that this file is located in must be added to the MATLAB path.
%
% Platform Specific Information:-
%
% Microsoft Windows: Download the Software Development Kit installer from
% the <a href="matlab: web('https://www.picotech.com/downloads')">Pico Technology Download software and manuals for oscilloscopes and data loggers</a> page.
% 
% Linux: Follow the instructions to install the libusbpt104 package from the <a href="matlab:
% web('https://www.picotech.com/downloads/linux')">Pico Technology Linux Software & Drivers for Oscilloscopes and Data Loggers</a> page.
%
% Apple Mac OS X: Follow the instructions to install the PicoScope 6
% application from the <a href="matlab: web('https://www.picotech.com/downloads')">Pico Technology Download software and manuals for oscilloscopes and data loggers</a> page.
% Optionally, create a 'maci64' folder in the same directory as this file
% and copy the following files into it:
%
% * libusbpt104.dylib and any other libusbpt104 library files
%
% Contact our Technical Support team via the <a href="matlab: web('https://www.picotech.com/tech-support/')">Technical Enquiries form</a> for further assistance.
%
% Run this script in the MATLAB environment prior to connecting to the 
% device.
%
% This file can be edited to suit application requirements.
%
% *Copyright:* © 2016-2017 Pico Technology Ltd. See LICENSE file for terms.

%% Set Path to Shared Libraries
% Set paths to shared library files according to the operating system and
% architecture.

% Identify working directory
usbpt104ConfigInfo.workingDir = pwd;

% Find file name
usbpt104ConfigInfo.configFileName = mfilename('fullpath');

% Only require the path to the config file
[usbpt104ConfigInfo.pathStr] = fileparts(usbpt104ConfigInfo.configFileName);

% Identify architecture e.g. 'win64'
usbpt104ConfigInfo.archStr = computer('arch');

try

    addpath(fullfile(usbpt104ConfigInfo.pathStr, usbpt104ConfigInfo.archStr));
    
catch err
    
    error('USBPT104Config:OperatingSystemNotSupported', 'Operating system not supported - please contact support@picotech.com');
    
end

% Set the path according to operating system.

if (ismac())
    
    % Libraries (including wrapper libraries) are stored in the PicoScope
    % 6 App folder. Add locations of library files to environment variable.
    
    setenv('DYLD_LIBRARY_PATH', '/Applications/PicoScope6.app/Contents/Resources/lib');
    
    if(contains(getenv('DYLD_LIBRARY_PATH'), '/Applications/PicoScope6.app/Contents/Resources/lib'))
       
        addpath('/Applications/PicoScope6.app/Contents/Resources/lib');
        
    else
        
        warning('USBPT104Config:LibraryPathNotFound', 'Locations of libraries not found in DYLD_LIBRARY_PATH');
        
    end
    
elseif (isunix())
	    
    % Edit to specify location of .so files or place .so files in same directory
    addpath('/opt/picoscope/lib/'); 
		
elseif (ispc())
    
    % Microsoft Windows operating systems
    
    % Set path to dll files if the Pico Technology SDK Installer has been
    % used or place dll files in the folder corresponding to the
    % architecture. Detect if 32-bit version of MATLAB on 64-bit Microsoft
    % Windows.
    
    usbpt104ConfigInfo.winSDKInstallPath = '';
    
    if (strcmp(usbpt104ConfigInfo.archStr, 'win32') && exist('C:\Program Files (x86)\', 'dir') == 7)
       
        try 
            
            addpath('C:\Program Files (x86)\Pico Technology\SDK\lib\');
            usbpt104ConfigInfo.winSDKInstallPath = 'C:\Program Files (x86)\Pico Technology\SDK';
            
        catch err
           
            warning('USBPT104Config:DirectoryNotFound', ['Folder C:\Program Files (x86)\Pico Technology\SDK\lib\ not found. '...
                'Please ensure that the location of the library files are on the MATLAB path.']);
            
        end
        
    else
        
        % 32-bit MATLAB on 32-bit Windows or 64-bit MATLAB on 64-bit
        % Windows operating systems
        try 
        
            addpath('C:\Program Files\Pico Technology\SDK\lib\');
            usbpt104ConfigInfo.winSDKInstallPath = 'C:\Program Files\Pico Technology\SDK';
            
        catch err
           
            warning('USBPT104Config:DirectoryNotFound', ['Folder C:\Program Files\Pico Technology\SDK\lib\ not found. '...
                'Please ensure that the location of the library files are on the MATLAB path.']);
            
        end
        
    end
    
else
    
    error('USBPT104Config:OperatingSystemNotSupported', 'Operating system not supported - please contact support@picotech.com');
    
end

%% Set Path for PicoScope Support Toolbox Files if not Installed
% Set MATLAB Path to include location of PicoScope Support Toolbox
% Functions and Classes if the Toolbox has not been installed. Installation
% of the toolbox is only supported in MATLAB 2014b and later versions.
%
% Check if PicoScope Support Toolbox is installed - using code based on
% <http://stackoverflow.com/questions/6926021/how-to-check-if-matlab-toolbox-installed-in-matlab How to check if matlab toolbox installed in matlab>

usbpt104ConfigInfo.psTbxName = 'PicoScope Support Toolbox';
usbpt104ConfigInfo.v = ver; % Find installed toolbox information

if (~any(strcmp(usbpt104ConfigInfo.psTbxName, {usbpt104ConfigInfo.v.Name})))
   
    warning('USBPT104Config:PSTbxNotFound', 'PicoScope Support Toolbox not found, searching for folder.');
    
    % If the PicoScope Support Toolbox has not been installed, check to see
    % if the folder is on the MATLAB path, having been downloaded via zip
    % file.
    
    usbpt104ConfigInfo.psTbxFound = strfind(path, usbpt104ConfigInfo.psTbxName);
    
    if (isempty(usbpt104ConfigInfo.psTbxFound))
        
        warning('USBPT104Config:PSTbxDirNotFound', 'PicoScope Support Toolbox directory not found.');
            
    end
    
end

% Change back to the folder where the script was called from.
cd(usbpt104ConfigInfo.workingDir);

%% Load Enumerations and Structure Information
% Enumerations and structures can be used with function calls to the shared
% library.

% Find prototype file names based on architecture

usbpt104ConfigInfo.usbpt104MFile = str2func(strcat('usbpt104MFile_', usbpt104ConfigInfo.archStr));
[usbpt104Methodinfo, usbpt104Structs, usbpt104Enuminfo, usbpt104ThunkLibName] = usbpt104ConfigInfo.usbpt104MFile(); 
