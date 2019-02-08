﻿CREATE FUNCTION [dbo].[fnAP1099EFileBPayee]
(
	@year INT,
	@reprint BIT = 0,
	@corrected BIT = 0,
	@vendorFrom NVARCHAR(100) = NULL,
	@vendorTo NVARCHAR(100) = NULL
)
RETURNS @returntable TABLE
(
	B NVARCHAR(1500)
)
AS
BEGIN

	--See PAGE 61
	DECLARE @maxAmount DECIMAL(18,6) = 9999999999.99;

	INSERT @returntable
	SELECT 
		'B'
		+ CAST(@year AS NVARCHAR(10))  --Position 2-5
		+ CASE WHEN @corrected = 1 THEN '1' ELSE ' ' END
		+ SPACE(4)
		+ '1'
		+ ISNULL(NULLIF(A.strFederalTaxId,''),SPACE(9)) -- 12-20
		+ dbo.fnTrimX(A.strVendorId) + SPACE(20 - LEN(dbo.fnTrimX(A.strVendorId))) -- 21-40
		+ SPACE(4) -- 41-44
		+ SPACE(10) -- 45-54
		+ REPLICATE ('0',12)
		+ REPLICATE ('0',12)
		+ REPLICATE ('0',12)
		+ CASE WHEN ISNULL(A.dbl1099B,0) > @maxAmount 
				THEN dbo.fnAPRemoveSpecialChars(CAST(@maxAmount - CAST(ISNULL(A.dbl1099B,0) AS DECIMAL(18,2)) AS NVARCHAR(100))) 
					+ REPLICATE('0',12 - LEN(dbo.fnAPRemoveSpecialChars(CAST(@maxAmount - CAST(ISNULL(A.dbl1099B,0) AS DECIMAL(18,2)) AS NVARCHAR(100)))))
				ELSE 
					dbo.fnAPRemoveSpecialChars(CAST(CAST(ISNULL(A.dbl1099B,0) AS DECIMAL(18,2)) AS NVARCHAR(100)))
					+ REPLICATE('0',12 - LEN(dbo.fnAPRemoveSpecialChars(CAST(CAST(ISNULL(A.dbl1099B,0) AS DECIMAL(18,2)) AS NVARCHAR(100)))))
			END
		+ REPLICATE('0',144)
		+ ' '
		+ dbo.fnTrimX(A.strPayeeName) + SPACE(40 - LEN(dbo.fnTrimX(A.strPayeeName)))
		+ SPACE(40) -- 288-327
		+ SPACE(40) -- 328-367
		+ ISNULL(A.strAddress,'') + SPACE(40 - LEN(ISNULL(A.strAddress,'')))
		+ SPACE(40)
		+ ISNULL(A.strCity,'') + SPACE(40 - LEN(ISNULL(A.strCity,'')))
		+ ISNULL(A.strState,SPACE(2))
		+ REPLACE(ISNULL(A.strZip,''),'-','') + SPACE(9 - LEN(REPLACE(ISNULL(A.strZip,''),'-','')))
		+ ' '
		+ REPLICATE('0',8 - LEN(CAST((2 + ROW_NUMBER() OVER (ORDER BY (SELECT 1))) AS NVARCHAR(100)))) + CAST((2 + ROW_NUMBER() OVER (ORDER BY (SELECT 1))) AS NVARCHAR(100))
		+ SPACE(36)
		+ SPACE(1) --544 Page 89
		+ SPACE(1) 
		+ SPACE(1) 
		+ SPACE(1)
		+ SPACE(8)
		/**--OLD--FROM 2016 SPECS--**/
		--+ SPACE(13) --569-607
		--+ SPACE(8) --569-607
		--+ SPACE(1)
		--+ SPACE(1) -- 617
		--+ SPACE(1)
		--+ SPACE(44)
		--+ SPACE(60)
		--+ SPACE(12) -- State Income Tax Withheld
		--+ SPACE(12) -- LOcal Income Tax Withheld
		--+ SPACE(2)
		--+ SPACE(2)
		/**--NEW--FROM 2017 SPECS--**/
		+ SPACE(13) --556-568 CUSIP Number
		+ SPACE(39) --569-607 Description of property
		+ SPACE(8) --608-615 Date acquired
		+ SPACE(1) --616 Loss not allowed indicator
		+ SPACE(1) --617 Applicable check box of Form 8949
		+ SPACE(1) --618 Applicable check box for  Collectables
		+ SPACE(1) --619 FATCA filing requirements indicator
		+ SPACE(43) --620-662 blank
		+ SPACE(60) --663-722 special data entries
		+ SPACE(12) --723-734 State Income Tax Withheld
		+ SPACE(12) --735-746 Local Income Tax Withheld
		+ SPACE(2) --747-748 Combined Federal/State Code
		+ CHAR(13) + CHAR(10)
	FROM vyuAP1099B A
	-- OUTER APPLY 
	-- (
	-- 	SELECT TOP 1 * FROM tblAP1099History B
	-- 	WHERE A.intYear = B.intYear AND B.int1099Form = 3
	-- 	AND B.intEntityVendorId = A.[intEntityId]
	-- 	ORDER BY B.dtmDatePrinted DESC
	-- ) History
	WHERE 1 = (CASE WHEN @vendorFrom IS NOT NULL THEN
				(CASE WHEN A.strVendorId BETWEEN @vendorFrom AND @vendorTo THEN 1 ELSE 0 END)
			ELSE 1 END)
	AND A.intYear = @year
	-- AND 1 = (CASE WHEN History.ysnPrinted IS NOT NULL AND History.ysnPrinted = 1 AND @reprint = 1 THEN 1 
	-- 		WHEN History.ysnPrinted IS NULL THEN 1
	-- 		WHEN History.ysnPrinted IS NOT NULL AND History.ysnPrinted = 0 THEN 1
	-- 		ELSE 0 END)
	RETURN;
END
