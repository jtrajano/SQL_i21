CREATE FUNCTION [dbo].[fnAP1099EFileTransmitter]
(
	@year INT,
	@test BIT = 0
)
RETURNS NVARCHAR(1500)
AS
BEGIN

	DECLARE @transmitter NVARCHAR(1400)

	SELECT 
	@transmitter = 
		'T' --1
		+ CAST(@year AS NVARCHAR(10))  --Position 2-5
		+ CASE WHEN @year = YEAR(GETDATE()) THEN ' ' ELSE 'P' END -- Position 6
		+ ISNULL(NULLIF(LEFT(A.strFederalTaxID,9),''),SPACE(9)) --Position 7-15 TIN
		+ '12345' --Position 16-20 TCC
		+ SPACE(7) -- 21-27Position 
		+ CASE WHEN @test = 1 THEN 'T' ELSE ' ' END --Position 28
		+ ' ' COLLATE Latin1_General_CI_AS --Position 29 Foreign Indicator
		+ LEFT(A.strCompanyName, 40) + SPACE(40 - LEN(A.strCompanyName)) --Position 30-69 First 40 (Transmitter name)
		+ SUBSTRING(A.strCompanyName, 41, LEN(A.strCompanyName)) + SPACE(40 - LEN(SUBSTRING(A.strCompanyName, 41,LEN(A.strCompanyName)))) --Position 70-109 Remaining 40 and spaces
		+ LEFT(REPLACE(A.strCompanyName, CHAR(13) + CHAR(10), ' '), 40) + SPACE(40 - LEN(REPLACE(A.strCompanyName, CHAR(13) + CHAR(10), ' '))) --Position 110-149 First 40
		+ SUBSTRING(REPLACE(A.strCompanyName, CHAR(13) + CHAR(10), ' '),41, LEN(REPLACE(A.strCompanyName, CHAR(13) + CHAR(10), ' '))) --Position 150-189 Remaining 40
		+ LEFT(REPLACE(A.strAddress, CHAR(13) + CHAR(10), ' '), 40) + SPACE(40 - LEN(REPLACE(A.strAddress, CHAR(13) + CHAR(10), ' '))) --Position 190-229 Get 40 Char only
		+ LEFT(REPLACE(A.strCity, CHAR(13) + CHAR(10), ' '), 40) + SPACE(40 - LEN(REPLACE(A.strCity, CHAR(13) + CHAR(10), ' '))) --Position 230-269 Get 40 Char only
		+ dbo.fnTrim(A.strState)  --Position 270-271
		+ dbo.fnTrim(A.strZip) --Position 272-280
		+ SPACE(15) --Position 281-295
		+ SPACE(8) --Position 296-303
		+ dbo.fnTrim(C.strContactName) + SPACE(40 - LEN(dbo.fnTrim(C.strContactName))) --Position 304-343
		+ REPLACE(dbo.fnAPRemoveSpecialChars(strContactPhone), ' ','') + SPACE(15 - LEN(REPLACE(dbo.fnAPRemoveSpecialChars(strContactPhone), ' ',''))) --Position 344-358
		+ dbo.fnTrim(C.strContactEmail) + SPACE(50 - LEN(dbo.fnTrim(C.strContactEmail))) --Position 359-408
		+ SPACE(91)
		+ '00000001' --Position 500-507
		+ SPACE(10)
		+ 'V'
		+ 'IRELY,LLC.' + SPACE(30)
		+ '4242 FLAGSTAFF COVE' + SPACE(21)
		+ 'FORT WAYNE' + SPACE(30)
		+ 'IN'
		+ '468154417'
		+ 'GEORGE OLNEY' + SPACE(28)
		+ '260486435700030'
		+ SPACE(35)
		+ SPACE(1)
		+ CHAR(13) + CHAR(10)
	FROM tblSMCompanySetup A
	CROSS JOIN tblAP1099Threshold C

	RETURN @transmitter;
END
