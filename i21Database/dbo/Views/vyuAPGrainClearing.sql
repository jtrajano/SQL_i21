CREATE VIEW [dbo].[vyuAPGrainClearing]
AS 

-- SELECT 
-- 	CS.intEntityId
-- 	,CS.dtmDeliveryDate
-- 	,dtmSettlementDate = SS.dtmCreated
-- 	,SS.strStorageTicket
-- 	,SS.intSettleStorageId
-- 	,NULL AS intBillId
--     ,NULL AS strBillId
--     ,NULL AS intBillDetailId
-- 	,CS.intCustomerStorageId
-- 	,CS.intItemId
-- 	,0 AS dblVoucherTotal
--     ,0 AS dblVoucherQty
-- 	,CAST(SS.dblNetSettlement AS DECIMAL(18,2)) AS dblSettleStorageAmount
-- 	,SS.dblSettleUnits AS dblSettleStorageQty
-- 	,GD.intAccountId
-- 	,strAccountDescription = AD.strDescription
-- 	,strGLDescription = GD.strDescription
-- FROM vyuGLDetail GD
-- INNER JOIN vyuGLAccountDetail AD
-- 	ON AD.intAccountId = GD.intAccountId
-- INNER JOIN tblGRSettleStorage SS
-- 	ON SS.intSettleStorageId = GD.intTransactionId
-- 		AND SS.strStorageTicket = GD.strTransactionId
-- INNER JOIN tblGRSettleStorageTicket SST
-- 	ON SST.intSettleStorageId = SS.intSettleStorageId
-- INNER JOIN tblGRCustomerStorage CS
-- 	ON CS.intCustomerStorageId = SST.intCustomerStorageId
-- WHERE GD.strTransactionId LIKE 'STR-%'
-- 	AND SS.intBillId IS NULL
-- 	AND GD.strCode IN ('STR','IC')

--Settle Storage items
SELECT 
	CS.intEntityId AS intEntityVendorId
	,CS.dtmDeliveryDate AS dtmDate
	,SS.strStorageTicket AS strTransactionNumber
	,SS.intSettleStorageId
	,NULL AS intBillId
    ,NULL AS strBillId
    ,NULL AS intBillDetailId
	,CS.intCustomerStorageId
	,CS.intItemId
	,CS.intItemUOMId  AS intItemUOMId
    ,unitMeasure.strUnitMeasure AS strUOM 
	,0 AS dblVoucherTotal
    ,0 AS dblVoucherQty
	,CAST(SS.dblNetSettlement AS DECIMAL(18,2)) AS dblSettleStorageAmount
	,SS.dblSettleUnits AS dblSettleStorageQty
	,CS.intCompanyLocationId AS intLocationId
	,CL.strLocationName
	,CAST(0 AS BIT) ysnAllowVoucher
	,GD.intAccountId
	,AD.strAccountId
FROM tblGRCustomerStorage CS
INNER JOIN tblICItem IM
	ON IM.intItemId = CS.intItemId
INNER JOIN tblICCommodity CO
	ON CO.intCommodityId = CS.intCommodityId
INNER JOIN tblSMCompanyLocation CL
	ON CL.intCompanyLocationId = CS.intCompanyLocationId
INNER JOIN tblGRSettleStorageTicket SST
	ON SST.intCustomerStorageId = CS.intCustomerStorageId
INNER JOIN tblGRSettleStorage SS
	ON SST.intSettleStorageId = SS.intSettleStorageId
		AND SS.intParentSettleStorageId IS NOT NULL
		AND SS.dblSettleUnits = 0
INNER JOIN vyuGLDetail GD
	ON GD.strTransactionId = SS.strStorageTicket
		AND GD.intTransactionId = SS.intSettleStorageId
		AND GD.strTransactionType = 'Storage Settlement'
		AND GD.ysnIsUnposted = 0
		AND GD.strCode = 'IC' --get only the AP Clearing for item
INNER JOIN vyuGLAccountDetail AD
	ON GD.intAccountId = AD.intAccountId AND AD.intAccountCategoryId = 45
LEFT JOIN 
(
    tblICItemUOM itemUOM INNER JOIN tblICUnitMeasure unitMeasure
        ON itemUOM.intUnitMeasureId = unitMeasure.intUnitMeasureId
)
    ON itemUOM.intItemUOMId = CS.intItemUOMId
