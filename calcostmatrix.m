function [cost_matrix] = calcostmatrix(classdata)

classes = unique (classdata);
num_classes = length(classes);
for i =1:num_classes
    class_lengths(i) = length(find(classdata==classes(i))); % 
end


% 类别i的误分类代价是类别i样本数量占j类的比例
cost_matrix = zeros(num_classes, num_classes);

for i = 1:num_classes
    for j = 1:num_classes
        if i == j
            % 正确分类的代价设为0
            cost_matrix(i, j) = 0;
        else
           
            cost_matrix(i, j) = (class_lengths(j) / class_lengths(i));
        end
    end
end

end