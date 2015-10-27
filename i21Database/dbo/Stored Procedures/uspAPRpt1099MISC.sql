CREATE PROCEDURE [dbo].[uspAPRpt1099MISC]
	@vendorFrom NVARCHAR(100) = NULL,
	@vendorTo NVARCHAR(100) = NULL,
	@year INT,
	@corrected BIT = 0
AS

DECLARE @vendorFromParam NVARCHAR(100);
DECLARE @vendorToParam NVARCHAR(100);
DECLARE @yearParam INT;
DECLARE @correctedParam BIT;
DECLARE @query NVARCHAR(MAX);

SET @vendorFromParam = @vendorFrom;
SET @vendorToParam = @vendorTo;
SET @yearParam = @year;
SET @correctedParam = @corrected;


SELECT * FROM vyuAP1099MISC
WHERE 1 = (CASE WHEN @vendorFromParam IS NOT NULL THEN
				(CASE WHEN strVendorId BETWEEN @vendorFromParam AND @vendorToParam THEN 1 ELSE 0 END)
			ELSE 1 END)
AND intYear = @yearParam



