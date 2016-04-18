CREATE VIEW [dbo].[vyuGRGetStorageTransferTicket]  
AS  
SELECT TOP 100 PERCENT   
   a.intCustomerStorageId  
   ,a.strStorageTicketNumber  
  ,a.intEntityId  
 ,E.strName  
 ,a.intStorageTypeId  
 ,b.strStorageTypeDescription
,b.ysnCustomerStorage
,a.intStorageScheduleId
,SR.strScheduleId  
 ,a.intCommodityId  
 ,CM.strCommodityCode  
 ,CM.strDescription
,a.intItemId
,Item.strItemNo   
 ,a.intCompanyLocationId  
 ,c.strLocationName
,ISNULL(a.intCompanyLocationSubLocationId,0) intCompanyLocationSubLocationId
,ISNULL(Sub.strSubLocationName,'') strSubLocationName 
 ,a.dtmDeliveryDate  
 ,ISNULL(a.strDPARecieptNumber,'')strDPARecieptNumber  
 ,a.dblOpenBalance
,b.ysnDPOwnedType
,SH.intContractHeaderId
,CD.strContractNumber   
 ,ISNULL(SH1.intTicketId,0) AS intTicketId
FROM tblGRCustomerStorage a  
JOIN tblGRStorageType b ON b.intStorageScheduleTypeId = a.intStorageTypeId  
JOIN tblSMCompanyLocation c ON c.intCompanyLocationId = a.intCompanyLocationId  
JOIN tblEMEntity E ON E.intEntityId = a.intEntityId  
JOIN tblICCommodity CM ON CM.intCommodityId = a.intCommodityId
JOIN tblGRStorageScheduleRule SR ON SR.intStorageScheduleRuleId=a.intStorageScheduleId
JOIN tblICItem Item ON Item.intItemId = a.intItemId
LEFT JOIN tblSMCompanyLocationSubLocation Sub ON Sub.intCompanyLocationSubLocationId=a.intCompanyLocationSubLocationId
LEFT JOIN tblGRStorageHistory SH ON SH.intCustomerStorageId=a.intCustomerStorageId
LEFT JOIN tblGRStorageHistory SH1 ON SH1.intCustomerStorageId=a.intCustomerStorageId AND SH.strType='From Scale'
LEFT JOIN vyuCTContractDetailView CD ON CD.intContractHeaderId=SH.intContractHeaderId  
Where a.dblOpenBalance >0 AND ISNULL(a.strStorageType,'') <> 'ITR'AND SH.strType IN('From Scale','From Transfer')  
ORDER BY a.dtmDeliveryDate
