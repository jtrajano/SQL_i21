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
		SELECT @amountCodes = COALESCE(@amountCodes,'') + strAmountCodes FROM (
			SELECT DISTINCT(strAmountCodes) strAmountCodes 
			FROM (
				SELECT 
					CASE WHEN A.dblDirectSales > 0 THEN '1' --ELSE '' END, --DIRECT SALES see page 53
							WHEN A.dblRents > 0 THEN '1' --ELSE '' END,
							WHEN A.dblRoyalties > 0 THEN '2' --ELSE '' END,
						WHEN A.dblOtherIncome > 0 THEN '3' --ELSE '' END,
						WHEN A.dblFederalIncome > 0 THEN '4' --ELSE '' END,
						WHEN A.dblBoatsProceeds > 0 THEN '5' --ELSE '' END,
						WHEN A.dblMedicalPayments > 0 THEN '6' --ELSE '' END,
						WHEN A.dblNonemployeeCompensation > 0 THEN '7' --ELSE '' END,
						WHEN A.dblSubstitutePayments > 0 THEN '8' --ELSE '' END,
						WHEN A.dblCropInsurance > 0 THEN 'A' --ELSE '' END,
						WHEN A.dblParachutePayments > 0 THEN 'B' --ELSE '' END,
						WHEN A.dblGrossProceedsAtty > 0 THEN 'C' 
					ELSE '' END AS strAmountCodes
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
				AND A.intYear = 2016
			) tmpAmountCodes
		) tblAmountCodes
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
		SET @amountCodes = ' ';
	END

	SELECT 
	@payer =
		'A'
		+ CAST(@year AS NVARCHAR(10))  --Position 2-5
		+ ' ' --CF/SF
		+ SPACE(5) -- 7-11
		+ ISNULL(NULLIF(LEFT(A.strEin,9),''), SPACE(9)) --Position 12-20 TIN
		+ SPACE(4) --21-24
		+ ' ' --25 Last Filing Indicator
		+ CASE @form1099 WHEN 1 THEN 'A ' --1099 MISC
			WHEN 2 THEN '6 ' --1099 INT
			WHEN 3 THEN 'B ' --1099 B
			WHEN 4 THEN '7 ' --1099 PATR
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
		+ SPACE(40)
		+ ' '
		+ LEFT(REPLACE(A.strAddress, CHAR(13) + CHAR(10), ' '), 40) + SPACE(40 - LEN(REPLACE(A.strAddress, CHAR(13) + CHAR(10), ' '))) --Position 134-173
		+ LEFT(REPLACE(A.strCity, CHAR(13) + CHAR(10), ' '), 40) + SPACE(40 - LEN(REPLACE(A.strCity, CHAR(13) + CHAR(10), ' '))) 
		+ SPACE(2 - LEN(ISNULL(dbo.fnTrimX(A.strState),''))) + dbo.fnTrimX(A.strState)  
		+ SPACE(9 - LEN(ISNULL(dbo.fnTrimX(A.strZip),'')))+  dbo.fnTrimX(A.strZip) 
		+ SPACE(15 - LEN(ISNULL(dbo.fnAPRemoveSpecialChars(A.strPhone),''))) + REPLACE(ISNULL(dbo.fnAPRemoveSpecialChars(A.strPhone),''), ' ','') --Position 225-239
		+ SPACE(260)
		+ '00000002' --500-507
		+ SPACE(241)
		+ CHAR(13) + CHAR(10)
	FROM tblSMCompanySetup A
	CROSS JOIN tblAP1099Threshold C

	RETURN @payer

END
