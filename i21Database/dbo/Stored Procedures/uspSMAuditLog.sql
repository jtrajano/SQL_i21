--=====================================================================================================================================
-- 	CREATE THE STORED PROCEDURE AFTER DELETING IT
---------------------------------------------------------------------------------------------------------------------------------------
CREATE PROCEDURE [dbo].[uspSMAuditLog]
	@screenName			AS NVARCHAR(100),
	@keyValue			AS NVARCHAR(50),
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
	@keyValue,
	@screenName,
	@entityId,
	1,
	GETDATE()
	
GO