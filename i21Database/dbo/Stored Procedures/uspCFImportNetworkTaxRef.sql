CREATE PROCEDURE [dbo].[uspCFImportNetworkTaxRef](
	@strGUID NVARCHAR(50)
	,@intNetworkId INT
	,@intEntityId INT
)
AS
BEGIN

	DECLARE @intTotalRead INT
	DECLARE @intInserted INT
	DECLARE @intUpdated INT
	DECLARE @intNoTaxCodeSetup INT
	DECLARE @intNoInvalidData INT
	DECLARE @intNoInvalidNetworkTaxCodeSetup INT
	DECLARE @intNoDuplicateRecord INT
	DECLARE @intNoItemCategorySetup INT
	DECLARE @strNetworkType NVARCHAR(MAX)


	SELECT TOP 1 @strNetworkType = LOWER(LTRIM(RTRIM(strNetworkType))) FROM tblCFNetwork where intNetworkId = @intNetworkId

	DECLARE @CFNTaxCodes TABLE 
	(
		strNetworkTaxCode NVARCHAR(MAX)
	)

	INSERT INTO @CFNTaxCodes
	(
		strNetworkTaxCode
	)
	VALUES 
    ('Federal Excise Tax 1'),
    ('Federal Excise Tax 2'),
    ('State Excise Tax 1'),
    ('State Excise Tax 2'),
    ('State Excise Tax 3'),
    ('County Tax 1'),
    ('City Tax 1'),
    ('State Sales Tax'),
    ('County Sales Tax'),
    ('City Sales Tax' )

	


	DECLARE @PacPrideTaxCodes TABLE 
	(
		strNetworkTaxCode NVARCHAR(MAX)
	)

	INSERT INTO @PacPrideTaxCodes
	(
		strNetworkTaxCode
	)
	VALUES   ('Federal Excise Tax Rate')
            ,('State Excise Tax Rate 1')
            ,('State Excise Tax Rate 2')
            ,('County Excise Tax Rate' )
            ,('City Excise Tax Rate')
            ,('State Sales Tax Percentage Rate' )
            ,('County Sales Tax Percentage Rate')
            ,('City Sales Tax Percentage Rate' )
            ,('Other Sales Tax Percentage Rate' )
            ,('Federal Excise Tax 1' )
            ,('Federal Excise Tax 2' )
            ,('State Excise Tax 1' )
            ,('State Excise Tax 2' )
            ,('State Excise Tax 3' )
            ,('County Tax 1' )
            ,('City Tax 1' )
            ,('State Sales Tax' )
            ,('County Sales Tax' )
            ,('City Sales Tax' )


	--DECLARE @strGUID NVARCHAR
	--DECLARE @intNetworkId INT
	--DECLARE @intEntityId INT

	--SET @intNetworkId = 1
	--SET  @strGUID = 'a30fe1a0-a715-468b-8a1d-7ed748a357a6'
	--SET @intEntityId = 1

	---clear Import Log
	DELETE FROM tblCFImportNetworkTaxRefResult
	WHERE intEntityId = @intEntityId 

	--DELETE tblCFNetworkTaxRefStaging 
	--FROM (
	--SELECT 
	--strSiteNumber,dtmDate,strItemNumber,intEntityId, MAX(intRecordNo) intLastRecord
	--FROM tblCFNetworkTaxRefStaging GROUP BY strSiteNumber,dtmDate,strItemNumber,intEntityId HAVING COUNT(1) > 1) as tblGroupData
	--WHERE 
	--tblCFNetworkTaxRefStaging.strSiteNumber = tblGroupData.strSiteNumber
	--AND tblCFNetworkTaxRefStaging.dtmDate = tblGroupData.dtmDate
	--AND tblCFNetworkTaxRefStaging.strItemNumber = tblGroupData.strItemNumber
	--AND tblCFNetworkTaxRefStaging.intEntityId = tblGroupData.intEntityId
	--AND tblCFNetworkTaxRefStaging.intRecordNo != tblGroupData.intLastRecord



	--Select Records to Process
	IF OBJECT_ID('tempdb..#tmpStagingTable') IS NOT NULL DROP TABLE #tmpStagingTable	
	SELECT 
		*
		,ysnProcessed = 0
	INTO #tmpStagingTable
	FROM tblCFNetworkTaxRefStaging
	WHERE strGUID = @strGUID

	SELECT @intTotalRead = COUNT(1) FROM #tmpStagingTable

	-----------------------------------------------------------------------------
	---------------------Start Invalid Issue-------------------------------------
	-------------------------------------------------------------------------------
	--SELECt all records that dont have productcode
	IF OBJECT_ID('tempdb..#tmInvalidData') IS NOT NULL DROP TABLE #tmInvalidData
	SELECT 
		*
	INTO #tmInvalidData
	FROM #tmpStagingTable A
	WHERE ISNULL(ysnInvalidData,0) = 1


	SELECT @intNoInvalidData = COUNT(1) FROM #tmInvalidData

	--Update ysnProcessed based on product code
	UPDATE #tmpStagingTable
	SET ysnProcessed = 1
	FROM #tmInvalidData A
	WHERE A.intNetworkTaxRefStagingId = #tmpStagingTable.intNetworkTaxRefStagingId


	---Insert into Import result table
	INSERT INTO tblCFImportNetworkTaxRefResult (
		 intEntityId
		,strNote
		,strItemCategory		
		,strNetworkTaxCode		
		,strDescription		
		,strState			
		,strTaxCode			
		,intRecordNo)
	SELECT
		 intEntityId
		,'Invalid Data'
		,strItemCategory		
		,strNetworkTaxCode		
		,strDescription		
		,strState			
		,strTaxCode
		,intRecordNo			
	FROM #tmInvalidData A


	-----------------------------------------------------------------------------
	---------------------Start Network Tax Code Issue-------------------------------------
	-------------------------------------------------------------------------------
	--SELECt all records that dont have productcode
	IF(@strNetworkType = 'pacpride' OR @strNetworkType = 'pac pride')
	BEGIN 
		IF OBJECT_ID('tempdb..#tmNoPacprideNetworkTaxCodeSetup') IS NOT NULL DROP TABLE #tmNoPacprideNetworkTaxCodeSetup
		SELECT 
			*
		INTO #tmNoPacprideNetworkTaxCodeSetup
		FROM #tmpStagingTable A
		WHERE NOT EXISTS(SELECT TOP 1 1 FROM @PacPrideTaxCodes 
							WHERE strNetworkTaxCode COLLATE Latin1_General_CI_AS = A.strNetworkTaxCode COLLATE Latin1_General_CI_AS)
							AND ISNULL(ysnInvalidData,0) = 0

		SELECT @intNoInvalidNetworkTaxCodeSetup = COUNT(1) FROM #tmNoPacprideNetworkTaxCodeSetup

		--Update ysnProcessed based on product code
		UPDATE #tmpStagingTable
		SET ysnProcessed = 1
		FROM #tmNoPacprideNetworkTaxCodeSetup A
		WHERE A.intNetworkTaxRefStagingId = #tmpStagingTable.intNetworkTaxRefStagingId

		---Insert into Import result table
		INSERT INTO tblCFImportNetworkTaxRefResult (
			 intEntityId
			,strNote
			,strItemCategory		
			,strNetworkTaxCode		
			,strDescription		
			,strState			
			,strTaxCode			
			,intRecordNo)
		SELECT
			 intEntityId
			,'Invalid Network Tax Code'
			,strItemCategory		
			,strNetworkTaxCode		
			,strDescription		
			,strState			
			,strTaxCode
			,intRecordNo			
		FROM #tmNoPacprideNetworkTaxCodeSetup A

	END


	IF(@strNetworkType = 'cfn')
	BEGIN 
		IF OBJECT_ID('tempdb..#tmNoCFNNetworkTaxCodeSetup') IS NOT NULL DROP TABLE #tmNoCFNNetworkTaxCodeSetup
		SELECT 
			*
		INTO #tmNoCFNNetworkTaxCodeSetup
		FROM #tmpStagingTable A
		WHERE NOT EXISTS(SELECT TOP 1 1 FROM @CFNTaxCodes 
							WHERE strNetworkTaxCode COLLATE Latin1_General_CI_AS = A.strNetworkTaxCode COLLATE Latin1_General_CI_AS)
							AND ISNULL(ysnInvalidData,0) = 0

		SELECT @intNoInvalidNetworkTaxCodeSetup = COUNT(1) FROM #tmNoCFNNetworkTaxCodeSetup

		--Update ysnProcessed based on product code
		UPDATE #tmpStagingTable
		SET ysnProcessed = 1
		FROM #tmNoCFNNetworkTaxCodeSetup A
		WHERE A.intNetworkTaxRefStagingId = #tmpStagingTable.intNetworkTaxRefStagingId

		---Insert into Import result table
		INSERT INTO tblCFImportNetworkTaxRefResult (
			 intEntityId
			,strNote
			,strItemCategory		
			,strNetworkTaxCode		
			,strDescription		
			,strState			
			,strTaxCode			
			,intRecordNo)
		SELECT
			 intEntityId
			,'Invalid Network Tax Code'
			,strItemCategory		
			,strNetworkTaxCode		
			,strDescription		
			,strState			
			,strTaxCode
			,intRecordNo			
		FROM #tmNoCFNNetworkTaxCodeSetup A

	END

	
	-----------------------------------------------------------------------------
	---------------------END Network Tax Code Issue-------------------------------------
	-------------------------------------------------------------------------------


	-----------------------------------------------------------------------------
	---------------------Start Tax Code Issue-------------------------------------
	-------------------------------------------------------------------------------
	--SELECt all records that dont have productcode
	IF OBJECT_ID('tempdb..#tmNoTaxCodeSetup') IS NOT NULL DROP TABLE #tmNoTaxCodeSetup
	SELECT 
		*
	INTO #tmNoTaxCodeSetup
	FROM #tmpStagingTable A
	WHERE NOT EXISTS(SELECT TOP 1 1 FROM tblSMTaxCode 
						WHERE strTaxCode COLLATE Latin1_General_CI_AS = A.strTaxCode COLLATE Latin1_General_CI_AS)
						AND ISNULL(ysnInvalidData,0) = 0

	SELECT @intNoTaxCodeSetup = COUNT(1) FROM #tmNoTaxCodeSetup

	--Update ysnProcessed based on product code
	UPDATE #tmpStagingTable
	SET ysnProcessed = 1
	FROM #tmNoTaxCodeSetup A
	WHERE A.intNetworkTaxRefStagingId = #tmpStagingTable.intNetworkTaxRefStagingId


	---Insert into Import result table
	INSERT INTO tblCFImportNetworkTaxRefResult (
		 intEntityId
		,strNote
		,strItemCategory		
		,strNetworkTaxCode		
		,strDescription		
		,strState			
		,strTaxCode			
		,intRecordNo)
	SELECT
		 intEntityId
		,'No Tax Code Setup'
		,strItemCategory		
		,strNetworkTaxCode		
		,strDescription		
		,strState			
		,strTaxCode
		,intRecordNo			
	FROM #tmNoTaxCodeSetup A
	
	-----------------------------------------------------------------------------
	---------------------END Product Code Issue-------------------------------------
	-------------------------------------------------------------------------------


	-----------------------------------------------------------------------------
	---------------------Start Item Category Code Issue-------------------------------------
	-------------------------------------------------------------------------------
	--SELECt all records that dont have productcode
	IF OBJECT_ID('tempdb..#tmNoItemCategorySetup') IS NOT NULL DROP TABLE #tmNoItemCategorySetup
	SELECT 
		*
	INTO #tmNoItemCategorySetup
	FROM #tmpStagingTable A
	WHERE  ISNULL(A.strItemCategory,'') != '' AND NOT EXISTS(SELECT TOP 1 1 FROM tblICCategory 
						WHERE strCategoryCode COLLATE Latin1_General_CI_AS = A.strItemCategory COLLATE Latin1_General_CI_AS)
						AND ISNULL(ysnInvalidData,0) = 0

	SELECT @intNoItemCategorySetup = COUNT(1) FROM #tmNoItemCategorySetup

	--Update ysnProcessed based on product code
	UPDATE #tmpStagingTable
	SET ysnProcessed = 1
	FROM #tmNoItemCategorySetup A
	WHERE A.intNetworkTaxRefStagingId = #tmpStagingTable.intNetworkTaxRefStagingId


	---Insert into Import result table
	INSERT INTO tblCFImportNetworkTaxRefResult (
		 intEntityId
		,strNote
		,strItemCategory		
		,strNetworkTaxCode		
		,strDescription		
		,strState			
		,strTaxCode			
		,intRecordNo)
	SELECT
		 intEntityId
		,'No Item Category Setup'
		,strItemCategory		
		,strNetworkTaxCode		
		,strDescription		
		,strState			
		,strTaxCode
		,intRecordNo			
	FROM #tmNoTaxCodeSetup A
	
	-----------------------------------------------------------------------------
	---------------------END Product Code Issue-------------------------------------
	-------------------------------------------------------------------------------


	-------------------------------------------------------------------------------
	-----------------------Start Duplicate Record Issue-------------------------------------
	---------------------------------------------------------------------------------
	----SELECt all records that dont have productcode
	--IF OBJECT_ID('tempdb..#tmDuplicateRecord') IS NOT NULL DROP TABLE #tmDuplicateRecord
	--SELECT 
	--	*
	--INTO #tmDuplicateRecord
	--FROM #tmpStagingTable A
	--WHERE EXISTS(SELECT TOP 1 1 FROM tblCFNetworkTaxCode 
	--					WHERE tblCFNetworkTaxCode.intItemCategory = A.int 
	--					AND  tblCFNetworkTaxCode.intTaxCodeId =  A.intTaxCodeId 
	--					AND  tblCFNetworkTaxCode.strNetworkTaxCode = A.strNetworkTaxCode
	--					AND  tblCFNetworkTaxCode.strState = A.strState
	--					AND  tblCFNetworkTaxCode.strDescription = A.strDescription
	--					AND  tblCFNetworkTaxCode.intNetworkId = @intNetworkId)
	--					AND ISNULL(ysnInvalidData,0) = 0


	--					--WHERE EXISTS(SELECT TOP 1 1 FROM tblCFNetworkTaxCode WHERE tblCFNetworkTaxCode.intItemCategory = A.intItemCategoryId 
	----													    AND  tblCFNetworkTaxCode.intTaxCodeId =  A.intTaxCodeId 
	----													    AND  tblCFNetworkTaxCode.strNetworkTaxCode = A.strNetworkTaxCode
	----													    AND  tblCFNetworkTaxCode.strState = A.strState
	----													    AND  tblCFNetworkTaxCode.strDescription = A.strDescription
	----													    AND  tblCFNetworkTaxCode.intNetworkId = @intNetworkId)



	--SELECT @intNoDuplicateRecord = COUNT(1) FROM #tmDuplicateRecord

	----Update ysnProcessed based on product code
	--UPDATE #tmpStagingTable
	--SET ysnProcessed = 1
	--FROM #tmDuplicateRecord A
	--WHERE A.intNetworkTaxRefStagingId = #tmpStagingTable.intNetworkTaxRefStagingId


	-----Insert into Import result table
	--INSERT INTO tblCFImportNetworkTaxRefResult (
	--	 intEntityId
	--	,strNote
	--	,strItemCategory		
	--	,strNetworkTaxCode		
	--	,strDescription		
	--	,strState			
	--	,strTaxCode			
	--	,intRecordNo)
	--SELECT
	--	 intEntityId
	--	,'Duplicate Record'
	--	,strItemCategory		
	--	,strNetworkTaxCode		
	--	,strDescription		
	--	,strState			
	--	,strTaxCode
	--	,intRecordNo			
	--FROM #tmDuplicateRecord A
	
	-------------------------------------------------------------------------------
	-----------------------END Product Code Issue-------------------------------------
	---------------------------------------------------------------------------------



	------------------------------------------------------------------------------------
	------------START No Validation Issues on Site and product------------------------
	------------------------------------------------------------------------------------

	--get valid data with ysnProcessed = 0
	IF OBJECT_ID('tempdb..#tmpToProcessed') IS NOT NULL DROP TABLE #tmpToProcessed
	SELECT 
		*
	INTO #tmpToProcessed
	FROM #tmpStagingTable 
	WHERE ysnProcessed = 0


	---Get Site Id and Item Id
	IF OBJECT_ID('tempdb..#tmpNoTaxCodeIssue') IS NOT NULL DROP TABLE #tmpNoTaxCodeIssue
	SELECT
		 strItemCategory			
		,strNetworkTaxCode			
		,strDescription			
		,strState				
		,strTaxCode	= B.strTaxCode
		,intItemCategoryId = C.intCategoryId
		,intTaxCodeId = B.intTaxCodeId
		--,strGUID					
		--,intEntityId				
		--,intRecordNo				
		--,ysnInvalidData			
		--,strInvalidDataReason			
		--,intConcurrencyId	
	INTO #tmpNoTaxCodeIssue
	FROM #tmpToProcessed A
	INNER JOIN (
			SELECT DISTINCT 
				intTaxCodeId
				,strTaxCode
			FROM tblSMTaxCode 
	) B ON A.strTaxCode COLLATE Latin1_General_CI_AS = B.strTaxCode COLLATE Latin1_General_CI_AS
	INNER JOIN (
			SELECT DISTINCT
				 intCategoryId
				,strCategoryCode
			FROM tblICCategory
	) C ON C.strCategoryCode COLLATE Latin1_General_CI_AS = A.strItemCategory COLLATE Latin1_General_CI_AS


	---- GEt Count of records to update
	--SELECT @intUpdated = COUNT(1)
	--FROM  #tmpNoTaxCodeIssue A
	--WHERE EXISTS(SELECT TOP 1 1 FROM tblCFNetworkTaxCode WHERE tblCFNetworkTaxCode.intItemCategory = A.intItemCategoryId 
	--													    AND  tblCFNetworkTaxCode.intTaxCodeId =  A.intTaxCodeId 
	--													    AND  tblCFNetworkTaxCode.strNetworkTaxCode = A.strNetworkTaxCode
	--													    AND  tblCFNetworkTaxCode.strState = A.strState
	--													    AND  tblCFNetworkTaxCode.strDescription = A.strDescription
	--													    AND  tblCFNetworkTaxCode.intNetworkId = @intNetworkId)

	--------UPDATE Existing
	--UPDATE tblCFNetworkTaxCode
	--SET dblTransferCost = A.dblTransferCost
	--	,dblTaxesPerUnit = A.dblTaxesPerUnit
	--FROM  #tmpNoTaxCodeIssue A
	--WHERE tblCFNetworkTaxCode.dtmDate = A.dtmDate 
	--	AND  tblCFNetworkTaxCode.intSiteId =  A.intSiteId 
	--	AND  tblCFNetworkTaxCode.intItemId = A.intItemId
	--	AND  tblCFNetworkTaxCode.intNetworkId = @intNetworkId
	

	---- GEt Count of records to be inserted
	SELECT @intInserted = COUNT(1)
	FROM  #tmpNoTaxCodeIssue A
	WHERE NOT EXISTS(SELECT TOP 1 1 
					 FROM tblCFNetworkTaxCode 
					 WHERE tblCFNetworkTaxCode.intItemCategory = A.intItemCategoryId 
					 AND  tblCFNetworkTaxCode.intTaxCodeId =  A.intTaxCodeId 
					 AND  tblCFNetworkTaxCode.strNetworkTaxCode = A.strNetworkTaxCode
					 AND  tblCFNetworkTaxCode.strState = A.strState
					 AND  tblCFNetworkTaxCode.strDescription = A.strDescription)


	---Insert records into tblCFNetworkTaxCode
	INSERT INTO tblCFNetworkTaxCode(
		 intNetworkId
		,intItemCategory
		,strNetworkTaxCode
		,strDescription
		,strState
		,intTaxCodeId
	)
	SELECT	
		 @intNetworkId
		,intItemCategoryId
		,strNetworkTaxCode
		,strDescription
		,strState
		,intTaxCodeId
	FROM #tmpNoTaxCodeIssue A
	WHERE NOT EXISTS(SELECT TOP 1 1 
					 FROM tblCFNetworkTaxCode 
					 WHERE tblCFNetworkTaxCode.intItemCategory = A.intItemCategoryId 
						 AND  tblCFNetworkTaxCode.intTaxCodeId =  A.intTaxCodeId 
						 AND  tblCFNetworkTaxCode.strNetworkTaxCode = A.strNetworkTaxCode
						 AND  tblCFNetworkTaxCode.strState = A.strState
						 AND  tblCFNetworkTaxCode.strDescription = A.strDescription
						 AND intNetworkId = @intNetworkId)

	
	SELECT 
		 intInserted = ISNULL(@intInserted,0)
		,intTotalRead = ISNULL(@intTotalRead,0)
		--,intUpdated = @intUpdated
		,intNoInvalidNetworkTaxCodeSetup = ISNULL(@intNoInvalidNetworkTaxCodeSetup,0)
		,intNoTaxCodeSetup = ISNULL(@intNoTaxCodeSetup,0)
		,intNoItemCategorySetup = ISNULL(@intNoItemCategorySetup,0)
		,intNoInvalidData = ISNULL(@intNoInvalidData,0)
	

	------------------------------------------------------------------------------------
	------------END No Validation Issues on Site and product------------------------
	-------------------------------------------------------------------------------
    
END