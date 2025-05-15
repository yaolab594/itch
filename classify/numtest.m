clear

load('dataNRSbtrain.mat')

for k=1:10

    m=1;
for i =0.2:0.05:0.8

[idxTrain,idxValidation,idxTest] = trainingPartition(height(x),[(i) 0.1 (0.9-i)]);

XTrain = x(idxTrain,:);
TTrain = y(idxTrain);

XValidation = x(idxValidation,:);
TValidation = y(idxValidation);

XTest = x(idxTest,:);
TTest = y(idxTest);

XValidation = x([idxValidation,idxTest],:);
TValidation = y([idxValidation,idxTest]);
 
[trainedClassifier, validationAccuracy] = vasbtrain(XTrain,TTrain);

inpredict = trainedClassifier.predictFcn(table2array(XTrain));

outpredict = trainedClassifier.predictFcn(table2array(XValidation));
outacc(m,k) = length(find(outpredict==TValidation))/length(TValidation);

acc(m,k) = validationAccuracy;

m=m+1;
end

end



% roc

for i=1:10
[idxTrain,idxValidation,idxTest] = trainingPartition(height(x),[0.8 0.1 0.1]);
XTrain = x(idxTrain,:);
TTrain = y(idxTrain);

XValidation = x([idxValidation,idxTest],:);
TValidation = y([idxValidation,idxTest]);

[trainedClassifier, validationAccuracy] = vasbtrain(XTrain,TTrain);
[~,Scores] = predict(trainedClassifier.ClassificationEnsemble,XValidation);

ROC= rocmetrics(TValidation,Scores,[0,1,2]) ;
auc(i,:)= ROC.AUC;
% plot(ROC)
end

ci1 = bootci(100, {@mean, auc(:,1)}, 'alpha', 0.05);
ci2 = bootci(100, {@mean, auc(:,2)}, 'alpha', 0.05);
ci3 = bootci(100, {@mean, auc(:,3)}, 'alpha', 0.05);