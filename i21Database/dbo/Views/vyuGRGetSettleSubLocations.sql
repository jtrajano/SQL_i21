CREATE VIEW [dbo].[vyuGRGetSettleSubLocations]
AS   
SELECT DISTINCT   
 CS.intCompanyLocationSubLocationId
,CS.intItemId
,SLOC.strSubLocationName
,ST.ysnCustomerStorage
,SLOC.intCompanyLocationId
FROM tblGRCustomerStorage CS
JOIN tblSMCompanyLocationSubLocation SLOC ON SLOC.intCompanyLocationSubLocationId=CS.intCompanyLocationSubLocationId
JOIN tblGRStorageType ST ON ST.intStorageScheduleTypeId=CS.intStorageTypeId 
WHERE CS.dblOpenBalance >0 AND ISNULL(CS.strStorageType,'') <> 'ITR' AND ST.ysnCustomerStorage=1