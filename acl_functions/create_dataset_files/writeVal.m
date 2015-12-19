function writeVal(directory)

if nargin < 1
    directory = 'datasets/custom_dataset/images';
end

extension = 'JPEG';
files = dir(directory);
num_images = numel(files);

first_line_break = false;
fileID = fopen([directory, '/val.txt'], 'w');
counter = 0;
for i = 1:num_images
    strs = strsplit(files(i).name,'.');
    % find all valid images
    if numel(strs) == 2 && strcmp(strs(2), extension)==true
        % see if it is a flip image
        sub_strs = strsplit(strs{1}, '_');
        if strcmp(sub_strs{end}, 'flip') == true
            continue;
        end
        if first_line_break == false
            fprintf(fileID, strs{1});
            first_line_break = true;
        else
            fprintf(fileID, sprintf('\n%s',strs{1}));
        end
        if mod(counter, 1000) == 0
            fprintf(sprintf('processing %d images\n', counter));
        end
        counter = counter + 1; 
    end
end
fprintf(sprintf('write %d images to val.txt\n', counter));
fclose(fileID);
end