clc;
clear;
close all;

%% load dataset

allFiles = dir('dataset\');
datasetName = {allFiles.name};

[s,v] = listdlg('PromptString','Select a Dataset:',...
                'SelectionMode','single',...
                'ListString',datasetName);    

path=char(strcat('dataset\',datasetName(s)));

load(path);
data=dataset;

nData=size(data,1);

%% parameters
gamma=0.6;  % the granularity parameter
tau=0.25;   % selection threshold

delta=1e-6;

%%
i=randperm(nData);
data=data(i,:);

x=data(:,1:end-1);
y=data(:,end);

%% k-fold cross-validation 
k=10;
indices = crossvalind('Kfold',nData,k);
TestOutput=zeros(2,k);

for i = 1:k

    TestData=data((indices == i),:);
    TrainData = data((indices ~= i),:);
    
    TrainDataPosIndex=find(TrainData(:,end)==1);
    TrainDataNegIndex=find(TrainData(:,end)==-1);
    TestDataPosIndex=find(TestData(:,end)==1);
    TestDataNegIndex=find(TestData(:,end)==-1);
    
    TrainDataClassPos=TrainData(TrainDataPosIndex,:);
    TrainDataClassNeg=TrainData(TrainDataNegIndex,:);
    TestDataClassPos=TestData(TestDataPosIndex,:);
    TestDataClassNeg=TestData(TestDataNegIndex,:);
    
    X1=TrainDataClassPos(:,(1:end-1));          %TrainInputs+
    X1Targets=TrainDataClassPos(:,(end));    	%TrainTargets+
    
    X2=TrainDataClassNeg(:,(1:end-1));          %TrainInputs-
    X2Targets=TrainDataClassNeg(:,(end));       %TrainTargets-
    
    X1Test=TestDataClassPos(:,(1:end-1));
    X1TestTargets=TestDataClassPos(:,(end));
    
    X2Test=TestDataClassNeg(:,(1:end-1));
    X2TestTargets=TestDataClassNeg(:,(end));
    
    m=size(X1,1);
    n=size(X2,1);
    
    
    %% Divide Train and Test
    D=[X1;X2]';
    DTargets=[X1Targets;X2Targets]';
    
    XTest=[X1Test;X2Test];
    XTestTargets=[X1TestTargets;X2TestTargets];
    
    
    %% Undersampling Rough 
    
    X2temp=X2;
    X2=FuzzyRoughSampling(X2,gamma,tau);    % under sampling for Neg. samples
    
    %% Weightd Rough
    W1=FuzzyRoughWeighting(X1,2);
    W2=FuzzyRoughWeighting(X2,2);
    
    
    %% Parameter SVM
    C1=20;
    C2=10;
    e1=ones(size(X1,1),1);
    e2=ones(size(X2,1),1);
    delta=0.001;
    
    %% Design SVM
    H=[X1 e1];
    G=[X2 e2];
    
   
    alpha=inv(inv(W2)/C1+G*inv(H'*H+delta*eye(size(H'*H,1)))*G')*e2;
    beta=inv(inv(W1)/C2+H*inv(G'*G+delta*eye(size(G'*G,1)))*H')*e1;
    
    u1=-inv(H'*H+delta*eye(size(H,2)))*G'*alpha;
    u2=-inv(G'*G+delta*eye(size(G,2)))*H'*beta;
    
    % computing w1,w2,b1,b2
    w1=u1(1:(length(u1)-1));
    b1=u1(length(u1));
    w2=u2(1:(length(u2)-1));
    b2=u2(length(u2));
    
    % predict process
    l=size(XTest,1);
    H=XTest;
    w11=sqrt(w1'*w1);
    w22=sqrt(w2'*w2);
    y1=H*w1+b1*ones(l,1);
    y2=H*w2+b2*ones(l,1);
    
    mp1=y1/w11;
    mn2=y2/w22;
    TestOutputs = sign(abs(mn2)-abs(mp1));
    
    TestOutput(1,i) = sum(TestOutputs == XTestTargets)/length(XTestTargets);
    TestOutput(2,i)=Gmean(TestOutputs,XTestTargets);
end

%% Show results
disp(['Number of majority data=',num2str(size(X2,1))]);
disp(['Average Accuracy=',num2str(mean(TestOutput(1,:))*100),'  std=',num2str(std(TestOutput(1,:)))]);
disp(['Average G-mean=',num2str(mean(TestOutput(2,:))*100),'  std=',num2str(std(TestOutput(2,:)))]);



