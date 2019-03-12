# Book Catalog
iOS app that loads a book catalog from a CloudKit public database and updates its contents on each launch

<p align="center">
    <img src="/BookCatalog.PNG" width="250">
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

**Update:** If you make sure that all the changes made on the database are made through the app on the 'Book Catalog Creator' project, you don't have to worry about creating change records anymore. It will all be done automatically.

## Book Catalog Creator
iOS app to manage the database

<p align="center">
    <img src="/BookCatalogCreator_main.png" width="250">
    <img src="/BookCatalogCreator_insert.png" width="250">
    <img src="/BookCatalogCreator_options.png" width="250">
<p/>
