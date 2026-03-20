%% Annual
load '/home/ndphu/PUnet_new/PUnet_CDR_evaluation/Matlab Code/IMERG_DF_22_1d.mat'
load '/home/ndphu/PUnet_new/PUnet_CDR_evaluation/Matlab Code/IMERG_DF_23_1d.mat'

load '/home/ndphu/PUnet_new/PUnet_CDR_evaluation/Matlab Code/punetcdr_daily_22_agu_1d.mat'
load '/home/ndphu/PUnet_new/PUnet_CDR_evaluation/Matlab Code/punetcdr_daily_23_agu_1d.mat'

load gpcp_daily_22_1d.mat
load gpcp_daily_23_1d.mat

load pccscdr_daily_22_1d.mat
load pccscdr_daily_23_1d.mat

load cpc_daily_22.mat
load cpc_daily_23.mat

load pcdr_daily_22_23_1d.mat

load cmorph_daily_1d.mat
%%

%%
PUnet_daily= PUnet_daily_22;
PDIR_daily=PDIR_daily_22;
HE_daily= HE_daily_22;
IMERG_DF = IMERG_DF_22;
IMERG_DF_22=[];
PUnet_daily_22=[];
PDIR_daily_22=[];
HE_daily_22=[];
%%

IMERG_DF= cat(3, IMERG_DF_22_1d, IMERG_DF_23_1d);
IMERG_DF_22_1d=[];IMERG_DF_23_1d=[];

PUnet_daily= cat(3, punetcdr_daily_22, punetcdr_daily_23);
punetcdr_daily_22=[];punetcdr_daily_23=[];

GPCP_daily = cat(3, gpcp_daily_22, gpcp_daily_23);
gpcp_daily_22=[]; gpcp_daily_23=[];

PCCSCDR_daily = cat(3, pccscdr_daily_22, pccscdr_daily_23);
pccscdr_daily_22=[]; pccscdr_daily_23=[];

CPC_daily = cat(3, cpc_daily_22, cpc_daily_23);
cpc_daily_22=[]; cpc_daily_23=[];

cmorph_daily = cmorph_daily_1d;

% PDIR_daily= cat(3, PDIR_daily_22, PDIR_daily_23);
% PDIR_daily_22=[];PDIR_daily_23=[];
% 
% HE_daily= cat(3, HE_daily_22, HE_daily_23);
% HE_daily_22=[] ; HE_daily_23=[];

%%Missing or bad data
s1= nanmean(PUnet_daily,[1 2]);
s2= nanmean(IMERG_DF,[1 2]);
s1=s1(:);
s2=s2(:);
idx1 = find(isnan(s1) | s1 > 5);
idx2 = find(isnan(s2) | s2 > 5);
idx= [idx1; idx2];

PUnet_daily(:,:,idx)=[];
IMERG_DF(:,:,idx)=[];
GPCP_daily(:,:,idx)=[];
PCCSCDR_daily(:,:,idx)=[];
pcdr_daily_22_23(:,:,idx)=[];
cmorph_daily(:,:,idx)=[];




%% Accumulation year
IMERG_YF= nansum(IMERG_DF,3)/2;
PUnet_year= nansum(PUnet_daily,3)/2;
GPCP_year = nansum(GPCP_daily,3)/2;
PCDR_year = nansum(pcdr_daily_22_23,3)/2;
PCCSCDR_year = nansum(PCCSCDR_daily,3)/2;
CPC_year = mean(CPC_daily, 3, 'omitnan')*365;


cmorph_year= nansum(cmorph_daily,3)/2;
%% Year Land
land_mask = ~isnan(CPC_year); 

IMERGF_year_land = IMERG_YF;IMERGF_year_land(land_mask == 0) = NaN;
PUnet_year_land = PUnet_year;PUnet_year_land(land_mask == 0) = NaN;
PCDR_year_land = PCDR_year;PCDR_year_land(land_mask == 0) = NaN;
PCCSCDR_year_land = PCCSCDR_year;PCCSCDR_year_land(land_mask == 0) = NaN;
GPCP_year_land = GPCP_year;GPCP_year_land(land_mask == 0) = NaN;
%% Plot annual global
load custom.mat

plot_global_year(PCDR_year, '',custom,[0 2000]);
plot_global_year(PCCSCDR_year, '',custom,[0 2000]);
plot_global_year(PUnet_year, '',custom,[0 2000]);
% plot_global_year(IMERG_YF, '',custom,[0 2000]);
plot_global_year(GPCP_year, '',custom,[0 2000]);
plot_global_year(cmorph_year, '',custom,[0 2000]);


