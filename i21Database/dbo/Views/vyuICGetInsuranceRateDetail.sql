CREATE VIEW [dbo].[vyuICGetInsuranceRateDetail]
AS



SELECT
	A.intInsuranceRateDetailId
	,A.intInsuranceRateId
	,A.intStorageLocationId
	,A.intCompanyLocationId
	,A.strRateType
	,A.strAppliedTo
	,A.dblRate 
	,A.intCurrencyId
	,A.intUnitMeasureId
	,A.intConcurrencyId
	,strUnitMeasure = B.strUnitMeasure
	,strStorageLocation = C.strSubLocationName
	,strCompanyLocation = D.strLocationName
	,strCurrency = E.strCurrency
FROM tblICInsuranceRateDetail A
LEFT JOIN tblICUnitMeasure B
	ON A.intUnitMeasureId = B.intUnitMeasureId
LEFT JOIN tblSMCompanyLocationSubLocation C
	ON A.intStorageLocationId = C.intCompanyLocationSubLocationId
LEFT JOIN tblSMCompanyLocation D
	ON A.intCompanyLocationId = D.intCompanyLocationId
LEFT JOIN tblSMCurrency E	
	ON A.intCurrencyId = E.intCurrencyID


