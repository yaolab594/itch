function [scr_up,scr_down] = getscrlength(loc_peak,loc_beak)

%使长度一致
if length(loc_peak)>length(loc_beak)
    loc_peak(length(loc_beak)+1:end)=[];
end
if length(loc_peak)<length(loc_beak)
    loc_beak(length(loc_peak)+1:end)=[];
end


if loc_peak(1)<loc_beak(1) %先出现了峰值
    scr_down = mean(loc_beak-loc_peak);
    scr_up = mean(loc_peak(2:end) -loc_beak(1:end-1));
end
if loc_beak(1)<loc_peak(1) %先出现谷值
    scr_down = mean(loc_beak(2:end)-loc_peak(1:end-1));
    scr_up = mean(loc_peak-loc_beak);
end


end