plot_global_year(PCDR_year_land, 'PERSIANN-CDR',custom,[0 2000]);
plot_global_year(PCCSCDR_year_land, 'PERSIANN-CCS-CDR',custom,[0 2000]);
plot_global_year(PUnet_year_land, 'PUnet-CDR',custom,[0 2000]);
% plot_global_year(IMERGF_year_land, 'IMERGF',custom,[0 2000]);
plot_global_year(GPCP_year_land, 'GPCP-1DD',custom,[0 2000]);
plot_global_year(CPC_year, 'CPC',custom,[0 2000]);

%STAT yearly 

[CORR,RMSE,BIAS,MAE,NSE] = fn_STAT(IMERG_YF(:),GPCP_year(:));
[CORR,RMSE,BIAS,MAE,NSE] 
[CORR,RMSE,BIAS,MAE,NSE] = fn_STAT(IMERG_YF(:),PCCSCDR_year(:));
[CORR,RMSE,BIAS,MAE,NSE] 
[CORR,RMSE,BIAS,MAE,NSE] = fn_STAT(IMERG_YF(:),PUnet_year(:));
[CORR,RMSE,BIAS,MAE,NSE] 


[CORR,RMSE,BIAS,MAE,NSE] = fn_STAT(GPCP_year(:),IMERG_YF(:));
[CORR,RMSE,BIAS,MAE,NSE] 
[CORR,RMSE,BIAS,MAE,NSE] = fn_STAT(GPCP_year(:),PCCSCDR_year(:));
[CORR,RMSE,BIAS,MAE,NSE] 
[CORR,RMSE,BIAS,MAE,NSE] = fn_STAT(GPCP_year(:),PUnet_year(:));
[CORR,RMSE,BIAS,MAE,NSE] 
[CORR,RMSE,BIAS,MAE,NSE] = fn_STAT(GPCP_year(:),PCDR_year(:));
[CORR,RMSE,BIAS,MAE,NSE] 
[CORR,RMSE,BIAS,MAE,NSE] = fn_STAT(GPCP_year(:),cmorph_year(:));
[CORR,RMSE,BIAS,MAE,NSE] 


[CORR,RMSE,BIAS,MAE,NSE] = fn_STAT(CPC_year(:),PCDR_year(:));
[CORR,RMSE,BIAS,MAE,NSE] 
[CORR,RMSE,BIAS,MAE,NSE] = fn_STAT(CPC_year(:),PCCSCDR_year(:));
[CORR,RMSE,BIAS,MAE,NSE] 
[CORR,RMSE,BIAS,MAE,NSE] = fn_STAT(CPC_year(:),PUnet_year(:));
[CORR,RMSE,BIAS,MAE,NSE] 
[CORR,RMSE,BIAS,MAE,NSE] = fn_STAT(CPC_year(:),GPCP_year(:));
[CORR,RMSE,BIAS,MAE,NSE] 
[CORR,RMSE,BIAS,MAE,NSE] = fn_STAT(CPC_year(:),IMERG_YF(:));
[CORR,RMSE,BIAS,MAE,NSE] 
%%Mean annual zonal perecipitation
latmean_PCCSCDR = nanmean(PCCSCDR_year, 2);
latmean_PCDR = nanmean(PCDR_year, 2);
latmean_IMERGF = nanmean(IMERG_YF, 2);
latmean_PUnet = nanmean(PUnet_year, 2);
latmean_GPCP = nanmean(GPCP_year,2);


latitude = linspace(60, -60, 120);

% Plot the data
figure;
tiledlayout(1, 1, 'TileSpacing', 'none', 'Padding', 'none');
nexttile;
hold on;

plot(latmean_PCDR, latitude, 'DisplayName', 'PERSIANN-CDR', 'LineWidth', 2);
plot(latmean_PCCSCDR, latitude, 'DisplayName', 'PERSIANN-CCS-CDR', 'LineWidth', 2);
plot(latmean_IMERGF, latitude, 'DisplayName', 'IMERGF', 'LineWidth', 2);
plot(latmean_PUnet, latitude, 'DisplayName', 'PUnet-CDR', 'LineWidth', 2);
plot(latmean_GPCP, latitude, 'DisplayName', 'GPCP-1DD', 'LineWidth', 2,'Color','black');
hold off;
xlabel('Precipitation (mm)');
ylabel('Latitude');
%legend('show');
grid on;

%%Mean annual meridional perecipitation
lonmean_PCCSCDR = nanmean(PCCSCDR_year, 1);
lonmean_PCDR = nanmean(PCDR_year, 1);
lonmean_IMERGF = nanmean(IMERG_YF, 1);
lonmean_PUnet = nanmean(PUnet_year, 1);
lonmean_GPCP = nanmean(GPCP_year,1);

longitude = linspace(-180, 180, 360);

% Plot the data
figure( 'Position', [200, 200, 1600, 600]);
tiledlayout(1, 1, 'TileSpacing', 'none', 'Padding', 'none');
nexttile;
hold on;

