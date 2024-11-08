function x=vibrocleanerlddm3(FILENAME)
close all;
format long g;
%
%% Reading file
if nargin<1
    %FILENAME = 'E:\Projects\Seismology\Tarature\2021.adel\DUT\lddm.asc';
    FILENAME = '/Users/dzuliani/VBOX.SHARE/Projects/Seismology/Tarature/2021.adel/DUT.esperimento.outlier.remove/lddm.asc';
end
%
%% User parameters
THRESHOLDS  = [18 8 5];       % limits to reject outliers for each derivative order
SAMPLESMARGIN = 5; % Number of samples to exclude before and after the worst outlier
dOrder      = length(THRESHOLDS)-1; % 1 means find outliers at displacemente and velocity level, 2 find outliers at displacement, velocity and acceleration level
%
%% reading header
fid = fopen(FILENAME);
x.header=textscan(fid,'%s',1,'delimiter','\n');
fclose(fid);
%
%% getting data
x.data.ori=textread(FILENAME,'%f','commentstyle','shell');  % original signal with outliers at thifferent levels (or derivatives)
x.data.raw=x.data.ori;                                      % this is an intermediate array used to keep derivatives
x.data.clean=x.data.ori;                                    % this is the cleaned array
%
%% Derivative loops
for dO = 0:dOrder
    idxGlobal.(['dO',num2str(dO)])=[];
    search = 1;             % used as a flag variable to stop outlier seraching loop
    runNum = 0;             % number of runs needed to exclude outliers (initial set up is 0, at each loop it increases)
    %
    % differentiates n-times the original signal, the array is included
    % inside the raw version.
    x.data.raw=deriv(x.data.raw,dO); % this is needed for searching at different diff datasets, dO = 0 means no derivatives
    figure;
    plot(x.data.raw,'b'); % plots raw data partially cleaned at each drivative order (at 1st run the dataset is uncleaned)
    hold on;
    grid on;
    title(['Outliers at derivative order: ',num2str(dO)]);
    %
    %% searching outliers
    while (search == 1)
        runNum = runNum +1;
        %
        % find worst outlier
        [~,~,~,idx] = findoutlier(x.data.raw,THRESHOLDS(dO+1),'N'); % find one outlier above the threshold and refer it at the original dataset idx
        idx=idx-dO;
        idxGlobal.(['dO',num2str(dO)]) = [idxGlobal.(['dO',num2str(dO)]),idx];
        %
        % Check if the worst outlier has overcome the threshold (empty
        % means the outlier is below the threshold
        if ~isempty(idx)
            x.data.clean = replaceoutlier(x.data.clean,idx,SAMPLESMARGIN);
            plot(deriv(x.data.clean,dO),'r:');    % plots cleaned dataset
            plot(idx+dO,x.data.raw(idx+dO),'ro'); % plots outliers
            x.data.raw  = deriv(x.data.clean,dO); % now data.raw becomes a differentiated partially cleaned dataset
        else
            search = 0;
        end
    end
    legend({'raw','cleaned',['outliers: [',num2str(length(idxGlobal.(['dO',num2str(dO)]))),']']})
    x.data.raw = x.data.clean; % now data.raw becomes a partially cleaned dataset not differentiated
end
%
%% Final plots
figure
plot(x.data.ori);
hold on;
plot(x.data.clean);
grid on;
title('Final plot');
legend('raw','cleaned');
%
%% writing data
fid = fopen([FILENAME,'.corr.asc'],'w');
fprintf(fid,'%s\n',char(x.header{1}));
fprintf(fid,'%ld\n',x.data.clean);
fclose(fid);

function y=deriv(x,ord)
% derivative function with order
y=x;
for i = 1:ord
    y=diff(y);
end

function [xRes,xAvg,xStd,idx] = findoutlier(x,threshold,doplot)
% this function looks for the worts outlier idx. Worst outlier is
% recognized if it is bigger than a value obtained using threshold, mean
% and std values of x.
%%
% A smoothed version af the signal is needed. This signal must
% roughly aproximate the signal at lower frequecies and it's needed to
% evaluate spikes from the residuals.
Fs=500;
Fc_L=60; 			% cutoff frequency in Hz
Wcs=2*pi*Fs;
Wc_L=2*pi*Fc_L;		% beat frequency
Wcn_L=Wc_L/(Wcs/2);	% normalized beat frequency
O=8;				% filter order
Nc=10*Fs/Fc_L;      % number of samples of the frequency response of the filter
Nc_power2=2;
while Nc_power2<=Nc % routine to evaluate Nc as a power of 2 (to speed up calculs)
    Nc_power2=2*Nc_power2;
end
[B_d_hp,A_d_hp] = butter(O,Wcn_L,'low');                % digital filter (the procedure produces the filter coeffs.)
xSmt = filtfilt(B_d_hp,A_d_hp,x); 	% filtered signal
%
%% needed values
xRes = x-xSmt;                      % residuals
xAvg = mean(xRes);
xStd = std(xRes);
%
%% getting the outlier
if max(abs(xRes)) >= xAvg+threshold*xStd
    [~,idx] = max(abs(xRes)); % looking for worst outlier
else
    idx = [];
end
%
%% Optional plots
switch doplot
    case {'Y','y'}
        figure;
        plot(xRes);
        hold on;
        plot(idx,xRes(idx),'ro');
        plot(ones(1,length(xRes))*(xAvg+threshold*xStd),'r');
        plot(-ones(1,length(xRes))*(xAvg+threshold*xStd),'r');
        grid on;
    otherwise
end

function y=replaceoutlier(x,idx,nsamp)
% this function gets the x dataset, where the outlier array index is idx.
% y dataset will be x dataset except for the samples from idx-nsamp to idx+nsamp.
% Those samples will be replaced with an interpolated version of x.
%
%% Interpolate signal N times before the worst outlier and N times after
% the worst outlier. Check if this margin is outside the signal limits
if (idx-nsamp < 1)
    leftMargin=idx+1;
else
    leftMargin=nsamp;
end
if (idx+nsamp > length(x))
    rightMargin=length(x)-idx;
else
    rightMargin=nsamp;
end
keepIdx     = [1:idx-leftMargin,idx+rightMargin:length(x)];
fullIdx     = 1:length(x);
xInterp     = interp1(keepIdx,x(keepIdx),fullIdx,'spline');
y           = x;
y(idx-leftMargin:idx+rightMargin) =  xInterp(idx-leftMargin:idx+rightMargin);
return







