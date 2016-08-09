GO
	PRINT N'BEGIN Comments Migration'
GO
	-- INSERT to tblSMTransaction all comments' unique transaction link that are not existing yet
	INSERT INTO tblSMTransaction (
		intScreenId,
		strRecordNo,
		intConcurrencyId
	) 
	SELECT 
		DISTINCT
		B.intScreenId,
		A.strRecordNo,
		A.intConcurrencyId
	FROM tblSMComment A 
		INNER JOIN tblSMScreen B ON A.strScreen = B.strNamespace
		LEFT OUTER JOIN tblSMTransaction C ON B.intScreenId = C.intScreenId AND C.strRecordNo = A.strRecordNo
	WHERE ISNULL(C.intTransactionId, 0) = 0	

	-- INSERT to tblSMTransaction all comments watcher's unique transaction link that are not existing yet
	INSERT INTO tblSMTransaction (
		intScreenId,
		strRecordNo,
		intConcurrencyId
	) 
	SELECT 
		DISTINCT
		B.intScreenId,
		A.strRecordNo,
		A.intConcurrencyId
	FROM tblSMCommentWatcher A 
		INNER JOIN tblSMScreen B ON A.strScreen = B.strNamespace
		LEFT OUTER JOIN tblSMTransaction C ON C.intScreenId = B.intScreenId AND C.strRecordNo = A.strRecordNo
	WHERE ISNULL(C.intTransactionId, 0) = 0	

	-- UPDATE tblSMComment of the transationId of the previously inserted transaction records
	UPDATE tblSMComment
	SET tblSMComment.intTransactionId = C.intTransactionId
	FROM tblSMComment A 
		INNER JOIN tblSMScreen B ON A.strScreen = B.strNamespace
		INNER JOIN tblSMTransaction C ON B.intScreenId = C.intScreenId AND C.strRecordNo = A.strRecordNo

	-- UPDATE tblSMCommentWatcher of the transationId of the previously inserted transaction records
	UPDATE tblSMCommentWatcher
	SET tblSMCommentWatcher.intTransactionId = C.intTransactionId
	FROM tblSMCommentWatcher A 
		INNER JOIN tblSMScreen B ON A.strScreen = B.strNamespace
		INNER JOIN tblSMTransaction C ON B.intScreenId = C.intScreenId AND C.strRecordNo = A.strRecordNo
GO
	PRINT N'Comments Migration'
GO

	