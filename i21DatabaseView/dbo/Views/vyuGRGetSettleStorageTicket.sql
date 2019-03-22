CREATE VIEW [dbo].[vyuGRGetSettleStorageTicket]
AS  
SELECT 
 TOP 100 PERCENT   
 CS.intCustomerStorageId  
,CS.strStorageTicketNumber  
,CS.intEntityId  
,E.strName  
,CS.intStorageTypeId  
,ST.strStorageTypeDescription
,ST.ysnCustomerStorage
,CS.intStorageScheduleId
,SR.strScheduleId  
,CS.intItemId
,Item.strItemNo   
,CS.intCompanyLocationId  
,L.strLocationName
,CS.dtmDeliveryDate  
,dbo.fnCTConvertQuantityToTargetItemUOM(CS.intItemId,CS.intUnitMeasureId,CU.intUnitMeasureId,CS.dblOpenBalance)-ISNULL(SST.TotalUnits,0) AS dblOpenBalance   
,ST.ysnDPOwnedType
,SH.intContractHeaderId
,CH.strContractNumber   
,ISNULL(SH1.intTicketId,0) AS intTicketId
,ISNULL(dblDiscountsDue,0)-ISNULL(dblDiscountsPaid,0) AS dblDiscountUnPaid
,ISNULL(dblStorageDue,0)-ISNULL(dblStoragePaid,0) AS dblStorageUnPaid
FROM tblGRCustomerStorage CS  
JOIN tblGRStorageType ST ON ST.intStorageScheduleTypeId = CS.intStorageTypeId  
JOIN tblSMCompanyLocation L ON L.intCompanyLocationId = CS.intCompanyLocationId  
JOIN tblEMEntity E ON E.intEntityId = CS.intEntityId  
JOIN tblGRStorageScheduleRule SR ON SR.intStorageScheduleRuleId=CS.intStorageScheduleId
JOIN tblICItem Item ON Item.intItemId = CS.intItemId
JOIN tblICCommodityUnitMeasure CU ON CU.intCommodityId=CS.intCommodityId AND CU.ysnStockUnit=1
LEFT JOIN (SELECT intCustomerStorageId,SUM(dblUnits) TotalUnits FROM tblGRSettleStorageTicket WHERE dblUnits >0 GROUP BY intCustomerStorageId) SST ON SST.intCustomerStorageId=CS.intCustomerStorageId AND dbo.fnCTConvertQuantityToTargetItemUOM(CS.intItemId,CS.intUnitMeasureId,CU.intUnitMeasureId,CS.dblOpenBalance)-SST.TotalUnits >0
LEFT JOIN tblGRStorageHistory SH ON SH.intCustomerStorageId=CS.intCustomerStorageId
LEFT JOIN tblGRStorageHistory SH1 ON SH1.intCustomerStorageId=CS.intCustomerStorageId AND SH1.strType='From Scale'
LEFT JOIN tblCTContractHeader CH ON CH.intContractHeaderId=SH.intContractHeaderId  
WHERE ISNULL(CS.strStorageType,'') <> 'ITR'AND SH.strType IN('From Scale','From Transfer','From Delivery Sheet') 
ORDER BY CS.dtmDeliveryDate