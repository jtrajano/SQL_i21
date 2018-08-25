--=====================================================================================================================================
-- 	CREATE THE STORED PROCEDURE AFTER DELETING IT
---------------------------------------------------------------------------------------------------------------------------------------
CREATE PROCEDURE [dbo].[uspCFCardSycnAuditLog]
	@entityId			AS INT,
	@session			AS NVARCHAR(MAX)

AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON

--=====================================================================================================================================
-- 	VARIABLE DECLARATIONS
---------------------------------------------------------------------------------------------------------------------------------------



--=====================================================================================================================================
-- 	DECLARE TEMPORARY TABLES
---------------------------------------------------------------------------------------------------------------------------------------

DECLARE @tmpCSULogs TABLE (
	 intId					INT
	,strSessionId			NVARCHAR(MAX)
	,intPK					INT
	,strType				NVARCHAR(MAX)
	,strTableName			NVARCHAR(MAX)
	,strFieldName			NVARCHAR(MAX)
	,strOldValue			NVARCHAR(MAX)
	,strNewValue			NVARCHAR(MAX)
	,dtmUpdateDate			DATETIME
	,strUserName			NVARCHAR(MAX)
	,strRecord				NVARCHAR(MAX)
	,strAccountNumber		NVARCHAR(MAX)
);


DECLARE @tmpCSUDistinctLogs TABLE (
	intPK					INT
	,strSessionId			NVARCHAR(MAX)
);

--=====================================================================================================================================
-- 	INSERT AUDIT ENTRY
---------------------------------------------------------------------------------------------------------------------------------------

INSERT INTO @tmpCSUDistinctLogs (	
intPK	
,strSessionId
)
SELECT DISTINCT
intPK				
,strSessionId
FROM tblCFCSUAuditLog where strSessionId = @session

--=====================================================================================================================================
-- 	COMPOSE JSON DATA
---------------------------------------------------------------------------------------------------------------------------------------

DECLARE @outerloopPK				INT
DECLARE @outerloopSessionId			NVARCHAR(MAX)
--DECLARE @outerloopIcon				NVARCHAR(MAX)
--DECLARE @outerloopAction			NVARCHAR(MAX)

WHILE EXISTS (SELECT TOP (1) 1 FROM @tmpCSUDistinctLogs)
BEGIN


	SELECT TOP 1
	 @outerloopPK = intPK				
	,@outerloopSessionId = strSessionId
	FROM @tmpCSUDistinctLogs
	
	INSERT INTO @tmpCSULogs (
	 strSessionId		
	,intPK				
	,strType			
	,strTableName		
	,strFieldName		
	,strOldValue		
	,strNewValue		
	,dtmUpdateDate		
	,strUserName		
	,strRecord			
	,strAccountNumber	
	)
	SELECT 
	 strSessionId		
	,intPK				
	,strType			
	,strTableName		
	,strFieldName		
	,strOldValue		
	,strNewValue		
	,dtmUpdateDate		
	,strUserName		
	,strRecord			
	,strAccountNumber	
	FROM tblCFCSUAuditLog where strSessionId = @outerloopSessionId 
	AND intPK = @outerloopPK

	DECLARE @loopSessionId		NVARCHAR(MAX)
	DECLARE @loopPK				INT
	DECLARE @loopType			NVARCHAR(MAX)
	DECLARE @loopTableName		NVARCHAR(MAX)
	DECLARE @loopFieldName		NVARCHAR(MAX)
	DECLARE @loopOldValue		NVARCHAR(MAX)
	DECLARE @loopNewValue		NVARCHAR(MAX)
	DECLARE @loopUpdateDate		DATETIME
	DECLARE @loopUserName		NVARCHAR(MAX)
	DECLARE @loopRecord			NVARCHAR(MAX)
	DECLARE @loopAccountNumber	NVARCHAR(MAX)
	DECLARE @loopAction			NVARCHAR(MAX)
	DECLARE @loopIcon			NVARCHAR(MAX)
	DECLARE @screenName			NVARCHAR(100)

	DECLARE @children AS NVARCHAR(MAX) = ''
	DECLARE @jsonData AS NVARCHAR(MAX) = ''
	DECLARE @singleValue AS NVARCHAR(MAX) = ''
	DECLARE @count AS INT = 0

	DECLARE @counter INT
	SET @counter = 0

	SELECT @count = Count(*) FROM @tmpCSULogs

	WHILE EXISTS (SELECT TOP (1) 1 FROM @tmpCSULogs)
	BEGIN

		SET @counter += 1

		SELECT TOP 1 
		 @loopSessionId			 =  strSessionId		
		,@loopPK				 =  intPK				
		,@loopType				 =  strType			
		,@loopTableName			 =  strTableName		
		,@loopFieldName			 =  strFieldName		
		,@loopOldValue			 =  strOldValue		
		,@loopNewValue			 =  strNewValue		
		,@loopUpdateDate		 =  dtmUpdateDate		
		,@loopUserName			 =  strUserName		
		,@loopRecord			 =  strRecord			
		,@loopAccountNumber		 =  strAccountNumber
		,@loopAction			 =  (CASE WHEN strType = 'Update' THEN 'Updated' ELSE 'Created' END)
		,@screenName			 =  (CASE WHEN strTableName = 'tblCFCard' THEN 'CardFueling.view.AccountCard' ELSE 'CardFueling.view.Vehicle' END) 
		,@loopIcon				 =  (CASE WHEN strType = 'Update' THEN 'small-tree-modified' ELSE 'small-new-plus' END)
		FROM @tmpCSULogs

		SET @children += '{' + '"action":' + '"'+ @loopAction +'"' + ', "change":' + '"'+ @loopFieldName +'"' + ', "from":' + '"'+ CONVERT(NVARCHAR(MAX),ISNULL(@loopOldValue,'')) +'"' +  ', "to":' + '"'+ CONVERT(NVARCHAR(MAX),ISNULL(@loopNewValue,'')) +'"' +  ', "iconCls": "small-gear"' +  ', "leaf":true' + ', "keyValue":' +  '"'+ CONVERT(NVARCHAR(MAX),ISNULL(@loopPK,'')) + '"' + ', "hidden":false' + '}'
		IF(@counter != @count)
		BEGIN
		SET @children += ','
		END

		DELETE TOP (1) 
		FROM @tmpCSULogs 
		WHERE strSessionId		  =  @loopSessionId		
		AND intPK				  =  @loopPK			
		AND strFieldName		  =  @loopFieldName		
	END


--DROP TABLE #tmpCardNumbers
	

	SET @jsonData = '{"action":"' + @loopAction + ' via Card Synchronization'  + '","change":"' + @loopAction + ' ' + CONVERT(NVARCHAR(MAX),@count) + ' records' + '","iconCls":"' + @loopIcon +  '"' + ', "keyValue":' +  '"'+ CONVERT(NVARCHAR(MAX),ISNULL(@outerloopPK,'')) + '","children":['+ '{"change":"",' + '"children":[' + @children +'],"iconCls":"small-tree-grid","changeDescription":"Updated Fields"}]}'
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
			@loopAction,
			'',
			@jsonData,
			@loopPK,
			@screenName,
			@entityId,
			1,
			GETUTCDATE()

	DELETE 
	FROM @tmpCSUDistinctLogs
	WHERE intPK = @outerloopPK			
	AND strSessionId = @outerloopSessionId

END

