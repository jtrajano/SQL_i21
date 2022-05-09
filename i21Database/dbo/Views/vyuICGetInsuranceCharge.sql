CREATE VIEW [dbo].[vyuICGetInsuranceCharge]
	AS


SELECT
	A.intInsuranceChargeId
	,A.intCommodityId
	,A.strStorageLocationIds 
	,A.intInsurerId
	,A.dtmChargeDateUTC
	,A.dtmInvoiceDateUTC
	,A.dtmInvoiceDate
	,A.intM2MBatchId 
	,A.strChargeNo
	,A.ysnPosted
	,A.intConcurrencyId
	,strCommodity = C.strCommodityCode
	,strInsurerName = B.strName
	-- ,strStorageLocation = D.strSubLocationName
	,strM2MBatch = E.strRecordName
FROM tblICInsuranceCharge A
LEFT JOIN tblEMEntity B
	ON A.intInsurerId = B.intEntityId
LEFT JOIN tblICCommodity C
	ON A.intCommodityId = C.intCommodityId
-- OUTER APPLY (
-- 		SELECT strStorageLocations =	STUFF((SELECT 
-- 											',' + AA.strSubLocationName 
-- 										FROM tblSMCompanyLocationSubLocation AA
-- 										WHERE intCompanyLocationSubLocationId IN (
-- 																					SELECT											
-- 																						AAA.Item
-- 																					FROM dbo.fnSplitString (ISNULL(A.strStorageLocationIds,''),',') AAA
-- 																				)
-- 										FOR XML PATH('')
-- 										),1,1,'')
		
-- 		 		,strCompanyLocations =	STUFF((SELECT 
-- 											',' + BB.strLocationName
-- 										FROM tblSMCompanyLocationSubLocation AA
-- 										INNER JOIN tblSMCompanyLocation BB
-- 											ON AA.intCompanyLocationId = BB.intCompanyLocationId
-- 										WHERE intCompanyLocationSubLocationId IN (
-- 																					SELECT											
-- 																						AAA.Item
-- 																					FROM dbo.fnSplitString (ISNULL(A.strStorageLocationIds,''),',') AAA
-- 																				)
-- 										FOR XML PATH('')
-- 										),1,1,'')
-- ) D
LEFT JOIN vyuRKGetM2MHeader E
	ON A.intM2MBatchId = E.intM2MHeaderId


