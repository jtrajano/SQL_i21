CREATE VIEW [dbo].[vyuAP1099KYear]
AS

SELECT DISTINCT
	 A.strVendorId COLLATE Latin1_General_CI_AS AS strVendorId
	, A.intYear
	, SUM(A.dbl1099K) AS dbl1099B
FROM vyuAP1099 A
CROSS JOIN tblSMCompanySetup B
CROSS JOIN tblAP1099Threshold C
WHERE A.int1099Form = 6
GROUP BY intYear, A.strVendorId
HAVING SUM(ISNULL(A.dbl1099K,0)) > 0


GO
