CREATE FUNCTION [dbo].[fnAP1099EFileDIVPayee]
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
		+ 
			 CASE WHEN ISNULL(A.dblOrdinaryDividends,0) > @maxAmount 
				THEN REPLICATE('0',12 - LEN(dbo.fnAPRemoveSpecialChars(CAST(@maxAmount - CAST(ISNULL(A.dblOrdinaryDividends,0) AS DECIMAL(18,2)) AS NVARCHAR(100)))))
					+ dbo.fnAPRemoveSpecialChars(CAST(@maxAmount - CAST(ISNULL(A.dblOrdinaryDividends,0) AS DECIMAL(18,2)) AS NVARCHAR(100))) 
				ELSE 
					REPLICATE('0',12 - LEN(dbo.fnAPRemoveSpecialChars(CAST(CAST(ISNULL(A.dblOrdinaryDividends,0) AS DECIMAL(18,2)) AS NVARCHAR(100)))))
					+ dbo.fnAPRemoveSpecialChars(CAST(CAST(ISNULL(A.dblOrdinaryDividends,0) AS DECIMAL(18,2)) AS NVARCHAR(100)))
			END
			+ CASE WHEN ISNULL(A.dblQualified,0) > @maxAmount 
				THEN REPLICATE('0',12 - LEN(dbo.fnAPRemoveSpecialChars(CAST(@maxAmount - CAST(ISNULL(A.dblQualified,0) AS DECIMAL(18,2)) AS NVARCHAR(100)))))
					+ dbo.fnAPRemoveSpecialChars(CAST(@maxAmount - CAST(ISNULL(A.dblQualified,0) AS DECIMAL(18,2)) AS NVARCHAR(100))) 
				ELSE 
					REPLICATE('0',12 - LEN(dbo.fnAPRemoveSpecialChars(CAST(CAST(ISNULL(A.dblQualified,0) AS DECIMAL(18,2)) AS NVARCHAR(100)))))
					+ dbo.fnAPRemoveSpecialChars(CAST(CAST(ISNULL(A.dblQualified,0) AS DECIMAL(18,2)) AS NVARCHAR(100)))
			END
			+ CASE WHEN ISNULL(ISNULL(A.dblCapitalGain,0),0) > @maxAmount 
				THEN REPLICATE('0',12 - LEN(dbo.fnAPRemoveSpecialChars(CAST(@maxAmount - CAST(ISNULL(A.dblCapitalGain,0) AS DECIMAL(18,2)) AS NVARCHAR(100)))))
					+ dbo.fnAPRemoveSpecialChars(CAST(@maxAmount - CAST(ISNULL(A.dblCapitalGain,0) AS DECIMAL(18,2)) AS NVARCHAR(100))) 
				ELSE 
					REPLICATE('0',12 - LEN(dbo.fnAPRemoveSpecialChars(CAST(CAST(ISNULL(A.dblCapitalGain,0) AS DECIMAL(18,2)) AS NVARCHAR(100)))))
					+ dbo.fnAPRemoveSpecialChars(CAST(CAST(ISNULL(A.dblCapitalGain,0) AS DECIMAL(18,2)) AS NVARCHAR(100)))
			END
			+ CASE WHEN ISNULL(A.dblUnrecapGain,0) > @maxAmount 
				THEN REPLICATE('0',12 - LEN(dbo.fnAPRemoveSpecialChars(CAST(@maxAmount - CAST(ISNULL(A.dblUnrecapGain,0) AS DECIMAL(18,2)) AS NVARCHAR(100)))))
					+ dbo.fnAPRemoveSpecialChars(CAST(@maxAmount - CAST(ISNULL(A.dblUnrecapGain,0) AS DECIMAL(18,2)) AS NVARCHAR(100))) 
				ELSE 
					REPLICATE('0',12 - LEN(dbo.fnAPRemoveSpecialChars(CAST(CAST(ISNULL(A.dblUnrecapGain,0) AS DECIMAL(18,2)) AS NVARCHAR(100)))))
					+ dbo.fnAPRemoveSpecialChars(CAST(CAST(ISNULL(A.dblUnrecapGain,0) AS DECIMAL(18,2)) AS NVARCHAR(100)))
			END
			+ CASE WHEN ISNULL(A.dblSection1202,0) > @maxAmount 
				THEN REPLICATE('0',12 - LEN(dbo.fnAPRemoveSpecialChars(CAST(@maxAmount - CAST(ISNULL(A.dblSection1202,0) AS DECIMAL(18,2)) AS NVARCHAR(100)))))
					+ dbo.fnAPRemoveSpecialChars(CAST(@maxAmount - CAST(ISNULL(A.dblSection1202,0) AS DECIMAL(18,2)) AS NVARCHAR(100))) 
				ELSE 
					REPLICATE('0',12 - LEN(dbo.fnAPRemoveSpecialChars(CAST(CAST(ISNULL(A.dblSection1202,0) AS DECIMAL(18,2)) AS NVARCHAR(100)))))
					+ dbo.fnAPRemoveSpecialChars(CAST(CAST(ISNULL(A.dblSection1202,0) AS DECIMAL(18,2)) AS NVARCHAR(100)))
			END
			+ CASE WHEN ISNULL(A.dblCollectibles,0) > @maxAmount 
				THEN REPLICATE('0',12 - LEN(dbo.fnAPRemoveSpecialChars(CAST(@maxAmount - CAST(ISNULL(A.dblCollectibles,0) AS DECIMAL(18,2)) AS NVARCHAR(100)))))
					+ dbo.fnAPRemoveSpecialChars(CAST(@maxAmount - CAST(ISNULL(A.dblCollectibles,0) AS DECIMAL(18,2)) AS NVARCHAR(100))) 
				ELSE 
					REPLICATE('0',12 - LEN(dbo.fnAPRemoveSpecialChars(CAST(CAST(ISNULL(A.dblCollectibles,0) AS DECIMAL(18,2)) AS NVARCHAR(100)))))
					+ dbo.fnAPRemoveSpecialChars(CAST(CAST(ISNULL(A.dblCollectibles,0) AS DECIMAL(18,2)) AS NVARCHAR(100)))
			END
			+ CASE WHEN ISNULL(A.dblNonDividends,0) > @maxAmount 
				THEN REPLICATE('0',12 - LEN(dbo.fnAPRemoveSpecialChars(CAST(@maxAmount - CAST(ISNULL(A.dblNonDividends,0) AS DECIMAL(18,2)) AS NVARCHAR(100)))))
					+ dbo.fnAPRemoveSpecialChars(CAST(@maxAmount - CAST(ISNULL(A.dblNonDividends,0) AS DECIMAL(18,2)) AS NVARCHAR(100))) 
				ELSE 
					REPLICATE('0',12 - LEN(dbo.fnAPRemoveSpecialChars(CAST(CAST(ISNULL(A.dblNonDividends,0) AS DECIMAL(18,2)) AS NVARCHAR(100)))))
					+ dbo.fnAPRemoveSpecialChars(CAST(CAST(ISNULL(A.dblNonDividends,0) AS DECIMAL(18,2)) AS NVARCHAR(100)))
			END
			+ CASE WHEN ISNULL(A.dblFITW,0) > @maxAmount 
				THEN REPLICATE('0',12 - LEN(dbo.fnAPRemoveSpecialChars(CAST(@maxAmount - CAST(ISNULL(A.dblFITW,0) AS DECIMAL(18,2)) AS NVARCHAR(100)))))
					+ dbo.fnAPRemoveSpecialChars(CAST(@maxAmount - CAST(ISNULL(A.dblFITW,0) AS DECIMAL(18,2)) AS NVARCHAR(100))) 
				ELSE 
					REPLICATE('0',12 - LEN(dbo.fnAPRemoveSpecialChars(CAST(CAST(ISNULL(A.dblFITW,0) AS DECIMAL(18,2)) AS NVARCHAR(100)))))
					+ dbo.fnAPRemoveSpecialChars(CAST(CAST(ISNULL(A.dblFITW,0) AS DECIMAL(18,2)) AS NVARCHAR(100)))
			END
			+ REPLICATE('0',12) --Payment Amount 9
			+ CASE WHEN ISNULL(A.dblInvestment,0) > @maxAmount 
				THEN REPLICATE('0',12 - LEN(dbo.fnAPRemoveSpecialChars(CAST(@maxAmount - CAST(ISNULL(A.dblInvestment,0) AS DECIMAL(18,2)) AS NVARCHAR(100)))))
					+ dbo.fnAPRemoveSpecialChars(CAST(@maxAmount - CAST(ISNULL(A.dblInvestment,0) AS DECIMAL(18,2)) AS NVARCHAR(100))) 
				ELSE 
					REPLICATE('0',12 - LEN(dbo.fnAPRemoveSpecialChars(CAST(CAST(ISNULL(A.dblInvestment,0) AS DECIMAL(18,2)) AS NVARCHAR(100)))))
					+ dbo.fnAPRemoveSpecialChars(CAST(CAST(ISNULL(A.dblInvestment,0) AS DECIMAL(18,2)) AS NVARCHAR(100)))
			END
			+ CASE WHEN ISNULL(A.dblForeignTax,0) > @maxAmount 
				THEN REPLICATE('0',12 - LEN(dbo.fnAPRemoveSpecialChars(CAST(@maxAmount - CAST(ISNULL(A.dblForeignTax,0) AS DECIMAL(18,2)) AS NVARCHAR(100)))))
					+ dbo.fnAPRemoveSpecialChars(CAST(@maxAmount - CAST(ISNULL(A.dblForeignTax,0) AS DECIMAL(18,2)) AS NVARCHAR(100))) 
				ELSE 
					REPLICATE('0',12 - LEN(dbo.fnAPRemoveSpecialChars(CAST(CAST(ISNULL(A.dblForeignTax,0) AS DECIMAL(18,2)) AS NVARCHAR(100)))))
					+ dbo.fnAPRemoveSpecialChars(CAST(CAST(ISNULL(A.dblForeignTax,0) AS DECIMAL(18,2)) AS NVARCHAR(100)))
			END
			+ CASE WHEN ISNULL(A.dblCash,0) > @maxAmount 
				THEN REPLICATE('0',12 - LEN(dbo.fnAPRemoveSpecialChars(CAST(@maxAmount - CAST(ISNULL(A.dblCash,0) AS DECIMAL(18,2)) AS NVARCHAR(100)))))
					+ dbo.fnAPRemoveSpecialChars(CAST(@maxAmount - CAST(ISNULL(A.dblCash,0) AS DECIMAL(18,2)) AS NVARCHAR(100))) 
				ELSE 
					REPLICATE('0',12 - LEN(dbo.fnAPRemoveSpecialChars(CAST(CAST(ISNULL(A.dblCash,0) AS DECIMAL(18,2)) AS NVARCHAR(100)))))
					+ dbo.fnAPRemoveSpecialChars(CAST(CAST(ISNULL(A.dblCash,0) AS DECIMAL(18,2)) AS NVARCHAR(100)))
			END
			+ CASE WHEN ISNULL(A.dblNonCash,0) > @maxAmount 
				THEN REPLICATE('0',12 - LEN(dbo.fnAPRemoveSpecialChars(CAST(@maxAmount - CAST(ISNULL(A.dblNonCash,0) AS DECIMAL(18,2)) AS NVARCHAR(100)))))
					+ dbo.fnAPRemoveSpecialChars(CAST(@maxAmount - CAST(ISNULL(A.dblNonCash,0) AS DECIMAL(18,2)) AS NVARCHAR(100))) 
				ELSE 
					REPLICATE('0',12 - LEN(dbo.fnAPRemoveSpecialChars(CAST(CAST(ISNULL(A.dblNonCash,0) AS DECIMAL(18,2)) AS NVARCHAR(100)))))
					+ dbo.fnAPRemoveSpecialChars(CAST(CAST(ISNULL(A.dblNonCash,0) AS DECIMAL(18,2)) AS NVARCHAR(100)))
			END
			+ CASE WHEN ISNULL(A.dblExempt,0) > @maxAmount 
				THEN REPLICATE('0',12 - LEN(dbo.fnAPRemoveSpecialChars(CAST(@maxAmount - CAST(ISNULL(A.dblExempt,0) AS DECIMAL(18,2)) AS NVARCHAR(100)))))
					+ dbo.fnAPRemoveSpecialChars(CAST(@maxAmount - CAST(ISNULL(A.dblExempt,0) AS DECIMAL(18,2)) AS NVARCHAR(100))) 
				ELSE 
					REPLICATE('0',12 - LEN(dbo.fnAPRemoveSpecialChars(CAST(CAST(ISNULL(A.dblExempt,0) AS DECIMAL(18,2)) AS NVARCHAR(100)))))
					+ dbo.fnAPRemoveSpecialChars(CAST(CAST(ISNULL(A.dblExempt,0) AS DECIMAL(18,2)) AS NVARCHAR(100)))
			END	
			+ CASE WHEN ISNULL(A.dblPrivate,0) > @maxAmount 
				THEN REPLICATE('0',12 - LEN(dbo.fnAPRemoveSpecialChars(CAST(@maxAmount - CAST(ISNULL(A.dblPrivate,0) AS DECIMAL(18,2)) AS NVARCHAR(100)))))
					+ dbo.fnAPRemoveSpecialChars(CAST(@maxAmount - CAST(ISNULL(A.dblPrivate,0) AS DECIMAL(18,2)) AS NVARCHAR(100))) 
				ELSE 
					REPLICATE('0',12 - LEN(dbo.fnAPRemoveSpecialChars(CAST(CAST(ISNULL(A.dblPrivate,0) AS DECIMAL(18,2)) AS NVARCHAR(100)))))
					+ dbo.fnAPRemoveSpecialChars(CAST(CAST(ISNULL(A.dblPrivate,0) AS DECIMAL(18,2)) AS NVARCHAR(100)))
			END           
		--+ REPLICATE('0',12) --Section 409A deferals
		--+ REPLICATE('0',12) --Section 409A income
		--+ REPLICATE('0',12)
		+ REPLICATE('0',12) 
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
		+ CASE WHEN A.dblOrdinaryDividends IS NOT NULL THEN '11' ELSE ' ' END
		+ SPACE(1)
		+ SPACE(114)
		+ SPACE(60)
		+ SPACE(12)
		+ SPACE(12)
		+ SPACE(2)
		+ CHAR(13) + CHAR(10)
	FROM dbo.vyuAP1099DIV A
	WHERE 1 = (CASE WHEN @vendorFrom IS NOT NULL THEN
				(CASE WHEN A.strVendorId BETWEEN @vendorFrom AND @vendorTo THEN 1 ELSE 0 END)
			ELSE 1 END)
	AND A.intYear = @year
	RETURN;
END