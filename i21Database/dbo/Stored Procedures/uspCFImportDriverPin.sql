CREATE PROCEDURE [dbo].[uspCFImportDriverPin](
	 @strGUID NVARCHAR(50)
	,@intEntityId INT
)
AS
BEGIN

	DECLARE @intTotalRead				INT
	DECLARE @intInserted				INT
	DECLARE @intNoAccountSetup			INT
	DECLARE @intDuplicate				INT
	DECLARE @intDuplicateInImportFile	INT
	
	
	DELETE FROM tblCFImportDriverPinResult
	WHERE intEntityId = @intEntityId 

	DECLARE  @tmpStagingTable TABLE
	(
		 intDriverPinStagingId		 INT
		,strAccountNumber		     NVARCHAR(MAX)
		,strDriverPinNumber			 NVARCHAR(MAX)
		,strDriverDescription		 NVARCHAR(MAX)
		,strComment					 NVARCHAR(MAX)
		,ysnActive					 BIT
		,strGUID					 NVARCHAR(MAX)
		,intEntityId				 INT
		,intRecordNo				 INT
		,ysnProcessed				 BIT
	)

	
	DECLARE  @tmpToProcess TABLE
	(
		 intDriverPinStagingId		 INT
		,strAccountNumber		     NVARCHAR(MAX)
		,strDriverPinNumber			 NVARCHAR(MAX)
		,strDriverDescription		 NVARCHAR(MAX)
		,strComment					 NVARCHAR(MAX)
		,ysnActive					 BIT
		,strGUID					 NVARCHAR(MAX)
		,intEntityId				 INT
		,intRecordNo				 INT
		,ysnProcessed				 BIT
	)

	DECLARE  @tmpNoAccountSetup TABLE
	(
		 intDriverPinStagingId		 INT
		,strAccountNumber		     NVARCHAR(MAX)
		,strDriverPinNumber			 NVARCHAR(MAX)
		,strDriverDescription		 NVARCHAR(MAX)
		,strComment					 NVARCHAR(MAX)
		,ysnActive					 BIT
		,strGUID					 NVARCHAR(MAX)
		,intEntityId				 INT
		,intRecordNo				 INT
		,ysnProcessed				 BIT
	)

	DECLARE  @tmpDuplicateDriverPin TABLE
	(
		 intDriverPinStagingId		 INT
		,strAccountNumber		     NVARCHAR(MAX)
		,strDriverPinNumber			 NVARCHAR(MAX)
		,strDriverDescription		 NVARCHAR(MAX)
		,strComment					 NVARCHAR(MAX)
		,ysnActive					 BIT
		,strGUID					 NVARCHAR(MAX)
		,intEntityId				 INT
		,intRecordNo				 INT
		,ysnProcessed				 BIT
	)

	DECLARE  @tmpDupImportDriverPin TABLE
	(
		 intDriverPinStagingId		 INT
		,strAccountNumber		     NVARCHAR(MAX)
		,strDriverPinNumber			 NVARCHAR(MAX)
		,strDriverDescription		 NVARCHAR(MAX)
		,strComment					 NVARCHAR(MAX)
		,ysnActive					 BIT
		,strGUID					 NVARCHAR(MAX)
		,intEntityId				 INT
		,intRecordNo				 INT
		,ysnProcessed				 BIT
	)

	--Select Records to Process
	INSERT INTO @tmpStagingTable
	(
		 intDriverPinStagingId
		,strAccountNumber		
		,strDriverPinNumber		
		,strDriverDescription	
		,strComment				
		,ysnActive				
		,strGUID				
		,intEntityId		
		,intRecordNo				 	
		,ysnProcessed			
	)
	SELECT
		 intDriverPinStagingId
		,strAccountNumber		
		,strDriverPinNumber		
		,strDriverDescription	
		,strComment				
		,ysnActive				
		,strGUID				
		,intEntityId		
		,intRecordNo			
		,0			
	FROM
	tblCFDriverPinStaging
	WHERE strGUID = @strGUID

	SELECT @intTotalRead = COUNT(1) FROM @tmpStagingTable


	-----------------------------------------------------------------------------
	---------------------Start Account Issue-------------------------------------
	-------------------------------------------------------------------------------
	--SELECt all records that dont have account
	INSERT INTO @tmpNoAccountSetup
	(
		 intDriverPinStagingId
		,strAccountNumber		
		,strDriverPinNumber		
		,strDriverDescription	
		,strComment				
		,ysnActive				
		,strGUID				
		,intEntityId		
		,intRecordNo			
		,ysnProcessed			
	)
	SELECT 
		intDriverPinStagingId
		,strAccountNumber		
		,strDriverPinNumber		
		,strDriverDescription	
		,strComment				
		,ysnActive				
		,strGUID				
		,intEntityId		
		,intRecordNo			
		,0			
	FROM @tmpStagingTable A
	WHERE NOT EXISTS(SELECT TOP 1 1 
					 FROM vyuCFAccountCustomer cfacc
					 WHERE cfacc.strCustomerNumber COLLATE Latin1_General_CI_AS = A.strAccountNumber COLLATE Latin1_General_CI_AS)

	SELECT @intNoAccountSetup = COUNT(1) FROM @tmpNoAccountSetup

	--Update ysnProcessed based on product code
	UPDATE @tmpStagingTable
	SET ysnProcessed = 1
	WHERE intDriverPinStagingId IN (SELECT intDriverPinStagingId FROM @tmpNoAccountSetup)

	---Insert into Import result table
	INSERT INTO tblCFImportDriverPinResult (
		intEntityId
		,strNote
		,intRecordNo
		,strAccountNumber
		,strDriverPinNumber
		)
	SELECT
		intEntityId = A.intEntityId
		,strNote = 'No account setup'
		,intRecordNo = A.intRecordNo
		,strAccountNumber
		,strDriverPinNumber
	FROM @tmpNoAccountSetup A

	
	-----------------------------------------------------------------------------
	---------------------END ACCOUNT Issue-------------------------------------
	-------------------------------------------------------------------------------

	
	-----------------------------------------------------------------------------
	---------------------Start Duplicate Issue-------------------------------------
	-------------------------------------------------------------------------------
	
	INSERT INTO @tmpDuplicateDriverPin
	(
		 intDriverPinStagingId
		,strAccountNumber		
		,strDriverPinNumber		
		,strDriverDescription	
		,strComment				
		,ysnActive				
		,strGUID				
		,intEntityId		
		,intRecordNo			
		,ysnProcessed			
	)
	SELECT 
		 intDriverPinStagingId
		,strAccountNumber		
		,strDriverPinNumber		
		,strDriverDescription	
		,strComment				
		,ysnActive				
		,strGUID				
		,intEntityId		
		,intRecordNo			
		,0		
	FROM (
		SELECT tmpStng.*, cfAcc.intAccountId, cfAcc.intCustomerId
		FROM  @tmpStagingTable tmpStng
		INNER JOIN vyuCFAccountCustomer cfAcc
		on tmpStng.strAccountNumber COLLATE Latin1_General_CI_AS = cfAcc.strCustomerNumber COLLATE Latin1_General_CI_AS
		WHERE ISNULL(tmpStng.ysnProcessed,0) = 0 
		) AS main
	WHERE 
		EXISTS(SELECT TOP 1 1 
		FROM tblCFDriverPin cfdp
		WHERE cfdp.strDriverPinNumber COLLATE Latin1_General_CI_AS = main.strDriverPinNumber COLLATE Latin1_General_CI_AS
		AND cfdp.intAccountId = main.intAccountId
		)

	SELECT @intDuplicate = COUNT(1) FROM @tmpDuplicateDriverPin

	--Update ysnProcessed based on product code
	UPDATE @tmpStagingTable
	SET ysnProcessed = 1
	WHERE intDriverPinStagingId IN (SELECT intDriverPinStagingId FROM @tmpDuplicateDriverPin)

	---Insert into Import result table
	INSERT INTO tblCFImportDriverPinResult (
		intEntityId
		,strNote
		,intRecordNo
		,strAccountNumber
		,strDriverPinNumber
		)
	SELECT
		intEntityId = A.intEntityId
		,strNote = 'Duplicate driver pin'
		,intRecordNo = A.intRecordNo
		,strAccountNumber
		,strDriverPinNumber
	FROM @tmpDuplicateDriverPin A

	
	-----------------------------------------------------------------------------
	---------------------END Duplicate Issue-------------------------------------
	-------------------------------------------------------------------------------

	-----------------------------------------------------------------------------
	---------------------Start Duplicate Issue-------------------------------------
	-------------------------------------------------------------------------------
	
	

	DECLARE @tmpDupImportDriverPinList TABLE 
	(
		 strDriverPinNumber			NVARCHAR(MAX)
	)

	
	INSERT INTO @tmpDupImportDriverPinList (strDriverPinNumber)
	SELECT strDriverPinNumber FROM @tmpStagingTable 
		WHERE ysnProcessed = 0 GROUP BY strDriverPinNumber HAVING COUNT(1) > 1

	WHILE((SELECT COUNT(1) FROM @tmpDupImportDriverPinList) > 0)
	BEGIN
		DECLARE @strLoopDriverPinNumber NVARCHAR(MAX)
		DECLARE @intLoopDriverPinStagingId  INT

		SELECT TOP 1 
		@strLoopDriverPinNumber = strDriverPinNumber
		FROM @tmpDupImportDriverPinList 

		SELECT TOP 1 
		@intLoopDriverPinStagingId = intDriverPinStagingId
		FROM @tmpStagingTable
		WHERE strDriverPinNumber = @strLoopDriverPinNumber

		INSERT INTO @tmpDupImportDriverPin
		(
			intDriverPinStagingId
			,strAccountNumber		
			,strDriverPinNumber		
			,strDriverDescription	
			,strComment				
			,ysnActive				
			,strGUID				
			,intEntityId		
			,intRecordNo			
			,ysnProcessed			
		)
		SELECT 
			intDriverPinStagingId
			,strAccountNumber		
			,strDriverPinNumber		
			,strDriverDescription	
			,strComment				
			,ysnActive				
			,strGUID				
			,intEntityId		
			,intRecordNo			
			,ysnProcessed		
		FROM @tmpStagingTable 
		WHERE ysnProcessed = 0
		AND strDriverPinNumber = @strLoopDriverPinNumber
		AND intDriverPinStagingId != @intLoopDriverPinStagingId


		DELETE FROM @tmpDupImportDriverPinList WHERE strDriverPinNumber = @strLoopDriverPinNumber

	END


	SELECT @intDuplicateInImportFile = COUNT(1) FROM @tmpDupImportDriverPin

	--Update ysnProcessed based on product code
	UPDATE @tmpStagingTable
	SET ysnProcessed = 1
	WHERE intDriverPinStagingId IN (SELECT intDriverPinStagingId FROM @tmpDupImportDriverPin)

	---Insert into Import result table
	INSERT INTO tblCFImportDriverPinResult (
		intEntityId
		,strNote
		,intRecordNo
		,strAccountNumber
		,strDriverPinNumber
		)
	SELECT
		intEntityId = A.intEntityId
		,strNote = 'Duplicate driver pin on import file'
		,intRecordNo = A.intRecordNo
		,strAccountNumber
		,strDriverPinNumber
	FROM @tmpDupImportDriverPin A

	-----------------------------------------------------------------------------
	---------------------End Duplicate Issue-------------------------------------
	-------------------------------------------------------------------------------


	--get valid data with ysnProcessed = 0
	INSERT INTO @tmpToProcess
	(
		intDriverPinStagingId
		,strAccountNumber		
		,strDriverPinNumber		
		,strDriverDescription	
		,strComment				
		,ysnActive				
		,strGUID				
		,intEntityId		
		,intRecordNo			
		,ysnProcessed			
	)
	SELECT 
		intDriverPinStagingId
		,strAccountNumber		
		,strDriverPinNumber		
		,strDriverDescription	
		,strComment				
		,ysnActive				
		,strGUID				
		,intEntityId		
		,intRecordNo			
		,ysnProcessed		
	FROM @tmpStagingTable 
	WHERE ysnProcessed = 0
	

	---- GEt Count of records to be inserted
	SELECT @intInserted = COUNT(1)
	FROM  @tmpToProcess A


	---Insert records into tblCFNetworkCost
	INSERT INTO tblCFDriverPin(
		 intAccountId
		,strDriverPinNumber
		,strDriverDescription
		,ysnActive
		,strComment
	)
	SELECT	
		intAccountId = (SELECT TOP 1 intAccountId FROM vyuCFAccountCustomer WHERE strCustomerNumber COLLATE Latin1_General_CI_AS = main.strAccountNumber COLLATE Latin1_General_CI_AS)
		,strDriverPinNumber
		,strDriverDescription
		,ysnActive
		,strComment
	FROM @tmpToProcess AS main
	
	SELECT 
		 intInserted = @intInserted
		,intTotalRead = @intTotalRead
		,intNoAccountSetup = @intNoAccountSetup
		,intDuplicate = @intDuplicate
		,intDuplicateInImportFile = @intDuplicateInImportFile
	

	------------------------------------------------------------------------------------
	------------END No Validation Issues on Site and product------------------------
	-------------------------------------------------------------------------------
    
END


