CREATE VIEW [dbo].[vyuICGetRetailValuation]
AS

SELECT	category.intCategoryId
		,categoryLocation.intCategoryLocationId
		,companyLocation.strLocationName
		,category.strCategoryCode	
		,strCategoryDescription = category.strDescription	
		,dblBeginningRetail			= CAST(0 AS NUMERIC(18, 6)) 
		,dblReceipts				= CAST(0 AS NUMERIC(18, 6))
		,dblSales					= CAST(0 AS NUMERIC(18, 6))
		,dblMarkUpsDowns			= CAST(0 AS NUMERIC(18, 6))
		,dblWriteOffs				= CAST(0 AS NUMERIC(18, 6))
		,dblEndingRetail			= CAST(0 AS NUMERIC(18, 6)) 
		,dblGrossMarginPct			= CAST(0 AS NUMERIC(18, 6)) 
		,dblTargetGrossMarginPct	= CAST(0 AS NUMERIC(18, 6)) 
		,dblEndingCost				= CAST(0 AS NUMERIC(18, 6)) 
		,dtmDateFrom = CAST(NULL AS DATETIME)
		,dtmDateTo = CAST(NULL AS DATETIME)
FROM 	tblICCategory category LEFT JOIN tblICCategoryLocation categoryLocation
			ON category.intCategoryId = categoryLocation.intCategoryId
		LEFT JOIN tblSMCompanyLocation companyLocation
			ON categoryLocation.intLocationId = companyLocation.intCompanyLocationId
WHERE	category.ysnRetailValuation = 1