CREATE VIEW [dbo].[vyuICSearchCompanyPreference]
--Fixing to right view name vyuICGetCompanyPreference(not use) to vyuICSearchCompanyPreference
AS

SELECT 
	ic.* 
	-- Get the company preference from the other modules that is related with IC. 
	,ysnImposeReversalTransaction = CAST(0 AS BIT) --rk.ysnImposeReversalTransaction
	,i.strItemNo
FROM 
	tblICCompanyPreference ic
	OUTER APPLY (
		SELECT TOP 1 
			rk.*
		FROM 
			tblRKCompanyPreference rk
	) rk 
	LEFT JOIN tblICItem i 
		ON i.intItemId = ic.intItemIdHolderForReceiptImport