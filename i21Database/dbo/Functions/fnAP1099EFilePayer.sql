CREATE FUNCTION [dbo].[fnAP1099EFilePayer]
(
	@year INT,
	@form1099 INT
)
RETURNS NVARCHAR(1500)
AS
BEGIN
	--See PAGE 44
	DECLARE @payer NVARCHAR(1400)

	SELECT 
	@payer =
		'A'
		+ CAST(2015 AS NVARCHAR(10))  --Position 2-5
		+ ' ' --CF/SF
		+ SPACE(5) -- 7-11
		+ ISNULL(NULLIF(LEFT(A.strFederalTaxID,9),''), SPACE(9)) --Position 12-20 TIN
		+ SPACE(4) --21-24
		+ ' ' --25 Last Filing Indicator
		+ CASE 1 WHEN 1 THEN 'A ' --1099 MISC
			ELSE SPACE(2) END --Type of return/1099 --Position 26-27
		+ CASE 1 WHEN 1 THEN SPACE(15) + '1' --Always use Amount Code '1' since we don't have monthly filing and Amount Code of Direct Sales is '1' SPACE(16) --28-43
			ELSE SPACE(16) END
		+ SPACE(8) --44-51
		+ ' ' --Foreign Indicator
		+ SPACE(40 - LEN(A.strCompanyName)) + dbo.fnTrim(A.strCompanyName) --Position 53-92
		+ SPACE(40)
		+ ' '
		+ LEFT(REPLACE(A.strAddress, CHAR(13) + CHAR(10), ' '), 40) + SPACE(40 - LEN(REPLACE(A.strAddress, CHAR(13) + CHAR(10), ' '))) --Position 134-173
		+ LEFT(REPLACE(A.strCity, CHAR(13) + CHAR(10), ' '), 40) + SPACE(40 - LEN(REPLACE(A.strCity, CHAR(13) + CHAR(10), ' '))) 
		+ SPACE(2 - LEN(ISNULL(dbo.fnTrim(A.strState),''))) + dbo.fnTrim(A.strState)  
		+ SPACE(9 - LEN(ISNULL(dbo.fnTrim(A.strZip),'')))+  dbo.fnTrim(A.strZip) 
		+ SPACE(15 - LEN(ISNULL(dbo.fnAPRemoveSpecialChars(A.strPhone),''))) + REPLACE(ISNULL(dbo.fnAPRemoveSpecialChars(A.strPhone),''), ' ','') --Position 225-239
		+ SPACE(260)
		+ '00000002' --500-507
		+ SPACE(241)
		+ CHAR(13) + CHAR(10)
	FROM tblSMCompanySetup A
	CROSS JOIN tblAP1099Threshold C

	RETURN @payer

END
