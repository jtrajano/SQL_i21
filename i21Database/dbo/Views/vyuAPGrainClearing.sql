CREATE VIEW [dbo].[vyuAPGrainClearing]
AS 

SELECT --'a' AS TEST,
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
	,CASE 
		WHEN SS.dblUnpaidUnits != 0 
			THEN (
				CASE 
					WHEN PFD.intSettleContractId IS NOT NULL THEN CAST(PFD.dblUnits * PFD.dblCashPrice as decimal(18, 4))
					WHEN SC.intSettleContractId IS NOT NULL THEN CAST(SC.dblUnits * SC.dblPrice as decimal(18, 4))
					ELSE SS.dblNetSettlement
				END
			)
		ELSE CAST(
				CASE 
					WHEN PFD.intSettleContractId IS NOT NULL THEN CAST(PFD.dblUnits * PFD.dblCashPrice as decimal(18, 4))
					WHEN SC.intSettleContractId IS NULL 
						THEN (SS.dblNetSettlement + SS.dblStorageDue + SS.dblDiscountsDue) 
					ELSE
						(SC.dblUnits * SC.dblPrice) --NET SETTLEMENT
				END						
			AS DECIMAL(18,4))
	END AS dblSettleStorageAmount
	,CAST(
			CASE 
				WHEN SS.dblUnpaidUnits != 0 THEN SS.dblUnpaidUnits 
				ELSE 
					CASE 
						WHEN PFD.intSettleContractId IS NOT NULL THEN PFD.dblUnits
						WHEN SC.intSettleStorageId IS NOT NULL THEN SC.dblUnits
						ELSE SS.dblSettleUnits 
					END 
			END AS DECIMAL(18,4)
	) AS dblSettleStorageQty
	,CS.intCompanyLocationId AS intLocationId
	,CL.strLocationName
	,CAST(0 AS BIT) ysnAllowVoucher
	,GD.intAccountId
	,AD.strAccountId
FROM tblGRCustomerStorage CS
INNER JOIN tblGRStorageType STY
	ON STY.intStorageScheduleTypeId = CS.intStorageTypeId
		AND STY.ysnDPOwnedType = 0
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
		--AND SS.dblSpotUnits = 0
INNER JOIN tblGLDetail GD
	ON GD.strTransactionId = SS.strStorageTicket
		AND GD.intTransactionId = SS.intSettleStorageId
		AND GD.strTransactionType = 'Storage Settlement'
		AND GD.ysnIsUnposted = 0
		AND GD.strCode = 'IC'
		AND ((GD.dblDebit <> 0 AND GD.dblCredit = 0) OR (GD.dblDebit = 0 AND GD.dblCredit <> 0))
 INNER JOIN vyuGLAccountDetail AD
 	ON GD.intAccountId = AD.intAccountId AND AD.intAccountCategoryId = 45
LEFT JOIN tblGRSettleContract SC
	ON SC.intSettleStorageId = SS.intSettleStorageId
LEFT JOIN tblCTContractDetail CT
	ON CT.intContractDetailId = SC.intContractDetailId
LEFT JOIN tblCTContractHeader CH
	ON CH.intContractHeaderId = CT.intContractHeaderId
LEFT JOIN tblGRSettleContractPriceFixationDetail PFD --Basis has price already when it was used for settlement
	ON PFD.intSettleContractId = SC.intSettleContractId
LEFT JOIN 
(
    tblICItemUOM itemUOM INNER JOIN tblICUnitMeasure unitMeasure
        ON itemUOM.intUnitMeasureId = unitMeasure.intUnitMeasureId
)
    ON itemUOM.intItemUOMId = CS.intItemUOMId
OUTER APPLY (
	SELECT ysnReversed = 1
	FROM tblGLDetail 
	WHERE strTransactionId = SS.strStorageTicket
		AND intTransactionId = SS.intSettleStorageId
		AND strTransactionType = 'Storage Settlement'
		AND ysnIsUnposted = 0
		AND strComments IN ('GRN-2604-REVERSAL','GRN-2741-REVERSAL')
) GL
WHERE SS.ysnPosted = 1
	--and SS.strStorageTicket = 'STR-8294/3'
	AND GL.ysnReversed IS NULL
	--AND (GD.dblCredit <> 0 AND GD.dblDebit <> 0)