UNION ALL
SELECT
	bill.intEntityVendorId
	,bill.dtmDate
	,SS.strStorageTicket
	,SS.intSettleStorageId
	,bill.intBillId
    ,bill.strBillId
    ,billDetail.intBillDetailId
	,billDetail.intCustomerStorageId
	,billDetail.intItemId
	,CS.intItemUOMId  AS intItemUOMId
    ,unitMeasure.strUnitMeasure AS strUOM 
	,billDetail.dblTotal + billDetail.dblTax AS dblVoucherTotal
    ,CASE 
		WHEN billDetail.intWeightUOMId IS NULL THEN 
			ISNULL(billDetail.dblQtyReceived, 0) 
		ELSE 
			CASE 
			WHEN ISNULL(billDetail.dblNetWeight, 0) = 0 THEN 
				ISNULL(dbo.fnCalculateQtyBetweenUOM(billDetail.intUnitOfMeasureId, billDetail.intWeightUOMId, ISNULL(billDetail.dblQtyReceived, 0)), 0)
			ELSE 
				ISNULL(billDetail.dblNetWeight, 0) 
		END
		END AS dblVoucherQty
	,CAST(SS.dblNetSettlement AS DECIMAL(18,2)) AS dblSettleStorageAmount
	,SS.dblSettleUnits AS dblSettleStorageQty
	,bill.intShipToId AS intLocationId
	,compLoc.strLocationName
	,0
	,glAccnt.intAccountId
	,glAccnt.strDescription
FROM tblAPBill bill
INNER JOIN tblAPBillDetail billDetail
	ON bill.intBillId = billDetail.intBillId
INNER JOIN (tblGRCustomerStorage CS INNER JOIN tblGRSettleStorageTicket SST
			ON SST.intCustomerStorageId = CS.intCustomerStorageId
		INNER JOIN tblGRSettleStorage SS
			ON SST.intSettleStorageId = SS.intSettleStorageId AND SS.intParentSettleStorageId IS NOT NULL)
	ON billDetail.intCustomerStorageId = CS.intCustomerStorageId AND billDetail.intItemId = CS.intItemId
INNER JOIN vyuGLAccountDetail glAccnt
	ON glAccnt.intAccountId = billDetail.intAccountId
INNER JOIN tblSMCompanyLocation compLoc
    ON bill.intShipToId = compLoc.intCompanyLocationId
LEFT JOIN 
(
    tblICItemUOM itemUOM INNER JOIN tblICUnitMeasure unitMeasure
        ON itemUOM.intUnitMeasureId = unitMeasure.intUnitMeasureId
)
    ON itemUOM.intItemUOMId = CS.intItemUOMId
WHERE bill.ysnPosted = 1
UNION ALL --Charges
SELECT 
	CS.intEntityId AS intEntityVendorId
	,CS.dtmDeliveryDate
	,SS.strStorageTicket
	,SS.intSettleStorageId
	,NULL AS intBillId
    ,NULL AS strBillId
    ,NULL AS intBillDetailId
	,CS.intCustomerStorageId
	,IM.intItemId
	,CS.intItemUOMId  AS intItemUOMId
    ,unitMeasure.strUnitMeasure AS strUOM 
	,0 AS dblVoucherTotal
    ,0 AS dblVoucherQty
	,0
	,0
	,CS.intCompanyLocationId
	,CL.strLocationName
	,0
	,GD.intAccountId
	,AD.strDescription
FROM tblGRCustomerStorage CS
INNER JOIN tblICCommodity CO
	ON CO.intCommodityId = CS.intCommodityId
INNER JOIN tblICItem IM
	ON IM.strType = 'Other Charge' 
		AND IM.strCostType = 'Storage Charge' 
		AND (IM.intCommodityId = CO.intCommodityId OR IM.intCommodityId IS NULL)
INNER JOIN tblSMCompanyLocation CL
	ON CL.intCompanyLocationId = CS.intCompanyLocationId
INNER JOIN tblGRSettleStorageTicket SST
	ON SST.intCustomerStorageId = CS.intCustomerStorageId
INNER JOIN tblGRSettleStorage SS
	ON SST.intSettleStorageId = SS.intSettleStorageId
		AND SS.intParentSettleStorageId IS NOT NULL
INNER JOIN vyuGLDetail GD
	ON GD.strTransactionId = SS.strStorageTicket
		AND GD.intTransactionId = SS.intSettleStorageId
		AND GD.strCode = 'STR'
		AND GD.strDescription LIKE '%Charges from ' + IM.strItemNo
		AND GD.ysnIsUnposted = 0
INNER JOIN vyuGLAccountDetail AD
	ON GD.intAccountId = AD.intAccountId AND AD.intAccountCategoryId = 45
