CREATE VIEW [dbo].[vyuICGetStorageCharge]
	AS

SELECT
	A.[intStorageChargeId]
	,A.[dtmBillDateUTC] 
	,A.[intStorageLocationId] 
	,A.[intCompanyLocationId]
	,A.[intCommodityId]
	,A.[intStorageRateId] 
	,A.[strStorageChargeNumber]
	,A.[intCurrencyId]
	,A.[strDescription]
	,A.[intConcurrencyId] 
	,A.ysnPosted
	,strStorageLocation = B.strSubLocationName
	,strCompanyLocation = C.strLocationName
	,strCommodity = D.strCommodityCode
	,strCurrency = E.strCurrency
	,strPlanNo = F.strPlanNo
FROM tblICStorageCharge A
LEFT JOIN tblSMCompanyLocationSubLocation B
	ON A.intStorageLocationId = B.intCompanyLocationSubLocationId
LEFT JOIN tblSMCompanyLocation C
	ON A.intCompanyLocationId = C.intCompanyLocationId
LEFT JOIN tblICCommodity D	
	ON A.intCommodityId = D.intCommodityId
LEFT JOIN tblSMCurrency E	
	ON A.intCurrencyId = E.intCurrencyID
LEFT JOIN tblICStorageRate F
	ON A.intStorageRateId = F.intStorageRateId
