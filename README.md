# Dynamic Scene Video Stabilisation

MATLAB-based computer vision project for stabilising video in dynamic scenes while preserving the motion of independently moving objects. The project uses feature detection, feature matching, outlier rejection and frame-to-frame motion estimation to reduce unwanted camera motion and evaluate stabilisation quality.

## Overview

This project focuses on video stabilisation in scenes containing both camera motion and independently moving objects.

The system estimates dominant background motion between consecutive frames, rejects outlier matches caused by moving objects, and applies geometric correction to produce a more stable output video. The project also visualises feature matches, stabilised frames and red-cyan frame overlays to assess stabilisation quality.

## Key Features

- Implemented a MATLAB video stabilisation pipeline for dynamic scenes
- Used SURF feature detection and descriptor matching for frame-to-frame correspondence
- Applied RANSAC-based outlier rejection to estimate dominant background motion
- Generated stabilised video output while preserving independently moving objects
- Used PSNR-based evaluation to compare stabilisation performance between frames
- Visualised inlier matches, stabilised frames and red-cyan overlays during processing

## Technologies Used

- MATLAB
- Computer Vision Toolbox
- SURF feature detection
- Feature matching
- RANSAC
- Geometric transformation estimation
- PSNR evaluation
- Video processing

## Repository Structure

    dynamic-scene-video-stabilisation-cv/
    ├── code/
    │   └── stabilise_videos.m
    ├── media/
    ├── README.md
    └── LICENSE.txt

## System Pipeline

    Input Video
         ↓
    Frame Extraction
         ↓
    SURF Feature Detection
         ↓
    Feature Matching
         ↓
    RANSAC Outlier Rejection
         ↓
    Dominant Motion Estimation
         ↓
    Frame Warping / Stabilisation
         ↓
    PSNR Evaluation and Visualisation

## Method

The stabilisation method estimates the dominant camera/background motion between consecutive frames. SURF features are detected and matched across frames, then RANSAC is used to reject outliers caused by moving objects or incorrect matches.

The remaining inlier correspondences are used to estimate the frame-to-frame transformation. This transformation is then applied to reduce unwanted camera motion and generate a stabilised output sequence.

## Visual Outputs

The project displays several outputs during stabilisation:

- Inlier feature matches between frames
- Stabilised frame output
- Red-cyan overlay for comparing frame alignment
- PSNR values for objective stability evaluation

## Setup

Clone the repository:

    git clone https://github.com/musa-z/dynamic-scene-video-stabilisation-cv.git
    cd dynamic-scene-video-stabilisation-cv/code

Open MATLAB and run:

    stabilise_videos

Alternatively, from the MATLAB command window:

    run("stabilise_videos.m")

## Limitations and Future Improvements

Performance depends on feature quality, lighting conditions, the amount of camera shake, the number of independently moving objects and RANSAC parameter tuning.

Future improvements would include saving stabilised output videos automatically, adding side-by-side input/output comparisons, testing alternative feature methods such as ORB or SIFT, and reimplementing the pipeline in Python/OpenCV for easier deployment.
