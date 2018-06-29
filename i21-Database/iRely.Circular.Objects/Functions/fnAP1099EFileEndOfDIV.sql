CREATE FUNCTION [dbo].[fnAP1099EFileEndOfDIV]
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
	
	DECLARE @endOfDEV NVARCHAR(1500);
	DECLARE @totalPayees INT;
	DECLARE @controlTotal1 NVARCHAR(36), @controlTotal2 NVARCHAR(36), @controlTotal3 NVARCHAR(36),
			@controlTotal4 NVARCHAR(36),@controlTotal5 NVARCHAR(36),@controlTotal6 NVARCHAR(36),@controlTotal7 NVARCHAR(36),
			@controlTotal8 NVARCHAR(36),@controlTotal9 NVARCHAR(36);
	DECLARE @controlTotalA NVARCHAR(36), @controlTotalB NVARCHAR(36),@controlTotalC NVARCHAR(36),
			@controlTotalD NVARCHAR(36),@controlTotalE NVARCHAR(36),@controlTotalF NVARCHAR(36),@controlTotalG NVARCHAR(36);

	WITH DEV1099 (
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
			,dblOrdinaryDividends
			,dblQualified
			,dblCapitalGain 
			,dblUnrecapGain 
			,dblSection1202 
			,dblCollectibles 
			,dblNonDividends 
			,dblFITW  
			,dblInvestment 
			,dblForeignTax 
			,dblCash 
			,dblNonCash 
			,dblExempt 
			,dblPrivate 
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
			,A.dblOrdinaryDividends
			,A.dblQualified
			,A.dblCapitalGain 
			,A.dblUnrecapGain 
			,A.dblSection1202 
			,A.dblCollectibles 
			,A.dblNonDividends 
			,A.dblFITW  
			,A.dblInvestment 
			,A.dblForeignTax 
			,A.dblCash 
			,A.dblNonCash 
			,A.dblExempt 
			,A.dblPrivate 
			,A.dblTotalPayment
		FROM dbo.vyuAP1099DIV A
		WHERE 1 = (CASE WHEN @vendorFrom IS NOT NULL THEN
					(CASE WHEN A.strVendorId BETWEEN @vendorFrom AND @vendorTo THEN 1 ELSE 0 END)
				ELSE 1 END)
		AND A.intYear = @year
	)
	--SAMPLE OUTPUT OF 100.00
	--000000010000
	SELECT
		@totalPayees = (SELECT COUNT(*) FROM DEV1099),
		@controlTotal1 = REPLICATE('0',18 - LEN(REPLACE(CAST(CAST(SUM(ISNULL(A.dblOrdinaryDividends,0)) AS DECIMAL(18,2)) AS NVARCHAR(100)),'.','')))
						+ REPLACE(CAST(CAST(SUM(ISNULL(A.dblOrdinaryDividends,0)) AS DECIMAL(18,2)) AS NVARCHAR(100)),'.',''),
		
		@controlTotal2 = REPLICATE('0',18 - LEN(REPLACE(CAST(CAST(SUM(ISNULL(A.dblQualified,0)) AS DECIMAL(18,2)) AS NVARCHAR(100)),'.','')))
						+ REPLACE(CAST(CAST(SUM(ISNULL(A.dblQualified,0)) AS DECIMAL(18,2)) AS NVARCHAR(100)),'.',''),
		
		@controlTotal3 = REPLICATE('0',18 - LEN(REPLACE(CAST(CAST(SUM(ISNULL(A.dblCapitalGain,0)) AS DECIMAL(18,2)) AS NVARCHAR(100)),'.','')))
						+ REPLACE(CAST(CAST(SUM(ISNULL(A.dblCapitalGain,0)) AS DECIMAL(18,2)) AS NVARCHAR(100)),'.',''),
		
		@controlTotal4 = REPLICATE('0',18 - LEN(REPLACE(CAST(CAST(SUM(ISNULL(A.dblUnrecapGain,0)) AS DECIMAL(18,2)) AS NVARCHAR(100)),'.','')))
						+ REPLACE(CAST(CAST(SUM(ISNULL(A.dblUnrecapGain,0)) AS DECIMAL(18,2)) AS NVARCHAR(100)),'.',''),
		
		@controlTotal5 = REPLICATE('0',18 - LEN(REPLACE(CAST(CAST(SUM(ISNULL(A.dblSection1202,0)) AS DECIMAL(18,2)) AS NVARCHAR(100)),'.','')))
						+ REPLACE(CAST(CAST(SUM(ISNULL(A.dblSection1202,0)) AS DECIMAL(18,2)) AS NVARCHAR(100)),'.',''),
		
		@controlTotal6 = REPLICATE('0',18 - LEN(REPLACE(CAST(CAST(SUM(ISNULL(A.dblCollectibles,0)) AS DECIMAL(18,2)) AS NVARCHAR(100)),'.','')))
						+ REPLACE(CAST(CAST(SUM(ISNULL(A.dblCollectibles,0)) AS DECIMAL(18,2)) AS NVARCHAR(100)),'.',''),
		
		@controlTotal7 = REPLICATE('0',18 - LEN(REPLACE(CAST(CAST(SUM(ISNULL(A.dblNonDividends,0)) AS DECIMAL(18,2)) AS NVARCHAR(100)),'.','')))
						+ REPLACE(CAST(CAST(SUM(ISNULL(A.dblNonDividends,0)) AS DECIMAL(18,2)) AS NVARCHAR(100)),'.',''),
		
		@controlTotal8 = REPLICATE('0',18 - LEN(REPLACE(CAST(CAST(SUM(ISNULL(A.dblFITW,0)) AS DECIMAL(18,2)) AS NVARCHAR(100)),'.','')))
						+ REPLACE(CAST(CAST(SUM(ISNULL(A.dblFITW,0)) AS DECIMAL(18,2)) AS NVARCHAR(100)),'.',''),
		
		@controlTotal9 =  REPLICATE('0',18 - LEN(REPLACE(CAST(CAST(SUM(ISNULL(A.dblInvestment,0)) AS DECIMAL(18,2)) AS NVARCHAR(100)),'.','')))
						+ REPLACE(CAST(CAST(SUM(ISNULL(A.dblInvestment,0)) AS DECIMAL(18,2)) AS NVARCHAR(100)),'.','') ,
		
		@controlTotalA = REPLICATE('0',18 - LEN(REPLACE(CAST(CAST(SUM(ISNULL(A.dblForeignTax,0)) AS DECIMAL(18,2)) AS NVARCHAR(100)),'.','')))
						+ REPLACE(CAST(CAST(SUM(ISNULL(A.dblForeignTax,0)) AS DECIMAL(18,2)) AS NVARCHAR(100)),'.',''),	
		
		@controlTotalB = REPLICATE('0',18 - LEN(REPLACE(CAST(CAST(SUM(ISNULL(A.dblCash,0)) AS DECIMAL(18,2)) AS NVARCHAR(100)),'.','')))
						+ REPLACE(CAST(CAST(SUM(ISNULL(A.dblCash,0)) AS DECIMAL(18,2)) AS NVARCHAR(100)),'.',''),
		
		@controlTotalC = REPLICATE('0',18 - LEN(REPLACE(CAST(CAST(SUM(ISNULL(A.dblNonCash,0)) AS DECIMAL(18,2)) AS NVARCHAR(100)),'.','')))
						+ REPLACE(CAST(CAST(SUM(ISNULL(A.dblNonCash,0)) AS DECIMAL(18,2)) AS NVARCHAR(100)),'.',''),
		
		@controlTotalD = REPLICATE('0',18 - LEN(REPLACE(CAST(CAST(SUM(ISNULL(A.dblExempt,0)) AS DECIMAL(18,2)) AS NVARCHAR(100)),'.','')))
						+ REPLACE(CAST(CAST(SUM(ISNULL(A.dblExempt,0)) AS DECIMAL(18,2)) AS NVARCHAR(100)),'.',''),
		
		@controlTotalE = REPLICATE('0',18 - LEN(REPLACE(CAST(CAST(SUM(ISNULL(A.dblNonCash,0)) AS DECIMAL(18,2)) AS NVARCHAR(100)),'.','')))
						+ REPLACE(CAST(CAST(SUM(ISNULL(A.dblNonCash,0)) AS DECIMAL(18,2)) AS NVARCHAR(100)),'.',''),
		@controlTotalF = REPLICATE('0',18)		,
		@controlTotalG = REPLICATE('0',18)		
	FROM DEV1099 A

	--PAGE 110
	SELECT
		@endOfDEV = 'C'
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
		+ SPACE(8) --500-507
		+ SPACE(241)
		+ CHAR(13) + CHAR(10)

	RETURN @endOfDEV;

END