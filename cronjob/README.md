# Cronjob to create backup of desired directory

## Code for python api to backup
Should be present here:
https://github.com/prashik856/python/tree/main/drive

## Code to run cronjob
Present here:
https://github.com/prashik856/bash/tree/master/cronjob

## Prerequisites

### 1. config.json file
Need to update config.json file to our needs.

### 2. credentials.json file
cronjob.sh scripts expects credentials.json file to be present in the project directory.
This credentials.json file contains oauth credentials to access google drive APIs.

### 3. Creating credentials.json file
1. Create project in [Google Cloud Console](https://console.cloud.google.com/)
2. Enable required APIs for the project
3. Create oAuth Consent screen for the project
4. Create OAuth Credentials for the project. We need to select Desktop Application as Type.
5. Download this file and rename it to credentials.json file

### 4. token.json file
This file is created dynamically by the code. Once python backup code runs, it will ask to login to Google Account in a new browser window. A successful login creates this token.json file.

## Run cronjob
This will create a backup in google drive
```bash
sh ./cronjob.sh
```