UNION
SELECT --'b',
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
	--,billDetail.dblTotal AS dblVoucherTotal
	--use the cost of settlement for cost adjustment
	,  CAST(isnull(dblOldCost, billDetail.dblCost) * CASE 
		WHEN billDetail.intWeightUOMId IS NULL THEN 
			ISNULL(billDetail.dblQtyReceived, 0) 
		ELSE 
			CASE 
			WHEN ISNULL(billDetail.dblNetWeight, 0) = 0 THEN 
				ISNULL(dbo.fnCalculateQtyBetweenUOM(billDetail.intUnitOfMeasureId, billDetail.intWeightUOMId, ISNULL(billDetail.dblQtyReceived, 0)), 0)
			ELSE 
				ISNULL(billDetail.dblNetWeight, 0) 
		END
		END * (CASE WHEN bill.intTransactionType = 1 THEN 1 ELSE -1 END) AS DECIMAL(18,4)) as dblVoucherTotal	
    ,CAST(CASE 
		WHEN billDetail.intWeightUOMId IS NULL THEN 
			ISNULL(billDetail.dblQtyReceived, 0) 
		ELSE 
			CASE 
			WHEN ISNULL(billDetail.dblNetWeight, 0) = 0 THEN 
				ISNULL(dbo.fnCalculateQtyBetweenUOM(billDetail.intUnitOfMeasureId, billDetail.intWeightUOMId, ISNULL(billDetail.dblQtyReceived, 0)), 0)
			ELSE 
				ISNULL(billDetail.dblNetWeight, 0) 
		END
		END * (CASE WHEN bill.intTransactionType = 1 THEN 1 ELSE -1 END) AS DECIMAL(18,4)) AS dblVoucherQty
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
INNER JOIN (tblGRCustomerStorage CS 
		INNER JOIN tblGRStorageType STY 
			ON STY.intStorageScheduleTypeId  = CS.intStorageTypeId AND STY.ysnDPOwnedType = 0
		INNER JOIN tblGRSettleStorageTicket SST
			ON SST.intCustomerStorageId = CS.intCustomerStorageId
		INNER JOIN tblGRSettleStorage SS
			ON SST.intSettleStorageId = SS.intSettleStorageId 
				AND SS.intParentSettleStorageId IS NOT NULL
				--AND SS.dblSpotUnits = 0
				)
	ON billDetail.intCustomerStorageId = CS.intCustomerStorageId AND billDetail.intItemId = CS.intItemId
		and billDetail.intSettleStorageId = SS.intSettleStorageId
		--AND SS.intBillId = bill.intBillId
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
LEFT JOIN tblGRSettleContract ST
	ON ST.intSettleStorageId = SS.intSettleStorageId --AND ST.intContractDetailId = billDetail.intContractDetailId
LEFT JOIN tblCTContractDetail CT
	ON CT.intContractDetailId = ST.intContractDetailId
left join tblCTContractHeader CH
		on CH.intContractHeaderId = CT.intContractHeaderId
WHERE bill.ysnPosted = 1
AND glAccnt.intAccountCategoryId = 45
------- Charges
--and SS.strStorageTicket = 'STR-1729/1'
UNION ALL

SELECT DISTINCT --'c',
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
	,CAST(CASE WHEN SS.dblSettleUnits != 0 THEN  -SS.dblSettleUnits ELSE -SS.dblUnpaidUnits END AS DECIMAL(18,2))
	,CS.intCompanyLocationId
	,CL.strLocationName
	,0
	,GD.intAccountId
	,AD.strAccountId
FROM tblGRCustomerStorage CS
INNER JOIN tblGRStorageType STY
	ON STY.intStorageScheduleTypeId = CS.intStorageTypeId
		AND STY.ysnDPOwnedType = 0
INNER JOIN tblGRSettleStorageTicket SST
	ON SST.intCustomerStorageId = CS.intCustomerStorageId
INNER JOIN tblGRSettleStorage SS
	ON SST.intSettleStorageId = SS.intSettleStorageId
		AND SS.intParentSettleStorageId IS NOT NULL
		--AND SS.dblSpotUnits = 0

INNER JOIN tblGLDetail GD
 	ON GD.strTransactionId = SS.strStorageTicket
 		AND GD.intTransactionId = SS.intSettleStorageId
 		AND GD.ysnIsUnposted = 0
		AND GD.strCode = 'STR'
INNER JOIN vyuGLAccountDetail AD
	on AD.intAccountId = GD.intAccountId and AD.intAccountCategoryId = 45
INNER JOIN tblICCommodity CO
	ON CO.intCommodityId = CS.intCommodityId
