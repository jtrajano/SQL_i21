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
	,SS.dtmCreated AS dtmDate
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
	--,CAST((SS.dblNetSettlement + SS.dblStorageDue + SS.dblDiscountsDue) AS DECIMAL(18,2)) AS dblSettleStorageAmount
	,CASE WHEN SS.dblUnpaidUnits != 0 
		THEN (
			CASE WHEN ST.intSettleContractId IS NOT NULL THEN ST.dblUnits * ST.dblPrice
			ELSE SS.dblNetSettlement
			END
		)
		ELSE CAST((SS.dblNetSettlement + SS.dblStorageDue + SS.dblDiscountsDue) AS DECIMAL(18,2))
		END AS dblSettleStorageAmount
	--,SS.dblSettleUnits AS dblSettleStorageQty
	,CASE WHEN SS.dblUnpaidUnits != 0 THEN SS.dblUnpaidUnits ELSE SS.dblSettleUnits END AS dblSettleStorageQty
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
		--AND SS.dblSettleUnits = 0 --OPEN STORAGE ONLY , THIS IS THE ONLY SETTLE STORAGE THAT DO NOT CREATE VOUCHER IMMEDIATELEY
INNER JOIN vyuGLDetail GD
	ON GD.strTransactionId = SS.strStorageTicket
		AND GD.intTransactionId = SS.intSettleStorageId
		AND GD.strTransactionType = 'Storage Settlement'
		AND GD.ysnIsUnposted = 0
		AND GD.strDescription LIKE '%Item: ' + IM.strItemNo + '%'
		--AND GD.strCode = 'STR' --get only the AP Clearing for item
INNER JOIN vyuGLAccountDetail AD
	ON GD.intAccountId = AD.intAccountId AND AD.intAccountCategoryId = 45
LEFT JOIN tblGRSettleContract ST
	ON ST.intSettleStorageId = SS.intSettleStorageId
LEFT JOIN tblCTContractDetail CT
	ON CT.intContractDetailId = ST.intContractDetailId
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
	,billDetail.dblTotal AS dblVoucherTotal
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
	,0 AS dblSettleStorageAmount
	,0 AS dblSettleStorageQty
	-- ,CAST(SS.dblNetSettlement AS DECIMAL(18,2)) AS dblSettleStorageAmount
	-- ,SS.dblSettleUnits AS dblSettleStorageQty
	,bill.intShipToId AS intLocationId
	,compLoc.strLocationName
	,0
	,glAccnt.intAccountId
	,glAccnt.strAccountId
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
	,SS.dtmCreated
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
	,CAST(-SS.dblStorageDue AS DECIMAL(18,2)) AS dblSettleStorageAmount
	,CASE WHEN SS.dblSettleUnits != 0 THEN  -SS.dblSettleUnits ELSE -SS.dblUnpaidUnits END
	,CS.intCompanyLocationId
	,CL.strLocationName
	,0
	,GD.intAccountId
	,AD.strAccountId
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
INNER JOIN tblGLDetail GD
	ON GD.strTransactionId = SS.strStorageTicket
		AND GD.intTransactionId = SS.intSettleStorageId
		AND GD.strDescription LIKE '%Charges from ' + IM.strItemNo
		AND GD.ysnIsUnposted = 0
		--AND GD.strCode = 'STR'
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
	,billDetail.dblTotal AS dblVoucherTotal
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
	,0 AS dblSettleStorageAmount
	,0 AS dblSettleStorageQty
	-- ,CAST(-SS.dblStorageDue AS DECIMAL(18,2)) AS dblSettleStorageAmount
	-- ,CASE WHEN IM.strCostMethod != 'Per Unit' THEN -1 ELSE -SS.dblSettleUnits END AS dblSettleStorageQty
	,bill.intShipToId AS intLocationId
	,compLoc.strLocationName
	,0
	,glAccnt.intAccountId
	,glAccnt.strAccountId
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
	,SS.dtmCreated
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
	,CAST(CASE
		WHEN QM.strDiscountChargeType = 'Percent' AND QM.dblDiscountAmount < 0 
		THEN (QM.dblDiscountAmount * (CASE WHEN ISNULL(SS.dblCashPrice,0) > 0 THEN SS.dblCashPrice ELSE CD.dblCashPrice END) * -1)
		WHEN QM.strDiscountChargeType = 'Percent' AND QM.dblDiscountAmount > 0 THEN (QM.dblDiscountAmount * (CASE WHEN ISNULL(SS.dblCashPrice,0) > 0 THEN SS.dblCashPrice ELSE CD.dblCashPrice END)) *  -1
		WHEN QM.strDiscountChargeType = 'Dollar' AND QM.dblDiscountAmount < 0 THEN (QM.dblDiscountAmount)
		WHEN QM.strDiscountChargeType = 'Dollar' AND QM.dblDiscountAmount > 0 THEN (QM.dblDiscountAmount * -1)
	END * (CASE WHEN QM.strCalcMethod = 3 THEN CS.dblGrossQuantity ELSE SST.dblUnits END) AS DECIMAL(18,2))
	,CASE WHEN QM.strCalcMethod = 3 
		THEN (CS.dblGrossQuantity * (SST.dblUnits / CS.dblOriginalBalance))--@dblGrossUnits 
	ELSE SST.dblUnits END * (CASE WHEN QM.dblDiscountAmount > 0 THEN -1 ELSE 1 END)
	,CS.intCompanyLocationId
	,CL.strLocationName
	,0
	,GLDetail.intAccountId
	,GLDetail.strAccountId