plot(longitude,lonmean_PCDR, 'DisplayName', 'PERSIANN-CDR', 'LineWidth', 2);
plot(longitude,lonmean_PCCSCDR, 'DisplayName', 'PERSIANN-CCS-CDR', 'LineWidth', 2);
plot(longitude,lonmean_IMERGF,  'DisplayName', 'IMERGF', 'LineWidth', 2);
plot(longitude,lonmean_PUnet,  'DisplayName', 'PUnet-CDR', 'LineWidth', 2);
plot(longitude,lonmean_GPCP,  'DisplayName', 'GPCP-1DD', 'LineWidth', 2,'Color','black');

hold off;
xlabel('Longitude');
ylabel('Precipitation (mm)');
xlim([-180,180])
legend('Location', 'northoutside', 'Orientation', 'horizontal', 'FontSize', 14, 'LineWidth', 1.5, 'Box', 'off');
grid on;

%% Monthly evaluation
%%Create monthly rainfall 0.1 degree
Year_start=2022;
Year_end=2023;
N_years=Year_end-Year_start+1;
N_days=[];

for i=1:N_years
    n_days=[1*ones(31,1); 2*ones(28,1); 3*ones(31,1); 4*ones(30,1); 5*ones(31,1); 6*ones(30,1); 7*ones(31,1); 8*ones(31,1); 9*ones(30,1); 10*ones(31,1); 11*ones(30,1); 12*ones(31,1)];
    if mod((Year_start+i-1),4)==0
        n_days=[1*ones(31,1); 2*ones(29,1); 3*ones(31,1); 4*ones(30,1); 5*ones(31,1); 6*ones(30,1); 7*ones(31,1); 8*ones(31,1); 9*ones(30,1); 10*ones(31,1); 11*ones(30,1); 12*ones(31,1)];
    end
    N_days=[N_days; n_days];
end

n=length(N_days);

PCCSCDR_monthly=[];
PUnet_monthly=[];
IMERGF_monthly=[];
%GPCP_monthly=[];
PCDR_monthly=[];

temp1=N_days;
temp1(idx)=[];

for mon=1:12 
    mon
    PCDR_monthly(:,:,mon)=nansum(pcdr_daily_22_23(:,:,temp1==mon),3);
    PCCSCDR_monthly(:,:,mon)=nansum(PCCSCDR_daily(:,:,temp1==mon),3);
%     GPCP_monthly(:,:,mon)=nansum(GPCP_daily(:,:,temp1==mon),3);
    PUnet_monthly(:,:,mon)=nansum(PUnet_daily(:,:,temp1==mon),3);
    IMERGF_monthly(:,:,mon)=nansum(IMERG_DF(:,:,temp1==mon),3);
end


for i=1:12
    disp(i)
    [CORR_PCDR_m(i),RMSE_PCDR_m(i),BIAS_PCDR_m(i),MAE_PCDR_m(i),NSE_PCDR_m(i)] = fn_STAT(reshape(GPCP_monthly(:,:,i),1,[])',reshape(PCDR_monthly(:,:,i),1,[])');
    [CORR_PCCSCDR_m(i),RMSE_PCCSCDR_m(i),BIAS_PCCSCDR_m(i),MAE_PCCSCDR_m(i),NSE_PCCSCDR_m(i)] = fn_STAT(reshape(GPCP_monthly(:,:,i),1,[])',reshape(PCCSCDR_monthly(:,:,i),1,[])');
    [CORR_IMERGF_m(i),RMSE_IMERGF_m(i),BIAS_IMERGF_m(i),MAE_IMERGF_m(i),NSE_IMERGF_m(i)]  = fn_STAT(reshape(GPCP_monthly(:,:,i),1,[])',reshape(IMERGF_monthly(:,:,i),1,[])');
    [CORR_PUnet_m(i),RMSE_PUnet_m(i),BIAS_PUnet_m(i),MAE_PUnet_m(i),NSE_PUnet_m(i)]  = fn_STAT(reshape(GPCP_monthly(:,:,i),1,[])',reshape(PUnet_monthly(:,:,i),1,[])');

    PRECIP_PCDR_m(i) = nanmean(reshape(PCDR_monthly(:,:,i), 1, []));
    PRECIP_PCCSCDR_m(i) = nanmean(reshape(PCCSCDR_monthly(:,:,i), 1, []));
%     PRECIP_GPCP_m(i) = nanmean(reshape(GPCP_monthly(:,:,i), 1, []));
    PRECIP_PUnet_m(i) = nanmean(reshape(PUnet_monthly(:,:,i), 1, []));
    PRECIP_IMERGF_m(i) = nanmean(reshape(IMERGF_monthly(:,:,i), 1, []));
    
end

%% Daily evaluation

