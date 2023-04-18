CREATE PROCEDURE [dbo].[uspQMImportCatalogue]
(
	@intImportLogId INT
)
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS ON

-- Check if API errors already exists in the log table
IF EXISTS (SELECT 1 FROM tblQMImportCatalogue WHERE intImportLogId = @intImportLogId AND ysnSuccess = 0)
	BEGIN
		RETURN;
	END

BEGIN TRY
	BEGIN TRANSACTION

	-- Delete old error logs for the same user
	DECLARE @intEntityUserId INT
	SELECT @intEntityUserId = intEntityId FROM tblQMImportLog WHERE intImportLogId = @intImportLogId

	DELETE IC
	FROM tblQMImportCatalogue IC
	INNER JOIN tblQMImportLog IL ON IL.intImportLogId = IC.intImportLogId
	WHERE IC.ysnSuccess = 0
	AND IL.intEntityId = @intEntityUserId
	AND IL.intImportLogId < @intImportLogId	

	/* Validation of Missing Fields for Auction & Non-Auction Sample. */
	UPDATE IMP
	SET strLogResult	= 'Missing Field(s): ' + REVERSE(SUBSTRING(REVERSE(MSG.strLogMessage), charindex(',', reverse(MSG.strLogMessage)) + 1, len(MSG.strLogMessage)))
	  , ysnSuccess		= 0
	  , ysnProcessed	= 1
	FROM tblQMImportCatalogue IMP
	-- Format log message
	OUTER APPLY 
	(
		SELECT strLogMessage = CASE WHEN ISNULL(IMP.strSaleYear, '') = '' THEN 'SALE YEAR, '
									ELSE ''
							   END 
							 + CASE WHEN ISNULL(IMP.strBuyingCenter, '') = '' THEN 'BUYING CENTER, '
									ELSE ''
							   END 
							 + CASE WHEN ISNULL(IMP.strSaleNumber, 0) = 0 THEN 'SALE NUMBER, '
									ELSE ''
							   END 
							 + CASE WHEN ISNULL(IMP.strCatalogueType, '') = '' THEN 'CATALOGUE TYPE, '
									ELSE ''
							   END 
							 + CASE WHEN ISNULL(IMP.strSupplier, '') = '' THEN 'SUPPLIER, '
									ELSE ''
							   END 
							 + CASE WHEN ISNULL(IMP.strLotNumber, '') = '' THEN 'LOT NUMBER, '
									ELSE ''
							   END 
							 + CASE WHEN ISNULL(IMP.strSampleTypeName, '') = '' THEN 'SAMPLE TYPE, '
									ELSE ''
							   END
	) MSG
	WHERE IMP.intImportLogId = @intImportLogId
		AND ISNULL(IMP.strBatchNo, '') = '' -- Having no batch number indicates that the import is an Auction or Non-Action sample
		AND IMP.ysnSuccess = 1
		AND 
		(
			ISNULL(IMP.strSaleYear, '') = ''
		 OR ISNULL(IMP.strBuyingCenter, '') = ''
		 OR ISNULL(IMP.strSaleNumber, '') = ''
		 OR ISNULL(IMP.strCatalogueType, '') = ''
		 OR ISNULL(IMP.strSupplier, '') = ''
		 OR ISNULL(IMP.strLotNumber, '') = ''
		 OR ISNULL(IMP.strSampleTypeName, '') = ''
		)
	/* End if Validation of Missing Fields for Auction & Non-Auction Sample. */
	

	/* Validation of Missing Fields for Pre-Shipment Sample. */
	UPDATE IMP
	SET strLogResult	= 'Missing Field(s): ' + REVERSE(SUBSTRING(REVERSE(MSG.strLogMessage), charindex(',', reverse(MSG.strLogMessage)) + 1, len(MSG.strLogMessage)))
	  , ysnSuccess		= 0
	  , ysnProcessed	= 1
	FROM tblQMImportCatalogue IMP
	-- Format log message
	OUTER APPLY 
	(
		SELECT strLogMessage = CASE WHEN ISNULL(IMP.strBatchNo, '') = '' THEN 'BATCH NO, '
									ELSE ''
							   END 
							 + CASE WHEN ISNULL(IMP.strB1GroupNumber, '') = '' THEN 'BUYER1 GROUP NUMBER, '
									ELSE ''
							   END 
							 + CASE WHEN ISNULL(IMP.strSampleTypeName, '') = '' THEN 'SAMPLE TYPE, '
									ELSE ''
							   END
	) MSG
	WHERE IMP.intImportLogId = @intImportLogId
		AND ISNULL(IMP.strBatchNo, '') <> '' -- Having batch number indicates that the import is a Pre-shipment Sample.
		AND IMP.ysnSuccess = 1
		AND 
		(
			ISNULL(IMP.strBatchNo, '') = ''
		 OR ISNULL(IMP.strB1GroupNumber, '') = ''
		 OR ISNULL(IMP.strSampleTypeName, '') = ''
		)
	/* End of Validation of Missing Fields for Pre-Shipment Sample. */

	/* Validate Key Fields for Auction & Non-Auction Sample. */
	UPDATE IMP
	SET strLogResult	= 'Incorrect Field(s): ' + REVERSE(SUBSTRING(REVERSE(MSG.strLogMessage), charindex(',', reverse(MSG.strLogMessage)) + 1, len(MSG.strLogMessage)))
		,ysnSuccess		= 0
		,ysnProcessed	= 1
	FROM tblQMImportCatalogue AS IMP
	LEFT JOIN tblSMCompanyLocation AS CL ON CL.strLocationName = IMP.strB1GroupNumber
	LEFT JOIN tblQMSampleType ST ON ST.strSampleTypeName = IMP.strSampleTypeName
	LEFT JOIN tblMFBatch B ON B.strBatchId = IMP.strBatchNo
	LEFT JOIN tblQMControlPoint AS ControlPoint ON ST.intControlPointId = ControlPoint.intControlPointId
	-- Format log message
	OUTER APPLY 
	(
		SELECT strLogMessage = CASE WHEN B.intBatchId IS NULL THEN 'BATCH NO, '
									ELSE ''
							   END 
							 + CASE WHEN CL.strLocationName IS NULL THEN 'BUYER1 GROUP NAME, '
									ELSE ''
							   END 
							 + CASE WHEN ST.intSampleTypeId IS NULL THEN 'SAMPLE TYPE, '
									ELSE ''
							   END
	) MSG
	WHERE IMP.intImportLogId = @intImportLogId
		AND ysnSuccess = 1
		AND (CL.intCompanyLocationId IS NULL OR ST.intSampleTypeId IS NULL)
		AND (ControlPoint.intControlPointId NOT IN (1, 5))

	/* End of Validate Key Fields for Auction & Non-Auction Sample. */


	-- Validate Key Fields for Auction/Non-Auction Sample

	/** Title: Past Sale Date Validation 
	 *  Description: Skip sale date earlier than todays date.
	 *  JIRA: QC-990 
	**/
	--UPDATE IMP
	--SET strLogResult	= 'Sale Date cannot be earlier than date Today.'   
	--  , ysnSuccess		= 0
	--  , ysnProcessed	= 1
	--FROM tblQMImportCatalogue AS IMP
	--LEFT JOIN tblQMSampleType AS ST ON ST.strSampleTypeName = IMP.strSampleTypeName
	--LEFT JOIN tblQMControlPoint AS ControlPoint ON ST.intControlPointId = ControlPoint.intControlPointId
	--WHERE IMP.intImportLogId = @intImportLogId
	--	/* Having no batch number indicates that the import is an Auction or Non-Action sample. */
	--    AND ISNULL(IMP.strBatchNo, '') = '' 
	--	AND ysnSuccess = 1
	--	AND CONVERT(DATE, IMP.dtmSaleDate) < CONVERT(DATE, GETDATE());
	--/* End of Past Sale Date Validation */


	UPDATE IMP
	SET strLogResult	= 'Incorrect Field(s): ' + REVERSE(SUBSTRING(REVERSE(MSG.strLogMessage), charindex(',', reverse(MSG.strLogMessage)) + 1, len(MSG.strLogMessage)))
		,ysnSuccess		= 0
		,ysnProcessed	= 1
	FROM tblQMImportCatalogue AS IMP
	LEFT JOIN tblSMCompanyLocation AS CL ON CL.strLocationName = IMP.strBuyingCenter
	LEFT JOIN tblQMCatalogueType AS CT ON CT.strCatalogueType = IMP.strCatalogueType
	LEFT JOIN 
	(
		tblEMEntity AS E 
		INNER JOIN tblAPVendor AS V ON V.intEntityId = E.intEntityId
	) ON E.strName = IMP.strSupplier
	LEFT JOIN tblQMSaleYear SY ON SY.strSaleYear = IMP.strSaleYear
	-- Format log message
	OUTER APPLY 
	(
		SELECT strLogMessage = CASE WHEN SY.intSaleYearId IS NULL THEN 'SALE YEAR, '
									ELSE ''
							   END 
							 + CASE WHEN CL.strLocationName IS NULL THEN 'BUYING CENTER, '
									ELSE ''
							   END 
							 + CASE WHEN CT.intCatalogueTypeId IS NULL THEN 'CATALOGUE TYPE, '
									ELSE ''
							   END 
							 + CASE WHEN E.intEntityId IS NULL THEN 'SUPPLIER, '
									ELSE ''
							   END
	) MSG
	WHERE IMP.intImportLogId = @intImportLogId
		AND ISNULL(IMP.strBatchNo, '') = ''
		AND 
		(
			SY.intSaleYearId IS NULL
		 OR CL.intCompanyLocationId IS NULL
		 OR CT.intCatalogueTypeId IS NULL
		 OR E.intEntityId IS NULL
		)

	-- End Validate Key Fields for Pre-Shipment Sample

	/* Delete temp tables for audit logs. */
    IF OBJECT_ID('tempdb..##tmpQMSample') IS NOT NULL
		DROP TABLE ##tmpQMSample;

    IF OBJECT_ID('tempdb..##tmpQMTestResult') IS NOT NULL
		DROP TABLE ##tmpQMTestResult;
	
	/* Prepare temporary table that will be used for audit logs to fix performance issue. */
	SELECT * INTO ##tmpQMSample FROM tblQMSample WHERE 1 = 0;
	CREATE INDEX [IX_tmpQMSample_intSampleId] ON ##tmpQMSample(intSampleId);

	SELECT * INTO ##tmpQMTestResult FROM tblQMTestResult WHERE 1 = 0;
	CREATE INDEX [IX_tmpQMTestResult_intSampleId] ON ##tmpQMTestResult(intSampleId);

	/* Importing starts here. */
	DECLARE @strImportType AS NVARCHAR(MAX);

	SELECT @strImportType = strImportType
	FROM tblQMImportLog
	WHERE intImportLogId = @intImportLogId;

    /* Catalogue. */
	IF (@strImportType = 'Catalogue')
		BEGIN
			EXEC uspQMImportCatalogueMain @intImportLogId;
		END

    /* Tasting Score. */
	IF (@strImportType = 'Tasting Score')
		BEGIN
			EXEC uspQMImportTastingScore @intImportLogId;
		END

	/* Supplier Valuation. */
	IF (@strImportType = 'Supplier Valuation')
		BEGIN
			EXEC uspQMImportSupplierEvaluation @intImportLogId;
		END

	/* Initial Buy. */ 
	IF (@strImportType = 'Initial Buy')
		BEGIN
			EXEC uspQMImportInitialBuy @intImportLogId;
		END

	/* Contract Line Allocation. */
	IF (@strImportType = 'Contract Line Allocation')
		BEGIN
			EXEC uspQMImportContractAllocation @intImportLogId;
		END

	COMMIT TRANSACTION

END TRY

BEGIN CATCH

	DECLARE @strErrorMsg NVARCHAR(MAX) = NULL;

	SET @strErrorMsg = ERROR_MESSAGE();

	RAISERROR 
	(
		@strErrorMsg
	  , 11
	  , 1
	);
END CATCH