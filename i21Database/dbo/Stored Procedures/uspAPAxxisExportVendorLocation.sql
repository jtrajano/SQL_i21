CREATE PROCEDURE [dbo].[uspAPAxxisExportVendorLocation]
	@vendorId INT = NULL,
	@modifiedFields NVARCHAR(MAX) = NULL
AS

BEGIN

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET ANSI_WARNINGS OFF

BEGIN TRY

IF OBJECT_ID(N'dbo.tmpAxxisVendorLocation') IS NOT NULL 
BEGIN
	DROP TABLE tmpAxxisVendorLocation
END

CREATE TABLE tmpAxxisVendorLocation(
		strLocationName NVARCHAR (200) COLLATE Latin1_General_CI_AS,
		strPrintedName NVARCHAR (MAX) COLLATE Latin1_General_CI_AS NULL,
		strShipVia NVARCHAR (100) COLLATE Latin1_General_CI_AS NULL,
		strTerminalNo NVARCHAR (250) COLLATE Latin1_General_CI_AS NULL,
		ysnActive BIT
	)

IF OBJECT_ID(N'tempdb..#tmpModifiedFields') IS NOT NULL DROP TABLE #tmpModifiedFields
CREATE TABLE #tmpModifiedFields(strFields NVARCHAR(MAX))

INSERT INTO #tmpModifiedFields
SELECT @modifiedFields

DECLARE @tblFields TABLE(strField NVARCHAR(50))

;WITH tmp(DataItem, strFields) AS
(
    SELECT
        LEFT(strFields, CHARINDEX(',', strFields + ',') - 1),
		STUFF(strFields, 1, CHARINDEX(',', strFields + ','), '')
    FROM #tmpModifiedFields
    UNION all

    SELECT
        LEFT(strFields, CHARINDEX(',', strFields + ',') - 1),
		STUFF(strFields, 1, CHARINDEX(',', strFields + ','), '')
    FROM tmp
    WHERE
        strFields > ''
)

INSERT INTO @tblFields
SELECT
    DataItem
FROM tmp

-- SELECT * FROM @tblFields

IF NOT EXISTS(SELECT 1 FROM @tblFields WHERE strField IN ('strLocationName','strCheckPayeeName','strShipVia','strTerminalNo','ysnActive')) 
BEGIN
	RETURN;
END

IF @vendorId IS NULL
BEGIN
	INSERT INTO tmpAxxisVendorLocation(
		strLocationName,
		strPrintedName,
		strShipVia,
		strTerminalNo,
		ysnActive
	)
	SELECT
		B.strLocationName,
		B.strCheckPayeeName AS strPrintedName,
		C.strShipVia,
		E.strTerminalControlNumber AS strTerminalNo,
		B.ysnActive
	FROM tblAPVendor A
	INNER JOIN tblEMEntityLocation B ON A.intEntityId = B.intEntityId
	INNER JOIN tblTRSupplyPoint D ON B.intEntityLocationId = D.intEntityLocationId
	LEFT JOIN tblSMShipVia C ON B.intShipViaId = C.intEntityId
	LEFT JOIN tblTFTerminalControlNumber E ON D.intTerminalControlNumberId = E.intTerminalControlNumberId
	WHERE
		A.ysnTransportTerminal = 1
END
ELSE
BEGIN
	INSERT INTO tmpAxxisVendorLocation(
		strLocationName,
		strPrintedName,
		strShipVia,
		strTerminalNo,
		ysnActive
	)
	SELECT
		B.strLocationName,
		B.strCheckPayeeName AS strPrintedName,
		C.strShipVia,
		E.strTerminalControlNumber AS strTerminalNo,
		B.ysnActive
	FROM tblAPVendor A
	INNER JOIN tblEMEntityLocation B ON A.intEntityId = B.intEntityId
	INNER JOIN tblTRSupplyPoint D ON B.intEntityLocationId = D.intEntityLocationId
	LEFT JOIN tblSMShipVia C ON B.intShipViaId = C.intEntityId
	LEFT JOIN tblTFTerminalControlNumber E ON D.intTerminalControlNumberId = E.intTerminalControlNumberId
	WHERE 
		A.intEntityId = @vendorId
	AND A.ysnTransportTerminal = 1
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