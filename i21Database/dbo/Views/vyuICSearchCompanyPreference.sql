--Fixing to right view name vyuICGetCompanyPreference (do not use) to vyuICSearchCompanyPreference
CREATE VIEW [dbo].[vyuICSearchCompanyPreference]
AS
SELECT 
	ic.* 
	-- Get the company preference from the other modules that is related with IC. 
	,ysnImposeReversalTransaction = CAST(0 AS BIT) --rk.ysnImposeReversalTransaction
	,i.strItemNo
	,strEnableIntraCompanyTransfer = CASE WHEN ic.ysnEnableIntraCompanyTransfer = 1 THEN 'Yes' ELSE 'No' END 	
	,strOverrideCompanySegment = CASE WHEN ic.ysnOverrideCompanySegment = 1 OR ic.ysnOverrideCompanySegment IS NULL THEN 'Yes' ELSE 'No' END 
	,strOverrideLocationSegment = CASE WHEN ic.ysnOverrideLocationSegment = 1 OR ic.ysnOverrideLocationSegment IS NULL THEN 'Yes' ELSE 'No' END 
	,strOverrideLOBSegment = CASE WHEN ic.ysnOverrideLOBSegment = 1 THEN 'Yes' ELSE 'No' END 
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
	OUTER APPLY (
		SELECT	TOP 1 
				ysnEnable 
		FROM	tblSMStartingNumber 
		WHERE	intStartingNumberId = '185'
	) startingNumber
