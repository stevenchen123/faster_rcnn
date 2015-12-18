function [imdb_downsampled, roidb_downsampled] = ...
    reduceClasses(imdb, roidb, desired_classes, max_images_per_class, return_type)

if strcmp(return_type,'test') 
    max_images_per_class = max_images_per_class /2;
end

% find valid indices
counts = zeros(length(desired_classes),1);
[~, num_img] = size(roidb.rois);
valid_inds = [];
for i = 1:num_img
    for j = 1:length(desired_classes)
        if counts(j) >= max_images_per_class
            continue;
        end
        if strcmp(return_type,'test') && (imdb.flip_from(i) ~=0)
           continue;
        end
        if any(desired_classes(j) == roidb.rois(i).class)
            valid_inds = [valid_inds, i];
            %counts(j) = counts(j) + 1;
            unique_class = unique(roidb.rois(i).class);
            for kk = 1:length(unique_class)
                ind = find(desired_classes == unique_class(kk));
                if ind > 0 
                    counts(ind) = counts(ind) + 1;
                    assert(length(valid_inds)>=counts(ind));
                end
            end
            break;
        end
    end
    
    if sum(counts>=max_images_per_class) == length(desired_classes)
       break; 
    end
end

% valid_inds;
% assemble downsampled dataset
imdb_downsampled = {};
imdb_downsampled.name = imdb.name;
imdb_downsampled.image_dir = imdb.image_dir;
imdb_downsampled.image_ids = imdb.image_ids(valid_inds,:);
imdb_downsampled.extension = imdb.extension;
if strcmp(return_type, 'train')
    imdb_downsampled.flip = imdb.flip;
    imdb_downsampled.flip_from = (1:length(valid_inds))'-1;
        imdb_downsampled.flip_from(1:2:end) = 0;
elseif strcmp(return_type, 'test')
    imdb_downsampled.flip = 0;
    imdb_downsampled.flip_from = zeros(length(valid_inds),1);
end
imdb_downsampled.classes = imdb.classes(desired_classes,:);
imdb_downsampled.num_classes = length(desired_classes);
    keys = imdb.classes(desired_classes);
    values = 1:length(desired_classes);
imdb_downsampled.class_to_id = containers.Map(keys, values);
imdb_downsampled.class_ids = 1:length(desired_classes);
imdb_downsampled.eval_func = @imdb_eval_ImageNet;
imdb_downsampled.roidb_func = @roidb_from_ImageNet;
imdb_downsampled.image_at = @(i) ...
       sprintf('%s/%s.%s', imdb_downsampled.image_dir, imdb_downsampled.image_ids{i}, imdb_downsampled.extension);
imdb_downsampled.sizes = imdb.sizes(valid_inds,:);

%
%   imdb.eval_func = @imdb_eval_ImageNet;
%   imdb.roidb_func = @roidb_from_ImageNet;
%   imdb.image_at = @(i) ...
%       sprintf('%s/%s.%s', imdb.image_dir, imdb.image_ids{i}, imdb.extension);

roidb_downsampled = {};
roidb_downsampled.name = roidb.name;
roidb_downsampled.rois = {};
for i = 1:length(valid_inds)
   valid_entries = [];
   valid_entries_ind = [];
   for j = 1:length(roidb.rois(valid_inds(i)).class)
       ind = find(desired_classes == roidb.rois(valid_inds(i)).class(j));
       if ~isempty(ind)
           valid_entries = [valid_entries; j];
           valid_entries_ind = [valid_entries_ind; ind];
       end
   end
   assert(length(valid_entries)>0);

   roidb_downsampled.rois(i).gt = roidb.rois(valid_inds(i)).gt(valid_entries, :);
   roidb_downsampled.rois(i).overlap = roidb.rois(valid_inds(i)).overlap(valid_entries, desired_classes);
   roidb_downsampled.rois(i).boxes = roidb.rois(valid_inds(i)).boxes(valid_entries, :);
   % force each bbox to be within image bounds
   pic_size = imdb_downsampled.sizes(i,:);
   roidb_downsampled.rois(i).boxes = forceBnd(roidb_downsampled.rois(i).boxes, pic_size);
   

   roidb_downsampled.rois(i).feat = roidb.rois(valid_inds(i)).feat;
   roidb_downsampled.rois(i).class = valid_entries_ind;
    
end

% remap label
% comment out if don't want to remap labels
classes= importdata('datasets/ImageNetData/class_labels_str');
imdb_downsampled.classes = classes(desired_classes,:);
fprintf(sprintf('--> want to detect %d classes \n', length(desired_classes)));
for i = 1:length(desired_classes)
    fprintf(sprintf('%s \t %d imgs \n',classes{desired_classes(i)}, counts(i))); 
end

% verify selection is correct (show one image from each chosen category)
% im_dir = fullfile(pwd,  imdb.image_dir);
% for i = 1:length(desired_classes)
%     for j = 1:numel(roidb_downsampled.rois)
%        if any (roidb_downsampled.rois(j).class == i)
%            figure;
%            im = imread (fullfile(im_dir, [imdb_downsampled.image_ids{j}, '.JPEG']));
%            imshow(im);
%            title(sprintf('class %d, type %s', i, imdb_downsampled.classes{i}));
%            drawnow;
% %             showDataPic(imdb_downsampled, roidb_downsampled, j);
%            break;
%        end
%     end
% end

end


function boxes = forceBnd(boxes, pic_size)
%lower bound
boxes = max(boxes,1);

% upper bound
boxes(:,1) = min(boxes(:,1), pic_size(2));
boxes(:,2) = min(boxes(:,2), pic_size(1));
boxes(:,3) = min(boxes(:,3), pic_size(2));
boxes(:,4) = min(boxes(:,4), pic_size(1));

% checking
[num_boxes, ~] = size(boxes);
assert(sum(boxes(:,1) <= pic_size(2)) == num_boxes);
assert(sum(boxes(:,2) <= pic_size(1)) == num_boxes);
assert(sum(boxes(:,3) <= pic_size(2)) == num_boxes);
assert(sum(boxes(:,4) <= pic_size(1)) == num_boxes);
end


