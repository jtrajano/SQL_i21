CREATE VIEW [dbo].[vyuGRGetUnpaidStorageDiscount]
AS  
SELECT CONVERT(INT, DENSE_RANK() OVER (  
   ORDER BY CS.intCustomerStorageId  
    ,CS.intEntityId  
    ,CS.intItemId  
    ,CS.intCompanyLocationId  
    ,QM.intDiscountScheduleCodeId  
   )) AS BillDiscountKey  
 ,CS.intCustomerStorageId  
 ,CS.intEntityId  
 ,E.strName  
 ,CS.intItemId  
 ,Item.strItemNo  
 ,CS.intCompanyLocationId  
 ,c.strLocationName  
 ,CS.strStorageTicketNumber  
 ,QM.intDiscountScheduleCodeId  
 ,DItem.intItemId AS intDiscountItemId  
 ,DItem.strItemNo AS strDiscountCode  
 ,dbo.fnCTConvertQuantityToTargetItemUOM(CS.intItemId, CS.intUnitMeasureId, CU.intUnitMeasureId, CS.dblOpenBalance) dblOpenBalance  
 ,ISNULL(QM.dblDiscountDue, 0) AS dblDiscountDue  
 ,ISNULL(QM.dblDiscountPaid, 0) AS dblDiscountPaid  
 ,(ISNULL(QM.dblDiscountDue, 0) - ISNULL(QM.dblDiscountPaid, 0)) AS dblDiscountUnpaid  
 ,dbo.fnCTConvertQuantityToTargetItemUOM(CS.intItemId, CS.intUnitMeasureId, CU.intUnitMeasureId, CS.dblOpenBalance) * (ISNULL(QM.dblDiscountDue, 0) - ISNULL(QM.dblDiscountPaid, 0)) AS dblDiscountTotal  
FROM tblGRCustomerStorage CS  
JOIN tblSMCompanyLocation c ON c.intCompanyLocationId = CS.intCompanyLocationId  
JOIN tblEMEntity E ON E.intEntityId = CS.intEntityId  
JOIN tblICCommodity CM ON CM.intCommodityId = CS.intCommodityId  
JOIN tblICItem Item ON Item.intItemId = CS.intItemId  
JOIN tblICCommodityUnitMeasure CU ON CU.intCommodityId = CS.intCommodityId AND CU.ysnStockUnit = 1  
LEFT JOIN tblQMTicketDiscount QM ON QM.intTicketFileId = CS.intCustomerStorageId AND QM.strSourceType = 'Storage'  
JOIN tblGRDiscountScheduleCode a ON a.intDiscountScheduleCodeId = QM.intDiscountScheduleCodeId  
JOIN tblICItem DItem ON DItem.intItemId = a.intItemId  
WHERE ISNULL(CS.strStorageType, '') <> 'ITR' AND CS.dblOpenBalance >0 AND (ISNULL(QM.dblDiscountDue, 0) - ISNULL(QM.dblDiscountPaid, 0)) <> 0