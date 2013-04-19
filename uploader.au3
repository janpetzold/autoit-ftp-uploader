;
; FTP-Uploader with error correction and notification
;
; @author janpetzold
; @version 1.0
;

#include <Date.au3>;
#include <FTPEx.au3>;
#include <INet.au3>;


; Functions

Func uploadFile($ftp, $server, $user, $password, $dir, $file)
	$con = _FTP_Connect($ftp, $server, $user, $password);
	$put = _FTP_ProgressUpload($con, $file, $dir & "/" & $file);
	Return $con;
EndFunc

Func checkFile($ftp, $con, $dir, $file)
	Dim $success = false;
	$size = _FTP_FileGetSize($con, $dir & "/" & $file);

	If $size > 0 Then
		$success = true;
	EndIf

	Return $success;
EndFunc

Func sendMail($file)
	Dim $date = _NowDate();
	Dim $time  = _NowTime();
	Dim $smtp = "MY_SMTP_MAIL_SERVER";
	Dim $from = "MY_SENDER";
	Dim $sender = "MY_SENDER_MAIL@HOST.COM";
	Dim $recipient =  "MY_RECIPIENT_MAIL@HOST.COM";
	Dim $subject = "MY_SUBJECT";

	Dim $body[2];
	$body[0] = "MY_MESSAGE_LINE_1";
	$body[1] = "MY_MESSAGE_LINE_2";

	$mail = _INetSmtpMail($smtp, $from, $sender, $recipient, $subject, $body, @ComputerName, -1);
	;$err = @error
	;If $mail = 1 Then
	;	MsgBox(0, "Success!", "Mail sent")
	;Else
	;	MsgBox(0, "Error!", "Mail failed with error code " & $err)
	;EndIf
EndFunc

Func init($errorCounter, $ftp, $server, $user, $password, $dir, $file)
	$con = uploadFile($ftp, $server, $user, $password, $dir, $file);
	$check = checkFile($ftp, $con, $dir, $file);

	If $check = false Then
		$errorCounter = $errorCounter + 1;
		If $errorCounter > 3 Then
			;MsgBox(0, "Critical Error", "Upload failes multiple times - terminating");
			$mail = sendMail($dir & "/" & $file);
			$bye = _FTP_Close($ftp);
			Exit;
		Else
			;MsgBox(0, "Error", "Upload failed - " & $errorCounter & ". attempt");
			init($errorCounter, $ftp, $server, $user, $password, $dir, $file);
		EndIf
	Else
		;MsgBox(0, "Finished", "Upload was successful");
	EndIf
EndFunc

; Workflow

If $CmdLine[0] < 5 Then
	Exit;
EndIf

Const $server = $CmdLine[1];
Const $user = $CmdLine[2];
Const $password = $CmdLine[3];
Const $dir = $CmdLine[4];
Const $file = $CmdLine[5];
Dim $errorCounter = 0;

$ftp = _FTP_Open("FTP Control");
$upload = init($errorCounter, $ftp, $server, $user, $password, $dir, $file);
$bye = _FTP_Close($ftp);