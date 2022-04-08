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

DECLARE @SingleAuditLogParam SingleAuditLogParam
INSERT INTO @SingleAuditLogParam ([Id], [KeyValue], [Action], [Change], [From], [To], [Alias], [Field], [Hidden], [ParentId])
	SELECT 1, '', 'Updated', 'Updated - Record: ' + CAST(@keyValue AS VARCHAR(MAX)), NULL, NULL, NULL, NULL, NULL, NULL

WHILE EXISTS (SELECT TOP (1) 1 FROM #tmpCardNumbers)
BEGIN

	SET @counter += 1
	SELECT TOP 1 @singleValue = [strCardNumber] FROM #tmpCardNumbers

	SET @children += '{' + '"change":' +'"'+ @singleValue +'"'+ ', "iconCls": "small-gear"}'
	IF(@counter != @count)
	BEGIN
	SET @children += ','
	END

	INSERT INTO @SingleAuditLogParam ([Id], [KeyValue], [Action], [Change], [From], [To], [Alias], [Field], [Hidden], [ParentId])
		SELECT @counter + 1, '', '', @singleValue, NULL, NULL, NULL, NULL, NULL, 1

	DELETE TOP (1) FROM #tmpCardNumbers where strCardNumber = @singleValue
END

DROP TABLE #tmpCardNumbers


exec uspSMAuditLog
@screenName				 = @screenName,
@keyValue				 = @keyValue,
@entityId				 = @entityId,
@actionType				 = @action,
@changeDescription  	 = 'Locked Cards',
@details				 = @children

BEGIN TRY
EXEC uspSMSingleAuditLog 
	@screenName     = @screenName,
	@recordId       = @keyValue,
	@entityId       = @entityId,
	@AuditLogParam  = @SingleAuditLogParam
END TRY
BEGIN CATCH
END CATCH

