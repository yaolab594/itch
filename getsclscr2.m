function [scl,p1, scr,scr_acm] = getsclscr2(data)



y = smoothdata(data,'movmean',5);
% y = lowpass(data,0.1,1,'Steepness',0.85,'StopbandAttenuation',60);

x = (1:length(y))';
% 谷值内插
[val_beak,loc_beak] = findpeaks(-y);
val_beak = -val_beak;
x = loc_beak(2):(loc_beak(end-1)-loc_beak(2))+1;
scl = interp1(loc_beak(2:end-1),val_beak(2:end-1),x,'spline')';

scr = y(x)-scl;

for j = 1:length(scr)
    scr_acm(j) = sum(scr(1:j)) ;
end

[xData, yData] = prepareCurveData( x', scl );

% 设置 fittype 和选项。
ft = fittype( 'poly1' );

% 对数据进行模型拟合。
[fitresult, gof] = fit( xData, yData, ft );
p1 =  fitresult.p1;