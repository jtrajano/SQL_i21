﻿
CREATE VIEW [dbo].[vyuAPYearINT]
AS

	SELECT
		 A.intYear
	FROM vyuAP1099 A
	CROSS JOIN tblSMCompanySetup B
	CROSS JOIN tblAP1099Threshold C
	WHERE A.int1099Form = 2

GO


