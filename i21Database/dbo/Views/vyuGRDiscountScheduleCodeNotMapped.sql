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
FROM tblGRDiscountScheduleCode Dcode
LEFT JOIN tblICItem Item ON Item.intItemId=Dcode.intItemId
LEFT JOIN tblGRStorageType ST ON ST.intStorageScheduleTypeId=Dcode.intStorageTypeId
LEFT JOIN tblSMCompanyLocation LOC ON LOC.intCompanyLocationId = Dcode.intCompanyLocationId
LEFT JOIN tblICUnitMeasure UOM ON UOM.intUnitMeasureId = Dcode.intUnitMeasureId
