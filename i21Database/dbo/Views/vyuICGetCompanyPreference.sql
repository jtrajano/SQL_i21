CREATE VIEW [dbo].[vyuICSearchCompanyPreference]
AS

SELECT 
	ic.* 
	-- Get the company preference from the other modules that is related with IC. 
	,rk.ysnImposeReversalTransaction
FROM 
	tblICCompanyPreference ic
	OUTER APPLY (
		SELECT TOP 1 
			rk.*
		FROM 
			tblRKCompanyPreference rk
	) rk 