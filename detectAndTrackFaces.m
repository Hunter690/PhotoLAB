function detectAndTrackFaces()
% Detects the face using the cascade object detector which is a branch off
% of the Viola-Jones detection algorithm. The cascade object detector uses 
% a trained classification model for detection and can detect other parts
% of the human body as well.

% load camera shutter sound
[y,Fs] = audioread('shutter.wav');

% initialize webcam and cascade object detector
video = webcam();

faceDetector = vision.CascadeObjectDetector(); 

% Create an instance of the KLTTracker class 
tracker = KLTTracker;

% get the size of the webcam video
frame = snapshot(video);
frameSize = size(frame);

% initialize the video player object
videoFigure = figure('Name', 'PhotoLAB', 'Position', [78, 50, frameSize(2), frameSize(1)], ...
    'WindowButtonDownFcn', @initialPosition, ...
    'WindowButtonUpFcn',@selectFilter, ...
    'WindowKeyPressFcn', @keyPressed, ...
    'CloseRequestFcn', @attemptedfigureClose);

% intialize the filter to be regular bounding box with markers
filterID = 0;
initialXPosition = 0;
initialYPosition = 0;
brightness = 0;
pictureNumber = 1;
    
% iterate until we have successfully detected a face
bboxes = [];
while isempty(bboxes)
    framergb = snapshot(video);
    frame = rgb2gray(framergb);
    bboxes = faceDetector.step(frame);
end
tracker.addDetections(frame, bboxes);

% loop until the detection is closed
frameNumber = 0;
keepRunning = true;

while keepRunning
    try
        framergb = snapshot(video);
        frame = rgb2gray(framergb);
    catch error
    end
    
    % can modify division of frameNumber to increase/decrease the number of
    % times the bboxes are redetected
    if mod(frameNumber, 10) == 0
        % redetect faces
        bboxes = faceDetector.step(frame);
        if ~isempty(bboxes)
            tracker.addDetections(frame, bboxes);
        end
    else
        % track faces
        tracker.track(frame);
    end
     
    % display a filter over the displayFrame
    [displayFrame, picture, alphaData, location] = ...
        filterDisplayFrame(tracker, framergb, filterID);
    
    % show the actual frame
    imshow(displayFrame + brightness, 'Border', 'tight');
    % if a hat/glasses filter is selected, show the image
    if mod(filterID,5) ~= 0
        hold on
        % show the filter
        image(picture, 'AlphaData', alphaData, 'XData', location(1),...
            'YData', location(2));
        hold off
    end
    frameNumber = frameNumber + 1;
    % so that callbacks have time to trigger
    pause(eps)
end

    function initialPosition(varargin)
        % store initial position of the cursor on click
        cursorPosition = get(gca, 'CurrentPoint');
        initialXPosition = cursorPosition(1, 1);
        initialYPosition = cursorPosition(1, 2);
    end

    function selectFilter(varargin)
        % store final position of the cursor on mouse release
        cursorPosition = get(gca, 'CurrentPoint');
        finalXPosition = cursorPosition(1,1);
        finalYPosition = cursorPosition(1,2);
        % calculate delta x and y positions
        changeInXPosition = finalXPosition - initialXPosition;
        changeInYPosition = finalYPosition - initialYPosition;
        if abs(changeInXPosition) < 200
            % if the swipe's delta x is less than a certain threshold, then
            % assume it is a vertical swipe
            % change brightness of image proportional to distance swiped
            brightness = brightness - changeInYPosition/20;
        elseif changeInXPosition > 0
            % assume horizontal swipe, cycle through filters accordingly
            filterID = filterID + 1;
        else
            filterID = filterID - 1;
        end
    end

    function keyPressed(~,eventdata)  
        switch eventdata.Key
            case 'space'
                disp('space')
                % user wants to take picture, save current displayFrame
                % play a camera shutter sound
                sound(y,Fs);
                saveas(gcf, ['Picture', num2str(pictureNumber), '.png']);
                pictureNumber = pictureNumber + 1;    
            case 'backspace'
                % user wants to delete most recent picture
                % check if the picture exists
                if isfile(['Picture', num2str(pictureNumber - 1), '.png'])
                    pictureNumber = pictureNumber - 1;
                    delete(['Picture', num2str(pictureNumber), '.png'])
                end
            case 'escape'
                % completely closes PhotoLAB
                keepRunning = false;
                delete(gcf)
            otherwise
                disp('invalid command')
        end
    end

    function attemptedfigureClose(varargin) 
        % close everything ;)
        keepRunning = false;
        delete(gcf)
    end
end