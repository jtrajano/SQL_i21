﻿GO
	PRINT N'BEGIN NOTIFICATION'
GO
	-- DELETE OBSOLETE NOTIFICATIONS
	DELETE tblSMNotification
	WHERE ISNULL(intCommentId, 0) = 0

	-- Add Comment Watchers
	INSERT tblSMCommentWatcher (
		strScreen, 
		strRecordNo, 
		intEntityId,
		intConcurrencyId
	)
	SELECT DISTINCT 
		A.strScreen, 
		A.strRecordNo, 
		A.intEntityId,
		1 
	FROM tblSMComment A
	WHERE NOT EXISTS (	
		SELECT 1 
		FROM tblSMCommentWatcher B 
		WHERE B.strScreen = A.strScreen AND B.strRecordNo = A.strRecordNo
	) 
	AND NOT EXISTS (
		SELECT 1
		FROM tblSMNotification C
		WHERE C.intCommentId = A.intCommentId
	)

	-- Add Notification Entry
	INSERT tblSMNotification (
		intFromEntityId,
		intToEntityId,
		strTitle,
		strAction,
		strType,
		intCommentId,
		ysnSent,
		intConcurrencyId
	)
	SELECT 
		A.intEntityId,
		B.intEntityId,
		A.strScreen,
		'watch',
		'comment',
		A.intCommentId,
		0,
		1
	FROM tblSMComment A INNER JOIN tblSMCommentWatcher B 
		ON A.strScreen = B.strScreen AND A.strRecordNo = B.strRecordNo
	WHERE A.intCommentId NOT IN(SELECT ISNULL(C.intCommentId,0) FROM tblSMNotification C)

GO
	PRINT N'END NOTIFICATION'
GO