INNER JOIN tblICItem IM
	ON IM.strType = 'Other Charge' 
		AND IM.strCostType = 'Storage Charge' 
		AND (IM.intCommodityId = CO.intCommodityId OR isnull(IM.intCommodityId, 0) = 0)
		-- AND GD.strDescription LIKE '%Charges from ' + IM.strItemNo
		AND IM.strItemNo = REPLACE(SUBSTRING(GD.strDescription, CHARINDEX('Charges from ', GD.strDescription), LEN(GD.strDescription) -1),'Charges from ','')
INNER JOIN tblSMCompanyLocation CL
	ON CL.intCompanyLocationId = CS.intCompanyLocationId
	
LEFT JOIN 
(
    tblICItemUOM itemUOM INNER JOIN tblICUnitMeasure unitMeasure
        ON itemUOM.intUnitMeasureId = unitMeasure.intUnitMeasureId
)
    ON itemUOM.intItemUOMId = CS.intItemUOMId
LEFT JOIN tblGRSettleContract ST
	ON ST.intSettleStorageId = SS.intSettleStorageId
LEFT JOIN tblCTContractDetail CT
	ON CT.intContractDetailId = ST.intContractDetailId
left join tblCTContractHeader CH
		on CH.intContractHeaderId = CT.intContractHeaderId
OUTER APPLY (
	SELECT ysnReversed = CASE 
							WHEN strComments IN ('Added from data fix to offset the orphan records; GRN-2513','GRN-2741-REVERSAL') THEN 1
							WHEN strComments = 'Added from data fix to create STR GL entries for manually added items in voucher; GRN-2513' THEN 0
						END
	FROM tblGLDetail 
	WHERE strTransactionId = SS.strStorageTicket
		AND intTransactionId = SS.intSettleStorageId
		AND strTransactionType = 'Storage Settlement'
		AND ysnIsUnposted = 0
		AND strComments IN ('Added from data fix to offset the orphan records; GRN-2513','Added from data fix to create STR GL entries for manually added items in voucher; GRN-2513','GRN-2741-REVERSAL')
		AND strDescription = GD.strDescription
) GL
WHERE SS.ysnPosted = 1
--and SS.strStorageTicket = 'STR-4248/1'
AND ISNULL(GL.ysnReversed,0) = 0
UNION ALL
SELECT DISTINCT --'d',
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
	,billDetail.dblTotal * (CASE WHEN bill.intTransactionType = 1 THEN 1 ELSE -1 END) AS dblVoucherTotal
    ,CAST(CASE 
		WHEN billDetail.intWeightUOMId IS NULL THEN 
			ISNULL(billDetail.dblQtyReceived, 0) 
		ELSE 
			CASE 
			WHEN ISNULL(billDetail.dblNetWeight, 0) = 0 THEN 
				ISNULL(dbo.fnCalculateQtyBetweenUOM(billDetail.intUnitOfMeasureId, billDetail.intWeightUOMId, ISNULL(billDetail.dblQtyReceived, 0)), 0)
			ELSE 
				ISNULL(billDetail.dblNetWeight, 0) 
		END
		END * (CASE WHEN bill.intTransactionType = 1 THEN 1 ELSE -1 END) AS DECIMAL(18,2)) AS dblVoucherQty
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
INNER JOIN (tblGRCustomerStorage CS
		INNER JOIN tblGRStorageType STY 
			ON STY.intStorageScheduleTypeId  = CS.intStorageTypeId 
				AND STY.ysnDPOwnedType = 0
		INNER JOIN tblGRSettleStorageTicket SST
			ON SST.intCustomerStorageId = CS.intCustomerStorageId
		INNER JOIN tblGRSettleStorage SS
			ON SST.intSettleStorageId = SS.intSettleStorageId 
				AND SS.intParentSettleStorageId IS NOT NULL
				--AND SS.dblSpotUnits = 0
		INNER JOIN tblICCommodity CO
			ON CO.intCommodityId = CS.intCommodityId
		INNER JOIN tblICItem IM
			ON IM.strType = 'Other Charge' 
				AND IM.strCostType = 'Storage Charge' 
				AND (IM.intCommodityId = CO.intCommodityId OR isnull(IM.intCommodityId, 0) = 0))
	ON billDetail.intCustomerStorageId = CS.intCustomerStorageId AND billDetail.intItemId = IM.intItemId
		and billDetail.intSettleStorageId = SS.intSettleStorageId
	--AND SS.intBillId = bill.intBillId
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
LEFT JOIN tblGRSettleContract ST
	ON ST.intSettleStorageId = SS.intSettleStorageId
