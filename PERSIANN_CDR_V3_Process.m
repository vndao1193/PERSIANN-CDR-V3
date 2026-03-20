%% IMERGF
load '/zfs_data2/shared/ResearchSpace/PUnet/Matlab Code/IMERG_DF_22.mat'
IMERG_DF_22 = IMERG;
IMERG =[];
load '/zfs_data2/shared/ResearchSpace/PUnet/Matlab Code/IMERG_DF_23.mat'
parpool(10, 'IdleTimeout', 10000);
parfor i=1:365
    disp(i)
    IMERG_DF_22_1d(:,:,i)=imresize(IMERG_DF_22(:,:,i),[240,720],'bilinear');
    IMERG_DF_23_1d(:,:,i)=imresize(IMERG_DF_23(:,:,i),[240,720],'bilinear');
end

IMERG_DF_22_1d(IMERG_DF_22_1d<0)=NaN;
IMERG_DF_22_1d= single(IMERG_DF_22_1d);
IMERG_DF_23_1d(IMERG_DF_23_1d<0)=NaN;
IMERG_DF_23_1d= single(IMERG_DF_23_1d);
save('IMERG_DF_22_1d','IMERG_DF_22_1d','-v7.3');
save('IMERG_DF_23_1d','IMERG_DF_23_1d','-v7.3');

figure()
img =nansum(IMERG_DF_22_1d(:,:,:),3);
imagesc(img,[0,2000])
colormap(turbo)
%% PUnet CDR global
path='/zfs_data2/ndphu/PUnet/PUnetCDR/PUnetCDR1d/';

