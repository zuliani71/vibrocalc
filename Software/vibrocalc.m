function vibrocalc(action,opt1,opt2)
% - Ver 1.00 written  by David ZUliani 2004/01/01
% - Ver 1.10 modified by David Zuliani 2010/02/11
%   added spafdr calculus method
%   some minor changes for compatibility between matlab 7.0, 7.5 and 7.9
% - Ver 1.20 modified by David Zuliani 2010/02/12
%   removed latex interpreter for titles and legends
%   removed a bug for overwriting plot names when you do different elaborations
%   added units of magnitude to all the data plots (both time and freq)
%   added more checks for missing channels or missing files
%   added more checks for a right kind of loaded result
% - Ver 1.15 modified by David Zuliani 2010/02/17
%   added the cookie for the pathname results (mat and txt reports)
% - Ver 1.20 modified by David Zuliani 2010/02/118
%   better setup of the pathfilename to the mfile default dir
%   all spectral estimates methods and parameters implemented
%   minor changes to access the vibrocalc help file
%   minor changes for no supported functions
% - Ver 1.25 modified by David Zuliani 2010/02/22
%   minor changes to support matlab 7.9 ver
%   improved report printout
%   corrected report (with 45° and revert phase infos
%    embedded within data channels)
%   added figure path savings
%   improved comments inside vibtab.cfg
%   changed  colors
% - todo a control when ChanA and ChanB are not
%    calcultated and you want to plot them

warning off;
if nargin<1
    action='initialize';
end

% [R G B]
% Main figure background color
ColorMain=[0.8 0.8 0.8];

% background edits color
%ColorEdit=[0.5 0.6 0.7];
ColorEdit=[1 1 1];

% buttons, background pop-ups color
ColorBackground_1=[0.831372549019608 0.815686274509804 0.784313725490196];

% background pannel color up
%ColorBackground_2=[0.4 0.4 0.4];
ColorBackground_2=[0.3 0.5 0.8];

% background pannel color down
%ColorBackground_3=[0.4 0.4 0.6];
ColorBackground_3=[0.3 0.5 0.8];

% Title background colors
%ColorBackground_4=[0.4 0.8 0.9];
ColorBackground_4=[1 0.8 0.5];

% Background edit info colors (Channel summary values)
ColorBackground_5=[1 1 1];


% Setting SLASH for computer dependent PATHS
if ispc
    SLASH_TYPE = '\';
else
    SLASH_TYPE = '/';
end

%set paths and config files
%[Objects.LocalPathName,NAME,EXT,VERSN] = fileparts(mfilename('fullpath'));
[Objects.LocalPathName,NAME,EXT] = fileparts(mfilename('fullpath'));
Objects.ScriptVer = 'Ver. 1.25';
Objects.ConfigPath   =	[Objects.LocalPathName,SLASH_TYPE];
Objects.ConfigFileName	=	[Objects.LocalPathName,SLASH_TYPE,'vibtab.cfg'];
Objects.PathFileName	=	[Objects.LocalPathName,SLASH_TYPE,'vibtab.path'];

% check the path config file
D=dir(Objects.PathFileName);
if isempty(D)
    set_path({},{},Objects.PathFileName);
end

SummaryStrings_Default = {  'Channel ref. name: ',...
    'Buffer file name: ',...
    'Datalogger type: ',...
    'Datalogger sensitivity: ',...
    'Datalogger channel: ',...
    'Datalogger sampling time: ',...
    'Date: ','Time of 1st sample: ',...
    'Num. of samples: ',...
    'Sensor type: ',...
    'Data Units: '};
SensorTypeString_Default={'None','Laser','Velocimeter','Accelerometer'};

Objects.Loaded_Channels_Default = struct('Ref_Name','',...
    'Path','',...
    'Logger_Sens',[],...
    'Logger_Units','',...
    'Sens_Type','',...
    'Logger_Type','',...
    'Logger_Chan','',...
    'Logger_Sampling',[],...
    'Date','',...
    'Time1st','',...
    'Num_Sample',[],...
    'Units',[],...
    'Data',[]);

Objects.Loaded_Channels=Objects.Loaded_Channels_Default;

if strcmp(action,'initialize');
    [Ref_Name,Path,Logger_Sens,Logger_Units]=textread(Objects.ConfigFileName,'%s %s %f %s','commentstyle','shell');
    Ref_Name={'none',Ref_Name{:}}';
    Path={'none',Path{:}}';
    Logger_Sens=[0;Logger_Sens];
    Logger_Units={'none',Logger_Units{:}}';
    Units=Logger_Units; %aggiunto da David 18/08/2005
    fields={'Ref_Name','Path','Logger_Sens','Logger_Units','Units'};
    Channels=cell2struct([Ref_Name,Path,num2cell(Logger_Sens),Logger_Units,Units],fields,2);
    MainFigure = figure('Color',ColorMain, ...
        'Units','normalized', ...
        'FileName',[Objects.LocalPathName,SLASH_TYPE,NAME,'.',EXT], ...
        'PaperUnits','normalized', ...
        'PaperPosition',[0 0 0.1 0.1], ...
        'Position',[0.2 0.2 0.7 0.7], ...
        'Tag','Fig1', ...
        'Name','vibrocalc',...
        'NumberTitle','off',...
        'ToolBar','none');
    
    %***************** Top Popups & their Strings ****************************
    pos=[0.02 0.30 0.96 0.635];
    Objects.Top_Frame = uicontrol('Parent',MainFigure, ...
        'Units','normalized', ...
        'FontUnits','normalized',...
        'BackgroundColor',ColorBackground_2, ...
        'Position',pos, ...
        'Style','frame', ...
        'Tag','StaticText1');
    
    %****************** Channel A ******************
    pos=[0.03 0.68 0.45 0.21];
    dpos=[0 0.211 0 -0.18];
    CallBackString='vibrocalc(''PopUp_Chan'',''A'')';
    String={Channels.Ref_Name};
    Objects.PopUp_ChanA = uicontrol('Parent',MainFigure, ...
        'Units','normalized', ...
        'FontUnits','normalized',...
        'FontSize',0.08,...
        'FontName','Helvetica',...
        'FontWeight','bold',...
        'BackgroundColor',ColorBackground_1, ...
        'ListboxTop',0, ...
        'Position',pos, ...
        'String',String, ...
        'Call',CallBackString,...
        'Style','popupmenu', ...
        'Tag','PopupMenu1', ...
        'Enable','on',...
        'UserData',Channels,...
        'Value',1);
    Objects.Text_ChanA = uicontrol('Parent',MainFigure, ...
        'Units','normalized', ...
        'FontUnits','normalized',...
        'FontSize',0.8,...
        'FontName','Helvetica',...
        'FontWeight','bold',...
        'BackgroundColor',ColorBackground_4, ...
        'ListboxTop',0, ...
        'Position',pos+dpos, ...
        'HorizontalAlignment','left',...
        'String','Channel A:', ...
        'Style','text', ...
        'Tag','StaticText1');
    pos=[0.03 0.59 0.45 0.21];
    dpso=[0 0.211 0 -0.18];
    CallBackString='vibrocalc(''PopUp_Chan'',''A'',''A'')';
    Objects.PopUp_SensorA = uicontrol('Parent',MainFigure, ...
        'Units','normalized', ...
        'FontUnits','normalized',...
        'FontSize',0.08,...
        'FontName','Helvetica',...
        'FontWeight','bold',...
        'BackgroundColor',ColorBackground_1, ...
        'ListboxTop',0, ...
        'Position',pos, ...
        'String',SensorTypeString_Default, ...
        'Call',CallBackString,...
        'Style','popupmenu', ...
        'Tag','PopupMenu1', ...
        'Enable','on',...
        'Value',1);
    Objects.Text_SensorA = uicontrol('Parent',MainFigure, ...
        'Units','normalized', ...
        'FontUnits','normalized',...
        'FontSize',0.8,...
        'FontName','Helvetica',...
        'FontWeight','bold',...
        'BackgroundColor',ColorBackground_4, ...
        'ListboxTop',0, ...
        'Position',pos+dpos, ...
        'HorizontalAlignment','left',...
        'String','Sensor type:', ...
        'Style','text', ...
        'Tag','StaticText1');
    
    %****************** Channel B ******************
    pos=[0.52 0.68 0.45 0.21];
    dpos=[0 0.211 0 -0.18];
    CallBackString='vibrocalc(''PopUp_Chan'',''B'')';
    String={Channels.Ref_Name};
    Objects.PopUp_ChanB = uicontrol('Parent',MainFigure, ...
        'Units','normalized', ...
        'FontUnits','normalized',...
        'FontSize',0.08,...
        'FontName','Helvetica',...
        'FontWeight','bold',...
        'BackgroundColor',ColorBackground_1, ...
        'ListboxTop',0, ...
        'Position',pos, ...
        'String',String, ...
        'Call',CallBackString,...
        'Style','popupmenu', ...
        'Tag','PopupMenu1', ...
        'Enable','on',...
        'UserData',Channels,...
        'Value',1);
    Objects.Text_ChanB = uicontrol('Parent',MainFigure, ...
        'Units','normalized', ...
        'FontUnits','normalized',...
        'FontSize',0.8,...
        'FontName','Helvetica',...
        'FontWeight','bold',...
        'BackgroundColor',ColorBackground_4, ...
        'ListboxTop',0, ...
        'Position',pos+dpos, ...
        'HorizontalAlignment','left',...
        'String','Channel B:', ...
        'Style','text', ...
        'Tag','StaticText1');
    pos=[0.52 0.59 0.45 0.21];
    dpos=[0 0.211 0 -0.18];
    CallBackString='vibrocalc(''PopUp_Chan'',''B'',''B'')';
    Objects.PopUp_SensorB = uicontrol('Parent',MainFigure, ...
        'Units','normalized', ...
        'FontUnits','normalized',...
        'FontSize',0.08,...
        'FontName','Helvetica',...
        'FontWeight','bold',...
        'BackgroundColor',ColorBackground_1, ...
        'ListboxTop',0, ...
        'Position',pos, ...
        'String',SensorTypeString_Default, ...
        'Call',CallBackString,...
        'Style','popupmenu', ...
        'Tag','PopupMenu1', ...
        'Enable','on',...
        'Value',1);
    Objects.Text_SensorB = uicontrol('Parent',MainFigure, ...
        'Units','normalized', ...
        'FontUnits','normalized',...
        'FontSize',0.8,...
        'FontName','Helvetica',...
        'FontWeight','bold',...
        'BackgroundColor',ColorBackground_4, ...
        'ListboxTop',0, ...
        'Position',pos+dpos, ...
        'HorizontalAlignment','left',...
        'String','Sensor type:', ...
        'Style','text', ...
        'Tag','StaticText1');
    
    %***************** Top Edit & Strings ****************************
    SummaryStrings_Default;
    pos=[0.03 0.45 0.45 0.26];
    dpos=[0.01 0.01 -0.02 -0.02];
    dposT=[0 0.261 0 -0.23];
    Objects.Text_Summary_ChanA = uicontrol('Parent',MainFigure, ...
        'Units','normalized', ...
        'FontUnits','normalized',...
        'FontSize',0.8,...
        'FontName','Helvetica',...
        'FontWeight','bold',...
        'BackgroundColor',ColorBackground_4, ...
        'ListboxTop',0, ...
        'Position',pos+dposT, ...
        'HorizontalAlignment','left',...
        'String','Channel A summary:', ...
        'Style','text', ...
        'Tag','StaticText1');
    Objects.Edit_SensorA = uicontrol('Parent',MainFigure, ...
        'Units','normalized', ...
        'FontUnits','normalized',...
        'BackgroundColor',ColorEdit, ...
        'Position',pos, ...
        'Style','edit', ...
        'Tag','StaticText1');
    Objects.TextSummary_SensorA = uicontrol('Parent',MainFigure, ...
        'Units','normalized', ...
        'FontUnits','normalized',...
        'FontSize',0.07,...
        'FontName','Helvetica',...
        'FontWeight','bold',...
        'BackgroundColor',ColorBackground_5, ...
        'ListboxTop',0, ...
        'Position',pos+dpos, ...
        'HorizontalAlignment','left',...
        'String',SummaryStrings_Default,...
        'Style','text', ...
        'Tag','StaticText1');
    
    pos=[0.52 0.45 0.45 0.26];
    dpos=[0.01 0.01 -0.02 -0.02];
    dposT=[0 0.261 0 -0.23];
    Objects.Text_Summary_ChanB = uicontrol('Parent',MainFigure, ...
        'Units','normalized', ...
        'FontUnits','normalized',...
        'FontSize',0.8,...
        'FontName','Helvetica',...
        'FontWeight','bold',...
        'BackgroundColor',ColorBackground_4, ...
        'ListboxTop',0, ...
        'Position',pos+dposT, ...
        'HorizontalAlignment','left',...
        'String','Channel B summary:', ...
        'Style','text', ...
        'Tag','StaticText1');
    Objects.Edit_SensorB = uicontrol('Parent',MainFigure, ...
        'Units','normalized', ...
        'FontUnits','normalized',...
        'FontSize',0.07,...
        'FontName','Helvetica',...
        'FontWeight','bold',...
        'BackgroundColor',ColorEdit, ...
        'Position',pos, ...
        'Style','edit', ...
        'Tag','StaticText1');
    Objects.TextSummary_SensorB = uicontrol('Parent',MainFigure, ...
        'Units','normalized', ...
        'FontUnits','normalized',...
        'FontSize',0.07,...
        'FontName','Helvetica',...
        'FontWeight','bold',...
        'BackgroundColor',ColorBackground_5, ...
        'ListboxTop',0, ...
        'Position',pos+dpos, ...
        'HorizontalAlignment','left',...
        'String',SummaryStrings_Default,...
        'Style','text', ...
        'Tag','StaticText1');
    
    %***************** Top Plot Type of plot ****************************
    pos=[0.52 0.185 0.45 0.21];
    dpos=[0 0.211 0 -0.18];
    st={'Time[HH:MM:SS]','Time[s]','Frequency'};
    CallBackString='vibrocalc(''PopUp_TypePlot'')';
    Objects.PopUp_TypePlot = uicontrol('Parent',MainFigure, ...
        'Units','normalized', ...
        'FontUnits','normalized',...
        'FontSize',0.08,...
        'FontName','Helvetica',...
        'FontWeight','bold',...
        'BackgroundColor',ColorBackground_1, ...
        'ListboxTop',0, ...
        'Position',pos, ...
        'String',st, ...
        'Call',CallBackString,...
        'Style','popupmenu', ...
        'Tag','PopupMenu1', ...
        'Enable','on',...
        'Value',1);
    Objects.Text_TypePlot = uicontrol('Parent',MainFigure, ...
        'Units','normalized', ...
        'FontUnits','normalized',...
        'FontSize',0.8,...
        'FontName','Helvetica',...
        'FontWeight','bold',...
        'BackgroundColor',ColorBackground_4, ...
        'ListboxTop',0, ...
        'Position',pos+dpos, ...
        'HorizontalAlignment','left',...
        'String','Type of plot:', ...
        'Style','text', ...
        'Tag','StaticText1');
    
    %***************** Top Plot Buttons ****************************
    CallBackString='vibrocalc(''Plot_Channels'')';
    pos=[0.52 0.315 0.45 0.04];
    Objects.Button_Plot_Channels = uicontrol('Parent',MainFigure, ...
        'Units','normalized', ...
        'FontUnits','normalized',...
        'FontSize',0.6,...
        'FontName','Helvetica',...
        'FontWeight','bold',...
        'BackgroundColor',ColorBackground_1, ...
        'ListboxTop',0, ...
        'Position',pos, ...
        'Style','pushbutton', ...
        'String','Plot', ...
        'Call',CallBackString,...
        'BusyAction','cancel',...
        'Enable','on',...
        'Tag','Pushbutton1');
    %***************** Top Plot Lists ****************************
    pos=[0.03 0.315 0.45 0.08];
    dpos=[0 0.083 0 -0.05];
    String={'Chan_A','Chan_B',Channels(2:end).Ref_Name};
    CallBackString='vibrocalc(''Channel_List'')';
    Objects.ListBox_Channel_List = uicontrol('Parent',MainFigure, ...
        'Units','normalized', ...
        'FontUnits','normalized',...
        'FontSize',0.25,...
        'FontName','Helvetica',...
        'FontWeight','bold',...
        'BackgroundColor',ColorBackground_1, ...
        'Position',pos, ...
        'Style','listbox', ...
        'String',String, ...
        'Max',3,...
        'Min',1,...
        'Call',CallBackString,...
        'BusyAction','cancel',...
        'Enable','on',...
        'Tag','Pushbutton1');
    Objects.Text_Channel_List = uicontrol('Parent',MainFigure, ...
        'Units','normalized', ...
        'FontUnits','normalized',...
        'FontSize',0.8,...
        'FontName','Helvetica',...
        'FontWeight','bold',...
        'BackgroundColor',ColorBackground_4, ...
        'ListboxTop',0, ...
        'Position',pos+dpos, ...
        'HorizontalAlignment','left',...
        'String','Choose channels to plot:', ...
        'Style','text', ...
        'Tag','StaticText1');
    
    %***************** Middle Edits & Strings ****************************
    pos=[0.02 0.01 0.96 0.28];
    Objects.Middle_Frame = uicontrol('Parent',MainFigure, ...
        'Units','normalized', ...
        'FontUnits','normalized',...
        'BackgroundColor',ColorBackground_3, ...
        'Position',pos, ...
        'Style','frame', ...
        'Tag','StaticText1');
    
    st={'Channel ref. name:','Buffer file name:','Datalogger type:',...
        'Datalogger sensitivity:','Datalogger channel:',...
        'Datalogger sampling time:','Time of 1st sample:','Num. of samples:','Sensor type:'};
    
    pos=[0.15 0.2 0.10 0.045];
    dposT=[-0.12 0.05 0.15 -0.018];
    dposTA=[-0.12 0.01 -0.04 -0.018];
    dposTAHz=[0.11 0.01 -0.08 -0.018];
    dposTBE=[0 -0.05 0 0];
    dposTB   = [-0.12 0.01 -0.035 -0.018];
    dposTBHz = [0.11 0.01 -0.08 -0.018];
    dposForm = [-0.12 -0.18 0.15 0.08];
    dposB= [0.15 0.01 0.10 0.18];
    dposA= [0.15 0.06 0.10 0.18];
    dposC= [-0.05 0.01 -0.01 -0.018];
    dposD= [-0.05 -0.04 -0.01 -0.018];
    dposE= [0.065 -0.015 -0.035 -0.018];
    dposF= [-0.12 0.045 0.06 -0.015];
    dposG= [0.05 0.045 -0.02 -0.015];
    Objects.Text_Phase_Rotation = uicontrol('Parent',MainFigure, ...
        'Units','normalized', ...
        'FontUnits','normalized',...
        'FontSize',0.8,...
        'FontName','Helvetica',...
        'FontWeight','bold',...
        'BackgroundColor',ColorBackground_4, ...
        'ListboxTop',0, ...
        'Position',pos+dposF, ...
        'HorizontalAlignment','left',...
        'String','Phase rotations:', ...
        'Style','text', ...
        'Tag','StaticText1');
    Objects.Text_45_Test = uicontrol('Parent',MainFigure, ...
        'Units','normalized', ...
        'FontUnits','normalized',...
        'FontSize',0.8,...
        'FontName','Helvetica',...
        'FontWeight','bold',...
        'BackgroundColor',ColorBackground_4, ...
        'ListboxTop',0, ...
        'Position',pos+dposG, ...
        'HorizontalAlignment','left',...
        'String','45 test:', ...
        'Style','text', ...
        'Tag','StaticText1');
    CallBackString='vibrocalc(''RevPhase'')';
    Objects.Phase_Rotation_checkA = uicontrol('Parent',MainFigure, ...
        'Units','normalized', ...
        'FontUnits','normalized',...
        'FontSize',0.65,...
        'FontName','Helvetica',...
        'FontWeight','bold',...
        'BackgroundColor',ColorBackground_4, ...
        'ListboxTop',0, ...
        'Position',pos+dposC, ...
        'HorizontalAlignment','left',...
        'HandleVisibility','off',...
        'Enable','on',...
        'Max',1,...
        'Min',0,...
        'String','Revert Ph.', ...
        'Call',CallBackString,...
        'Style','checkbox', ...
        'Tag','checkbox1',...
        'Visible','on');
    CallBackString='vibrocalc(''RevPhase'')';
    Objects.Phase_Rotation_checkB = uicontrol('Parent',MainFigure, ...
        'Units','normalized', ...
        'FontUnits','normalized',...
        'FontSize',0.65,...
        'FontName','Helvetica',...
        'FontWeight','bold',...
        'BackgroundColor',ColorBackground_4, ...
        'ListboxTop',0, ...
        'Position',pos+dposD, ...
        'HorizontalAlignment','left',...
        'HandleVisibility','off',...
        'Enable','on',...
        'Max',1,...
        'Min',0,...
        'String','Revert Ph.', ...
        'Call',CallBackString,...
        'Style','checkbox', ...
        'Tag','checkbox2',...
        'Visible','on');
    CallBackString='vibrocalc(''Phase45'')';
    Objects.Phase_45_test = uicontrol('Parent',MainFigure, ...
        'Units','normalized', ...
        'FontUnits','normalized',...
        'FontSize',0.65,...
        'FontName','Helvetica',...
        'FontWeight','bold',...
        'BackgroundColor',ColorBackground_4, ...
        'ListboxTop',0, ...
        'Position',pos+dposE, ...
        'HorizontalAlignment','left',...
        'HandleVisibility','off',...
        'Enable','on',...
        'Max',1,...
        'Min',0,...
        'String','45', ...
        'Call',CallBackString,...
        'Style','checkbox', ...
        'Tag','checkbox3',...
        'Visible','on');
    
    Objects.Text_Phase_Rotation_Chan_A = uicontrol('Parent',MainFigure, ...
        'Units','normalized', ...
        'FontUnits','normalized',...
        'FontSize',0.8,...
        'FontName','Helvetica',...
        'FontWeight','bold',...
        'BackgroundColor',ColorBackground_4, ...
        'ListboxTop',0, ...
        'Position',pos+dposTA, ...
        'HorizontalAlignment','left',...
        'String','Chan.A:', ...
        'Style','text', ...
        'Tag','StaticText1');
    Objects.Text_Phase_Rotation_Chan_B = uicontrol('Parent',MainFigure, ...
        'Units','normalized', ...
        'FontUnits','normalized',...
        'FontSize',0.8,...
        'FontName','Helvetica',...
        'FontWeight','bold',...
        'BackgroundColor',ColorBackground_4, ...
        'ListboxTop',0, ...
        'Position',pos+dposTB+dposTBE, ...
        'HorizontalAlignment','left',...
        'String','Chan.B:', ...
        'Style','text', ...
        'Tag','StaticText1');
    st={'            Chan.B(f)','H(f) = ----------------','            Chan.A(f)'};
    Objects.Text_Formula = uicontrol('Parent',MainFigure, ...
        'Units','normalized', ...
        'FontUnits','normalized',...
        'FontSize',0.27,...
        'FontName','Helvetica',...
        'FontWeight','bold',...
        'BackgroundColor',ColorBackground_4, ...
        'ListboxTop',0, ...
        'Position',pos+dposForm, ...
        'HorizontalAlignment','center',...
        'String',st, ...
        'Style','text', ...
        'Tag','StaticText1');
    pos = [0.36 0.035 0.27 0.21];
    dpos = [0 0.211 0 -0.18];
    dpos_but1 = [0 0.001 0 -0.16];
    dposT1 = [0 0.145 -0.08 -0.18];
    dposE1 = [0.19 0.145 -0.19 -0.18];
    dposT2 = [0 0.105 -0.08 -0.18];
    dposE2 = [0.19 0.105 -0.19 -0.18];
    dposT3 = [0 0.065 -0.08 -0.18];
    dposE3 = [0.19 0.065 -0.19 -0.18];
    Objects.Text_Choose_Method = uicontrol('Parent',MainFigure, ...
        'Units','normalized', ...
        'FontUnits','normalized',...
        'FontSize',0.8,...
        'FontName','Helvetica',...
        'FontWeight','bold',...
        'BackgroundColor',ColorBackground_4, ...
        'ListboxTop',0, ...
        'Position',pos+dpos, ...
        'HorizontalAlignment','left',...
        'String','Choose a method:', ...
        'Style','text', ...
        'Tag','StaticText1');
    st={'Pwelch: tfe','Modified Pwelch: tfemod',...
        'Empirical estimate: etfe',...
        'Spectral analysis: spa',...
        'Spectral Analysis Estimates with Frequency Dependent Resolution: spafdr',...
        'State-space model estimate: n4sid',...
        'Linear model estimate: pem'};
    N=size(st,2);
    for i = 1:N
        a(i)=regexp(st(i),':');
        ischar(st{i}(a{i}+2:end));
        Objects.Elab.(st{i}(a{i}+2:end)).COUNT=0;
        Objects.Elab.(st{i}(a{i}+2:end)).NAME=st{i}(a{i}+2:end);
    end
    Objects.Elab.MAINCOUNT=0;
    Objects.Elab.SensorNAME='None';
    Objects.Elab.SensorSN='None';
    Objects.Elab.Minf=[];
    Objects.Elab.Maxf=[];
    CallBackString='vibrocalc(''PopUp_Method'')';
    Objects.PopUp_Method = uicontrol('Parent',MainFigure, ...
        'Units','normalized', ...
        'FontUnits','normalized',...
        'FontSize',0.08,...
        'FontName','Helvetica',...
        'FontWeight','bold',...
        'BackgroundColor',ColorBackground_1, ...
        'ListboxTop',0, ...
        'Position',pos, ...
        'String',st, ...
        'Call',CallBackString,...
        'Style','popupmenu', ...
        'Tag','PopupMenu1', ...
        'Enable','on',...
        'Value',1);
    CallBackString='vibrocalc(''Do_elab'')';
    Objects.Button_Do_elab = uicontrol('Parent',MainFigure, ...
        'Units','normalized', ...
        'FontUnits','normalized',...
        'FontSize',0.5,...
        'FontName','Helvetica',...
        'FontWeight','bold',...
        'BackgroundColor',ColorBackground_1, ...
        'ListboxTop',0, ...
        'Position',pos+dpos_but1, ...
        'Style','pushbutton', ...
        'String','Elaboration', ...
        'Call',CallBackString,...
        'BusyAction','cancel',...
        'Enable','on',...
        'Tag','Pushbutton1');
    
    DEF_EDIT_Opt1_STRING = 'nfft: FFT legth [256]';
    DEF_EDIT_Opt2_STRING = 'noverlap: num. overl. samp. [as 50%]';
    DEF_EDIT_Opt3_STRING = '';
    Objects.Text_Opt1 = uicontrol('Parent',MainFigure, ...
        'Units','normalized', ...
        'FontUnits','normalized',...
        'FontSize',0.5,...
        'FontName','Helvetica',...
        'FontWeight','bold',...
        'BackgroundColor',ColorBackground_4, ...
        'ListboxTop',0, ...
        'Position',pos+dposT1, ...
        'HorizontalAlignment','left',...
        'String',DEF_EDIT_Opt1_STRING, ...
        'Style','text', ...
        'Tag','StaticText1');
    Objects.Edit_Opt1 = uicontrol('Parent',MainFigure, ...
        'Units','normalized', ...
        'FontUnits','normalized',...
        'FontSize',0.6,...
        'FontName','Helvetica',...
        'FontWeight','bold',...
        'HorizontalAlignment','right',...
        'BackgroundColor',ColorEdit, ...
        'Position',pos+dposE1, ...
        'String','', ...
        'Style','edit', ...
        'Tag','StaticText1');
    Objects.Text_Opt2 = uicontrol('Parent',MainFigure, ...
        'Units','normalized', ...
        'FontUnits','normalized',...
        'FontSize',0.5,...
        'FontName','Helvetica',...
        'FontWeight','bold',...
        'BackgroundColor',ColorBackground_4, ...
        'ListboxTop',0, ...
        'Position',pos+dposT2, ...
        'HorizontalAlignment','left',...
        'String',DEF_EDIT_Opt2_STRING, ...
        'Style','text', ...
        'Tag','StaticText1');
    Objects.Edit_Opt2 = uicontrol('Parent',MainFigure, ...
        'Units','normalized', ...
        'FontUnits','normalized',...
        'FontSize',0.6,...
        'FontName','Helvetica',...
        'FontWeight','bold',...
        'HorizontalAlignment','right',...
        'BackgroundColor',ColorEdit, ...
        'Position',pos+dposE2, ...
        'String','', ...
        'Style','edit', ...
        'Tag','StaticText1');
    Objects.Text_Opt3 = uicontrol('Parent',MainFigure, ...
        'Units','normalized', ...
        'FontUnits','normalized',...
        'FontSize',0.5,...
        'FontName','Helvetica',...
        'FontWeight','bold',...
        'BackgroundColor',ColorBackground_4, ...
        'ListboxTop',0, ...
        'Position',pos+dposT3, ...
        'HorizontalAlignment','left',...
        'String',DEF_EDIT_Opt3_STRING, ...
        'Style','text', ...
        'visible','off',...
        'Tag','StaticText1');
    Objects.Edit_Opt3 = uicontrol('Parent',MainFigure, ...
        'Units','normalized', ...
        'FontUnits','normalized',...
        'FontSize',0.6,...
        'FontName','Helvetica',...
        'FontWeight','bold',...
        'HorizontalAlignment','right',...
        'BackgroundColor',ColorEdit, ...
        'Position',pos+dposE3, ...
        'String','', ...
        'Style','edit', ...
        'visible','off',...
        'Tag','StaticText1');
    pos=[0.70 0.035 0.27 0.21];
    dpos=[0 0.211 0 -0.18];
    dpos_but1=[0 0.14 -0.15 -0.18];
    dpos_but2=[0 0.10 -0.15 -0.18];
    dpos_but3=[0 0.06 -0.15 -0.18];
    dpos_butH=[0.14  0.08 -0.14 -0.125];
    dpos_butC=[0.14 -0.01 -0.14 -0.13];
    dpos_butD=[0 0.02 -0.15 -0.18];
    dpos_butE=[0 -0.02 -0.15 -0.18];
    Objects.Text_Choose_Result_To_Plot = uicontrol('Parent',MainFigure, ...
        'Units','normalized', ...
        'FontUnits','normalized',...
        'FontSize',0.8,...
        'FontName','Helvetica',...
        'FontWeight','bold',...
        'BackgroundColor',ColorBackground_4, ...
        'ListboxTop',0, ...
        'Position',pos+dpos, ...
        'HorizontalAlignment','left',...
        'String','Result list:', ...
        'Style','text', ...
        'Tag','StaticText1');
    st={'New'};
    CallBackString='vibrocalc(''Choose_Result_To_Plot'')';
    Objects.PopUp_Choose_Result_To_Plot = uicontrol('Parent',MainFigure, ...
        'Units','normalized', ...
        'FontUnits','normalized',...
        'FontSize',0.08,...
        'FontName','Helvetica',...
        'FontWeight','bold',...
        'BackgroundColor',ColorBackground_1, ...
        'ListboxTop',0, ...
        'Position',pos, ...
        'String',st, ...
        'Call',CallBackString,...
        'Style','popupmenu', ...
        'Tag','PopupMenu1', ...
        'Enable','on',...
        'Value',1);
    CallBackString='vibrocalc(''Plot_Results'')';
    Objects.Button_Plot_Results = uicontrol('Parent',MainFigure, ...
        'Units','normalized', ...
        'FontUnits','normalized',...
        'FontSize',0.6,...
        'FontName','Helvetica',...
        'FontWeight','bold',...
        'BackgroundColor',ColorBackground_1, ...
        'ListboxTop',0, ...
        'Position',pos+dpos_but1, ...
        'Style','pushbutton', ...
        'String','Plot results', ...
        'Call',CallBackString,...
        'BusyAction','cancel',...
        'Enable','on',...
        'Tag','Pushbutton1');
    Objects.Plot.COUNT=0;
    Objects.Plot.Minf=[];
    Objects.Plot.Maxf=[];
    Objects.Plot.MinM=[];
    Objects.Plot.MaxM=[];
    Objects.Plot.MinPh=[];
    Objects.Plot.MaxPh=[];
    CallBackString='vibrocalc(''Save_Results'')';
    Objects.Button_Save_Results = uicontrol('Parent',MainFigure, ...
        'Units','normalized', ...
        'FontUnits','normalized',...
        'FontSize',0.6,...
        'FontName','Helvetica',...
        'FontWeight','bold',...
        'BackgroundColor',ColorBackground_1, ...
        'ListboxTop',0, ...
        'Position',pos+dpos_but2, ...
        'Style','pushbutton', ...
        'String','Save results', ...
        'Call',CallBackString,...
        'BusyAction','cancel',...
        'Enable','on',...
        'Tag','Pushbutton1');
    CallBackString='vibrocalc(''Load_Results'')';
    Objects.Button_Load_Results = uicontrol('Parent',MainFigure, ...
        'Units','normalized', ...
        'FontUnits','normalized',...
        'FontSize',0.6,...
        'FontName','Helvetica',...
        'FontWeight','bold',...
        'BackgroundColor',ColorBackground_1, ...
        'ListboxTop',0, ...
        'Position',pos+dpos_but3, ...
        'Style','pushbutton', ...
        'String','Load results', ...
        'Call',CallBackString,...
        'BusyAction','cancel',...
        'Enable','on',...
        'Tag','Pushbutton1');
    CallBackString='vibrocalc(''Help'')';
    Objects.Button_Help = uicontrol('Parent',MainFigure, ...
        'Units','normalized', ...
        'FontUnits','normalized',...
        'FontSize',0.4,...
        'FontName','Helvetica',...
        'FontWeight','bold',...
        'BackgroundColor',ColorBackground_1, ...
        'ListboxTop',0, ...
        'Position',pos+dpos_butH, ...
        'Style','pushbutton', ...
        'String','Help', ...
        'Call',CallBackString,...
        'BusyAction','cancel',...
        'Enable','on',...
        'Tag','Pushbutton1');
    CallBackString='vibrocalc(''Close'')';
    Objects.Button_Close = uicontrol('Parent',MainFigure, ...
        'Units','normalized', ...
        'FontUnits','normalized',...
        'FontSize',0.4,...
        'FontName','Helvetica',...
        'FontWeight','bold',...
        'BackgroundColor',ColorBackground_1, ...
        'ListboxTop',0, ...
        'Position',pos+dpos_butC, ...
        'Style','pushbutton', ...
        'String','Close', ...
        'Call',CallBackString,...
        'BusyAction','cancel',...
        'Enable','on',...
        'Tag','Pushbutton1');
    CallBackString='vibrocalc(''Del_Sel'')';
    Objects.Button_Del = uicontrol('Parent',MainFigure, ...
        'Units','normalized', ...
        'FontUnits','normalized',...
        'FontSize',0.6,...
        'FontName','Helvetica',...
        'FontWeight','bold',...
        'BackgroundColor',ColorBackground_1, ...
        'ListboxTop',0, ...
        'Position',pos+dpos_butD, ...
        'Style','pushbutton', ...
        'String','Delete Sel.', ...
        'Call',CallBackString,...
        'BusyAction','cancel',...
        'Enable','on',...
        'Tag','Pushbutton1');
    CallBackString='vibrocalc(''Make_File_Report'')';
    Objects.Button_Make_Report = uicontrol('Parent',MainFigure, ...
        'Units','normalized', ...
        'FontUnits','normalized',...
        'FontSize',0.6,...
        'FontName','Helvetica',...
        'FontWeight','bold',...
        'BackgroundColor',ColorBackground_1, ...
        'ListboxTop',0, ...
        'Position',pos+dpos_butE, ...
        'Style','pushbutton', ...
        'String','Make Report', ...
        'Call',CallBackString,...
        'BusyAction','cancel',...
        'Enable','on',...
        'Tag','Pushbutton1');
    Objects.Result = [];
    set(MainFigure,'UserData',Objects);
    
