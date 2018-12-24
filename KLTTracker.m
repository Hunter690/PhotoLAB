% Defines the KLTTracker class that allows for multiple face tracking
% using the Kanade-Lucas-Tomasi (KLT) algorithm.

% KLTTracker properties:
%   PointTracker - a vision.PointTracker object
%   Bboxes       - face bounding boxes
%   BoxIds       - ids associated with each bounding box
%   Points       - tracked points from all objects
%   PointIds     - ids associated with each point
%   NextId       - the next object will have this id
%   BoxScores    - and indicator of whether or not an object is lost
%
% KLTTracker methods:
%   addDetections - add detected bounding boxes
%   track         - track the objects

% having handle as the super class gives the KLTTracker class access to
% more built-in functions
classdef KLTTracker < handle
    properties
        % PointTracker is the vision.PointTracker
        PointTracker; 
        
        % Bboxes M-by-4 matrix of [x y w h] object bounding boxes
        Bboxes = [];
        
        % BoxIds M-by-1 array containing ids associated with each bounding box
        BoxIds = [];
        
        % Points M-by-2 matrix containing tracked points from all objects
        Points = [];
        
        % PointIds M-by-1 array containing object id associated with each 
        %   point. This array keeps track of which point belongs to which object.
        PointIds = [];
        
        % NextId The next new object will have this id.
        NextId = 1;
        
        % BoxScores M-by-1 array. Low box score means that we probably lost the object.
        BoxScores = [];
    end
    
    methods
        function this = KLTTracker()
        % adds the PointTracker function to the local available functions
            this.PointTracker = ...
                vision.PointTracker('MaxBidirectionalError', 2);
        end
        
        function addDetections(this, I, bboxes)
        % addDetections(tracker, I, bboxes) adds detected bounding boxes.
        % tracker is the KLTTracker object, I is the current
        % frame, and bboxes is an M-by-4 array of [x y w h] bounding boxes
        % with M being the number of faces in the current frame.
        % This method determines whether a detection belongs to an existing
        % object, or whether it is a brand new object.
            for i = 1:size(bboxes, 1)
                boxIdx = this.findMatchingBox(bboxes(i, :));

                if isempty(boxIdx)
                    % This is a brand new object, add the new bounding box
                    % as another row to the matrix of bounding boxes.
                    this.Bboxes = [this.Bboxes; bboxes(i, :)];

                    % find feature (tracking) points inside the detected region
                    points = detectMinEigenFeatures(I, 'ROI', bboxes(i, :));
                    points = points.Location;

                    % give the new box the new Id
                    this.BoxIds(end+1) = this.NextId;

                    % set new ids to each of the new points to distinguish
                    % between multiple objects
                    idx = ones(size(points, 1), 1) * this.NextId;
                    this.PointIds = [this.PointIds; idx];
                    this.Points = [this.Points; points];

                    % increment NextId for the next new box
                    this.NextId = this.NextId + 1;

                    % completely new box, so the box has not been lost yet
                    this.BoxScores(end+1) = 1;

                else
                    % the same face is here; delete the previous bounding
                    % box score and add the new bounding box to the list of
                    % bounding boxes
                    currentBoxScore = this.deleteBox(boxIdx);
                    this.Bboxes = [this.Bboxes; bboxes(i, :)];

                    % find feature (tracking) points inside the detected region
                    points = detectMinEigenFeatures(I, 'ROI', bboxes(i, :));
                    points = points.Location;

                    % use the previous bounding box Id
                    this.BoxIds(end+1) = boxIdx;
                    idx = ones(size(points, 1), 1) * boxIdx;
                    this.PointIds = [this.PointIds; idx];
                    this.Points = [this.Points; points];                    
                    this.BoxScores(end+1) = currentBoxScore + 1;
                end
            end

            % Decrement the accuracy on the any boxes that were not seen again
            % and remove the boxes that aren't tracked any more
            minBoxScore = -2;
            this.BoxScores(this.BoxScores < 3) = ...
                this.BoxScores(this.BoxScores < 3) - 0.5;
            boxesToRemoveIds = this.BoxIds(this.BoxScores < minBoxScore);
            while ~isempty(boxesToRemoveIds)
                this.deleteBox(boxesToRemoveIds(1));
                boxesToRemoveIds = this.BoxIds(this.BoxScores < minBoxScore);
            end
            
            % update the point tracker
            if this.PointTracker.isLocked()
                this.PointTracker.setPoints(this.Points);
            else
                this.PointTracker.initialize(this.Points, I);
            end
        end
                
        function track(this, I)
        % Tracks the face in frame I which is the current video frame, 
        % updating the points and the face bounding boxes; isFound is a 
        % logical vector.
            [newPoints, isFound] = this.PointTracker.step(I);
            this.Points = newPoints(isFound, :);
            this.PointIds = this.PointIds(isFound);
            generateNewBoxes(this);
            if ~isempty(this.Points)
                this.PointTracker.setPoints(this.Points);
            end
        end
    end
    
    methods(Access=private) 
        % local functions only available to the KLTTracker class
        function boxIdx = findMatchingBox(this, box)
        % Determine which tracked object (if any) the new detection belongs to. 
            boxIdx = [];
            for i = 1:size(this.Bboxes, 1)
                area = rectint(this.Bboxes(i,:), box);                
                if area > 0.2 * this.Bboxes(i, 3) * this.Bboxes(i, 4)
                    % the area of intersection is bigger than 20% of the
                    % previous bounding box, suggesting that they are the
                    % same bounding box; return the previous bounding box
                    % Id
                    boxIdx = this.BoxIds(i);
                    return;
                end
            end           
        end
        
        function currentScore = deleteBox(this, boxIdx)            
        % delete bounding box
            this.Bboxes(this.BoxIds == boxIdx, :) = [];
            this.Points(this.PointIds == boxIdx, :) = [];
            this.PointIds(this.PointIds == boxIdx) = [];
            currentScore = this.BoxScores(this.BoxIds == boxIdx);
            this.BoxScores(this.BoxIds == boxIdx) = [];
            this.BoxIds(this.BoxIds == boxIdx) = [];
            
        end
        
        function generateNewBoxes(this)  
        % Get bounding boxes for each face from tracked points.
            oldBoxIds = this.BoxIds;
            oldScores = this.BoxScores;
            this.BoxIds = unique(this.PointIds);
            numBoxes = numel(this.BoxIds);
            
            % refills bounding boxes with new boxes
            this.Bboxes = zeros(numBoxes, 4);
            this.BoxScores = zeros(numBoxes, 1);
            for i = 1:numBoxes
                % reset the points
                points = this.Points(this.PointIds == this.BoxIds(i), :);
                newBox = getBoundingBox(points);
                this.Bboxes(i, :) = newBox;
                % change the score of the current box
                this.BoxScores(i) = oldScores(oldBoxIds == this.BoxIds(i));
            end
        end 
    end
end

% child function that the embedded function generateNewBoxes uses to find
% the coordinates of the bounding boxes
function bbox = getBoundingBox(points)
x1 = min(points(:, 1));
y1 = min(points(:, 2));
x2 = max(points(:, 1));
y2 = max(points(:, 2));
bbox = [x1 y1 x2 - x1 y2 - y1];
end
