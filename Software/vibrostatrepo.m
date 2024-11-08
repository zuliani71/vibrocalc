function x=vibrostatrepo(FILENAME)
if nargin<1
    FILENAME = 'E:\Projects\Seismology\Tarature\2017.LUNITEK\COLUMBIA_ACC\MODSA213417_SN068\FINAL\1800s_3\ColumbiaSA213417.068.Z.txt';
end
fileData=textread(FILENAME,'%s','delimiter','');
fileData=char(fileData);
readMags = 0;
readData = 0;
x=[];
for i = 1:length(fileData)
    row=fileData(i,:);
    if strcmp(deblank(row),'f        |H(f)|   ang(H(f))')
        readMags = 1;        
    else
        if readMags == 1
            mags = sscanf(row, '%s %s %s');
            mags = regexprep(mags, '][', ',');
            mags = regexprep(mags, '[[]+[]]', '');
            [magF,magM,magP] = strread(mags,'%s%s%s','delimiter',',');
            readMags = 0;
            readData = 1;
        else
            if readData == 1
                x = [x;(sscanf(row, '%f %f %f'))'];
            else
            end
        end
    end
end
fMin = min(x(:,1));
fMax = max(x(:,1));
%fMin = 1;
%fMax = 30;
idx = find((x(:,1)>=fMin) & (x(:,1)<=fMax));
MAG     = [sprintf('%3.1f',mean(x(idx,2))),char(magM),' +/- ',sprintf('%3.1f',(std(x(idx,2)))),char(magM)]
PHASE   = [sprintf('%3.1f',mean(x(idx,3))),char(magP),' +/- ',sprintf('%3.1f',(std(x(idx,3)))),char(magP)]

