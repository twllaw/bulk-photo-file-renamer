# bulk-photo-file-renamer
When you have multiple cameras, I find it to be a pain to organise all your photos afterwards, with different file name formatting styles depending on the camera and/or brand.

This script simply adds the timestamp of when the picture was taken to the front of the file name.
If the Date Taken field is missing, the Modified Date of the file will be used instead.

Multiple folders can be passed in the first argument.

##### Preview new file names
.\BulkPhotoRenamer.ps1 {folderPath}[, {anotherFolderPath}]

##### Confirm renaming of files
.\BulkPhotoRenamer.ps1 {folderPath}[, {anotherFolderPath}] rename