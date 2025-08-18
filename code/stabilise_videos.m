%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% VIDEO STABILISATION USING SURF AND RANSAC
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% PART 1: Full Video Stabilisation for Video 1 static scene
filename1 = "video_seq_1.avi";  % Set the filename for Video 1
outFile1  = "stabilised_video_1.avi";  % Set output filename for stabilised Video 1

vR1 = VideoReader(filename1);   % Create a VideoReader object to read Video 1
vW1 = VideoWriter(outFile1, "Motion JPEG AVI");  % Create a VideoWriter object for output video in .avi
vW1.FrameRate = vR1.FrameRate;  % Set the output video frame rate to match the input video frame rate
open(vW1);  % Open the VideoWriter to write frames

FramePrev = readFrame(vR1);  % Read first frame
grayPrev = im2gray(FramePrev);  % Convert the first frame to grayscale
ptsPrev = detectSURFFeatures(grayPrev);  % Detect SURF keypoints in the gray frame
[featPrev, ptsPrev] = extractFeatures(grayPrev, ptsPrev);  % Extract SURF descriptors at the detected keypoints

psnrValues = []; % Initialise to store PSNR values

cumulativeTform = simtform2d;  % Set to identity transform
writeVideo(vW1, im2uint8(FramePrev));  % Write the first frame to the output video in colour

figure("Name", "Video 1 Stabilisation", "Position", [100,100,1600,800]); % Window to show frames and stabilisation

% Process the rest of the frames of Video 1
while hasFrame(vR1)
    colorFrameCurr = readFrame(vR1);  % Read the next frame from Video 1
    grayCurr = im2gray(colorFrameCurr);  % Convert to grayscale
    
    % Detect SURF features in frame
    ptsCurr = detectSURFFeatures(grayCurr);
    [featCurr, ptsCurr] = extractFeatures(grayCurr, ptsCurr);
    
    % Match features between the previous frame and the current frame
    idxPairs = matchFeatures(featPrev, featCurr, "MaxRatio", 0.8, "MatchThreshold", 100);
    
    if size(idxPairs,1) < 2
        % If there arent enough matched features then reuse transform
        stabilisedFrame = imwarp(colorFrameCurr, cumulativeTform, "OutputView", imref2d(size(colorFrameCurr(:,:,1))));
    else
        % Use the helper function to estimate the affine transform between previous and current frames
        tformAffine = cvexEstStabilizationTform(grayPrev, grayCurr, 0.1);
        % Convert the affine transform to a similarity transform
        sRtTform = cvexTformToSRT(tformAffine);
        % Update the cumulative transformation by multiplying the new similarity transform
        cumulativeTform = simtform2d(cumulativeTform.A * sRtTform.A);
        % Warp the current frame using the cumulative transformation
        stabilisedFrame = imwarp(colorFrameCurr, cumulativeTform, "OutputView", imref2d(size(colorFrameCurr(:,:,1))));
    end

    if exist('prevStabilisedFrame','var')
        % Calulate PSNR between the current stabilised frame and the previous one
        currentPSNR = psnr(im2uint8(stabilisedFrame), im2uint8(prevStabilisedFrame));
        psnrValues = [psnrValues; currentPSNR];
    end

    prevStabilisedFrame = stabilisedFrame;    % Update previous stable frame
    
    % Write the new stable frame to the output video
    writeVideo(vW1, im2uint8(stabilisedFrame));
    
    % Display 3 subplots
    subplot(1,3,1);
    imshow(grayCurr);  % Show the current grayscale frame
    hold on;
    if size(idxPairs,1) >= 2
        % Display inliers using estgeotform2d RANSAC function
        matchedPrev = ptsPrev(idxPairs(:,1));  % Get matched points from the previous frame
        matchedCurr = ptsCurr(idxPairs(:,2));  % Get matched points from the current frame
        [~, inlierIdxVis] = estgeotform2d(matchedCurr, matchedPrev, "affine", "MaxDistance", 4, "Confidence", 99);
        % Overlay the inlier matches
        plot(ptsCurr(idxPairs(inlierIdxVis,2)), "showOrientation", true);
    end
    hold off;
    title("Current Frame with Inlier Matches");
    
    subplot(1,3,2);
    imshow(im2uint8(stabilisedFrame));  % Display the stabilised frame
    title("Stabilised Frame");
    
    subplot(1,3,3);
    % Create a red–cyan overlay of the current grayscale frame and the stabilised grayscale frame.
    imshowpair(grayCurr, im2gray(stabilisedFrame), "ColorChannels", "red-cyan");
    title("Red-Cyan Overlay");
    drawnow;
    
    % Update variables for the next iteration
    FramePrev = colorFrameCurr;  % Update previous frame
    grayPrev = grayCurr;  % Update previous grayscale frame
    ptsPrev = ptsCurr;  % Update previous keypoints
    featPrev = featCurr;  % Update previous descriptors
