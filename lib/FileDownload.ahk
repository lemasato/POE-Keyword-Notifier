FileDownload(url, dest) {
	UrlDownloadToFile,% url,% dest
	if (ErrorLevel) {
		MsgBox, Failed to download file!`nURL: %url%`nDest: %dest%
		return 0
	}
	return 1
}
