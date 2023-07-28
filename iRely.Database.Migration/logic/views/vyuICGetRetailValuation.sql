--liquibase formatted sql

-- changeset Von:vyuICGetRetailValuation.sql.1 runOnChange:true splitStatements:false
-- comment: RK-1234

CREATE OR ALTER VIEW [dbo].[vyuICGetRetailValuation]
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
		,intLocationId
FROM 	tblICRetailValuation



