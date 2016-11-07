CREATE VIEW [dbo].[vyuGRDiscountScheduleCodeNotMapped]
AS
SELECT
 S.intDiscountScheduleCodeId
,S.intStorageTypeId
,ST.strStorageTypeCode
,ST.strStorageTypeDescription
,S.intCompanyLocationId
,L.strLocationName
FROM tblGRDiscountScheduleCode S
LEFT JOIN tblICItem Item ON Item.intItemId=S.intItemId
LEFT JOIN tblGRStorageType ST ON ST.intStorageScheduleTypeId=S.intStorageTypeId
LEFT JOIN tblSMCompanyLocation L ON L.intCompanyLocationId = S.intCompanyLocationId
