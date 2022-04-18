CREATE VIEW [dbo].[vyuICSearchInsuranceRate]
	AS


SELECT
	A.intInsuranceRateId
	,A.dtmStartDateUTC 
	,A.dtmEndDateUTC 
	,A.intInsurerId
	,A.strPolicyNumber
	,A.intItemId 
	,strInsurerName = B.strName
	,A.[strDescription]
	,A.intConcurrencyId
	,strChargeItemNo = C.strItemNo
FROM tblICInsuranceRate A
LEFT JOIN tblEMEntity B
	ON A.intInsurerId = B.intEntityId
LEFT JOIN tblICItem C
	ON A.intItemId = C.intItemId


