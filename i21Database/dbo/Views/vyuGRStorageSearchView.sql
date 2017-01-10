CREATE VIEW [dbo].[vyuGRStorageSearchView]
AS    
SELECT TOP 100 PERCENT  
 CS.intCustomerStorageId
,CS.intEntityId
,E.strName  
,strStorageTicketNumber
,CS.intCompanyLocationId
,LOC.strLocationName
,CS.intStorageTypeId
,ST.strStorageTypeDescription  
,CS.dtmDeliveryDate
,CS.intItemId  
,Item.strItemNo  
,ISNULL(CS.strCustomerReference,'')strCustomerReference  
,dbo.fnCTConvertQuantityToTargetItemUOM(CS.intItemId,CS.intUnitMeasureId,CU.intUnitMeasureId,CS.dblOpenBalance) dblOpenBalance
,CS.dtmLastStorageAccrueDate
,CS.intStorageScheduleId
,SR.strScheduleId
,ISNULL(CS.dblDiscountsDue,0)-ISNULL(CS.dblDiscountsPaid,0) AS dblDiscountUnPaid
,ISNULL(CS.dblStorageDue,0)-ISNULL(CS.dblStoragePaid,0) AS dblStorageUnPaid
,SH.intContractHeaderId
,CD.strContractNumber 
FROM tblGRCustomerStorage CS  
JOIN tblSMCompanyLocation LOC ON LOC.intCompanyLocationId=CS.intCompanyLocationId  
LEFT JOIN tblGRStorageType ST ON ST.intStorageScheduleTypeId=CS.intStorageTypeId  
JOIN tblICItem Item on Item.intItemId=CS.intItemId
JOIN tblICCommodityUnitMeasure CU ON CU.intCommodityId=CS.intCommodityId AND CU.ysnStockUnit=1  
JOIN tblEMEntity E ON E.intEntityId = CS.intEntityId
JOIN tblGRStorageScheduleRule SR ON SR.intStorageScheduleRuleId=CS.intStorageScheduleId
LEFT JOIN tblGRStorageHistory SH ON SH.intCustomerStorageId=CS.intCustomerStorageId
LEFT JOIN vyuCTContractDetailView CD ON CD.intContractHeaderId=SH.intContractHeaderId  
Where ISNULL(CS.strStorageType,'') <> 'ITR' AND ST.ysnCustomerStorage=0 AND SH.strType IN('From Scale','From Transfer')
ORDER BY CS.intCustomerStorageId