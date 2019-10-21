CREATE FUNCTION [dbo].[fnAP1099EFileKPayee]
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
		+ SPACE(9 - LEN(ISNULL(NULLIF(SUBSTRING(REPLACE(SUBSTRING(dbo.fnTrimX(A.strFederalTaxId),0,10),'-',''),1,10),''),SPACE(9)))) 
			+ ISNULL(NULLIF(SUBSTRING(REPLACE(SUBSTRING(dbo.fnTrimX(A.strFederalTaxId),0,10),'-',''),1,10),''),SPACE(9)) -- 12-20
		+ CAST(A.intEntityVendorId AS NVARCHAR) + SPACE(20 - LEN(CAST(A.intEntityVendorId AS NVARCHAR))) -- 21-40
		+ SPACE(4) -- 41-44
		+ SPACE(10) -- 45-54
		+ --PAGE 79
			 CASE WHEN ISNULL(A.dblGrossThirdParty,0) > @maxAmount 
				THEN REPLICATE('0',10 - LEN(CAST(FLOOR((@maxAmount - CAST(ISNULL(A.dblGrossThirdParty,0) AS DECIMAL(18,2)))) AS NVARCHAR(100))))
					+ CAST(FLOOR((@maxAmount - CAST(ISNULL(A.dblGrossThirdParty,0) AS DECIMAL(18,2)))) AS NVARCHAR(100))
					+ CAST(PARSENAME(CAST(ISNULL(A.dblGrossThirdParty,0) AS DECIMAL(18,2)),1) AS NVARCHAR(2))
				ELSE 
					REPLICATE('0',10 - LEN(CAST(FLOOR((CAST(ISNULL(A.dblGrossThirdParty,0) AS DECIMAL(18,2)))) AS NVARCHAR(100)))) --add zeros after the whole number
					+ CAST(FLOOR((CAST(ISNULL(A.dblGrossThirdParty,0) AS DECIMAL(18,2)))) AS NVARCHAR(100)) --get the whole number
					+ CAST(PARSENAME(CAST(ISNULL(A.dblGrossThirdParty,0) AS DECIMAL(18,2)),1) AS NVARCHAR(2)) --last two digit decimal
			END
			+ CASE WHEN ISNULL(A.dblCardNotPresent,0) > @maxAmount 
				THEN REPLICATE('0',10 - LEN(CAST(FLOOR((@maxAmount - CAST(ISNULL(A.dblCardNotPresent,0) AS DECIMAL(18,2)))) AS NVARCHAR(100))))
					+ CAST(FLOOR((@maxAmount - CAST(ISNULL(A.dblCardNotPresent,0) AS DECIMAL(18,2)))) AS NVARCHAR(100))
					+ CAST(PARSENAME(CAST(ISNULL(A.dblCardNotPresent,0) AS DECIMAL(18,2)),1) AS NVARCHAR(2))
				ELSE 
					REPLICATE('0',10 - LEN(CAST(FLOOR((ISNULL(A.dblCardNotPresent,0))) AS NVARCHAR(100))))
					+ CAST(FLOOR((CAST(ISNULL(A.dblCardNotPresent,0) AS DECIMAL(18,2)))) AS NVARCHAR(100))
					+ CAST(PARSENAME(CAST(ISNULL(A.dblCardNotPresent,0) AS DECIMAL(18,2)),1) AS NVARCHAR(2))
			END
			+ CASE WHEN ISNULL(ISNULL(A.dblFederalIncomeTax,0),0) > @maxAmount 
				THEN REPLICATE('0',10 - LEN(CAST(FLOOR((@maxAmount - CAST(ISNULL(A.dblFederalIncomeTax,0) AS DECIMAL(18,2)))) AS NVARCHAR(100))))
					+ CAST(FLOOR((@maxAmount - CAST(ISNULL(A.dblFederalIncomeTax,0) AS DECIMAL(18,2)))) AS NVARCHAR(100))
					+ CAST(PARSENAME(CAST(ISNULL(A.dblFederalIncomeTax,0) AS DECIMAL(18,2)),1) AS NVARCHAR(2))
				ELSE 
					REPLICATE('0',10 - LEN(CAST(FLOOR((ISNULL(A.dblFederalIncomeTax,0))) AS NVARCHAR(100))))
					+ CAST(FLOOR((CAST(ISNULL(A.dblFederalIncomeTax,0) AS DECIMAL(18,2)))) AS NVARCHAR(100))
					+ CAST(PARSENAME(CAST(ISNULL(A.dblFederalIncomeTax,0) AS DECIMAL(18,2)),1) AS NVARCHAR(2))
			END
			+ CASE WHEN ISNULL(A.dblJanuary,0) > @maxAmount 
				THEN REPLICATE('0',10 - LEN(CAST(FLOOR((@maxAmount - CAST(ISNULL(A.dblJanuary,0) AS DECIMAL(18,2)))) AS NVARCHAR(100))))
					+ CAST(FLOOR((@maxAmount - CAST(ISNULL(A.dblJanuary,0) AS DECIMAL(18,2)))) AS NVARCHAR(100))
					+ CAST(PARSENAME(CAST(ISNULL(A.dblJanuary,0) AS DECIMAL(18,2)),1) AS NVARCHAR(2))
				ELSE 
					REPLICATE('0',10 - LEN(CAST(FLOOR((ISNULL(A.dblJanuary,0))) AS NVARCHAR(100))))
					+ CAST(FLOOR((CAST(ISNULL(A.dblJanuary,0) AS DECIMAL(18,2)))) AS NVARCHAR(100))
					+ CAST(PARSENAME(CAST(ISNULL(A.dblJanuary,0) AS DECIMAL(18,2)),1) AS NVARCHAR(2))
			END
			+ CASE WHEN ISNULL(A.dblFebruary,0) > @maxAmount 
				THEN REPLICATE('0',10 - LEN(CAST(FLOOR((@maxAmount - CAST(ISNULL(A.dblFebruary,0) AS DECIMAL(18,2)))) AS NVARCHAR(100))))
					+ CAST(FLOOR((@maxAmount - CAST(ISNULL(A.dblFebruary,0) AS DECIMAL(18,2)))) AS NVARCHAR(100))
					+ CAST(PARSENAME(CAST(ISNULL(A.dblFebruary,0) AS DECIMAL(18,2)),1) AS NVARCHAR(2))
				ELSE 
					REPLICATE('0',10 - LEN(CAST(FLOOR((ISNULL(A.dblFebruary,0))) AS NVARCHAR(100))))
					+ CAST(FLOOR((CAST(ISNULL(A.dblFebruary,0) AS DECIMAL(18,2)))) AS NVARCHAR(100))
					+ CAST(PARSENAME(CAST(ISNULL(A.dblFebruary,0) AS DECIMAL(18,2)),1) AS NVARCHAR(2))
			END
			+ CASE WHEN ISNULL(A.dblMarch,0) > @maxAmount 
				THEN REPLICATE('0',10 - LEN(CAST(FLOOR((@maxAmount - CAST(ISNULL(A.dblMarch,0) AS DECIMAL(18,2)))) AS NVARCHAR(100))))
					+ CAST(FLOOR((@maxAmount - CAST(ISNULL(A.dblMarch,0) AS DECIMAL(18,2)))) AS NVARCHAR(100))
					+ CAST(PARSENAME(CAST(ISNULL(A.dblMarch,0) AS DECIMAL(18,2)),1) AS NVARCHAR(2))
				ELSE 
					REPLICATE('0',10 - LEN(CAST(FLOOR((ISNULL(A.dblMarch,0))) AS NVARCHAR(100))))
					+ CAST(FLOOR((CAST(ISNULL(A.dblMarch,0) AS DECIMAL(18,2)))) AS NVARCHAR(100))
					+ CAST(PARSENAME(CAST(ISNULL(A.dblMarch,0) AS DECIMAL(18,2)),1) AS NVARCHAR(2))
			END
			+ CASE WHEN ISNULL(A.dblApril,0) > @maxAmount 
				THEN REPLICATE('0',10 - LEN(CAST(FLOOR((@maxAmount - CAST(ISNULL(A.dblApril,0) AS DECIMAL(18,2)))) AS NVARCHAR(100))))
					+ CAST(FLOOR((@maxAmount - CAST(ISNULL(A.dblApril,0) AS DECIMAL(18,2)))) AS NVARCHAR(100))
					+ CAST(PARSENAME(CAST(ISNULL(A.dblApril,0) AS DECIMAL(18,2)),1) AS NVARCHAR(2))
				ELSE 
					REPLICATE('0',10 - LEN(CAST(FLOOR((ISNULL(A.dblApril,0))) AS NVARCHAR(100))))
					+ CAST(FLOOR((CAST(ISNULL(A.dblApril,0) AS DECIMAL(18,2)))) AS NVARCHAR(100))
					+ CAST(PARSENAME(CAST(ISNULL(A.dblApril,0) AS DECIMAL(18,2)),1) AS NVARCHAR(2))
			END
			+ CASE WHEN ISNULL(A.dblMay,0) > @maxAmount 
				THEN REPLICATE('0',10 - LEN(CAST(FLOOR((@maxAmount - CAST(ISNULL(A.dblMay,0) AS DECIMAL(18,2)))) AS NVARCHAR(100))))
					+ CAST(FLOOR((@maxAmount - CAST(ISNULL(A.dblMay,0) AS DECIMAL(18,2)))) AS NVARCHAR(100))
					+ CAST(PARSENAME(CAST(ISNULL(A.dblMay,0) AS DECIMAL(18,2)),1) AS NVARCHAR(2))
				ELSE 
					REPLICATE('0',10 - LEN(CAST(FLOOR((ISNULL(A.dblMay,0))) AS NVARCHAR(100))))
					+ CAST(FLOOR((CAST(ISNULL(A.dblMay,0) AS DECIMAL(18,2)))) AS NVARCHAR(100))
					+ CAST(PARSENAME(CAST(ISNULL(A.dblMay,0) AS DECIMAL(18,2)),1) AS NVARCHAR(2))
			END
			+ REPLICATE('0',12) --Payment Amount 9
			+ CASE WHEN ISNULL(A.dblJune,0) > @maxAmount 
				THEN REPLICATE('0',10 - LEN(CAST(FLOOR((@maxAmount - CAST(ISNULL(A.dblJune,0) AS DECIMAL(18,2)))) AS NVARCHAR(100))))
					+ CAST(FLOOR((@maxAmount - CAST(ISNULL(A.dblJune,0) AS DECIMAL(18,2)))) AS NVARCHAR(100))
					+ CAST(PARSENAME(CAST(ISNULL(A.dblJune,0) AS DECIMAL(18,2)),1) AS NVARCHAR(2))
				ELSE 
					REPLICATE('0',10 - LEN(CAST(FLOOR((ISNULL(A.dblJune,0))) AS NVARCHAR(100))))
					+ CAST(FLOOR((CAST(ISNULL(A.dblJune,0) AS DECIMAL(18,2)))) AS NVARCHAR(100))
					+ CAST(PARSENAME(CAST(ISNULL(A.dblJune,0) AS DECIMAL(18,2)),1) AS NVARCHAR(2))
			END
			+ CASE WHEN ISNULL(A.dblJuly,0) > @maxAmount 
				THEN REPLICATE('0',10 - LEN(CAST(FLOOR((@maxAmount - CAST(ISNULL(A.dblJuly,0) AS DECIMAL(18,2)))) AS NVARCHAR(100))))
					+ CAST(FLOOR((@maxAmount - CAST(ISNULL(A.dblJuly,0) AS DECIMAL(18,2)))) AS NVARCHAR(100))
					+ CAST(PARSENAME(CAST(ISNULL(A.dblJuly,0) AS DECIMAL(18,2)),1) AS NVARCHAR(2))
				ELSE 
					REPLICATE('0',10 - LEN(CAST(FLOOR((ISNULL(A.dblJuly,0))) AS NVARCHAR(100))))
					+ CAST(FLOOR((CAST(ISNULL(A.dblJuly,0) AS DECIMAL(18,2)))) AS NVARCHAR(100))
					+ CAST(PARSENAME(CAST(ISNULL(A.dblJuly,0) AS DECIMAL(18,2)),1) AS NVARCHAR(2))
			END
			+ CASE WHEN ISNULL(A.dblAugust,0) > @maxAmount 
				THEN REPLICATE('0',10 - LEN(CAST(FLOOR((@maxAmount - CAST(ISNULL(A.dblAugust,0) AS DECIMAL(18,2)))) AS NVARCHAR(100))))
					+ CAST(FLOOR((@maxAmount - CAST(ISNULL(A.dblAugust,0) AS DECIMAL(18,2)))) AS NVARCHAR(100))
					+ CAST(PARSENAME(CAST(ISNULL(A.dblAugust,0) AS DECIMAL(18,2)),1) AS NVARCHAR(2))
				ELSE 
					REPLICATE('0',10 - LEN(CAST(FLOOR((ISNULL(A.dblAugust,0))) AS NVARCHAR(100))))
					+ CAST(FLOOR((CAST(ISNULL(A.dblAugust,0) AS DECIMAL(18,2)))) AS NVARCHAR(100))
					+ CAST(PARSENAME(CAST(ISNULL(A.dblAugust,0) AS DECIMAL(18,2)),1) AS NVARCHAR(2))
			END
			+ CASE WHEN ISNULL(A.dblSeptember,0) > @maxAmount 
				THEN REPLICATE('0',10 - LEN(CAST(FLOOR((@maxAmount - CAST(ISNULL(A.dblSeptember,0) AS DECIMAL(18,2)))) AS NVARCHAR(100))))
					+ CAST(FLOOR((@maxAmount - CAST(ISNULL(A.dblSeptember,0) AS DECIMAL(18,2)))) AS NVARCHAR(100))
					+ CAST(PARSENAME(CAST(ISNULL(A.dblSeptember,0) AS DECIMAL(18,2)),1) AS NVARCHAR(2))
				ELSE 
					REPLICATE('0',10 - LEN(CAST(FLOOR((ISNULL(A.dblSeptember,0))) AS NVARCHAR(100))))
					+ CAST(FLOOR((CAST(ISNULL(A.dblSeptember,0) AS DECIMAL(18,2)))) AS NVARCHAR(100))
					+ CAST(PARSENAME(CAST(ISNULL(A.dblSeptember,0) AS DECIMAL(18,2)),1) AS NVARCHAR(2))
			END
			+ CASE WHEN ISNULL(A.dblOctober,0) > @maxAmount 
				THEN REPLICATE('0',10 - LEN(CAST(FLOOR((@maxAmount - CAST(ISNULL(A.dblOctober,0) AS DECIMAL(18,2)))) AS NVARCHAR(100))))
					+ CAST(FLOOR((@maxAmount - CAST(ISNULL(A.dblOctober,0) AS DECIMAL(18,2)))) AS NVARCHAR(100))
					+ CAST(PARSENAME(CAST(ISNULL(A.dblOctober,0) AS DECIMAL(18,2)),1) AS NVARCHAR(2))
				ELSE 
					REPLICATE('0',10 - LEN(CAST(FLOOR((ISNULL(A.dblOctober,0))) AS NVARCHAR(100))))
					+ CAST(FLOOR((CAST(ISNULL(A.dblOctober,0) AS DECIMAL(18,2)))) AS NVARCHAR(100))
					+ CAST(PARSENAME(CAST(ISNULL(A.dblOctober,0) AS DECIMAL(18,2)),1) AS NVARCHAR(2))
			END
			+ CASE WHEN ISNULL(A.dblNovember,0) > @maxAmount 
				THEN REPLICATE('0',10 - LEN(CAST(FLOOR((@maxAmount - CAST(ISNULL(A.dblNovember,0) AS DECIMAL(18,2)))) AS NVARCHAR(100))))
					+ CAST(FLOOR((@maxAmount - CAST(ISNULL(A.dblNovember,0) AS DECIMAL(18,2)))) AS NVARCHAR(100))
					+ CAST(PARSENAME(CAST(ISNULL(A.dblNovember,0) AS DECIMAL(18,2)),1) AS NVARCHAR(2))
				ELSE 
					REPLICATE('0',10 - LEN(CAST(FLOOR((ISNULL(A.dblNovember,0))) AS NVARCHAR(100))))
					+ CAST(FLOOR((CAST(ISNULL(A.dblNovember,0) AS DECIMAL(18,2)))) AS NVARCHAR(100))
					+ CAST(PARSENAME(CAST(ISNULL(A.dblNovember,0) AS DECIMAL(18,2)),1) AS NVARCHAR(2))
			END
			+ CASE WHEN ISNULL(A.dblDecember,0) > @maxAmount 
				THEN REPLICATE('0',10 - LEN(CAST(FLOOR((@maxAmount - CAST(ISNULL(A.dblDecember,0) AS DECIMAL(18,2)))) AS NVARCHAR(100))))
					+ CAST(FLOOR((@maxAmount - CAST(ISNULL(A.dblDecember,0) AS DECIMAL(18,2)))) AS NVARCHAR(100))
					+ CAST(PARSENAME(CAST(ISNULL(A.dblDecember,0) AS DECIMAL(18,2)),1) AS NVARCHAR(2))
				ELSE 
					REPLICATE('0',10 - LEN(CAST(FLOOR((ISNULL(A.dblDecember,0))) AS NVARCHAR(100))))
					+ CAST(FLOOR((CAST(ISNULL(A.dblDecember,0) AS DECIMAL(18,2)))) AS NVARCHAR(100))
					+ CAST(PARSENAME(CAST(ISNULL(A.dblDecember,0) AS DECIMAL(18,2)),1) AS NVARCHAR(2))
			END
		-- + REPLICATE('0',12) --Section 409A deferals
		-- + REPLICATE('0',12) --Section 409A income
		-- + REPLICATE('0',12)
		-- + REPLICATE('0',12) 
		-- 235-246
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
		+ SPACE(2)
		+ CASE WHEN A.strFilerType = 'PSE' THEN '1' ELSE '2' END
		+ CASE WHEN A.strTransactionType = 'Payment Card' THEN '1' ELSE '2' END
		+ SPACE(13) --Number of payment transactions
		+ SPACE(3)
		+ SPACE(40)
		+ SPACE(4)
		+ SPACE(54)
		+ SPACE(60)
		+ SPACE(12)
		+ SPACE(12)
		+ SPACE(2)
		+ CHAR(13) + CHAR(10)
	FROM vyuAP1099K A
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