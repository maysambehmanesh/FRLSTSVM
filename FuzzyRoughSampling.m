function [dataNegRed] = FuzzyRoughSampling(InputsNeg,gamma,tau)

nDataNeg=size(InputsNeg,1);
corr=zeros(nDataNeg);
nFeature= size(InputsNeg,2);
Ra=zeros(nFeature,1);
maxi=zeros(nFeature,1);
mini=zeros(nFeature,1);


%%Down sampling Method
maxi=max(InputsNeg);
mini=min(InputsNeg);

for i=1:nDataNeg
    for j=i+1:nDataNeg
        for k=1:nFeature
            Ra(k)=R(gamma,InputsNeg(i,k),InputsNeg(j,k),maxi(k),mini(k));
        end
         corr(i,j)=max(0,sum(Ra)-nFeature+1);
         corr(j,i)=corr(i,j);
    end
end



meanCorr=mean(corr)';

meanCorr=(1-max(meanCorr))+meanCorr;  % Normalize

selectIndex=(meanCorr>=tau);
dataNegRed=InputsNeg(selectIndex,:);


end