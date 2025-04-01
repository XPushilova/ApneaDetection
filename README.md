# Apnea Detection Algorithm

## Project Overview

This project aims to develop an algorithm for detecting and classifying sleep apnea using respiratory signals. The algorithm categorizes sleep events into four types:

- **Central Apnea (1)**
- **Obstructive Apnea (2)**
- **Hypopnea (3)**
- **Normal breathing (4)**

## Background

Sleep apnea is a serious disorder characterized by pauses in breathing during sleep, leading to reduced sleep quality and an increased risk of cardiovascular and metabolic diseases. Traditional diagnostics via polysomnography are effective but costly and uncomfortable for patients. This project focuses on creating a signal-processing-based algorithm to automate the classification of apnea events using non-invasive respiratory data.

## Data Used

The dataset used for this project is derived from the MESA database and includes the following signals:

- **Flow** (airflow measurement)
- **Thor** (chest movement)
- **Abdo** (abdomen movement)
- **SpO2** (oxygen saturation)

The sampling frequencies for the signals are:

- **32 Hz** for Flow, Thor, and Abdo
- **1 Hz** for SpO2

Annotations for each dataset segment provide labeled apnea events for evaluation.

## Algorithm Description

### 1. Signal Preprocessing

- The raw signals are filtered to remove DC components and isolate relevant frequency bands.
- A Butterworth filter is applied for further signal smoothing.

### 2. Apnea Event Detection

- The algorithm identifies apnea events based on the reduction of airflow below predefined thresholds:
  - **Apnea:** 91% reduction in airflow.
  - **Hypopnea:** 60% reduction in airflow.

### 3. Apnea Classification

- The detected apnea events are further analyzed to determine their type:
  - If both abdominal and thoracic movement signals are absent, it is classified as **Central Apnea (1)**.
  - If respiratory effort is detected in the abdominal or thoracic movement, it is classified as **Obstructive Apnea (2)**.

### 4. Hypopnea and Oxygen Saturation Check

- If a hypopnea event is detected, the algorithm checks whether SpO2 has dropped below a defined threshold.
  - If there is a significant drop in SpO2, the event is classified as **Hypopnea with Desaturation (3)**.
  - Otherwise, it is classified as **Normal breathing (4)**.

## File Structure

- `main.html` - Entry point script for executing the detection algorithm.
- `apneaDetection.m` - Core function implementing apnea classification.
- `filter_signals.m` - Helper function for signal preprocessing.
- `get_apnea_indexes.m` - Function for detecting apnea event timestamps.
- `apnoe_detection.m` - Function for classifying apnea type based on signal analysis.

## References

1. MESA Sleep Study Database
2. Research papers on sleep apnea detection techniques

---

This project provides a foundational algorithm for classifying sleep apnea using respiratory signals. Future enhancements could integrate machine learning for improved classification accuracy.

