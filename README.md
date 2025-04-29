# Biomatrix Scaffold and Cell Invasion Image Analysis

This repository contains MATLAB and ImageJ scripts for automated and semi-automated analysis of 3D scaffold and cell invasion imaging data. These tools are designed for processing large TIFF stacks acquired from stitched light-sheet or confocal scans and are adaptable for similar 3D biological tissue imaging pipelines.

## Overview

The code is divided into two main modules:
1. Scaffold segmentation and characterization (fully automated in MATLAB)  
2. Cell segmentation and invasion (semi-automated in ImageJ with MATLAB merging)

---

## Scaffold segmentation and characterization – MATLAB

**Purpose:**  
Automatically segment biomatrix scaffolds from raw TIFF image stacks and quantify 3D scaffold volume and porosity.

**Usage:**  
1. Run `rawTiffData_preprocess__segment_porosity_script1.m`  
   - **Input:** Folder containing stitched raw TIFF slices.  
   - **Functions:**  
     - Identifies biomatrix in each 2D slice.  
     - Computes 3D scaffold volume based on voxel count.  
     - Generates a filled segmented "envelope" of the scaffold.  
     - Calculates porosity using the formula:  
       `porosity = (1 - scaffold_volume / envelope_volume) * 100%`  
   - **Output:** Segmented images and envelope saved in an automatically created subfolder.

2. Run `tiffSlicesToStack_script2.m`  
   - Converts:  
     - The original 2D TIFF slices into a single stack for use in ImageJ.  
     - The segmented envelope stack into a `.tif` file.

---

## Cell segmentation and invasion – ImageJ and MATLAB

**Purpose:**  
Semi-automatically segment cells from the scaffold using ImageJ, and merge with scaffold data in MATLAB and Imaris.

**Usage:**  
Note: ImageJ memory is limited. Process stacks in batches of about 500 slices (~5 GB chunks).

1. In ImageJ:  
   - Drag and drop `cell_segmentation_3Dinvasion.ijm` into the ImageJ window.  
   - Edit the script:  
     - Set `z_begin` and `z_end` to define the range of slices for each batch (e.g., 500 slices).  
     - Update file paths and folder names.  
   - Run the macro to segment cell-like structures.

2. Repeat the above process until all slices are processed.

3. In MATLAB:  
   - Use `tiffSlicesToStack_script2.m` to combine all segmented cell slices into a single `.tif` stack.

4. In ImageJ:  
   - Use `combineEnvelopeCellsStack_script4.ijm` to merge the final segmented cell stack with the scaffold envelope stack.

5. In Imaris:  
   - Save the result as a merged `.tif` file.

---

## Requirements

- MATLAB (tested with R2021a or newer)  
- ImageJ or Fiji (64-bit)  
- Imaris (for stack merging and visualization)

