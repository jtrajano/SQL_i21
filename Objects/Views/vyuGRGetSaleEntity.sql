CREATE VIEW [dbo].[vyuGRGetSaleEntity]
AS   
SELECT DISTINCT   
 intCompanyLocationSubLocationId = CS.intCompanyLocationSubLocationId
,intItemId						 = CS.intItemId
,strSubLocationName				 = SLOC.strSubLocationName
,ysnCustomerStorage				 = ST.ysnCustomerStorage
,intCompanyLocationId			 = SLOC.intCompanyLocationId
,intEntityId					 = CS.intEntityId
,strEntityName					 = E.strName
FROM tblGRCustomerStorage CS
JOIN tblSMCompanyLocationSubLocation SLOC ON SLOC.intCompanyLocationSubLocationId=CS.intCompanyLocationSubLocationId
JOIN tblGRStorageType ST ON ST.intStorageScheduleTypeId=CS.intStorageTypeId
JOIN tblEMEntity E ON E.intEntityId = CS.intEntityId 
WHERE CS.dblOpenBalance >0 AND ISNULL(CS.strStorageType,'') <> 'ITR' AND ST.ysnCustomerStorage=1