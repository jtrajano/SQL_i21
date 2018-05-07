CREATE VIEW [dbo].[vyuAPYearDIV]
AS

WITH DIV1099 (
	intYear
)
AS
(
	SELECT
	 A.intYear
																  
	FROM vyuAP1099 A
	CROSS JOIN tblSMCompanySetup B
	CROSS JOIN tblAP1099Threshold C
	WHERE A.int1099Form = 5
	
	)
	SELECT
		*
	FROM DIV1099 A
GO


