clc
close all

% import class_labels
class_num = importdata('class_labels');

% import class_labels_num2str
class_num2str = importdata('class_labels_num2str');
num_categories = numel(class_num2str);
class_num_match = cell(num_categories, 1);
class_str_match = cell(num_categories, 1);
for i = 1:numel(class_num2str)
    c = strsplit(class_num2str{i}, ' ');
    class_num_match(i) = c(1);
    class_str_match{i} = strjoin(c(2:end), '-');
end

% match with class labels
class_str = cell(num_categories, 1);
for i = 1:num_categories
    for j = 1:num_categories
       if class_num{i} == class_num_match{j}
           class_str{i} = class_str_match{j};
           break;
       end
        
    end   
end


% create class_labels_str
fileID = fopen('class_labels_str','w');
for i = 1:num_categories
    fprintf(fileID, sprintf('%s%s', class_str{i}, '\n'));
end
fclose(fileID);
