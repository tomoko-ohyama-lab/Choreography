%% chore_multipleplot
% Best when comparing different genotypes (2 or more lines plotted)

%% Set parameters - **** MANUALLY ****
clear all
figureName='';
chore = {'curve'}; % SET MANUALLY
choredir = 'E:\temp\'; % SET MANUALLY
    % choredir = folder location where all genotypes are stored
    %         ~= folder location of specific genotype
outdir = 'E:\'; % SET MANUALLY

%% get filelist (uses GUI)
fileTypes = {'midline','curve','kink','x','y','bias','speed','crabspeed','cast'};
d = dir(choredir);
% Select genotype(s) (more than one including control is acceptable)
[indx,tf] = listdlg('ListString',{d.name});
d2 = [];
for ii = 1:length(indx)
    newpath = fullfile(d(indx(ii)).folder,d(indx(ii)).name);
    d2 = vertcat(d2, dir(newpath));
end
un = unique({d2.name});
% Select ONE protocol
[indx,tf] = listdlg('ListString',un);
filt = contains({d2.name},un{indx})';
d2 = d2(filt);
d3 = [];
for ii = 1:length(d2)
    newpath = fullfile(d2(ii).folder,d2(ii).name);
    d3 = vertcat(d3, dir(newpath));
end
names = {d3.name};
expr = '^\d\d\d\d\d\d\d\d';
dates = regexp(names,expr,'match','once');
[C,ia,ic] = unique(dates);
% Select date folders
[indx,tf] = listdlg('ListString',C);
filt = any(ic == indx,2);
d3 = d3(filt);
clear choredir
d_final = [];
for ii = 1:length(d3)
    choredir{ii} = fullfile(d3(ii).folder,d3(ii).name);
    d_final = vertcat(d_final, dir([choredir{ii} '\*.' chore{:} '.dat']));
end
%% read name for the genotype
protocol=char(d2(1).name);
times=read_protocol(protocol);
waiting=times.waiting;
circles=times.circles;
stimdur=times.stimdur;
stimint=times.stimint;
stimspec=stimdur+stimint;
%% group genotypes
names = {d_final.folder}';
splits = cellfun(@(x) split(x,'\'), names, 'UniformOutput', false);
splits = cellfun(@(x) [x{end-2},'\',x{end-1}], splits, 'UniformOutput', false);
[uname,na,nb] = unique(splits);
%% plot loop 
% import specs
delimiter = ' ';
startRow = 0;
formatSpec = '%s%f%f%f%[^\n\r]';
for ii = 1:length(uname)
    % determine files to import
    idx = find(nb == ii);
    % import midline data %
    et = {};
    dat = {};
    for jj = idx'
        fname = fullfile(d_final(jj).folder,d_final(jj).name);
        fileID = fopen(fname,'r');
        dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter,'MultipleDelimsAsOne', true, 'HeaderLines' ,startRow, 'ReturnOnError', false);
        fclose(fileID);
        et = vertcat(et,dataArray{:,3});
        dat = vertcat(dat,dataArray{:,4});
        clear dataArray
    end
    et = vertcat(et{:});
    dat = vertcat(dat{:});
    
    % calculate timeseries %
    bins = 0:0.5:ceil(max(et));
    nanarr = nan(1,length(bins));
    Y = discretize(et,bins);
    seri = accumarray(Y,dat,[],@mean);
    nanarr(1:length(seri)) = seri;
    seri = nanarr;
    
    fig = figure(1);
    p(ii) = plot(bins,seri);
    hold on
    drawnow
    ylim_min=[];
    ylim_max=[];
    if strcmp(chore,'crabspeed')
        ylim_min=0;
        ylim_max=1.5;
    elseif strcmp(chore, 'speed')
        ylim_min=0.2;
        ylim_max=1.4;
    elseif strcmp (chore, 'midline')
        ylim_min=2.8;
        ylim_max=4.2;
    else
        ylim_min=5;
        ylim_max=40;
    end
    ylim= [ylim_min ylim_max];
    xlim([30 160])
    fileName = strrep(uname{ii},'\','@');
    ax = gca;
    if strcmp(chore,'speed')||strcmp(chore,'crabspeed')
        choreUnit=strcat(chore,' (ms)');
        ax.YLabel.String=choreUnit;
    else
        ax.YLabel.String = chore;
    end
    ax.XLabel.String = 'time (s)';
    if ii==1
        figureName=fileName;
        titleName = strrep(fileName,'_','-');
        index=strfind(titleName,'@');
        titleName=titleName(1:index(2)+7);
        ax.Title.String = titleName;
    end
end

for i=1:circles
    f=fill([waiting+(i-1)*(stimdur+stimint),waiting+(i-1)*(stimdur+stimint)+stimdur,waiting+(i-1)*(stimdur+stimint)+stimdur,waiting+(i-1)*(stimdur+stimint)],[ylim_min,ylim_min,ylim_max,ylim_max],'k');
    f.FaceAlpha=0.1;
    f.EdgeColor='none';
end
hold off

legendnames = regexp(uname,'\w*[@]\w*','match','once');
legendnames = strrep(legendnames,'_','-');
lgd = legend(p,legendnames,'Location','northeast');

figureName=strcat(figureName,'@',chore);
figureName=char(figureName);
filepath=strcat(outdir,'\',figureName);
savefig(fig,filepath);

%% credit: AG,JZ,SN