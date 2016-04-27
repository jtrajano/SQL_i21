CREATE VIEW [dbo].[vyuGRGetStorageLocation]  
AS  
SELECT Distinct
   Cs.intEntityId 
  ,Cs.intCompanyLocationId  
  ,Loc.strLocationName  
FROM tblGRCustomerStorage Cs
JOIN tblSMCompanyLocation Loc ON Loc.intCompanyLocationId =Cs.intCompanyLocationId
JOIN tblGRStorageType ST ON ST.intStorageScheduleTypeId=Cs.intStorageTypeId  
Where Cs.dblOpenBalance >0 AND ISNULL(Cs.strStorageType,'') <> 'ITR' AND ST.ysnCustomerStorage=0

