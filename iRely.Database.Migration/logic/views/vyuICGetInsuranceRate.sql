--liquibase formatted sql

-- changeset Von:vyuICGetInsuranceRate.sql.1 runOnChange:true splitStatements:false
-- comment: RK-1234

CREATE OR ALTER VIEW [dbo].[vyuICGetInsuranceRate]
	AS


SELECT
	A.intInsuranceRateId
	,A.dtmStartDateUTC 
	,A.dtmEndDateUTC 
	,A.intInsurerId
	,A.strPolicyNumber
	,A.intItemId 
	,A.strDescription
	,A.intConcurrencyId
	,strChargeItemNo = C.strItemNo
	,strInsurerName = B.strName
FROM tblICInsuranceRate A
LEFT JOIN tblEMEntity B
	ON A.intInsurerId = B.intEntityId
LEFT JOIN tblICItem C
	ON A.intItemId = C.intItemId