end

meanPSNR = mean(psnrValues); % Calulate mean PSNR
disp("Average PSNR: " + meanPSNR + " dB"); % Display average PSNR

close(vW1);  % Close the VideoWriter for Video 1
disp("Saved stabilised Video 1 to: " + outFile1);

%% PART 2: Full Video Stabilisation for Video 2 with moving robot
filename2 = "video_seq_2.avi";  % Create a VideoReader object to read Video 2
outFile2  = "stabilised_video_2.avi";  % Set output filename for stabilised Video 2

vR2 = VideoReader(filename2);  % Create a VideoReader object for Video 2
vW2 = VideoWriter(outFile2, "Motion JPEG AVI");  % Create a VideoWriter object for output video in .avi
vW2.FrameRate = vR2.FrameRate;  % Set the output video frame rate to match the input video frame rate
open(vW2);  % Open the VideoWriter to write frames

FramePrev2 = readFrame(vR2);  % Read first frame
grayPrev2 = im2gray(FramePrev2);  % Convert the first frame to grayscale 
ptsPrev2 = detectSURFFeatures(grayPrev2);  % Detect SURF keypoints in the gray frame
[featPrev2, ptsPrev2] = extractFeatures(grayPrev2, ptsPrev2);  % Extract SURF descriptors at the detected keypoints

psnrValues2 = []; % Initialise to store PSNR values

cumulativeTform2 = simtform2d;  % Set to identity transform
writeVideo(vW2, im2uint8(FramePrev2));  % Write the first frame to the output video in colour

figure("Name", "Video 2 Stabilisation", "Position", [200,150,1600,800]); % Window to show frames and stabilisation

% Process the rest of the frames of Video 2
while hasFrame(vR2)
    colorFrameCurr2 = readFrame(vR2);  % Read the next frame from Video 2
    grayCurr2 = im2gray(colorFrameCurr2);  % Convert to grayscale
    
    % Detect SURF features in frame
    ptsCurr2 = detectSURFFeatures(grayCurr2);
    [featCurr2, ptsCurr2] = extractFeatures(grayCurr2, ptsCurr2);
    
    % Match features between the previous frame and the current frame
    idxPairs2 = matchFeatures(featPrev2, featCurr2, "MaxRatio", 0.8, "MatchThreshold", 100);
    
    if size(idxPairs2,1) < 2
        % If there arent enough matched features then reuse transform
        stabilisedFrame2 = imwarp(colorFrameCurr2, cumulativeTform2, "OutputView", imref2d(size(colorFrameCurr2(:,:,1))));
    else
        % Use the helper function to estimate the affine transform between previous and current frames
        tformAffine2 = cvexEstStabilizationTform(grayPrev2, grayCurr2, 0.1);
        % Convert the affine transform to a similarity transform
        sRtTform2 = cvexTformToSRT(tformAffine2);
        % Update the cumulative transformation by multiplying the new similarity transform
        cumulativeTform2 = simtform2d(cumulativeTform2.A * sRtTform2.A);
        % Warp the current frame using the cumulative transformation
        stabilisedFrame2 = imwarp(colorFrameCurr2, cumulativeTform2, "OutputView", imref2d(size(colorFrameCurr2(:,:,1))));
    end

    if exist('prevStabilisedFrame2','var')
        % Calculate PSNR between the current stabilised frame and the previous one
        currentPSNR2 = psnr(im2uint8(stabilisedFrame2), im2uint8(prevStabilisedFrame2));
        psnrValues2 = [psnrValues2; currentPSNR2];
    end

    prevStabilisedFrame2 = stabilisedFrame2;    % Update previous stable frame
    
    % Write the new stable frame to the output video
    writeVideo(vW2, im2uint8(stabilisedFrame2));
    
    % Display 3 subplots
    subplot(1,3,1);
    imshow(grayCurr2);  % Show the current grayscale frame
    hold on;
    if size(idxPairs2,1) >= 2
        % Display inliers using estgeotform2d RANSAC function
        matchedPrev2 = ptsPrev2(idxPairs2(:,1));  % Get matched points from the previous frame
        matchedCurr2 = ptsCurr2(idxPairs2(:,2));  % Get matched points from the current frame
        [~, inlierIdxVis2] = estgeotform2d(matchedCurr2, matchedPrev2, "affine", "MaxDistance", 4, "Confidence", 99);
        % Overlay the inlier matches
        plot(ptsCurr2(idxPairs2(inlierIdxVis2,2)), "showOrientation", true);
    end
    hold off;
    title("Current Frame with Inlier Matches");
    
    subplot(1,3,2);
    imshow(im2uint8(stabilisedFrame2));  % Display the stabilised frame
    title("Stabilised Frame");
    
    subplot(1,3,3);
    % Create a red–cyan overlay of the current grayscale frame and the stabilised grayscale frame
    imshowpair(grayCurr2, im2gray(stabilisedFrame2), "ColorChannels", "red-cyan");
    title("Red–Cyan Overlay");
    drawnow;
    
    % Update references for the next iteration
    grayPrev2 = grayCurr2;
    ptsPrev2 = ptsCurr2;
    featPrev2 = featCurr2;
