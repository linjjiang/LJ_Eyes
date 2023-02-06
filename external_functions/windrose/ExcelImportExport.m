clc; clear all; close all;

%% Check that excel.exe is not running

[~,result] = system('tasklist /FI "imagename eq excel.exe" /fo table /nh'); %Check if the process excel.exe is running (taks manager process list)
while ~isempty(strfind(result,'EXCEL.EXE')) % If excel.exe is there, display message
    PosibAnswers   = {'I have saved my work and manually closed excel','I cannot close excel, kill the process'};
    Seleccion    = questdlg({'Excel is running.';'Save your work, close excel and choose one of the following options.'},'EXCEL IS RUNNING!',PosibAnswers{1},PosibAnswers{2},PosibAnswers{1});
    switch Seleccion
        case PosibAnswers{2} % If user wants to kill the process
            system('taskkill /IM "Excel.exe" /F /T'); % Kill the process, force termination
    end
    [~,result]   = system('tasklist /FI "imagename eq excel.exe" /fo table /nh'); % Re check that excel is not running.
end

%% Reading data, creating windrose, writing output table and saving image into file.
% Read the excel spreadsheet data
ExcelName   = [pwd filesep 'wind data.xlsx'];          % Full path to Excel input file e.g.: 'C:\Users\User1\Desktop\Wind data.xlsx'
OutputExcel = [pwd filesep 'wind data outputs.xlsx'];  % Full path to Excel output file e.g.: 'C:\Users\User1\Desktop\Wind data.xlsx'
if exist(OutputExcel,'file'); delete(OutputExcel); end % Delete the output excel if it exists, as a new one will be created.
[data]      = xlsread(ExcelName,'Data'); 

% Assign direction and speed
direction = data(:,1); % Directions are in the first column
speed = data(:,2);     % Speeds are in the second column

% Define options for the wind rose 
Options = {'anglenorth',0,... 'The angle in the north is 0 deg (this is the reference from our data, but can be any other)
           'angleeast',90,... 'The angle in the east is 90 deg
           'labels',{'N (0°)','S (180°)','E (90°)','W (270°)'},... 'If you change the reference angles, do not forget to change the labels.
           'freqlabelangle',45};

% Launch the windrose with necessary output arguments.
[figure_handle,count,speeds,directions,Table] = WindRose(direction,speed,Options);

% Write the output table into same excel, new worksheet
% Change OutputExcel to ExcelName if you want the outputs to be created in the input excel.
xlswrite(OutputExcel,Table,1,'A1'); % Write into the ExcelFile the table data in sheet 1 (you can specify a name), starting at cell A1.

% Save the figure into an image file
ImageName = ['WindRose_' datestr(now,'yymmdd_HHMMSS') '.png']; % Save the image into WindRose_date_time.png
print('-dpng',ImageName,'-painters'); % Print = save
% delete(figure_handle); % Close the widnrose figure
clear figure_handle;   % Clear the figure handle variable

%% Writing the image into excel (tricky part)
% Retrieve image dimensions
a      = size(imread(ImageName));
width  = a(2);
height = a(1);
clear a;

% Open the excel file for internal modifications
Excel = actxserver ('Excel.Application'); % handle to excel application
try
    ExcelWorkbook = Excel.workbooks.Open(OutputExcel); % Excel 2010+
catch exc
    try
        ExcelWorkbook = invoke(Excel.workbooks,'Open',OutputExcel); % Previous versions
    catch exc2
        disp(exc.message);disp(exc2.message);throw(exc2); % didn't work. could not open excel file for modifications.
    end
end

% Get the sheet name
Sheets  = Excel.ActiveWorkBook.Sheets;
ActSht = Sheets.Item(1); % If you specified a name for the output sheet, specify it here again, insetad of 1.

% Convert the pixels into points
auxfig = figure('units','pixels','position',[0 0 width height]); % auxiliary figure with dimensions in pixels
set(auxfig,'units','points'); % convert dimensions into points
p = get(auxfig,'position');   % Get the position in points
delete(auxfig);               % close the auxiliary figure
clear auxfig;
p      = p * 0.75;            % Scale factor for image in excel, change as needed.
width  = p(3);                % Width in points
height = p(4);                % heihgt in points

% Add the picture inside the excel
ActSht.Shapes.AddPicture([pwd filesep ImageName],0,1,ActSht.Range('B1').Left,ActSht.Range(['A' num2str(size(Table,1)+2)]).Top,width,height);  % VBA reference:  .AddPicture(Filename, LinkToFile, SaveWithDocument, Left, Top, Width, Height)

% Close the excel file
[~,~,Ext]  = fileparts(OutputExcel);
if strcmpi(Ext,'.xlsx') % If xlsx file
    ExcelWorkbook.Save  % Save the workbook
    ExcelWorkbook.Close(false) % Close Excel workbook.
    Excel.Quit;         % Quit excel application
    delete(Excel);      % Delete the handle to the application
elseif strcmpi(Ext,'.xls') % If old format
    invoke(Excel.ActiveWorkbook,'Save'); % Save
    Excel.Quit          % Quit Excel application
    Excel.delete        % Delete the handle to the application.
end