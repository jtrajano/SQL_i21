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
	SET @children = '{"change":"' + @changeDescription + '","iconCls":"small-menu-maintenance","from":"' + @fromValue + '","to":"' + @toValue + '","leaf":true}'	
END

IF (ISNULL(@details, '') <> '')
BEGIN
	SET @children = @details
END

SET @jsonData = '{"action":"' + @actionType + '","change":"Updated - Record: 1158","iconCls":"' + @actionIcon + '","children":['+ @children +']}'

--=====================================================================================================================================
-- 	INSERT AUDIT ENTRY
---------------------------------------------------------------------------------------------------------------------------------------


INSERT INTO #tmpAuditEntries
SELECT [intID] FROM fnGetRowsFromDelimitedValues(@keyValue)


WHILE EXISTS (SELECT TOP (1) 1 FROM #tmpAuditEntries)
BEGIN
	SELECT TOP 1 @singleValue = CAST([intId] AS NVARCHAR(50)) FROM #tmpAuditEntries

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
		@actionType,
		'',
		@jsonData,
		@singleValue,
		@screenName,
		@entityId,
		1,
		GETUTCDATE()

	DELETE TOP (1) FROM #tmpAuditEntries
END

DROP TABLE #tmpAuditEntries
	
GO