LEFT JOIN 
(
    tblICItemUOM itemUOM INNER JOIN tblICUnitMeasure unitMeasure
        ON itemUOM.intUnitMeasureId = unitMeasure.intUnitMeasureId
)
    ON itemUOM.intItemUOMId = CS.intItemUOMId
UNION ALL
SELECT
	bill.intEntityVendorId
	,bill.dtmDate
	,SS.strStorageTicket
	,SS.intSettleStorageId
	,bill.intBillId
    ,bill.strBillId
    ,billDetail.intBillDetailId
	,billDetail.intCustomerStorageId
	,billDetail.intItemId
	,CS.intItemUOMId  AS intItemUOMId
    ,unitMeasure.strUnitMeasure AS strUOM 
	,billDetail.dblTotal + billDetail.dblTax AS dblVoucherTotal
    ,CASE 
		WHEN billDetail.intWeightUOMId IS NULL THEN 
			ISNULL(billDetail.dblQtyReceived, 0) 
		ELSE 
			CASE 
			WHEN ISNULL(billDetail.dblNetWeight, 0) = 0 THEN 
				ISNULL(dbo.fnCalculateQtyBetweenUOM(billDetail.intUnitOfMeasureId, billDetail.intWeightUOMId, ISNULL(billDetail.dblQtyReceived, 0)), 0)
			ELSE 
				ISNULL(billDetail.dblNetWeight, 0) 
		END
		END AS dblVoucherQty
	,CAST(SS.dblNetSettlement AS DECIMAL(18,2)) AS dblSettleStorageAmount
	,SS.dblSettleUnits AS dblSettleStorageQty
	,bill.intShipToId AS intLocationId
	,compLoc.strLocationName
	,0
	,glAccnt.intAccountId
	,glAccnt.strDescription
FROM tblAPBill bill
INNER JOIN tblAPBillDetail billDetail
	ON bill.intBillId = billDetail.intBillId
INNER JOIN (tblGRCustomerStorage CS INNER JOIN tblGRSettleStorageTicket SST
			ON SST.intCustomerStorageId = CS.intCustomerStorageId
		INNER JOIN tblGRSettleStorage SS
			ON SST.intSettleStorageId = SS.intSettleStorageId AND SS.intParentSettleStorageId IS NOT NULL
		INNER JOIN tblICCommodity CO
			ON CO.intCommodityId = CS.intCommodityId
		INNER JOIN tblICItem IM
			ON IM.strType = 'Other Charge' 
				AND IM.strCostType = 'Storage Charge' 
				AND (IM.intCommodityId = CO.intCommodityId OR IM.intCommodityId IS NULL))
	ON billDetail.intCustomerStorageId = CS.intCustomerStorageId AND billDetail.intItemId = IM.intItemId
INNER JOIN vyuGLAccountDetail glAccnt
	ON glAccnt.intAccountId = billDetail.intAccountId
INNER JOIN tblSMCompanyLocation compLoc
    ON bill.intShipToId = compLoc.intCompanyLocationId
LEFT JOIN 
(
    tblICItemUOM itemUOM INNER JOIN tblICUnitMeasure unitMeasure
        ON itemUOM.intUnitMeasureId = unitMeasure.intUnitMeasureId
)
    ON itemUOM.intItemUOMId = CS.intItemUOMId
WHERE bill.ysnPosted = 1
UNION ALL --DISCOUNTS
SELECT 
	CS.intEntityId AS intEntityVendorId
	,CS.dtmDeliveryDate
	,SS.strStorageTicket
	,SS.intSettleStorageId
	,NULL AS intBillId
    ,NULL AS strBillId
    ,NULL AS intBillDetailId
	,CS.intCustomerStorageId
	,IM.intItemId
	,CS.intItemUOMId  AS intItemUOMId
    ,unitMeasure.strUnitMeasure AS strUOM 
	,0 AS dblVoucherTotal
    ,0 AS dblVoucherQty
	,0
	,0
	,CS.intCompanyLocationId
	,CL.strLocationName
	,0
	,GD.intAccountId
	,AD.strDescription
FROM tblQMTicketDiscount QM
INNER JOIN tblGRDiscountScheduleCode DSC
	ON DSC.intDiscountScheduleCodeId = QM.intDiscountScheduleCodeId
INNER JOIN tblGRCustomerStorage CS
	ON CS.intCustomerStorageId = QM.intTicketFileId
INNER JOIN tblICItem IM
	ON DSC.intItemId = IM.intItemId
INNER JOIN tblGRDiscountSchedule DS
	ON DS.intDiscountScheduleId = DSC.intDiscountScheduleId
