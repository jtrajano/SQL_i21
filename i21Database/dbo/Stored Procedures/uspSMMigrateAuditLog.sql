  
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
  
DECLARE @querySpecific BIT = (CASE WHEN ISNULL(@screenName,'') <> '' and ISNULL(@keyValue,'') <> '' THEN 1 ELSE 0 END)  

--=====================================================================================================================================    
--  DECLARE TEMPORARY TABLES    
---------------------------------------------------------------------------------------------------------------------------------------    
  
DECLARE @tblSMAuditLog TABLE (  
 intAuditLogId  INT,  
 strActionType  NVARCHAR(100),  
 strJsonData   NVARCHAR(MAX),  
 dtmDate    DATE,  
 intEntityId   INT,  
 intTransactionId INT  
)  
  
--=====================================================================================================================================    
--  GET ALL AUDIT LOGS BASED ON THE NAMESPACE AND PRIMARY KEY   
---------------------------------------------------------------------------------------------------------------------------------------   
 
IF(@querySpecific = 1)  
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
	 ) A LEFT OUTER JOIN  tblSMTransaction B ON A.intScreenId = B.intScreenId AND CAST(A.strRecordNo AS INT) = B.intRecordId  
	WHERE ISNULL(A.ysnProcessed, 0) = 0 AND  
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
	) A LEFT OUTER JOIN tblSMTransaction B ON A.intScreenId = B.intScreenId AND CAST(A.strRecordNo AS INT) = B.intRecordId  
	WHERE ISNULL(A.ysnProcessed, 0) = 0 AND  
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
	@intAuditLogId  = intAuditLogId,  
	@strJsonData  = strJsonData,  
	@dtmDate   = dtmDate,  
	@intEntityId  = intEntityId,  
	@intTransactionId = intTransactionId  
 FROM @tblSMAuditLog  
  
 SELECT @maxAuditId = ISNULL(MAX(intAuditId), 0) FROM tblSMAudit  
 SELECT @logId = intLogId, @parentAuditId = intAuditId FROM tblSMAudit WHERE intOldAuditLogId = @intAuditLogId  
  
 DECLARE @JsonData TABLE (
	[id]		int NOT NULL,
    [parent]	int NOT NULL,
    [name]		nvarchar(100) NOT NULL,
    [kind]		nvarchar(10) NOT NULL,
    [value]		nvarchar(MAX) NOT NULL
)

DECLARE @JsonTransformed TABLE (
	[intRowId]			int NULL,
	[intAuditId]		int NULL,
    [intParentAuditId]	int NULL,
    [strAction]			nvarchar(MAX) NULL,
    [strChange]			nvarchar(MAX) NULL,
    [strKeyValue]		nvarchar(MAX) NULL,
    [strFrom]			nvarchar(MAX) NULL,
    [strTo]				nvarchar(MAX) NULL,
    [strAlias]			nvarchar(MAX) NULL,
	[ysnHidden]			BIT NULL,
	[ysnField]			BIT NULL
)

-- Save raw Json data into a temporary table
INSERT INTO @JsonData ([id], [parent], [name], [kind], [value])
SELECT 
	[id], 
	[parent], 
	[name], 
	[kind], 
	[value]   
FROM fnSMJson_Parse(REPLACE(REPLACE(@strJsonData, ':null', ':"null"'), ',"children":[]', ''))  
WHERE [name] NOT IN ('leaf', 'iconCls')

-- Save transformed json data into a temporary table
INSERT INTO @JsonTransformed (
	[intRowId], 
	[intAuditId],
	[intParentAuditId], 
	[strAction], 
	[strChange], 
	[strKeyValue], 
	[strFrom], 
	[strTo], 
	[strAlias], 
	[ysnHidden], 
	[ysnField]
)
SELECT  
	ROW_NUMBER() OVER (ORDER BY [intParentAuditId] ASC) AS [intRowId],
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
	[strAlias],  
	[ysnHidden],  
	[ysnField]  
FROM (
	 SELECT  
		NULL														AS [intAuditId],
		[parent]													AS [intParentAuditId],   
		MIN(CASE [name] WHEN 'action'   THEN [value] END)			AS [strAction],   
		MIN(CASE [name] WHEN 'change'   THEN [value] END)			AS [strChange],   
		MIN(CASE [name] WHEN 'keyValue' THEN [value] END)			AS [strKeyValue],   
		MIN(CASE [name] WHEN 'from'   THEN [value] END)				AS [strFrom],   
		MIN(CASE [name] WHEN 'to'     THEN [value] END)				AS [strTo],   
		MIN(CASE [name] WHEN 'changeDescription' THEN [value] END)	AS [strAlias],  
		MIN(CASE [name] WHEN 'hidden'  THEN [value] END)			AS [ysnHidden],  
		MIN(CASE [name] WHEN 'isField' THEN [value] END)			AS [ysnField]  
	FROM @JsonData WHERE [kind] <> 'OBJECT' GROUP BY parent
	UNION ALL  
	SELECT   
		[id]		AS [intAuditId],
		[parent]	AS [intParentAuditId],   
		[kind]		AS [strAction],   
		''			AS [strChange],   
		''			AS [strKeyValue],   
		''			AS [strFrom],   
		''			AS [strTo],   
		''			AS [strAlias],  
		''			AS [ysnHidden],  
		''			AS [ysnField]  
	FROM @JsonData WHERE [kind] IN ('OBJECT','ARRAY')
) JsonTransformed ORDER BY [intParentAuditId]

