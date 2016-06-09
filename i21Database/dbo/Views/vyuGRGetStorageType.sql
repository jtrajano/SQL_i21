CREATE VIEW [dbo].[vyuGRGetStorageType]
AS  
SELECT Distinct
   Cs.intEntityId
  ,Cs.intCompanyLocationId     
  ,Cs.intItemId  
 ,ST.intStorageScheduleTypeId
 ,ST.strStorageTypeCode
 ,ST.strStorageTypeDescription
FROM tblGRCustomerStorage Cs
JOIN tblGRStorageType ST ON ST.intStorageScheduleTypeId=Cs.intStorageTypeId 
Where Cs.dblOpenBalance >0 AND ISNULL(Cs.strStorageType,'') <> 'ITR' AND ST.ysnCustomerStorage=0