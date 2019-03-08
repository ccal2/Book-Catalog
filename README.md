# CloudKitCatalog
iOS app that loads a book catalog from a CloudKit public database and updates its contents on each launch

<p align="center">
    <img src="/screenshot.PNG" width="300">
<p/>

## Reminder
If you choose to run this project, please remember to change the app's BundleID and setup the CloudKit container


## CloudKit setup
In order to run this project you must have an Apple Developer Account and add the following recordTypes to the project's CloudKit container:

- **Book**
    - authorName: String
    - colorName: String
    - title: String

- **Change**
    - changedRecordName: String
    - timestamp: Date/Time (QUERYABLE)
    - type: String
    
Also make sure that the recordName field of both these types are queryable

### Changes
All the changes made on the database should create a Change record. For the time being, all this work is done manually, but I intend to create something that will automate this process
