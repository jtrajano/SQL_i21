CREATE PROCEDURE [dbo].[uspAPCreate1099MISCFile]
	@year INT,
	@vendors NVARCHAR(MAX),
	@test BIT
AS

CREATE TABLE #tmpVendors (
	[intEntityVendorId] [int] PRIMARY KEY,
	UNIQUE (intEntityVendorId)
);

INSERT INTO #tmpVendors SELECT [intID] FROM [dbo].fnGetRowsFromDelimitedValues(@vendors)

SELECT 
'T' --1
+ CAST(A.intYear AS NVARCHAR(10))  --Position 2-5
+ CASE WHEN A.intYear = YEAR(GETDATE()) THEN ' ' ELSE 'P' END -- Position 6
+ ISNULL(NULLIF(A.strEIN,''),SPACE(9)) --Position 7-15 TIN
+ '12345' --Position 16-20 TCC
+ SPACE(7) -- 21-27Position 
+ CASE WHEN @test = 1 THEN 'T' ELSE ' ' END --Position 28
+ ' ' COLLATE Latin1_General_CI_AS --Position 29 Foreign Indicator
+ LEFT(A.strCompanyName, 40) --Position 30-69 First 40
+ SUBSTRING(A.strCompanyName, 41, LEN(A.strCompanyName)) + SPACE(40 - LEN(SUBSTRING(A.strCompanyName, 41,LEN(A.strCompanyName)))) --Position 70-109 Remaining 40 and spaces
+ LEFT(REPLACE(A.strCompanyName, CHAR(13) + CHAR(10), ' '), 40) + SPACE(40 - LEN(REPLACE(A.strCompanyName, CHAR(13) + CHAR(10), ' '))) --Position 110-149 First 40
+ SUBSTRING(REPLACE(A.strCompanyName, CHAR(13) + CHAR(10), ' '),41, LEN(REPLACE(A.strCompanyName, CHAR(13) + CHAR(10), ' '))) --Position 150-189 Remaining 40
+ LEFT(REPLACE(A.strAddress, CHAR(13) + CHAR(10), ' '), 40) + SPACE(40 - LEN(REPLACE(A.strAddress, CHAR(13) + CHAR(10), ' '))) --Position 190-229 Get 40 Char only
+ LEFT(REPLACE(A.strCity, CHAR(13) + CHAR(10), ' '), 40) + SPACE(40 - LEN(REPLACE(A.strCity, CHAR(13) + CHAR(10), ' '))) --Position 230-269 Get 40 Char only
+ dbo.fnTrim(A.strState)  --Position 270-271
+ dbo.fnTrim(A.strZip) --Position 272-280
+ SPACE(15) --Position 281-295
+ REPLICATE('0',8 - LEN(COUNT(*))) + CAST(COUNT(*) AS NVARCHAR(16)) --Position 296-303
AS MISC1099File
FROM vyuAP1099MISC A
CROSS JOIN tblSMCompanySetup B
WHERE A.intYear = A.intYear AND A.intEntityVendorId IN (SELECT intEntityVendorId FROM #tmpVendors)
GROUP BY A.intYear, A.strEIN, A.strCompanyName, A.strAddress, A.strCity, A.strState, A.strZip