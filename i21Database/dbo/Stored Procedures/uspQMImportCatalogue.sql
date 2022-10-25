CREATE PROCEDURE uspQMImportCatalogue
    @intImportLogId INT
AS

BEGIN TRY
	BEGIN TRANSACTION

	-- Validate Key Fields
    UPDATE IMP
    SET strLogResult = 'Incorrect Fields: ' + TRIM (', ' FROM (
            CASE WHEN CL.strLocationName IS NULL THEN 'BUYING CENTER, ' ELSE '' END
            + CASE WHEN CT.intCatalogueTypeId IS NULL THEN 'CATALOGUE TYPE, ' ELSE '' END
            + CASE WHEN E.intEntityId IS NULL THEN 'SUPPLIER, ' ELSE '' END
        ))
        ,ysnSuccess = 0
        ,ysnProcessed = 1
    FROM tblQMImportCatalogue IMP
    LEFT JOIN tblSMCompanyLocation CL
        ON CL.strLocationName = IMP.strBuyingCenter
    LEFT JOIN tblQMCatalogueType CT
        ON CT.strCatalogueType = IMP.strCatalogueType
    LEFT JOIN (tblEMEntity E INNER JOIN tblAPVendor V ON V.intEntityId = E.intEntityId)
        ON E.strName = IMP.strSupplier
    WHERE IMP.intImportLogId = @intImportLogId
    AND (
        CL.intCompanyLocationId IS NULL
        OR CT.intCatalogueTypeId IS NULL
        OR E.intEntityId IS NULL
    )

    -- Catalogue Import
    IF EXISTS(SELECT 1 FROM tblQMImportLog WHERE intImportLogId = @intImportLogId AND strImportType = 'Catalogue')
        EXEC uspQMImportCatalogueMain @intImportLogId

    -- -- Tasting Score Import
    -- IF EXISTS(SELECT 1 FROM tblQMImportLog WHERE intImportLogId = @intImportLogId AND strImportType = 'Tasting Score')
    --     EXEC uspQMImportCatalogueMain @intImportLogId

    -- -- Supplier Evaluation Import
    -- IF EXISTS(SELECT 1 FROM tblQMImportLog WHERE intImportLogId = @intImportLogId AND strImportType = 'Supplier Evaluation')
    --     EXEC uspQMImportCatalogueMain @intImportLogId

    -- -- Initial Buy Import
    -- IF EXISTS(SELECT 1 FROM tblQMImportLog WHERE intImportLogId = @intImportLogId AND strImportType = 'Initial Buy')
    --     EXEC uspQMImportCatalogueMain @intImportLogId

    -- -- Contract Line Allocation Import
    -- IF EXISTS(SELECT 1 FROM tblQMImportLog WHERE intImportLogId = @intImportLogId AND strImportType = 'Contract Line Allocation')
    --     EXEC uspQMImportCatalogueMain @intImportLogId

	COMMIT TRANSACTION
END TRY
BEGIN CATCH
	DECLARE @strErrorMsg NVARCHAR(MAX) = NULL

	SET @strErrorMsg = ERROR_MESSAGE()
	ROLLBACK TRANSACTION 

	RAISERROR(@strErrorMsg, 11, 1) 
END CATCH