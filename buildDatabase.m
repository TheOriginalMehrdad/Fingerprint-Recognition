% ==============================
% buildDatabase.m
% ==============================

clear; clc; close all;

databaseDir = 'database';

if ~isfolder(databaseDir)
    error('Database folder not found: %s', databaseDir);
end

% Support multiple image extensions
exts = {'.bmp', '.png', '.jpg', '.jpeg', '.tif', '.tiff'};
imageFiles = [];

for i = 1:numel(exts)
    imageFiles = [imageFiles; dir(fullfile(databaseDir, ['*' exts{i}]))]; %#ok<AGROW>
end

if isempty(imageFiles)
    error('No fingerprint images found in database folder.');
end

fingerDB = struct('id', {}, 'minutiae', {}, 'enhanced', {});

fprintf('Building fingerprint database from folder: %s\n', databaseDir);

for k = 1:numel(imageFiles)
    filename = imageFiles(k).name;
    filepath = fullfile(databaseDir, filename);

    fprintf('Processing %s ...\n', filename);

    img = imread(filepath);
    [~, name, ~] = fileparts(filename);
    subjectId = name;

    % You can keep your own version of preprocessFingerprint
    [~, enhancedImg, ~, skeletonImg] = preprocessFingerprint(img);

    % Downsample enhanced image for optional global similarity (SSIM)
    enhSmall = imresize(enhancedImg, [128 128]);

    % Extract minutiae with orientation
    minutiae = extractMinutiae(skeletonImg);

    fingerDB(k).id       = subjectId;
    fingerDB(k).minutiae = minutiae;
    fingerDB(k).enhanced = enhSmall;
end

save('finger_db.mat', 'fingerDB');
fprintf('Database built and saved to finger_db.mat\n');
