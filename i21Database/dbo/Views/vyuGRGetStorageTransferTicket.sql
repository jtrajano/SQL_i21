CREATE VIEW [dbo].[vyuGRGetStorageTransferTicket]  
AS  
SELECT TOP 100 PERCENT   
    CS.intCustomerStorageId  
    ,CS.strStorageTicketNumber  
    ,CS.intEntityId  
    ,E.strName  
    ,CS.intStorageTypeId  
    ,ST.strStorageTypeDescription
    ,ST.ysnCustomerStorage
    ,CS.intStorageScheduleId
    ,SR.strScheduleId  
    ,CS.intCommodityId  
    ,COM.strCommodityCode  
    ,COM.strDescription
    ,CS.intItemId
    ,Item.strItemNo   
    ,CS.intCompanyLocationId  
    ,LOC.strLocationName
    ,ISNULL(CS.intCompanyLocationSubLocationId,0) intCompanyLocationSubLocationId
    ,ISNULL(SLOC.strSubLocationName,'') strSubLocationName 
    ,CS.dtmDeliveryDate  
    ,ISNULL(CS.strDPARecieptNumber,'')strDPARecieptNumber  
    ,dbo.fnCTConvertQuantityToTargetItemUOM(CS.intItemId,CS.intUnitMeasureId,CU.intUnitMeasureId,CS.dblOpenBalance)  dblOpenBalance
    ,ST.ysnDPOwnedType
    ,SH.intContractHeaderId
    ,CH.strContractNumber   
    ,ISNULL(SH1.intTicketId,0) AS intTicketId
    ,ISNULL(dblDiscountsDue,0) - ISNULL(dblDiscountsPaid,0) AS dblDiscountUnPaid
    ,ISNULL(dblStorageDue,0) - ISNULL(dblStoragePaid,0) AS dblStorageUnPaid
    ,IR.strReceiptNumber
FROM tblGRCustomerStorage CS  
JOIN tblGRStorageType ST 
    ON ST.intStorageScheduleTypeId = CS.intStorageTypeId  
JOIN tblSMCompanyLocation LOC 
    ON LOC.intCompanyLocationId = CS.intCompanyLocationId  
JOIN tblEMEntity E 
    ON E.intEntityId = CS.intEntityId  
JOIN tblICCommodity COM 
    ON COM.intCommodityId = CS.intCommodityId
JOIN tblGRStorageScheduleRule SR 
    ON SR.intStorageScheduleRuleId = CS.intStorageScheduleId
JOIN tblICItem Item 
    ON Item.intItemId = CS.intItemId
JOIN tblICCommodityUnitMeasure CU 
    ON CU.intCommodityId = CS.intCommodityId 
        AND CU.ysnStockUnit = 1
LEFT JOIN tblSMCompanyLocationSubLocation SLOC 
    ON SLOC.intCompanyLocationSubLocationId = CS.intCompanyLocationSubLocationId
LEFT JOIN tblGRStorageHistory SH 
    ON SH.intCustomerStorageId = CS.intCustomerStorageId
LEFT JOIN tblGRStorageHistory SH1 
    ON SH1.intCustomerStorageId = CS.intCustomerStorageId 
        AND SH1.strType = 'From Scale'
LEFT JOIN tblCTContractHeader CH 
    ON CH.intContractHeaderId = SH.intContractHeaderId  
LEFT JOIN tblICInventoryReceipt IR 
    ON IR.intInventoryReceiptId = SH1.intInventoryReceiptId
LEFT JOIN tblSCDeliverySheet DS
    ON DS.intDeliverySheetId = CS.intDeliverySheetId
WHERE CS.dblOpenBalance > 0 
    AND ISNULL(CS.strStorageType,'') <> 'ITR'
    AND SH.strType IN ('From Scale','From Transfer','From Delivery Sheet')
    AND (DS.ysnPost = 1 OR CS.intTicketId IS NOT NULL)
ORDER BY CS.dtmDeliveryDate