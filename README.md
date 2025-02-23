# Illumina Use Case - Salesforce LWC and Flow Implementation

## Overview
This repository contains the implementation of two Salesforce use cases utilizing **Lightning Web Components (LWC), Flows, Apex, and Platform Events, assignment rules**.

## Use Case 1: Get Places Based on Country and Zip code

### 📌 Objective
Develop an LWC that accepts a zip code as input, makes an API call to fetch location details, and processes the response based on country conditions.

### 🚀 Features
- **LWC Component for Zip Code Input & API Call**  
  - Uses `http://api.zippopotam.us/{country}/{zipcode}` dynamically.
  - Fetches location data based on the selected country.
  
- **Dynamic Country Selection**  
  - Implemented a **separate searchable combobox** for selecting the country.
  - Countries are stored as **picklist values in a custom object**.
  - Enhances usability and quick data retrieval.

- **US Data Handling**  
  - If `country = US`, the response is displayed using an LWC **datatable** (child component).
  - In **Flow**, the data is directly shown on the screen with proper exception handling.

- **Non-US Data Handling**  
  - If `country ≠ US`, the response is stored in a **custom object** along with the places retrieved from the API.
  - Stored data can be viewed on a **record page**.
  - i have implemented a very complex approach,but a efficient one by having the database upserts from UI controller in a parallel mode **parallel mode**

- **Similar Flow Implementation**  
  - The above same design has been implemented using **Screen Flow**. with a minor change in functionality

- **Error Handling & UI Experience**  
  - LWC and Flow both ensure proper error handling and user-friendly data display.

---

## Use Case 2: Risk-Based Case Creation with Platform Events

### 📌 Objective
Trigger a platform event when the **Risk** field is set to `High` and create a case with a different owner.

### 🚀 Features
- **Custom Field: Risk**
  - A picklist field (`Risk__c`) with values **High, Medium, and Low**.

- **Platform Event Trigger**
  - When `Risk__c = High`, a **platform event is triggered**.
  - Used **PlatformEventSubscriber configuration** to overwrite the publishing automation user.

- **Case Creation and Owner Assignment**
  - **Assignment Rules** are used to set the case owner.
  - If assignment rules are not present, the fallback mechanism assigns the case to a **Queue ID**.
  - New **InternalAccount** is used as a case origin for this use case.

- **Error Handling**
  - **Trigger-based subscriber** used instead of Flow for **failure callbacks & exception handling** during publish.

---

## 💡 Why This Design for both use cases?
- **Dynamic Country Selection**: A separate, reusable searchable combobox improves usability over standard choice sets.
- **Single Custom Object for Non-US Data**: Simplifies data structure and avoids redundancy.
- **Trigger-based Platform Event Subscription**: Allows error handling at the publish level.
- **Fallback Mechanism for Case Assignment**: Ensures cases are never left unassigned.


## ✅ Testing & Best Practices
- **Unit Tests:** Apex test classes included for API calls and Platform Event handling.
- **Error Handling:** Implemented in both LWC and Flows for user-friendly messages.
- **Code Reusability:** Common components like the **searchable combobox** are used across LWC and Flow.
---