%%Continuous
CORR_PUnet=[];RMSE_PUnet=[];BIAS_PUnet=[];MAE_PUnet=[];
[n,m,t]=size(GPCP_daily);
delete(gcp('nocreate'))
parpool(10,'IdleTimeout',10000)
parfor i=1:n
    disp(i)
    for j=1:m
         [CORR_PCDR(i,j),RMSE_PCDR(i,j),BIAS_PCDR(i,j),MAE_PCDR(i,j),NSE_PCDR(i,j)] = fn_STAT(reshape(GPCP_daily(i,j,:),[1, t])',reshape(pcdr_daily_22_23(i,j,:),[1, t])');
         [CORR_PCCSCDR(i,j),RMSE_PCCSCDR(i,j),BIAS_PCCSCDR(i,j),MAE_PCCSCDR(i,j),NSE_PCCSCDR(i,j)] = fn_STAT(reshape(GPCP_daily(i,j,:),[1, t])',reshape(PCCSCDR_daily(i,j,:),[1, t])');
         [CORR_PUnet(i,j),RMSE_PUnet(i,j),BIAS_PUnet(i,j),MAE_PUnet(i,j),NSE_PUnet(i,j)] = fn_STAT(reshape(GPCP_daily(i,j,:),[1, t])',reshape(PUnet_daily(i,j,:),[1, t])');
         [CORR_IMERGF(i,j),RMSE_IMERGF(i,j),BIAS_IMERGF(i,j),MAE_IMERGF(i,j),NSE_IMERGF(i,j)] = fn_STAT(reshape(GPCP_daily(i,j,:),[1, t])',reshape(IMERG_DF(i,j,:),[1, t])');
        [CORR_CMORPH(i,j),RMSE_CMORPH(i,j),BIAS_CMORPH(i,j),MAE_CMORPH(i,j),NSE_CMORPH(i,j)] = fn_STAT(reshape(GPCP_daily(i,j,:),[1, t])',reshape(cmorph_daily(i,j,:),[1, t])');
    end
end
delete(gcp('nocreate'))

BIAS_PCDR(BIAS_PCDR==Inf)=NaN;
BIAS_PCCSCDR(BIAS_PCCSCDR==Inf)=NaN;
BIAS_IMERGF(BIAS_IMERGF==Inf)=NaN;
BIAS_PUnet(BIAS_PUnet==Inf)=NaN;

MAE_PCDR(MAE_PCDR>20)=NaN;
MAE_PCCSCDR(MAE_PCCSCDR>20)=NaN;
MAE_IMERGF(MAE_IMERGF>20)=NaN;
MAE_PUnet(MAE_PUnet>20)=NaN;

BIAS_CMORPH(BIAS_CMORPH==Inf)=NaN;
MAE_CMORPH(MAE_CMORPH>20)=NaN;

[nanmean(CORR_PCDR(:)),nanmean(RMSE_PCDR(:)),nanmean(BIAS_PCDR(:)),nanmean(MAE_PCDR(:))]
[nanmean(CORR_PCCSCDR(:)),nanmean(RMSE_PCCSCDR(:)),nanmean(BIAS_PCCSCDR(:)),nanmean(MAE_PCCSCDR(:))]
[nanmean(CORR_PUnet(:)),nanmean(RMSE_PUnet(:)),nanmean(BIAS_PUnet(:)),nanmean(MAE_PUnet(:))]
[nanmean(CORR_IMERGF(:)),nanmean(RMSE_IMERGF(:)),nanmean(BIAS_IMERGF(:)),nanmean(MAE_IMERGF(:))]
[nanmean(CORR_CMORPH(:)),nanmean(RMSE_CMORPH(:)),nanmean(BIAS_CMORPH(:)),nanmean(MAE_CMORPH(:))]

%%Continuous Land
[n,m,t]=size(CPC_daily);
delete(gcp('nocreate'))
parpool(10,'IdleTimeout',10000)
parfor i=1:n
    disp(i)
    for j=1:m
         [CORR_PCDR(i,j),RMSE_PCDR(i,j),BIAS_PCDR(i,j),MAE_PCDR(i,j),NSE_PCDR(i,j)] = fn_STAT(reshape(CPC_daily(i,j,:),[1, t])',reshape(pcdr_daily_22_23(i,j,:),[1, t])');
         [CORR_PCCSCDR(i,j),RMSE_PCCSCDR(i,j),BIAS_PCCSCDR(i,j),MAE_PCCSCDR(i,j),NSE_PCCSCDR(i,j)] = fn_STAT(reshape(CPC_daily(i,j,:),[1, t])',reshape(PCCSCDR_daily(i,j,:),[1, t])');
         [CORR_PUnet(i,j),RMSE_PUnet(i,j),BIAS_PUnet(i,j),MAE_PUnet(i,j),NSE_PUnet(i,j)] = fn_STAT(reshape(CPC_daily(i,j,:),[1, t])',reshape(PUnet_daily(i,j,:),[1, t])');
         [CORR_IMERGF(i,j),RMSE_IMERGF(i,j),BIAS_IMERGF(i,j),MAE_IMERGF(i,j),NSE_IMERGF(i,j)] = fn_STAT(reshape(CPC_daily(i,j,:),[1, t])',reshape(IMERG_DF(i,j,:),[1, t])');
    end
