--liquibase formatted sql

-- changeset Von:vyuICGetRetailValuationByLocation.sql.1 runOnChange:true splitStatements:false
-- comment: RK-1234

CREATE OR ALTER VIEW [dbo].[vyuICGetRetailValuationByLocation]
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



