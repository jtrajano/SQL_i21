CREATE VIEW [dbo].[vyuGRStorageStmtStorageType]
AS 
SELECT DISTINCT
	 CS.intEntityId    
	,CS.intItemId
	,ST.intStorageScheduleTypeId
	,ST.strStorageTypeCode
	,ST.strStorageTypeDescription 
FROM tblGRCustomerStorage CS
JOIN tblICItem Item 
	ON Item.intItemId = CS.intItemId
JOIN tblGRStorageType ST 
	ON ST.intStorageScheduleTypeId = CS.intStorageTypeId
LEFT JOIN tblGRStorageStatement SS 
	ON SS.intCustomerStorageId = CS.intCustomerStorageId
WHERE ST.ysnCustomerStorage = 0 
	AND CS.dblOpenBalance > 0
	AND SS.intCustomerStorageId IS NULL