end
delete(gcp('nocreate'))

BIAS_PCDR(BIAS_PCDR==Inf)=NaN;
BIAS_PCCSCDR(BIAS_PCCSCDR==Inf)=NaN;
BIAS_IMERGF(BIAS_IMERGF==Inf)=NaN;
BIAS_PUnet(BIAS_PUnet==Inf)=NaN;

MAE_PCDR(MAE_PCDR>20)=NaN;
MAE_PCCSCDR(MAE_PCCSCDR>20)=NaN;
MAE_IMERGF(MAE_IMERGF>20)=NaN;
MAE_PUnet(MAE_PUnet>20)=NaN;

[nanmean(CORR_PCDR(:)),nanmean(RMSE_PCDR(:)),nanmean(BIAS_PCDR(:)),nanmean(MAE_PCDR(:))]
[nanmean(CORR_PCCSCDR(:)),nanmean(RMSE_PCCSCDR(:)),nanmean(BIAS_PCCSCDR(:)),nanmean(MAE_PCCSCDR(:))]
[nanmean(CORR_PUnet(:)),nanmean(RMSE_PUnet(:)),nanmean(BIAS_PUnet(:)),nanmean(MAE_PUnet(:))]
[nanmean(CORR_IMERGF(:)),nanmean(RMSE_IMERGF(:)),nanmean(BIAS_IMERGF(:)),nanmean(MAE_IMERGF(:))]

%%Category
threshold=0.1;

[POD_PCDR FAR_PCDR CSI_PCDR]=Categ_fn(pcdr_daily_22_23,GPCP_daily,threshold);
[POD_PCCSCDR FAR_PCCSCDR CSI_PCCSCDR]=Categ_fn(PCCSCDR_daily,GPCP_daily,threshold);
[POD_IMERGF FAR_IMERGF CSI_IMERGF]=Categ_fn(IMERG_DF,GPCP_daily,threshold);
[POD_PUnet FAR_PUnet CSI_PUnet]=Categ_fn(PUnet_daily,GPCP_daily,threshold);
[POD_CMORPH FAR_CMORPH CSI_CMORPH]=Categ_fn(cmorph_daily,GPCP_daily,threshold);

[nanmean(POD_PCDR(:)),nanmean(FAR_PCDR(:)),nanmean(CSI_PCDR(:))]
[nanmean(POD_PCCSCDR(:)),nanmean(FAR_PCCSCDR(:)),nanmean(CSI_PCCSCDR(:))]
[nanmean(POD_IMERGF(:)),nanmean(FAR_IMERGF(:)),nanmean(CSI_IMERGF(:))]
[nanmean(POD_PUnet(:)),nanmean(FAR_PUnet(:)),nanmean(CSI_PUnet(:))]
[nanmean(POD_CMORPH(:)),nanmean(FAR_CMORPH(:)),nanmean(CSI_CMORPH(:))]

%Plot
plot_global(CORR_PUnet, '');
plot_global_RMSE(RMSE_PUnet, 'RMSE');
plot_global_BIAS(BIAS_PCCSCDR, 'BIAS');

plot_global(POD_PCCSCDR, 'POD');
plot_global(FAR_PCCSCDR, 'FAR');
plot_global(CSI_PCCSCDR, 'CSI');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%CONUS%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

load '/zfs_data2/shared/ResearchSpace/PUnet/Matlab Code/IMERGF_daily_CONUS_22.mat'
load '/zfs_data2/shared/ResearchSpace/PUnet/Matlab Code/IMERGF_daily_CONUS_23.mat'

load '/zfs_data2/shared/ResearchSpace/PUnet/Matlab Code/ST4_daily_22.mat'
load '/zfs_data2/shared/ResearchSpace/PUnet/Matlab Code/ST4_daily_23.mat'

load punetcdr_daily_CONUS_22.mat
load punetcdr_daily_CONUS_23.mat

load pccscdr_daily_CONUS_22.mat
load pccscdr_daily_CONUS_23.mat

load gpcp_daily_CONUS_22.mat
load gpcp_daily_CONUS_23.mat

load pcdr_daily_CONUS_22_23.mat

load cmorph_daily_CONUS_22.mat
load cmorph_daily_CONUS_23.mat

%%%
IMERGF_daily_CONUS= cat(3, IMERGF_daily_CONUS_22, IMERGF_daily_CONUS_23);
IMERGF_daily_CONUS_22=[]; IMERGF_daily_CONUS_23=[];

ST4_daily= cat(3, ST4_daily_22, ST4_daily_23);
ST4_daily_22=[]; ST4_daily_23=[];

