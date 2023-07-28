--liquibase formatted sql

-- changeset Von:vyuICGetStorageRateDetail.sql.1 runOnChange:true splitStatements:false
-- comment: RK-1234

CREATE OR ALTER VIEW [dbo].[vyuICGetStorageRateDetail]
AS


SELECT
	A.[intStorageRateDetailId]
	,A.[intStorageRateId]
	,A.[dblNoOfDays]
	,A.[strRateType] COLLATE Latin1_General_CI_AS AS strRateType
	,A.[dblRate]
	,A.[intCommodityUnitMeasureId]
	,A.[intConcurrencyId]
	,C.strUnitMeasure
FROM tblICStorageRateDetail A
LEFT JOIN tblICCommodityUnitMeasure B
	ON A.intCommodityUnitMeasureId = B.intCommodityUnitMeasureId
LEFT JOIN tblICUnitMeasure C
	ON B.intUnitMeasureId = C.intUnitMeasureId



