% Test to verify the 630nm resolution against the 2.5nm resolution
clear all;
close all;
DIG_RES = 630; %(means 630nm)
%
% Lennratz 3D 1s: velocimetro
%DATA_PATH = 'E:\Projects\Seismology\Tarature\2013.CalibrazioniXCacco\F0304\SOURCEDATA\';
%
% EPISENOR: accelerometro
DATA_PATH = 'E:\Projects\Seismology\Tarature\2013.EPISENSOR\FBA_E_ST_01340\BUFFERS\hor.buffer\';
SOURCEFILE  = [DATA_PATH, 'lddm.asc'];
DESTFILE    = [DATA_PATH, 'lddm_low_res.asc'];
HEADER  =   textread(SOURCEFILE,'%s',1,'delimiter','\r');
DIST    =   textread(SOURCEFILE,'%f','commentstyle','shell');
DIST_LOW_RES_TO_FILE =   DIST-rem(DIST,DIG_RES);
DIST=DIST*1e-9;
DIST_LOW_RES = DIST_LOW_RES_TO_FILE*1e-9;
T=0:2e-3:(length(DIST)-1)*2e-3;
H1=plot(T,DIST);
hold on;
H2=plot(T,DIST_LOW_RES,'r');
STRING_LEGEND = {'FULL RES. 2.5nm','LOW RES. 630nm'};
xlabel('t[s]');
ylabel('Displacement[m]');
legend([H1,H2],STRING_LEGEND)
grid on;
disp(sprintf('%s',char(HEADER)))
disp(sprintf('%d\n',DIST_LOW_RES_TO_FILE))
fid = fopen(DESTFILE,'w');
fprintf(fid,'%s\n',char(HEADER));
fprintf(fid,'%d\n',DIST_LOW_RES_TO_FILE);
fclose(fid)