CREATE PROCEDURE [dbo].[uspAPAxxisExportVendor]
	@vendorId INT = NULL,
	@modifiedFields NVARCHAR(MAX) = NULL
AS

BEGIN

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET ANSI_WARNINGS OFF

BEGIN TRY

IF OBJECT_ID(N'tmpAxxisVendor') IS NOT NULL
BEGIN
	DROP TABLE tmpAxxisVendor
END

CREATE TABLE tmpAxxisVendor(
		strName NVARCHAR (100)  COLLATE Latin1_General_CI_AS NOT NULL,
		strLocationName NVARCHAR (200) COLLATE Latin1_General_CI_AS,
		strPrintedName NVARCHAR (MAX) COLLATE Latin1_General_CI_AS NULL,
		strTaxNumber NVARCHAR(20) COLLATE Latin1_General_CI_AS NULL
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

IF NOT EXISTS(SELECT 1 FROM @tblFields WHERE strField IN ('strName','strTaxNumber','strLocationName','strCheckPayeeName')) 
BEGIN
	RETURN;
END

IF @vendorId IS NULL
BEGIN
	INSERT INTO tmpAxxisVendor
	SELECT
		B.strName,
		C.strLocationName,
		ISNULL(C.strCheckPayeeName,'') AS strPrintedName,
		ISNULL(A.strTaxNumber,'') AS strTaxNumber
	FROM tblAPVendor A
	INNER JOIN tblEMEntity B ON A.intEntityId = B.intEntityId
	INNER JOIN tblEMEntityLocation C ON B.intEntityId = C.intEntityId
	WHERE
		A.ysnTransportTerminal = 1
END
ELSE
BEGIN
	INSERT INTO tmpAxxisVendor
	SELECT
		B.strName,
		C.strLocationName,
		ISNULL(C.strCheckPayeeName,'') AS strPrintedName,
		ISNULL(A.strTaxNumber,'') AS strTaxNumber
	FROM tblAPVendor A
	INNER JOIN tblEMEntity B ON A.intEntityId = B.intEntityId
	INNER JOIN tblEMEntityLocation C ON B.intEntityId = C.intEntityId
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

	SET @ErrorMessage  = 'Error staging vendor export.' + CHAR(13) + 
		'SQL Server Error Message is: ' + CAST(@ErrorNumber AS VARCHAR(10)) + 
		' in procedure: ' + @ErrorProc + ' Line: ' + CAST(@ErrorLine AS VARCHAR(10)) + ' Error text: ' + @ErrorMessage
		
	RAISERROR (@ErrorMessage , @ErrorSeverity, @ErrorState, @ErrorNumber)
END CATCH

END