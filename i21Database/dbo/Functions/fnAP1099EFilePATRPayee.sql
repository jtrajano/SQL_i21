CREATE FUNCTION [dbo].[fnAP1099EFilePATRPayee]
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
		+ CASE WHEN ISNULL(A.dblDividends,0) IS NOT NULL THEN REPLICATE('0',192) -- ALL ZEROS WHEN DIRECT SALES SEE PAGE 53
		  ELSE
			 CASE WHEN ISNULL(A.dblDividends,0) > @maxAmount 
				THEN dbo.fnAPRemoveSpecialChars(CAST(@maxAmount - CAST(ISNULL(A.dblDividends,0) AS DECIMAL(18,2)) AS NVARCHAR(100))) 
					+ REPLICATE('0',12 - LEN(dbo.fnAPRemoveSpecialChars(CAST(@maxAmount - CAST(ISNULL(A.dblDividends,0) AS DECIMAL(18,2)) AS NVARCHAR(100)))))
				ELSE 
					dbo.fnAPRemoveSpecialChars(CAST(CAST(ISNULL(A.dblDividends,0) AS DECIMAL(18,2)) AS NVARCHAR(100)))
					+ REPLICATE('0',12 - LEN(dbo.fnAPRemoveSpecialChars(CAST(CAST(ISNULL(A.dblDividends,0) AS DECIMAL(18,2)) AS NVARCHAR(100)))))
			END
			+ CASE WHEN ISNULL(A.dblNonpatronage,0) > @maxAmount 
				THEN dbo.fnAPRemoveSpecialChars(CAST(@maxAmount - CAST(ISNULL(A.dblNonpatronage,0) AS DECIMAL(18,2)) AS NVARCHAR(100))) 
					+ REPLICATE('0',12 - LEN(dbo.fnAPRemoveSpecialChars(CAST(@maxAmount - CAST(ISNULL(A.dblNonpatronage,0) AS DECIMAL(18,2)) AS NVARCHAR(100)))))
				ELSE 
					dbo.fnAPRemoveSpecialChars(CAST(CAST(ISNULL(A.dblNonpatronage,0) AS DECIMAL(18,2)) AS NVARCHAR(100)))
					+ REPLICATE('0',12 - LEN(dbo.fnAPRemoveSpecialChars(CAST(CAST(ISNULL(A.dblNonpatronage,0) AS DECIMAL(18,2)) AS NVARCHAR(100)))))
			END
			+ CASE WHEN ISNULL(A.dblPerUnit,0) > @maxAmount 
				THEN dbo.fnAPRemoveSpecialChars(CAST(@maxAmount - CAST(ISNULL(A.dblPerUnit,0) AS DECIMAL(18,2)) AS NVARCHAR(100))) 
					+ REPLICATE('0',12 - LEN(dbo.fnAPRemoveSpecialChars(CAST(@maxAmount - CAST(ISNULL(A.dblPerUnit,0) AS DECIMAL(18,2)) AS NVARCHAR(100)))))
				ELSE 
					dbo.fnAPRemoveSpecialChars(CAST(CAST(ISNULL(A.dblPerUnit,0) AS DECIMAL(18,2)) AS NVARCHAR(100)))
					+ REPLICATE('0',12 - LEN(dbo.fnAPRemoveSpecialChars(CAST(CAST(ISNULL(A.dblPerUnit,0) AS DECIMAL(18,2)) AS NVARCHAR(100)))))
			END
			+ CASE WHEN ISNULL(A.dblFederalTax,0) > @maxAmount 
				THEN dbo.fnAPRemoveSpecialChars(CAST(@maxAmount - CAST(ISNULL(A.dblFederalTax,0) AS DECIMAL(18,2)) AS NVARCHAR(100))) 
					+ REPLICATE('0',12 - LEN(dbo.fnAPRemoveSpecialChars(CAST(@maxAmount - CAST(ISNULL(A.dblFederalTax,0) AS DECIMAL(18,2)) AS NVARCHAR(100)))))
				ELSE 
					dbo.fnAPRemoveSpecialChars(CAST(CAST(ISNULL(A.dblFederalTax,0) AS DECIMAL(18,2)) AS NVARCHAR(100)))
					+ REPLICATE('0',12 - LEN(dbo.fnAPRemoveSpecialChars(CAST(CAST(ISNULL(A.dblFederalTax,0) AS DECIMAL(18,2)) AS NVARCHAR(100)))))
			END
			+ CASE WHEN ISNULL(A.dblRedemption,0) > @maxAmount 
				THEN dbo.fnAPRemoveSpecialChars(CAST(@maxAmount - CAST(ISNULL(A.dblRedemption,0) AS DECIMAL(18,2)) AS NVARCHAR(100))) 
					+ REPLICATE('0',12 - LEN(dbo.fnAPRemoveSpecialChars(CAST(@maxAmount - CAST(ISNULL(A.dblRedemption,0) AS DECIMAL(18,2)) AS NVARCHAR(100)))))
				ELSE 
					dbo.fnAPRemoveSpecialChars(CAST(CAST(ISNULL(A.dblRedemption,0) AS DECIMAL(18,2)) AS NVARCHAR(100)))
					+ REPLICATE('0',12 - LEN(dbo.fnAPRemoveSpecialChars(CAST(CAST(ISNULL(A.dblRedemption,0) AS DECIMAL(18,2)) AS NVARCHAR(100)))))
			END
			+ CASE WHEN ISNULL(A.dblDomestic,0) > @maxAmount 
				THEN dbo.fnAPRemoveSpecialChars(CAST(@maxAmount - CAST(ISNULL(A.dblDomestic,0) AS DECIMAL(18,2)) AS NVARCHAR(100))) 
					+ REPLICATE('0',12 - LEN(dbo.fnAPRemoveSpecialChars(CAST(@maxAmount - CAST(ISNULL(A.dblDomestic,0) AS DECIMAL(18,2)) AS NVARCHAR(100)))))
				ELSE 
					dbo.fnAPRemoveSpecialChars(CAST(CAST(ISNULL(A.dblDomestic,0) AS DECIMAL(18,2)) AS NVARCHAR(100)))
					+ REPLICATE('0',12 - LEN(dbo.fnAPRemoveSpecialChars(CAST(CAST(ISNULL(A.dblDomestic,0) AS DECIMAL(18,2)) AS NVARCHAR(100)))))
			END
			+ CASE WHEN ISNULL(A.dblInvestment,0) > @maxAmount 
				THEN dbo.fnAPRemoveSpecialChars(CAST(@maxAmount - CAST(ISNULL(A.dblInvestment,0) AS DECIMAL(18,2)) AS NVARCHAR(100))) 
					+ REPLICATE('0',12 - LEN(dbo.fnAPRemoveSpecialChars(CAST(@maxAmount - CAST(ISNULL(A.dblInvestment,0) AS DECIMAL(18,2)) AS NVARCHAR(100)))))
				ELSE 
					dbo.fnAPRemoveSpecialChars(CAST(CAST(ISNULL(A.dblInvestment,0) AS DECIMAL(18,2)) AS NVARCHAR(100)))
					+ REPLICATE('0',12 - LEN(dbo.fnAPRemoveSpecialChars(CAST(CAST(ISNULL(A.dblInvestment,0) AS DECIMAL(18,2)) AS NVARCHAR(100)))))
			END
			+ CASE WHEN ISNULL(A.dblOpportunity,0) > @maxAmount 
				THEN dbo.fnAPRemoveSpecialChars(CAST(@maxAmount - CAST(ISNULL(A.dblOpportunity,0) AS DECIMAL(18,2)) AS NVARCHAR(100))) 
					+ REPLICATE('0',12 - LEN(dbo.fnAPRemoveSpecialChars(CAST(@maxAmount - CAST(ISNULL(A.dblOpportunity,0) AS DECIMAL(18,2)) AS NVARCHAR(100)))))
				ELSE 
					dbo.fnAPRemoveSpecialChars(CAST(CAST(ISNULL(A.dblOpportunity,0) AS DECIMAL(18,2)) AS NVARCHAR(100)))
					+ REPLICATE('0',12 - LEN(dbo.fnAPRemoveSpecialChars(CAST(CAST(ISNULL(A.dblOpportunity,0) AS DECIMAL(18,2)) AS NVARCHAR(100)))))
			END
			+ REPLICATE('0',12) --Payment Amount 9
			+ CASE WHEN ISNULL(A.dblAMT,0) > @maxAmount 
				THEN dbo.fnAPRemoveSpecialChars(CAST(@maxAmount - CAST(ISNULL(A.dblAMT,0) AS DECIMAL(18,2)) AS NVARCHAR(100))) 
					+ REPLICATE('0',12 - LEN(dbo.fnAPRemoveSpecialChars(CAST(@maxAmount - CAST(ISNULL(A.dblAMT,0) AS DECIMAL(18,2)) AS NVARCHAR(100)))))
				ELSE 
					dbo.fnAPRemoveSpecialChars(CAST(CAST(ISNULL(A.dblAMT,0) AS DECIMAL(18,2)) AS NVARCHAR(100)))
					+ REPLICATE('0',12 - LEN(dbo.fnAPRemoveSpecialChars(CAST(CAST(ISNULL(A.dblAMT,0) AS DECIMAL(18,2)) AS NVARCHAR(100)))))
			END
			+ CASE WHEN ISNULL(A.dblOther,0) > @maxAmount 
				THEN dbo.fnAPRemoveSpecialChars(CAST(@maxAmount - CAST(ISNULL(A.dblOther,0) AS DECIMAL(18,2)) AS NVARCHAR(100))) 
					+ REPLICATE('0',12 - LEN(dbo.fnAPRemoveSpecialChars(CAST(@maxAmount - CAST(ISNULL(A.dblOther,0) AS DECIMAL(18,2)) AS NVARCHAR(100)))))
				ELSE 
					dbo.fnAPRemoveSpecialChars(CAST(CAST(ISNULL(A.dblOther,0) AS DECIMAL(18,2)) AS NVARCHAR(100)))
					+ REPLICATE('0',12 - LEN(dbo.fnAPRemoveSpecialChars(CAST(CAST(ISNULL(A.dblOther,0) AS DECIMAL(18,2)) AS NVARCHAR(100)))))
			END
		+ ' '
		+ REPLICATE('0',12) --Section 409A deferals
		+ REPLICATE('0',12) --Section 409A income
		+ REPLICATE('0',12)
		+ REPLICATE('0',12) 
		END-- 235-246
		+ ' '
		+ A.strPayeeName + SPACE(40 - LEN(A.strPayeeName))
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
		+ ' ' 
		+ SPACE(1)
		+ SPACE(114)
		+ SPACE(60)
		+ SPACE(12)
		+ SPACE(12)
		+ SPACE(2)
		+ SPACE(2)
	FROM vyuAP1099PATR A
	OUTER APPLY 
	(
		SELECT TOP 1 * FROM tblAP1099History B
		WHERE A.intYear = B.intYear AND B.int1099Form = 4
		AND B.intEntityVendorId = A.intEntityVendorId
		ORDER BY B.dtmDatePrinted DESC
	) History
	WHERE 1 = (CASE WHEN @vendorFrom IS NOT NULL THEN
				(CASE WHEN A.strVendorId BETWEEN @vendorFrom AND @vendorTo THEN 1 ELSE 0 END)
			ELSE 1 END)
	AND A.intYear = @year
	AND 1 = (CASE WHEN History.ysnPrinted IS NOT NULL AND History.ysnPrinted = 1 AND @reprint = 1 THEN 1 
			WHEN History.ysnPrinted IS NULL THEN 1
			WHEN History.ysnPrinted IS NOT NULL AND History.ysnPrinted = 0 THEN 1
			ELSE 0 END)
	RETURN;
END