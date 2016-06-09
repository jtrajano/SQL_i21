CREATE VIEW [dbo].[vyuGRGetSettleSubLocations]
AS   
SELECT Distinct   
  Cs.intCompanyLocationSubLocationId
 ,Cs.intItemId
,Sub.strSubLocationName
,ST.ysnCustomerStorage
,Sub.intCompanyLocationId
FROM tblGRCustomerStorage Cs
JOIN tblSMCompanyLocationSubLocation Sub ON Sub.intCompanyLocationSubLocationId=Cs.intCompanyLocationSubLocationId
JOIN tblGRStorageType ST ON ST.intStorageScheduleTypeId=Cs.intStorageTypeId 
Where Cs.dblOpenBalance >0 AND ISNULL(Cs.strStorageType,'') <> 'ITR' AND ST.ysnCustomerStorage=1