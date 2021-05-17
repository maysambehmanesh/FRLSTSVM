function output=Gmean(TestOutput,TestTarget)

tt=[TestTarget,TestOutput];
A=tt(find(tt(:,1)==1),:);

TP=size(find(A(:,2)==1),1);
FN=size(find(A(:,2)==-1),1);


B=tt(find(tt(:,1)==-1),:);

FP=size(find(B(:,2)==1),1);
TN=size(find(B(:,2)==-1),1);

sen=TP/(TP+FP);
spe=TN/(TN+FN);

output=sqrt(sen*spe);

end
