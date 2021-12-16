CREATE PROCEDURE [dbo].[uspSTGenerateHandheldScannerExportPricebook]
	@StoreId INT,
	@HandheldScannerId INT
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

DECLARE @ErrorMessage NVARCHAR(MAX)
DECLARE @ErrorSeverity INT
DECLARE @ErrorState INT
DECLARE @CreatedInvoices NVARCHAR(MAX)
DECLARE @UpdatedInvoices NVARCHAR(MAX)

BEGIN TRY

	DECLARE @LocationId INT
	SELECT TOP 1 @LocationId = intCompanyLocationId FROM tblSTStore WHERE intStoreId = @StoreId

	INSERT INTO tblSTHandheldScannerExportPricebook(
		intHandheldScannerId
		, strUPCNo
		, strCaseUPC
		, strPOSDescription
		, intCaseSize
		, dblLastCaseCost
		, dblUnitPrice
		, strItemUOM
		, strVendorId
		, strDeptNo
		, dblOnHandQty)
	SELECT @HandheldScannerId
		, CASE WHEN ISNULL(strUpcCode, '') != '' THEN strUpcCode ELSE strItemNo END
		, '0000000000000'
		, strShortName
		, '1'
		, dblLastCost
		, dblSalePrice
		, strUnitMeasure
		, strVendorId
		, CAST(ISNULL(intRegisterDepartmentId, '') AS NVARCHAR(50))
		, dblOnHand
	FROM vyuSTGetPricebookExport
	WHERE ysnStockUnit = 1 
		AND intLocationId = @LocationId
	ORDER BY intItemId, intLocationId, intItemUOMId


END TRY

BEGIN CATCH
	SELECT 
		@ErrorMessage = ERROR_MESSAGE(),
		@ErrorSeverity = ERROR_SEVERITY(),
		@ErrorState = ERROR_STATE();

	-- Use RAISERROR inside the CATCH block to return error
	-- information about the original error that caused
	-- execution to jump to the CATCH block.
	RAISERROR (
		@ErrorMessage, -- Message text.
		@ErrorSeverity, -- Severity.
		@ErrorState -- State.
	);
END CATCH