end

meanPSNR2 = mean(psnrValues2); % Calculate mean PSNR
disp("Average PSNR: " + meanPSNR2 + " dB"); % Display average PSNR

close(vW2);  % Close the VideoWriter for Video 2
disp("Saved stabilised Video 2 to: " + outFile2);


%% FUNCTIONS
% cvexEstStabilizationTform.m

function tform = cvexEstStabilizationTform(leftI,rightI,ptThresh)
%Get inter-image transformation and aligned point features.
%  tform = cvexEstStabilizationTform(leftI,rightI) returns an affine
%  transformation between leftI and rightI using the |estgeotform2d|
%  function.
%
%  tform = cvexEstStabilizationTform(leftI,rightI,ptThresh) also accepts
%  arguments for the threshold to use for the corner detector.

% Copyright 2010-2022 The MathWorks, Inc.

% Set default parameters
if nargin < 3 || isempty(ptThresh)
    ptThresh = 0.1;
end

%% Generate prospective points
pointsA = detectSURFFeatures(leftI, 'MetricThreshold', 1000);
pointsB = detectSURFFeatures(rightI, 'MetricThreshold', 1000);

%% Select point correspondences
% Extract features for the corners
[featuresA,pointsA] = extractFeatures(leftI,pointsA);
[featuresB,pointsB] = extractFeatures(rightI,pointsB);

% Match features which were computed from the current and the previous
% images
indexPairs = matchFeatures(featuresA,featuresB);
pointsA = pointsA(indexPairs(:, 1),:);
pointsB = pointsB(indexPairs(:, 2),:);

%% Use MSAC algorithm to compute the affine transformation
tform = estgeotform2d(pointsB,pointsA,'affine');

end

% cvexTformToSRT.m

function [tformOut,s,ang,t,R] = cvexTformToSRT(tformIn)
%Convert an affine transformation to a similarity (scale-rotation-translation) transformation.
%  [tformOut,S,ANG,T,R] = cvexTformToSRT(tformIn) returns the scale,
%  rotation, and translation parameters, and the reconstituted
%  transformation tformOut.

% Copyright 2010-2022 The MathWorks, Inc.

% Extract scale and rotation part sub-matrix
tformAffine = tformIn.A;
R = tformAffine(1:2,1:2);

% Compute theta from mean of two possible arctangents
ang = mean([atan2(-R(3),R(1)) atan2(R(2),R(4))]);

% Compute scale from mean of two stable mean calculations
s = mean(R([1 4])/cos(ang));

% Convert theta to degrees
angd = rad2deg(ang);

% Translation remains the same
t = tformAffine(1:2,3);

% Reconstitute new s-R-t transformation and store it in a simtform2d object
tformOut = simtform2d(s,angd,t);

end