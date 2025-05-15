clc
clear
allData = {};alllength=0;
path = 'C:\Users\11601\Desktop\瘙痒\所有excel同步20240831\';
File = dir(fullfile(path,'*.csv'));  % 显示文件夹下所有符合后缀名为.csv文件的完整信息
Score = importfileScore('C:\Users\11601\Desktop\瘙痒\瘙痒评分20240831.xlsx');
numData=[];
eda_Figure={}; minlength=[];
for i = 1:length(File)
    listfile=File(i).name;
    a = importfile(strcat(path,listfile));
    datanow = a(find(a<10000));
    alllength=length(datanow)+alllength;

    allData{i,1} = datanow;
    allData{i,2} = listfile;


    % feature
    [scl,scr,scl_p1,scl_p2,scl_p3,scl_p4] =  getsclscr(datanow); % 三次拟合


    scr_acm=[];scl=[];scr=[];
    [scl,scl_p1, scr,scr_acm] =  getsclscr2(datanow);    % 谷值插值



    eda_Figure{i,1} = ([scl(1:end-1),diff(scl),scr(1:end-1),scr_acm(1:end-1)']);

    minlength(i) =length(diff(scl));

    scl_cv = std(scl)./mean(scl);
    scl_ave = mean(scl);

    [val_peak,loc_peak] = findpeaks(scr);
    [val_beak,loc_beak] = findpeaks(-scr);
    val_beak = -val_beak;
    scr_amp = mean(val_peak)-mean(val_beak);
    scr_intval = mean(diff(loc_peak));
    [scr_up,scr_down] = getscrlength(loc_peak,loc_beak);

    allData{i,4}= scl_ave;
    allData{i,5}= scl_cv;
    allData{i,6}= scl_p1;
    allData{i,7}= scl_p2;
    allData{i,8}= scl_p3;
    allData{i,9}= scl_p4;
    allData{i,10}= scr_amp;
    allData{i,11}= scr_intval;
    allData{i,12}= scr_up;
    allData{i,13}= scr_down;

    % allData{i,4}= scl_ave;
    % allData{i,5}= scl_cv;
    % allData{i,6}= scl_p1;
    %
    % allData{i,7}= scr_amp;
    % allData{i,8}= scr_intval;
    % allData{i,9}= scr_up;
    % allData{i,10}= scr_down;


    k(i) = 0;
    if length(strfind(listfile,'腘'))~=0
        if length(strfind(listfile,'0-患'))~=0
            k(i) = 4; %% 正常

        else
            k(i) = 4;  %%皮损
        end
    elseif length(strfind(listfile,'背'))~= 0
        if length(strfind(listfile,'0-患'))~=0
            k(i) = 3; %% 正常

        else
            k(i) = 3;  %%皮损
        end
    elseif length(strfind(listfile,'面'))~= 0
        if length(strfind(listfile,'0-患'))~=0
            k(i) = 1; %% 正常

        else
            k(i) = 1;  %%皮损
        end

    elseif length(strfind(listfile,'肘'))~=0
        if length(strfind(listfile,'0-患'))~=0
            k(i) = 2; %% 正常

        else
            k(i) = 2;  %%皮损
        end
    end

    allData{i,3} = k(i);

    %匹配编号
    str = strsplit(listfile,'-');
    tag = str{2};
    tag(1:4)=[];
    tag = str2num(tag);

    feture_num = 10;
    numData(i,1:feture_num) = squeeze([allData{i,4:4+feture_num-1}]);
    numData(i,feture_num+1:13+feture_num) =table2array(Score(find(table2array(Score(:,2))==tag),4:end));
    numData(i,14+feture_num) = k(i);

end


%%  numData 十个特征 年龄	身高	体重  bmi	所患疾病（0为健康，1为银屑病，2为特应性皮炎，3为点滴型银屑病，4为其他） 16NRS级	VAS级	CDLQI级	PSQI级	NRS评分 VAR分 CDLQI评分 PSQI评分  位置分类标签
clearvars -except numData feture_num eda_Figure
[x,y] = find(isnan(numData)==1); %异常数据清除
numData(x,:)=[];




numData_heal=numData(find(numData(:,feture_num+5)==0),:);
numData_ad=numData(find(numData(:,feture_num+5)==2),:);
numData_pso=numData(find(numData(:,feture_num+5)==1),:);

feature = [numData_heal(:,1:feture_num+5),numData_heal(:,end);numData_ad(:,1:feture_num+5),numData_ad(:,end);numData_pso(:,1:feture_num+5),numData_pso(:,end)];

feature_label=[feature,[numData_heal(:,feture_num+9);numData_ad(:,feture_num+9);numData_pso(:,feture_num+9)]];

for i=1:length(feature_label)
    if feature_label(i,end)==3
        feature_label(i,end)=2;
    end
end

feture_num = 10;


%% 相关性
% for k =1:4
%     for i =1:14
% 
%         hcorrk(i,k) = corr(numData_heal(:,i),numData_heal(:,k+15),'Type','Kendall');
%         hcorrs(i,k) = corr(numData_heal(:,i),numData_heal(:,k+15),'Type','Spearman');
% 
%         adcorrk(i,k) = corr(numData_ad(:,i),numData_ad(:,k+15),'Type','Kendall');
%         adcorrs(i,k) = corr(numData_ad(:,i),numData_ad(:,k+15),'Type','Spearman');
% 
%         psocorrk(i,k) = corr(numData_pso(:,i),numData_pso(:,k+15),'Type','Kendall');
%         psocorrs(i,k) = corr(numData_pso(:,i),numData_pso(:,k+15),'Type','Spearman');
% 
%         corrp(i,k) = corr(numData(:,i),numData(:,k+15),'Type','Pearson');
%         corrk(i,k)=corr(numData(:,i),numData(:,k+15),'Type','Kendall');
%         corrs(i,k)=corr(numData(:,i),numData(:,k+15),'Type','Spearman');
% 
%     end
% end
% feature_regress =[feature,[numData_heal(:,feture_num+9);numData_ad(:,feture_num+9);numData_pso(:,feture_num+9)]];

%% 显著性检验
%疾病检验
for i =1:13
    % pks(i,1) = kstest(numData_heal(:,i));
    % pks(i,2) = kstest(numData_ad(:,i));
    % pks(i,3) = kstest(numData_pso(:,i));

     [p0,h0] = kruskalwallis([(numData_heal(:,i));(numData_ad(:,i))],[ones(length(numData_heal(:,i)),1);ones(length(numData_ad(:,i)),1)+1]);
     [p1,h0] = kruskalwallis([numData_heal(:,i);numData_pso(:,i)],[ones(length(numData_heal(:,i)),1);ones(length(numData_pso(:,i)),1)+2]);
     [p2,h0] = kruskalwallis([numData_ad(:,i);numData_pso(:,i)],[ones(length(numData_ad(:,i)),1)+1;ones(length(numData_pso(:,i)),1)+2]);
     [p3,h0] = kruskalwallis([numData_heal(:,i);numData_ad(:,i);numData_pso(:,i)],[ones(length(numData_heal(:,i)),1);ones(length(numData_ad(:,i)),1)+1;ones(length(numData_pso(:,i)),1)+2]);

     p(i,1)=p0;
     p(i,2)=p1;
     p(i,3)=p2;
     p(i,4)=p3;
end
close all
%
% % 区域检验
load('featurefromlocation.mat')
%分病情计算p
bh = back(find(back(:,14)==0),:);
ba = back(find(back(:,14)==2),:);
bp = back([find(back(:,14)==1);find(back(:,14)==3)],:);

gh = guo(find(guo(:,14)==0),:);
ga = guo(find(guo(:,14)==2),:);
gp = guo([find(guo(:,14)==1);find(guo(:,14)==3)],:);

fh = face(find(face(:,14)==0),:);
fa = face(find(face(:,14)==2),:);
fp = face([find(face(:,14)==1);find(face(:,14)==3)],:);

zh = zhou(find(zhou(:,14)==0),:);
za = zhou(find(zhou(:,14)==2),:);
zp = zhou([find(zhou(:,14)==1);find(zhou(:,14)==3)],:);

face = fp;
guo = gp;
zhou = zp;
back =bp;

for i =1:10
    %正态检验
    pks(i,1) = kstest(face(:,i));
    pks(i,2) = kstest(guo(:,i));
    pks(i,3) = kstest(zhou(:,i));
    pks(i,4) = kstest(back(:,i));

     [p0,h0] = kruskalwallis([face(:,i);guo(:,i)],[ones(length(face(:,i)),1);ones(length(guo(:,i)),1)+1]);
     [p1,h0] = kruskalwallis([face(:,i);zhou(:,i)],[ones(length(face(:,i)),1);ones(length(zhou(:,i)),1)+2]);
     [p2,h0] = kruskalwallis([face(:,i);back(:,i)],[ones(length(face(:,i)),1)+1;ones(length(back(:,i)),1)+2]);
     [p3,h0] = kruskalwallis([guo(:,i);zhou(:,i)],[ones(length(guo(:,i)),1)+1;ones(length(zhou(:,i)),1)+2]);
     [p4,h0] = kruskalwallis([guo(:,i);back(:,i)],[ones(length(guo(:,i)),1)+1;ones(length(back(:,i)),1)+2]);
     [p5,h0] = kruskalwallis([zhou(:,i);back(:,i)],[ones(length(zhou(:,i)),1)+1;ones(length(back(:,i)),1)+2]);
close all

     p(i,1)=p0;
     p(i,2)=p1;
     p(i,3)=p2;
     p(i,4)=p3;
     p(i,5)=p4;
     p(i,6)=p5;

end
heatmap(p);


% 对应区域疾病检验
for i =1:10

     [p0,h0] = kruskalwallis([bh(:,i);ba(:,i);bp(:,i)],[ones(length(bh(:,i)),1);ones(length(ba(:,i)),1)+1;ones(length(bp(:,i)),1)+2]);
     [p1,h0] = kruskalwallis([gh(:,i);ga(:,i);gp(:,i)],[ones(length(gh(:,i)),1);ones(length(ga(:,i)),1)+1;ones(length(gp(:,i)),1)+2]);
     [p2,h0] = kruskalwallis([fh(:,i);fa(:,i);fp(:,i)],[ones(length(fh(:,i)),1);ones(length(fa(:,i)),1)+1;ones(length(fp(:,i)),1)+2]);
     [p3,h0] = kruskalwallis([zh(:,i);za(:,i);zp(:,i)],[ones(length(zh(:,i)),1);ones(length(za(:,i)),1)+1;ones(length(zp(:,i)),1)+2]);



close all

     p(i,1)=p0;
     p(i,2)=p1;
     p(i,3)=p2;
     p(i,4)=p3;


end

strlabel= string(numData(:,14));
strlabel(find(numData(:,14)==0)) = 'Health';
strlabel(find(numData(:,14)==2)) = 'AD';
strlabel(find(numData(:,14)==1)) = 'PSO';
strlabel(find(numData(:,14)==3)) = 'PSO';


%% shap incomplete
clc
columnNames = {'SCLmean', 'SCLcv', 'p1','p2', 'p3', 'p4','SCRamp', 'SCRintval', 'SCRup','SCRdowm', 'age', 'height','weight', 'disease','location'};
columnNames = {'column_1', 'column_2', 'column_3','column_4', 'column_5', 'column_6','column_7', 'column_8', 'column_9','column_10', 'column_11', 'column_14','column_15', 'column_16'};

feature(:,12:13)=[];
T = array2table(feature, 'VariableNames',columnNames);

explainer = shapley(trainedModel.ClassificationEnsemble,T,QueryPoints=T);
swarmchart(explainer,"NumImportantPredictors",14)
plot(explainer,"NumImportantPredictors",14);


parfor i =1:length(feature)
    explainer = shapley(trainedModel.ClassificationEnsemble,'QueryPoint',feature(i,:))
    t1 = explainer.ShapleyValues;
    shapv  = table2array(t1(:,2:end));
    [v,indx] = max(sum(shapv));
    [B,I] = sort(shapv(:,indx));
    [~,II] = sort(I);
    shapfreq(:,i)=II;  %行号代表了特征原顺序，内容表示了重要程度排序，越高越好

end
shapfreq=shapfreq';
feature_important = mean(shapfreq);



feature_local = [[numData_heal(:,feture_num+15);numData_ad(:,feture_num+15);numData_pso(:,feture_num+15)]];

% %按12345678分类
% imp_facial =mean(shapfreq([find(feature_local==1);find(feature_local==2)],:));
% imp_poplit =mean(shapfreq([find(feature_local==3);find(feature_local==4)],:));
% imp_cubit =mean(shapfreq([find(feature_local==5);find(feature_local==6)],:));
% imp_back =mean(shapfreq([find(feature_local==7);find(feature_local==8)],:));

%按1234分类
imp_facial =mean(shapfreq(find(feature_local==1),:));
imp_poplit =mean(shapfreq(find(feature_local==2),:));
imp_cubit =mean(shapfreq(find(feature_local==3),:));
imp_back =mean(shapfreq(find(feature_local==4),:));
figure
bar([imp_facial',imp_poplit',imp_cubit',imp_back'],"stacked")
feature_ele = [imp_facial(1:feture_num);imp_poplit(1:feture_num);imp_cubit(1:feture_num);imp_back(1:feture_num)];
imp_ele = sum(feature_ele');

[B,I] = sort(imp_facial);
[~,II_F] = sort(I);
[B,I] = sort(imp_poplit);
[~,II_P] = sort(I);
[B,I] = sort(imp_cubit);
[~,II_C] = sort(I);
[B,I] = sort(imp_facial);
[~,II_B] = sort(imp_back);
% plot(explainer)
bar([II_F',II_P',II_C',II_B'],"stacked")
legend("facial","poplit","cubit","back")

feature_ele = [II_F(1:feture_num);II_P(1:feture_num);II_C(1:feture_num);II_B(1:feture_num)];
imp_ele = sum(feature_ele');

%% 误分类代价计算
cost_matrix = calcostmatrix(numData(:,feture_num+5));












