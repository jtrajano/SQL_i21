CREATE VIEW [dbo].[vyuAPYearMISC]
AS

WITH MISC1099 (
	
	intYear,
	strVendorId
)
AS
(
	SELECT DISTINCT
		 A.intYear
		 , A.strVendorId
	FROM vyuAP1099 A
	WHERE A.int1099Form = 1
	
)

	SELECT
		*										
	FROM MISC1099 A
	GROUP BY 
		intYear,
		strVendorId
GO
