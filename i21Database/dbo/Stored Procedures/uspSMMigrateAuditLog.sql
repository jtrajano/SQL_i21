
--=====================================================================================================================================  
--  CREATE THE STORED PROCEDURE AFTER DELETING IT  
---------------------------------------------------------------------------------------------------------------------------------------  
CREATE PROCEDURE [dbo].[uspSMMigrateAuditLog]  
 @screenName   AS NVARCHAR(100) = NULL,  
 @keyValue     AS INT = NULL
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

DECLARE @queryAll BIT = (CASE WHEN ISNULL(@screenName,'') <> '' and ISNULL(@keyValue,'') <> '' THEN 1 ELSE 0 END)
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
IF(@queryAll = 1)
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
		ISNULL(B.intRecordId, 0) = @keyValue AND 
		ISNULL(A.strNamespace, '') = @screenName AND 
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
SELECT TOP 10000  --top 10k RECORDS
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
		--ISNULL(B.intRecordId, 0) = @keyValue AND 
		--ISNULL(A.strNamespace, '') = @screenName AND 
		ISNULL(A.strJsonData, '') LIKE '%}' AND 
		ISNULL(A.strActionType, '') NOT IN ('Created','Deleted')
END
--=====================================================================================================================================  
--  INSERT AUDIT ENTRY  
---------------------------------------------------------------------------------------------------------------------------------------  
SET IDENTITY_INSERT dbo.tblSMAudit ON; 

WHILE EXISTS (SELECT 1 FROM @tblSMAuditLog)
BEGIN
	SELECT TOP 1 
		@intAuditLogId		= intAuditLogId,
		@strJsonData		= strJsonData,
		@dtmDate			= dtmDate,
		@intEntityId		= intEntityId,
		@intTransactionId	= intTransactionId
	FROM @tblSMAuditLog

	SELECT @maxAuditId = ISNULL(MAX(intAuditId), 0) FROM tblSMAudit
	SELECT @logId = intLogId, @parentAuditId = intAuditId FROM tblSMAudit WHERE intOldAuditLogId = @intAuditLogId

	;WITH Json_CTE AS (
		SELECT 
			CASE WHEN ROW_NUMBER() OVER (ORDER BY parent ASC) = 1 THEN 
				@parentAuditId 
			ELSE 	
				@maxAuditId + ROW_NUMBER() OVER (ORDER BY parent ASC) END				AS [intAuditId], 
			SourceTable.parent															AS [intParentAuditId], 
			MIN(CASE SourceTable.[name] WHEN 'action'				THEN [value] END)	AS [strAction], 
			MIN(CASE SourceTable.[name] WHEN 'change'				THEN [value] END)	AS [strChange], 
			MIN(CASE SourceTable.[name] WHEN 'keyValue'				THEN [value] END)	AS [strKeyValue], 
			MIN(CASE SourceTable.[name] WHEN 'from'					THEN [value] END)	AS [strFrom], 
			MIN(CASE SourceTable.[name] WHEN 'to'					THEN [value] END)	AS [strTo], 
			MIN(CASE SourceTable.[name] WHEN 'changeDescription'	THEN [value] END)	AS [strAlias],
			MIN(CASE SourceTable.[name] WHEN 'hidden'				THEN [value] END)	AS [ysnHidden],
			MIN(CASE SourceTable.[name] WHEN 'isField'				THEN [value] END)	AS [ysnField]
		FROM (
			SELECT * 
			FROM fnSMJson_Parse(REPLACE(REPLACE(@strJsonData, ':null', ':"null"'), ',"children":[]', ''))
			WHERE [name] NOT IN ('leaf', 'iconCls') AND ([kind] <> 'OBJECT')
		) SourceTable 
		GROUP BY SourceTable.parent
	), Corrected_CTE AS (
		SELECT
			[intAuditId],
			[intParentAuditId],
			CASE WHEN ISNULL([strAction], '') = '' THEN 
				CASE WHEN [strChange] LIKE 'Created -%' THEN
					'Created'
				WHEN [strChange] LIKE 'Updated -%' THEN
					'Updated'
				WHEN [strChange] LIKE 'Deleted -%' THEN
					'Deleted'
				ELSE
					''
				END
			ELSE [strAction] END [strAction],
			[strChange],
			[strKeyValue],
			[strFrom],
			[strTo],
			[strAlias]
		FROM Json_CTE
	), Final_CTE AS (
		SELECT
			A.[intAuditId],
			C.[intAuditId] AS [intParentAuditId],
			A.[strAction],
			A.[strChange],
			A.[strKeyValue],
			A.[strFrom],
			A.[strTo],
			A.[strAlias]
		FROM Corrected_CTE A 
		OUTER APPLY (
			SELECT TOP 1 *
			FROM Corrected_CTE B
			WHERE  B.[intAuditId] < A.[intAuditId] AND 
			1 = CASE WHEN ISNULL(A.[strAction], '') = '' AND ISNULL(B.[strAction], '') <> '' THEN 1 ELSE 
					CASE WHEN ISNULL(A.[strAction], '') <> '' AND ISNULL(B.[strAction], '') = '' AND ISNULL(B.[strFrom], '') = '' AND ISNULL(B.[strTo], '') = '' 
					--CASE WHEN ISNULL(A.[strAction], '') IN ('Updated', 'Created', 'Deleted') AND ISNULL(B.[strAction], '') = '' AND ISNULL(B.[strFrom], '') = '' AND ISNULL(B.[strTo], '') = '' 
						THEN 1 ELSE 0  
					END
				END
			ORDER BY B.[intAuditId] DESC
		) C 
	) 
	INSERT INTO tblSMAudit(
			intAuditId, 
			intParentAuditId, 
			intLogId, 
			strAction, 
			strChange, 
			intKeyValue, 
			strFrom, 
			strTo, 
			strAlias,
			ysnHidden,
			ysnField, 
			intConcurrencyId
	)
	SELECT	intAuditId, 
			intParentAuditId,
			@logId, 
			strAction, 
			strChange, 
			CAST(strKeyValue AS INT) intKeyValue, 
			strFrom, 
			strTo, 
			strAlias,
			CASE WHEN (ISNULL(strAction,'') = '' AND ISNULL(strAlias,'') = '') THEN 1 ELSE ysnHidden END AS 'ysnHidden',
			ysnField, 
			1 
	FROM Final_CTE
	WHERE intAuditId > @maxAuditId + 1

	
	UPDATE tblSMAuditLog SET ysnProcessed = 1 WHERE intAuditLogId = @intAuditLogId

	DELETE FROM @tblSMAuditLog WHERE intAuditLogId = @intAuditLogId
END 

SET IDENTITY_INSERT dbo.tblSMAudit OFF; 
  
