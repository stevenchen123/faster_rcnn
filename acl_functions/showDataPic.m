function showDataPic(imdb, imroi, pic_num)
close all;

% print stats
fprintf(sprintf('image_dir: %s\n', imdb.image_dir));
fprintf(sprintf('image_ids: %s\n', imdb.image_ids{pic_num}));
fprintf(sprintf('@image_at: %s\n', imdb.image_at(pic_num)));
% show image
%f = figure;
im_dir = fullfile(imdb.image_dir) ;
im = imread (fullfile(im_dir, [imdb.image_ids{pic_num}, ['.', imdb.extension]]));
%imshow(im);
%hold on;

g = figure;
im_dir = fullfile(imdb.image_dir) ;
im = imread (fullfile(im_dir, [imdb.image_ids{pic_num}, ['.', imdb.extension]]));
imshow(im);
hold on;

% plot bounding boxes
[num_bounding_boxes, ~] = size(imroi.rois(pic_num).boxes);
classes = imdb.classes;
for i = 1:num_bounding_boxes
    if imroi.rois(pic_num).class(i) ~= 0
        figure(g);
        box = imroi.rois(pic_num).boxes(i,:);
        plot([box(1) box(3) box(3) box(1) box(1)], ...
             [box(4) box(4) box(2) box(2) box(4)], 'linewidth', 2);
        text_str = sprintf('%s \n %.2f\n', ...
            classes{imroi.rois(pic_num).class(i)}, ...
            imroi.rois(pic_num).overlap(i,imroi.rois(pic_num).class(i)));
        text(double(box(3)), double(box(4)), text_str,...
            'FontSize', 14, 'Color', 'red');
    else
        figure(g);
        box = imroi.rois(pic_num).boxes(i,:);
        [m,n,~] = size(im);
        size(im)
        box
        assert(box(1)>0 && box(1)<=n);
        assert(box(2)>0 && box(2)<=m);
        assert(box(3)>0 && box(3)<=n);
        assert(box(4)>0 && box(4)<=m);
        plot([box(1) box(3) box(3) box(1) box(1)], ...
             [box(4) box(4) box(2) box(2) box(4)], 'linewidth', 2);
       
    end
end
drawnow;

% evaluate functions
% imdb.eval_func(pic_num)
% imdb.roidb_func(pic_num)
end