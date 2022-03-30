CREATE VIEW [dbo].[vyuICGetStorageRateDetail]
AS


SELECT
	A.[intStorageRateDetailId]
	,A.[intStorageRateId]
	,A.[dblNoOfDays]
	,A.[strRateType]
	,A.[dblRate]
	,A.[intCommodityUnitMeasureId]
	,A.[intConcurrencyId]
	,C.strUnitMeasure
FROM tblICStorageRateDetail A
LEFT JOIN tblICCommodityUnitMeasure B
	ON A.intCommodityUnitMeasureId = B.intCommodityUnitMeasureId
LEFT JOIN tblICUnitMeasure C
	ON B.intUnitMeasureId = C.intUnitMeasureId