pcdr_daily_CONUS= pcdr_daily_CONUS_22_23;pcdr_daily_CONUS_22_23=[];

pccscdr_daily_CONUS= cat(3, pccscdr_daily_CONUS_22, pccscdr_daily_CONUS_23);
pccscdr_daily_CONUS_22=[]; pccscdr_daily_CONUS_23=[];

punetcdr_daily_CONUS= cat(3, punetcdr_daily_CONUS_22, punetcdr_daily_CONUS_23);
punetcdr_daily_CONUS_22=[]; punetcdr_daily_CONUS_23=[];

gpcp_daily_CONUS= cat(3, gpcp_daily_CONUS_22, gpcp_daily_CONUS_23);
gpcp_daily_CONUS_22=[]; gpcp_daily_CONUS_23=[];

cmorph_daily_CONUS= cat(3, cmorph_daily_CONUS_22, cmorph_daily_CONUS_23);
cmorph_daily_CONUS_22=[]; cmorph_daily_CONUS_23=[];

%%
%% Remove missing and bad data
s1= nanmean(punetcdr_daily_CONUS,[1 2]);
s2= nanmean(ST4_daily,[1 2]);
s1=s1(:);
s2=s2(:);
idx1 = find(isnan(s1) | s1 > 7.5);
idx2 = find(isnan(s2) | s2 == 0);
idx= [idx1; idx2];

punetcdr_daily_CONUS(:,:,idx)=[];
ST4_daily(:,:,idx)=[];
gpcp_daily_CONUS(:,:,idx)=[];
% IMERGF_daily_CONUS(:,:,idx)=[];
pccscdr_daily_CONUS(:,:,idx)=[];
pcdr_daily_CONUS(:,:,idx)=[];
cmorph_daily_CONUS(:,:,idx)=[];
%%
load mask_CONUS.mat

% dimension of CONUS images at 0.04 degree
n_row_conus=875; n_col_conus=1750;

% conus_mask=mask_CONUS(141:749,134:1577);
load conus_mask
load custom.mat
%load conus_mask_full
conus_mask(conus_mask<0)=nan; conus_mask=double(conus_mask);
conus_mask=single(conus_mask); 
%% Annual

ST4_year= nansum(ST4_daily,3)/2+conus_mask;
% IMERG_YF= nansum(IMERGF_daily_CONUS,3)/2+conus_mask;
PUnet_year= nansum(punetcdr_daily_CONUS,3)/2+conus_mask;
pccscdr_year= nansum(pccscdr_daily_CONUS,3)/2+conus_mask;
pcdr_year= nansum(pcdr_daily_CONUS,3)/2+conus_mask;
gpcp_year= nansum(gpcp_daily_CONUS,3)/2+conus_mask;
cmorph_year= nansum(cmorph_daily_CONUS,3)/2+conus_mask;

plot_CONUS_year(ST4_year, 'ST4',custom);
% plot_CONUS_year(IMERG_YF, 'IMERGF',custom);
plot_CONUS_year(PUnet_year, 'PUnet-CDR',custom);
plot_CONUS_year(pccscdr_year, 'PERSIANN-CCS-CDR',custom);
plot_CONUS_year(pcdr_year, 'PERSIANN-CDR',custom);
plot_CONUS_year(gpcp_year, 'GPCP-1DD',custom);
plot_CONUS_year(cmorph_year, 'CMORPH-CDR',custom);

[CORR,RMSE,BIAS,MAE,NSE] = fn_STAT(ST4_year(:),gpcp_year(:));
[CORR,RMSE,BIAS,MAE,NSE] 
[CORR,RMSE,BIAS,MAE,NSE] = fn_STAT(ST4_year(:),pcdr_year(:));
[CORR,RMSE,BIAS,MAE,NSE] 
[CORR,RMSE,BIAS,MAE,NSE] = fn_STAT(ST4_year(:),pccscdr_year(:));
[CORR,RMSE,BIAS,MAE,NSE] 
[CORR,RMSE,BIAS,MAE,NSE] = fn_STAT(ST4_year(:),PUnet_year(:));
[CORR,RMSE,BIAS,MAE,NSE] 
[CORR,RMSE,BIAS,MAE,NSE] = fn_STAT(ST4_year(:),cmorph_year(:));
[CORR,RMSE,BIAS,MAE,NSE] 

%%
%% Daily evaluation 0.1 degree
%%Continuous
[n,m,t]=size(ST4_daily); 
delete(gcp('nocreate'))
parpool(10,'IdleTimeout',10000)

