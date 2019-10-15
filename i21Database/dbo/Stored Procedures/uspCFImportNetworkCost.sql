CREATE PROCEDURE [dbo].[uspCFImportNetworkCost](
	@strGUID NVARCHAR(50)
	,@intNetworkId INT
	,@intEntityId INT
)
AS
BEGIN

	DECLARE @intTotalRead INT
	DECLARE @intInserted INT
	DECLARE @intUpdated INT
	DECLARE @intNoProductSetup INT
	DECLARE @intNoInvalidData INT
	DECLARE @intNoSiteSetup INT

	--DECLARE @strGUID NVARCHAR
	--DECLARE @intNetworkId INT
	--DECLARE @intEntityId INT

	--SET @intNetworkId = 1
	--SET  @strGUID = 'a30fe1a0-a715-468b-8a1d-7ed748a357a6'
	--SET @intEntityId = 1

	---clear Import Log
	DELETE FROM tblCFImportNetworkCostResult
	WHERE intEntityId = @intEntityId 



	--Select Records to Process
	IF OBJECT_ID('tempdb..#tmpStagingTable') IS NOT NULL DROP TABLE #tmpStagingTable	
	SELECT 
		*
		,ysnProcessed = 0
	INTO #tmpStagingTable
	FROM tblCFNetworkCostStaging
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
	WHERE A.intNetworkCostStagingId = #tmpStagingTable.intNetworkCostStagingId


	---Insert into Import result table
	INSERT INTO tblCFImportNetworkCostResult (
		intEntityId
		,strNote
		,strSiteNumber
		,strProductNumber
		,intRecordNo)
	SELECT
		intEntityId = A.intEntityId
		,strNote = 'Invalid Data'
		,strSiteNumber = A.strSiteNumber
		,strProductNumber = A.strItemNumber
		,intRecordNo = A.intRecordNo
	FROM #tmInvalidData A

	-----------------------------------------------------------------------------
	---------------------Start Product Code Issue-------------------------------------
	-------------------------------------------------------------------------------
	--SELECt all records that dont have productcode
	IF OBJECT_ID('tempdb..#tmNoProductCodeSetup') IS NOT NULL DROP TABLE #tmNoProductCodeSetup
	SELECT 
		*
	INTO #tmNoProductCodeSetup
	FROM #tmpStagingTable A
	WHERE NOT EXISTS(SELECT TOP 1 1 FROM tblCFItem 
						WHERE strProductNumber COLLATE Latin1_General_CI_AS = A.strItemNumber COLLATE Latin1_General_CI_AS
							AND intNetworkId = @intNetworkId)
							AND ISNULL(ysnInvalidData,0) = 0

	SELECT @intNoProductSetup = COUNT(1) FROM #tmNoProductCodeSetup

	--Update ysnProcessed based on product code
	UPDATE #tmpStagingTable
	SET ysnProcessed = 1
	FROM #tmNoProductCodeSetup A
	WHERE A.intNetworkCostStagingId = #tmpStagingTable.intNetworkCostStagingId


	---Insert into Import result table
	INSERT INTO tblCFImportNetworkCostResult (
		intEntityId
		,strNote
		,strSiteNumber
		,strProductNumber
		,intRecordNo)
	SELECT
		intEntityId = A.intEntityId
		,strNote = 'No Product Code Setup'
		,strSiteNumber = A.strSiteNumber
		,strProductNumber = A.strItemNumber
		,intRecordNo = A.intRecordNo
	FROM #tmNoProductCodeSetup A

	
	-----------------------------------------------------------------------------
	---------------------END Product Code Issue-------------------------------------
	-------------------------------------------------------------------------------


	-----------------------------------------------------------------------------
	---------------------Start Site Issue-------------------------------------
	-------------------------------------------------------------------------------

	--Select all records that don't have a Site Records
	IF OBJECT_ID('tempdb..#tmpNoSiteRecords') IS NOT NULL DROP TABLE #tmpNoSiteRecords
	SELECT 
		*
	INTO #tmpNoSiteRecords
	FROM #tmpStagingTable A
	WHERE A.ysnProcessed = 0
		AND NOT EXISTS(SELECT TOP 1 1 
						FROM tblCFSite 
						WHERE strSiteNumber COLLATE Latin1_General_CI_AS = A.strSiteNumber COLLATE Latin1_General_CI_AS
							AND intNetworkId = @intNetworkId)
							AND ISNULL(ysnInvalidData,0) = 0

	SELECT @intNoSiteSetup = COUNT(1) FROM #tmpNoSiteRecords
	
	--Update ysnProcessed based on site
	UPDATE #tmpStagingTable
	SET ysnProcessed = 1
	FROM #tmpNoSiteRecords A
	WHERE A.intNetworkCostStagingId = #tmpStagingTable.intNetworkCostStagingId



	
	----------------------------- CF-1819 -------------------------------------
	---Insert Site
	--INSERT INTO tblCFSite(
	--	intNetworkId 
	--	,strSiteType
	--	,intARLocationId
	--	,strControllerType
	--	,strSiteNumber
	--	,strSiteName
	--	,strPPSiteType
	--)
	--SELECT DISTINCT
	--	intNetworkId = @intNetworkId
	--	,strSiteType = 'Remote'
	--	,intARLocationId = B.intLocationId
	--	,strControllerType = 'PacPride'
	--	,strSiteNumber = A.strSiteNumber
	--	,strSiteName = A.strSiteNumber
	--	,strPPSiteType = 'Network'
	--FROM #tmpNoSiteRecords A 
	--	,(SELECT TOP 1 intLocationId 
	--		FROM tblCFNetwork
	--		WHERE intNetworkId = @intNetworkId) B

	
	---Get Site Id and Item Id
	--IF OBJECT_ID('tempdb..#tmpWithSiteIssue') IS NOT NULL DROP TABLE #tmpWithSiteIssue
	--SELECT
	--		intSiteId = C.intSiteId
	--		,dtmDate = A.dtmDate
	--		,intItemId = B.intARItemId
	--		,A.dblTransferCost
	--		,A.dblTaxesPerUnit
	--INTO #tmpWithSiteIssue
	--FROM #tmpNoSiteRecords A
	--INNER JOIN (
	--		SELECT DISTINCT 
	--			intARItemId
	--			,strProductNumber
	--		FROM tblCFItem 
	--		WHERE intNetworkId = @intNetworkId
	--) B ON A.strItemNumber COLLATE Latin1_General_CI_AS = B.strProductNumber COLLATE Latin1_General_CI_AS
	--INNER JOIN (
	--		SELECT DISTINCT
	--			intSiteId
	--			,strSiteNumber
	--		FROM tblCFSite
	--		WHERE intNetworkId = @intNetworkId	
	--) C ON A.strSiteNumber COLLATE Latin1_General_CI_AS = C.strSiteNumber COLLATE Latin1_General_CI_AS
	----------------------------- CF-1819 -------------------------------------


	----------------------------- CF-1819 -------------------------------------
	-----Insert records into tblCFNetworkCost
	--INSERT INTO tblCFNetworkCost(
	--	intSiteId 
	--	,dtmDate
	--	,intItemId
	--	,dblTransferCost
	--	,dblTaxesPerUnit
	--	,intNetworkId
	--)
	--SELECT 
	--	intSiteId = A.intSiteId
	--	,dtmDate = A.dtmDate
	--	,intItemId = A.intItemId
	--	,dblTransferCost = A.dblTransferCost
	--	,dblTaxesPerUnit  = A.dblTaxesPerUnit
	--	,intNetworkId = @intNetworkId
	--FROM #tmpWithSiteIssue A
	----------------------------- CF-1819 -------------------------------------

	-----------------------------------------------------------------------------
	---------------------End Site Issue-------------------------------------
	-------------------------------------------------------------------------------


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
	IF OBJECT_ID('tempdb..#tmpNoSiteItemIssue') IS NOT NULL DROP TABLE #tmpNoSiteItemIssue
	SELECT
			intSiteId = C.intSiteId
			,dtmDate = A.dtmDate
			,intItemId = B.intARItemId
			,A.dblTransferCost
			,A.dblTaxesPerUnit
	INTO #tmpNoSiteItemIssue
	FROM #tmpToProcessed A
	INNER JOIN (
			SELECT DISTINCT 
				intARItemId
				,strProductNumber
			FROM tblCFItem 
			WHERE intNetworkId = @intNetworkId
	) B ON A.strItemNumber COLLATE Latin1_General_CI_AS = B.strProductNumber COLLATE Latin1_General_CI_AS
	INNER JOIN (
			SELECT DISTINCT
				intSiteId
				,strSiteNumber
			FROM tblCFSite
			WHERE intNetworkId = @intNetworkId	
	) C ON A.strSiteNumber COLLATE Latin1_General_CI_AS = C.strSiteNumber COLLATE Latin1_General_CI_AS


	---- GEt Count of records to update
	SELECT @intUpdated = COUNT(1)
	FROM  #tmpNoSiteItemIssue A
	WHERE EXISTS(SELECT TOP 1 1 FROM tblCFNetworkCost WHERE tblCFNetworkCost.dtmDate = A.dtmDate 
		AND  tblCFNetworkCost.intSiteId =  A.intSiteId 
		AND  tblCFNetworkCost.intItemId = A.intItemId
		AND  tblCFNetworkCost.intNetworkId = @intNetworkId)

	------UPDATE Existing
	UPDATE tblCFNetworkCost
	SET dblTransferCost = A.dblTransferCost
		,dblTaxesPerUnit = A.dblTaxesPerUnit
	FROM  #tmpNoSiteItemIssue A
	WHERE tblCFNetworkCost.dtmDate = A.dtmDate 
		AND  tblCFNetworkCost.intSiteId =  A.intSiteId 
		AND  tblCFNetworkCost.intItemId = A.intItemId
		AND  tblCFNetworkCost.intNetworkId = @intNetworkId
	

	---- GEt Count of records to be inserted
	SELECT @intInserted = COUNT(1)
	FROM  #tmpNoSiteItemIssue A
	WHERE NOT EXISTS(SELECT TOP 1 1 
					 FROM tblCFNetworkCost 
					 WHERE dtmDate = A.dtmDate 
						AND intSiteId =  A.intSiteId 
						AND intItemId = A.intItemId)


	---Insert records into tblCFNetworkCost
	INSERT INTO tblCFNetworkCost(
		intSiteId 
		,dtmDate
		,intItemId
		,dblTransferCost
		,dblTaxesPerUnit
		,intNetworkId
	)
	SELECT	
		intSiteId = A.intSiteId
		,dtmDate = A.dtmDate
		,intItemId = A.intItemId
		,dblTransferCost = A.dblTransferCost
		,dblTaxesPerUnit  = A.dblTaxesPerUnit
		,intNetworkId = @intNetworkId
	FROM #tmpNoSiteItemIssue A
	WHERE NOT EXISTS(SELECT TOP 1 1 
					 FROM tblCFNetworkCost 
					 WHERE dtmDate = A.dtmDate 
						AND intSiteId =  A.intSiteId 
						AND intItemId = A.intItemId
						AND intNetworkId = @intNetworkId)

	
	SELECT 
		intInserted = @intInserted
		,intTotalRead = @intTotalRead
		,intUpdated = @intUpdated
		,intNoSiteSetup = @intNoSiteSetup
		,intNoProductSetup = @intNoProductSetup
		,intNoInvalidData = @intNoInvalidData
	

	------------------------------------------------------------------------------------
	------------END No Validation Issues on Site and product------------------------
	-------------------------------------------------------------------------------
    
END