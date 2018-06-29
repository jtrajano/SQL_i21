--=====================================================================================================================================
-- 	CREATE THE STORED PROCEDURE AFTER DELETING IT
---------------------------------------------------------------------------------------------------------------------------------------
CREATE PROCEDURE [dbo].[uspCFCardLockAuditLog]
	@screenName			AS NVARCHAR(100),
	@keyValue			AS NVARCHAR(MAX),
	@entityId			AS INT,
	@action				AS NVARCHAR(50),
	@cardnumbers		AS NVARCHAR(MAX) = ''

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
DECLARE @count AS INT = 0

--=====================================================================================================================================
-- 	DECLARE TEMPORARY TABLES
---------------------------------------------------------------------------------------------------------------------------------------
CREATE TABLE #tmpCardNumbers (
	[strCardNumber] NVARCHAR(150)
);



--=====================================================================================================================================
-- 	INSERT AUDIT ENTRY
---------------------------------------------------------------------------------------------------------------------------------------


INSERT INTO #tmpCardNumbers
SELECT Record FROM [fnCFSplitString](@cardnumbers,'|^|')
SELECT @count = Count(*) FROM #tmpCardNumbers


--=====================================================================================================================================
-- 	COMPOSE JSON DATA
---------------------------------------------------------------------------------------------------------------------------------------


DECLARE @counter INT
SET @counter = 0
WHILE EXISTS (SELECT TOP (1) 1 FROM #tmpCardNumbers)
BEGIN

	SET @counter += 1
	SELECT TOP 1 @singleValue = [strCardNumber] FROM #tmpCardNumbers

	SET @children += '{' + '"change":' +'"'+ @singleValue +'"'+ ', "iconCls": "small-gear"}'
	IF(@counter != @count)
	BEGIN
	SET @children += ','
	END

	DELETE TOP (1) FROM #tmpCardNumbers where strCardNumber = @singleValue
END

DROP TABLE #tmpCardNumbers

SET @jsonData = '{"action":"' + @action  + '","change":"' + @action + ' ' + CONVERT(NVARCHAR(MAX),@count) + ' cards' + '","iconCls":"' + 'small-gear' + '","children":['+ @children +']}'
INSERT INTO tblSMAuditLog (
		strActionType,
		strDescription,
		strJsonData,
		strRecordNo,
		strTransactionType,
		intEntityId,
		intConcurrencyId,
		dtmDate
	) SELECT 
		@action,
		'',
		@jsonData,
		@keyValue,
		@screenName,
		@entityId,
		1,
		GETUTCDATE()