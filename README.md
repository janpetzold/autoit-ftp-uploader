autoit-ftp-uploader
===================

This is s simple FTP upload script based on [AutoIt](http://www.autoitscript.com/site/autoit/) that I wrote once because some of our FTP file uploads failed from time to time. 

The script uploads a file and checks the file size on the remote server afterwards. If the file size does not match, the upload starts again. If that fails for three times I get notified by e-mail.

You control the script entirely by its command-line parameters - see the bottom of the script for this.
