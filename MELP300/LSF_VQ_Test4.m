%上一超级帧最后一帧作为基准预测的残差 矢量量化 采用预测矩阵
clear all;
Error_All = 0;
% melp_init;
melp300_init;
global LSF_ResCB_31_s1 LSF_ResCB_31_s2 LSF_ResCB_31_s3 LSF_ResCB_31_s4;
load('./codebook/LSF_ResCB_31b.mat');
% load('./trainData/lsf_all.mat'); %lsf_all
% load('./trainData/lpc_all.mat'); %lpc_all
load('./data_org2.mat');
lsf_all = lsf_org;

b = [0.7918,0.6926,0.6938,0.7637,0.8064,0.7797,0.7677,0.7016,0.6774,0.6263;
0.6573,0.4403,0.4018,0.5280,0.5734,0.5757,0.5716,0.4977,0.4812,0.4058;
0.5685,0.2785,0.1912,0.3455,0.3947,0.4369,0.4389,0.3627,0.3510,0.2593;
0.5122,0.1726,0.0880,0.2350,0.2768,0.3415,0.3609,0.2849,0.3112,0.2000;
0.4888,0.1383,0.0528,0.1699,0.2075,0.2814,0.3204,0.2657,0.2999,0.1899;
0.4718,0.1350,0.0619,0.1524,0.1694,0.2469,0.2980,0.2608,0.2856,0.1915;
0.4803,0.1539,0.0860,0.1581,0.1446,0.2341,0.2968,0.2622,0.2815,0.1854;
0.4664,0.1483,0.0964,0.1638,0.1325,0.2195,0.2922,0.2682,0.2915,0.1889;];%帧间预测系数矩阵
frameSize = 8;%8帧
frameNum = size(lsf_all,1);
SD = zeros(frameNum,1);
count = 0;
superNum = fix(frameNum/frameSize);
lsfSuperPre = zeros(1, 10);%编码端上一超级帧最后一帧
lsfSuperPreRes = zeros(1, 10);%解码端上一超级帧最后一帧
for frameIdx = 1:superNum
    LSF = lsf_all(frameSize*frameIdx-7:frameSize*frameIdx,:);
%     lpcSuper = lpc_all(frameSize*frameIdx-7:frameSize*frameIdx,:);
    
    %去均值
    for i = 1:frameSize
        LSF(i,:) = LSF(i,:) - lsf_mean;
    end
    
    %残差
    lsf_res = zeros(frameSize, 10);
    for i = 1:frameSize
        lsf_res(i,:) = LSF(i,:) - b(i,:).*lsfSuperPre;
    end
    lsfSuperPre = LSF(frameSize,:);    
    
    %calculate weight
    
    weight = ones(1,80);
    
    %对残差进行矢量量化
    LSF_VQ_Data = zeros(1,80);
    for i=1:8
        LSF_VQ_Data((i-1)*10+1:i*10) = lsf_res(i,:);
    end   
    LSF_Q = LSF_4SVQ(LSF_VQ_Data, weight, LSF_ResCB_31_s1, LSF_ResCB_31_s2, LSF_ResCB_31_s3, LSF_ResCB_31_s4);
    LSF_d = MSVQ_d(LSF_ResCB_31_s1,LSF_Q(1),LSF_ResCB_31_s2,LSF_Q(2),LSF_ResCB_31_s3,LSF_Q(3),LSF_ResCB_31_s4,LSF_Q(4));
    
    LSF_decode = zeros(8,10);
    for i=1:8
        LSF_decode(i,:) = LSF_d((i-1)*10+1:i*10);
    end
    
    %恢复
    lsf_restor = zeros(frameSize, 10);
    for i = 1:frameSize
        lsf_restor(i,:) = b(i,:).*lsfSuperPreRes + LSF_decode(i,:);
    end
    lsfSuperPreRes = lsf_restor(frameSize,:);
    
    %加均值
    for i = 1:frameSize
        lsf_restor(i,:) = lsf_restor(i,:) + lsf_mean;
         LSF(i,:) = LSF(i,:) + lsf_mean;
    end
    for i = 1:frameSize
        for j=1:10
            if(lsf_restor(i,j)<=0) || (lsf_restor(i,j)>=4000)
                lsf_restor(i,j) = lsf_mean(j);
            end
        end
    end
    %计算谱失真
    for i = 1:8
        count = count+1;
        SD(count) = spectral_distortion(lsf_restor(i,:)*pi/4000,LSF(i,:)*pi/4000);
    end
    
end
disp(mean(SD));
hist(SD,100);
