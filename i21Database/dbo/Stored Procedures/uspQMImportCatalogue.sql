CREATE PROCEDURE uspQMImportCatalogue
    @intImportLogId INT
AS

-- Check if API errors already exists in the log table
IF EXISTS(SELECT 1 FROM tblQMImportCatalogue WHERE intImportLogId = @intImportLogId AND ysnSuccess = 0)
    RETURN

BEGIN TRY

	BEGIN TRANSACTION

    -- Check for missing key fields
    UPDATE IMP
    SET strLogResult = 'Missing Field(s): ' + REVERSE(SUBSTRING(REVERSE(MSG.strLogMessage),charindex(',',reverse(MSG.strLogMessage))+1,len(MSG.strLogMessage)))
        ,ysnSuccess = 0
        ,ysnProcessed = 1
    FROM tblQMImportCatalogue IMP
    -- Format log message
    OUTER APPLY (
        SELECT strLogMessage =
            CASE WHEN ISNULL(IMP.strSaleYear, '') = '' THEN 'SALE YEAR, ' ELSE '' END
            + CASE WHEN ISNULL(IMP.strBuyingCenter, '') = '' THEN 'BUYING CENTER, ' ELSE '' END
            + CASE WHEN ISNULL(IMP.intSaleNumber, 0) = 0 THEN 'SALE NUMBER, ' ELSE '' END
            + CASE WHEN ISNULL(IMP.strCatalogueType, '') = '' THEN 'CATALOGUE TYPE, ' ELSE '' END
            + CASE WHEN ISNULL(IMP.strSupplier, '') = '' THEN 'SUPPLIER, ' ELSE '' END
            + CASE WHEN ISNULL(IMP.strLotNumber, '') = '' THEN 'LOT NUMBER, ' ELSE '' END
    ) MSG
    WHERE IMP.intImportLogId = @intImportLogId
    AND IMP.ysnSuccess = 1
    AND (
        ISNULL(IMP.strSaleYear, '') = ''
        OR ISNULL(IMP.strBuyingCenter, '') = ''
        OR ISNULL(IMP.intSaleNumber, 0) = 0
        OR ISNULL(IMP.strCatalogueType, '') = ''
        OR ISNULL(IMP.strSupplier, '') = ''
        OR ISNULL(IMP.strLotNumber, '') = ''
    )

	-- Validate Key Fields
    UPDATE IMP
    SET strLogResult = 'Incorrect Field(s): ' + REVERSE(SUBSTRING(REVERSE(MSG.strLogMessage),charindex(',',reverse(MSG.strLogMessage))+1,len(MSG.strLogMessage)))
        ,ysnSuccess = 0
        ,ysnProcessed = 1
    FROM tblQMImportCatalogue IMP
    LEFT JOIN tblSMCompanyLocation CL
        ON CL.strLocationName = IMP.strBuyingCenter
    LEFT JOIN tblQMCatalogueType CT
        ON CT.strCatalogueType = IMP.strCatalogueType
    LEFT JOIN (tblEMEntity E INNER JOIN tblAPVendor V ON V.intEntityId = E.intEntityId)
        ON V.strVendorAccountNum = IMP.strSupplier
    LEFT JOIN tblQMSaleYear SY ON SY.strSaleYear = IMP.strSaleYear
    -- Format log message
    OUTER APPLY (
        SELECT strLogMessage =
            CASE WHEN SY.intSaleYearId IS NULL THEN 'SALE YEAR, ' ELSE '' END
            + CASE WHEN CL.strLocationName IS NULL THEN 'BUYING CENTER, ' ELSE '' END
            + CASE WHEN CT.intCatalogueTypeId IS NULL THEN 'CATALOGUE TYPE, ' ELSE '' END
            + CASE WHEN E.intEntityId IS NULL THEN 'SUPPLIER, ' ELSE '' END
    ) MSG
    WHERE IMP.intImportLogId = @intImportLogId
    AND (
        SY.intSaleYearId IS NULL
        OR CL.intCompanyLocationId IS NULL
        OR CT.intCatalogueTypeId IS NULL
        OR E.intEntityId IS NULL
    )

    -- Catalogue Import
    IF EXISTS(SELECT 1 FROM tblQMImportLog WHERE intImportLogId = @intImportLogId AND strImportType = 'Catalogue')
        EXEC uspQMImportCatalogueMain @intImportLogId

    -- -- Tasting Score Import
    -- IF EXISTS(SELECT 1 FROM tblQMImportLog WHERE intImportLogId = @intImportLogId AND strImportType = 'Tasting Score')
    --     EXEC uspQMImportCatalogueMain @intImportLogId

    -- Supplier Evaluation Import
    IF EXISTS(SELECT 1 FROM tblQMImportLog WHERE intImportLogId = @intImportLogId AND strImportType = 'Supplier Evaluation')
        EXEC uspQMImportSupplierEvaluation @intImportLogId

    -- Initial Buy Import
    IF EXISTS(SELECT 1 FROM tblQMImportLog WHERE intImportLogId = @intImportLogId AND strImportType = 'Initial Buy')
        EXEC uspQMImportInitialBuy @intImportLogId

    -- -- Contract Line Allocation Import
    -- IF EXISTS(SELECT 1 FROM tblQMImportLog WHERE intImportLogId = @intImportLogId AND strImportType = 'Contract Line Allocation')
    --     EXEC uspQMImportCatalogueMain @intImportLogId

	COMMIT TRANSACTION
END TRY
BEGIN CATCH
	DECLARE @strErrorMsg NVARCHAR(MAX) = NULL

	SET @strErrorMsg = ERROR_MESSAGE()

	RAISERROR(@strErrorMsg, 11, 1) 
END CATCH