LEFT JOIN tblCTContractDetail CT
	ON CT.intContractDetailId = ST.intContractDetailId
left join tblCTContractHeader CH
		on CH.intContractHeaderId = CT.intContractHeaderId

WHERE bill.ysnPosted = 1
--AND SS.strStorageTicket = 'STR-49/3'
AND glAccnt.intAccountCategoryId = 45
--and SS.strStorageTicket = 'STR-1729/1'
--AND (CH.intContractHeaderId is null or (CH.intContractHeaderId is not null and CH.intPricingTypeId = 2))
--DISCOUNTS
UNION ALL
SELECT DISTINCT --'e',
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
	,CAST((CASE
		WHEN QM.strDiscountChargeType = 'Percent' AND QM.dblDiscountAmount < 0 
			THEN ((QM.dblDiscountAmount * (CASE WHEN ISNULL(SS.dblCashPrice,0) > 0 THEN SS.dblCashPrice ELSE CD.dblCashPrice END) * -1))
		WHEN QM.strDiscountChargeType = 'Percent' AND QM.dblDiscountAmount > 0 
			THEN ((QM.dblDiscountAmount * (CASE WHEN ISNULL(SS.dblCashPrice,0) > 0 THEN SS.dblCashPrice ELSE CD.dblCashPrice END)) *  -1)
		WHEN QM.strDiscountChargeType = 'Dollar' THEN QM.dblDiscountAmount
	END 
	* (CASE 
		WHEN QM.strCalcMethod = 3 
			THEN (CS.dblGrossQuantity * (SST.dblUnits / CS.dblOriginalBalance))	
		ELSE SST.dblUnits 
	END) * -1) AS DECIMAL(18,2))
	,ROUND(((CASE WHEN QM.strCalcMethod = 3 
		THEN (CS.dblGrossQuantity * (SST.dblUnits / CS.dblOriginalBalance))--@dblGrossUnits 
	ELSE SST.dblUnits END * (CASE WHEN QM.dblDiscountAmount > 0 THEN 1 ELSE -1 END)) ) * -1, 2)--+ ISNULL(ADJ.dblUnits,0)) * -1, 2)
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
INNER JOIN tblGRStorageType STY
	ON STY.intStorageScheduleTypeId = CS.intStorageTypeId
		AND STY.ysnDPOwnedType = 0
INNER JOIN tblICItem IM
	ON DSC.intItemId = IM.intItemId
INNER JOIN tblGRDiscountSchedule DS
	ON DS.intDiscountScheduleId = DSC.intDiscountScheduleId
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
left join tblCTContractHeader CH
		on CH.intContractHeaderId = CD.intContractHeaderId

LEFT JOIN 
(
    tblICItemUOM itemUOM INNER JOIN tblICUnitMeasure unitMeasure
        ON itemUOM.intUnitMeasureId = unitMeasure.intUnitMeasureId
)
    ON itemUOM.intItemUOMId = CS.intItemUOMId
OUTER APPLY
(
	SELECT GD.intAccountId, AD.strAccountId, GD.strDescription
	FROM tblGLDetail GD
	INNER JOIN vyuGLAccountDetail AD
		ON GD.intAccountId = AD.intAccountId AND AD.intAccountCategoryId = 45
	WHERE GD.strTransactionId = SS.strStorageTicket
		AND GD.intTransactionId = SS.intSettleStorageId
		AND GD.strCode = 'STR'
		AND IM.strItemNo = REPLACE(SUBSTRING(GD.strDescription, CHARINDEX('Charges from ', GD.strDescription), LEN(GD.strDescription) -1),'Charges from ','')
		AND GD.ysnIsUnposted = 0
) GLDetail
OUTER APPLY (
	SELECT ysnReversed = 1
	FROM tblGLDetail 
	WHERE strTransactionId = SS.strStorageTicket
		AND intTransactionId = SS.intSettleStorageId
		AND strTransactionType = 'Storage Settlement'
		AND ysnIsUnposted = 0
		AND strComments IN ('Added from data fix to offset the orphan records; GRN-2513','GRN-2741-REVERSAL')
		AND strDescription = GLDetail.strDescription
) GL
WHERE 
	QM.strSourceType = 'Storage' 
