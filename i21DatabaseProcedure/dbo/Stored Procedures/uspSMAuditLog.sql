--=====================================================================================================================================
-- 	CREATE THE STORED PROCEDURE AFTER DELETING IT
---------------------------------------------------------------------------------------------------------------------------------------
CREATE PROCEDURE [dbo].[uspSMAuditLog]
	@screenName			AS NVARCHAR(100),
	@keyValue			AS NVARCHAR(MAX),
	@entityId			AS INT,
	@actionType			AS NVARCHAR(50),
	@actionIcon			AS NVARCHAR(50) = 'small-menu-maintenance', -- 'small-new-plus', 'small-new-minus',
	--====================================================================================================
	-- THIS PART WILL APPEAR AS A CHILD ON THE TREE
	------------------------------------------------------------------------------------------------------
	@changeDescription  AS NVARCHAR(255) = '',
	@fromValue			AS NVARCHAR(255) = '',
	@toValue			AS NVARCHAR(255) = '',
	@details			AS NVARCHAR(MAX) = ''
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON

--=====================================================================================================================================
-- 	VARIABLE DECLARATIONS
---------------------------------------------------------------------------------------------------------------------------------------

DECLARE @children AS NVARCHAR(MAX) = ''
DECLARE @jsonData AS NVARCHAR(MAX) = ''
DECLARE @singleValue AS NVARCHAR(MAX) = ''

--=====================================================================================================================================
-- 	DECLARE TEMPORARY TABLES
---------------------------------------------------------------------------------------------------------------------------------------
CREATE TABLE #tmpAuditEntries (
	[intId] INT
);

--=====================================================================================================================================
-- 	COMPOSE JSON DATA
---------------------------------------------------------------------------------------------------------------------------------------

IF (ISNULL(@changeDescription, '') <> '')
BEGIN
	SET @children = '{"change":"' + ISNULL(@changeDescription,'') + '","iconCls":"small-menu-maintenance","from":"' + ISNULL(@fromValue,'') + '","to":"' + ISNULL(@toValue,'') + '","leaf":true}'	
END

IF (ISNULL(@details, '') <> '')
BEGIN
	SET @children = @details
END

SET @jsonData = '{"action":"' + ISNULL(@actionType,'') + '","change":"Updated - Record: ' + ISNULL(@keyValue,'') + '","iconCls":"' + ISNULL(@actionIcon,'') + '","children":['+ ISNULL(@children,'') +']}'

--=====================================================================================================================================
-- 	INSERT AUDIT ENTRY
---------------------------------------------------------------------------------------------------------------------------------------


INSERT INTO #tmpAuditEntries
SELECT [intID] FROM fnGetRowsFromDelimitedValues(@keyValue)

declare @output INT;
--INSERT on tblSMTransaction
EXEC uspSMInsertTransaction @intKeyValue = @keyValue , @screenNamespace = @screenName, @output = @output

