CREATE VIEW [dbo].[vyuGRGetUnpaidStorageDiscount]
AS  
SELECT 
	BillDiscountKey = CONVERT(INT, DENSE_RANK() OVER (  
			ORDER BY CS.intCustomerStorageId  
			,CS.intEntityId  
			,CS.intItemId  
			,CS.intCompanyLocationId  
			,QM.intDiscountScheduleCodeId  
		)
	)  
	,CS.intCustomerStorageId  
	,CS.intEntityId  
	,E.strName  
	,CS.intItemId  
	,Item.strItemNo  
	,CS.intCompanyLocationId  
	,LOC.strLocationName  
	,CS.strStorageTicketNumber  
	,QM.intDiscountScheduleCodeId  
	,intDiscountItemId	= DItem.intItemId  
	,strDiscountCode	= DItem.strItemNo
	,dblOpenBalance		= (
							CASE 
								WHEN QM.strCalcMethod = 1 THEN ((SC.dblGrossUnits - (CS.dblOriginalBalance - CS.dblOpenBalance)) / 100.0) * (100 - ISNULL(TS.dblTotalShrink,0))
								WHEN QM.strCalcMethod = 2 THEN ((SC.dblGrossUnits - (CS.dblOriginalBalance - CS.dblOpenBalance)) / 100.0) * (100 - ISNULL(GS.dblGrossShrink,0))
								WHEN QM.strCalcMethod = 3 THEN SC.dblGrossUnits - (CS.dblOriginalBalance - CS.dblOpenBalance)
							END
						) * ISNULL(SCTicketSplit.dblSplitPercent / 100.0, 1)  
	,strDicountOn		= DC.strDiscountCalculationOption
	,dblGrossUnits		= SC.dblGrossUnits - (CS.dblOriginalBalance - CS.dblOpenBalance)
	,dblWetUnits		= ((SC.dblGrossUnits - (CS.dblOriginalBalance - CS.dblOpenBalance)) / 100.0) * (100 - ISNULL(GS.dblGrossShrink,0))
	,dblTotalShrink		= (SC.dblGrossUnits - (CS.dblOriginalBalance - CS.dblOpenBalance)) * ISNULL(TS.dblTotalShrink,0) / 100.0
	,dblNetUnits		= ((SC.dblGrossUnits - (CS.dblOriginalBalance - CS.dblOpenBalance)) / 100.0) * (100 - ISNULL(TS.dblTotalShrink,0))
	,dblDiscountDue		= ISNULL(QM.dblDiscountDue, 0)
	,dblDiscountPaid	= ISNULL(QM.dblDiscountPaid, 0)
	,dblDiscountUnpaid	= (ISNULL(QM.dblDiscountDue, 0) - ISNULL(QM.dblDiscountPaid, 0))
	,dblDiscountTotal	= (
							CASE
								WHEN QM.strCalcMethod = 1 THEN ((SC.dblGrossUnits - (CS.dblOriginalBalance - CS.dblOpenBalance)) / 100.0) * (100 - ISNULL(TS.dblTotalShrink,0))
								WHEN QM.strCalcMethod = 2 THEN ((SC.dblGrossUnits - (CS.dblOriginalBalance - CS.dblOpenBalance)) / 100.0) * (100 - ISNULL(GS.dblGrossShrink,0))
								WHEN QM.strCalcMethod = 3 THEN SC.dblGrossUnits-(CS.dblOriginalBalance-CS.dblOpenBalance)
							END
						) * ISNULL(SCTicketSplit.dblSplitPercent / 100.0, 1) * (ISNULL(QM.dblDiscountDue, 0) - ISNULL(QM.dblDiscountPaid, 0))  
	,CS.intStorageTypeId
FROM tblGRCustomerStorage CS
JOIN tblSCTicket SC 
	ON SC.intTicketId = CS.intTicketId    
JOIN tblSMCompanyLocation LOC 
	ON LOC.intCompanyLocationId = CS.intCompanyLocationId  
JOIN tblEMEntity E 
	ON E.intEntityId = CS.intEntityId
