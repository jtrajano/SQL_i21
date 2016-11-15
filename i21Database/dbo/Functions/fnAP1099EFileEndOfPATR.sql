﻿CREATE FUNCTION [dbo].[fnAP1099EFileEndOfPATR]
(
	@year INT,
	@reprint BIT = 0,
	@corrected BIT = 0,
	@vendorFrom NVARCHAR(100) = NULL,
	@vendorTo NVARCHAR(100) = NULL
)
RETURNS NVARCHAR(1500)
AS
BEGIN
	
	DECLARE @endOfPATR NVARCHAR(1500);
	DECLARE @totalPayees NVARCHAR(16);
	DECLARE @controlTotal1 NVARCHAR(36), @controlTotal2 NVARCHAR(36), @controlTotal3 NVARCHAR(36),
			@controlTotal4 NVARCHAR(36),@controlTotal5 NVARCHAR(36),@controlTotal6 NVARCHAR(36),@controlTotal7 NVARCHAR(36),
			@controlTotal8 NVARCHAR(36),@controlTotal9 NVARCHAR(36);
	DECLARE @controlTotalA NVARCHAR(36), @controlTotalB NVARCHAR(36),@controlTotalC NVARCHAR(36),
			@controlTotalD NVARCHAR(36),@controlTotalE NVARCHAR(36),@controlTotalF NVARCHAR(36),@controlTotalG NVARCHAR(36);

	WITH PATR1099 (
		strEmployerAddress
		,strCompanyName
		,strEIN
		,strFederalTaxId
		,strAddress
		,strVendorCompanyName
		,strPayeeName
		,strVendorId
		,strZip
		,strCity
		,strState
		,strZipState
		,intYear
		,dblDividends
		,dblNonpatronage
		,dblPerUnit
		,dblFederalTax
		,dblRedemption
		,dblDomestic
		,dblInvestment
		,dblOpportunity
		,dblAMT
		,dblOther
		,intEntityVendorId
	)
	AS (
		SELECT
		 A.strEmployerAddress
		,A.strCompanyName
		,A.strEIN
		,A.strFederalTaxId
		,A.strAddress
		,A.strVendorCompanyName
		,A.strPayeeName
		,A.strVendorId
		,A.strZip
		,A.strCity
		,A.strState
		,A.strZipState
		,A.intYear
		,A.dblDividends
		,A.dblNonpatronage
		,A.dblPerUnit
		,A.dblFederalTax
		,A.dblRedemption
		,A.dblDomestic
		,A.dblInvestment
		,A.dblOpportunity
		,A.dblAMT
		,A.dblOther
		,A.intEntityVendorId
		FROM dbo.vyuAP1099PATR A
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
	)

	SELECT
		@totalPayees = (SELECT COUNT(*) FROM PATR1099)		,
		@controlTotal1 = REPLICATE('0',18 - LEN(dbo.fnAPRemoveSpecialChars(CAST(CAST(SUM(ISNULL(A.dblDividends,0)) AS DECIMAL(18,2)) AS NVARCHAR(100)))))
						+ dbo.fnAPRemoveSpecialChars(CAST(CAST(SUM(ISNULL(A.dblDividends,0)) AS DECIMAL(18,2)) AS NVARCHAR(100))),
		@controlTotal2 = REPLICATE('0',18 - LEN(dbo.fnAPRemoveSpecialChars(CAST(CAST(SUM(ISNULL(A.dblNonpatronage,0)) AS DECIMAL(18,2)) AS NVARCHAR(100)))))
						+ dbo.fnAPRemoveSpecialChars(CAST(CAST(SUM(ISNULL(A.dblNonpatronage,0)) AS DECIMAL(18,2)) AS NVARCHAR(100))),
		@controlTotal3 = REPLICATE('0',18 - LEN(dbo.fnAPRemoveSpecialChars(CAST(CAST(SUM(ISNULL(A.dblPerUnit,0)) AS DECIMAL(18,2)) AS NVARCHAR(100)))))
						+ dbo.fnAPRemoveSpecialChars(CAST(CAST(SUM(ISNULL(A.dblPerUnit,0)) AS DECIMAL(18,2)) AS NVARCHAR(100))),
		@controlTotal4 = REPLICATE('0',18 - LEN(dbo.fnAPRemoveSpecialChars(CAST(CAST(SUM(ISNULL(A.dblFederalTax,0)) AS DECIMAL(18,2)) AS NVARCHAR(100)))))
						+ dbo.fnAPRemoveSpecialChars(CAST(CAST(SUM(ISNULL(A.dblFederalTax,0)) AS DECIMAL(18,2)) AS NVARCHAR(100)))			,
		@controlTotal5 = REPLICATE('0',18 - LEN(dbo.fnAPRemoveSpecialChars(CAST(CAST(SUM(ISNULL(A.dblRedemption,0)) AS DECIMAL(18,2)) AS NVARCHAR(100)))))
						+ dbo.fnAPRemoveSpecialChars(CAST(CAST(SUM(ISNULL(A.dblRedemption,0)) AS DECIMAL(18,2)) AS NVARCHAR(100)))			,
		@controlTotal6 = REPLICATE('0',18 - LEN(dbo.fnAPRemoveSpecialChars(CAST(CAST(SUM(ISNULL(A.dblDomestic,0)) AS DECIMAL(18,2)) AS NVARCHAR(100)))))
						+ dbo.fnAPRemoveSpecialChars(CAST(CAST(SUM(ISNULL(A.dblDomestic,0)) AS DECIMAL(18,2)) AS NVARCHAR(100)))			,
		@controlTotal7 = REPLICATE('0',18 - LEN(dbo.fnAPRemoveSpecialChars(CAST(CAST(SUM(ISNULL(A.dblInvestment,0)) AS DECIMAL(18,2)) AS NVARCHAR(100)))))
						+ dbo.fnAPRemoveSpecialChars(CAST(CAST(SUM(ISNULL(A.dblInvestment,0)) AS DECIMAL(18,2)) AS NVARCHAR(100)))			,
		@controlTotal8 = REPLICATE('0',18 - LEN(dbo.fnAPRemoveSpecialChars(CAST(CAST(SUM(ISNULL(A.dblOpportunity,0)) AS DECIMAL(18,2)) AS NVARCHAR(100)))))
						+ dbo.fnAPRemoveSpecialChars(CAST(CAST(SUM(ISNULL(A.dblOpportunity,0)) AS DECIMAL(18,2)) AS NVARCHAR(100)))			,
		@controlTotal9 = REPLICATE('0',18)		,
		@controlTotalA = REPLICATE('0',18 - LEN(dbo.fnAPRemoveSpecialChars(CAST(CAST(SUM(ISNULL(A.dblAMT,0)) AS DECIMAL(18,2)) AS NVARCHAR(100)))))
						+ dbo.fnAPRemoveSpecialChars(CAST(CAST(SUM(ISNULL(A.dblAMT,0)) AS DECIMAL(18,2)) AS NVARCHAR(100)))			,	
		@controlTotalB = REPLICATE('0',18 - LEN(dbo.fnAPRemoveSpecialChars(CAST(CAST(SUM(ISNULL(A.dblOther,0)) AS DECIMAL(18,2)) AS NVARCHAR(100)))))
						+ dbo.fnAPRemoveSpecialChars(CAST(CAST(SUM(ISNULL(A.dblOther,0)) AS DECIMAL(18,2)) AS NVARCHAR(100)))			,
		@controlTotalC = REPLICATE('0',18)		,
		@controlTotalD = REPLICATE('0',18)		,
		@controlTotalE = REPLICATE('0',18)		,
		@controlTotalF = REPLICATE('0',18)		,
		@controlTotalG = REPLICATE('0',18)		
	FROM PATR1099 A

	--PAGE 110
	SELECT
		@endOfPATR = 'C'
		+ REPLICATE('0', 8 - LEN(CAST(COUNT(*) AS NVARCHAR(100)))) + CAST(COUNT(*) AS NVARCHAR(100))
		+ SPACE(6)
		+ @controlTotal1
		+ @controlTotal2
		+ @controlTotal3
		+ @controlTotal4
		+ @controlTotal5
		+ @controlTotal6
		+ @controlTotal7
		+ @controlTotal8
		+ @controlTotal9
		+ @controlTotalA
		+ @controlTotalB
		+ @controlTotalC
		+ @controlTotalD
		+ @controlTotalE
		+ @controlTotalF
		+ @controlTotalG
		+ SPACE(196)
		+ SPACE(8) --500-507
		+ SPACE(241)
		+ SPACE(2)

	RETURN @endOfPATR;

END