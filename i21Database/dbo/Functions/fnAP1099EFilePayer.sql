CREATE FUNCTION [dbo].[fnAP1099EFilePayer]
(
	@year INT,
	@form1099 INT,
	@vendorFrom NVARCHAR(100) = NULL,
	@vendorTo NVARCHAR(100) = NULL
)
RETURNS NVARCHAR(1500)
AS
BEGIN
	--See PAGE 44
	DECLARE @payer NVARCHAR(1400)
	DECLARE @amountCodes NVARCHAR(16)

	IF @form1099 = 1
	BEGIN
		-- SELECT @amountCodes = COALESCE(@amountCodes,'') + strAmountCodes 
		-- FROM (
			SELECT @amountCodes = strAmountCodes 
			FROM (
				SELECT 
					CASE WHEN SUM(A.dblDirectSales) > 0 THEN '1' --DIRECT SALES see page 53
					ELSE  
						CASE WHEN SUM(A.dblRents) > 0 THEN '1' ELSE '' END +
						CASE WHEN SUM(A.dblRoyalties) > 0 THEN '2' ELSE '' END +
						CASE WHEN SUM(A.dblOtherIncome) > 0 THEN '3' ELSE '' END +
						CASE WHEN SUM(A.dblFederalIncome) > 0 THEN '4' ELSE '' END +
						CASE WHEN SUM(A.dblBoatsProceeds) > 0 THEN '5' ELSE '' END + 
						CASE WHEN SUM(A.dblMedicalPayments) > 0 THEN '6' ELSE '' END + 
						CASE WHEN SUM(A.dblSubstitutePayments) > 0 THEN '8' ELSE '' END + 
						CASE WHEN SUM(A.dblCropInsurance) > 0 THEN 'A' ELSE '' END + 
						CASE WHEN SUM(A.dblParachutePayments) > 0 THEN 'B' ELSE '' END + 
						CASE WHEN SUM(A.dblGrossProceedsAtty) > 0 THEN 'C' ELSE '' END +
						CASE WHEN SUM(A.dblDeferrals) > 0 THEN 'D' ELSE '' END +
						CASE WHEN SUM(A.dblDeferredCompensation) > 0 THEN 'E' ELSE '' END +
						CASE WHEN @year < YEAR(GETDATE()) AND SUM(A.dblNonemployeeCompensation) > 0 THEN 'G' ELSE '' END
					END AS strAmountCodes
				FROM vyuAP1099MISC A
				--OUTER APPLY --Temporarily removed, identify when the voucher will exclude from generating 1099 file and report
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
			) tmpAmountCodes
		-- ) tblAmountCodes
	END
	ELSE IF @form1099 = 2
	BEGIN
		SET @amountCodes = '1 ';
	END
	ELSE IF @form1099 = 3
	BEGIN
		SET @amountCodes = '4 ';
	END
	ELSE IF @form1099 = 4
	BEGIN
		--SET @amountCodes = ' ';
		SELECT @amountCodes = COALESCE(@amountCodes,'') + strAmountCodes FROM (
			SELECT DISTINCT(strAmountCodes) strAmountCodes 
			FROM (
				SELECT 
					CASE WHEN A.dblDividends > 0 THEN '1' --PAGE 63
						WHEN A.dblNonpatronage > 0 THEN '2' --ELSE '' END,
						WHEN A.dblPerUnit > 0 THEN '3' --ELSE '' END,
						WHEN A.dblFederalTax > 0 THEN '4' --ELSE '' END,
						WHEN A.dblRedemption > 0 THEN '5' --ELSE '' END,
						WHEN A.dblDomestic > 0 THEN '6' --ELSE '' END,
						WHEN A.dblInvestment > 0 THEN '7' --ELSE '' END, INVESTMENT CREDITS???
						WHEN A.dblOpportunity > 0 THEN '8' --ELSE '' END,
						WHEN A.dblAMT > 0 THEN '9' --ELSE '' END,
						WHEN A.dblOther > 0 THEN 'A' --ELSE '' END,
					ELSE '' END AS strAmountCodes
				FROM vyuAP1099PATR A
				WHERE 1 = (CASE WHEN @vendorFrom IS NOT NULL THEN
							(CASE WHEN A.strVendorId BETWEEN @vendorFrom AND @vendorTo THEN 1 ELSE 0 END)
						ELSE 1 END)
				AND A.intYear = @year
			) tmpAmountCodes
		) tblAmountCodes
	END   
	ELSE IF @form1099 = 5 --DIV
	BEGIN
		SELECT @amountCodes = COALESCE(@amountCodes,'') + strAmountCodes FROM (
			SELECT DISTINCT(strAmountCodes) strAmountCodes 
			FROM (
				SELECT 
					CASE 
						WHEN A.dblOrdinaryDividends > 0 THEN '1' --PAGE 53
						WHEN A.dblQualified > 0 THEN '2' --ELSE '' END,
						WHEN A.dblCapitalGain > 0 THEN '3' --ELSE '' END,
						WHEN A.dblUnrecapGain > 0 THEN '6' --ELSE '' END,
						WHEN A.dblSection1202 > 0 THEN '7' --ELSE '' END,
						WHEN A.dblCollectibles > 0 THEN '8' --ELSE '' END,
						WHEN A.dblNonDividends > 0 THEN '9' --ELSE '' END, 
						WHEN A.dblFITW > 0 THEN 'A' --ELSE '' END,
						WHEN A.dblInvestment > 0 THEN 'B' --ELSE '' END,
						WHEN A.dblForeignTax > 0 THEN 'C' --ELSE '' END,
						WHEN A.dblCash > 0 THEN 'D' --ELSE '' END,
						WHEN A.dblNonCash > 0 THEN 'E' --ELSE '' END,
						WHEN A.dblExempt > 0 THEN 'F' --ELSE '' END,
						WHEN A.dblPrivate > 0 THEN 'G' --ELSE '' END,
					ELSE '' END AS strAmountCodes
				FROM dbo.vyuAP1099DIV A
				WHERE 1 = (CASE WHEN @vendorFrom IS NOT NULL THEN
							(CASE WHEN A.strVendorId BETWEEN @vendorFrom AND @vendorTo THEN 1 ELSE 0 END)
						ELSE 1 END)
				AND A.intYear = @year
			) tmpAmountCodes
		) tblAmountCodes
	END 
	ELSE IF @form1099 = 7 --NEC
	BEGIN
		SELECT @amountCodes = COALESCE(@amountCodes,'') + strAmountCodes 
		FROM (
			SELECT 
				CASE WHEN SUM(A.dblNonemployeeCompensationNEC) > 0 THEN '1' ELSE '' END +
				CASE WHEN SUM(A.dblFederalIncomeNEC) > 0 THEN '4' ELSE '' END AS strAmountCodes
			FROM dbo.vyuAP1099NEC A
			WHERE 1 = (CASE WHEN @vendorFrom IS NOT NULL THEN  
			(CASE WHEN A.strVendorId BETWEEN @vendorFrom AND @vendorTo THEN 1 ELSE 0 END)  
			ELSE 1 END)  
			AND A.intYear = @year  
		) tblAmountCodes  
	END
	ELSE IF @form1099 = 6
	BEGIN
		SELECT @amountCodes = COALESCE(@amountCodes,'') + strAmountCodes FROM (
			SELECT DISTINCT(strAmountCodes) strAmountCodes 
			FROM (
				SELECT 
					CASE 
						WHEN A.dblGrossThirdParty > 0 THEN '1' --PAGE 53
						WHEN A.dblCardNotPresent > 0 THEN '2' --ELSE '' END,
						WHEN A.dblFederalIncomeTax > 0 THEN '4' --ELSE '' END,
						WHEN A.dblJanuary > 0 THEN '5' --ELSE '' END,
						WHEN A.dblFebruary > 0 THEN '6' --ELSE '' END,
						WHEN A.dblMarch > 0 THEN '7' --ELSE '' END,
						WHEN A.dblApril > 0 THEN '8' --ELSE '' END, 
						WHEN A.dblMay > 0 THEN '9' --ELSE '' END,
						WHEN A.dblJune > 0 THEN 'A' --ELSE '' END,
						WHEN A.dblJuly > 0 THEN 'B' --ELSE '' END,
						WHEN A.dblAugust > 0 THEN 'C' --ELSE '' END,
						WHEN A.dblSeptember > 0 THEN 'D' --ELSE '' END,
						WHEN A.dblOctober > 0 THEN 'E' --ELSE '' END,
						WHEN A.dblNovember > 0 THEN 'F' --ELSE '' END,
						WHEN A.dblDecember > 0 THEN 'G' --ELSE '' END,
					ELSE '' END AS strAmountCodes
				FROM dbo.vyuAP1099K A
				WHERE 1 = (CASE WHEN @vendorFrom IS NOT NULL THEN
							(CASE WHEN A.strVendorId BETWEEN @vendorFrom AND @vendorTo THEN 1 ELSE 0 END)
						ELSE 1 END)
				AND A.intYear = @year
			) tmpAmountCodes
		) tblAmountCodes
	END

	SELECT 
	@payer =
		'A'
		+ CAST(@year AS NVARCHAR(10))  --Position 2-5
		+ ' ' --CF/SF
		+ SPACE(5) -- 7-11
		+ ISNULL(LEFT(REPLACE(A.strEin, '-', ''),9),SPACE(9)) --Position 12-20 TIN 00-0000000 Federal Tax Id format.
		+ SPACE(4) --21-24
		+ ' ' --25 Last Filing Indicator
		+ CASE @form1099 WHEN 1 THEN 'A ' --1099 MISC
			WHEN 2 THEN '6 ' --1099 INT
			WHEN 3 THEN 'B ' --1099 B
			WHEN 4 THEN '7 ' --1099 PATR
			WHEN 5 THEN '1 ' --1099 DIV
			WHEN 7 THEN 'NE' --1099 NEC
			WHEN 6 THEN 'MC' --1099 K
			ELSE SPACE(2) END --Type of return/1099 --Position 26-27
		+ @amountCodes + SPACE(16 - LEN(@amountCodes))
			--CASE @form1099 
			--WHEN 1 --1099 MISC
			--	THEN @amountCodes
			--WHEN 2 --1099 INT
			--	THEN SPACE(2)
			--WHEN 3 --1099 B
			--	THEN SPACE(2)
			--WHEN 4 --1099 PATR
			--	THEN SPACE(16)
			----SPACE(15) + '1' --Always use Amount Code '1' since we don't have monthly filing and Amount Code of Direct Sales is '1' SPACE(16) --28-43
			--ELSE SPACE(16) END
		+ SPACE(8) --44-51
		+ ' ' --Foreign Indicator
		+ SPACE(40 - LEN(A.strCompanyName)) + dbo.fnTrimX(A.strCompanyName) --Position 53-92
		+ CASE @form1099 WHEN 2 THEN SPACE(39) --1099 INT 
			WHEN 3 THEN SPACE(39) --1099 B
			ELSE SPACE(40) --1099 MISC/PATR/DIV
		END
		+ ' '
		+ LEFT(REPLACE(A.strAddress, CHAR(13) + CHAR(10), ' '), 40) + SPACE(40 - LEN(REPLACE(A.strAddress, CHAR(13) + CHAR(10), ' '))) --Position 134-173
		+ LEFT(REPLACE(A.strCity, CHAR(13) + CHAR(10), ' '), 40) + SPACE(40 - LEN(REPLACE(A.strCity, CHAR(13) + CHAR(10), ' '))) 
		+ SPACE(2 - LEN(ISNULL(dbo.fnTrimX(A.strState),''))) + dbo.fnTrimX(A.strState)  
		+ SPACE(9 - LEN(ISNULL(dbo.fnTrimX(A.strZip),''))) +  dbo.fnTrimX(A.strZip) 
		+ SPACE(15 - LEN(REPLACE(ISNULL(dbo.fnAPRemoveSpecialChars(A.strPhone),''), ' ',''))) + REPLACE(ISNULL(dbo.fnAPRemoveSpecialChars(A.strPhone),''), ' ','') --Position 225-239
		+ SPACE(260)
		+ '00000002' --500-507
		+ SPACE(241)
		+ CHAR(13) + CHAR(10)
	FROM tblSMCompanySetup A
	CROSS JOIN tblAP1099Threshold C

	RETURN @payer

END
