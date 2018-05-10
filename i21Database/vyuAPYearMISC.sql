CREATE VIEW [dbo].[vyuAPYearMISC]
AS

WITH MISC1099 (
	
	intYear
)
AS
(
	SELECT DISTINCT
		 A.intYear
	FROM vyuAP1099 A
	WHERE A.int1099Form = 1
	
)

	SELECT
		*										
	FROM MISC1099 A
	GROUP BY 
		intYear
GO