parfor i=1:n
    disp(i);
    for j=1:m
         [CORR_pcdr(i,j),RMSE_pcdr(i,j),BIAS_pcdr(i,j),MAE_pcdr(i,j),NSE_pcdr(i,j)] = fn_STAT(reshape(ST4_daily(i,j,:),[1, t])',reshape(pcdr_daily_CONUS(i,j,:),[1, t])');
         [CORR_gpcp(i,j),RMSE_gpcp(i,j),BIAS_gpcp(i,j),MAE_gpcp(i,j),NSE_gpcp(i,j)] = fn_STAT(reshape(ST4_daily(i,j,:),[1, t])',reshape(gpcp_daily_CONUS(i,j,:),[1, t])');
         [CORR_PUnet(i,j),RMSE_PUnet(i,j),BIAS_PUnet(i,j),MAE_PUnet(i,j),NSE_PUnet(i,j)] = fn_STAT(reshape(ST4_daily(i,j,:),[1, t])',reshape(punetcdr_daily_CONUS(i,j,:),[1, t])');
         [CORR_CMORPH(i,j),RMSE_CMORPH(i,j),BIAS_CMORPH(i,j),MAE_CMORPH(i,j),NSE_CMORPH(i,j)] = fn_STAT(reshape(ST4_daily(i,j,:),[1, t])',reshape(cmorph_daily_CONUS(i,j,:),[1, t])');
         [CORR_pccscdr(i,j),RMSE_pccscdr(i,j),BIAS_pccscdr(i,j),MAE_pccscdr(i,j),NSE_pccscdr(i,j)] = fn_STAT(reshape(ST4_daily(i,j,:),[1, t])',reshape(pccscdr_daily_CONUS(i,j,:),[1, t])');
    end
end

BIAS_gpcp(BIAS_gpcp==Inf)=NaN;
BIAS_pcdr(BIAS_pcdr==Inf)=NaN;
BIAS_pccscdr(BIAS_pccscdr==Inf)=NaN;
% BIAS_IMERGF(BIAS_IMERGF==Inf)=NaN;
BIAS_PUnet(BIAS_PUnet==Inf)=NaN;
BIAS_CMORPH(BIAS_CMORPH==Inf)=NaN;

[nanmean(CORR_PUnet(:)),nanmean(RMSE_PUnet(:)),nanmean(BIAS_PUnet(:)),nanmean(MAE_PUnet(:))]
[nanmean(CORR_CMORPH(:)),nanmean(RMSE_CMORPH(:)),nanmean(BIAS_CMORPH(:)),nanmean(MAE_CMORPH(:))]

[nanmean(CORR_gpcp(:)),nanmean(RMSE_gpcp(:)),nanmean(BIAS_gpcp(:)),nanmean(MAE_gpcp(:))]
[nanmean(CORR_pcdr(:)),nanmean(RMSE_pcdr(:)),nanmean(BIAS_pcdr(:)),nanmean(MAE_pcdr(:))]
[nanmean(CORR_pccscdr(:)),nanmean(RMSE_pccscdr(:)),nanmean(BIAS_pccscdr(:)),nanmean(MAE_pccscdr(:))]

% [nanmean(CORR_IMERGF(:)),nanmean(RMSE_IMERGF(:)),nanmean(BIAS_IMERGF(:)),nanmean(MAE_IMERGF(:))]

%%Category
threshold=0.05;

[POD_gpcp FAR_gpcp CSI_gpcp]=Categ_fn(gpcp_daily_CONUS,ST4_daily,threshold);
[POD_pcdr FAR_pcdr CSI_pcdr]=Categ_fn(pcdr_daily_CONUS,ST4_daily,threshold);
[POD_pccscdr FAR_pccscdr CSI_pccscdr]=Categ_fn(pccscdr_daily_CONUS,ST4_daily,threshold);
[POD_PUnet FAR_PUnet CSI_PUnet]=Categ_fn(punetcdr_daily_CONUS,ST4_daily,threshold);
% [POD_IMERGF FAR_IMERGF CSI_IMERGF]=Categ_fn(IMERGF_daily_CONUS,ST4_daily,threshold);
[POD_CMORPH FAR_CMORPH CSI_CMORPH]=Categ_fn(cmorph_daily_CONUS,ST4_daily,threshold);

[nanmean(POD_gpcp(:)),nanmean(FAR_gpcp(:)),nanmean(CSI_gpcp(:))]
[nanmean(POD_pcdr(:)),nanmean(FAR_pcdr(:)),nanmean(CSI_pcdr(:))]
[nanmean(POD_pccscdr(:)),nanmean(FAR_pccscdr(:)),nanmean(CSI_pccscdr(:))]
[nanmean(POD_PUnet(:)),nanmean(FAR_PUnet(:)),nanmean(CSI_PUnet(:))]
% [nanmean(POD_IMERGF(:)),nanmean(FAR_IMERGF(:)),nanmean(CSI_IMERGF(:))]
[nanmean(POD_CMORPH(:)),nanmean(FAR_CMORPH(:)),nanmean(CSI_CMORPH(:))]

