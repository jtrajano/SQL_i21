﻿CREATE FUNCTION [dbo].[fnAP1099EFileNECPayee]
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

	--DECLARE @year INT = 2016
	--DECLARE @reprint BIT = 0
	--DECLARE @corrected BIT = 0
	--DECLARE @vendorFrom NVARCHAR(100) = NULL
	--DECLARE @vendorTo NVARCHAR(100) = NULL

	--See PAGE 61
	DECLARE @maxAmount DECIMAL(18,6) = 9999999999.99;

	INSERT @returntable
	SELECT 
		'B'
		+ CAST(@year AS NVARCHAR(10))  --Position 2-5
		+ CASE WHEN @corrected = 1 THEN 'G' ELSE ' ' END
		+ SPACE(4)
		+ '1' --EIN
		+ SPACE(9 - LEN(ISNULL(NULLIF(SUBSTRING(REPLACE(dbo.fnTrimX(A.strFederalTaxId),'-',''),1,10),''),SPACE(9)))) 
			+ ISNULL(NULLIF(SUBSTRING(REPLACE(dbo.fnTrimX(A.strFederalTaxId),'-',''),1,10),''),SPACE(9)) -- 12-20
		+ CAST(A.intEntityVendorId AS NVARCHAR) + SPACE(20 - LEN(CAST(A.intEntityVendorId AS NVARCHAR))) -- 21-40
		+ SPACE(4) -- 41-44
		+ SPACE(10) -- 45-54
		+ CASE WHEN ISNULL(A.dblNonemployeeCompensationNEC,0) > @maxAmount 
				THEN REPLICATE('0',10 - LEN(CAST(FLOOR((@maxAmount - CAST(ISNULL(A.dblNonemployeeCompensationNEC,0) AS DECIMAL(18,2)))) AS NVARCHAR(100))))
					+ CAST(FLOOR((@maxAmount - CAST(ISNULL(A.dblNonemployeeCompensationNEC,0) AS DECIMAL(18,2)))) AS NVARCHAR(100))
					+ CAST(PARSENAME(CAST(ISNULL(A.dblNonemployeeCompensationNEC,0) AS DECIMAL(18,2)),1) AS NVARCHAR(2))
				ELSE 
					REPLICATE('0',10 - LEN(CAST(FLOOR((CAST(ISNULL(A.dblNonemployeeCompensationNEC,0) AS DECIMAL(18,2)))) AS NVARCHAR(100)))) --add zeros after the whole number
					+ CAST(FLOOR((CAST(ISNULL(A.dblNonemployeeCompensationNEC,0) AS DECIMAL(18,2)))) AS NVARCHAR(100)) --get the whole number
					+ CAST(PARSENAME(CAST(ISNULL(A.dblNonemployeeCompensationNEC,0) AS DECIMAL(18,2)),1) AS NVARCHAR(2)) --last two digit decimal
			END
			+ CASE WHEN ISNULL(A.dblFederalIncomeNEC,0) > @maxAmount 
				THEN REPLICATE('0',10 - LEN(CAST(FLOOR((@maxAmount - CAST(ISNULL(A.dblFederalIncomeNEC,0) AS DECIMAL(18,2)))) AS NVARCHAR(100))))
					+ CAST(FLOOR((@maxAmount - CAST(ISNULL(A.dblFederalIncomeNEC,0) AS DECIMAL(18,2)))) AS NVARCHAR(100))
					+ CAST(PARSENAME(CAST(ISNULL(A.dblFederalIncomeNEC,0) AS DECIMAL(18,2)),1) AS NVARCHAR(2))
				ELSE 
					REPLICATE('0',10 - LEN(CAST(FLOOR((ISNULL(A.dblFederalIncomeNEC,0))) AS NVARCHAR(100))))
					+ CAST(FLOOR((CAST(ISNULL(A.dblFederalIncomeNEC,0) AS DECIMAL(18,2)))) AS NVARCHAR(100))
					+ CAST(PARSENAME(CAST(ISNULL(A.dblFederalIncomeNEC,0) AS DECIMAL(18,2)),1) AS NVARCHAR(2))
				END
			+ REPLICATE('0',12)
			+ REPLICATE('0',12)
			+ REPLICATE('0',12)
			+ REPLICATE('0',12) 
			+ REPLICATE('0',12)
			+ REPLICATE('0',12)
			+ REPLICATE('0',12)
			+ REPLICATE('0',12) 
			+ REPLICATE('0',12)
			+ REPLICATE('0',12)
			+ REPLICATE('0',12)
			+ REPLICATE('0',12) 
			+ REPLICATE('0',12)
			+ REPLICATE('0',12)
		+ ' ' --Foreign Indicator
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
		+ SPACE(1) --544
		+ SPACE(3) --545-547
		+ ' ' -- FATCA
		+ SPACE(174) --549-722
		+ SPACE(12) --723-734
		+ SPACE(12) --735-746
		+ SPACE(2) --747-748
		+ CHAR(13) + CHAR(10) --749-750
	FROM vyuAP1099NEC A
	--OUTER APPLY 
	--(
	--	SELECT TOP 1 * FROM tblAP1099History B
	--	WHERE A.intYear = B.intYear AND B.int1099Form = 1
	--	AND B.intEntityVendorId = A.intEntityVendorId
	--	ORDER BY B.dtmDatePrinted DESC
	--) History
	WHERE 1 = (CASE WHEN @vendorFrom IS NOT NULL THEN
				(CASE WHEN A.strVendorId BETWEEN @vendorFrom AND @vendorTo THEN 1 ELSE 0 END)
			ELSE 1 END)
	AND A.intYear = @year
	--AND 1 = (CASE WHEN History.ysnPrinted IS NOT NULL AND History.ysnPrinted = 1 AND @reprint = 1 THEN 1 
	--		WHEN History.ysnPrinted IS NULL THEN 1
	--		WHEN History.ysnPrinted IS NOT NULL AND History.ysnPrinted = 0 THEN 1
	--		ELSE 0 END)
	RETURN;
END