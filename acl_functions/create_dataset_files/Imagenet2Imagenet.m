function Imagenet2Imagenet(imdb, roidb, directory)
if nargin < 3
    directory = 'datasets/custom_dataset';
end
% for each picture in imdb, 
%   write image to directory.images
%   write roidb to directory.bboxes
dst_extension = '.JPEG';
[~, num_img] = size(roidb.rois);
im_dir = fullfile(imdb.image_dir) ;

assert(imdb.num_classes == 200);

% imagenet labels
classes = imdb.classes;
assert(imdb.classes{1,1}(1) == 'n');


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

fprintf(fileID, sprintf('</annotation>\n'));
fclose(fileID);
end