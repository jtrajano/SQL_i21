CREATE PROCEDURE uspQMImportSupplierEvaluation
    @intImportLogId INT
AS

BEGIN TRY
	BEGIN TRANSACTION

    DECLARE
        @intImportCatalogueId INT
        ,@dblSupplierValuationPrice NUMERIC(18, 6)
        ,@intSampleId INT

    -- Loop through each valid import detail
    DECLARE @C AS CURSOR;
	SET @C = CURSOR FAST_FORWARD FOR
        SELECT
            intImportCatalogueId = IMP.intImportCatalogueId
            ,dblSupplierValuationPrice = IMP.dblSupplierValuation
            ,intSampleId = S.intSampleId
        FROM tblQMSample S
        INNER JOIN tblSMCompanyLocation CL ON CL.intCompanyLocationId = S.intLocationId
        INNER JOIN tblQMCatalogueType CT ON CT.intCatalogueTypeId = S.intCatalogueTypeId
        INNER JOIN (tblEMEntity E INNER JOIN tblAPVendor V ON V.intEntityId = E.intEntityId)
            ON V.intEntityId = S.intEntityId
        INNER JOIN (
            tblQMImportCatalogue IMP INNER JOIN tblQMSaleYear SY ON SY.strSaleYear = IMP.strSaleYear
        )
            ON S.strSaleYear = IMP.strSaleYear
            AND CL.strLocationName = IMP.strBuyingCenter
            AND S.strSaleNumber = IMP.strSaleNumber
            AND CT.strCatalogueType = IMP.strCatalogueType
            AND E.strName = IMP.strSupplier
            AND S.strRepresentLotNumber = IMP.strLotNumber
        WHERE IMP.intImportLogId = @intImportLogId
            AND IMP.ysnSuccess = 1

    OPEN @C 
	FETCH NEXT FROM @C INTO
		@intImportCatalogueId
        ,@dblSupplierValuationPrice
        ,@intSampleId
	WHILE @@FETCH_STATUS = 0
	BEGIN

        UPDATE S
        SET
            intConcurrencyId = S.intConcurrencyId + 1
            ,dblSupplierValuationPrice = @dblSupplierValuationPrice
        FROM tblQMSample S
        WHERE S.intSampleId = @intSampleId

        UPDATE tblQMImportCatalogue
        SET intSampleId = @intSampleId
        WHERE intImportCatalogueId = @intImportCatalogueId

        FETCH NEXT FROM @C INTO
            @intImportCatalogueId
            ,@dblSupplierValuationPrice
            ,@intSampleId
    END
    CLOSE @C
	DEALLOCATE @C

	COMMIT TRANSACTION
END TRY
BEGIN CATCH
	DECLARE @strErrorMsg NVARCHAR(MAX) = NULL

	SET @strErrorMsg = ERROR_MESSAGE()

	RAISERROR(@strErrorMsg, 11, 1) 
END CATCH