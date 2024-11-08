function out=secday2datenum(secday)
% converts the given number of seconds from the beginning of the day to a
% correct datenum format
dateNow=clock;
secday=secday(:);
Y=ones(length(secday),1)*dateNow(1);
M=ones(length(secday),1)*dateNow(2);
D=ones(length(secday),1)*dateNow(3);
HH=floor(secday/3600);
MM=floor((secday-3600*HH)/60);
SS=secday-3600*HH-60*MM;
out = datenum([Y,M,D,HH,MM,SS]);