function [displayFrame, picture, alphaData, location] = ...
    filterDisplayFrame(tracker, framergb, filterID)
% Applies filter over display frame given the webcam frame as well as the
% filterId which determines the filter to apply. The tracker is an instance
% of the KLTTracker class and contains the location of the bounding boxes
% and tracking points. The function returns any changes made to the
% framergb as displayFrame, an overlaying picture (along with its
% alphaData) if application, and the location of the picture based on the
% tracker bounding box location.
filterID = mod(filterID,5);
        
% set picture and alphaData to NaN
picture = NaN;
alphaData = NaN;
location = [0, 0];

% determine which filter to apply
if filterID == 0
    try
        % display bounding boxes and tracked points.
        displayFrame = insertObjectAnnotation(framergb, 'rectangle',...
            tracker.Bboxes, tracker.BoxIds);
        displayFrame = insertMarker(displayFrame, tracker.Points);

        % resize displayFrame
        displayFrame = imresize(displayFrame, 2);
    catch error
        displayFrame = imresize(framergb, 2);
    end
elseif filterID == 1
    try
        % display gottem hat on top of normal framergb
        [picture, ~, alphaData] = imread('gottem_hat.png');
        
        % tracker.Bboxes contains the four x, y, w, and h of the bounding
        % boxes
        boundingBoxes = round(tracker.Bboxes);
        
        % can reset picture size if desired
        % picture = imresize(picture, insert_constant_here);
        
        % find the center of the top bounding box line to later give to
        % image function
        location = [boundingBoxes(1), boundingBoxes(2)-size(picture, 2)/2+100]*2;
        % resize displayFrame
        displayFrame = imresize(framergb, 2);
    catch error
        displayFrame = imresize(framergb, 2);
    end
elseif filterID == 2
    try
        % display chaplin hat on top of normal framergb
        [picture, ~, alphaData] = imread('charlie_chaplin.png');
        
        % tracker.Bboxes contains the four x, y, w, and h of the bounding
        % boxes
        boundingBoxes = round(tracker.Bboxes);
        
        % can reset picture size if desired
        % picture = imresize(picture, insert_constant_here);
        
        % find the center of the top bounding box line to later give to
        % image function
        location = [boundingBoxes(1), boundingBoxes(2)-size(picture, 2)/2+50]*2;
        % resize displayFrame
        displayFrame = imresize(framergb, 2);
    catch error
        displayFrame = imresize(framergb, 2);
    end
elseif filterID == 3
    try
        % display upenn hat on top of normal framergb
        [picture, ~, alphaData] = imread('upenn_hat.png');
        
        % tracker.Bboxes contains the four x, y, w, and h of the bounding
        % boxes
        boundingBoxes = round(tracker.Bboxes);
        
        % can reset picture size if desired
        % picture = imresize(picture, insert_constant_here);
        
        % find the center of the top bounding box line to later give to
        % image function
        location = [boundingBoxes(1), boundingBoxes(2)-size(picture, 2)/2+100]*2;
        % resize displayFrame
        displayFrame = imresize(framergb, 2);
    catch error
        displayFrame = imresize(framergb, 2);
    end
elseif filterID == 4
    try
        % display glasses on top of normal framergb
        [picture, ~, alphaData] = imread('glasses.png');
        
        % tracker.Bboxes contains the four x, y, w, and h of the bounding
        % boxes
        boundingBoxes = round(tracker.Bboxes);
        
        % can reset picture size if desired
        % picture = imresize(picture, insert_constant_here);
        
        % find the center of the top bounding box line to later give to
        % image function
        location = [boundingBoxes(1), boundingBoxes(2)+50]*2;
        % resize displayFrame
        displayFrame = imresize(framergb, 2);
    catch error
        displayFrame = imresize(framergb, 2);
    end
end
    