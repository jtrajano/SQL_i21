CREATE FUNCTION [dbo].[fnAPGet1099PrintStatus]
(
	@vendorFrom NVARCHAR(100) = NULL,
	@vendorTo NVARCHAR(100)  = NULL,
	@year INT,
	@form1099 INT
)
RETURNS BIT
AS
BEGIN
	
	DECLARE @hasPrinted BIT = 0;

	IF EXISTS(SELECT 1
				FROM tblAP1099History A
				WHERE A.intYear = @year AND A.int1099Form = @form1099
				AND 1 = (CASE WHEN ISNULL(@vendorFrom,'') = '' THEN 1
					WHEN ISNULL(@vendorFrom,'') <> '' AND A.strVendorId BETWEEN @vendorFrom AND @vendorTo THEN 1 ELSE 0 END)
				AND A.ysnPrinted = 1
			)
	BEGIN
		SET @hasPrinted = 1
	END

	RETURN @hasPrinted;

END
