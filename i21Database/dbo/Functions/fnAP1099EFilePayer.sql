CREATE FUNCTION [dbo].[fnAP1099EFilePayer]
(
	@year INT
)
RETURNS NVARCHAR(1500)
AS
BEGIN
	DECLARE @payer NVARCHAR(1400)

	SELECT 
	@payer =
		'A'
		+ CAST(@year AS NVARCHAR(10))  --Position 2-5
		+ ' ' --CF/SF
		+ SPACE(5) -- 7-11
		+ ISNULL(NULLIF(LEFT(A.strFederalTaxID,9),''), SPACE(9)) --Position 12-20 TIN
		+ SPACE(4) --21-24
		+ ' ' --25
		+ 'A ' --Type of return/1099 --Position 26-27
		+ SPACE(16) --28-43
		+ SPACE(8) --44-51
		+ ' '
		+ LEFT(A.strCompanyName, 40) + SPACE(40 - LEN(A.strCompanyName)) --Position 53-92
		+ SPACE(40)
		+ ' '
		+ LEFT(REPLACE(A.strAddress, CHAR(13) + CHAR(10), ' '), 40) + SPACE(40 - LEN(REPLACE(A.strAddress, CHAR(13) + CHAR(10), ' '))) --Position 134-173
		+ LEFT(REPLACE(A.strCity, CHAR(13) + CHAR(10), ' '), 40) + SPACE(40 - LEN(REPLACE(A.strCity, CHAR(13) + CHAR(10), ' '))) 
		+ dbo.fnTrim(A.strState)  
		+ dbo.fnTrim(A.strZip) 
		+ REPLACE(ISNULL(dbo.fnAPRemoveSpecialChars(A.strPhone),''), ' ','') --Position 225-239
		+ SPACE(260)
		+ '00000002' --500-507
		+ SPACE(241)
		+ CHAR(13) + CHAR(10)
	FROM tblSMCompanySetup A
	CROSS JOIN tblAP1099Threshold C

	RETURN @payer

END