AND QM.dblDiscountDue <> 0
AND SS.ysnPosted = 1
AND GLDetail.intAccountId IS NOT NULL
--AND SS.strStorageTicket = 'STR-5175/1'
AND GL.ysnReversed IS NULL

--and SS.strStorageTicket = 'STR-1729/1'
UNION ALL
SELECT DISTINCT --'f',
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
	--use the storage data to  handle cost adjustment
	-- ,CAST(CASE
	-- 	WHEN QM.strDiscountChargeType = 'Percent' AND QM.dblDiscountAmount < 0 
	-- 	THEN (QM.dblDiscountAmount * (CASE WHEN ISNULL(SS.dblCashPrice,0) > 0 THEN SS.dblCashPrice ELSE CD.dblCashPrice END) * -1)
	-- 	WHEN QM.strDiscountChargeType = 'Percent' AND QM.dblDiscountAmount > 0 THEN (QM.dblDiscountAmount * (CASE WHEN ISNULL(SS.dblCashPrice,0) > 0 THEN SS.dblCashPrice ELSE CD.dblCashPrice END)) *  -1
	-- 	WHEN QM.strDiscountChargeType = 'Dollar' AND QM.dblDiscountAmount < 0 THEN (QM.dblDiscountAmount)
	-- 	WHEN QM.strDiscountChargeType = 'Dollar' AND QM.dblDiscountAmount > 0 THEN (QM.dblDiscountAmount * -1)
	-- END * (CASE WHEN QM.strCalcMethod = 3 THEN CS.dblGrossQuantity ELSE SST.dblUnits END) AS DECIMAL(18,2))
    ,ROUND((CASE 
		WHEN billDetail.intWeightUOMId IS NULL THEN 
			ISNULL(billDetail.dblQtyReceived, 0) 
		ELSE 
			CASE 
			WHEN ISNULL(billDetail.dblNetWeight, 0) = 0 THEN 
				ISNULL(dbo.fnCalculateQtyBetweenUOM(billDetail.intUnitOfMeasureId, billDetail.intWeightUOMId, ISNULL(billDetail.dblQtyReceived, 0)), 0)
			ELSE 
				ISNULL(billDetail.dblNetWeight, 0) 
		END
		END) * (CASE WHEN bill.intTransactionType = 1 THEN 1 ELSE -1 END), 2) AS dblVoucherQty
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
INNER JOIN (tblGRCustomerStorage CS 
			INNER JOIN tblGRStorageType STY 
				ON STY.intStorageScheduleTypeId  = CS.intStorageTypeId 
					AND STY.ysnDPOwnedType = 0
			INNER JOIN tblGRSettleStorageTicket SST
				ON SST.intCustomerStorageId = CS.intCustomerStorageId
			INNER JOIN tblGRSettleStorage SS
				ON SST.intSettleStorageId = SS.intSettleStorageId
					AND SS.intParentSettleStorageId IS NOT NULL
					--AND SS.dblSpotUnits = 0
			-- INNER JOIN tblQMTicketDiscount QM
			-- 	ON QM.intTicketFileId = CS.intCustomerStorageId
			-- LEFT JOIN tblGRSettleContract SC
			-- 	ON SC.intSettleStorageId = SS.intSettleStorageId
			-- LEFT JOIN tblCTContractDetail CD
			-- 	ON CD.intContractDetailId = SC.intContractDetailId
			)
	ON CS.intCustomerStorageId = billDetail.intCustomerStorageId
		and billDetail.intSettleStorageId = SS.intSettleStorageId
	--AND SS.intBillId = bill.intBillId
	-- AND CD.intContractDetailId = billDetail.intContractDetailId
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
LEFT JOIN tblGRSettleContract ST
	ON ST.intSettleStorageId = SS.intSettleStorageId
LEFT JOIN tblCTContractDetail CT
	ON CT.intContractDetailId = ST.intContractDetailId
left join tblCTContractHeader CH
		on CH.intContractHeaderId = CT.intContractHeaderId
OUTER APPLY (
	SELECT TOP 1 [ysnDiscountExists] = 1
	FROM tblQMTicketDiscount QM
	INNER JOIN tblGRDiscountScheduleCode DSC
		ON DSC.intDiscountScheduleCodeId = QM.intDiscountScheduleCodeId
		AND DSC.intItemId = billDetail.intItemId
		AND billDetail.intCustomerStorageId = QM.intTicketFileId
) QM
WHERE bill.ysnPosted = 1
AND QM.ysnDiscountExists = 1
AND glAccnt.intAccountCategoryId = 45