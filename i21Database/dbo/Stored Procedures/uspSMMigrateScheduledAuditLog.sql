CREATE PROCEDURE uspSMMigrateScheduledAuditLog
@blast BIT
AS
SET QUOTED_IDENTIFIER OFF  
SET NOCOUNT ON  
SET XACT_ABORT ON  
  
--=====================================================================================================================================  
--  VARIABLE DECLARATIONS  
---------------------------------------------------------------------------------------------------------------------------------------  
  
DECLARE @intAuditLogId AS INT
DECLARE @strJsonData AS NVARCHAR(MAX)
DECLARE @dtmDate AS DATE
DECLARE @intEntityId AS INT
DECLARE @intTransactionId AS INT

DECLARE @maxAuditId AS INT
DECLARE @logId AS INT
DECLARE @parentAuditId AS INT
--=====================================================================================================================================  
--  DECLARE TEMPORARY TABLES  
---------------------------------------------------------------------------------------------------------------------------------------  

DECLARE @tblSMAuditLog TABLE (
	intAuditLogId		INT,
	strActionType		NVARCHAR(100),
	strJsonData			NVARCHAR(MAX),
	dtmDate				DATE,
	intEntityId			INT,
	intTransactionId	INT
)

--=====================================================================================================================================  
--  GET ALL AUDIT LOGS BASED ON THE NAMESPACE AND PRIMARY KEY 
---------------------------------------------------------------------------------------------------------------------------------------  
BEGIN
	
IF(@blast = 1)
BEGIN
INSERT INTO @tblSMAuditLog (
	intAuditLogId, 
	strActionType,
	strJsonData, 
	dtmDate, 
	intEntityId,
	intTransactionId
)
SELECT 
	A.intAuditLogId,
	A.strActionType,
	A.strJsonData,
	A.dtmDate,
	A.intEntityId,
	B.intTransactionId
FROM 
	(  
		SELECT 
			E.dtmDate,
			E.intAuditLogId,
			E.strActionType,
			F.intScreenId,
			E.strRecordNo,
			E.strJsonData,
			E.intEntityId,
			E.ysnProcessed,
			F.strNamespace
		FROM tblSMAuditLog E
		INNER JOIN tblSMScreen F ON E.strTransactionType = F.strNamespace
	) A LEFT OUTER JOIN 
	tblSMTransaction B ON A.intScreenId = B.intScreenId AND CAST(A.strRecordNo AS INT) = B.intRecordId
WHERE	ISNULL(A.ysnProcessed, 0) = 0 AND
		ISNULL(A.strJsonData, '') LIKE '%}' AND 
		ISNULL(A.strActionType, '') NOT IN ('Created','Deleted')
END
ELSE
	BEGIN
		INSERT INTO @tblSMAuditLog (
	intAuditLogId, 
	strActionType,
	strJsonData, 
	dtmDate, 
	intEntityId,
	intTransactionId
)
SELECT TOP 1000  --top 1k RECORDS
	A.intAuditLogId,
	A.strActionType,
	A.strJsonData,
	A.dtmDate,
	A.intEntityId,
	B.intTransactionId
FROM 
	(  
		SELECT 
			E.dtmDate,
			E.intAuditLogId,
			E.strActionType,
			F.intScreenId,
			E.strRecordNo,
			E.strJsonData,
			E.intEntityId,
			E.ysnProcessed,
			F.strNamespace
		FROM tblSMAuditLog E
		INNER JOIN tblSMScreen F ON E.strTransactionType = F.strNamespace
	) A LEFT OUTER JOIN 
	tblSMTransaction B ON A.intScreenId = B.intScreenId AND CAST(A.strRecordNo AS INT) = B.intRecordId
WHERE	ISNULL(A.ysnProcessed, 0) = 0 AND
		ISNULL(A.strJsonData, '') LIKE '%}' AND 
		ISNULL(A.strActionType, '') NOT IN ('Created','Deleted')
	END
END