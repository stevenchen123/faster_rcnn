function voc2Imagenet(imdb, roidb, directory)
if nargin < 3
    directory = 'datasets/custom_dataset';
end
% for each picture in imdb, 
%   write image to directory.images
%   write roidb to directory.bboxes
dst_extension = '.JPEG';
[~, num_img] = size(roidb.rois);
im_dir = fullfile(imdb.image_dir) ;

assert(imdb.num_classes == 20);

% voc classes 2 imagenet labels
classes = {};
classes{1,1} = 'n02691156'; %'aeroplane';
classes{2,1} = 'n02834778'; %'bicycle';
classes{3,1} = 'n01503061'; %'bird';
classes{4,1} = 'empty';         %'boat' ---> class not in ImageNet 
classes{5,1} = 'empty';         %'bottle'---> class split into water bottle 
                            %             and wine bottle in ImageNet
classes{6,1} = 'n02924116'; %'bus';
classes{7,1} = 'n02958343'; %'car';
classes{8,1} = 'n02121808'; %'cat';
classes{9,1} = 'n03001627'; %'chair';
classes{10,1} = 'n02402425'; %'cow';
classes{11,1} = 'n04379243'; %'diningtable';
classes{12,1} = 'n02084071'; %'dog';
classes{13,1} = 'n02374451'; %'horse';
classes{14,1} = 'n03790512'; %'motorbike';
classes{15,1} = 'n00007846'; %'person';
classes{16,1} = 'n03991062'; %'pottedplant';
classes{17,1} = 'n02411705'; %'sheep';
classes{18,1} = 'n04256520'; %'sofa';
classes{19,1} = 'n04468005'; %'train';
classes{20,1} = 'n03211117'; %'tvmonitor';





counter = 0;
%for i = 1:min(5,num_img)
for i = 1:num_img
    % do not include non-fliped images
    if imdb.flip_from(i) ~= 0
        continue;
    end
    % load image
    fprintf(sprintf('processing %d \t at: %s\n', i, imdb.image_at(i)));
    im = imread (fullfile(im_dir, [imdb.image_ids{i}, ['.', imdb.extension]]));

    % save images
    imwrite(im, [directory, '/images/', [imdb.image_ids{i}, dst_extension]]);
    
    % save bboxes xml files
    write2xml(directory, imdb.image_ids{i}, imdb.name, imdb.sizes(i,2), imdb.sizes(i,1), ...
        classes, roidb.rois(i).boxes, roidb.rois(i).class);
    
    counter = counter + 1;
end

fprintf(sprintf('write %d images to files', counter));


end



function write2xml(directory, filename, database, width, height, classes_all, boxes, classes)
fileID = fopen([directory, '/bboxes/', filename, '.xml'],'w');
fprintf(fileID, sprintf('<annotation>\n'));
fprintf(fileID, sprintf('\t<folder>images</folder>\n'));
fprintf(fileID, sprintf('\t<filename>%s</filename>\n', filename));

fprintf(fileID, sprintf('\t<source>\n'));
fprintf(fileID, sprintf('\t\t<database>%s</database>\n', database));
fprintf(fileID, sprintf('\t</source>\n'));

fprintf(fileID, sprintf('\t<size>\n'));
fprintf(fileID, sprintf('\t\t<width>%d</width>\n', width));
fprintf(fileID, sprintf('\t\t<height>%d</height>\n', height));
fprintf(fileID, sprintf('\t</size>\n'));

num_bboxes = length(classes);
for i = 1:num_bboxes
   if strcmp(classes_all{classes(i)},'empty') == false 
       fprintf(fileID, sprintf('\t<object>\n'));
           fprintf(fileID, sprintf('\t\t<name>%s</name>\n', classes_all{classes(i)}));
           fprintf(fileID, sprintf('\t\t<bndbox>\n'));
           fprintf(fileID, sprintf('\t\t\t<xmin>%d</xmin>\n', boxes(i,1)));
           fprintf(fileID, sprintf('\t\t\t<xmax>%d</xmax>\n', boxes(i,3)));
           fprintf(fileID, sprintf('\t\t\t<ymin>%d</ymin>\n', boxes(i,2)));
           fprintf(fileID, sprintf('\t\t\t<ymax>%d</ymax>\n', boxes(i,4)));
           fprintf(fileID, sprintf('\t\t</bndbox>\n'));
       fprintf(fileID, sprintf('\t</object>\n'));
   end
end

fprintf(fileID, sprintf('</annotation>\n'));
fclose(fileID);
end





