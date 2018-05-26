﻿
CREATE VIEW [dbo].[vyuAPYearPATR]
AS

WITH PATR1099 (
	intYear,
	strVendorId
)
AS
(
	SELECT
	 A.intYear,
	 A.strVendorId
FROM vyuAP1099 A
CROSS JOIN tblSMCompanySetup B
CROSS JOIN tblAP1099Threshold C
WHERE A.int1099Form = 4
)
SELECT
	*
FROM PATR1099 A
GO