FROM tblQMTicketDiscount QM
INNER JOIN tblGRDiscountScheduleCode DSC
	ON DSC.intDiscountScheduleCodeId = QM.intDiscountScheduleCodeId
INNER JOIN tblGRCustomerStorage CS
	ON CS.intCustomerStorageId = QM.intTicketFileId
INNER JOIN tblICItem IM
	ON DSC.intItemId = IM.intItemId
INNER JOIN tblGRDiscountSchedule DS
	ON DS.intDiscountScheduleId = DSC.intDiscountScheduleId
-- INNER JOIN tblICCommodity CO
-- 	ON CO.intCommodityId = DS.intCommodityId
INNER JOIN tblSMCompanyLocation CL
	ON CL.intCompanyLocationId = CS.intCompanyLocationId
INNER JOIN tblGRSettleStorageTicket SST
	ON SST.intCustomerStorageId = CS.intCustomerStorageId
INNER JOIN tblGRSettleStorage SS
	ON SST.intSettleStorageId = SS.intSettleStorageId
		AND SS.intParentSettleStorageId IS NOT NULL
		AND SS.ysnPosted = 1
LEFT JOIN tblGRSettleContract SC
		ON SC.intSettleStorageId = SS.intSettleStorageId
--SETTLE FOR BASIS CONTRACT IS THE ONLY TRANSACTION THAT SHOULD SHOW ON CLEARING TAB
--BUT WE WILL INCLUDE THE OTHERS FOR NOW TO IDENTIFY THE DATA ISSUES ON AP CLEARING
LEFT JOIN tblCTContractDetail CD
		ON CD.intContractDetailId = SC.intContractDetailId 
LEFT JOIN 
(
    tblICItemUOM itemUOM INNER JOIN tblICUnitMeasure unitMeasure
        ON itemUOM.intUnitMeasureId = unitMeasure.intUnitMeasureId
)
    ON itemUOM.intItemUOMId = CS.intItemUOMId
OUTER APPLY
(
	SELECT GD.intAccountId, AD.strAccountId
	FROM tblGLDetail GD
	INNER JOIN vyuGLAccountDetail AD
		ON GD.intAccountId = AD.intAccountId AND AD.intAccountCategoryId = 45
	WHERE GD.strTransactionId = SS.strStorageTicket
		AND GD.intTransactionId = SS.intSettleStorageId
		AND GD.strCode = 'STR'
		AND GD.strDescription LIKE '%Charges from ' + IM.strItemNo
		AND GD.ysnIsUnposted = 0
) GLDetail
WHERE 
	QM.strSourceType = 'Storage' 
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
	,billDetail.intUnitOfMeasureId  AS intItemUOMId
    ,unitMeasure.strUnitMeasure AS strUOM 
	,billDetail.dblTotal AS dblVoucherTotal
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
	,0 AS dblSettleStorageAmount
	,0 AS dblSettleStorageQty
	-- ,CAST(SS.dblNetSettlement AS DECIMAL(18,2)) AS dblSettleStorageAmount
	-- ,SS.dblSettleUnits AS dblSettleStorageQty
	,bill.intShipToId AS intLocationId
	,compLoc.strLocationName
	,0
	,glAccnt.intAccountId
	,glAccnt.strAccountId
FROM tblAPBill bill
INNER JOIN tblAPBillDetail billDetail
	ON bill.intBillId = billDetail.intBillId
INNER JOIN tblICItem IM
	ON billDetail.intItemId = IM.intItemId
INNER JOIN (tblGRCustomerStorage CS INNER JOIN tblGRSettleStorageTicket SST
				ON SST.intCustomerStorageId = CS.intCustomerStorageId
			INNER JOIN tblGRSettleStorage SS
				ON SST.intSettleStorageId = SS.intSettleStorageId
					AND SS.intParentSettleStorageId IS NOT NULL)
	ON CS.intCustomerStorageId = billDetail.intCustomerStorageId
INNER JOIN vyuGLAccountDetail glAccnt
	ON glAccnt.intAccountId = billDetail.intAccountId
INNER JOIN tblSMCompanyLocation compLoc
    ON bill.intShipToId = compLoc.intCompanyLocationId
LEFT JOIN 
(
    tblICItemUOM itemUOM INNER JOIN tblICUnitMeasure unitMeasure
        ON itemUOM.intUnitMeasureId = unitMeasure.intUnitMeasureId
)
    ON itemUOM.intItemUOMId = billDetail.intUnitOfMeasureId
WHERE bill.ysnPosted = 1
AND EXISTS (
	SELECT 1
	FROM tblQMTicketDiscount QM
	INNER JOIN tblGRDiscountScheduleCode DSC
		ON DSC.intDiscountScheduleCodeId = QM.intDiscountScheduleCodeId
		AND DSC.intItemId = billDetail.intItemId
		AND billDetail.intCustomerStorageId = QM.intTicketFileId
)