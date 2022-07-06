CREATE VIEW [dbo].vyuICGetStorageRate
	AS

SELECT
	 A.[intStorageRateId] 
	,A.[dtmStartDateUTC]
	,A.[dtmEndDateUTC]
	,A.[intStorageLocationId] 
	,A.[intCompanyLocationId]
	,A.[intCommodityId]
	,A.[strPlanNo] 
	,A.[strDescription] 
	,A.[intConcurrencyId]
	,A.strChargePeriod 
 	,A.[ysnActive] 
	,A.[intItemId]
	,A.intVendorId
	,A.strChargeType
	,strStorageLocation = B.strSubLocationName
	,strCompanyLocation = C.strLocationName
	,strCommodity = D.strCommodityCode
	,strItemNo = E.strItemNo
	,strVendorName = F.strName
FROM tblICStorageRate A
LEFT JOIN tblSMCompanyLocationSubLocation B
	ON A.intStorageLocationId = B.intCompanyLocationSubLocationId
LEFT JOIN tblSMCompanyLocation C
	ON A.intCompanyLocationId = C.intCompanyLocationId
LEFT JOIN tblICCommodity D	
	ON A.intCommodityId = D.intCommodityId
LEFT JOIN tblICItem E	
	ON A.intItemId = E.intItemId
LEFT JOIN tblEMEntity F
	ON A.intVendorId = F.intEntityId