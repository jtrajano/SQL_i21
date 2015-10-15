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
'T'
+ CAST(A.intYear AS NVARCHAR(10)) 
+ CASE WHEN A.intYear = YEAR(GETDATE()) THEN ' ' ELSE 'P' END
+ ISNULL(NULLIF(A.strEIN,''),SPACE(9)) --TIN
+ '12345' --TCC
+ '       '
+ CASE WHEN 1 = 1 THEN 'T' ELSE ' ' END
+ ' ' COLLATE Latin1_General_CI_AS --Foreign
+ LEFT(A.strCompanyName, 40) --First 40
+ SUBSTRING(A.strCompanyName, 41, LEN(A.strCompanyName)) + SPACE(40 - LEN(SUBSTRING(A.strCompanyName, 41,LEN(A.strCompanyName)))) --Remaining 40 and spaces
+ LEFT(REPLACE(A.strEmployerAddress, CHAR(13) + CHAR(10), ' '), 40) + SPACE(40 - LEN(REPLACE(A.strEmployerAddress, CHAR(13) + CHAR(10), ' '))) --First 40
+ SUBSTRING(REPLACE(A.strEmployerAddress, CHAR(13) + CHAR(10), ' '),41, LEN(REPLACE(A.strEmployerAddress, CHAR(13) + CHAR(10), ' '))) --Remaining 40
AS T
FROM vyuAP1099MISC A
CROSS JOIN tblSMCompanySetup B