;WITH FirstLayer AS (  
	-- Fixing the entries that has NULL ids but the prior record (ARRAY) has Id value and they share the same parent w/c means they should have the same id as well.
	SELECT  
		A.[intRowId],
		CASE WHEN ISNULL(A.[intAuditId], 0) = 0 THEN C.[intAuditId] ELSE A.[intAuditId] END AS [intAuditId],  
		A.intParentAuditId, 
		A.[strAction],  
		A.[strChange],  
		A.[strKeyValue],  
		A.[strFrom],  
		A.[strTo],  
		A.[strAlias],  
		A.[ysnHidden],  
		A.[ysnField]  
	FROM @JsonTransformed A   
	OUTER APPLY (  
		SELECT TOP 1 *  
		FROM @JsonTransformed B  
		WHERE  B.[intRowId] = A.[intRowId] - 1
		AND   
		1 = CASE WHEN ISNULL(A.[strAction], '') IN ('Created', 'Updated', 'Deleted')  AND ISNULL(B.[strAction], '') = 'ARRAY' THEN 1  ELSE 0  END  AND ISNULL(A.[ysnField], '') = ''  
		ORDER BY B.[intRowId] DESC
	) C   
 ), SecondLayer AS (
	-- Fixing the entries that has NULL ids but the next record (ARRAY) has Id value and they share the same parent w/c means they should have the same id as well.
	SELECT  
		A.[intRowId],
		CASE WHEN ISNULL(A.[intAuditId], 0) = 0 THEN C.[intAuditId] ELSE A.[intAuditId] END AS [intAuditId],  
		A.intParentAuditId, 
		A.[strAction],  
		A.[strChange],  
		A.[strKeyValue],  
		A.[strFrom],  
		A.[strTo],  
		A.[strAlias],  
		A.[ysnHidden],  
		A.[ysnField]  
	FROM FirstLayer  A
	OUTER APPLY (  
		SELECT TOP 1 *  
		FROM FirstLayer B  
		WHERE  B.[intRowId] = A.[intRowId] + 1
		AND   
		1 = CASE WHEN (ISNULL(A.[strAction], '') = '' OR  ISNULL(A.[strAction], '') IN ('Created', 'Updated', 'Deleted')) AND ISNULL(B.[strAction], '') = 'ARRAY' THEN 1  ELSE 0  END  AND ISNULL(A.[ysnField], '') = ''  
		ORDER BY B.[intRowId]
	) C
 ), ThirdLayer AS (
	-- Fixing the entries that has a parent that points to an OBJECT and redirects them to the parent of the OBJECT instead.
	SELECT  
		A.[intRowId],
		A.[intAuditId],  
		ISNULL(C.intParentAuditId, A.intParentAuditId) [intParentId], 
		A.[strAction],  
		A.[strChange],  
		A.[strKeyValue],  
		A.[strFrom],  
		A.[strTo],  
		A.[strAlias],  
		A.[ysnHidden],  
		A.[ysnField]  
	FROM SecondLayer A 
	OUTER APPLY (  
		SELECT TOP 1 *  
		FROM SecondLayer B  
		WHERE  B.[intAuditId] = A.[intParentAuditId]  
		AND   
		1 = CASE WHEN ISNULL(B.[strAction], '') = 'OBJECT' THEN 1  ELSE 0  END  
	) C 
 ), FourtLayer AS (
	-- Removing the ARRAY and OBJECT entries that just serves as a mapping to the heirarchy.
	-- Also, adding a new Id column to hold the forecasted ids from the Database
	SELECT 
		CASE WHEN ROW_NUMBER() OVER (ORDER BY intParentId ASC) = 1 THEN   
			@parentAuditId 
		ELSE    
			@maxAuditId + ROW_NUMBER() OVER (ORDER BY intParentId ASC) END    AS [intNewId], 
		A.[intAuditId],  
		A.[intParentId],
		A.[strAction],  
		A.[strChange],  
		A.[strKeyValue],  
		A.[strFrom],  
		A.[strTo],  
		A.[strAlias],  
		A.[ysnHidden],  
		A.[ysnField]
	FROM ThirdLayer A WHERE A.[strAction] NOT IN ('ARRAY', 'OBJECT') 
), FifthLayer AS (
	-- Adding a new parent column to hold the right ids based on the forecasted ids
	SELECT 
		A.[intNewId] [intAuditId], 
		C.[intNewId] [intParentAuditId],
		A.[strAction],  
		A.[strChange],  
		A.[strKeyValue],  
		A.[strFrom],  
		A.[strTo],  
		A.[strAlias],  
		A.[ysnHidden],  
		A.[ysnField]
	FROM FourtLayer A
	OUTER APPLY (  
	   SELECT TOP 1 *  
	   FROM FourtLayer B  
	   WHERE  B.[intAuditId] = A.[intParentId]  
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
 SELECT 
	intAuditId,   
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
 FROM FifthLayer  
 WHERE intAuditId > @maxAuditId + 1  
  
   
 UPDATE tblSMAuditLog SET ysnProcessed = 1 WHERE intAuditLogId = @intAuditLogId  
  
 DELETE FROM @tblSMAuditLog WHERE intAuditLogId = @intAuditLogId  
END   
  
SET IDENTITY_INSERT dbo.tblSMAudit OFF;