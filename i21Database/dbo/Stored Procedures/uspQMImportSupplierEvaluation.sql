CREATE PROCEDURE uspQMImportSupplierEvaluation
(
	@intImportLogId INT
)    
AS

BEGIN TRY
	BEGIN TRANSACTION

    DECLARE @intImportCatalogueId		INT
		  , @dblSupplierValuationPrice	NUMERIC(18, 6)
		  , @intSampleId				INT
		  , @intEntityUserId			INT

	EXECUTE uspQMImportValidationTastingScore @intImportLogId;

    /* Loop through each valid import detail. */
    DECLARE @C AS CURSOR;

	SET @C = CURSOR FAST_FORWARD FOR
        SELECT intImportCatalogueId			= IMP.intImportCatalogueId
             , dblSupplierValuationPrice	= IMP.dblSupplierValuation
             , intSampleId					= S.intSampleId
             , intEntityUserId				= IL.intEntityId
        FROM tblQMSample S
        INNER JOIN tblSMCompanyLocation CL ON CL.intCompanyLocationId = S.intLocationId
        INNER JOIN tblQMCatalogueType CT ON CT.intCatalogueTypeId = S.intCatalogueTypeId
        INNER JOIN (tblEMEntity E INNER JOIN tblAPVendor V ON V.intEntityId = E.intEntityId)
            ON V.intEntityId = S.intEntityId
        INNER JOIN tblQMSaleYear SY ON SY.intSaleYearId = S.intSaleYearId
        INNER JOIN tblQMImportCatalogue IMP
            ON SY.strSaleYear = IMP.strSaleYear
            AND CL.strLocationName = IMP.strBuyingCenter
            AND S.strSaleNumber = IMP.strSaleNumber
            AND CT.strCatalogueType = IMP.strCatalogueType
            AND E.strName = IMP.strSupplier
            AND S.strRepresentLotNumber = IMP.strLotNumber
        INNER JOIN tblQMImportLog IL ON IL.intImportLogId = IMP.intImportLogId
        WHERE IMP.intImportLogId = @intImportLogId
            AND IMP.ysnSuccess = 1

    OPEN @C 
	FETCH NEXT FROM @C INTO @intImportCatalogueId
						  , @dblSupplierValuationPrice
						  , @intSampleId
						  , @intEntityUserId

	WHILE @@FETCH_STATUS = 0
	BEGIN
        EXEC uspQMGenerateSampleCatalogueImportAuditLog @intSampleId  = @intSampleId
													  , @intUserEntityId = @intEntityUserId
													  , @strRemarks = 'Updated from Supplier Valuation Import'
													  , @ysnCreate = 0
													  , @ysnBeforeUpdate = 1

        UPDATE S
        SET intConcurrencyId			= S.intConcurrencyId + 1
          , dblSupplierValuationPrice	= @dblSupplierValuationPrice
        FROM tblQMSample S
        WHERE S.intSampleId = @intSampleId;

        UPDATE tblQMImportCatalogue
        SET intSampleId = @intSampleId
        WHERE intImportCatalogueId = @intImportCatalogueId

        FETCH NEXT FROM @C INTO @intImportCatalogueId
							  , @dblSupplierValuationPrice
							  , @intSampleId
							  , @intEntityUserId
    END
    CLOSE @C
	DEALLOCATE @C

    EXEC uspQMGenerateSampleCatalogueImportAuditLog
        @intUserEntityId = @intEntityUserId
        , @strRemarks = 'Updated from Supplier Valuation Import'
        , @ysnCreate = 0
        , @ysnBeforeUpdate = 0

	COMMIT TRANSACTION
END TRY
BEGIN CATCH
	DECLARE @strErrorMsg NVARCHAR(MAX) = NULL

	SET @strErrorMsg = ERROR_MESSAGE()

	RAISERROR(@strErrorMsg, 11, 1) 
END CATCH