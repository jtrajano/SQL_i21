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
 ,LOC.strLocationName  
 ,CS.strStorageTicketNumber  
 ,QM.intDiscountScheduleCodeId  
 ,DItem.intItemId AS intDiscountItemId  
 ,DItem.strItemNo AS strDiscountCode
 --,dbo.fnCTConvertQuantityToTargetItemUOM(CS.intItemId, CS.intUnitMeasureId, CU.intUnitMeasureId, CS.dblOpenBalance) dblOpenBalance
 ,CASE 
	WHEN QM.strCalcMethod=1 THEN ((SC.dblGrossUnits-(CS.dblOriginalBalance-CS.dblOpenBalance))/100.0)*(100-ISNULL(t1.dblTotalShrink,0))
	WHEN QM.strCalcMethod=2 THEN ((SC.dblGrossUnits-(CS.dblOriginalBalance-CS.dblOpenBalance))/100.0)*(100-ISNULL(t.dblGrossShrink,0))
	WHEN QM.strCalcMethod=3 THEN SC.dblGrossUnits-(CS.dblOriginalBalance-CS.dblOpenBalance)
  END  dblOpenBalance  
 ,DC.strDiscountCalculationOption AS strDicountOn
 ,SC.dblGrossUnits-(CS.dblOriginalBalance-CS.dblOpenBalance) AS dblGrossUnits
 ,((SC.dblGrossUnits-(CS.dblOriginalBalance-CS.dblOpenBalance))/100.0)*(100-ISNULL(t.dblGrossShrink,0)) AS dblWetUnits
 ,(SC.dblGrossUnits-(CS.dblOriginalBalance-CS.dblOpenBalance))* ISNULL(t1.dblTotalShrink,0)/100.0 AS dblTotalShrink
 ,((SC.dblGrossUnits-(CS.dblOriginalBalance-CS.dblOpenBalance))/100.0)*(100-ISNULL(t1.dblTotalShrink,0)) AS dblNetUnits
 ,ISNULL(QM.dblDiscountDue, 0) AS dblDiscountDue  
 ,ISNULL(QM.dblDiscountPaid, 0) AS dblDiscountPaid  
 ,(ISNULL(QM.dblDiscountDue, 0) - ISNULL(QM.dblDiscountPaid, 0)) AS dblDiscountUnpaid  
 ,CASE 
	WHEN QM.strCalcMethod=1 THEN ((SC.dblGrossUnits-(CS.dblOriginalBalance-CS.dblOpenBalance))/100.0)*(100-ISNULL(t1.dblTotalShrink,0))
	WHEN QM.strCalcMethod=2 THEN ((SC.dblGrossUnits-(CS.dblOriginalBalance-CS.dblOpenBalance))/100.0)*(100-ISNULL(t.dblGrossShrink,0))
	WHEN QM.strCalcMethod=3 THEN SC.dblGrossUnits-(CS.dblOriginalBalance-CS.dblOpenBalance)
  END
 * (ISNULL(QM.dblDiscountDue, 0) - ISNULL(QM.dblDiscountPaid, 0)) AS dblDiscountTotal  
FROM tblGRCustomerStorage CS
JOIN tblSCTicket SC ON SC.intTicketId=CS.intTicketId    
JOIN tblSMCompanyLocation LOC ON LOC.intCompanyLocationId = CS.intCompanyLocationId  
JOIN tblEMEntity E ON E.intEntityId = CS.intEntityId  
JOIN tblICCommodity COM ON COM.intCommodityId = CS.intCommodityId  
JOIN tblICItem Item ON Item.intItemId = CS.intItemId  
JOIN tblICCommodityUnitMeasure CU ON CU.intCommodityId = CS.intCommodityId AND CU.ysnStockUnit = 1  
LEFT JOIN tblQMTicketDiscount QM ON QM.intTicketFileId = CS.intCustomerStorageId AND QM.strSourceType = 'Storage'  
JOIN tblGRDiscountScheduleCode Dcode ON Dcode.intDiscountScheduleCodeId = QM.intDiscountScheduleCodeId  
JOIN tblICItem DItem ON DItem.intItemId = Dcode.intItemId
JOIN tblGRDiscountCalculationOption DC ON DC.intDiscountCalculationOptionId = QM.strCalcMethod
LEFT JOIN (SELECT intTicketFileId,ISNULL(SUM(dblShrinkPercent),0) dblGrossShrink FROM tblQMTicketDiscount WHERE strSourceType = 'Storage' AND strCalcMethod=3 GROUP BY intTicketFileId)t ON t.intTicketFileId=CS.intCustomerStorageId
LEFT JOIN (SELECT intTicketFileId,ISNULL(SUM(dblShrinkPercent),0) dblTotalShrink FROM tblQMTicketDiscount WHERE strSourceType = 'Storage' GROUP BY intTicketFileId)t1 ON t1.intTicketFileId=CS.intCustomerStorageId    
WHERE ISNULL(CS.strStorageType, '') <> 'ITR' AND CS.dblOpenBalance >0 AND (ISNULL(QM.dblDiscountDue, 0) - ISNULL(QM.dblDiscountPaid, 0)) <> 0