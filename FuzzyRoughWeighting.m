function [W] = FuzzyRoughWeighting(X,gamma)

n=size(X,1);
corr=zeros(n);
nFeature= size(X,2);
Ra=zeros(nFeature,1);
maxi=zeros(nFeature,1);
mini=zeros(nFeature,1);


%%Down sampling Method
maxi=max(X);
mini=min(X);

for i=1:n
    for j=i+1:n
        for k=1:nFeature
            Ra(k)=R(gamma,X(i,k),X(j,k),maxi(k),mini(k));
        end
         corr(i,j)=min(Ra);
%          corr(i,j)=max(0,sum(Ra)-nFeature+1);
%          corr(j,i)=corr(i,j);
    end
end

d=mean(corr')'+0.0001;

W=diag(d);

end