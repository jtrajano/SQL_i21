CREATE VIEW [dbo].[vyuICSearchStorageRateDetail]
AS


SELECT
	A.[intStorageRateDetailId]
	,A.[intStorageRateId]
	,A.[dblNoOfDays]
	,A.[strRateType]
	,A.[dblRate]
	,A.[intCommodityUnitMeasureId]
	,D.strUnitMeasure
	,strCompanyLocation = F.strLocationName
	,B.strPlanNo
	,H.strItemNo
	,B.dtmStartDateUTC
	,B.dtmEndDateUTC
	,strCommodity = G.strCommodityCode
	,strStorageLocation = E.strSubLocationName
	,B.ysnActive
	,A.intConcurrencyId
FROM tblICStorageRateDetail A
INNER JOIN tblICStorageRate B
	ON A.intStorageRateId = B.intStorageRateId
LEFT JOIN tblICCommodityUnitMeasure C
	ON A.intCommodityUnitMeasureId = C.intCommodityUnitMeasureId
LEFT JOIN tblICUnitMeasure D
	ON C.intUnitMeasureId = D.intUnitMeasureId
LEFT JOIN tblSMCompanyLocationSubLocation E
	ON B.intStorageLocationId = E.intCompanyLocationSubLocationId
LEFT JOIN tblSMCompanyLocation F
	ON B.intCompanyLocationId = F.intCompanyLocationId
LEFT JOIN tblICCommodity G	
	ON B.intCommodityId = G.intCommodityId
LEFT JOIN tblICItem H	
	ON B.intItemId = H.intItemId