JOIN tblICItem Item 
	ON Item.intItemId = CS.intItemId
JOIN tblICItemUOM ItemUOM
	ON ItemUOM.intItemId = Item.intItemId
		AND ItemUOM.intItemUOMId = CS.intItemUOMId
LEFT JOIN tblQMTicketDiscount QM 
	ON QM.intTicketFileId = CS.intCustomerStorageId 
		AND QM.strSourceType = 'Storage'  
JOIN tblGRDiscountScheduleCode Dcode 
	ON Dcode.intDiscountScheduleCodeId = QM.intDiscountScheduleCodeId  
JOIN tblICItem DItem 
	ON DItem.intItemId = Dcode.intItemId
JOIN tblGRDiscountCalculationOption DC 
	ON DC.intDiscountCalculationOptionId = QM.strCalcMethod
LEFT JOIN tblSCTicketSplit SCTicketSplit 
	ON SCTicketSplit.intTicketId = SC.intTicketId 
		AND SCTicketSplit.intCustomerId = CS.intEntityId 
		AND SCTicketSplit.intStorageScheduleTypeId = CS.intStorageTypeId
LEFT JOIN (
			SELECT 
				intTicketFileId
				,ISNULL(SUM(dblShrinkPercent),0) dblGrossShrink 
			FROM tblQMTicketDiscount 
			WHERE strSourceType = 'Storage' 
				AND strCalcMethod = 3 
			GROUP BY intTicketFileId
		) GS 
	ON GS.intTicketFileId = CS.intCustomerStorageId
LEFT JOIN (
			SELECT 
				intTicketFileId
				,ISNULL(SUM(dblShrinkPercent),0) dblTotalShrink 
			FROM tblQMTicketDiscount 
			WHERE strSourceType = 'Storage' 
			GROUP BY intTicketFileId
		) TS
	ON TS.intTicketFileId = CS.intCustomerStorageId    
WHERE CS.dblOpenBalance > 0 
	AND (ISNULL(QM.dblDiscountDue, 0) - ISNULL(QM.dblDiscountPaid, 0)) <> 0

UNION ALL

SELECT 
	BillDiscountKey = CONVERT(INT, DENSE_RANK() OVER (  
			ORDER BY CS.intCustomerStorageId  
			,CS.intEntityId  
			,CS.intItemId  
			,CS.intCompanyLocationId  
			,QM.intDiscountScheduleCodeId  
		)
	)
	,CS.intCustomerStorageId  
	,CS.intEntityId  
	,E.strName  
	,CS.intItemId  
	,Item.strItemNo  
	,CS.intCompanyLocationId  
	,LOC.strLocationName  
	,CS.strStorageTicketNumber  
	,QM.intDiscountScheduleCodeId  
	,intDiscountItemId	= DItem.intItemId
	,strDiscountCode	= DItem.strItemNo
	,dblOpenBalance		= (
							CASE 
								WHEN QM.strCalcMethod = 1 THEN ((DS.dblGross - (CS.dblOriginalBalance - CS.dblOpenBalance)) / 100.0) * (100 - ISNULL(TS.dblTotalShrink,0))
								WHEN QM.strCalcMethod = 2 THEN ((DS.dblGross - (CS.dblOriginalBalance - CS.dblOpenBalance)) / 100.0) * (100 - ISNULL(GS.dblGrossShrink,0))
								WHEN QM.strCalcMethod = 3 THEN DS.dblGross - (CS.dblOriginalBalance - CS.dblOpenBalance)
							END
						) * ISNULL(DSSplit.dblSplitPercent / 100.0, 1)
	,strDicountOn		= DC.strDiscountCalculationOption
	,dblGrossUnits		= DS.dblGross - (CS.dblOriginalBalance - CS.dblOpenBalance)
	,dblWetUnits		= ((DS.dblGross - (CS.dblOriginalBalance - CS.dblOpenBalance)) / 100.0) * (100 - ISNULL(GS.dblGrossShrink,0))
	,dblTotalShrink		= (DS.dblGross - (CS.dblOriginalBalance - CS.dblOpenBalance)) * ISNULL(TS.dblTotalShrink,0) / 100.0
	,dblNetUnits		= ((DS.dblGross - (CS.dblOriginalBalance - CS.dblOpenBalance)) / 100.0) * (100 - ISNULL(TS.dblTotalShrink,0))
	,dblDiscountDue		= ISNULL(QM.dblDiscountDue, 0) 
	,dblDiscountPaid	= ISNULL(QM.dblDiscountPaid, 0) 
	,dblDiscountUnpaid	= (ISNULL(QM.dblDiscountDue, 0) - ISNULL(QM.dblDiscountPaid, 0)) 
	,dblDiscountTotal	= (
							CASE
								WHEN QM.strCalcMethod = 1 THEN ((DS.dblGross - (CS.dblOriginalBalance - CS.dblOpenBalance)) / 100.0) * (100 - ISNULL(TS.dblTotalShrink,0))
								WHEN QM.strCalcMethod = 2 THEN ((DS.dblGross - (CS.dblOriginalBalance - CS.dblOpenBalance)) / 100.0) * (100 - ISNULL(GS.dblGrossShrink,0))
								WHEN QM.strCalcMethod = 3 THEN DS.dblGross - (CS.dblOriginalBalance-CS.dblOpenBalance)
							END
						) * ISNULL(DSSplit.dblSplitPercent / 100.0, 1) * (ISNULL(QM.dblDiscountDue, 0) - ISNULL(QM.dblDiscountPaid, 0))  
	,CS.intStorageTypeId