elseif strcmp(action,'PopUp_Chan');
    % ogni volta che viene utilizzato il menu' di popup dei canali (sia per
    % il canale A che quello B) si entra in questa routine.
    
    % ogni volta che si fa un plot o si realizza
    % un nuovo canale, bisogna caricare il set di dati nella struttura dei
    % dati.
    
    % - Channels contiene tutte le info lette da vibrocalc.cfg
    %   per ogni canale ivi inserito
    % - Channel è costruito in base alle informazioni selezionata
    %   dal menu di popup (legato a sua volta a channels) e dai
    %   dati letti dal file dei dati identificato dalla slezione sul
    %   menu di popup. Se per caso Channel è già presente in Object.Loaded_Channels
    %   allora viene recuperato da quest'ultima lista
    % - Object.Loaded_Channels è una lista completa di tutti i dati
    %   e le informazioni inserite man mano durante l'uso
    %   dell'applicazione.
    MainFigure	=	gcf;
    Objects		=	get(MainFigure,'UserData');
    
    % in base al poup utilizzato si identifica qual'è il canale cliccato,
    % tutte le info vengono poi inglobate nella struttura dati Channel che
    % poi è quello che d'ora in poi chiamerò canale attuale.
    if strcmp(opt1,'A')
        PopUp_Chan=Objects.PopUp_ChanA;
        PopUp_Sensor=Objects.PopUp_SensorA;
        TextSummary_Sensor=Objects.TextSummary_SensorA;
        TextSummary_Sensor_Mate=Objects.TextSummary_SensorB;
    elseif strcmp(opt1,'B')
        PopUp_Chan=Objects.PopUp_ChanB;
        PopUp_Sensor=Objects.PopUp_SensorB;
        TextSummary_Sensor=Objects.TextSummary_SensorB;
        TextSummary_Sensor_Mate=Objects.TextSummary_SensorA;
    end
    
    % ora PopUp_Chan è relativo al menu' di popup cliccato (cioè
    % PopUp_ChanA o PopUp_ChanB, al suo interno è contenuta la struttura
    % dati di Channels (cioè tutte le info lette da vibrocalc.cfg)
    Channels    =   get(PopUp_Chan,'UserData');
    
    % Summary_Strings contiene tutte le info di testo che poi vengono
    % visualizzate sul pannello di testo del canale A e del canale B
    Summary_Strings =   get(TextSummary_Sensor,'String');
    
    % in base al canale scelto sul menu' di popup, si recuperano le
    % informazioni relative a quel canale
    Value = get(PopUp_Chan,'Value');
    Channel = Channels(Value);
    Value = get(PopUp_Sensor,'Value');
    Channel.Sens_Type = SensorTypeString_Default(Value);
    Channel.Sens_Type = Channel.Sens_Type{1};
    d=dir(Channel.Path);
    if isempty(d)
        % se il ring buffer non è sul disco (macchina locale o remota)
        % allora invia un messsaggio di errore su schermo e configura il
        % canale attualmente in uso (cioè Channel) con un canale di default
        % vuoto (cioè Objects.Loaded_Channels_Defaul)
        if strcmp(Channel.Ref_Name,'none')
            % poichè si entra in questa routine sia quando non esiste il ring
            % buffer sia quando si seleziona "none" sul menu di popup del
            % canale (in entrambi i casi il campo "Channel.Path" è vuoto,
            % bisogna gestire anche questa eccezione.
        else
            set(PopUp_Chan,'Value',1);
            errordlg('File not found','File Error');
            return
        end
        Channel=Objects.Loaded_Channels_Default;
    else
        % se il ring buffer è sul disco (macchina locale o remota),
        % proviamo da aprirlo e vedere se nell'header ci sono info
        % interessanti
        fid=fopen(Channel.Path,'r');
        header=fgetl(fid);
        fclose(fid);
        if header(1,1)=='#'
            %se l'header contiene info interessanti si comincia a costruire
            %la struttura del canale attuale (Channel) con i dati ivi
            %contenuti) cioè:
            % 1) tipo di acquisitore utilizzato: Channel.Logger_Type
            % 2) tipo di canale dell'acquisitore: Channel.Logger_Chan
            % 3) tipo di canale dell'acquisitore: Channel.Logger_Chan
            [Channel.Logger_Type,...
                Channel.Logger_Chan,...
                Channel.Logger_Sampling,...
                Channel.Date,...
                Channel.Time1st]=textread(Channel.Path,...
                '%*s %*s %s %*s %s %*s %f %*s %s %s',1);
            Channel.Logger_Type=Channel.Logger_Type{1};
            Channel.Logger_Chan=Channel.Logger_Chan{1};
            Channel.Date=Channel.Date{1};
            Channel.Time1st=Channel.Time1st{1};
            Channel.Logger_Sampling=(Channel.Logger_Sampling)*1e-3;
            % ora è necessario recuperare le informazioni mancanti (cioè i
            % dati acquisiti). Questo può essere fatto in 3 modi:
            % a) FromBuffer: se i dati sono già presenti nella struttura
            %    dati generale (Objects.Loaded_Channels) allora il dato si
            %    recupera dai dati già memorizzati
            % b) se il canale non compare ancora nella lista dei canali disponibili
            %    oppure il file dei dati è da aggiornare allora caricalo nella lista
            %    recuperandolo dal disco. C'è un'ulteriiore suddivisione
            %    nel caso in cui il file sul disco sia con o senza header
            %    (è il terzo modo)
            ToLoad='FromBuffer';
            if isempty(strmatch(Channel.Ref_Name,{Objects.Loaded_Channels(:).Ref_Name},'exact'))
                % se non trovi il file nella struttura dati che hai già in
                % memoria allora attiva il flag per caricarlo da file
                ToLoad = 'FromFileWithHeader';
            else
                % trova, all'interno della struttura dei dati di tutti i
                % canali caricati in memoria (Objects.Loaded_Channels), se
                % esiste già il canale selezionato dal pop_up (il metodo di
                % ricerca è basato sul nome del canale cioè Ref_Name)
                Index = strmatch(Channel.Ref_Name,{Objects.Loaded_Channels(:).Ref_Name},'exact');
                % se il file su disco è piu' aggiornato di quello in
                % memoria, attiva il flag per il recupero del canale dal
                % file.
                if (strcmp(Channel.Date,Objects.Loaded_Channels(Index).Date) && strcmp(Channel.Time1st,Objects.Loaded_Channels(Index).Time1st))
                else
                    ToLoad = 'FromFileWithHeader';
                end
            end
        else
            ToLoad = 'FromFileNoHeader';
        end
        switch ToLoad
            case 'FromBuffer'
                % recupera il canale selezionato dal menu' di popoup dalla
                % sua copia in memoria
                Index = strmatch(Channel.Ref_Name,{Objects.Loaded_Channels(:).Ref_Name},'exact');
                Channel=Objects.Loaded_Channels(Index);
                Channel.Sens_Type = SensorTypeString_Default(Value);
                Channel.Sens_Type = Channel.Sens_Type{1};
            otherwise
                % recupera il canale selezionato dal menu' di popoup dal
                % ring buffer su disco, nel caso in cui il ring buffer su
                % disco non abbia un'header aggiungere dei flag di tipo
                % unknown per ogni info mancante
                if strcmp(ToLoad,'FromFileWithHeader')
                    x=textread(Channel.Path,'%f','headerlines',1);
                elseif strcmp(ToLoad,'FromFileNoHeader')
                    Channel.Logger_Type     =   'unknown';
                    Channel.Logger_Chan     =   'unknown';
                    Channel.Logger_Sampling =   1;
                    Channel.Date            =   'unknown';
                    Channel.Time1st         =   'unknown';
                    x=textread(Channel.Path,'%f');
                end
                Channel.Num_Sample=size(x,1);
                t=Channel.Logger_Sampling*(0:1:Channel.Num_Sample-1);
                x=x(:);
                t=t(:);
                Channel.Data=[t,x];
                Channel.Sens_Type = SensorTypeString_Default(Value);
                Channel.Sens_Type = Channel.Sens_Type{1};
                Channel=orderfields(Channel,Objects.Loaded_Channels);
                % ora ai dati contenuti in channel va aggiunto il tempo assoluto
                % che si ricava dall'informazione Time1st (cioè istante del primo dato)
                Time_string=Channel.Time1st;
                if isempty(Time_string)
                    % se dal pop-up seleziono il canale "none" non serve
                    % aggiornare il suo vettore dei tempi (che è nullo)
                else
                    Time=3600*(str2num(Time_string(1:2)))+60*(str2num(Time_string(4:5)))+str2num(Time_string(7:8))+str2num(Time_string(9:end));
                    Channel.Data(:,1)=Time+Channel.Data(:,1);
                    % Channel.Data(:,2)=Channel.Logger_Sens*Channel.Data(:,2);
                end
                % attenzione se il file in memoria è una versione datata di
                % quello su disco, bisogna sostituire la vecchia copia con
                % la versione aggiornata presente sul disco, altrimenti è
                % sufficiente aggiungere un nuovo canale alla lista dei
                % canali in memoria
                Index = strmatch(Channel.Ref_Name,{Objects.Loaded_Channels(:).Ref_Name},'exact');
                if isempty(Index)
                    Objects.Loaded_Channels(size(Objects.Loaded_Channels,2)+1)=Channel;
                else
                    Objects.Loaded_Channels(Index)=Channel;
                end
        end
    end
    
    % aggiornamento del pannello di riassunto del canale selezionato dal
    % popup
    SummaryStrings=SummaryStrings_Default;
    for Index = 1:size(SummaryStrings_Default,2)
        switch SummaryStrings{Index}
            case 'Channel ref. name: '
                CurrentString=Channel.Ref_Name;
            case 'Buffer file name: '
                CurrentString=Channel.Path;
            case 'Datalogger type: '
                CurrentString=Channel.Logger_Type;
            case 'Datalogger sensitivity: '
                CurrentString=[num2str(Channel.Logger_Sens),Channel.Logger_Units];
            case 'Datalogger channel: '
                CurrentString=Channel.Logger_Chan;
            case 'Datalogger sampling time: '
                CurrentString=num2str(Channel.Logger_Sampling);
            case 'Date: '
                CurrentString=Channel.Date;
            case 'Time of 1st sample: '
                CurrentString=Channel.Time1st;
            case 'Num. of samples: '
                CurrentString=num2str(Channel.Num_Sample);
            case 'Sensor type: '
                CurrentString=Channel.Sens_Type;
            case 'Data Units: '
                CurrentString=Channel.Units;
        end
        Summary_Strings{Index}=[SummaryStrings{Index},CurrentString];
    end
    set(TextSummary_Sensor,'String',Summary_Strings);
    
    % bisogna ora aggiungere alla struttura dati generale (Objects)
    % i dati completi del canale (cioè canale + sensore) su 2 set di
    % dati nuovi che chiamo ChanA e ChanB (che fantasia eh!)
    
    % ** se Chan_A o Chan_B esitono già, controlla se sono
    % ancora selezionati (se sul Summary del canale non compare alcuna
    % info vuol dire che non è selezionato alcun canale d'ingresso e
    % quindi il Chan_A o il Chan_B vanno rimossi), se sono ancora
    % selezionati aggiornare il loro stato.
    
    % ** Se Chan_A o Chan_B non esistono creali purchè sia selezionato
    % il canale ad essi relativo (come prima: se sul Summary del
    % canale non compare alcuna info vuol dire che non è selezionato
    % alcun canale d'ingresso e quindi il Chan_A o il Chan_B non
    % vanno creati)
    
    CommandString='';
    % di seguito si realizza una struttura temporanea che contiene i due
    % canali Chan_A eChan_B. La struttura si chiama Chan_X ed è composta da
    % due campi: il primo è relativo a Chan_A/Chan_B se è stato selezionato il
    % popup relativo a quel canale, il secondo è relativo a Chan_B/Chan_A
    % relativo al canale non selezionato. In questo modo Chan_X contiene
    % la struttura completa (sensore + canale) di entrambi con in prima
    % posizione il canale selezionato e in seconda posizione quello non
    % selezionato
    if strcmp(opt1,'A')
        Chan_X={['Chan_',opt1],['Chan_','B']};
    elseif strcmp(opt1,'B')
        Chan_X={['Chan_',opt1],['Chan_','A']};
    else
        Chan_X={};
    end
    if isfield(Objects,Chan_X{2})
        % se il canale comprimario esiste già, recuperare tutte le sue
        % informazioni dalla lista di canali preesistenti ed inoltre
        % applicare le modifiche del caso (sensibilità datalogger). Il
        % recupero viene fatto in questa maniera perchè il canale
        % comprimario potrebbe essere stato modificato in passi precedenti
        % del programma e quindi non sarebbe conforme ai dati originali
        % (soprattutto a causa della troncatura sui tempi)
        Index = strmatch(Objects.(Chan_X{2}).Ref_Name,{Objects.Loaded_Channels(:).Ref_Name},'exact'); % ultima modifica
        Channel_Mate = Objects.Loaded_Channels(Index);
        Channel_Mate.Sens_Type=Objects.(Chan_X{2}).Sens_Type;
        %Time_string=Channel_Mate.Time1st;
        %Time=3600*(str2num(Time_string(1:2)))+60*(str2num(Time_string(4:5)))+str2num(Time_string(7:8))+str2num(Time_string(9:end));
        %Channel_Mate.Data(:,1) = Time + Channel_Mate.Data(:,1);
        Channel_Mate.Data(:,2) = Channel_Mate.Logger_Sens*detrend(Channel_Mate.Data(:,2),'constant');%ora Channel_Mate contiene esattamente tutte le info del canale comprimario
        %Channel_Mate.Units=sym(Channel_Mate.Logger_Units);         % aggiunto 17/08/2005
        Channel_Mate.Units=str2sym(Channel_Mate.Logger_Units);      % aggiunto 22/12/2021
        
    else
        Channel_Mate=[];
    end
    if isfield(Objects,Chan_X{1})
        % nel caso in cui il canale primario esita già è possibile che vi siano due opzioni da verificare:
        % a) il canale primario è vuoto, questa eventualità è presente nel
        % caso in cui: o non è presente il Ring Buffer su disco, oppure nel
        % caso in cui il canale selezionato sul popup è "none".(qui si attiva il flag di
        % "Add Channel")
        % b) il canale primario è già presente nella struttura dati in
        % memoria e quindi va solo aggiornato (qui si attiva il flag di
        % "Add Channel")
        if isempty(Channel.Ref_Name)
            % caso a) vedi commento precedente
            CommandString='Remove Channel'; % rimuovi Chan_A o Chan_B
        else
            % caso b) vedi commento precedente
            CommandString='Add Channel'; % aggiorna Chan_A o Chan_B
        end
    else
        if isempty(Channel.Ref_Name)
            % Il canale primario non esiste ancora e il menu di popup ad esso relativo non
            % è comunque selezionato
        else
            % Il canale primario esite già e il menu di popup ad esso
            % relativo è ora selezionato. Bisogna attivare il flag di
            % aggiornamento del canale primario
            CommandString='Add Channel'; % agginungi Chan_A o Chan_B
        end
    end
    switch CommandString
        case 'Add Channel'
            % aggiungi o aggiorna Chan_A o Chan_B:
            % in ogni caso la configurazione di Chan_X
            % è legata a quella della sua controparte
            % che deve essere riassestata ogni volta.
            if isempty(Channel_Mate)
                %Channel.Data(:,2)=Channel.Logger_Sens*Channel.Data(:,2);
                Channel.Data(:,2)=Channel.Logger_Sens*detrend(Channel.Data(:,2),'constant');
                %Channel.Units=sym(Channel.Logger_Units);       % aggiunto 17/08/2005
                Channel.Units=str2sym(Channel.Logger_Units);    % aggiunto 22/12/2021
                Objects.(Chan_X{1})=Channel;
            else
