CREATE VIEW [dbo].[vyuICGetRetailValuation]
AS

SELECT	intCategoryId
		,intCategoryLocationId
		,intRegisterDepartmentId
		,strLocationName
		,strCategoryCode	
		,strCategoryDescription
		,dblBeginningRetail
		,dblReceipts
		,dblSales
		,dblMarkUpsDowns
		,dblWriteOffs
		,dblEndingRetail
		,dblGrossMarginPct
		,dblTargetGrossMarginPct
		,dblEndingCost
		,dtmDateFrom
		,dtmDateTo
		,dtmDate = dtmDateFrom
FROM 	tblICRetailValuation 
