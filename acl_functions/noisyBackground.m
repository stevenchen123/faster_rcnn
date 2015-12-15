function noisyBackground(imdb, roidb)

    [~, num_img] = size(roidb.rois);
    im_dir = fullfile(imdb.image_dir) ;
    for i = 1:num_img
        % load image
        fprintf(sprintf('processing %d \t at: %s\n', i, imdb.image_at(i)));
        im = imread (fullfile(im_dir, [imdb.image_ids{i}, ['.', imdb.extension]]));


        % noise background
        bg_im =uint8(255*rand(size(im)));

        % fill in valid bounding boxes
        [num_boxes, ~] = size(roidb.rois(i).boxes);
        for j = 1:num_boxes
            box = roidb.rois(i).boxes(j, :)
            size(im)
            bg_im(box(2):box(4), box(1):box(3), :) = ...
                im(box(2):box(4), box(1):box(3), :);
        end

        % save image
        % imshow(bg_im);
        imwrite(bg_im, [im_dir, '/../ILSVRC2013_DET_val_mod/', [imdb.image_ids{i}, ['.', imdb.extension]]]);

    end

end

