PRINT N'START MIGRATE AUDIT LOG'
BEGIN

INSERT INTO tblSMScreen (strNamespace, strScreenId, strScreenName, strModule)
	SELECT DISTINCT tblSMAuditLog.strTransactionType, '',
					dbo.fnSMAddSpaceToTitleCase(REPLACE(SUBSTRING(tblSMAuditLog.strTransactionType,CHARINDEX('.',tblSMAuditLog.strTransactionType), LEN(tblSMAuditLog.strTransactionType)),'.view.',''),0),
					CASE WHEN SUBSTRING(tblSMAuditLog.strTransactionType,0,CHARINDEX('.',tblSMAuditLog.strTransactionType)) = 'i21' THEN 'System Manager'  --module
	 				ELSE dbo.fnSMAddSpaceToTitleCase(SUBSTRING(tblSMAuditLog.strTransactionType,0,CHARINDEX('.',tblSMAuditLog.strTransactionType)),0) END
		-- REPLACE(tblSMAuditLog.strTransactionType,SUBSTRING(tblSMAuditLog.strTransactionType,charindex('.',tblSMAuditLog.strTransactionType),LEN(tblSMAuditLog.strTransactionType)),'')
		 FROM tblSMAuditLog tblSMAuditLog
		 LEFT OUTER JOIN tblSMScreen on tblSMScreen.strNamespace = tblSMAuditLog.strTransactionType
		 WHERE ISNULL(tblSMScreen.strNamespace,'') = '' AND ISNULL(tblSMAuditLog.strTransactionType,'') <> ''

INSERT INTO tblSMTransaction (intScreenId, intRecordId, intConcurrencyId)
SELECT 
	DISTINCT 
	A.intScreenId,
	CAST(A.strRecordNo AS INT),
	1
FROM 
	(  
		SELECT 
			E.strJsonData,
			F.intScreenId,
			E.strRecordNo
		FROM tblSMAuditLog E
		INNER JOIN tblSMScreen F ON E.strTransactionType = F.strNamespace
	) A LEFT OUTER JOIN 
	tblSMTransaction B ON A.intScreenId = B.intScreenId AND CAST(A.strRecordNo AS INT) = B.intRecordId 
WHERE ISNULL(B.intRecordId, '') = '' AND ISNULL(A.strRecordNo, '') <> '' AND ISNULL(A.strRecordNo, '') <> 0


DECLARE @tblSMAudit TABLE (
	intLogId			INT,
	intAuditId			INT,
	intParentAuditId	INT,
	intOldAuditLogId	INT,
	strAction			NVARCHAR(50),
	strChange			NVARCHAR(255),
	strKeyValue			NVARCHAR(255),
	strFrom				NVARCHAR(MAX),
	strTo				NVARCHAR(MAX),
	strAlias			NVARCHAR(255)
)
 
-- Insert to tblSMLog and tblSMAudit for entries that doesn't have JsonData including Created/Deleted records
MERGE INTO tblSMLog USING (
	SELECT 
		A.dtmDate,
		A.intEntityId,
		B.intTransactionId,
		A.strActionType,
		A.intAuditLogId,
		A.strRoute
	FROM 
		(  
			SELECT  
				E.intAuditLogId,
				E.strJsonData,
			    F.intScreenId,
				E.strRecordNo,
				E.dtmDate,
				E.intEntityId,
				E.strActionType,
				E.ysnInit,
				E.strRoute
			FROM tblSMAuditLog E
			INNER JOIN tblSMScreen F ON E.strTransactionType = F.strNamespace
		) A LEFT OUTER JOIN 
		tblSMTransaction B ON A.intScreenId = B.intScreenId AND CAST(A.strRecordNo AS INT) = B.intRecordId  --AND B.intTransactionId = 3716
	WHERE ISNULL(B.intRecordId, '') <> '' AND ISNULL(A.strRecordNo, '') <> '' AND (ISNULL(ysnInit,'') = '' OR ysnInit = 0) --AND ISNULL(A.strJsonData, '') = '' AND ISNULL(A.strActionType, '') <> 'Updated'

) AS OldLog (dtmDate, intEntityId, intTransactionId, strActionType, intAuditLogId, strRoute) ON 1 = 0
WHEN NOT MATCHED THEN
INSERT (strType, dtmDate, intEntityId, intTransactionId, strRoute, intConcurrencyId)
VALUES ('Audit', OldLog.dtmDate, OldLog.intEntityId, OldLog.intTransactionId, OldLog.strRoute, 1)
OUTPUT inserted.intLogId,  OldLog.strActionType, OldLog.intAuditLogId
INTO @tblSMAudit(intLogId, strAction, intOldAuditLogId); 

--set true 
UPDATE tblSMAuditLog set ysnInit = 1 WHERE intAuditLogId = intAuditLogId

INSERT INTO tblSMAudit (intLogId, strAction, intOldAuditLogId, intConcurrencyId)
SELECT intLogId, strAction, intOldAuditLogId, 1 FROM @tblSMAudit



--exec uspSMMigrateAuditLog --remove 

END
PRINT N'END MIGRATE AUDIT LOG INCLUDING TOP 1000'