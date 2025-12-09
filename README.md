# Fingerprint-Recognition

## **README — Fingerprint Recognition System (MATLAB)**

_A Minutiae-Based Fingerprint Matching & Identification Project_

---

## **1. Overview**

This project implements a complete **fingerprint recognition system** in MATLAB based on **minutiae-based biometric matching**, which is one of the most widely used academic and industrial approaches in fingerprint identification.

The system:

- Preprocesses fingerprint images
    
- Performs ridge enhancement and skeletonization
    
- Extracts minutiae features (ridge endings & bifurcations)
    
- Estimates minutiae orientation
    
- Stores extracted features in a fingerprint database
    
- Matches a query fingerprint against the database
    
- Outputs **MATCH** or **NO MATCH FOUND** based on strict thresholds
    

This project is designed for academic use, biometric research, and demonstration of fingerprint feature extraction and matching principles.

---

## **2. Features**

- ✔ **Minutiae Extraction** (ridge endings + bifurcations)
    
- ✔ **Orientation-aware matching** (distance + angle constraints)
    
- ✔ **Skeletonization + Morphological processing**
    
- ✔ **SSIM global similarity score**
    
- ✔ **Double-threshold matching logic**
    
- ✔ **Support for BMP, PNG, JPG, TIFF images**
    
- ✔ **Works with SOCOFing Dataset**
    
- ✔ **Robust NO-MATCH detection for unknown fingerprints**
    
- ✔ Modular MATLAB code, easy to extend for research
    

---

## **3. Dataset**

This project uses the **SOCOFing Dataset**, a real-world and open-source fingerprint dataset:

- Over **6,000** real fingerprint images
    
- Resolution: 96 x 103 px
    
- Format: PNG (can be converted to BMP/JPG)
    

Download (official source):  
[https://www.kaggle.com/datasets/ruizgara/socofing](https://www.kaggle.com/datasets/ruizgara/socofing)

After downloading, place selected images inside:

```
fingerprint_project/database/
```

---

## **4. Folder Structure**

Your project folder should look like this:

```
fingerprint_project/
│
├── buildDatabase.m
├── main.m
├── preprocessFingerprint.m
├── extractMinutiae.m
├── matchFingerprints.m
├── skeletonizeFingerprint.m
│
├── database/
│      ├── 100__M_Left_index_finger.bmp
│      ├── 101__F_Right_thumb.bmp
│      └── ... (any number of fingerprint images)
│
└── query/
       └── query.bmp   (the fingerprint you want to test)
```

---

## **5. MATLAB Requirements**

- **MATLAB R2018b or later**
    
- Required Toolbox:
    
    - **Image Processing Toolbox**
        

The system has been tested on:

- MATLAB R2022b
    
- Windows, macOS, and Linux (Ubuntu)
    

---

## **6. How the System Works (Methodology)**

### **Step 1 — Preprocessing**

- Convert to grayscale
    
- Median filtering
    
- Adaptive histogram equalization
    
- Binarization (Otsu threshold)
    
- Hole filling & noise removal
    
- Skeletonization (1-pixel ridge lines)
    

### **Step 2 — Minutiae Extraction**

The algorithm detects:

- **Ridge endings**
    
- **Bifurcations**
    

Each minutia stores:

- (x, y) coordinates
    
- type: 'ending' or 'bifurcation'
    
- local ridge **orientation angle** in degrees
    

### **Step 3 — Database Construction**

Each fingerprint in `/database/` is processed and saved into:

```
finger_db.mat
```

This file contains:

- minutiae list
    
- orientation
    
- downsampled enhanced fingerprint (for SSIM)
    

### **Step 4 — Matching**

Matching uses **two stages**:

#### **Local Matching (Minutiae)**

Compare:

- spatial distance
    
- angle difference
    
- minutiae type
    

#### **Global Matching (SSIM)**

Compute structural similarity between enhanced images.

### **Step 5 — Decision Logic**

A fingerprint is considered a **valid match** if:

```
(1) Local score ≥ threshold
(2) Matched minutiae ≥ threshold
(3) SSIM ≥ threshold
(4) Best match is clearly better than 2nd best
```

Otherwise:

```
NO MATCH FOUND
```

---

## **7. How to Run the Project**

### **Step 1 — Open MATLAB**

Open MATLAB and set the project folder as the **Current Folder**.

```
cd path/to/fingerprint_project
```

### **Step 2 — Build the Database**

This processes all fingerprint images in the `/database` folder:

```matlab
buildDatabase
```

This will create:

```
finger_db.mat
```

### **Step 3 — Place Your Query Fingerprint**

Put your test fingerprint here:

```
fingerprint_project/query/query.bmp
```

You can also use `.png`, `.jpg`, `.tif`, etc.

### **Step 4 — Run the Matching System**

Execute:

```matlab
main
```

### **Step 5 — Read Output in Command Window**

Example output:

```
Best index: 5
Local score (minutiae): 0.723
Local match count: 29
Global score (SSIM): 0.802
Second best score: 0.102
Result: MATCH (fingerprint belongs to subject: 101__F_Right_thumb)
```

or:

```
Best index: 7
Local score: 0.188
Local match count: 4
Global score: 0.211
Result: NO MATCH FOUND
```

### **Step 6 — Visualization**

MATLAB will display:

- skeleton image
    
- minutiae plotted on the fingerprint
    

This is useful for debugging and presentation.

---

## **8. Troubleshooting**

### **Problem: Always Returns MATCH**

→ Use stricter thresholds in `main.m`:

```
localRatioThreshold = 0.60;
localCountThreshold = 20;
globalThreshold     = 0.45;
scoreGapThreshold   = 0.10;
```

Make sure your query fingerprint is **not inside the database**.

---

### **Problem: Too Few Minutiae in query**

Some images are low-quality.

Solution:

- Use unaltered SOCOFing images
    
- Increase contrast
    
- Adjust filtering parameters in `preprocessFingerprint.m`
    

---

### **Problem: "finger_db.mat Not found"**

Run:

```
buildDatabase
```

Make sure `/database` contains fingerprint images.

---

## **9. Academic Notes (Optional for Report)**

- This system uses a **minutiae-based approach**, the same category used in AFIS systems.
    
- Skeleton-based minutiae detection is sensitive to noise → preprocessing is critical.
    
- Orientation-based filtering greatly reduces false matches, following classical academic methods.
    
- SSIM global similarity combines local + global features, improving reliability.
    
- The project demonstrates the entire fingerprint recognition pipeline end-to-end.
    

---

## **10. Credits**

- SOCOFing Dataset — Ruiz-Garcia et al.
    
- Minutiae detection concepts inspired by standard biometric literature.
    
- Repository structure inspired by open-source MATLAB fingerprint projects.
    

---

## **11. License**

This project is for **academic and research purposes only**.

Commercial use is not permitted without permission.

---
