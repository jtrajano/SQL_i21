CREATE VIEW [dbo].[vyuICGetInsuranceCharge]
	AS


SELECT
	A.intInsuranceChargeId
	,A.intCommodityId
	,A.intStorageLocationId 
	,A.intInsurerId
	,A.dtmChargeDateUTC
	,A.intM2MBatchId 
	,A.strChargeNo
	,A.intConcurrencyId
	,strCommodity = C.strCommodityCode
	,strInsurerName = B.strName
	,strStorageLocation = D.strSubLocationName
	,strM2MBatch = E.strRecordName
FROM tblICInsuranceCharge A
LEFT JOIN tblEMEntity B
	ON A.intInsurerId = B.intEntityId
LEFT JOIN tblICCommodity C
	ON A.intCommodityId = C.intCommodityId
LEFT JOIN tblSMCompanyLocationSubLocation D
	ON A.intStorageLocationId = D.intCompanyLocationSubLocationId
LEFT JOIN vyuRKGetM2MHeader E
	ON A.intM2MBatchId = E.intM2MHeaderId