files = dir(fullfile(path, 'punetcdr1d22*'));
fileNames = cell2mat({files.name}');
delete(gcp('nocreate'));
parpool(10, 'IdleTimeout', 10000);

punetcdr_daily_22=[];
parfor i=1:365
    fn=fileNames(i,:);
    om = loadbfn_lgz([path fn],[3000, 9000], 'float');
    om = imresize(om,[240 720],'bilinear');
    punetcdr_daily_22(:,:,i)=single(om);
    i
end

%%%
files = dir(fullfile(path, 'punetcdr1d23*'));
fileNames = cell2mat({files.name}');

punetcdr_daily_23=[];
parfor i=1:365
    fn=fileNames(i,:);
    om = loadbfn_lgz([path fn],[3000, 9000], 'float');
    om = imresize(om,[240 720],'bilinear');
    punetcdr_daily_23(:,:,i)=single(om);
    i
end
delete(gcp('nocreate'));

punetcdr_daily_22(punetcdr_daily_22<0)=NaN;
punetcdr_daily_22= single(punetcdr_daily_22);
punetcdr_daily_23(punetcdr_daily_23<0)=NaN;
punetcdr_daily_23= single(punetcdr_daily_23);

save('punetcdr_daily_22_agu_1d','punetcdr_daily_22','-v7.3');
save('punetcdr_daily_23_agu_1d','punetcdr_daily_23','-v7.3');

figure()
img =nansum(punetcdr_daily_23(:,:,:),3);
imagesc(img,[0,2000])
colormap(turbo)

%% PUnet CDR CONUS
load mask_CONUS.mat

% dimension of CONUS images at 0.04 degree
n_row_conus=875; n_col_conus=1750;

% conus_mask=mask_CONUS(141:749,134:1577);
load conus_mask
%load conus_mask_full
conus_mask(conus_mask<0)=nan; conus_mask=double(conus_mask);
conus_mask=single(conus_mask); 
% path to ST4 data
path_ST4='/nfs/chrs-data1/CHRSData/StageIV/daily/';
% CONUS window rows 
row1 = 126; col1 = 5751-4500;

%%
path='/nfs/chrs-data3/goesdata/chrs-data/product/PUnetCDR/PUnetCDR1d/';

files = dir(fullfile(path, 'punetcdr1d22*'));
fileNames = cell2mat({files.name}');

delete(gcp('nocreate'))
parpool(12,'IdleTimeout',10000)

punetcdr_daily_CONUS_22=[];
parfor i=1:365
    fn=fileNames(i,:);
    tmp = loadbfn_lgz([path fn],[3000, 9000], 'float');
    tmp(tmp<0)=NaN;
    tmp = tmp(row1:row1+n_row_conus-1, col1:col1+n_col_conus);
    tmp = tmp(141:749,134:1577);
    punetcdr_daily_CONUS_22(:,:,i)=single(tmp)+conus_mask;
    disp(i)
end

figure()
img =nansum(punetcdr_daily_CONUS_22(:,:,:),3);
imagesc(img,[0,1500])
colormap(turbo)

save punetcdr_daily_CONUS_22.mat punetcdr_daily_CONUS_22 -v7.3
save punetcdr_daily_CONUS_23.mat punetcdr_daily_CONUS_23 -v7.3

delete(gcp('nocreate'))


%% GPCP 1DD
path_gpcp='/home/ndphu/PUnet_new/PUnet_CDR_evaluation/GPCP_1DD/';
files = dir(fullfile(path_gpcp, 'gpcp_v01r03_daily_d2023*'));
fileNames = cell2mat({files.name}');

gpcp_1dd_2023=[];
for i=1:365
    om = ncread([path_gpcp fileNames(i,:)], 'precip');
    precip = circshift(flipud(om'), 180, 2);
    precip = precip(31:150,:);
    %precip = imresize(precip,[1200 3600],'bilinear');
    gpcp_1dd_2023(:,:,i) = precip;
    i
end

gpcp_daily_22 = single(gpcp_1dd_2022);
gpcp_daily_23 = single(gpcp_1dd_2023);

gpcp_daily_22(gpcp_daily_22<0)=nan;
gpcp_daily_23(gpcp_daily_23<0)=nan;

save('gpcp_daily_22_1d','gpcp_daily_22','-v7.3');
save('gpcp_daily_23_1d','gpcp_daily_23','-v7.3');

figure()
img =GPCP_daily(:,:,10);
imagesc(img,[0,60])
colormap(turbo)

[N1,N2,N3] = size(PCCSCDR_daily);
nan_count2 = sum( reshape(isnan(PCCSCDR_daily), N1*N2, N3), 1 )';  % (t x 1)

figure()
img =PCCSCDR_daily(:,:,10);
imagesc(img,[0,60])
colormap(turbo)
%% GPCP 1dd CONUS
path_gpcp='/home/ndphu/PUnet_new/PUnet_CDR_evaluation/GPCP_1DD/';
files = dir(fullfile(path_gpcp, 'gpcp_v01r03_daily_d2023*'));
fileNames = cell2mat({files.name}');

gpcp_daily_CONUS_23=[];
for i=1:365
    om = ncread([path_gpcp fileNames(i,:)], 'precip');
    precip = circshift(flipud(om'), 180, 2);
    precip = precip(31:150,:);
    tmp = imresize(precip,[3000 9000],'bilinear');
    tmp = tmp(row1:row1+n_row_conus-1, col1:col1+n_col_conus);
    tmp = tmp(141:749,134:1577);
    gpcp_daily_CONUS_23(:,:,i)=single(tmp)+conus_mask;
    disp(i)
end

gpcp_daily_CONUS_22 = single(gpcp_daily_CONUS_22);
gpcp_daily_CONUS_23 = single(gpcp_daily_CONUS_23);

gpcp_daily_CONUS_22(gpcp_daily_CONUS_22<0)=nan;
gpcp_daily_CONUS_23(gpcp_daily_CONUS_23<0)=nan;

save('gpcp_daily_CONUS_22','gpcp_daily_CONUS_22','-v7.3');
save('gpcp_daily_CONUS_23','gpcp_daily_CONUS_23','-v7.3');



%% PCCSCDR daily
path_pccscdr='/nfs/chrs-data3/shared/Bol/CCS_CDR_CPC/Daily/2022/';
files = dir(fullfile(path_pccscdr, '*bin.gz'));
fileNames = cell2mat({files.name}');

pccscdr_daily_22=[];
parpool(12,'IdleTimeout',10000)
parfor i=1:365
    fn=fileNames(i,:);
    om = loadbfn_lgz([path_pccscdr fn],[3000, 9000], 'float');
    om = imresize(om,[240 720],'bilinear');
    pccscdr_daily_22(:,:,i)=circshift(om,360,2);
    i
end
%%%%
path_pccscdr='/nfs/chrs-data3/shared/Bol/CCS_CDR_CPC/Daily/2023/';
files = dir(fullfile(path_pccscdr, '*bin.gz'));
fileNames = cell2mat({files.name}');

pccscdr_daily_23=[];
parfor i=1:365
    fn=fileNames(i,:);
    om = loadbfn_lgz([path_pccscdr fn],[3000, 9000], 'float');
    om = imresize(om,[240 720],'bilinear');
    pccscdr_daily_23(:,:,i)=circshift(om,360,2);
    i
end
delete(gcp('nocreate'))

pccscdr_daily_22(pccscdr_daily_22<0)=nan;
pccscdr_daily_23(pccscdr_daily_23<0)=nan;
pccscdr_daily_22 = single(pccscdr_daily_22);
pccscdr_daily_23 = single(pccscdr_daily_23);
save('pccscdr_daily_22_1d','pccscdr_daily_22','-v7.3');
save('pccscdr_daily_23_1d','pccscdr_daily_23','-v7.3');

figure()
img =nansum(pccscdr_daily_23(:,:,:),3);
imagesc(img,[0 2000])
colormap(turbo)
%%CONUS
path_pccscdr='/nfs/chrs-data3/shared/Bol/CCS_CDR_CPC/Daily/2022/';
files = dir(fullfile(path_pccscdr, '*bin.gz'));
fileNames = cell2mat({files.name}');

pccscdr_daily_CONUS_22=[];

delete(gcp('nocreate'))
parpool(12,'IdleTimeout',10000)
parfor i=1:365
    fn=fileNames(i,:);
    om = loadbfn_lgz([path_pccscdr fn],[3000, 9000], 'float');
    tmp =circshift(om*100,4500,2);
    tmp = tmp(row1:row1+n_row_conus-1, col1:col1+n_col_conus);
    tmp = tmp(141:749,134:1577);
    pccscdr_daily_CONUS_22(:,:,i)=single(tmp)+conus_mask;
    disp(i)
end
delete(gcp('nocreate'))

pccscdr_daily_CONUS_22(pccscdr_daily_CONUS_22<0)=nan;
pccscdr_daily_CONUS_23(pccscdr_daily_CONUS_23<0)=nan;
pccscdr_daily_CONUS_22 = single(pccscdr_daily_CONUS_22);
pccscdr_daily_CONUS_23 = single(pccscdr_daily_CONUS_23);
save('pccscdr_daily_CONUS_22','pccscdr_daily_CONUS_22','-v7.3');
save('pccscdr_daily_CONUS_23','pccscdr_daily_CONUS_23','-v7.3');


%%%%PCDR yearly
path_pcdr='/home/ndphu/PUnet_new/PUnet_CDR_evaluation/PCDR_yearly/';
files = dir(fullfile(path_pcdr, '*bin.gz'));
fileNames = cell2mat({files.name}');

for i = 1:2
    fn=fileNames(i,:);
    om = loadbfn_lgz([path_pcdr fn],[480, 1440], 'float');
    om = imresize(om,[1200 3600],'bilinear');
    pcdr_22_23(:,:,i)=circshift(om,1800,2);
    pcdr_22_23(pcdr_22_23<0)= nan;
end

%%%%PCDR daily
path_pcdr='/home/ndphu/PUnet_new/PUnet_CDR_evaluation/PCDR_daily/';
files = dir(fullfile(path_pcdr, 'aB1*'));
fileNames = cell2mat({files.name}');

for i = 1:730
    fn=fileNames(i,:);
    om = loadbfn_lgz([path_pcdr fn],[480, 1440], 'float');
    om = imresize(om,[240 720],'bilinear');
    pcdr_daily_22_23(:,:,i)=circshift(om,360,2);
    pcdr_daily_22_23(pcdr_daily_22_23<0)= nan;
    disp(i)
end

pcdr_daily_22_23 = single(pcdr_daily_22_23);
save('pcdr_daily_22_23_1d','pcdr_daily_22_23','-v7.3');

figure()
img =nansum(pcdr_daily_22_23(:,:,:),3)/2;
imagesc(img,[0 2000])
colormap(turbo)

%%%%PCDR CONUS
path_pcdr='/home/ndphu/PUnet_new/PUnet_CDR_evaluation/PCDR_daily/';
files = dir(fullfile(path_pcdr, 'aB1*'));
fileNames = cell2mat({files.name}');

for i = 1:730
    fn=fileNames(i,:);
    om = loadbfn_lgz([path_pcdr fn],[480, 1440], 'float');
    om = imresize(om,[3000 9000],'bilinear');
    tmp = circshift(om,4500,2);
    tmp = tmp(row1:row1+n_row_conus-1, col1:col1+n_col_conus);
    tmp = tmp(141:749,134:1577);
    pcdr_daily_CONUS_22_23(:,:,i)=single(tmp)+conus_mask;
    pcdr_daily_CONUS_22_23(pcdr_daily_CONUS_22_23<0)= nan;
    disp(i)
end

pcdr_daily_CONUS_22_23 = single(pcdr_daily_CONUS_22_23);
save('pcdr_daily_CONUS_22_23','pcdr_daily_CONUS_22_23','-v7.3');

%%%%CPC global
path_cpc ='/home/ndphu/PUnet_new/PUnet_CDR_evaluation/CPC_global/';
files = dir(fullfile(path_cpc, '*nc'));
fileNames = cell2mat({files.name}');

ncdisp([path_cpc fileNames(1,:)]);

om = ncread([path_cpc fileNames(44,:)], 'precip');
om = permute(om, [2 1 3]);
om = circshift(om(61:300,:,:), [0 360 0]);
om(om<0)=nan;

cpc_daily_22 = single(om);

cpc_daily_23 = single(om);
save('cpc_daily_22_1d','cpc_daily_22','-v7.3');
save('cpc_daily_23_1d','cpc_daily_23','-v7.3');

%%%% GPCP 2.5 monthly
path = '/nfs/chrs-data3/archive/B1_persiann/noaa_gpcp_monthly/v23_swp_bin/2022/';
files = dir(fullfile(path, '*bin'));
fileNames = cell2mat({files.name}');
GPCP_monthly_22=[];
for m =1:12
    %% Load and preprocess GPCP
    gpcp_file = [path fileNames(m,:)];
    gpcp = loadbfn_b(gpcp_file, [72 144], 'float32');
    gpcp = gpcp(13:60, :);  % Trim to 48x144
    gpcp(gpcp == -99999 | gpcp < -4000) = 0;
    gpcp = [gpcp(:,73:144), gpcp(:,1:72)];
    gpcp = imresize(gpcp,[1200 3600],'bilinear');
    GPCP_monthly_22(:,:,m)=gpcp;
    disp(m)
end

gpcp25_month= (GPCP_monthly_22+GPCP_monthly_23);
for i=1:12
    days_m= [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];
    GPCP_monthly(:,:,i)=gpcp25_month(:,:,i)*days_m(i);
    PRECIP_GPCP25_m(i) = nanmean(reshape(gpcp25_month(:,:,i), 1, []))*days_m(i);
    disp(i)
end

%%%%PUnet CDR monthly
path='/nfs/chrs-data3/shared/Phu/PUnetCDR/PUnetCDR1m/';

files = dir(fullfile(path, 'punetcdr1m23*'));
fileNames = cell2mat({files.name}');

punetcdr_month_23=[];
for i=1:12
    fn=fileNames(i,:);
    om = loadbfn_lgz([path fn],[3000, 9000], 'float');
    om = imresize(om,[1200 3600],'bilinear');
    punetcdr_month_23(:,:,i)=single(om);
    i
end

punetcdr_month= (punetcdr_month_22+punetcdr_month_23);
for i=1:12
    PRECIP_punet_m(i) = nanmean(reshape(punetcdr_month(:,:,i), 1, []));
end

%%%%PUnet monthly
path='/nfs/chrs-data3/shared/Phu/PUnetCDR/PUnet1m/';

files = dir(fullfile(path, 'PUnetB1m23*'));
fileNames = cell2mat({files.name}');

punet_month_23=[];
for i=1:12
    fn=fileNames(i,:);
    om = loadbfn_lgz([path fn],[3000, 9000], 'float');
    %om = imresize(om,[48 144],'bilinear');
    punet_month_23(:,:,i)=single(om);
    i
end

punet_month= (punet_month_22+punet_month_23);
for i=1:12
    PRECIP_pu_m(i) = nanmean(reshape(punet_month(:,:,i), 1, []));
end
PRECIP_pu_m
PRECIP_punet_m
PRECIP_GPCP25_m

%% CMORPH CDR daily
%% CMORPH: Extract daily fields for 2022-2023 and downsample to 120x360

path = '/nfs/chrs-data3/shared/Bol/PUNET/CMORPH/CMORPH/Daily/';
files = dir(fullfile(path, 'CMORPH_V1.0_ADJ_0.25deg-DLY_00Z_*.nc'));

% --- select years 2022-2023 based on filename positions (YYYY at 33:36)
years_all = arrayfun(@(f) str2double(f.name(33:36)), files);
selected_years = [2022 2023];
idx_sel = ismember(years_all, selected_years);

files_sel = files(idx_sel);

% sort by filename (usually chronological)
[~, sidx] = sort({files_sel.name});
files_sel = files_sel(sidx);

N = numel(files_sel);
if N == 0
    error('No CMORPH daily files found for 2022-2023 in %s', path);
end

% output array: [lat x lon x time] = [120 x 360 x Ndays]
cmorph_daily_1d = nan(120, 360, N, 'single');

parpool(10, 'IdleTimeout', 10000);

parfor i = 1:N
    this_file = fullfile(path, files_sel(i).name);

    % read and orient like your original code
    precip = ncread(this_file, 'cmorph');   % likely [lon x lat] or [x y]
    precip = precip';                       % -> [lat x lon]
    precip = flipud(precip);                % flip latitude
    precip = [precip(:,721:1440), precip(:,1:720)]; % lon shift

    % downsample 0.25° -> 1.0° (480x1440 -> 120x360) using 4x4 block mean
    % (If you prefer block SUM for totals, replace mean(...) with sum(...))
    precip1deg = imresize(precip, [120 360], 'bilinear');

    cmorph_daily_1d(:,:,i) = single(precip1deg);

    if mod(i, 50) == 0 || i == N
        fprintf('Processed %d / %d files\n', i, N);
    end
end

save('cmorph_daily_1d','cmorph_daily_1d','-v7.3');

plot_global_year(nansum(cmorph_daily_1d,3)/2,'',custom,[0 2000])

%% CMORPH daily CONUS 
path_cmorph = '/nfs/chrs-data3/shared/Bol/PUNET/CMORPH/CMORPH/Daily/';
files = dir(fullfile(path_cmorph, 'CMORPH_V1.0_ADJ_0.25deg-DLY_00Z_*.nc'));

% select year 2023 from filename (YYYY at 33:36)
years_all = arrayfun(@(f) str2double(f.name(33:36)), files);
files_22 = files(years_all == 2022);

% sort
[~, sidx] = sort({files_22.name});
files_22 = files_22(sidx);

% ---- output size inferred from your final crop: 141:749 (609 rows), 134:1577 (1444 cols)
nrow_out = 749 - 141 + 1;   % 609
ncol_out = 1577 - 134 + 1;  % 1444

cmorph_daily_CONUS_22 = nan(nrow_out, ncol_out, numel(files_22), 'single');

delete(gcp('nocreate'));
parpool(12,'IdleTimeout',10000);

parfor i = 1:numel(files_22)
    fn = fullfile(path_cmorph, files_22(i).name);

    % --- read CMORPH like before
    precip = ncread(fn, 'cmorph');
    precip = precip'; 
    precip = flipud(precip);
    precip = [precip(:,721:1440), precip(:,1:720)];

    % --- your exact CONUS extraction steps
    tmp = imresize(precip, [3000 9000], 'bilinear');
    tmp = tmp(row1:row1+n_row_conus-1, col1:col1+n_col_conus);
    tmp = tmp(141:749, 134:1577);

    % add mask (assumes conus_mask same size as tmp; NaN outside or additive mask)
    tmp = single(tmp) + conus_mask;

    % clean negatives / fill
    tmp(tmp < 0) = NaN;

    cmorph_daily_CONUS_22(:,:,i) = tmp;

    if mod(i,50)==0
        fprintf('2023: %d / %d\n', i, numel(files_22));
    end
end

delete(gcp('nocreate'));

save('cmorph_daily_CONUS_22.mat', 'cmorph_daily_CONUS_22', '-v7.3');

