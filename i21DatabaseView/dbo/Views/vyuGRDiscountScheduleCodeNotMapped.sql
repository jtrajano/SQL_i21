CREATE VIEW [dbo].[vyuGRDiscountScheduleCodeNotMapped]
AS
SELECT
 Dcode.intDiscountScheduleCodeId
,Dcode.intStorageTypeId
,ST.strStorageTypeCode
,ST.strStorageTypeDescription
,Dcode.intCompanyLocationId
,LOC.strLocationName
,Dcode.intUnitMeasureId
,UOM.strUnitMeasure
,Dcode.intDiscountCalculationOptionId
,DCO.strDiscountCalculationOption
,Dcode.intShrinkCalculationOptionId
,SCO.strShrinkCalculationOption
,Dcode.intScalableItemId
,ScaleableItem.strItemNo AS strScaleableItemNo
FROM tblGRDiscountScheduleCode Dcode
LEFT JOIN tblICItem Item ON Item.intItemId=Dcode.intItemId
LEFT JOIN tblICItem ScaleableItem ON ScaleableItem.intItemId=Dcode.intScalableItemId
LEFT JOIN tblGRStorageType ST ON ST.intStorageScheduleTypeId=Dcode.intStorageTypeId
LEFT JOIN tblSMCompanyLocation LOC ON LOC.intCompanyLocationId = Dcode.intCompanyLocationId
LEFT JOIN tblICUnitMeasure UOM ON UOM.intUnitMeasureId = Dcode.intUnitMeasureId
LEFT JOIN tblGRDiscountCalculationOption DCO ON DCO.intDiscountCalculationOptionId = Dcode.intDiscountCalculationOptionId
LEFT JOIN tblGRShrinkCalculationOption SCO ON SCO.intShrinkCalculationOptionId = Dcode.intShrinkCalculationOptionId

