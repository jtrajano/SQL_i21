﻿CREATE VIEW [dbo].[vyuAP1099INTYear]
AS

SELECT DISTINCT
	 A.strVendorId
	, A.intYear
	, CASE WHEN SUM(A.dbl1099INT) >= MIN(C.dbl1099INT) THEN SUM(A.dbl1099INT) ELSE 0 END AS dbl1099INT
FROM vyuAP1099 A
CROSS JOIN tblSMCompanySetup B
CROSS JOIN tblAP1099Threshold C
WHERE A.int1099Form = 2
GROUP BY intYear, A.strVendorId
HAVING SUM(ISNULL(A.dbl1099INT,0)) > 0

GO