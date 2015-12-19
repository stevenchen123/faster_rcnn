% script file that copies images and bbx of specific classes in 
% imagenet 2013 training data into an output directory

classes = [2;32;35;53;54;56;72;73;79;80;87;89;...
                     91; 95; 97; 114; 150; 171; 182; 188];   
% classes = [32];
max_img_per_class = 1000;

imagenet_directory = 'datasets/ImageNetData';
output_directory = 'datasets/custom_dataset'; 

imagenet_bboxes_folder = '/ILSVRC2014_DET_bbox';
imagenet_images_folder = '/ILSVRC2014_DET_train';

output_bboxes_folder = '/single_class_bboxes';
output_images_folder = '/single_class_images';
                           
classes_label = importdata('datasets/ImageNetData/class_labels');
classes_label_str = importdata('datasets/ImageNetData/class_labels_str');
total_counter = 0;
for i = 1:length(classes)
    single_class_folder = classes_label{classes(i)};
    % unzip folder
    img_dir = [imagenet_directory, imagenet_images_folder, '/', single_class_folder];
    bbx_dir = [imagenet_directory, imagenet_bboxes_folder, '/', single_class_folder];

    assert(exist([img_dir, '.tar'])~=0);
    if exist(img_dir) ~= 7
        untar([img_dir, '.tar'], img_dir);
    end

    assert(exist([bbx_dir, '.tar.gz'])~=0);
    if exist(bbx_dir) ~= 7
        untar([bbx_dir, '.tar.gz'], bbx_dir);
    end
    
    % hack, just imagenet's data organization
    img_dir_tmp = [img_dir, '/',  single_class_folder];
    bbx_dir_tmp = [bbx_dir, '/', 'Annotation', '/', single_class_folder];
    
    % img_dir_tmp
    files = dir(img_dir_tmp);
    num_images = numel(files);
    counter = 0;
    for j = 1:num_images
        strs = strsplit(files(j).name,'.');
            % find all valid images and copy into target directories
            % strs
            if numel(strs) == 2 && strcmp(strs{2}, 'JPEG')==true
                img_file = [img_dir_tmp,'/',strs{1},'.JPEG'];
                bbx_file = [bbx_dir_tmp,'/',strs{1},'.xml'];
                % fprintf(sprintf('j: %d, exist img_file: %d, exist bbx_file %d\n', j, exist(img_file), exist(bbx_file)));
                if exist(img_file) && exist(bbx_file)
                    copyfile(img_file, [output_directory, output_images_folder, '/',strs{1},'.JPEG']);
                    copyfile(bbx_file, [output_directory, output_bboxes_folder,'/',strs{1},'.xml']);
                    counter = counter + 1;
                end
            end
            
            if counter >= max_img_per_class
                break;
            end
    end
    total_counter = total_counter + counter;
    fprintf(sprintf('class: %s, class_num: %s, copied %d images out of %d \n', classes_label_str{classes(i)}, classes_label{classes(i)}, counter, num_images-2));
    
    % remove directories
    rmdir(img_dir, 's');
    rmdir(bbx_dir, 's');
        
end

fprintf(sprintf('copied %d files in total\n', total_counter));