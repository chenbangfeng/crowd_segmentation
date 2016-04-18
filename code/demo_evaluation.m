clc
clear
startup;
UCSDped2;

%load data files
disp('Load data');
options.segments_file='../data/output/motion_feats_conv5_th_0_ped2.mat';
options.gt_folder='../data/ucsd/UCSDped2/gt/';
load(options.segments_file);

%my options
options.shift=ceil(options.tracklet_len/2);
options.th_roc=500;

options.itrnum = 21;
options.ClipOfFrame = options.shift;
options.threshold_pixellevel = 0.39;


disp('Create grand truth annotation');
[ImgGrandtruth,TestVideoFile_new] = Create_GT_UCSD_Frame(options,TestVideoFile);

disp('Evaluation results..');
result = SegmentResultMatrix(all_CoAp,TestVideoFile_new,ImgGrandtruth,options);
TP1 = TruePositiveValue(result,all_CoAp,options);
[TPR,FPR,Roc1] = ROCValue(TP1,all_CoAp,options);

disp('Plot ROC');
plot(Roc1(:,2),Roc1(:,1),'-*')
grid on
xlabel('FPR'); ylabel('TPR')
title('ROC for classification by logistic regression')