CREATE PROCEDURE [dbo].[uspAPCreate1099MISCFile]
	@vendorFrom NVARCHAR(100) = NULL,
	@vendorTo NVARCHAR(100) = NULL,
	@year INT,
	@reprint BIT = 0,
	@corrected BIT = 0,
	@test BIT = 0
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF;

DECLARE @transmitter AS TABLE(strTransmitter NVARCHAR(1500))
DECLARE @payer AS TABLE(strPayer NVARCHAR(1500))
DECLARE @payee AS TABLE(strPayee NVARCHAR(MAX))
DECLARE @totalPayee NVARCHAR(16)

INSERT INTO @transmitter
SELECT dbo.[fnAP1099EFileTransmitter](@year,@test)

INSERT INTO @payer
SELECT dbo.[fnAP1099EFilePayer](@year, @test)

INSERT INTO @payee
SELECT * FROM dbo.fnAP1099EFileMISCPayee(@year, @reprint, @corrected, @vendorFrom, @vendorTo)

SET @totalPayee = REPLICATE('0', 8 - LEN(CAST((SELECT COUNT(*) FROM @payee) AS NVARCHAR(100)))) + CAST((SELECT COUNT(*) FROM @payee) AS NVARCHAR(100))

UPDATE A
	SET A.strTransmitter = STUFF(A.strTransmitter, 296, 8, @totalPayee)
FROM @transmitter A

SELECT * FROM @transmitter
UNION ALL
SELECT * FROM @payer
UNION ALL
SELECT * FROM @payee

--SELECT 
--	'T' --1
--	+ CAST(A.intYear AS NVARCHAR(10))  --Position 2-5
--	+ CASE WHEN A.intYear = YEAR(GETDATE()) THEN ' ' ELSE 'P' END -- Position 6
--	+ ISNULL(NULLIF(A.strEIN,''),SPACE(9)) --Position 7-15 TIN
--	+ '12345' --Position 16-20 TCC
--	+ SPACE(7) -- 21-27Position 
--	+ CASE WHEN @test = 1 THEN 'T' ELSE ' ' END --Position 28
--	+ ' ' COLLATE Latin1_General_CI_AS --Position 29 Foreign Indicator
--	+ LEFT(A.strCompanyName, 40) + SPACE(40 - LEN(A.strCompanyName)) --Position 30-69 First 40 (Transmitter name)
--	+ SUBSTRING(A.strCompanyName, 41, LEN(A.strCompanyName)) + SPACE(40 - LEN(SUBSTRING(A.strCompanyName, 41,LEN(A.strCompanyName)))) --Position 70-109 Remaining 40 and spaces
--	+ LEFT(REPLACE(A.strCompanyName, CHAR(13) + CHAR(10), ' '), 40) + SPACE(40 - LEN(REPLACE(A.strCompanyName, CHAR(13) + CHAR(10), ' '))) --Position 110-149 First 40
--	+ SUBSTRING(REPLACE(A.strCompanyName, CHAR(13) + CHAR(10), ' '),41, LEN(REPLACE(A.strCompanyName, CHAR(13) + CHAR(10), ' '))) --Position 150-189 Remaining 40
--	+ LEFT(REPLACE(A.strAddress, CHAR(13) + CHAR(10), ' '), 40) + SPACE(40 - LEN(REPLACE(A.strAddress, CHAR(13) + CHAR(10), ' '))) --Position 190-229 Get 40 Char only
--	+ LEFT(REPLACE(A.strCity, CHAR(13) + CHAR(10), ' '), 40) + SPACE(40 - LEN(REPLACE(A.strCity, CHAR(13) + CHAR(10), ' '))) --Position 230-269 Get 40 Char only
--	+ dbo.fnTrim(A.strState)  --Position 270-271
--	+ dbo.fnTrim(A.strZip) --Position 272-280
--	+ SPACE(15) --Position 281-295
--	+ REPLICATE('0',8 - LEN(TotalMISC.intTotal)) + CAST(TotalMISC.intTotal AS NVARCHAR(16)) --Position 296-303
--	+ dbo.fnTrim(C.strContactName) + SPACE(40 - LEN(dbo.fnTrim(C.strContactName))) --Position 304-343
--	+ REPLACE(dbo.fnAPRemoveSpecialChars(strContactPhone), ' ','') + SPACE(15 - LEN(REPLACE(dbo.fnAPRemoveSpecialChars(strContactPhone), ' ',''))) --Position 344-358
--	+ dbo.fnTrim(C.strContactEmail) + SPACE(50 - LEN(dbo.fnTrim(C.strContactEmail))) --Position 359-408
--	+ SPACE(91)
--	+ '00000001' --Position 500-507
--	+ SPACE(10)
--	+ 'V'
--	+ 'IRELY,LLC.' + SPACE(30)
--	+ '4242 FLAGSTAFF COVE' + SPACE(21)
--	+ 'FORT WAYNE' + SPACE(30)
--	+ 'IN'
--	+ '468154417'
--	+ 'GEORGE OLNEY' + SPACE(28)
--	+ '260486435700030'
--	+ SPACE(35)
--	+ SPACE(1)
--	+ CHAR(13) + CHAR(10)
--	AS T
--FROM vyuAP1099MISC A
--CROSS JOIN tblSMCompanySetup B
--CROSS JOIN tblAP1099Threshold C
--CROSS APPLY 
--(
--	SELECT
--		COUNT(*) as intTotal
--	FROM vyuAP1099MISC Total
--	OUTER APPLY 
--	(
--		SELECT TOP 1 * FROM tblAP1099History B
--		WHERE A.intYear = B.intYear AND B.int1099Form = 1
--		AND B.intEntityVendorId = A.intEntityVendorId
--		ORDER BY B.dtmDatePrinted DESC
--	) History
--	WHERE 1 = (CASE WHEN @vendorFrom IS NOT NULL THEN
--					(CASE WHEN A.strVendorId BETWEEN @vendorFrom AND @vendorTo THEN 1 ELSE 0 END)
--				ELSE 1 END)
--	AND A.intYear = @year
--	AND 1 = (CASE WHEN History.ysnPrinted IS NOT NULL AND History.ysnPrinted = 1 AND @reprint = 1 THEN 1 
--				WHEN History.ysnPrinted IS NULL THEN 1
--				WHEN History.ysnPrinted IS NOT NULL AND History.ysnPrinted = 0 THEN 1
--				ELSE 0 END)
--	--AND Total.dblRents > 0
--) TotalMISC
--OUTER APPLY 
--(
--	SELECT TOP 1 * FROM tblAP1099History B
--	WHERE A.intYear = B.intYear AND B.int1099Form = 1
--	AND B.intEntityVendorId = A.intEntityVendorId
--	ORDER BY B.dtmDatePrinted DESC
--) History
--WHERE 1 = (CASE WHEN @vendorFrom IS NOT NULL THEN
--				(CASE WHEN A.strVendorId BETWEEN @vendorFrom AND @vendorTo THEN 1 ELSE 0 END)
--			ELSE 1 END)
--AND A.intYear = @year
--AND 1 = (CASE WHEN History.ysnPrinted IS NOT NULL AND History.ysnPrinted = 1 AND @reprint = 1 THEN 1 
--			WHEN History.ysnPrinted IS NULL THEN 1
--			WHEN History.ysnPrinted IS NOT NULL AND History.ysnPrinted = 0 THEN 1
--			ELSE 0 END)
--AND A.dblRents > 0
