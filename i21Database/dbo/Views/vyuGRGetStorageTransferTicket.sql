CREATE VIEW [dbo].[vyuGRGetStorageTransferTicket]  
AS  
SELECT TOP 100 PERCENT   
   a.intCustomerStorageId  
   ,a.intStorageTicketNumber  
  ,a.intEntityId  
 ,E.strName  
 ,a.intStorageTypeId  
 ,b.strStorageTypeDescription  
 ,a.intCommodityId  
 ,CM.strCommodityCode  
 ,CM.strDescription   
 ,a.intCompanyLocationId  
 ,c.strLocationName  
 ,a.dtmDeliveryDate  
 ,ISNULL(a.strDPARecieptNumber,'')strDPARecieptNumber  
 ,a.dblOpenBalance   
FROM tblGRCustomerStorage a  
JOIN tblGRStorageType b ON b.intStorageScheduleTypeId = a.intStorageTypeId  
JOIN tblSMCompanyLocation c ON c.intCompanyLocationId = a.intCompanyLocationId  
JOIN tblEntity E ON E.intEntityId = a.intEntityId  
JOIN tblICCommodity CM ON CM.intCommodityId = a.intCommodityId  
Where a.dblOpenBalance >0   
ORDER BY 3,5