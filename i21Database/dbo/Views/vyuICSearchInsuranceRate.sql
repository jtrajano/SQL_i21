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
	,D.strRateType
	,D.strAppliedTo
	,D.dblRate
	,E.strUnitMeasure
	,H.strCurrency
	,strStorageLocation = F.strSubLocationName
	,strCompanyLocation = G.strLocationName
FROM tblICInsuranceRate A
INNER JOIN tblICInsuranceRateDetail D
	ON A.intInsuranceRateId = D.intInsuranceRateId
LEFT JOIN tblEMEntity B
	ON A.intInsurerId = B.intEntityId
LEFT JOIN tblICItem C
	ON A.intItemId = C.intItemId
LEFT JOIN tblICUnitMeasure E
	ON D.intUnitMeasureId = E.intUnitMeasureId
LEFT JOIN tblSMCompanyLocationSubLocation F
	ON D.intStorageLocationId = F.intCompanyLocationSubLocationId
LEFT JOIN tblSMCompanyLocation G
	ON D.intCompanyLocationId = G.intCompanyLocationId
LEFT JOIN tblSMCurrency H	
	ON D.intCurrencyId = H.intCurrencyID

