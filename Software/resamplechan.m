% Used to resample signals to reach the 500Hz sample rate
clear all;
close all;
%
% USER SETTINGS START HERE
dstFs           = 500; % destination sampling rate = 500Hz
cutOffLowPass   = 125; % low pass pre-filtering cut-off frequency in Hz
BASEPATH= '/Users/dzuliani/VBOX.SHARE/Projects/Seismology/Tarature/2020.MAE.ROMANELLI.PETRONIO/2020.08.18/2197Hz/NOISE/';
DATESTRING='180820';
TIMESTRINGS={'180331'}; % you can inlcude more time strings if data is coming from different dataloggers
DATALOGGERS={'vmr1'};   % you can inlcude more datalogger strings if data is coming from different dataloggers
CHANNUM=6;
% USER SETTINGS ENDS HERE
%
outputTypes={'.res.asc','.prefilt.res.asc'};
for k = 1:length(outputTypes)
    outputType=outputTypes{k};
    for i=1:length(DATALOGGERS)
        for j=1:CHANNUM
            SOURCEFILE  = [BASEPATH,DATALOGGERS{i},'_',DATESTRING,'_',TIMESTRINGS{i},'ch',num2str(j),'.asc'];
            destFile    = regexprep(SOURCEFILE, '.asc', outputType);
            header      = textread(SOURCEFILE,'%s',1,'delimiter','\r');
            data        = textread(SOURCEFILE,'%f','commentstyle','shell');
            dstPeriod   = 1/dstFs; % destination sampling period = 2ms
            key1 = 'samp';
            key2 = 'start';
            sampPeriodStr(1) = cell2mat(regexp(header,key1))+length(key1)+1;
            sampPeriodStr(2) = cell2mat(regexp(header,key2))-2;
            PeriodStr = header{1}(sampPeriodStr(1):sampPeriodStr(2));
            sampPeriod = (1e-3)*str2double(PeriodStr);
            sampPeriod = 1/2197; % futizzato per un tentativo a 2197Hz invece che a quello divhiarato da MAE di 2193Hz
            strFs = round(1/sampPeriod);
            dataOri=data;   % saving the original signal
            switch outputType
                case '.res.asc'
                    %
                    % no pre-filtering
               case '.prefilt.res.asc'
                    %
                    % low-pass pre-filtering
                    Fs=strFs;               % sampling frequency
                    Wcs=2*pi*Fs;            % 
                    Ts=1/Fs;                % sampling period
                    Fc_H=cutOffLowPass;     % cut-off frequency
                    Wc_H=2*pi*Fc_H;         % 
                    Wcn_H=Wc_H/(Wcs/2);     % 
                    O=8;                    % filter order
                    Nc=10*Fs/Fc_H;          % N. of samples used to compute the digital filter
                    Nc_power2=2;
                    while Nc_power2<=Nc     % Nc is rebuild in order to be a power of 2 so speed up the calculs of the frequency response in the next steps
                        Nc_power2=2*Nc_power2;
                    end
                    [B_a_lp,A_a_lp]=butter(O,Wc_H,'low','s');               % building the analog filter
                    [B_d_lp,A_d_lp]=butter(O,Wcn_H,'low');                  % building the digital filter
                    SYS_Low_pass=tf(B_a_lp,A_a_lp);                         % analog filter transfer function
                    [h_a_lp,w_a_lp]=freqs(B_a_lp,A_a_lp);                   % analog filter frequency response
                    [h_d_lp,f_d_lp]=freqz(B_d_lp,A_d_lp,Nc_power2,Fs);      % digital filter frequency response
                    f_a_lp=w_a_lp/(2*pi);                                   % frequency values used to evaluate the frequency responses                    
                    data=filtfilt(B_d_lp,A_d_lp,data);                      % filtering
            end
            %
            % Resampling
            dataRes=resample(data,dstFs,strFs);
            strT = sampPeriod*(0:1:length(data)-1);
            dstT = dstPeriod*(0:1:length(dataRes)-1);
            %
            % Plots
            figure;
            switch outputType
                case '.res.asc'
                    %
                    % no pre-filtering
                    plot(strT,dataOri,'r'); % original signal
                    hold on;
                    plot(dstT,dataRes,'b'); % resampled signal without pre-filtering   
                    legend({['original at ',num2str(strFs),'Hz'],...
                        ['resampled at ',num2str(dstFs),'Hz']});
                case '.prefilt.res.asc'
                    %
                    % low-pass pre-filtering
                    plot(strT,dataOri,'r'); % original signal
                    hold on;
                    plot(strT,data,'b');    % pre-filered signal
                    plot(dstT,dataRes,'m'); % resampled signal without pre-filtering   
                    grid on;
                    legend({['original at ',num2str(strFs),'Hz'],...
                        [num2str(cutOffLowPass),'Hz low pass pre-filtered at ',num2str(strFs)],...
                        ['resampled at ',num2str(dstFs),'Hz']});
            end
            grid on;
            xlabel('time [s]');
            ylabel('Magnitude [counts]');
            finalheader = regexprep(header{1}, PeriodStr, num2str(dstPeriod*1000));
            title(char(finalheader),'Interpreter','none');
            fprintf('%s\n',char(finalheader));
            fid = fopen(destFile,'w');
            fprintf(fid,'%s\n',char(finalheader));
            fprintf(fid,'%d\n',round(dataRes));
            fclose(fid);
        end
    end
end