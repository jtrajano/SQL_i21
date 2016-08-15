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
	WHERE ISNULL(A.strScreen, '') <> '' AND ISNULL(A.strRecordNo, '') <> ''

	-- UPDATE tblSMCommentWatcher of the transationId of the previously inserted transaction records
	UPDATE tblSMCommentWatcher
	SET tblSMCommentWatcher.intTransactionId = C.intTransactionId
	FROM tblSMCommentWatcher A 
		INNER JOIN tblSMScreen B ON A.strScreen = B.strNamespace
		INNER JOIN tblSMTransaction C ON B.intScreenId = C.intScreenId AND C.strRecordNo = A.strRecordNo
	WHERE ISNULL(A.strScreen, '') <> '' AND ISNULL(A.strRecordNo, '') <> ''

	DECLARE @activityNo AS INT = 0 
	DECLARE @activityPrefix AS NVARCHAR(50)

	SELECT 
		@activityNo = (intNumber - 1),
		@activityPrefix = strPrefix 
	FROM tblSMStartingNumber 
	WHERE strModule = 'System Manager' AND strTransactionType = 'Activity'	

	;WITH CTE AS
	(
	   SELECT *,
			 ROW_NUMBER() OVER (PARTITION BY intTransactionId ORDER BY dtmAdded ASC) AS RowNumber
	   FROM tblSMComment 
	   WHERE ISNULL(strScreen, '') <> '' AND ISNULL(strRecordNo, '') <> ''
	)
	-- INSERT to tblSMActivity all comments Grouped By Transaction Id
	INSERT INTO tblSMActivity (
		intTransactionId,
		strActivityNo,
		strType,
		strSubject,
		dtmStartDate,
		dtmCreated,
		intCreatedBy,
		intAssignedTo,
		intConcurrencyId
	)
	SELECT 
		intTransactionId, 
		@activityPrefix + CAST((CAST(ROW_NUMBER() OVER (ORDER BY intTransactionId) AS INT) + @activityNo) AS NVARCHAR(50)) strActivityNo,
		'Comment' strType,
		SUBSTRING(
			REPLACE(
				REPLACE(
					REPLACE(dbo.fnStripHtml(REPLACE(strComment, '?', '#$%^')),
				'&nbsp;', ' '), 
			'?',''), '#$%^', '?'), 
		0, 99) strSubject,
		dtmAdded dtmStartDate,
		dtmAdded dtmCreated,
		intEntityId intCreatedBy,
		intEntityId intAssignedTo,
		1 intConcurrenctId
	FROM CTE
	WHERE RowNumber = 1

	-- Update tblSMStartingNumber
	UPDATE tblSMStartingNumber
	SET intNumber = @@ROWCOUNT + (@activityNo + 1)
	WHERE strModule = 'System Manager' AND strTransactionType = 'Activity'	

	DECLARE @screenId AS INT
	SELECT @screenId = intScreenId FROM tblSMScreen WHERE strNamespace = 'GlobalComponentEngine.view.Activity'

	--INSERT to tblSMTransaction from newly inserted activities
	INSERT INTO tblSMTransaction (
		intScreenId,
		strRecordNo,
		intConcurrencyId
	) 
	SELECT 
		@screenId intScreenId,
		CAST(A.intActivityId AS NVARCHAR(50)) strRecordNo,
		A.intConcurrencyId
	FROM tblSMActivity A 
		LEFT OUTER JOIN tblSMTransaction C ON intScreenId = @screenId AND C.strRecordNo = CAST(A.intActivityId AS NVARCHAR(50))
	WHERE ISNULL(C.intTransactionId, 0) = 0	 
	
	--UPDATE tblSMComment intTransactionId to be equal to newly inserted transaction from activities
	UPDATE tblSMComment
	SET tblSMComment.intTransactionId = C.intTransactionId,
		tblSMComment.intActivityId = B.intActivityId,
		strScreen = '',
		strRecordNo = ''
	FROM tblSMComment A 
		INNER JOIN tblSMActivity B ON A.intTransactionId = B.intTransactionId
		INNER JOIN tblSMTransaction C ON C.intScreenId = @screenId AND C.strRecordNo = CAST(B.intActivityId AS NVARCHAR(50))
	WHERE ISNULL(A.strScreen, '') <> '' AND ISNULL(A.strRecordNo, '') <> ''

	--UPDATE tblSMCommentWatcher intTransactionId to be equal to newly inserted transaction from activities
	UPDATE tblSMCommentWatcher
	SET tblSMCommentWatcher.intTransactionId = C.intTransactionId,
		tblSMCommentWatcher.intActivityId = B.intActivityId,
		strScreen = '',
		strRecordNo = ''
	FROM tblSMCommentWatcher A 
		INNER JOIN tblSMActivity B ON A.intTransactionId = B.intTransactionId
		INNER JOIN tblSMTransaction C ON C.intScreenId = @screenId AND C.strRecordNo = CAST(B.intActivityId AS NVARCHAR(50))
	WHERE ISNULL(A.strScreen, '') <> '' AND ISNULL(A.strRecordNo, '') <> ''

	UPDATE tblSMNotification
	SET tblSMNotification.intActivityId = B.intActivityId
	FROM tblSMNotification A 
		INNER JOIN tblSMComment B ON A.intCommentId = B.intCommentId

GO
	PRINT N'Comments Migration'
GO

	