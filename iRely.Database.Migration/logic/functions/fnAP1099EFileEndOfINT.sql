--liquibase formatted sql

-- changeset Von:fnAP1099EFileEndOfINT.sql.1 runOnChange:true splitStatements:false
-- comment: RK-1234

CREATE OR ALTER FUNCTION [dbo].[fnAP1099EFileEndOfINT]
(
	@year INT,
	@reprint BIT = 0,
	@corrected BIT = 0,
	@vendorFrom NVARCHAR(100) = NULL,
	@vendorTo NVARCHAR(100) = NULL
)
RETURNS @returnTable TABLE
(
	intINT NVARCHAR(1500)
	,intCount INT
)
AS
BEGIN
	
	DECLARE @endOfINT NVARCHAR(1500);
	DECLARE @totalPayees NVARCHAR(16);
	DECLARE @controlTotal1 NVARCHAR(36), @controlTotal2 NVARCHAR(36), @controlTotal3 NVARCHAR(36),
			@controlTotal4 NVARCHAR(36),@controlTotal5 NVARCHAR(36),@controlTotal6 NVARCHAR(36),@controlTotal7 NVARCHAR(36),
			@controlTotal8 NVARCHAR(36),@controlTotal9 NVARCHAR(36);
	DECLARE @controlTotalA NVARCHAR(36), @controlTotalB NVARCHAR(36),@controlTotalC NVARCHAR(36),
			@controlTotalD NVARCHAR(36),@controlTotalE NVARCHAR(36),@controlTotalF NVARCHAR(36),@controlTotalG NVARCHAR(36);

	WITH INT1099 (
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
		,dbl1099INT
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
			,A.dbl1099INT
			,A.[intEntityId]
		FROM vyuAP1099INT A
		-- OUTER APPLY 
		-- (
		-- 	SELECT TOP 1 * FROM tblAP1099History B
		-- 	WHERE A.intYear = B.intYear AND B.int1099Form = 2
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
	)

	SELECT
		@totalPayees = (SELECT COUNT(*) FROM INT1099)		,
		@controlTotal1 =  REPLICATE('0',18 - LEN(REPLACE(CAST(CAST(SUM(ISNULL(A.dbl1099INT,0)) AS DECIMAL(18,2)) AS NVARCHAR(100)),'.','')))
						+ REPLACE(CAST(CAST(SUM(ISNULL(A.dbl1099INT,0)) AS DECIMAL(18,2)) AS NVARCHAR(100)),'.',''),
		@controlTotal2 = REPLICATE('0',18),
		@controlTotal3 = REPLICATE('0',18),
		@controlTotal4 = REPLICATE('0',12),
		@controlTotal5 = REPLICATE('0',0),
		@controlTotal6 = REPLICATE('0',0),
		@controlTotal7 = REPLICATE('0',0),
		@controlTotal8 = REPLICATE('0',0),
		@controlTotal9 = REPLICATE('0',0),
		@controlTotalA = REPLICATE('0',18),
		@controlTotalB = REPLICATE('0',18),
		@controlTotalC = REPLICATE('0',18),
		@controlTotalD = REPLICATE('0',18),
		@controlTotalE = REPLICATE('0',18),
		@controlTotalF = REPLICATE('0',18),
		@controlTotalG = REPLICATE('0',18)			
	FROM INT1099 A

	--PAGE 110
	SELECT
		@endOfINT = 'C'
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
	SELECT @endOfINT, @totalPayees

	RETURN;

END



