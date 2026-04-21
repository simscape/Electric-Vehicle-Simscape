function captureSubsystemImage(subsystemPath)
%captureSubsystemImage Capture and display a Simulink subsystem screenshot.
%   captureSubsystemImage(SUBSYSTEMPATH) prints the subsystem to a
%   temporary PNG file and displays it in a figure so that MATLAB publish
%   includes the image in the generated HTML.
% Copyright 2026 The MathWorks, Inc.

    tmpFile = fullfile(tempdir, 'subsystem_snapshot.png');
    print(['-s' subsystemPath], '-dpng', '-r100', tmpFile)
    img = imread(tmpFile);
    [h, w, ~] = size(img);
    scale = 400 / w;
    fig = figure('Color','w', 'Position', [100 100 400 round(h*scale)]);
    imshow(img)
    set(gca, 'Position', [0 0 1 1])
    delete(tmpFile)
end