WHILE EXISTS (SELECT TOP (1) 1 FROM #tmpAuditEntries)
BEGIN
	SELECT TOP 1 @singleValue = CAST([intId] AS NVARCHAR(50)) FROM #tmpAuditEntries

	DECLARE @intTransactionID INT = NULL;
	DECLARE @intScreenId INT = (SELECT intScreenId FROM tblSMScreen WHERE strNamespace = @screenName)
	SET @intTransactionID = (SELECT intTransactionId FROM tblSMTransaction WHERE intScreenId = @intScreenId AND intRecordId = CAST(@singleValue AS INT))

	INSERT INTO tblSMLog(
		strType,
		intEntityId,
		intTransactionId,
		strRoute,
		dtmDate,
		intConcurrencyId
		) SELECT
			'Audit',
			@entityId,
			@intTransactionID,
			NULL,
			GETUTCDATE(),
			1

	 DECLARE @intLogId INT = (SELECT SCOPE_IDENTITY())
	 IF (@actionType != 'Created')
		BEGIN


			DECLARE @json AS NVARCHAR(MAX);
			SET @json = @jsonData;

			IF OBJECT_ID('tempdb..#tempSMAudit') IS NOT NULL
			DROP TABLE #tempSMAudit

			CREATE TABLE #tempSMAudit
			(
				[row] INT,
				[parent] INT,
				[strAction] NVARCHAR(MAX),
				[strChange] NVARCHAR(MAX),
				[strKeyValue] NVARCHAR(MAX),
				[strFrom] NVARCHAR(MAX),
				[strTo] NVARCHAR(MAX),
				[strAlias] NVARCHAR(MAX),
				[ysnField] BIT,
				[ysnHidden] BIT,
				[realId] INT NULL
			);

WITH Audit_CTE AS (
	SELECT 
	  ROW_NUMBER() OVER (ORDER BY parent asc) as [row], 
	--  min(case SourceTable.[name] when 'children' then id end) as [id]
	--, 
	  SourceTable.parent
	, min(case SourceTable.[name]  when 'action' then value end) as [strAction]
	, min(case SourceTable.[name]  when 'change' then value end) as [strChange]
	, min(case SourceTable.[name]  when 'keyValue' then value end) as [strKeyValue]
	, min(case SourceTable.[name]  when 'from' then value end) as [strFrom]
	, min(case SourceTable.[name] when 'to' then value end) as [strTo]
	, min(case SourceTable.[name] when 'changeDescription' then value end) as [strAlias]
	, min(case SourceTable.[name] when 'hidden' then value end) as [ysnHidden]
	, min(case SourceTable.[name] when 'isField' then value end) as [ysnField]
	from (
	SELECT * 
			FROM fnSMJson_Parse(REPLACE(REPLACE(@json, ':null', ':"null"'), ',"children":[]', ''))
			WHERE [name] NOT IN ('leaf', 'iconCls') AND ([kind] <> 'OBJECT')
			
		--select * from fnSMJson_Parse(REPLACE(@json, ':null', ':"null"')) where [name] NOT IN ('leaf', 'iconCls') AND ([kind] <> 'OBJECT')
	) SourceTable 
	group by SourceTable.parent
)
INSERT INTO #tempSMAudit --INSERT STATEMENT
SELECT
	A.[row],
	C.[row] AS [parent],
	A.[strAction],
	A.[strChange],
	A.[strKeyValue],
	A.[strFrom],
	A.[strTo],
	A.[strAlias],
	A.[ysnField],
	A.[ysnHidden],
	NULL
FROM Audit_CTE A 
OUTER APPLY (
	SELECT TOP 1 *
	FROM Audit_CTE B
	WHERE  B.[row] < A.[row] AND 
	1 = CASE WHEN ISNULL(A.[strAction], '') = '' AND ISNULL(B.[strAction], '') <> '' THEN 1 ELSE 
			CASE WHEN ISNULL(A.[strAction], '') <> '' AND ISNULL(B.[strAction], '') = '' AND ISNULL(B.[strFrom], '') = '' AND ISNULL(B.[strTo], '') = '' 
				THEN 1 ELSE 0  
			END
		END 
	ORDER BY B.[row] DESC
) C


WHILE EXISTS(SELECT TOP (1) 1 FROM #tempSMAudit WHERE realId IS NULL)
	BEGIN
		DECLARE @rowId INT;
		DECLARE @newId INT;
		DECLARE @parent INT;

		SELECT TOP 1 @rowId = [row] , @parent = parent
		FROM #tempSMAudit WHERE realId IS NULL

		INSERT INTO tblSMAudit(intLogId, intKeyValue, strAction,strChange, strFrom, strTo, strAlias, ysnField, ysnHidden, intParentAuditId, intConcurrencyId)
			SELECT @intLogId, 
					strKeyValue, 
					strAction,
					strChange,
					strFrom,
					strTo,
					strAlias,
					ysnField,
					ysnHidden,
					NULL,
					1 
					FROM #tempSMAudit WHERE [row] = @rowId

		SET @newId = (SELECT SCOPE_IDENTITY())

					UPDATE #tempSMAudit SET realId = @newId WHERE [row] = @rowId

		IF(@parent IS NOT NULL) 
			BEGIN
				DECLARE @realId INT = (SELECT realId FROM #tempSMAudit WHERE [row] = @parent)
					UPDATE tblSMAudit SET intParentAuditId = @realId WHERE intAuditId = @newId
			END

	END


END
	ELSE
		BEGIN
			INSERT INTO tblSMAudit(intLogId, intKeyValue, strAction, intConcurrencyId)
				VALUES(@intLogId, @keyValue,@actionType, 1)
		END
	--INSERT INTO tblSMAuditLog (
	--	strActionType,
	--	strDescription,
	--	strJsonData,
	--	strRecordNo,
	--	strTransactionType,
	--	intEntityId,
	--	intConcurrencyId,
	--	dtmDate
	--) SELECT 
	--	@actionType,
	--	'',
	--	@jsonData,
	--	@singleValue,
	--	@screenName,
	--	@entityId,
	--	1,
	--	GETUTCDATE()

	DELETE TOP (1) FROM #tmpAuditEntries
END

DROP TABLE #tmpAuditEntries
	
GO