%                 % attenzione qui ci va un controllo per capire se i due
%                 % canali A e B hanno già la stessa lunghezza. Se sono già
%                 % Ok non va modificato nulla. Inoltre si aggiorna anche il
%                 % valore del popup del sensore
%                 
%                 % le seguenti righe adattano i tempi di lettura dei vari canali
%                 % leggi l'istante estatto di inizio acquisizione dall'header dei file di dati:
%                 %% time1_string=Channel.Time1st;
%                 %% time2_string=Channel_Mate.Time1st;
%                 % conversione della data in numero di secondi passati dall'inizio del giorno
%                 %%time1=3600*(str2num(time1_string(1:2)))+60*(str2num(time1_string(4:5)))+str2num(time1_string(7:8))+str2num(time1_string(9:end));
%                 %%time2=3600*(str2num(time2_string(1:2)))+60*(str2num(time2_string(4:5)))+str2num(time2_string(7:8))+str2num(time2_string(9:end));
%                 time1 = Channel.Data(1,1);
%                 time2 = Channel_Mate.Data(1,1);
%                 time1_bak=time1;
%                 time2_bak=time2;
%                 % controlla se i due segnali sono in ritardo l'uno rispettto all'altro di più di 200ms.
%                 % Se è meno di 200ms allora il ritardo è dovuto al clock del PC e in realtà i segnali sono
%                 % sincronizzati. Se è più di 200ms allora il ritardo è vero e si dovrebbe attestare su 1s
%                 if abs(time1-time2) < 0.2
%                     %l'intervallo è minore di 200ms, si ricava quanti
%                     %ipotetici campioni esistono tra un vettore dei tempi e
%                     %l'alto (ho dovuto ricavare la differenza di tempo in
%                     %questo modo per poterla arrotondare meglio in
%                     %relazione all'intervallo di campionamento
%                     Nshift=round(abs((time1-time2)/Channel.Logger_Sampling));
%                     TimeShift=Channel.Logger_Sampling*Nshift;
%                     if (time1-time2) > 0
%                         time2 = time1;
%                         Channel_Mate.Data(:,1)=Channel.Data(1,1)+Channel_Mate.Logger_Sampling*(0:1:size(Channel_Mate.Data,1)-1);
%                     elseif (time2-time1) > 0
%                         time1 = time2;
%                         Channel.Data(:,1)=Channel_Mate.Data(1,1)+Channel.Logger_Sampling*(0:1:size(Channel.Data,1)-1);
%                     end
%                 else
%                     %time2 = 3600*(str2num(time2_string(1:2)))+60*(str2num(time2_string(4:5)))+str2num(time2_string(7:8))+str2num(time1_string(9:end));
%                 end
%                 % rileva l'intervallo di tempo che intercorre tra la lettura del primo dato del primo canale e quella
%                 % del secondo canale
%                 delta=time1-time2;
%                 %% converti gli istanti di tempo relativi in istanti di tempo assoluti (si suppone che l'ora 00:00:00
%                 %% del giorno attuale sia l'origine del tempo
%                 % Channel.Data(:,1)=time1+Channel.Data(:,1);
%                 % Channel_Mate.Data(:,1)=time2+Channel_Mate.Data(:,1);
%                 % controlla quanti campioni di differenza vi sono tra primo e secondo canale
%                 Nshift=round(abs(delta/Channel.Logger_Sampling));
%                 % se la differenza di tempo tra primo e secondo canale è positiva allora considera il vettore
%                 % dei dati del secondo canale a partire da Nshift valori in avanti (salta quindi i primi Nshift dati)
%                 if delta > 0
%                     t2=Channel_Mate.Data(Nshift+1:end,1);
%                     x2=Channel_Mate.Data(Nshift+1:end,2);
%                     Channel_Mate.Data=[t2,x2];
%                     % se la differenza di tempo tra secondo e primo canale è positiva allora considera il vettore
%                     % dei dati del primo canale a partire da Nshift valori in avanti (salta quindi i primi Nshift dati)
%                 elseif delta < 0
%                     t1=Channel.Data(Nshift+1:end,1);
%                     x1=Channel.Data(Nshift+1:end,2);
%                     Channel.Data=[t1,x1];
%                 end
%                 % I due vettori di dati ora sono sincronizzati all'inizio ma non alla fine,
%                 % la seguente procedura tronca la coda del vettore più lungo allo stesso
%                 % livello del vettore più corto
%                 if size(Channel.Data(:,1),1) > size(Channel_Mate.Data(:,1),1)
%                     EndVect=size(Channel_Mate.Data(:,1),1);
%                     t1=Channel.Data(1:EndVect,1);
%                     x1=Channel.Data(1:EndVect,2);
%                     Channel.Data=[t1,x1];
%                 elseif size(Channel_Mate.Data(:,1),1) > size(Channel.Data(:,1),1)
%                     EndVect=size(Channel.Data(:,1),1);
%                     t2=Channel_Mate.Data(1:EndVect,1);
%                     x2=Channel_Mate.Data(1:EndVect,2);
%                     Channel_Mate.Data=[t2,x2];
%                 end
                
                % è necessario ora aggiungere i fattori derivativi ed eventuali
                % correzioni per il tipo di sensore
                Channel.Data(:,2)=Channel.Logger_Sens*detrend(Channel.Data(:,2),'constant');
                String_Modes = {'None','Laser','Velocimeter','Accelerometer'};
                Order_Modes = [-1 0 1 2];
                Symb_t=sym('s');         % aggiunto 17/08/2005
                %Channel.Units=sym(Channel.Logger_Units);         % aggiunto 17/08/2005
                %Channel_Mate.Units=sym(Channel_Mate.Logger_Units);         % aggiunto 17/08/2005
                Channel.Units=str2sym(Channel.Logger_Units);         % aggiunto 22/12/2021
                Channel_Mate.Units=str2sym(Channel_Mate.Logger_Units);         % aggiunto 22/12/2021
                for count = 1:1:size(String_Modes,2)
                    if strmatch(String_Modes(count),Channel.Sens_Type)
                        Channel_Order=Order_Modes(count);
                    else
                    end
                    if strmatch(String_Modes(count),Channel_Mate.Sens_Type)
                        Channel_Mate_Order=Order_Modes(count);
                    else
                    end
                end
                if Channel_Mate_Order > Channel_Order
                    if Channel_Order == -1
                    else
                        while Channel_Order < Channel_Mate_Order
                            [xd,yd]=deriv(Channel.Data(:,1),Channel.Data(:,2));
                            Channel.Data=[xd,yd];
                            Channel_Order=Channel_Order+1;
                            % Changed by D. Zuliani 01/03/2017 each
                            % derivate adds a 2ms delay (works with
                            % accelerometers, to test with velocimeters
                            Channel_Mate.Data=Channel_Mate.Data(2:end,:); %ok for acc. and Tellus vel as well.
                            %Channel_Mate.Data=Channel_Mate.Data(1:size(Channel.Data,1),:); %ok for vel.
                            Channel.Units=Channel.Units/Symb_t;         % aggiunto 17/08/2005
                        end
                        %
                        % LOWPASS FILTERING for removing high frequency noise caused by
                        % derivation added 10/01/2014
                        %                         O       =   2;                      % filter order
                        %                         Fs      =   1/(Channel.Data(2,1)-Channel.Data(1,1)); %sampling beat frequency [Hz]
                        %                         Wcs     =   2*pi*Fs;                % sampling beat freqnecy [rad/s]
                        %                         Fc_H    =   10;                    % cutoff frequency [Hz]
                        %                         Wc_H    =   2*pi*Fc_H;              % cutoff beat frequency [rad/s]
                        %                         Wcn_H   =   Wc_H/(Wcs/2);           % normalized cutoff beat frequency
                        %                         [B,A]   =   butter(O,Wcn_H,'low');  %
                        %                         Channel.Data(:,2) = filtfilt(B,A,Channel.Data(:,2));
                    end
                else
                    if Channel_Mate_Order == -1
                    else
                        while Channel_Mate_Order < Channel_Order
                            [xd,yd]=deriv(Channel_Mate.Data(:,1),Channel_Mate.Data(:,2));
                            Channel_Mate.Data=[xd,yd];
                            Channel_Mate_Order=Channel_Mate_Order+1;
                            % Changed by D. Zuliani 01/03/2017 each
                            % derivate adds a 2ms delay (works with
                            % accelerometers, to test with velocimeters
                            Channel.Data=Channel.Data(2:end,:); % ok for acc. and Tellus vel as well.
                            %Channel.Data=Channel.Data(1:size(Channel_Mate.Data,1),:); % ok for vel
                            Channel_Mate.Units=Channel_Mate.Units/Symb_t;        % aggiunto 17/08/2005
                        end
                        %                         O       =   2;                      % filter order
                        %                         Fs      =   1/(Channel_Mate.Data(2,1)-Channel_Mate.Data(1,1)); %sampling beat frequency [Hz]
                        %                         Wcs     =   2*pi*Fs;                % sampling beat freqnecy [rad/s]
                        %                         Fc_H    =   10;                    % cutoff frequency [Hz]
                        %                         Wc_H    =   2*pi*Fc_H;              % cutoff beat frequency [rad/s]
                        %                         Wcn_H   =   Wc_H/(Wcs/2);           % normalized cutoff beat frequency
                        %                         [B,A]   =   butter(O,Wcn_H,'low');  %
                        %                         Channel_Mate.Data(:,2) = filtfilt(B,A,Channel_Mate.Data(:,2));
                    end
                end
                % last allignment using finddelay 2017/07/26
                dBef=finddelay(Channel.Data(:,2),Channel_Mate.Data(:,2));
                disp(['DELAY BEFORE THE CURE: ',num2str(dBef*Channel.Logger_Sampling),'s']);
                %
                % dBef > 0 => Channel_Mate is delayed with respect to Channel
                %dBef = dBef+1;
                %dBef = 0;
                % Trimming at the beginning
                if dBef > 0
                    Channel_Mate.Data = Channel_Mate.Data(abs(dBef)+1:end,:);
                    Channel.Data = Channel.Data(1:end,:);
                elseif dBef < 0
                    Channel.Data = Channel.Data(abs(dBef)+1:end,:);
                    Channel_Mate.Data = Channel_Mate.Data(1:end,:);
                end
                % Trimming at the end
                minNumCounts=min(length(Channel.Data),length(Channel_Mate.Data));
                Channel.Data=Channel.Data(1:minNumCounts,:);
                Channel_Mate.Data=Channel_Mate.Data(1:minNumCounts,:);
                dAft=finddelay(Channel.Data(:,2),Channel_Mate.Data(:,2));
                % Adjusting time just for plots
                Channel_Mate.Data(:,1)=Channel.Data(:,1);
                disp(['DELAY AFTER THE CURE: ',num2str(dAft*Channel.Logger_Sampling),'s']);
                % aggiorna la summary e le info del canale primario Chan_A/Chan_B
                % e quella del canale secondario ChanB/Chan_A
                Objects.(Chan_X{1})=Channel;
                Objects.(Chan_X{2})=Channel_Mate;
                for count = 1:1:size(Chan_X,2)
                    if count == 1
                        Channel_Pass=Channel;
                        TextSummary_Sensor_Pass=TextSummary_Sensor;
                    else
                        Channel_Pass=Channel_Mate;
                        TextSummary_Sensor_Pass=TextSummary_Sensor_Mate;
                    end
                    SummaryStrings=SummaryStrings_Default;
                    for Index = 1:size(SummaryStrings_Default,2)
                        switch SummaryStrings{Index}
                            case 'Channel ref. name: '
                                CurrentString=Channel_Pass.Ref_Name;
                            case 'Buffer file name: '
                                CurrentString=Channel_Pass.Path;
                            case 'Datalogger type: '
                                CurrentString=Channel_Pass.Logger_Type;
                            case 'Datalogger sensitivity: '
                                CurrentString=[num2str(Channel_Pass.Logger_Sens),Channel_Pass.Logger_Units];
                            case 'Datalogger channel: '
                                CurrentString=Channel_Pass.Logger_Chan;
                            case 'Datalogger sampling time: '
                                CurrentString=num2str(Channel_Pass.Logger_Sampling);
                            case 'Date: '
                                CurrentString=Channel_Pass.Date;
                            case 'Time of 1st sample: '
                                CurrentString=time2str(sec2hr(Channel_Pass.Data(1,1)),'hms','hms',-3); % attenzione il -3 è in relazione al passo di campionamento
                            case 'Num. of samples: '
                                CurrentString=num2str(size(Channel_Pass.Data,1));
                            case 'Sensor type: '
                                CurrentString=Channel_Pass.Sens_Type;
                            case 'Data Units: '
                                CurrentString=char(Channel_Pass.Units);
                        end
                        Summary_Strings{Index}=[SummaryStrings{Index},CurrentString];
                    end
                    set(TextSummary_Sensor_Pass,'String',Summary_Strings);
                end
            end
        case 'Remove Channel'
            % rimuovi Chan_A o Chan_B
            % in ogni caso la configurazione di Chan_X
            % è legata a quella della sua controparte
            % che deve essere riassestata ogni volta.
            if isempty(Channel_Mate)
                %  se la controparte è già stata rimossa non serve fare
                %  niente
            else
                % la controparte è ancora attiva e quindi bisogna
                % riportarla alla sua configurazione originale cioè quella
                % in cui non sono presenti le modifiche (ad esempio la
                % lunghezza temporale della traccia) dovute alla presenza
                % di un altro canale
                
                Index = strmatch(Objects.(Chan_X{2}).Ref_Name,{Objects.Loaded_Channels(:).Ref_Name},'exact');
                SensorType=Channel_Mate.Sens_Type; % serve per recuperare esattamente il tipo di sensore usato.
                Channel_Mate=Objects.Loaded_Channels(Index); % recupero del canale della controparte ancora attiva.
                % Questo viene fatto pescando dalla lista dei canali
                % originali presente in Objects.Loaded_Channels
                Channel_Mate.Sens_Type=SensorType; % recupero il sensore usato, e aggiorno il suo campo nella
                % struttura dati della
                % controparte attiva.
                Channel_Mate.Units=sym(Objects.Channel_Mate.Logger_Units);
                Channel_Mate.Data(:,2)=Channel_Mate.Logger_Sens*detrend(Channel_Mate.Data(:,2),'constant'); % i dati nella controparte attiva
                % sono da considerarsi "grezzi" e quindi vanno
                % moltiplicati per la sensibilità (LSB) dell'acquisitore
                % ad essi relativo
                Objects.(Chan_X{2}) = Channel_Mate;
                SummaryStrings=SummaryStrings_Default; % aggiornamento dei dati della controparte attiva sul pannello di
                % riassunto dell'applicazione
                for Index = 1:size(SummaryStrings_Default,2)
                    switch SummaryStrings{Index}
                        case 'Channel ref. name: '
                            CurrentString=Channel_Mate.Ref_Name;
                        case 'Buffer file name: '
                            CurrentString=Channel_Mate.Path;
                        case 'Datalogger type: '
                            CurrentString=Channel_Mate.Logger_Type;
                        case 'Datalogger sensitivity: '
                            CurrentString=[num2str(Channel_Mate.Logger_Sens),Channel_Mate.Logger_Units];
                        case 'Datalogger channel: '
                            CurrentString=Channel_Mate.Logger_Chan;
                        case 'Datalogger sampling time: '
                            CurrentString=num2str(Channel_Mate.Logger_Sampling);
                        case 'Date: '
                            CurrentString=Channel_Mate.Date;
                        case 'Time of 1st sample: '
                            CurrentString=Channel_Mate.Time1st;
                        case 'Num. of samples: '
                            CurrentString=num2str(Channel_Mate.Num_Sample);
                        case 'Sensor type: '
                            CurrentString=Channel_Mate.Sens_Type;
                        case 'Data Units: '
                            CurrentString=char(Channel_Mate.Units);
                            
                    end
                    Summary_Strings{Index}=[SummaryStrings{Index},CurrentString];
                end
                set(TextSummary_Sensor_Mate,'String',Summary_Strings);
            end
            
            % infine rimuovi il canale primario
            Objects=rmfield(Objects,Chan_X(1));
    end
    set(MainFigure,'UserData',Objects);
    vibrocalc('Phase45');
    vibrocalc('RevPhase');
elseif strcmp(action,'Plot_Channels');
    MainFigure	=	gcf;
    Objects		=	get(MainFigure,'UserData');
    TypeOfPlots=get(Objects.PopUp_TypePlot,'String');
    Index=get(Objects.PopUp_TypePlot,'Value');
    TypeOfPlot=TypeOfPlots(Index);
    IndexList=get(Objects.ListBox_Channel_List,'Value');
    ListBoxStrings=get(Objects.ListBox_Channel_List,'String');
    Chan_X={['Chan_','A'],['Chan_','B']};
    H=[];
    H_mag=[];
    H_phase=[];
    Legend={};
    FULLLEGENDTEXT='';
    CURRENT_FIG=figure;
    count=1;
    C=['g','c','m','y','k']; %lista dei colori, il blu e il rosso sono esclusi perchè utilizzati esclusivamente dal Chan_A e dal Chan_B
    C=lines;
    C_AB=['b','r'];
    if length(IndexList) == 1
        axPos = 'single';
    else
        axPos ='left';
    end
    for i=1:1:size(IndexList,2) % in questo modo scorro sia la lista dei canali generali che quella contenente Chan_A e Chan_B
        count=count+1;
        if count > size(C,2)
            count=1;
        end
        CurrentListBoxString=ListBoxStrings(IndexList(i));
        IndexChannel = strmatch(CurrentListBoxString,{Objects.Loaded_Channels(:).Ref_Name},'exact');
        IndexMainChannel = strmatch(CurrentListBoxString,Chan_X,'exact');
        switch TypeOfPlot{:}
            case 'Frequency'
                if ~isempty(IndexChannel)
                    X=fft(Objects.Loaded_Channels(IndexChannel).Data(:,2));
                    X=Objects.Loaded_Channels(IndexChannel).Logger_Sens*fft2ft(X);
                    Tsamp=Objects.Loaded_Channels(IndexChannel).Logger_Sampling;
                    Objects.Loaded_Channels_F(IndexChannel).Mag=abs(X);
                    %Objects.Loaded_Channels_F(IndexChannel).Phase=(360/(2*pi))*unwrap(angle(X));
                    Objects.Loaded_Channels_F(IndexChannel).Phase=(360/(2*pi))*(angle(X));
                    Objects.Loaded_Channels_F(IndexChannel).f=(0:1:(size(X,1)-1))*(1/(2*Tsamp))/size(X(:,1),1);
                    subplot(2,1,1);
                    h_mag=loglog(Objects.Loaded_Channels_F(IndexChannel).f,Objects.Loaded_Channels_F(IndexChannel).Mag,'color',C(count,:));
                    hold on;
                    set(gca,'YScale','log');
                    set(gca,'XScale','log');
                    set(gca,'XLimSpec','Tight');
                    subplot(2,1,2);
                    h_phase=semilogx(Objects.Loaded_Channels_F(IndexChannel).f,Objects.Loaded_Channels_F(IndexChannel).Phase,'color',C(count,:));
                    hold on;
                    set(gca, 'XScale', 'log');
                    set(gca,'XLimSpec','Tight');
                    FULLLEGENDTEXT=[Objects.Loaded_Channels(IndexChannel).Ref_Name,' [',char(Objects.Loaded_Channels(IndexChannel).Logger_Units),']'];
                elseif ~isempty(IndexMainChannel)
                    if strcmp(CurrentListBoxString{:},'Chan_A') || strcmp(CurrentListBoxString{:},'Chan_B')
                        Correction=Objects.(CurrentListBoxString{:}).Correction;
                        RevertPhase=Objects.(CurrentListBoxString{:}).RevertPhase;
                    else
                        Correction=1;
                        RevertPhase=1;
                    end
                    X=fft(Correction*RevertPhase*Objects.(CurrentListBoxString{:}).Data(:,2));
                    X=fft2ft(X);
                    Tsamp=Objects.(CurrentListBoxString{:}).Logger_Sampling;
                    Objects.([CurrentListBoxString{:},'_F']).Mag=abs(X);
                    Objects.([CurrentListBoxString{:},'_F']).Phase=(360/(2*pi))*(angle(X));
                    Objects.([CurrentListBoxString{:},'_F']).f=(0:1:(size(X,1)-1))*(1/(2*Tsamp))/size(X(:,1),1);
                    subplot(2,1,1);
                    hold on;
                    h_mag=loglog(Objects.([CurrentListBoxString{:},'_F']).f,Objects.([CurrentListBoxString{:},'_F']).Mag,C_AB(IndexMainChannel));
                    set(gca,'YScale','log');
                    set(gca,'XScale','log');
                    set(gca,'XLimSpec','Tight');
                    subplot(2,1,2);
                    hold on;
                    h_phase=semilogx(Objects.([CurrentListBoxString{:},'_F']).f,Objects.([CurrentListBoxString{:},'_F']).Phase,C_AB(IndexMainChannel));
                    set(gca, 'XScale', 'log');       
                    set(gca,'XLimSpec','Tight');
                    FULLLEGENDTEXT=[CurrentListBoxString{:},' [',char(Objects.(CurrentListBoxString{:}).Units),']'];
                end
                if exist('h_mag')
                    H_mag=[H_mag,h_mag];
                    H_phase=[H_phase,h_phase];
                else
                end
                Legend={Legend{:},FULLLEGENDTEXT};
            case 'Time[HH:MM:SS]'
                if ~isempty(IndexChannel)
                    Objects.Loaded_Channels(IndexChannel).Ref_Name;
                    dateNumTimeLoaded = secday2datenum(Objects.Loaded_Channels(IndexChannel).Data(:,1));
                    switch axPos
                        case 'left'
                            axPos = 'right';
                            yyaxis left
                        case 'right'
                            axPos = 'left';
                            yyaxis right
                        case 'single'
                    end
                    h=plot(dateNumTimeLoaded,...
                        Objects.Loaded_Channels(IndexChannel).Logger_Sens*Objects.Loaded_Channels(IndexChannel).Data(:,2),'color',C(count,:));
                    FULLLEGENDTEXT=[Objects.Loaded_Channels(IndexChannel).Ref_Name,' [',char(Objects.Loaded_Channels(IndexChannel).Logger_Units),']'];
                    datetick('x',13);
                    set(gcf,'units','normalized');
                    set(gcf,'position',[0.25,0.25,0.5,0.5]);
                    hold on;
                elseif ~isempty(IndexMainChannel)
                    if strcmp(CurrentListBoxString{:},'Chan_A') || strcmp(CurrentListBoxString{:},'Chan_B')
                        Correction=Objects.(CurrentListBoxString{:}).Correction;
                        RevertPhase=Objects.(CurrentListBoxString{:}).RevertPhase;
                    else
                        Correction=1;
                        RevertPhase=1;
                    end
                    dateNumTimeCurrent = secday2datenum(Objects.(CurrentListBoxString{:}).Data(:,1));
                    switch axPos
                        case 'left'
                            axPos = 'right';
                            yyaxis left
                        case 'right'
                            axPos = 'left';
                            yyaxis right
                        case 'single'
                    end
                    h=plot(dateNumTimeCurrent,Correction*RevertPhase*Objects.(CurrentListBoxString{:}).Data(:,2),C_AB(IndexMainChannel));
                    FULLLEGENDTEXT=[CurrentListBoxString{:},' [',char(Objects.(CurrentListBoxString{:}).Units),']'];
                    grid on;
                    datetick('x',13);
                    set(gcf,'units','normalized');
                    set(gcf,'position',[0.25,0.25,0.5,0.5]);
                    hold on;
                end
                axis tight
                if length(IndexList) == 1
                else
                    axCurr=axis;
                    axis([axCurr(1),axCurr(2),-max(abs(axCurr(3:4))),max(abs(axCurr(3:4)))]);
                end
                H=[H,h];
                Legend={Legend{:},FULLLEGENDTEXT};
            case 'Time[s]'
                switch axPos
                    case 'left'
                        axPos = 'right';
                        yyaxis left
                    case 'right'
                        axPos = 'left';
                        yyaxis right
                    otherwise
                        axPos = 'left';
                end
                if ~isempty(IndexChannel)
                    Objects.Loaded_Channels(IndexChannel).Ref_Name;
                    h=plot(Objects.Loaded_Channels(IndexChannel).Data(:,1),...
                        Objects.Loaded_Channels(IndexChannel).Logger_Sens*Objects.Loaded_Channels(IndexChannel).Data(:,2),'color',C(count,:));
                    FULLLEGENDTEXT=[Objects.Loaded_Channels(IndexChannel).Ref_Name,' [',char(Objects.Loaded_Channels(IndexChannel).Logger_Units),']'];
                    set(gcf,'units','normalized');
                    set(gcf,'position',[0.25,0.25,0.5,0.5]);
                    hold on;
                elseif ~isempty(IndexMainChannel)
                    if strcmp(CurrentListBoxString{:},'Chan_A') | strcmp(CurrentListBoxString{:},'Chan_B')
                        Correction=Objects.(CurrentListBoxString{:}).Correction;
                        RevertPhase=Objects.(CurrentListBoxString{:}).RevertPhase;
                    else
                        Correction=1;
                        RevertPhase=1;
                    end
                    h=plot(Objects.(CurrentListBoxString{:}).Data(:,1),Correction*RevertPhase*Objects.(CurrentListBoxString{:}).Data(:,2),C_AB(IndexMainChannel));
                    FULLLEGENDTEXT=[CurrentListBoxString{:},' [',char(Objects.(CurrentListBoxString{:}).Units),']'];
                    grid on;
                    set(gcf,'units','normalized');
                    set(gcf,'position',[0.25,0.25,0.5,0.5]);
                    hold on;
                end
                axis tight
                if length(IndexList) == 1
                else
                    axCurr=axis;
                    axis([axCurr(1),axCurr(2),-max(abs(axCurr(3:4))),max(abs(axCurr(3:4)))]);
                end
                H=[H,h];
                Legend={Legend{:},FULLLEGENDTEXT};
        end
    end
    if ~isempty(H)
        LEGEND_VAR=legend(H,{Legend{:}});
        set(LEGEND_VAR,'Interpreter','none')
        xlabel('Time [s]');
        %ylabel('Tracks');
        grid on;
    elseif ~isempty(H_mag)
        subplot(2,1,1)
        LEGEND_VAR_MAG=legend(H_mag,{Legend{:}});
        set(LEGEND_VAR_MAG,'Interpreter','none')
        xlabel('f [Hz]');
        ylabel('Module tracks in log scale');
        title('Module');
        grid on;
        subplot(2,1,2)
        LEGEND_VAR_PHA=legend(H_phase,{Legend{:}});
        set(LEGEND_VAR_PHA,'Interpreter','none')
        xlabel('f [Hz]');
        ylabel('Phase tracks (deg)');
        title('Phase');
        grid on;
    else
        close(CURRENT_FIG);
        warndlg('Before plotting load the channel at least once','!! No Channels !!')
    end
    
    
elseif strcmp(action,'PopUp_Method');
    Mainfigure=gcf;
    Objects=get(Mainfigure,'UserData');
    Pos=get(Objects.PopUp_Method,'Value');
    Types=get(Objects.PopUp_Method,'String');
    Func = Types(Pos);
    switch Func{:}
        case'Pwelch: tfe'
            set(Objects.Text_Opt1,'String','nfft: FFT legth [256]','visible','on');
            set(Objects.Text_Opt2,'String','noverlap: num. overl. samp. [as 50%]','visible','on');
            set(Objects.Text_Opt3,'String','','visible','off');
            set(Objects.Edit_Opt1,'String','','visible','on');
            set(Objects.Edit_Opt2,'String','','visible','on');
            set(Objects.Edit_Opt3,'String','','visible','off');
        case'Modified Pwelch: tfemod'
            set(Objects.Text_Opt1,'String','TRUNKS: min. num. of trunks [20]','FontSize',0.5);
            set(Objects.Text_Opt2,'String','','FontSize',0.5,'visible','off');
            set(Objects.Text_Opt3,'String','','visible','off');
            set(Objects.Edit_Opt1,'String','','visible','on');
            set(Objects.Edit_Opt2,'String','','visible','off');
            set(Objects.Edit_Opt3,'String','','visible','off');
        case'Empirical estimate: etfe'
            set(Objects.Text_Opt1,'String','M: smoothing factor [no smoothing]','visible','on');
            set(Objects.Text_Opt2,'String','N: estimated num. of TF values [128]','FontSize',0.5,'visible','on');
            set(Objects.Text_Opt3,'String','','visible','off');
            set(Objects.Edit_Opt1,'String','','visible','on');
            set(Objects.Edit_Opt2,'String','','visible','on');
            set(Objects.Edit_Opt3,'String','','visible','off');
        case'Spectral analysis: spa'
            set(Objects.Text_Opt1,'String','M: lag win. [max 30]','FontSize',0.5,'visible','on');
            set(Objects.Text_Opt2,'String','w: out freq. [[1:128]/128*pi/Ts]','FontSize',0.5,'visible','on');
            set(Objects.Text_Opt3,'String','','visible','off');
            set(Objects.Edit_Opt1,'String','','visible','on');
            set(Objects.Edit_Opt2,'String','','visible','on');
            set(Objects.Edit_Opt3,'String','','visible','off');
        case'Spectral Analysis Estimates with Frequency Dependent Resolution: spafdr'
            set(Objects.Text_Opt1,'String','Resol: freq. res. of est. [Automatic rad/s]','visible','on');
            set(Objects.Text_Opt2,'String','','visible','off');
            set(Objects.Text_Opt3,'String','','visible','off');
            set(Objects.Edit_Opt1,'String','','visible','on');
            set(Objects.Edit_Opt2,'String','','visible','off');
            set(Objects.Edit_Opt3,'String','','visible','off');
        case'State-space model estimate: n4sid'
            set(Objects.Text_Opt1,'String','n: state-space model order [2]','visible','on');
            set(Objects.Text_Opt2,'String','','visible','off');
            set(Objects.Text_Opt3,'String','','visible','off');
            set(Objects.Edit_Opt1,'String','','visible','on');
            set(Objects.Edit_Opt2,'String','','visible','off');
            set(Objects.Edit_Opt3,'String','','visible','off');
        case'Linear model estimate: pem'
            set(Objects.Text_Opt1,'String','n: state-space model order [2]','visible','on');
            set(Objects.Text_Opt2,'String','','visible','off');
            set(Objects.Text_Opt3,'String','','visible','off');
            set(Objects.Edit_Opt1,'String','','visible','on');
            set(Objects.Edit_Opt2,'String','','visible','off');
            set(Objects.Edit_Opt3,'String','','visible','off');
    end
    
elseif strcmp(action,'Do_elab');
    Mainfigure=gcf;
    Objects=get(Mainfigure,'UserData');
    METHODS=get(Objects.PopUp_Method,'String');
    SELECTION=get(Objects.PopUp_Method,'Value');
    METHOD=METHODS(SELECTION);
    if (isfield(Objects,'Chan_A') && isfield(Objects,'Chan_B'))
    else
        warndlg('Chan_A or Chan_B not available','!! Warning !!');
        return
    end
    WAITMSGBOX=msgbox('Please wait...','Work in progress.');
    WAITMSGBOX_PUSHBUTTON=findobj(WAITMSGBOX,'Style','pushbutton');
    set(WAITMSGBOX_PUSHBUTTON,'enable','off');
    pause(1);
    switch METHOD{:}
        case'Pwelch: tfe'
            NFFT = str2num(get(Objects.Edit_Opt1,'String'));
            OVERLAP = str2num(get(Objects.Edit_Opt2,'String'));
            if isempty(NFFT);
                NFFT=[];
            else
            end
            if isempty(OVERLAP)==0;
                OVERLAP=[];
            else
            end
            Fs = 1/(Objects.Chan_A.Data(2,1)-Objects.Chan_A.Data(1,1));
            [H,f]=tfe(Objects.Chan_A.Correction*Objects.Chan_A.RevertPhase*Objects.Chan_A.Data(:,2),...
                Objects.Chan_B.Correction*Objects.Chan_B.RevertPhase*Objects.Chan_B.Data(:,2),NFFT,Fs,OVERLAP);
            %Phase=(360/(2*pi))*unwrap(angle(H));
            PARAM = {get(Objects.Text_Opt1,'String'),str2num(get(Objects.Edit_Opt1,'String'));get(Objects.Text_Opt2,'String'),str2num(get(Objects.Edit_Opt2,'String'))};
        case'Modified Pwelch: tfemod'
            TRUNKS = str2num(get(Objects.Edit_Opt1,'String'));
            if isempty(TRUNKS)
                TRUNKS = 20; % numero di finestre minimo su cui calcolare i tfe, alla più bassa frequenza devono
                % essere usate, per fare le medie, almeno
                % NUMOFTRUNKS finestre. Con 10 ve ne sono
                % troppo poche.
            end
            DIM_VECT=size(Objects.Chan_A.Data(:,2),1);
            MAXPOWER=nextpow2(DIM_VECT/TRUNKS);
            POWERS=8:1:MAXPOWER;
            POWERS=fliplr(POWERS);
            NfftS=2.^POWERS;
            percS=0.1*ones(1,size(POWERS,2));
            %freqDiv=[0.7 1 1.5 2 3 10 20 50]; %frequenza di separazione tra 2 sezioni di rapporto spettrale
            % se si fa la regressione lineare con legge y=a/x^8 con y = [50 20 10 3 2 1.5 1 0.7000 0] e
            % x=[8 9 10 11 12 13 14 15 16] (si ha: X=(1./x.^8)' ed a=X\y') si ha il
            % miglior fit possibile ed a = 8.4475e+008
            a = 8.4475e+008;
            freqDiv=a./POWERS.^8;
            if (length(freqDiv) == 1)
            else
                freqDiv=freqDiv(2:end);
            end
            f_full=[];
            H_ABS_full = [];
            Phase_full = [];
            GAP_BACKUP=[];
            GAPS=[];
            for CONT = 1:size(NfftS,2)
                Nfft=NfftS(CONT); % è la lunghezza dei singoli pezzi di trasformata
                perc=percS(CONT); % percentuale di sovrapposizione tra i singoli pezzi
                
                % ****************************** PARAMETRI MODIFICABILI DALL'OPERATORE ******************************
                sov=round(perc*Nfft);
                Fs = 1/(Objects.Chan_A.Data(2,1)-Objects.Chan_A.Data(1,1));
                [H,f]=tfe(Objects.Chan_A.Correction*Objects.Chan_A.RevertPhase*Objects.Chan_A.Data(:,2),...
                    Objects.Chan_B.Correction*Objects.Chan_B.RevertPhase*Objects.Chan_B.Data(:,2),Nfft,Fs,[],sov);
                %[H,f]=tfe(Objects.Chan_A.Data(:,2),Objects.Chan_B.Data(:,2),Nfft,Fs,[],sov);
                f_backup=f;
                
                %                 %********************** Indici per il riquadro di stampa ****************
                %                 Index_max=max(find(f<=100));
                %                 Index_min=max(find(f<=0.1));
                %                 if isempty(Index_max)
                %                     Index_max=size(f,1);
                %                 end
                %                 if isempty(Index_min)
                %                     Index_min=1;
                %                 end
                %
                %                 % ******************  Calcolo della frequenza **************************
                %                 f=f(Index_min:Index_max);
                %
                %                 %*************************** Calcolo della fase ************************
                %                Phase=(360/(2*pi))*unwrap(angle(Y(Index_min:Index_max)));
                %
                Phase=(360/(2*pi))*unwrap(angle(H));
                %*************************** Calcolo del mdoulo ************************
                %H_ABS=abs(H(Index_min:Index_max));
                H_ABS=abs(H);
                
                % calcolo dei grafici sovrapposti
                if ~rem(CONT,2)
                    if CONT == size(NfftS,2)
                        INDEX_f = find(f>freqDiv(end));
                        DELTA=round(((Phase_full(end)-Phase(INDEX_f(1))))/180);
                        GAP=180*DELTA;
                        GAPS=[GAPS,GAP];
                        if (min(f(INDEX_f)) <= 1) && (max(f(INDEX_f))>= 1)
                            GAP_BACKUP = [GAP_BACKUP,GAP];
                        else
                        end
                        f_full=[f_full',f(INDEX_f)']';
                        Phase(INDEX_f)=GAP+Phase(INDEX_f);
                        H_ABS_full = [H_ABS_full',H_ABS(INDEX_f)']';
                        Phase_full = [Phase_full',Phase(INDEX_f)']';
                    else
                        INDEX_f_min = find(f>freqDiv(CONT-1));
                        INDEX_f_max = find(f<=freqDiv(CONT));
                        INDEX_f=intersect(INDEX_f_min,INDEX_f_max);
                        DELTA=round(((Phase_full(end)-Phase(INDEX_f(1))))/180);
                        GAP=180*DELTA;
                        GAPS=[GAPS,GAP];
                        if (min(f(INDEX_f)) <= 1) && (max(f(INDEX_f))>= 1)
                            GAP_BACKUP = [GAP_BACKUP,GAP];
                        else
                        end
                        f_full=[f_full',f(INDEX_f)']';
                        H_ABS_full = [H_ABS_full',H_ABS(INDEX_f)']';
                        Phase(INDEX_f)=GAP+Phase(INDEX_f);
                        Phase_full = [Phase_full',Phase(INDEX_f)']';
                    end
                else
                    if CONT == 1
                        INDEX_f = find(f<=freqDiv(1));
                        GAP=0;
                        GAPS=[GAPS,GAP];
                        if (min(f(INDEX_f)) <= 1) && (max(f(INDEX_f))>= 1)
                            GAP_BACKUP = [GAP_BACKUP,GAP];
                        else
                        end
                        f_full=[f_full',f(INDEX_f)']';
                        Phase(INDEX_f)=GAP+Phase(INDEX_f);
                        H_ABS_full = [H_ABS_full',H_ABS(INDEX_f)']';
                        Phase_full = [Phase_full',Phase(INDEX_f)']';
                    elseif CONT == size(NfftS,2)
                        INDEX_f = find(f>freqDiv(end));
                        DELTA=round(((Phase_full(end)-Phase(INDEX_f(1))))/180);
                        GAP=180*DELTA;
                        GAPS=[GAPS,GAP];
                        if (min(f(INDEX_f)) <= 1) && (max(f(INDEX_f))>= 1)
                            GAP_BACKUP = [GAP_BACKUP,GAP];
                        else
                        end
                        f_full=[f_full',f(INDEX_f)']';
                        Phase(INDEX_f)=GAP+Phase(INDEX_f);
                        H_ABS_full = [H_ABS_full',H_ABS(INDEX_f)']';
                        Phase_full = [Phase_full',Phase(INDEX_f)']';
                    else
                        INDEX_f_min = find(f>freqDiv(CONT-1));
                        INDEX_f_max = find(f<=freqDiv(CONT));
                        INDEX_f=intersect(INDEX_f_min,INDEX_f_max);
                        DELTA=round(((Phase_full(end)-Phase(INDEX_f(1))))/180);
                        GAP=180*DELTA;
                        GAPS=[GAPS,GAP];
                        if (min(f(INDEX_f)) <= 1) && (max(f(INDEX_f))>= 1)
                            GAP_BACKUP = [GAP_BACKUP,GAP];
                        else
                        end
                        f_full=[f_full',f(INDEX_f)']';
                        Phase(INDEX_f)=GAP+Phase(INDEX_f);
                        H_ABS_full = [H_ABS_full',H_ABS(INDEX_f)']';
                        Phase_full = [Phase_full',Phase(INDEX_f)']';
                    end
                end
            end
            H=H_ABS_full.*exp((eval('j*pi'))*Phase_full/180);
            f=f_full;
            PARAM = {get(Objects.Text_Opt1,'String'),str2num(get(Objects.Edit_Opt1,'String'));get(Objects.Text_Opt2,'String'),str2num(get(Objects.Edit_Opt2,'String'))};
        case'Spectral analysis: spa'
            M = str2num(get(Objects.Edit_Opt1,'String'))
            W = str2num(get(Objects.Edit_Opt2,'String'))
            MAXSIZE = []
            if isempty(M);
                M=[];
            else
            end
            if isempty(W);
                W=[];
            else
            end
            if isempty(MAXSIZE);
                MAXSIZE=[];
            else
            end
            T_samp=(Objects.Chan_B.Data(2,1)-Objects.Chan_B.Data(1,1));
            data = iddata(Objects.Chan_B.Correction*Objects.Chan_B.RevertPhase*Objects.Chan_B.Data(:,2),...
                Objects.Chan_A.Correction*Objects.Chan_A.RevertPhase*Objects.Chan_A.Data(:,2),T_samp);
            %data = iddata(Objects.Chan_B.Data(:,2),Objects.Chan_A.Data(:,2),T_samp);
            G=spa(data,M,W,MAXSIZE);
            H=squeeze(G.ResponseData);
            f=G.Frequency/(2*pi);
            PARAM = {get(Objects.Text_Opt1,'String'),str2num(get(Objects.Edit_Opt1,'String'));get(Objects.Text_Opt2,'String'),str2num(get(Objects.Edit_Opt2,'String'));get(Objects.Text_Opt3,'String'),str2num(get(Objects.Edit_Opt3,'String'))};
        case'State-space model estimate: n4sid'
            WARN_BUTT = questdlg('Warning n4sid will take a long time. Do you want to continue?', ...
                'Exit Dialog','Yes','No','No');
            pause(1);
            switch WARN_BUTT
                case 'Yes'
                    n = str2num(get(Objects.Edit_Opt1,'String'));
                    if isempty(n)
                        n=2;
                    else
                    end
                    T_samp=(Objects.Chan_B.Data(2,1)-Objects.Chan_B.Data(1,1));
                    data = iddata(Objects.Chan_B.Correction*Objects.Chan_B.RevertPhase*Objects.Chan_B.Data(:,2),...
                        Objects.Chan_A.Correction*Objects.Chan_A.RevertPhase*Objects.Chan_A.Data(:,2),T_samp);
                    m=n4sid(data,n);
                    G=idfrd(m);
                    H=squeeze(G.ResponseData);
                    f=G.Frequency/(2*pi);
                    PARAM = {get(Objects.Text_Opt1,'String'),str2num(get(Objects.Edit_Opt1,'String'));get(Objects.Text_Opt2,'String'),str2num(get(Objects.Edit_Opt2,'String'));get(Objects.Text_Opt3,'String'),str2num(get(Objects.Edit_Opt3,'String'))};
                case 'No'
                    if exist('WAITMSGBOX')
                        close(WAITMSGBOX);
                    end
                    return;
            end % switch
        case'Empirical estimate: etfe'
            T_samp=(Objects.Chan_B.Data(2,1)-Objects.Chan_B.Data(1,1));
            data = iddata(Objects.Chan_B.Correction*Objects.Chan_B.RevertPhase*Objects.Chan_B.Data(:,2),...
                Objects.Chan_A.Correction*Objects.Chan_A.RevertPhase*Objects.Chan_A.Data(:,2),T_samp);
            %data = iddata(Objects.Chan_B.Data(:,2),Objects.Chan_A.Data(:,2),T_samp)
            M = str2num(get(Objects.Edit_Opt1,'String'));
            N = str2num(get(Objects.Edit_Opt2,'String'));
            if isempty(M)
                M=[];
            else
            end
            if isempty(N)
                N=[];
            else
            end
            P=etfe(data,M,N);
            H=squeeze(P.ResponseData);
            f=P.Frequency/(2*pi);
            PARAM = {get(Objects.Text_Opt1,'String'),str2num(get(Objects.Edit_Opt1,'String'));get(Objects.Text_Opt2,'String'),str2num(get(Objects.Edit_Opt2,'String'))};
        case'Linear model estimate: pem'
            WARN_BUTT = questdlg('Warning pem will take a long time. Do you want to continue?', ...
                'Exit Dialog','Yes','No','No');
            pause(1);
            switch WARN_BUTT
                case 'Yes'
                    n = str2num(get(Objects.Edit_Opt1,'String'));
                    if isempty(n)
                        n=2;
                    else
                    end
                    T_samp=(Objects.Chan_B.Data(2,1)-Objects.Chan_B.Data(1,1));
                    data = iddata(Objects.Chan_B.Correction*Objects.Chan_B.RevertPhase*Objects.Chan_B.Data(:,2),...
                        Objects.Chan_A.Correction*Objects.Chan_A.RevertPhase*Objects.Chan_A.Data(:,2),T_samp);
                    m=pem(data,n);
                    H=squeeze(m.ResponseData);
                    f=m.Frequency/(2*pi);
                    PARAM = {get(Objects.Text_Opt1,'String'),str2num(get(Objects.Edit_Opt1,'String'));get(Objects.Text_Opt2,'String'),str2num(get(Objects.Edit_Opt2,'String'));get(Objects.Text_Opt3,'String'),str2num(get(Objects.Edit_Opt3,'String'))};
                case 'No'
                    if exist('WAITMSGBOX')
                        close(WAITMSGBOX);
                    end
                    return;
            end % switch
        case'Spectral Analysis Estimates with Frequency Dependent Resolution: spafdr'
            SPAFDR_RESOL = str2num(get(Objects.Edit_Opt1,'String'))
            T_samp=(Objects.Chan_B.Data(2,1)-Objects.Chan_B.Data(1,1));
            data = iddata(Objects.Chan_B.Correction*Objects.Chan_B.RevertPhase*Objects.Chan_B.Data(:,2),...
                Objects.Chan_A.Correction*Objects.Chan_A.RevertPhase*Objects.Chan_A.Data(:,2),T_samp);
            if isempty(SPAFDR_RESOL)
                G=spafdr(data);
            else
                G=spafdr(data,SPAFDR_RESOL);
            end
            H=squeeze(G.ResponseData);
            f=G.Frequency/(2*pi);
            PARAM = {get(Objects.Text_Opt1,'String'),str2num(get(Objects.Edit_Opt1,'String'));get(Objects.Text_Opt2,'String'),str2num(get(Objects.Edit_Opt2,'String'));get(Objects.Text_Opt3,'String'),str2num(get(Objects.Edit_Opt3,'String'))};
    end
    close(WAITMSGBOX);
    Phase=(360/(2*pi))*unwrap(angle(H));
    prompt = {'Result reference name:','Sensor Name/Brand','Sensor Serial Number','Min. frequency [Hz]:','Max. frequency [Hz]:'};
    dlg_title = 'Reference name, limits for output data and sensor dates';
    num_lines= 1;
    METHOD_COMA_INDEX = regexp(METHOD,':');
    if iscell(METHOD_COMA_INDEX)
        METHOD_COMA_INDEX=METHOD_COMA_INDEX{1}; %For Matlab 7.5 compatibility
    else
    end
    
    %METHODNAME = METHOD{1}(regexp(METHOD,':')+2:end); %MATLAB 7.0
    METHODNAME = METHOD{1}(METHOD_COMA_INDEX+2:end); %MATLAB 7.0
    RESULTNAME = Objects.Elab.(METHODNAME).NAME;
    SensorNAME = Objects.Elab.SensorNAME;
    SensorSN = Objects.Elab.SensorSN;
    Minf = Objects.Elab.Minf;
    Maxf = Objects.Elab.Maxf;
    if Objects.Elab.MAINCOUNT == 0
        Minf=num2str(min(f));
        Maxf=num2str(max(f));
    else
    end
    def     = {RESULTNAME,...
        SensorNAME,...
        SensorSN,...
        Minf,...
        Maxf};
    answer  = inputdlg(prompt,dlg_title,num_lines,def);
    if isempty(answer)
    else
        if isempty(answer{1})
        else
            OutputIndex=find( str2num(answer{4}) < f & f < str2num(answer{5}));
            NAME={answer{1}};
            if isempty(Objects.Result)
                NUMRESULTS = 1;
            else
                NUMRESULTS=size(Objects.Result,2)+1;
            end
            NUMMAX = size(Objects.Result,2);
            TYPEOFANSWER = 0;
            for count =1:1:NUMMAX
                if strcmp(char(Objects.Result(count).Name),NAME)
                    button = questdlg('Do you want to replace?',...
                        'This file already exist!!','Yes','No','No');
                    if strcmp(button,'Yes')
                        TYPEOFANSWER = 1;
                        INDEXTOREPLACE=count;
                        NUMRESULTS=NUMRESULTS-1; %used to leave unchanged the number
                        % of results when you have
                        % a replaced entry
                    else strcmp(button,'No')
                        TYPEOFANSWER = 2;
                    end
                end
            end
            switch TYPEOFANSWER
                case 0
                    Objects.Result(NUMRESULTS).Name = NAME;
                    Objects.Result(NUMRESULTS).Method = METHOD;
                    Objects.Result(NUMRESULTS).Param = PARAM;
                    Objects.Result(NUMRESULTS).ChanA = Objects.Chan_A;
                    Objects.Result(NUMRESULTS).ChanB = Objects.Chan_B;
                    Objects.Result(NUMRESULTS).H = H(OutputIndex);
                    Objects.Result(NUMRESULTS).f = f(OutputIndex);
                    Objects.Result(NUMRESULTS).SensBrand = answer{2};
                    Objects.Result(NUMRESULTS).SensSN = answer{3};
                    DATANAMES = get(Objects.PopUp_Choose_Result_To_Plot,'String');
                    NUMOFDATA = size(get(Objects.PopUp_Choose_Result_To_Plot,'String'),2);
                    LASTVALUE = get(Objects.PopUp_Choose_Result_To_Plot,'Value');
                    if (NUMOFDATA == 1) & (strcmp(DATANAMES(NUMOFDATA),'New'))
                        set(Objects.PopUp_Choose_Result_To_Plot,'String',Objects.Result(NUMRESULTS).Name);
                    else
                        DATANAMES = {DATANAMES{:},char(Objects.Result(NUMRESULTS).Name)};
                        set(Objects.PopUp_Choose_Result_To_Plot,'String',DATANAMES);
                    end
                case 1
                    Objects.Result(INDEXTOREPLACE).Name = NAME;
                    Objects.Result(INDEXTOREPLACE).Method = METHOD;
                    Objects.Result(INDEXTOREPLACE).Param = PARAM;
                    Objects.Result(INDEXTOREPLACE).ChanA = Objects.Chan_A;
                    Objects.Result(INDEXTOREPLACE).ChanB = Objects.Chan_B;
                    Objects.Result(INDEXTOREPLACE).H = H(OutputIndex);
                    Objects.Result(INDEXTOREPLACE).f = f(OutputIndex);
                    Objects.Result(NUMRESULTS).SensBrand = answer{2};
                    Objects.Result(NUMRESULTS).SensSN = answer{3};
                case 2
            end
            if Objects.Elab.MAINCOUNT == 0
                Objects.Elab.MAINCOUNT = 1;
                Objects.Elab.SensorNAME = answer{2};
                Objects.Elab.SensorSN = answer{3};
                Objects.Elab.Minf = answer{4};
                Objects.Elab.Maxf = answer{5};
            else
                Objects.Elab.SensorNAME = answer{2};
                Objects.Elab.SensorSN = answer{3};
                Objects.Elab.Minf = answer{4};
                Objects.Elab.Maxf = answer{5};
            end
            if Objects.Elab.(METHODNAME).COUNT == 0
                Objects.Elab.(METHODNAME).COUNT = 1;
                Objects.Elab.(METHODNAME).NAME = answer{1};
            else
                Objects.Elab.(METHODNAME).NAME = answer{1};
            end
            set(Mainfigure,'UserData',Objects);
        end
    end
elseif strcmp(action,'Choose_Result_To_Plot')
    Mainfigure=gcf;
    Objects=get(Mainfigure,'UserData');
    Pos=get(Objects.PopUp_Choose_Result_To_Plot,'Value');
    Types=get(Objects.PopUp_Choose_Result_To_Plot,'String');
    Func = Types(Pos);
    
elseif strcmp(action,'Plot_Results')
    Mainfigure=gcf;
    Objects=get(Mainfigure,'UserData');
    Legend={};
    Pos=get(Objects.PopUp_Choose_Result_To_Plot,'Value');
    Types=get(Objects.PopUp_Choose_Result_To_Plot,'String');
    Func = Types(Pos);
    size(Objects.Result,1);
    NUMMAX = size(Objects.Result,2);
    for count =1:1:NUMMAX
        if strcmp(char(Objects.Result(count).Name),Func)
            Phase=(360/(2*pi))*unwrap(angle(Objects.Result(count).H));
            UNITS_CHAN_A = sym(Objects.Result(count).ChanA.Units);
            UNITS_CHAN_B = sym(Objects.Result(count).ChanB.Units);
            UNITS_H = UNITS_CHAN_B/UNITS_CHAN_A;
            MIN_MOD_STRING = ['Min. Module [',char(UNITS_H),']:'];
            MAX_MOD_STRING = ['Max. Module [',char(UNITS_H),']:'];
            if isfield (Objects.Result(count),'Save2Plot')
                if isempty(Objects.Result(count).Save2Plot)
                    Objects.Result(count).Save2Plot='N';
                end
            else
                Objects.Result(count).Save2Plot='N';
            end
            
            if isfield (Objects.Result(count),'MinFreq2Plot')
                if isempty(Objects.Result(count).MinFreq2Plot)
                    Objects.Result(count).MinFreq2Plot=min(Objects.Result(count).f);
                end
            else
                Objects.Result(count).MinFreq2Plot=min(Objects.Result(count).f);
            end
            if isfield (Objects.Result(count),'MaxFreq2Plot')
                if isempty(Objects.Result(count).MaxFreq2Plot)
                    Objects.Result(count).MaxFreq2Plot=max(Objects.Result(count).f);
                end
            else
                Objects.Result(count).MaxFreq2Plot=max(Objects.Result(count).f);
            end
            if isfield (Objects.Result(count),'MinMod2Plot')
                if isempty(Objects.Result(count).MinMod2Plot)
                    if min(abs(Objects.Result(count).H)) < 0.5
                        MIN_MOD_PLOT = min(abs(Objects.Result(count).H));
                    else
                        MIN_MOD_PLOT = 0.5;
                    end
                    Objects.Result(count).MinMod2Plot=MIN_MOD_PLOT;
                end
            else
                if min(abs(Objects.Result(count).H)) < 0.5
                    MIN_MOD_PLOT = min(abs(Objects.Result(count).H));
                else
                    MIN_MOD_PLOT = 0.5;
                end
                Objects.Result(count).MinMod2Plot=MIN_MOD_PLOT;
            end
            if isfield (Objects.Result(count),'MaxMod2Plot')
                if isempty(Objects.Result(count).MaxMod2Plot)
                    if min(abs(Objects.Result(count).H)) > 1000
                        MAX_MOD_PLOT = max(abs(Objects.Result(count).H));
                    else
                        MAX_MOD_PLOT = 1000;
                    end
                    Objects.Result(count).MaxMod2Plot=MAX_MOD_PLOT;
                end
            else
                if max(abs(Objects.Result(count).H)) > 1000
                    MAX_MOD_PLOT = max(abs(Objects.Result(count).H));
                else
                    MAX_MOD_PLOT = 1000;
                end
                Objects.Result(count).MaxMod2Plot=MAX_MOD_PLOT;
            end
            if isfield (Objects.Result(count),'MinPha2Plot')
                if isempty(Objects.Result(count).MinPha2Plot)
                    if min(Phase) < -200
                        MIN_PHA_PLOT = min(Phase);
                    else
                        MIN_PHA_PLOT = -200;
                    end
                    Objects.Result(count).MinPha2Plot=MIN_PHA_PLOT;
                end
            else
                if min(Phase) < -200
                    MIN_PHA_PLOT = min(Phase);
                else
                    MIN_PHA_PLOT = -200;
                end
                Objects.Result(count).MinPha2Plot=MIN_PHA_PLOT;
            end
            if isfield (Objects.Result(count),'MaxPha2Plot')
                if isempty(Objects.Result(count).MaxPha2Plot)
                    if max(Phase) > 200
                        MAX_PHA_PLOT = max(Phase);
                    else
                        MAX_PHA_PLOT = 200;
                    end
                    Objects.Result(count).MaxPha2Plot=MAX_PHA_PLOT;
                end
            else
                if max(Phase) > 200
                    MAX_PHA_PLOT = max(Phase);
                else
                    MAX_PHA_PLOT = 200;
                end
                Objects.Result(count).MaxPha2Plot=MAX_PHA_PLOT;
            end
            if isfield (Objects.Result(count),'ExtraPhaRot')
                if isempty(Objects.Result(count).ExtraPhaRot)
                    Objects.Result(count).ExtraPhaRot=0;
                end
            else
                Objects.Result(count).ExtraPhaRot=0;
            end 
            if isfield (Objects.Result(count),'Model')
                if isempty(Objects.Result(count).Model)
                    Objects.Result(count).Model='';
                end
            else
                Objects.Result(count).Model='';
            end   
            if isfield (Objects.Result(count),'PhaseLims')
                if isempty(Objects.Result(count).PhaseLims)
                    Objects.Result(count).PhaseLims=[];
                end
            else
                Objects.Result(count).PhaseLims=[];
            end   
            prompt = {'Save the plot?',...
                'Min. frequency [Hz]:',...
                'Max. frequency [Hz]:',...
                MIN_MOD_STRING,...
                MAX_MOD_STRING,...
                'Min. Phase [degrees]:',...
                'Max. Phase [degrees]:',...
                'Extra. Phase rot. [degrees]',...
                'Sensor mod.: LE3D1S, GSONELF_20KOHM',...
                'Freq. lims to assess extra phase delay [Hz].:'};
            dlg_title = 'Define plot limits for module, phase and frequency';
            num_lines= 1;
            def     = {Objects.Result(count).Save2Plot,...
                num2str(Objects.Result(count).MinFreq2Plot),...
                num2str(Objects.Result(count).MaxFreq2Plot),...
                num2str(Objects.Result(count).MinMod2Plot),...
                num2str(Objects.Result(count).MaxMod2Plot),...
                num2str(Objects.Result(count).MinPha2Plot),...
                num2str(Objects.Result(count).MaxPha2Plot),...
                num2str(Objects.Result(count).ExtraPhaRot),...
                Objects.Result(count).Model,...
                num2str(Objects.Result(count).PhaseLims)};
            answer  = inputdlg(prompt,dlg_title,num_lines,def);
            if isempty(answer)
            else
                Objects.Result(count).Save2Plot = answer{1};
                Objects.Result(count).MinFreq2Plot = str2num(answer{2});
                Objects.Result(count).MaxFreq2Plot = str2num(answer{3});
                Objects.Result(count).MinMod2Plot = str2num(answer{4});
                Objects.Result(count).MaxMod2Plot = str2num(answer{5});
                Objects.Result(count).MinPha2Plot = str2num(answer{6});
                Objects.Result(count).MaxPha2Plot = str2num(answer{7});
                Objects.Result(count).ExtraPhaRot = str2num(answer{8});
                Objects.Result(count).Model = answer{9};
                Objects.Result(count).PhaseLims =str2num(answer{10});
                FIGURE_RESULTS=figure;
                %                 FULL_FIGURE_RESULT_FILENAME = get(H,'Filename');
                %                 [Paths,Flags]=get_path({'PLT'},Objects.PathFileName);
                %                 if isempty(Paths)
                %                     Paths={[pwd,SLASH_TYPE]};
                %                 end
                %
                %                 FilterSpec='*.mat;MAT-files (*.mat)';
                %                 [filename, pathname, filterindex] = uiputfile( ...
                %                     [Paths{1},FilterSpec],...
                %                     'Save as');
                %                 if (filterindex == 0)
                %                 else
                %                     VarToFile=Objects.Result(count);
                %                     save([pathname,filename], 'VarToFile');
                %                     set_path({'SRES'},{pathname},Objects.PathFileName);
                %                 end
                
                %
                %           Model overlapping
% modified by D.Z 31/07/2020                
%                 LE=read_seismo('LE3D1S','','N');
%                 [model.mag,model.phadeg]=bode(LE.TF,2*pi*Objects.Result(count).f); % for plotting bode
%                 subplot(2,1,1);
%                 loglog(Objects.Result(count).f,abs(Objects.Result(count).H),'r','LineWidth',2);
%                 hold on;
%                 loglog(Objects.Result(count).f,abs(model.mag(:)),'b','LineWidth',2); % for plotting bode
%                 grid on;
%
                %mods.names = {'LE3D1S','GSONELF_20KOHM'};
                %mods.names = {'GSONELF_20KOHM'};
                %mods.names = {'LE3D1S'};
%                 mods.names = Objects.Result(count).Model;
%                 mods.colors={'b','m','c','k','g'};
%                 for cnt = 1:length(mods.names)
%                     mods.sens{cnt}=read_seismo(mods.names{cnt},'','N');
%                     [model.mag{cnt},model.phadeg{cnt}]=bode(mods.sens{cnt}.TF,2*pi*Objects.Result(count).f); % for plotting bode
%                 end
                subplot(2,1,1);
                loglog(Objects.Result(count).f,abs(Objects.Result(count).H),'r','LineWidth',2);
                hold on;
%                 for cnt = 1:length(mods.names)
%                     loglog(Objects.Result(count).f,abs(model.mag{cnt}(:)),mods.colors{cnt},'LineWidth',2); % for plotting bode
%                 end
                mod.name = Objects.Result(count).Model;
                if isempty(mod.name)
                else
                    mod.sens = read_seismo(mod.name,'','N');
                    [mod.mag,mod.phadeg]=bode(mod.sens.TF,2*pi*Objects.Result(count).f); % for plotting bode
                    loglog(Objects.Result(count).f,abs(mod.mag(:)),'b','LineWidth',2); % for plotting bode
                end
                grid on;
                xlabel('Frequency [Hz]');
                ylabel(['Module [',char(UNITS_H),']']);
                %LEGEND_VAR_RESULTS=legend(Objects.Result(count).Name);
                LEGEND_VAR_RESULTS=legend([Objects.Result(count).Name,mod.name]);
                %LEGEND_VAR_RESULTS=legend(Objects.Result(count).Name,[LE.NAME,' model']);
                set(LEGEND_VAR_RESULTS,'Interpreter','none','Location','SouthEast');
                MAIN_TITLE=title(['Sensor: ',Objects.Result(count).SensBrand,'; S/N: ',Objects.Result(count).SensSN]);
                set(MAIN_TITLE,'Interpreter','none');
                AXIS_old = axis;
                axis([str2num(answer{2}),str2num(answer{3}),str2num(answer{4}),str2num(answer{5})]);
                subplot(2,1,2);
                % Added by D. Zuliani 20013/08/08
                % for time delay evaluation between channels. Useful if a
                % constant delay is evident from the phase plot
                P = polyfit(Objects.Result(count).f(Objects.Result(count).f>=str2num(answer{2}) & Objects.Result(count).f<=str2num(answer{3})),...
                    Phase(Objects.Result(count).f>=str2num(answer{2}) & Objects.Result(count).f<=str2num(answer{3})),1);
                %str2num(answer{2})
                %str2num(answer{3})
                %semilogx(Objects.Result(count).f,360+Phase,'r','LineWidth',2);
                %semilogx(Objects.Result(count).f,str2num(answer{8})+Phase,'r','LineWidth',2);
                %hold on;
% Modified by D.Z. 2020/07/31 
%                 %semilogx(Objects.Result(count).f,(model.phadeg(:)),'b','LineWidth',2); % for plotting bode
%                 
%                 %semilogx(Objects.Result(count).f,P(1)*Objects.Result(count).f,'g','LineWidth',2);
%                 % to verify fitting delay issue. Uncomment to see the
%                 % effect on the phase plot
%                 %P1 = polyval(P,Objects.Result(count).f(Objects.Result(count).f>=str2num(answer{2}) & Objects.Result(count).f<=str2num(answer{3})));
%                 %hold on;
%                 %semilogx(Objects.Result(count).f(Objects.Result(count).f>=str2num(answer{2})& Objects.Result(count).f<=str2num(answer{3})),P1,'b');
%                 TIME_DELAY  = P(1)/(2*180);
                %phaseDelayDegMean=0;
%                for cnt = 1:length(mods.names);
                    % Trying to estimate delays within  samplig frequency
                    % (usually 500Hz -> 2ms) in a given secure range
                    %phaseSecureRange=[10,100] % ORI
%                     phaseSecureRange=[10,100] % ORI
%                     phaseDelayDeg=str2num(answer{8})+Phase-(mod.phadeg(:));
%                     idx=find((Objects.Result(count).f>phaseSecureRange(1)) & (Objects.Result(count).f<phaseSecureRange(2)));
%                     phaseDelayTime=mean((phaseDelayDeg(idx)/180*pi)./(2*pi*Objects.Result(count).f(idx)))
%                     phaseDelayDegMean=phaseDelayTime*2*pi*Objects.Result(count).f/pi*180;
                    %phaseDelayDegMean=0; 
%                 %end
%                 %for cnt = 1:length(mods.names);
%                 if isempty(mod.name)
%                     % se nessun modello di sensore è selezionato, nessuna
%                     % valutazione di eventuali extra ritardi rilevabili da
%                     % un comportamente lineare della fase è realizzato.
%                     phaseDelayDegMean=0;
%                     semilogx(Objects.Result(count).f,str2num(answer{8})+Phase-phaseDelayDegMean,'r','LineWidth',2);
%                 else
%                     if isempty(Objects.Result(count).PhaseLims)
%                         phaseDelayDegMean=0;
%                         semilogx(Objects.Result(count).f,str2num(answer{8})+Phase-phaseDelayDegMean,'r','LineWidth',2);
%                         hold on;
%                         semilogx(Objects.Result(count).f,(mod.phadeg(:)),'b','LineWidth',2); % for plotting bode
%                     else
%                         phaseSecureRange=Objects.Result(count).PhaseLims(:); % ORI
%                         phaseDelayDeg=str2num(answer{8})+Phase-(mod.phadeg(:));
% %                        idx=find((Objects.Result(count).f>phaseSecureRange(1)) & (Objects.Result(count).f<phaseSecureRange(2)));
% %                        phaseDelayTime=mean((phaseDelayDeg(idx)/180*pi)./(2*pi*Objects.Result(count).f(idx)))
%                         phaseDelayTime=Objects.Result(count).PhaseLims;
%                         phaseDelayDegMean=phaseDelayTime*2*pi*Objects.Result(count).f/pi*180;                       
%                         semilogx(Objects.Result(count).f,str2num(answer{8})+Phase-phaseDelayDegMean,'r','LineWidth',2);
%                         hold on;
%                         semilogx(Objects.Result(count).f,(mod.phadeg(:)),'b','LineWidth',2); % for plotting bode
%                     end
%                 end
                phaseSecureRange=Objects.Result(count).PhaseLims;
                if isempty(phaseSecureRange)
                    %se non sono inseriti i limiti della banda di frequenze
                    %su cui stimare un eventuale extra ritardo di fase
                    %lineare (corrispondente a un ritardo temporale
                    %costante) la stima di tale valore è nullo.
                    if isempty(mod.name)
                        % se il sensore non è selezionato non è stampata la
                        % risposta in frequenza del modello
                        semilogx(Objects.Result(count).f,str2num(answer{8})+Phase,'r','LineWidth',2);
                    else
                        % se il sensore è selezionato è stampata la
                        % risposta in frequenza del modello
                        semilogx(Objects.Result(count).f,str2num(answer{8})+Phase,'r','LineWidth',2);
                        hold on;
                        semilogx(Objects.Result(count).f,(mod.phadeg(:)),'b','LineWidth',2); % for plotting bode. This is the model phase
                    end
                else
                    % in alternativa bisogna verificare se è presente o
                    % meno un modello del sensore
                    if isempty(mod.name)
                        % se il sensore non è selezionato; la stima dell'
                        % eventuale delay lineare di fase non tine conto
                        % del modello di fase del sensore
                        phaseDelayDeg=str2num(answer{8})+Phase; % current phase including extra rotations the model is not taken into account
                        idx=find((Objects.Result(count).f>=phaseSecureRange(1)) & (Objects.Result(count).f<=phaseSecureRange(2))); %take only the phase bewteen the limits choosen
                        P = polyfit(Objects.Result(count).f(idx),phaseDelayDeg(idx),1); % polynomial coefficients y=P(1)*f+P(2)
                        phaseLinDel = polyval(P,Objects.Result(count).f)-P(2); % linear Phase delay assesement in degrees all over the frequencies
                        timeLinDel=phaseLinDel/360./Objects.Result(count).f;
                        %phaseDelayTime=mean((phaseDelayDeg(idx)/180*pi)./(2*pi*Objects.Result(count).f(idx))); %if the phase delay is linear, time delay is a constant
                        %phaseDelayDegMean=phaseDelayTime*2*pi*Objects.Result(count).f/pi*180; % this an assessement of the linear phase delay
                        %
                        % lets go for the plots
                        %semilogx(Objects.Result(count).f,str2num(answer{8})+Phase-phaseDelayDegMean,'r','LineWidth',2); 
                        semilogx(Objects.Result(count).f,str2num(answer{8})+phaseDelayDeg-phaseLinDel,'r','LineWidth',2); 
                    else
                        % se il sensore è selezionato. La stima dell'
                        % eventuale delay lineare di fase deve essere fatto
                        % a meno del modello di fase del sensore
                        phaseDelayDeg=str2num(answer{8})+Phase-(mod.phadeg(:)); % current phase including extra rotations and without model phase
                        idx=find((Objects.Result(count).f>phaseSecureRange(1)) & (Objects.Result(count).f<phaseSecureRange(2))); %take only the phase bewteen the limits choosen
                        %phaseDelayTime=mean((phaseDelayDeg(idx)/180*pi)./(2*pi*Objects.Result(count).f(idx))); %if the phase delay is linear, time delay is a constant
                        %phaseDelayDegMean=phaseDelayTime*2*pi*Objects.Result(count).f/pi*180; % this an assessement of the linear phase delay
                        %
                        % lets go for the plots
                        P = polyfit(Objects.Result(count).f(idx),phaseDelayDeg(idx),1); % polynomial coefficients y=P(1)*f+P(2)
                        phaseLinDel = polyval(P,Objects.Result(count).f)-P(2);
                        semilogx(Objects.Result(count).f,str2num(answer{8})+Phase-phaseLinDel,'r','LineWidth',2); 
                        hold on;
                        semilogx(Objects.Result(count).f,(mod.phadeg(:)),'b','LineWidth',2); % for plotting bode. This is the model phase
                    end
                end
               % semilogx(Objects.Result(count).f,str2num(answer{8})+Phase-phaseDelayDegMean,'r','LineWidth',2);
                    %end
                set(gca, 'XScale', 'log')     
                grid on;
                xlabel('Frequency [Hz]');
                ylabel('Phase [degrees]');
                LEGEND_VAR_RESULTS=legend([Objects.Result(count).Name,mod.name]);
                %LEGEND_VAR_RESULTS=legend(Objects.Result(count).Name,[LE.NAME,' model']);
                set(LEGEND_VAR_RESULTS,'Interpreter','none','Location','NorthEast');
                AXIS_old = axis;
                axis([str2num(answer{2}),str2num(answer{3}),str2num(answer{6}),str2num(answer{7})]);
                % for saving the figure
                if strmatch(upper(Objects.Result(count).Save2Plot),'Y')
                    [Paths,Flags]=get_path({'PLT'},Objects.PathFileName);
                    if isempty(Paths)
                        Paths={[pwd,SLASH_TYPE]};
                    end
                    FilterSpec='*.fig;Figure MAT-files (*.fig)';
                    [filename, pathname, filterindex] = uiputfile( ...
                        [Paths{1},FilterSpec],...
                        'Save as');
                    if (filterindex == 0)
                    else
                        set(FIGURE_RESULTS,'Filename',[pathname,'/',filename]);
                        saveas(FIGURE_RESULTS, [pathname,'/',filename], 'fig');
                        set_path({'PLT'},{pathname},Objects.PathFileName);
                    end
                else
                end
                Objects.Result(count).Save2Plot='N';
                % doing a last check fo a single frequency sin function input
                % out=repChanSin(Objects.Result(count));
            end
        end
    end
    set(Mainfigure,'UserData',Objects);
    
elseif  strcmp(action,'Del_Sel');
    Mainfigure=gcf;
    Objects=get(Mainfigure,'UserData');
    Pos=get(Objects.PopUp_Choose_Result_To_Plot,'Value');
    Types=get(Objects.PopUp_Choose_Result_To_Plot,'String');
    Func = Types(Pos);
    NUMMAX = size(Objects.Result,2)
    count2=0;
    Result=[];
    for count =1:1:NUMMAX
        if strcmp(char(Objects.Result(count).Name),Func)
        else
            count2=count2+1;
            if isempty(Result)
                clear Result;
            end
            Result(count2)=Objects.Result(count);
        end
    end
    if (size(Objects.Result,2) == 1 || size(Objects.Result,2) == 0 || isempty(Result))
        Objects.Result=[];
        set(Objects.PopUp_Choose_Result_To_Plot,'String',{'New'});
    else
        Objects.Result=Result;
        set(Objects.PopUp_Choose_Result_To_Plot,'Val',1);
        set(Objects.PopUp_Choose_Result_To_Plot,'String',[Objects.Result(:).Name]);
    end
    set(Mainfigure,'UserData',Objects);
elseif strcmp (action,'Save_Results');
    Mainfigure=gcf;
    Objects=get(Mainfigure,'UserData');
    Pos=get(Objects.PopUp_Choose_Result_To_Plot,'Value');
    Types=get(Objects.PopUp_Choose_Result_To_Plot,'String');
    Func = Types(Pos);
    size(Objects.Result,1)
    NUMMAX = size(Objects.Result,2);
    for count =1:1:NUMMAX
        if strcmp(char(Objects.Result(count).Name),Func)
            [Paths,Flags]=get_path({'SRES'},Objects.PathFileName);
            if isempty(Paths)
                Paths={[pwd,SLASH_TYPE]};
            end
            FilterSpec='*.mat;MAT-files (*.mat)';
            [filename, pathname, filterindex] = uiputfile( ...
                [Paths{1},FilterSpec],...
                'Save as');
            if (filterindex == 0)
            else
                VarToFile=Objects.Result(count);
                save([pathname,filename], 'VarToFile');
                set_path({'SRES'},{pathname},Objects.PathFileName);
            end
        end
    end
elseif strcmp(action,'Load_Results');
    Mainfigure=gcf;
    Objects=get(Mainfigure,'UserData');
    [Paths,Flags]=get_path({'LRES'},Objects.PathFileName);
    if isempty(Paths)
        Paths={[pwd,SLASH_TYPE]};
    end
    FilterSpec='*.mat;MAT-files (*.mat)';
    [filename, pathname, filterindex] = uigetfile(...
        [Paths{1},FilterSpec],...
        'Pick a file');
    if (filterindex == 0)
    else
        if ischar(filename) & ischar(pathname)
            set_path({'LRES'},{pathname},Objects.PathFileName);
        end
        Mainfigure=gcf;
        Objects=get(Mainfigure,'UserData');
        Pos=get(Objects.PopUp_Choose_Result_To_Plot,'Value');
        Types=get(Objects.PopUp_Choose_Result_To_Plot,'String');
        Func = Types(Pos);
        NUMMAX = size(Objects.Result,2);
        %VarFromFile=Objects.Result(count);
        prompt = {'Enter result reference name:'};
        dlg_title = 'Enter a name for saving last result';
        num_lines= 1;
        def     = {''};
        answer  = inputdlg(prompt,dlg_title,num_lines,def);
        if isempty(answer)
        else
            NAME=answer;
            if isempty(Objects.Result)
                NUMRESULTS = 1;
            else
                NUMRESULTS=size(Objects.Result,2)+1;
            end
            NUMMAX = size(Objects.Result,2);
            TYPEOFANSWER = 0;
            for count =1:1:NUMMAX
                if strcmp(char(Objects.Result(count).Name),NAME)
                    button = questdlg('Do you want to replace?',...
                        'This file already exist!!','Yes','No','No');
                    if strcmp(button,'Yes')
                        TYPEOFANSWER = 1;
                        INDEXTOREPLACE=count;
                    else strcmp(button,'No')
                        TYPEOFANSWER = 2;
                    end
                end
            end
            switch TYPEOFANSWER
                case 0
                    load([pathname,filename]);
                    if exist('VarToFile')
                    else
                        errordlg('Not a vibrocalc file','File Error');
                        return
                    end
                    if NUMRESULTS==1
                        Objects.Result=VarToFile;
                        Objects.Result.Name=NAME;
                    else
                        VarToFile.Name=NAME;
                        try
                            Objects.Result(NUMRESULTS)=VarToFile;
                        catch ME
                            errordlg('Not a vibrocalc file','File Error');
                            return
                        end
                        %Objects.Result(NUMRESULTS).Name=NAME;
                    end
                    DATANAMES = get(Objects.PopUp_Choose_Result_To_Plot,'String');
                    NUMOFDATA = size(get(Objects.PopUp_Choose_Result_To_Plot,'String'),2);
                    LASTVALUE = get(Objects.PopUp_Choose_Result_To_Plot,'Value');
                    if (NUMOFDATA == 1) & (strcmp(DATANAMES(NUMOFDATA),'New'))
                        set(Objects.PopUp_Choose_Result_To_Plot,'String',Objects.Result(NUMRESULTS).Name);
                    else
                        DATANAMES = {DATANAMES{:},char(Objects.Result(NUMRESULTS).Name)};
                        set(Objects.PopUp_Choose_Result_To_Plot,'String',DATANAMES);
                    end
                case 1
                    load([pathname,filename]);
                    Objects.Result(INDEXTOREPLACE)=VarToFile;
                    Objects.Result(INDEXTOREPLACE).Name = NAME;
                case 2
            end
            set(Mainfigure,'UserData',Objects);
        end
    end
    
elseif strcmp(action,'Help');
    Mainfigure=gcf;
    Objects=get(Mainfigure,'UserData');
    %     button = questdlg('Do you want to see VIBROCALC help?',...
    %         'VIBROCALC Help','Yes','No','Yes');
    %     if strcmp(button,'Yes')
    %         open help.htm;
    %     else strcmp(button,'No')
    %     end
    open help.htm;
    
elseif strcmp(action,'Close');
    Mainfigure=gcf;
    Objects=get(Mainfigure,'UserData');
    button = questdlg('Do you want to close?',...
        'Close program','Yes','No','No');
    if strcmp(button,'Yes')
        close (gcf);
    else strcmp(button,'No')
    end
    
elseif strcmp(action,'Make_File_Report');
    Mainfigure=gcf;
    Objects=get(Mainfigure,'UserData');
    Pos=get(Objects.PopUp_Choose_Result_To_Plot,'Value');
    Types=get(Objects.PopUp_Choose_Result_To_Plot,'String');
    Func = Types(Pos);
    size(Objects.Result,1)
    NUMMAX = size(Objects.Result,2);
    for count =1:1:NUMMAX
        if strcmp(char(Objects.Result(count).Name),Func)
            Method=char(Objects.Result(count).Method);
            Param=Objects.Result(count).Param;
            Chan_A=Objects.Result(count).ChanA;
            Chan_B=Objects.Result(count).ChanB;
            F=Objects.Result(count).f;
            Module=abs(Objects.Result(count).H);
            if isfield (Objects.Result(count),'ExtraPhaRot')
                Phase=Objects.Result(count).ExtraPhaRot+...
                    (360/(2*pi))*unwrap(angle(Objects.Result(count).H));
            else
                Phase=(360/(2*pi))*unwrap(angle(Objects.Result(count).H));
            end
            String1='Include channels (default = N -> no data channels included within the report)';
            String2=['Frequency Interpolation limits (default = None -> min freq.=',num2str(min(F)),'Hz; max freq.=',num2str(max(F)),'Hz)'];
            String3='Frequency interpolation steps (default = None -> use original steps';
            prompt = {String1,String2,String3};
            dlg_title = 'Report options';
            num_lines= 1;
            def     = {'N','None','None'};
            answer  = inputdlg(prompt,dlg_title,num_lines,def);
            if isempty(answer)
            else
                if (strcmpi(answer{2},'None') & strcmpi(answer{3},'None'))
                    DataResultToFile=[F,Module,Phase]';
                else
                    %******************************** Interpolazione standard dei dati a 0.1Hz *********************
                    IntStep=0.01;
                    f_interp=0:IntStep:round(F(end));
                    Y_ABS_interp=interp1(F,Module,f_interp);
                    Phase_interp=interp1(F,Phase,f_interp);
                    f_interp=f_interp';
                    Y_ABS_interp=Y_ABS_interp';
                    Phase_interp=Phase_interp';
                    DataResultToFile=[f_interp,Y_ABS_interp,Phase_interp]';
                    %******************************** Interpolazione dei dati *********************
                    % frequenze di separazione tra i vari ranges
                    % ogni valore indica l'interpolazione sul dato: e.g. fino 1 1Hz steps da 0.1Hz, da 1Hz fino a 10Hz steps di 1Hz etc
                    ranges=str2num(answer{3});
                    fsteps=str2num(answer{2});
                    Index_ranges = ranges/IntStep;
                    PrevStop=1;
                    index=[];
                    for i = 1: size (fsteps,2)
                        StartIndex = PrevStop;
                        StopIndex=max(find(f_interp<=fsteps(i)));
                        if StartIndex == 1
                            index = StopIndex
                        else
                            index =  [index,StartIndex:Index_ranges(i-1):StopIndex];
                        end
                        if i < size (fsteps,2)
                            PrevStop = max(find(f_interp<=(fsteps(i)+ranges(i))));
                        end
                    end
                    DataResultToFile=[f_interp(index),Y_ABS_interp(index),Phase_interp(index)]';
                end
                
                DataChanToFile=[Chan_A.Data(:,1),...
                    Chan_A.Correction*Chan_A.RevertPhase*Chan_A.Data(:,2),...
                    Chan_B.Correction*Chan_B.RevertPhase*Chan_B.Data(:,2)]';
                DATE=clock;
                DATE1=[num2str(DATE(1)),'/',num2str(DATE(2)),'/',num2str(DATE(3))];
                TIME=[num2str(DATE(4)),':',num2str(DATE(5)),':',num2str(DATE(6))];
                [Paths,Flags]=get_path({'REP'},Objects.PathFileName);
                if isempty(Paths)
                    Paths={[pwd,SLASH_TYPE]};
                end
                FilterSpec='*.mat;*.txt';'All kind Files (*.mat, *.txt)';
                [filename, pathname, filterindex] = uiputfile( ...
                    [Paths{1},FilterSpec],...
                    'Save as');
                %                 [filename, pathname, filterindex] = uiputfile( ...
                %                     {'*.mat;*.txt', 'All kind Files (*.mat, *.txt)';
                %                     '*.mat','MAT-files (*.mat)'; ...
                %                         '*.txt','TXT-files (*.txt)'; ...
                %                         '*.*',  'All Files (*.*)'}, ...
                %                     'Save as');
                if (filterindex == 0)
                else
                    fid = fopen([pathname,SLASH_TYPE,filename],'w');
                    fprintf(fid,'%14s\r\n\r\n',['File report generated by VIBROCALC ',Objects.ScriptVer]);
                    fprintf(fid,'%5s %-12s\r\n','DATE:',DATE1);
                    fprintf(fid,'%5s %-12s\r\n\r\n','TIME:',TIME);
                    fprintf(fid,'%14s\r\n','This report  is the result  of spectral calculations');
                    fprintf(fid,'%14s\r\n','between Channel A and Channel B as a following form:');
                    fprintf(fid,'%14s\r\n\r\n','H(f)=Channel B(f)/Channel A(f)');
                    fprintf(fid,'%-22s\r\n','SENSOR:');
                    fprintf(fid,' %-15s %-14s\r\n','NAME:',Objects.Result(count).SensBrand);
                    fprintf(fid,' %-15s %-14s\r\n\r\n','SERIAL NUMBER:',Objects.Result(count).SensSN);
                    fprintf(fid,'%14s\r\n','SPECTRAL REPORT:');
                    fprintf(fid,' %-14s\r\n',Method);
                    for i =1:1:size(Param,1)
                        fprintf(fid,' %-9s %10.9g\r\n',Param{i,1},Param{i,2});
                    end
                    fprintf(fid,'\r\n');
                    fprintf(fid,'%19s\r\n','Frequency Response:');
                    fprintf(fid,'%7s %13s %11s\r\n','f','|H(f)||','ang(H(f))');
                    fprintf(fid,'%7s %13s %11s\r\n','[Hz]','[V/(m/s)]','[°]');
                    fprintf(fid,'%7.3f %13.9f %11.3f\r\n',DataResultToFile);
                    
                    if strcmpi(answer{1},'Y')
                        fprintf(fid,'\r\n');
                        fprintf(fid,'%11s\r\n','Input Data:');
                        fprintf(fid,'%9s %18s %18s\r\n','TIME','CHANNEL A:','CHANNEL B:');
                        fprintf(fid,'%9s %18s %18s\r\n','[s]',...
                            ['[',char(Chan_A.Units),']'],...
                            ['[',char(Chan_B.Units),']']);
                        fprintf(fid,'%9.3f %18.7E %18.7E\r\n',DataChanToFile);
                    else
                    end
                    fclose(fid);
                    set_path({'REP'},{pathname},Objects.PathFileName);
                end
            end
        end
    end
elseif strcmp(action,'Phase45');
    Mainfigure=gcf;
    Objects=get(Mainfigure,'UserData');
    SensorTypeString_Default=get(Objects.PopUp_SensorA,'String');
    IS45 = get(Objects.Phase_45_test,'Value');
    if IS45
        if isfield(Objects,'Chan_A')
            switch Objects.Chan_A.Sens_Type
                case SensorTypeString_Default(1)
                case SensorTypeString_Default(2)
                    Objects.Chan_A.Correction=1;
                case SensorTypeString_Default(3)
                    Objects.Chan_A.Correction=2^(0.5);
                case SensorTypeString_Default(4)
                    Objects.Chan_A.Correction=2^(0.5);
                otherwise
            end
        end
        if isfield(Objects,'Chan_B')
            switch Objects.Chan_B.Sens_Type
                case SensorTypeString_Default(1)
                case SensorTypeString_Default(2)
                    Objects.Chan_B.Correction=1;
                case SensorTypeString_Default(3)
                    Objects.Chan_B.Correction=2^(0.5);
                case SensorTypeString_Default(4)
                    Objects.Chan_B.Correction=2^(0.5);
                otherwise
            end
        end
    else
        if isfield(Objects,'Chan_A')
            Objects.Chan_A.Correction=1;
        end
        if isfield(Objects,'Chan_B')
            Objects.Chan_B.Correction=1;
        end
    end
    if isfield(Objects,'Chan_A')
        Objects.Chan_A;
    end
    if isfield(Objects,'Chan_B')
        Objects.Chan_B;
    end
    set(Mainfigure,'UserData',Objects);
elseif strcmp(action,'RevPhase');
    Mainfigure=gcf;
    Objects=get(Mainfigure,'UserData');
    if isfield(Objects,'Chan_A')
        Objects.Chan_A;
    end
    if isfield(Objects,'Chan_A')
        RevertPhaseA=get(Objects.Phase_Rotation_checkA,'Value');
        if RevertPhaseA
            Objects.Chan_A.RevertPhase=-1;
        else
            Objects.Chan_A.RevertPhase=1;
        end
    end
    if isfield(Objects,'Chan_B')
        RevertPhaseB=get(Objects.Phase_Rotation_checkB,'Value');
        if RevertPhaseB
            Objects.Chan_B.RevertPhase=-1;
        else
            Objects.Chan_B.RevertPhase=1;
        end
    end
    if isfield(Objects,'Chan_A')
        Objects.Chan_A;
    end
    if isfield(Objects,'Chan_B')
        Objects.Chan_B;
    end
    set(Mainfigure,'UserData',Objects);
end

%%%%%% FUNCTIONS %%%%%%%%%
function seconds = hr2sec(hrs)

%HR2SEC Converts time from hours to seconds
%
%  sec = HR2SEC(hr) converts time from hours to seconds.
%
%  See also SEC2HR, HR2HMS, TIMEDIM, TIME2STR

%  Copyright 1996-2003 The MathWorks, Inc.
%  Written by:  E. Brown, E. Byrns
%  $Revision: 1.9.4.1 $    $Date: 2003/08/01 18:16:38 $

if nargin==0
    error('Incorrect number of arguments')
elseif ~isreal(hrs)
    warning('Imaginary parts of complex TIME argument ignored')
    hrs = real(hrs);
end
seconds=hrs*3600;

function hrs = sec2hr(seconds)

%SEC2HR Converts time from seconds to hours
%
%  hr = SEC2HR(sec) converts time from seconds to hours.
%
%  See also HR2SEC, SEC2HMS, TIMEDIM, TIME2STR

%  Copyright 1996-2003 The MathWorks, Inc.
%  Written by:  E. Brown, E. Byrns
%  $Revision: 1.9.4.1 $    $Date: 2003/08/01 18:20:10 $

if nargin==0
    error('Incorrect number of arguments')
elseif ~isreal(seconds)
    warning('Imaginary parts of complex TIME argument ignored')
    seconds = real(seconds);
end

hrs=seconds/3600;

function strout = time2str(timein,clock,format,units,digits)

%TIME2STR  Time conversion to a string
%
%  str = TIME2STR(t) converts a numerical vector of times to
%  a string matrix.  The output string matrix is useful for the
%  display of times.
%
%  str = TIME2STR(t,'clock') uses the specified clock input to
%  construct the string matrix.  Allowable clock strings are
%  '12' for a regular 12 hour clock (AM and PM);  '24' for a
%  regular 24 hour clock; and 'nav' for a navigational hour clock.
%  If omitted or blank, '24' is assumed.
%
%  str = TIME2STR(t,'clock','format') uses the specified format input
%  to construct the string matrix.  Allowable format strings are
%  'hm' for hours and minutes; and 'hms' for hours, minutes
%  and seconds.  If omitted or blank, 'hm' is assumed.
%
%  str = TIME2STR(t,'clock','format','units') defines the units which
%  the input times are supplied.  Any valid time units string can be
%  entered.  If omitted or blank, 'hours' is assumed.
%
%  str = TIME2STR(t,'clock','format',digits) uses the input digits to
%  determine the number of decimal digits in the output matrix.
%  n = -2 uses accuracy in the hundredths position, n = 0 uses
%  accuracy in the units position.  Default is n = 0.  For further
%  discussion of the input n, see ROUNDN.
%
%  str = TIME2STR(t,'clock','format','units',digits) uses all the inputs
%  to construct the output string matrix.
%
%  See also TIMEDIM

%  Copyright 1996-2003 The MathWorks, Inc.
%  Written by:  E. Byrns, E. Brown
%   $Revision: 1.10.4.1 $    $Date: 2003/08/01 18:20:28 $


if nargin == 0
    error('Incorrect number of arguments')
    
elseif nargin == 1
    clock = [];    format = [];     units  = [];     digits = [];
    
elseif nargin == 2
    format = [];     units  = [];     digits = [];
    
elseif nargin == 3
    units  = [];     digits = [];
    
elseif nargin == 4
    if isstr(units)
        digits = [];
    else
        digits = units;   units  = [];
    end
end

%  Empty argument tests

if isempty(digits);  digits  = 0;   end

if isempty(format);           format = 'hms';
elseif ~isstr(format);    error('FORMAT input must be a string')
else;                     format = lower(format);
end
if isempty(clock);            clock = '24';
elseif isstr(clock);      clock = lower(clock);
else;                     clock = num2str(clock);
end

if isempty(units);        units  = 'hours';
else;                 [units,msg]  = unitstr(units,'time');
    if ~isempty(msg);   error(msg);   end
end

%  Test the format string

if ~strcmp(format,'hm') & ~strcmp(format,'hms')
    error('Unrecognized format string')
end

%  Prevent complex times

if ~isreal(timein)
    warning('Imaginary parts of complex TIME argument ignored')
    timein = real(timein);
end

%  Ensure that inputs are a column vector

timein = timein(:);

%  Compute the time (h,m,s) in 24 hour increments.
%  Eliminate 24 hour days from the time string.

timein = timedim(timein,units,'hours');
timein = timedim(rem(timein,24),'hours',format);
[h,m,s] = hms2mat(timein,digits);

%  Work with positive (h,m,s).  Prefix character takes care of
%  signs separately

h = abs(h);   m = abs(m);    s = abs(s);

%  Compute the prefix and suffix matrices.
%  Note that the * character forces a space in the output

prefix = ' ';     prefix = prefix(ones(size(timein)),:);
indx = find(timein<0);  if ~isempty(indx);   prefix(indx) = '-';   end

switch clock
    case '12'
        suffix = '* M';      suffix = suffix(ones(size(timein)),:);
        indx = find(h<12);   if ~isempty(indx); suffix(indx,2) = 'A';   end
        indx = find(h>=12);  if ~isempty(indx); suffix(indx,2) = 'P'; end
        indx = find(h>12);   if ~isempty(indx); h(indx) = h(indx) - 12; end
        
    otherwise
        suffix = ' ';     suffix = suffix(ones(size(timein)),:);
end

%  Compute the time string

if strcmp(clock(1),'n')  %  Navigational clock
    fillstr = ' ';     fillstr = fillstr( ones(size(timein)) );
    
    h_str = num2str(h,'%02g');     %  Convert hours to a string
    
    %  Determine the round to increments 15 seconds
    
    indx1 = find(s<7.5);
    indx2 = find(s >= 7.55 & s < 22.5);
    indx3 = find(s >= 22.5 & s < 37.5);
    indx4 = find(s >= 37.5 & s < 52.5);
    indx5 = find(s >= 52.5);
    
    s_str = zeros([length(h) 3]);   %  Blank seconds string
    
    if ~isempty(indx1);  s_str(indx1,1:3) = '***';     end
    if ~isempty(indx2);  s_str(indx2,1:3) = '''**';    end
    if ~isempty(indx3);  s_str(indx3,1:3) = '''''*';   end
    if ~isempty(indx4);  s_str(indx4,1:3) = '''''''';  end
    if ~isempty(indx5);  s_str(indx5,1:3) = '***';  m(indx5) = m(indx5)+1;  end
    
    %  Convert minutes now because an increment of m may have occurred
    
    m_str = num2str(m,'%02g');     %  Convert minutes to a string
    
else        %  12 or 24 hour regular clock
    fillstr = ':';     fillstr = fillstr( ones(size(timein)) );
    
    %  Construct the format string for converting seconds
    
    rightdigits  = abs(min(digits,0));
    if rightdigits > 0;   totaldigits = 3+ rightdigits;
    else              totaldigits = 2+ rightdigits;
    end
    formatstr = ['%0',num2str(totaldigits),'.',num2str(rightdigits),'f'];
    
    %  Hours, minutes and seconds
    
    h_str = num2str(h,'%02g');       %  Convert hours to a string
    m_str = num2str(m,'%02g');       %  Convert minutes to a string
    s_str = num2str(s,formatstr);    %  Convert seconds to a padded string
end

%  Construct the display string

if strcmp(format,'hms')
    strout = [prefix  h_str fillstr  m_str fillstr  s_str suffix];
else
    strout = [prefix  h_str fillstr  m_str suffix];
end

%  Right justify each row of the output matrix.  This places
%  all extra spaces in the leading position.  Then strip these
%  lead zeros.  Left justifying and then a DEBLANK call will
%  not ensure that all strings line up.  LEADBLNK only strips
%  leading blanks which appear in all rows of a string matrix,
%  thereby not messing up any right justification of the string matrix.

%strout = shiftspc(strout);
%strout = leadblnk(strout,' ');
strout = strjust(strout); % mod. by D.Z. 24/09/2024
strout = strtrim(strout); % mod. by D.Z. 24/09/2024

%  Replace the hold characters with a space

indx = find(strout == '*');
if ~isempty(indx);  strout(indx) = ' ';  end

function timemat = timedim(timemat,from,to)

%TIMEDIM  Converts times from one unit system to another
%
%  t = TIMEDIM(tin,'from','to') converts times between
%  recognized units.  Input and output units are entered as strings.
%  This function allows access to all time conversions based upon input
%  unit strings.  Allowable units strings are:  'hm' for hms:min;
%  'hms' for hms:min:sec; 'hours' or 'hr' for hours;
%  'seconds' or 'sec' for seconds.
%
%  See also HMS2HR, HMS2SEC, HMS2HM, HR2SEC, HR2HMS, HR2HM,
%          SEC2HMS,  SEC2HR, SEC2HM

%  Copyright 1996-2003 The MathWorks, Inc.
%  Written by:  E. Brown, E. Byrns
%  $Revision: 1.10.4.1 $    $Date: 2003/08/01 18:20:29 $

if nargin ~= 3;    error('Incorrect number of arguments');    end


[from,msg] = unitstr(from,'time');    %  Test the input strings for recognized units
if ~isempty(msg);   error(msg);  end

[to,msg] = unitstr(to,'time');        %  Return the full name in lower case
if ~isempty(msg);   error(msg);  end

%  Complex input test

if ~isreal(timemat)
    warning('Imaginary parts of complex TIME argument ignored')
    timemat = real(timemat);
end

%  If no unit changes, then simply return

if strcmp(from,to);	  return;    end

%  Find the appropriate string matches and transform the angles

switch from          %  Switch statment faster that if/elseif
    case 'hours'
        switch to
            case 'hm',        timemat = hr2hm(timemat);
            case 'hms',       timemat = hr2hms(timemat);
            case 'seconds',   timemat = hr2sec(timemat);
            otherwise,        error('Unrecognized time units string')
        end
        
    case 'hm'
        switch to
            case 'hours',     timemat = hms2hr(timemat);
            case 'hms',       timemat = timemat;
            case 'seconds',   timemat = hms2sec(timemat);
            otherwise,        error('Unrecognized time units string')
        end
        
    case 'hms'
        switch to
            case 'hours',     timemat = hms2hr(timemat);
            case 'hm',        timemat = hms2hm(timemat);
            case 'seconds',   timemat = hms2sec(timemat);
            otherwise,        error('Unrecognized time units string')
        end
        
    case 'seconds'
        switch to
            case 'hours',     timemat = sec2hr(timemat);
            case 'hm',        timemat = sec2hm(timemat);
            case 'hms',       timemat = sec2hms(timemat);
            otherwise,        error('Unrecognized time units string')
        end
        
    otherwise
        error('Unrecognized time units string')
end

function [str,msg] = unitstr(str0,measstr)

%UNITSTR  Tests for valid unit string or abbreviations
%
%  UNITSTR displays a list of recognized unit string in
%  the Mapping Toolbox.
%
%  str = UNITSTR('str0','measstr') tests for valid unit strings or
%  abbreviations.  If a string or abbreviation is found, then the output
%  string is set to the corresponding preset string.
%
%  The second input to determine the measurement system to be used.
%  Allowable strings are 'angles' for angle unit checks;  'distances'
%  for distance unit checks; and 'time' for time unit checks.
%
%  [str,msg] = UNITSTR(...) returns the string describing any error
%  condition encountered.
%
%  See also ANGLEDIM, DISTDIM, TIMEDIM

%  Copyright 1996-2003 The MathWorks, Inc.
%  Written by:  E. Byrns, E. Brown
%  $Revision: 1.12.4.1 $  $Date: 2003/08/01 18:20:35 $

%  Input argument tests

if nargin == 0;
    unitstra;  unitstrd;  unitstrt;  return
elseif nargin ~= 2
    error('Incorrect number of arguments')
end

%  Initialize outputs

str = [];   msg = [];

%  Test for a valid measurement string only if it is not already
%  an exact match.  This approach is faster that simply always
%  using strmatch.

measstr = lower(measstr);
if ~strcmp(measstr,'angles') & ~strcmp(measstr,'distances') & ...
        ~strcmp(measstr,'times')
    validparm = ['angles   ';  'distances'; 'times    '];
    indx = strmatch(lower(measstr),validparm);
    if length(indx) == 1;    measstr = deblank(validparm(indx,:));
    else;                error('Unrecognized MEASUREMENT string')
    end
end

%  Test for a valid units string in the appropriate measurement units

switch measstr
    case 'angles',      [str,msg] = unitstra(str0);
    case 'distances',   [str,msg] = unitstrd(str0);
    case 'times',       [str,msg] = unitstrt(str0);
end

if ~isempty(msg)
    if nargout ~= 2;   error(msg);   end
end


%************************************************************************
%************************************************************************
%************************************************************************


function [str,msg] = unitstra(str0)

%UNITSTRA  Tests for valid angle unit string or abbreviations
%
%  Purpose
%
%  UNITSTRA tests for valid angle unit strings or abbreviations.
%  If a valid string or abbreviation is found, then the
%  unit string is set to a preset string.  This allows
%  users to enter strings in a variety of formats, but then
%  this function determines the standard format for each
%  string.  This allows other functions to work with the
%  standard format unit strings.
%
%  Synopsis
%
%       unitstra              %  Displays a list of recongized strings
%       str = unitstra(str0)  %  Produces a standard format unit string
%       [str,errmsg] = unitstra(str0)
%            If two output arguments are supplied, then error condition
%            messages are returned to the calling function for processing.
%
%       See also UNITSTRD, UNITSTRT, ANGLEDIM


%  Define unit string names only if necessary.  This process
%  takes some time and should be done only if it is truly necessary.
%  This martix definition process is significantly faster than strvcat,
%  where the padding must be computed

%  Initialize outputs

str = [];   msg = [];

%  Display list or set input strings to lower case for comparison

if nargin == 0
    units = ['degrees'; 'dm     '; 'dms    '; 'radians'];
    abbreviations = ['deg   for degrees'
        'rad   for radians'];
    disp(' ');    disp('Recognized Angle Unit Strings')
    disp(' ');    disp(units)
    disp(' ');    disp('Recognized Angle Unit Abbreviations')
    disp(' ');    disp(abbreviations)
    return
elseif ~isstr(str0)
    msg = 'Input argument must be a string';
    if nargout < 2;  error(msg);  end
    return
else
    str0 = lower(str0);
end

%  Test for an appropriate string word.
%  Test for exact matches because this is a faster procedure that
%  the strmatch function.

switch str0
    case 'degrees',      str = str0;        return
    case 'deg',          str = 'degrees';   return
    case 'radians',      str = str0;        return
    case 'rad',          str = 'radians';   return
    case 'dm',           str = str0;        return
    case 'dms',          str = str0;        return
    otherwise,
        units = ['degrees'; 'dm     '; 'dms    '; 'radians'];
        strindx = strmatch(str0,units);
end

%  Set the output string or error message

if length(strindx) == 1
    str = deblank(units(strindx,:));   %  Set the name string
else
    msg = ['Unrecognized angle units string:  ',str0];
    if nargout < 2;  error(msg);  end
    return
end


%************************************************************************
%************************************************************************
%************************************************************************


function [str,msg] = unitstrd(str0)

%UNITSTRD  Tests for valid distance unit string or abbreviations
%
%  Purpose
%
%  UNITSTRD tests for valid distance unit strings or abbreviations.
%  If a valid string or abbreviation is found, then the
%  unit string is set to a preset string.  This allows
%  users to enter strings in a variety of formats, but then
%  this function determines the standard format for each
%  string.  This allows other functions to work with the
%  standard format unit strings.
%
%  Synopsis
%
%       unitstrd              %  Displays a list of recongized strings
%       str = unitstrd(str0)  %  Produces a standard format unit string
%       [str,errmsg] = unitstrd(str0)
%            If two output arguments are supplied, then error condition
%            messages are returned to the calling function for processing.
%
%       See also UNITSTRA, UNITSTRT, DISTDIM


%  Define unit string names only if necessary.  This process
%  takes some time and should be done only if it is truly necessary.
%  This martix definition process is significantly faster than strvcat,
%  where the padding must be computed

%  Initialize outputs

str = [];   msg = [];

%  Display list or set input strings to lower case for comparison

if nargin == 0
    units = ['degrees      '; 'feet         ';
        'kilometers   '; 'kilometres   ';
        'meters       '; 'metres       '; 'nauticalmiles';
        'radians      '; 'statutemiles '];
    
    abbreviations = ['deg          for degrees       '
        'ft           for feet          '
        'km           for kilometers    '
        'm            for meters        '
        'mi or miles  for statute miles '
        'nm           for nautical miles'
        'rad          for radians       '
        'sm           for statute miles ' ];
    disp(' ');    disp('Recognized Distance Unit Strings')
    disp(' ');    disp(units)
    disp(' ');    disp('Recognized Distance Abbreviations')
    disp(' ');    disp(abbreviations)
    return
elseif ~isstr(str0)
    msg = 'Input argument must be a string';
    if nargout < 2;  error(msg);  end
    return
else
    str0 = lower(str0);
end

%  Test for a valid abbreviation or appropriate string word.
%  Test for exact matches because this is a faster procedure that
%  the strmatch function.

switch str0
    case 'deg',                str = 'degrees';        return
    case 'km',                 str = 'kilometers';     return
    case 'm',                  str = 'meters';         return
    case 'mi',                 str = 'statutemiles';   return
    case 'miles',              str = 'statutemiles';   return
    case 'nm',                 str = 'nauticalmiles';  return
    case 'sm',                 str = 'statutemiles';   return
    case 'ft',                 str = 'feet';           return
    case 'degrees',            str = str0;             return
    case 'kilometers',         str = str0;             return
    case 'kilometres',         str = 'kilometers';     return
    case 'meters',             str = str0;             return
    case 'metres',             str = 'meters';         return
    case 'feet',               str = str0;             return
    case 'foot',               str = 'feet';           return
    case 'nauticalmiles',      str = str0;             return
    case 'radians',            str = str0;             return
    case 'statutemiles',       str = str0;             return
    otherwise,
        units = ['degrees      '; 'feet         ';
            'kilometers   '; 'meters       '; 'nauticalmiles'
            'radians      '; 'statutemiles '];
        strindx = strmatch(str0,units);
end

%  Set the output string or error message

if length(strindx) == 1
    str = deblank(units(strindx,:));   %  Set the name string
    
else
    msg = ['Unrecognized distance units string:  ',str0];
    if nargout < 2;  error(msg);  end
    return
end


%************************************************************************
%************************************************************************
%************************************************************************


function [str,msg] = unitstrt(str0)

%UNITSTRT  Tests for valid time unit string or abbreviations
%
%  Purpose
%
%  UNITSTRT tests for valid time unit strings or abbreviations.
%  If a valid string or abbreviation is found, then the
%  unit string is set to a preset string.  This allows
%  users to enter strings in a variety of formats, but then
%  this function determines the standard format for each
%  string.  This allows other functions to work with the
%  standard format unit strings.
%
%  Synopsis
%
%       unitstrt              %  Displays a list of recongized strings
%       str = unitsttr(str0)  %  Produces a standard format unit string
%       [str,errmsg] = unitstrt(str0)
%            If two output arguments are supplied, then error condition
%            messages are returned to the calling function for processing.
%
%       See also UNITSTRA, UNITSTRD, TIMEDIM


%  Define unit string names only if necessary.  This process
%  takes some time and should be done only if it is truly necessary.
%  This martix definition process is significantly faster than strvcat,
%  where the padding must be computed

%  Initialize outputs

str = [];   msg = [];

%  Display list or set input strings to lower case for comparison

if nargin == 0
    units = ['hm     '; 'hms    '; 'hours  '; 'seconds'];
    abbreviations = ['hr     for hours  '; 'sec    for seconds'];
    disp(' ');    disp('Recognized Time Unit Strings')
    disp(' ');    disp(units)
    disp(' ');    disp('Recognized Time Abbreviations')
    disp(' ');    disp(abbreviations)
    return
elseif ~isstr(str0)
    msg = 'Input argument must be a string';
    if nargout < 2;  error(msg);  end
    return
else
    str0 = lower(str0);
end

%  Test for a valid abbreviation or appropriate string word.
%  Test for exact matches because this is a faster procedure that
%  the strmatch function.

switch str0
    case 'hr',                  str = 'hours';        return
    case 'sec',                 str = 'seconds';      return
    case 'hm',                  str = str0;           return
    case 'hms',                 str = str0;           return
    case 'hours',               str = str0;           return
    case 'seconds',             str = str0;           return
    otherwise,
        units = ['hm     '; 'hms    '; 'hours  '; 'seconds'];
        strindx = strmatch(str0,units);
end

%  Set the output string or error message

if length(strindx) == 1
    str = deblank(units(strindx,:));   %  Set the name string
    
else
    msg = ['Unrecognized time units string:  ',str0];
    if nargout < 2;  error(msg);  end
    return
end

function hms=hr2hms(hrs)

%HR2HMS Converts time from hours to hrs:min:sec vector format
%
%  hms = HR2HMS(hr) converts time from hours to hrs:min:sec
%  vector format.
%
%  See also HMS2HR,  HR2SEC, MAT2HMS, HMS2MAT, TIMEDIM, TIME2STR

%  Copyright 1996-2003 The MathWorks, Inc.
%  Written by:  E. Byrns, E. Brown
%  $Revision: 1.9.4.1 $    $Date: 2003/08/01 18:16:37 $

if nargin==0
    error('Incorrect number of arguments')
elseif ~isreal(hrs)
    warning('Imaginary parts of complex TIME argument ignored')
    hrs = real(hrs);
end

%  Test for empty inputs

if isempty(hrs);     hms = [];   return;   end

%  Construct a sign vector which has +1 when hrs >= 0 and -1 when hrs < 0.

signvec = sign(hrs);
signvec = signvec + (signvec == 0);    %  Enforce +1 when hrs == 0

%  Compute the hours, minutes and seconds

hrs = abs(hrs);           %  Work in absolute value.  Signvec will set sign later
h   = fix(hrs);           %  Hours
ms  = 60*(hrs - h);       %  Minutes and seconds
m   = fix(ms);            %  Minutes
s   = 60*(ms - m);        %  Seconds

%  Determine where to store the sign of the time.  It should be
%  associated with the largest nonzero component of h:m:s.

hsign = signvec .* (h~=0);                %  Associate with hours
msign = signvec .* (h==0 & m~=0);         %  Assoicate with minutes (h = 0)
ssign = signvec .* (h==0 & m==0 & s~=0);  %  Associate with seconds (h = m = 0)

%  In the application of signs below, the ~ operator is used so that
%  the sign vector contains only +1 and -1.  Any zero occurances causes
%  data to be lost when the sign has been applied to a higher component
%  of h:m:s.

h = (~hsign + hsign).*h;      %  Apply signs to the hours
m = (~msign + msign).*m;      %  Apply signs to minutes
s = (~ssign + ssign).*s;      %  Apply signs to seconds


hms = mat2hms(h,m,s);     %  Construct the hms vector for output

function hmsvec = mat2hms(h,m,s,n)

%MAT2HMS Converts a [hrs min sec] matrix to vector format
%
%  hms = MAT2HMS(h,m,s) converts a hrs:min:sec matrix into a vector
%  format.  The vector format is hms = 100*hrs + min + sec/100.
%  This allows h,m,s triple to be compressed into a single value,
%  which can then be employed similar to a second or hour vector.
%  The inputs h, m and s must be of equal size.  Minutes and
%  second must be between 0 and 60.
%
%  hms = MAT2HMS(mat) assumes and input matrix of [h m s].  This is
%  useful only for single column vector for h, m and s.
%
%  hms = MAT2HMS(h,m) and hms = MAT2HMS([h m]) assume that seconds
%  are zero, s = 0.
%
%  hms = MAT2HMS(h,m,s,n) uses n as the accuracy of the seconds
%  calculation.  n = -2 uses accuracy in the hundredths position,
%  n = 0 uses accuracy in the units position.  Default is n = -5.
%  For further discussion of the input n, see ROUNDN.
%
%  See also HMS2MAT

%  Copyright 1996-2003 The MathWorks, Inc.
%  Written by:  E. Byrns, E. Brown
%  $Revision: 1.10.4.1 $    $Date: 2003/08/01 18:17:09 $

if nargin == 0
    error('Incorrect number of arguments')
    
elseif nargin==1
    if size(h,2)== 3
        s = h(:,3);   m = h(:,2);   h = h(:,1);
    elseif size(h,2)== 2
        m = h(:,2);   h = h(:,1);   s = zeros(size(h));
    elseif size(h,2) == 0
        h = [];   m = [];   s = [];
    else
        error('Single input matrices must be n-by-2 or n-by-3.');
    end
    n = -5;
    
elseif nargin == 2
    s = zeros(size(h));
    n = -5;
    
elseif nargin == 3
    n = -5;
end

%  Test for empty arguments

if isempty(h) & isempty(m) & isempty(s);  hmsvec = [];  return;  end

%  Don't let seconds be rounded beyond the tens place.
%  If you did, then 55 seconds rounds to 100, which is not good.

if n == 2;  n = 1;   end

%  Complex argument tests

if any([~isreal(h) ~isreal(m) ~isreal(s)])
    warning('Imaginary parts of complex TIME argument ignored')
    h = real(h);   m = real(m);   s = real(s);
end

%  Dimension and value tests

if  ~isequal(size(h),size(m),size(s))
    error('Inconsistent dimensions for input arguments')
elseif any(rem(h(~isnan(h)),1) ~= 0 || rem(m(~isnan(m)),1) ~= 0)
    error('Hours and minutes must be integers')
end

if any(abs(m) > 60) || any (abs(m) < 0)       %  Actually algorithm allows for
    error('Minutes must be >= 0 and < 60')   %  up to exactly 60 seconds or
    %  60 minutes, but the error message
elseif any(abs(s) > 60) || any(abs(s) < 0)    %  doesn't reflect this so that angst
    error('Seconds must be >= 0 and < 60')   %  is minimized in the user docs
end

%  Ensure that only one negative sign is present

if any((s<0 & m<0) || (s<0 & h<0) || (m<0 & h<0) )
    error('Multiple negative entries in a hms specification')
elseif any((s<0 & (m~=0 || h~= 0)) || (m<0 & h~=0))
    error('Incorrect negative HMS specification')
end

%  Construct a sign vector which has +1 when
%  time >= 0 and -1 when time < 0.  Note that the sign of the
%  time is associated with the largest nonzero component of h:m:s

negvec = (h<0) || (m<0) || (s<0);
signvec = ~negvec - negvec;

%  Convert to all positive numbers.  Allows for easier
%  adjusting at 60 seconds and 60 minutes

h = abs(h);     m = abs(m);    s = abs(s);

%  Truncate seconds to a specified accuracy to eliminate round-off errors

[s,msg] = roundn(s,n);
if ~isempty(msg);   error(msg);   end

%  Adjust for 60 seconds or 60 minutes. If s > 60, this can only be
%  from round-off during roundn since s > 60 is already tested above.
%  This round-off effect has happened though.

indx = find(s >= 60);
if ~isempty(indx);   m(indx) = m(indx) + 1;   s(indx) = 0;   end

%  The user can not put minutes > 60 as input.  However, the line
%  above may create minutes > 60 (since the user can put in m == 60),
%  thus, the test below includes the greater than condition.

indx = find(m >= 60);
if ~isempty(indx);   h(indx) = h(indx) + 1;   m(indx) = m(indx)-60;   end

%  Construct the hms vector format

hmsvec = signvec .* (100*h + m + s/100);

function [hout,mout,sout] = hms2mat(hms,n)

%HMS2MAT Converts a hms vector format to a [hrs min sec] matrix
%
%  [h,m,s] = HMS2MAT(hms) converts a hms vector format to a
%  hrs:min:sec matrix.  The vector format is hms = 100*hrs + min + sec/100.
%  This allows compressed hms data to be expanded to a h,m,s triple,
%  for easier reporting and viewing of the data.
%
%  [h,m,s] = HMS2MAT(hms,n) uses n digits in the accuracy of the
%  seconds calculation.  n = -2 uses accuracy in the hundredths position,
%  n = 0 uses accuracy in the units position.  Default is n = -5.
%  For further discussion of the input n, see ROUNDN.
%
%  mat = HMS2MAT(...) returns a single output argument of mat = [h m s].
%  This is useful only if the input hms is a single column vector.
%
%       See also MAT2HMS

%  Copyright 1996-2003 The MathWorks, Inc.
%  Written by:  E. Byrns, E. Brown
%  $Revision: 1.9.4.1 $    $Date: 2003/08/01 18:16:34 $

if nargin == 0
    error('Incorrect number of arguments')
elseif nargin == 1
    n = -5;
end

%  Test for empty arguments

if isempty(hms); hout = []; mout = []; sout = []; return; end

%  Test for complex arguments

if ~isreal(hms)
    warning('Imaginary parts of complex TIME argument ignored')
    hms = real(hms);
end

%  Don't let seconds be rounded beyond the tens place.
%  If you did, then 55 seconds rounds to 100, which is not good.

if n == 2;  n = 1;   end

%  Construct a sign vector which has +1 when hms >= 0 and -1 when hms < 0.

signvec = sign(hms);
signvec = signvec + (signvec == 0);   %  Ensure +1 when hms = 0

%  Decompress the hms data vector

hms = abs(hms);
h = fix(hms/100);                      %  Hours
m = fix(hms) - abs(100*h);             %  Minutes
[s,msg] = roundn(100*rem(hms,1),n);    %  Seconds:  Truncate to roundoff error
if ~isempty(msg);   error(msg);   end

%  Adjust for 60 seconds or 60 minutes.
%  Test for seconds > 60 to allow for round-off from roundn,
%  Test for minutes > 60 as a ripple effect from seconds > 60


indx = find(s >= 60);
if ~isempty(indx);   m(indx) = m(indx) + 1;   s(indx) = s(indx) - 60;   end
indx = find(m >= 60);
if ~isempty(indx);   h(indx) = h(indx) + 1;   m(indx) =  m(indx) - 60;   end

%  Data consistency checks

if any(m > 59) || any (m < 0)
    error('Minutes must be >= 0 and <= 59')
    
elseif any(s >= 60) || any( s < 0)
    error('Seconds must be >= 0 and < 60')
end

%  Determine where to store the sign of the time.  It should be
%  associated with the largest nonzero component of h:m:s.

hsign = signvec .* (h~=0);
msign = signvec .* (h==0 & m~=0);
ssign = signvec .* (h==0 & m==0 & s~=0);

%  In the application of signs below, the ~ operator is used so that
%  the sign vector contains only +1 and -1.  Any zero occurances causes
%  data to be lost when the sign has been applied to a higher component
%  of h:m:s.  Use fix function to eliminate potential round-off errors.

h = (~hsign + hsign).*fix(h);      %  Apply signs to the hours
m = (~msign + msign).*fix(m);      %  Apply signs to minutes
s = (~ssign + ssign).*s;           %  Apply signs to seconds


%  Set the output arguments

if nargout <= 1
    hout = [h m s];
elseif nargout == 3
    hout = h;   mout = m;   sout = s;
else
    error('Invalid number of output arguments')
end

function [x,msg] = roundn(x,n)
%ROUNDN  Round numbers to specified power of 10
%
%  y = ROUNDN(x) rounds the input data x to the nearest hundredth.
%
%  y = ROUNDN(x,n) rounds the input data x at the specified power
%  of tens position.  For example, n = -2 rounds the input data to
%  the 10E-2 (hundredths) position.
%
%  [y,msg] = ROUNDN(...) returns the text of any error condition
%  encountered in the output variable msg.
%
%  See also ROUND

% Copyright 1996-2006 The MathWorks, Inc.
% Written by:  E. Byrns, E. Brown
% $Revision: 1.9.4.2 $    $Date: 2006/05/24 03:36:29 $

msg = [];   %  Initialize output

if nargin == 0
    error('Incorrect number of arguments')
elseif nargin == 1
    n = -2;
end

%  Test for scalar n

if max(size(n)) ~= 1
    msg = 'Scalar accuracy required';
    if nargout < 2;  error(msg);  end
    return
elseif ~isreal(n)
    warning('Imaginary part of complex N argument ignored')
    n = real(n);
end

%  Compute the exponential factors for rounding at specified
%  power of 10.  Ensure that n is an integer.

factors  = 10 ^ (fix(-n));

%  Set the significant digits for the input data

x = round(x * factors) / factors;


function [xd,yd] = deriv(x,y)
x=x(:);
y=y(:);
h=x(2,1)-x(1,1);
yd=diff(y)/h;
xd=x(1)+(0:1:size(yd,1)-1)*h;
xd=xd(:);
yd=yd(:);

function [msg] = set_path(Flags_new,Paths_new,varargin)
% Setting SLASH for computer dependent PATHS
if ispc
    SLASH_TYPE = '\';
else
    SLASH_TYPE = '/';
end
if ~isempty(varargin)
    PathFileName=varargin{1};
else
    PathFileName='vibtab.path';
end
if isempty(Flags_new)
    % SRES: Save Results path
    % LRES: Load Results path
    % PLT: Plot path
    % REP: Report path
    Flags_new = {'SRES','LRES','PLT','REP'};
end
Size_new=size(Flags_new,2);
if isempty(Paths_new)
    Paths_new=cell(1,Size_new);
    %[PATH,NAME,EXT,VERSN] = fileparts(PathFileName);
    [PATH,NAME,EXT] = fileparts(PathFileName);
    [Paths_new{:}]=deal([PATH,SLASH_TYPE]);
end
Dir=dir(PathFileName);
if isempty(Dir)
    Flags=Flags_new;
    Paths=Paths_new;
else
    [Flags,Paths]=textread(PathFileName,'%s %s','delimiter','||');
    Flags=Flags';
    Paths=Paths';
    Size=size(Flags,2);
    for cont = 1:1:size(Flags_new,2)
        Index = strmatch(Flags_new(cont),Flags);
        if ~isempty(Index)
            Paths(Index)=Paths_new(cont);
            Flags(Index)=Flags_new(cont);
        else
            Paths(Size+1)=Paths_new(cont);
            Flags(Size+1)=Flags_new(cont);
        end
    end
end
fid=fopen(PathFileName,'w');
for count = 1:1:size(Flags,2)
    fprintf(fid,'%s\n',[Flags{count},'||',Paths{count}]);
end
fclose(fid);

%--------------------------------------------------------------------------
function [Paths_out,Flags_out] = get_path(Flags,varargin)
if ~isempty(varargin{1})
    PathFileName=varargin{1};
else
    PathFileName='vibtab.path';
end
if isempty(Flags)
    % SRES: Save Results path
    % LRES: Load Results path
    % PLT: Plot path
    % REP: Report path
    Flags = {'SRES','LRES','PLT','REP'};
end
Dir=dir(PathFileName);
if isempty(Dir)
    Flags_out=[];
    Paths_out=[];
else
    [Flags_tmp,Paths_tmp]=textread(PathFileName,'%s %s','delimiter','||');
    Flags_tmp=Flags_tmp';
    Paths_tmp=Paths_tmp';
    Size=size(Flags_tmp,2);
    for cont = 1:1:size(Flags,2)
        Index = strmatch(Flags(cont),Flags_tmp);
        if ~isempty(Index)
            if exist('Flags_out')
                Flags_out={Flags_out{:},Flags_tmp{Index}};
                Path_out={Path_out{:},Path_tmp{Index}};
            else
                Flags_out{1}=Flags_tmp{Index};
                Paths_out{1}=Paths_tmp{Index};
            end
        else
            Flags_out=[];
            Paths_out=[];
        end
    end
end