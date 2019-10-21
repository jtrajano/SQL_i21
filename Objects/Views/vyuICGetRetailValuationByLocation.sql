CREATE VIEW [dbo].[vyuICGetRetailValuationByLocation]
AS

SELECT	intCategoryId
		,intCategoryLocationId
		,intRegisterDepartmentId
		,v.strLocationName
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
        ,intLocationId
        , permission.intEntityId intUserId
        , permission.intUserRoleID intRoleId
FROM 	tblICRetailValuation v
    INNER JOIN vyuICUserCompanyLocations permission ON permission.intCompanyLocationId = v.intLocationId