INNER JOIN tblICCommodity CO
	ON CO.intCommodityId = DS.intCommodityId
INNER JOIN tblSMCompanyLocation CL
	ON CL.intCompanyLocationId = CS.intCompanyLocationId
INNER JOIN tblGRSettleStorageTicket SST
	ON SST.intCustomerStorageId = CS.intCustomerStorageId
INNER JOIN tblGRSettleStorage SS
	ON SST.intSettleStorageId = SS.intSettleStorageId
		AND SS.intParentSettleStorageId IS NOT NULL
INNER JOIN vyuGLDetail GD
	ON GD.strTransactionId = SS.strStorageTicket
		AND GD.intTransactionId = SS.intSettleStorageId
		AND GD.strCode = 'STR'
		AND GD.strDescription LIKE '%Charges from ' + IM.strItemNo
		AND GD.ysnIsUnposted = 0
INNER JOIN vyuGLAccountDetail AD
	ON GD.intAccountId = AD.intAccountId AND AD.intAccountCategoryId = 45
LEFT JOIN 
(
    tblICItemUOM itemUOM INNER JOIN tblICUnitMeasure unitMeasure
        ON itemUOM.intUnitMeasureId = unitMeasure.intUnitMeasureId
)
    ON itemUOM.intItemUOMId = CS.intItemUOMId
WHERE QM.strSourceType = 'Storage' 
	AND QM.dblDiscountDue <> 0
UNION ALL
SELECT
	bill.intEntityVendorId
	,bill.dtmDate
	,SS.strStorageTicket
	,SS.intSettleStorageId
	,bill.intBillId
    ,bill.strBillId
    ,billDetail.intBillDetailId
	,billDetail.intCustomerStorageId
	,billDetail.intItemId
	,CS.intItemUOMId  AS intItemUOMId
    ,unitMeasure.strUnitMeasure AS strUOM 
	,billDetail.dblTotal + billDetail.dblTax AS dblVoucherTotal
    ,CASE 
		WHEN billDetail.intWeightUOMId IS NULL THEN 
			ISNULL(billDetail.dblQtyReceived, 0) 
		ELSE 
			CASE 
			WHEN ISNULL(billDetail.dblNetWeight, 0) = 0 THEN 
				ISNULL(dbo.fnCalculateQtyBetweenUOM(billDetail.intUnitOfMeasureId, billDetail.intWeightUOMId, ISNULL(billDetail.dblQtyReceived, 0)), 0)
			ELSE 
				ISNULL(billDetail.dblNetWeight, 0) 
		END
		END AS dblVoucherQty
	,CAST(SS.dblNetSettlement AS DECIMAL(18,2)) AS dblSettleStorageAmount
	,SS.dblSettleUnits AS dblSettleStorageQty
	,bill.intShipToId AS intLocationId
	,compLoc.strLocationName
	,0
	,glAccnt.intAccountId
	,glAccnt.strDescription
FROM tblAPBill bill
INNER JOIN tblAPBillDetail billDetail
	ON bill.intBillId = billDetail.intBillId
INNER JOIN (tblGRCustomerStorage CS INNER JOIN tblGRSettleStorageTicket SST
				ON SST.intCustomerStorageId = CS.intCustomerStorageId
			INNER JOIN tblGRSettleStorage SS
				ON SST.intSettleStorageId = SS.intSettleStorageId
					AND SS.intParentSettleStorageId IS NOT NULL
			INNER JOIN tblQMTicketDiscount QM
				ON CS.intCustomerStorageId = QM.intTicketFileId
			INNER JOIN tblGRDiscountScheduleCode DSC
				ON DSC.intDiscountScheduleCodeId = QM.intDiscountScheduleCodeId
			INNER JOIN tblICItem IM
				ON DSC.intItemId = IM.intItemId
			)
	ON billDetail.intCustomerStorageId = CS.intCustomerStorageId AND billDetail.intItemId = IM.intItemId
INNER JOIN vyuGLAccountDetail glAccnt
	ON glAccnt.intAccountId = billDetail.intAccountId
INNER JOIN tblSMCompanyLocation compLoc
    ON bill.intShipToId = compLoc.intCompanyLocationId
LEFT JOIN 
(
    tblICItemUOM itemUOM INNER JOIN tblICUnitMeasure unitMeasure
        ON itemUOM.intUnitMeasureId = unitMeasure.intUnitMeasureId
)
    ON itemUOM.intItemUOMId = CS.intItemUOMId
WHERE bill.ysnPosted = 1