CREATE PROCEDURE [dbo].[uspAPAxxisExportVendorLocation]
	@vendorId INT = NULL
AS

BEGIN

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET ANSI_WARNINGS OFF

BEGIN TRY

IF OBJECT_ID(N'tmpAxxisVendorLocation') IS NOT NULL DROP TABLE tmpAxxisVendorLocation

IF @vendorId IS NULL
BEGIN
	SELECT
		B.strLocationName,
		B.strCheckPayeeName AS strPrintedName,
		C.strShipVia
	INTO tmpAxxisVendorLocation
	FROM tblAPVendor A
	INNER JOIN tblEMEntityLocation B ON A.intEntityId = B.intEntityId
	LEFT JOIN tblSMShipVia C ON B.intShipViaId = C.intEntityId
END
ELSE
BEGIN
	SELECT
		B.strLocationName,
		B.strCheckPayeeName AS strPrintedName,
		C.strShipVia
	INTO tmpAxxisVendorLocation
	FROM tblAPVendor A
	INNER JOIN tblEMEntityLocation B ON A.intEntityId = B.intEntityId
	LEFT JOIN tblSMShipVia C ON B.intShipViaId = C.intEntityId
	WHERE A.intEntityId = @vendorId
END

END TRY
BEGIN CATCH
	DECLARE @ErrorSeverity INT,
			@ErrorNumber   INT,
			@ErrorMessage nvarchar(4000),
			@ErrorState INT,
			@ErrorLine  INT,
			@ErrorProc nvarchar(200);
	-- Grab error information from SQL functions
	SET @ErrorSeverity = ERROR_SEVERITY()
	SET @ErrorNumber   = ERROR_NUMBER()
	SET @ErrorMessage  = ERROR_MESSAGE()
	SET @ErrorState    = ERROR_STATE()
	SET @ErrorLine     = ERROR_LINE()
	SET @ErrorProc     = ERROR_PROCEDURE()

	SET @ErrorMessage  = 'Error staging vendor location export.' + CHAR(13) + 
		'SQL Server Error Message is: ' + CAST(@ErrorNumber AS VARCHAR(10)) + 
		' in procedure: ' + @ErrorProc + ' Line: ' + CAST(@ErrorLine AS VARCHAR(10)) + ' Error text: ' + @ErrorMessage

	RAISERROR (@ErrorMessage , @ErrorSeverity, @ErrorState, @ErrorNumber)
END CATCH

END