FROM tblGRCustomerStorage CS
JOIN tblSCDeliverySheet DS 
	ON DS.intDeliverySheetId = CS.intDeliverySheetId
JOIN tblSMCompanyLocation LOC 
	ON LOC.intCompanyLocationId = CS.intCompanyLocationId  
JOIN tblEMEntity E 
	ON E.intEntityId = CS.intEntityId
JOIN tblICItem Item 
	ON Item.intItemId = CS.intItemId
JOIN tblICItemUOM ItemUOM
	ON ItemUOM.intItemId = Item.intItemId
		AND ItemUOM.intItemUOMId = CS.intItemUOMId
LEFT JOIN tblQMTicketDiscount QM 
	ON QM.intTicketFileId = CS.intCustomerStorageId 
		AND QM.strSourceType = 'Storage'  
JOIN tblGRDiscountScheduleCode Dcode 
	ON Dcode.intDiscountScheduleCodeId = QM.intDiscountScheduleCodeId  
JOIN tblICItem DItem 
	ON DItem.intItemId = Dcode.intItemId
JOIN tblGRDiscountCalculationOption DC 
	ON DC.intDiscountCalculationOptionId = QM.strCalcMethod
LEFT JOIN tblSCDeliverySheetSplit DSSplit 
	ON DSSplit.intDeliverySheetId = DS.intDeliverySheetId
		AND DSSplit.intEntityId = CS.intEntityId 
		AND DSSplit.intStorageScheduleTypeId = CS.intStorageTypeId
LEFT JOIN (
			SELECT 
				intTicketFileId
				,ISNULL(SUM(dblShrinkPercent),0) dblGrossShrink 
			FROM tblQMTicketDiscount 
			WHERE strSourceType = 'Storage' 
				AND strCalcMethod = 3 
			GROUP BY intTicketFileId
		) GS 
	ON GS.intTicketFileId = CS.intCustomerStorageId
LEFT JOIN (
			SELECT 
				intTicketFileId
				,ISNULL(SUM(dblShrinkPercent),0) dblTotalShrink 
			FROM tblQMTicketDiscount 
			WHERE strSourceType = 'Storage' 
			GROUP BY intTicketFileId
		) TS
	ON TS.intTicketFileId = CS.intCustomerStorageId    
WHERE CS.dblOpenBalance > 0 
	AND (ISNULL(QM.dblDiscountDue, 0) - ISNULL(QM.dblDiscountPaid, 0)) <> 0