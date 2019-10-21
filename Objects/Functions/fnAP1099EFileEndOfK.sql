CREATE FUNCTION [dbo].[fnAP1099EFileEndOfK]
(
	@year INT,
	@reprint BIT = 0,
	@corrected BIT = 0,
	@vendorFrom NVARCHAR(100) = NULL,
	@vendorTo NVARCHAR(100) = NULL
)
RETURNS @returnTable TABLE
(
	C NVARCHAR(1500)
	,intCount INT
)
AS
BEGIN
	
	DECLARE @endOfMISC NVARCHAR(1500);
	DECLARE @totalPayees INT;
	DECLARE @controlTotal1 NVARCHAR(36), @controlTotal2 NVARCHAR(36), @controlTotal3 NVARCHAR(36),
			@controlTotal4 NVARCHAR(36),@controlTotal5 NVARCHAR(36),@controlTotal6 NVARCHAR(36),@controlTotal7 NVARCHAR(36),
			@controlTotal8 NVARCHAR(36),@controlTotal9 NVARCHAR(36);
	DECLARE @controlTotalA NVARCHAR(36), @controlTotalB NVARCHAR(36),@controlTotalC NVARCHAR(36),
			@controlTotalD NVARCHAR(36),@controlTotalE NVARCHAR(36),@controlTotalF NVARCHAR(36),@controlTotalG NVARCHAR(36);

	WITH K1099 (
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
		,dblGrossThirdParty
		,dblCardNotPresent
		,dblFederalIncomeTax
		,dblJanuary
		,dblFebruary
		,dblMarch
		,dblApril
		,dblMay
		,dblJune
		,dblJuly
		,dblAugust
		,dblSeptember
		,dblOctober
		,dblNovember
		,dblDecember
		,intEntityVendorId
		,dblTotalPayment
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
			,A.dblGrossThirdParty
			,A.dblCardNotPresent
			,A.dblFederalIncomeTax
			,A.dblJanuary
			,A.dblFebruary
			,A.dblMarch
			,A.dblApril
			,A.dblMay
			,A.dblJune
			,A.dblJuly
			,A.dblAugust
			,A.dblSeptember
			,A.dblOctober
			,A.dblNovember
			,A.dblDecember
			,A.intEntityVendorId
			,A.dblTotalPayment
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
	)
	--SAMPLE OUTPUT OF 100.00
	--PAGE 138
	--000000010000
	SELECT
		@totalPayees = (SELECT COUNT(*) FROM K1099)		,
		@controlTotal1 = REPLICATE('0',18 - LEN(REPLACE(CAST(CAST(SUM(ISNULL(A.dblGrossThirdParty,0)) AS DECIMAL(18,2)) AS NVARCHAR(100)),'.','')))
						+ REPLACE(CAST(CAST(SUM(ISNULL(A.dblGrossThirdParty,0)) AS DECIMAL(18,2)) AS NVARCHAR(100)),'.',''),
		@controlTotal2 = REPLICATE('0',18 - LEN(REPLACE(CAST(CAST(SUM(ISNULL(A.dblCardNotPresent,0)) AS DECIMAL(18,2)) AS NVARCHAR(100)),'.','')))
						+ REPLACE(CAST(CAST(SUM(ISNULL(A.dblCardNotPresent,0)) AS DECIMAL(18,2)) AS NVARCHAR(100)),'.',''),
		@controlTotal3 = REPLICATE('0',18 - LEN(REPLACE(CAST(CAST(SUM(ISNULL(A.dblFederalIncomeTax,0)) AS DECIMAL(18,2)) AS NVARCHAR(100)),'.','')))
						+ REPLACE(CAST(CAST(SUM(ISNULL(A.dblFederalIncomeTax,0)) AS DECIMAL(18,2)) AS NVARCHAR(100)),'.',''),
		@controlTotal4 = REPLICATE('0',18 - LEN(REPLACE(CAST(CAST(SUM(ISNULL(A.dblJanuary,0)) AS DECIMAL(18,2)) AS NVARCHAR(100)),'.','')))
						+ REPLACE(CAST(CAST(SUM(ISNULL(A.dblJanuary,0)) AS DECIMAL(18,2)) AS NVARCHAR(100)),'.','')			,
		@controlTotal5 = REPLICATE('0',18 - LEN(REPLACE(CAST(CAST(SUM(ISNULL(A.dblFebruary,0)) AS DECIMAL(18,2)) AS NVARCHAR(100)),'.','')))
						+ REPLACE(CAST(CAST(SUM(ISNULL(A.dblFebruary,0)) AS DECIMAL(18,2)) AS NVARCHAR(100)),'.','')			,
		@controlTotal6 = REPLICATE('0',18 - LEN(REPLACE(CAST(CAST(SUM(ISNULL(A.dblMarch,0)) AS DECIMAL(18,2)) AS NVARCHAR(100)),'.','')))
						+ REPLACE(CAST(CAST(SUM(ISNULL(A.dblMarch,0)) AS DECIMAL(18,2)) AS NVARCHAR(100)),'.','')			,
		@controlTotal7 = REPLICATE('0',18 - LEN(REPLACE(CAST(CAST(SUM(ISNULL(A.dblApril,0)) AS DECIMAL(18,2)) AS NVARCHAR(100)),'.','')))
						+ REPLACE(CAST(CAST(SUM(ISNULL(A.dblApril,0)) AS DECIMAL(18,2)) AS NVARCHAR(100)),'.','')			,
		@controlTotal8 = REPLICATE('0',18 - LEN(REPLACE(CAST(CAST(SUM(ISNULL(A.dblMay,0)) AS DECIMAL(18,2)) AS NVARCHAR(100)),'.','')))
						+ REPLACE(CAST(CAST(SUM(ISNULL(A.dblMay,0)) AS DECIMAL(18,2)) AS NVARCHAR(100)),'.','')			,
		@controlTotal9 = REPLICATE('0',18)		,
		@controlTotalA = REPLICATE('0',18 - LEN(REPLACE(CAST(CAST(SUM(ISNULL(A.dblJune,0)) AS DECIMAL(18,2)) AS NVARCHAR(100)),'.','')))
						+ REPLACE(CAST(CAST(SUM(ISNULL(A.dblJune,0)) AS DECIMAL(18,2)) AS NVARCHAR(100)),'.','')			,	
		@controlTotalB = REPLICATE('0',18 - LEN(REPLACE(CAST(CAST(SUM(ISNULL(A.dblJuly,0)) AS DECIMAL(18,2)) AS NVARCHAR(100)),'.','')))
						+ REPLACE(CAST(CAST(SUM(ISNULL(A.dblJuly,0)) AS DECIMAL(18,2)) AS NVARCHAR(100)),'.','')			,
		@controlTotalC = REPLICATE('0',18 - LEN(REPLACE(CAST(CAST(SUM(ISNULL(A.dblAugust,0)) AS DECIMAL(18,2)) AS NVARCHAR(100)),'.','')))
						+ REPLACE(CAST(CAST(SUM(ISNULL(A.dblAugust,0)) AS DECIMAL(18,2)) AS NVARCHAR(100)),'.','')			,
		@controlTotalD = REPLICATE('0',18 - LEN(REPLACE(CAST(CAST(SUM(ISNULL(A.dblSeptember,0)) AS DECIMAL(18,2)) AS NVARCHAR(100)),'.','')))
						+ REPLACE(CAST(CAST(SUM(ISNULL(A.dblSeptember,0)) AS DECIMAL(18,2)) AS NVARCHAR(100)),'.','')			,
		@controlTotalE = REPLICATE('0',18 - LEN(REPLACE(CAST(CAST(SUM(ISNULL(A.dblOctober,0)) AS DECIMAL(18,2)) AS NVARCHAR(100)),'.','')))
						+ REPLACE(CAST(CAST(SUM(ISNULL(A.dblOctober,0)) AS DECIMAL(18,2)) AS NVARCHAR(100)),'.','')			,
		@controlTotalF = REPLICATE('0',18 - LEN(REPLACE(CAST(CAST(SUM(ISNULL(A.dblNovember,0)) AS DECIMAL(18,2)) AS NVARCHAR(100)),'.','')))
						+ REPLACE(CAST(CAST(SUM(ISNULL(A.dblNovember,0)) AS DECIMAL(18,2)) AS NVARCHAR(100)),'.','')			,
		@controlTotalG = REPLICATE('0',18 - LEN(REPLACE(CAST(CAST(SUM(ISNULL(A.dblDecember,0)) AS DECIMAL(18,2)) AS NVARCHAR(100)),'.','')))
						+ REPLACE(CAST(CAST(SUM(ISNULL(A.dblDecember,0)) AS DECIMAL(18,2)) AS NVARCHAR(100)),'.','')			
	FROM K1099 A

	--PAGE 110
	SELECT
		@endOfMISC = 'C'
		+ REPLICATE('0', 8 - LEN(CAST(@totalPayees AS NVARCHAR(100)))) + CAST(@totalPayees AS NVARCHAR(100))
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
		+ REPLICATE('0', 8 - LEN(CAST(@totalPayees AS NVARCHAR(100)))) + CAST(@totalPayees + 3 AS NVARCHAR(100)) --500-507
		+ SPACE(241)
		+ CHAR(13) + CHAR(10)

	INSERT INTO @returnTable
	SELECT @endOfMISC, @totalPayees
	
	RETURN;

END
