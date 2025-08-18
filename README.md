# Computer Vision: Stabilising Video in Dynamic Scenes

## Overview
**University Project:** Computer Vision: Stabilising Video in Dynamic Scenes.

Demonstrates the use of feature and outlier detectors to stablise videos while preserving the motion of moving objects, in real-time. Displays an objective measure of stability on the output videos.

---

## Features
- Displays the inlier matches, stablised frame and red-cyan overlay between each frame
- Speeded-Up Robust Feature (SURF) to detect features and RANdom SAmple Consensus (RANSAC) for outliers
- Utilises Peak Signal-to-Noise Ratio (PSNR) to display the performance of the stability method

---

## Code
- Written in the MATLAB language
- Script located in the `code/` folder

---

## Media
- Screenshots of both videos during the stabilisation process

---

## Setup

```bash
# Clone the repo
git clone https://github.com/musa-z/dynamic-scene-video-stabilisation-cv.git

# Navigate to code folder
cd dynamic-scene-video-stabilisation-cv/code

# Run main script
python stabilise_videos.m
```

## Acknowledgements
Video content used for analysis was provided by Prof. Bogdan Matuszewski