%% Extreme stats
[SDII R10mm R10mmTOT CDD CWD R95pTOT R99pTOT PRCPTOT]= fn_extreme_stats(cmorph_daily_CONUS);
R10mm=R10mm+conus_mask;
CDD=CDD+conus_mask;
CWD=CWD+conus_mask;
SDII=SDII+conus_mask;
R95pTOT=R95pTOT+conus_mask;
R99pTOT=R99pTOT+conus_mask;

tmp= nanmean(cat(3,SDII,CDD,CWD,R10mm,R95pTOT,R99pTOT),[1 2]);
tmp(:)'

plot_CONUS_SDII_fn(SDII,'ST4');
plot_CONUS_CDD_fn(CDD,'ST4');
plot_CONUS_CWD_fn(CWD,'ST4');

plot_CONUS_R10mm_fn(R10mm,'ST4');
plot_CONUS_R95pTOT_fn(R95pTOT,'ST4');
plot_CONUS_R99pTOT_fn(R99pTOT,'ST4');


%%%%%%%%%%%%%%%%%%%%%%%%% Monthly boxplot %%%%%%%%%%%%%%%%%%%%%%%%%%%
% ---- define time axis (adjust start date if needed)
t0 = datetime(2022,1,1);
time = t0 + days(0:729);

months = month(time);   % 1..12
years  = year(time);

figure('Color','w','Position',[100 100 1200 400]);

data_month = cell(12,1);

for m = 1:12
    tmp_all = [];

    for y = 2022:2023
        idx = (months == m) & (years == y);
        if ~any(idx), continue; end

        % monthly total at each grid cell (mm/month)
        mon_sum = sum(GPCP_daily(:,:,idx), 3, 'omitnan');

        % vectorize & (optional) filter tiny totals
        v = mon_sum(:);
        v = v(~isnan(v) & v > 0.1);   % threshold now in mm/month (adjust if desired)

        tmp_all = [tmp_all; v];
    end

    data_month{m} = tmp_all;
end

boxplot(cell2mat(data_month), ...
        repelem(1:12, cellfun(@numel,data_month)), ...
        'Notch','on');

set(gca,'YScale','log');
xticks(1:12);
xticklabels(month(datetime(2000,1:12,1),'shortname'));

ylabel('Monthly Precipitation (mm month^{-1})');
title('GPCP-1DD Monthly Climatology (Monthly totals, 2-year test)');
grid on;

%%%%%%

%% ===== Time axis =====
t0 = datetime(2022,1,1);
time = t0 + days(0:729);
mo = month(time);
yr = year(time);

%% ===== Products =====
Data  = { ...
    GPCP_daily, ...
    cmorph_daily, ...
    pcdr_daily_22_23, ...
    PCCSCDR_daily, ...
    PUnet_daily ...
    };

Names = { ...
    'GPCP-1DD', ...
    'CMORPH-CDR', ...
    'PERSIANN-CDR', ...
    'PERSIANN-CCS-CDR', ...
    'PUnet-CDR' ...
    };

nProd = numel(Data);
colors = lines(nProd);   % simple, clean color set

%% ===== Build monthly totals =====
pos = [];
val = [];
pid = [];

dx = linspace(-0.30, 0.30, nProd);  % offsets within each month

for m = 1:12
    for p = 1:nProd
        v_all = [];

        for y = min(yr):max(yr)
            idx = (mo == m) & (yr == y);
            if ~any(idx), continue; end

            % monthly total per grid cell (mm/month)
            mon_sum = sum(Data{p}(:,:,idx), 3, 'omitnan');
            v = mon_sum(:);
            v = v(~isnan(v));   % keep all valid values

            v_all = [v_all; v];
        end

        n = numel(v_all);
        pos = [pos; repmat(m + dx(p), n, 1)];
        val = [val; v_all];
        pid = [pid; repmat(p, n, 1)];
    end
end

%% ===== Plot =====
figure('Color','w','Position',[100 100 1200 450]);
hold on;

if exist('boxchart','file') == 2
    % Modern MATLAB (recommended)
    for p = 1:nProd
        sel = pid == p;
        boxchart(pos(sel), val(sel), ...
            'BoxFaceColor', colors(p,:), ...
            'BoxFaceAlpha', 0.12, ...
            'BoxWidth', 0.10, ...
            'MarkerStyle','none', ...
            'WhiskerLineColor', colors(p,:), ...
            'LineWidth',1.2);
    end
else
    % Fallback for older MATLAB
    boxplot(val, pid + 100*round(pos), 'Positions', pos, ...
            'Symbol','', 'Whisker',1.5);
end

xlim([0.5 12.5]);
ylim([0 400]);
xticks(1:12);
xticklabels(month(datetime(2000,1:12,1),'shortname'));

ylabel('Precipitation (mm month^{-1})');
title('Monthly Precipitation Climatology (2-year daily test)');
grid on;

legend(Names, 'Location','northwest');
set(gca,'FontSize',11);
