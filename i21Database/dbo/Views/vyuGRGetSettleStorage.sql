CREATE VIEW [dbo].[vyuGRGetSettleStorage]
AS     
SELECT DISTINCT
	 intSettleStorageId			= SS.intSettleStorageId
	,intEntityId				= SS.intEntityId
	,strEntityName				= E.strName
	,intCompanyLocationId		= SS.intCompanyLocationId
	,strLocationName			= ISNULL(L.strLocationName, 'Multi')
	,intItemId					= SS.intItemId
	,strItemNo					= Item.strItemNo
	,dblSpotUnits				= SS.dblSpotUnits
	,dblFuturesPrice			= SS.dblFuturesPrice
	,dblFuturesBasis			= SS.dblFuturesBasis
	,dblCashPrice				= CASE 
									WHEN ISNULL(_dblCashPrice.dblCashPrice,0) > 0 THEN _dblCashPrice.dblCashPrice
									ELSE
										CASE 
											WHEN SS.intParentSettleStorageId IS NOT NULL THEN SS.dblCashPrice
											ELSE 0
										END
								END
	,strStorageAdjustment		= SS.strStorageAdjustment
	,dtmCalculateStorageThrough = SS.dtmCalculateStorageThrough
	,dblAdjustPerUnit			= SS.dblAdjustPerUnit
	,dblStorageDue				= SS.dblStorageDue
	,strStorageTicket			= SS.strStorageTicket
	,dblSelectedUnits			= SS.dblSelectedUnits
	,dblUnpaidUnits				= SS.dblUnpaidUnits
	,dblSettleUnits				= SS.dblSettleUnits
	,dblDiscountsDue			= SS.dblDiscountsDue
	,dblNetSettlement			= SS.dblNetSettlement
	,intCreatedUserId			= SS.intCreatedUserId
	,strUserName				= Entity.strUserName
	,dtmCreated					= SS.dtmCreated
	,ysnPosted					= SS.ysnPosted
	,intBillId					= SS.intBillId
	,strBillId					= ISNULL(Bill.strBillId,'')
	,strContractIds				= _strContractIds.strContractIds
	,strContractNumbers         = STUFF(_strContractNumbers.strContractNumbers,1,1,'') 
	,strUnits                   = (CONVERT(VARCHAR(MAX), dbo.fnRemoveTrailingZeroes(dbo.fnCTConvertQtyToTargetItemUOM(ISNULL(SS.intItemUOMId, CS.intItemUOMId), ItemUOM.intItemUOMId, SS.dblSettleUnits))) + ' ' + UOM.strSymbol) COLLATE Latin1_General_CI_AS
	,intTransactionId			= CASE 
									WHEN SS.intParentSettleStorageId IS NULL THEN 99999999
									ELSE
										CASE
											WHEN CS.intDeliverySheetId IS NOT NULL AND CS.ysnTransferStorage = 0 THEN CS.intDeliverySheetId
											WHEN CS.intTicketId IS NOT NULL AND CS.ysnTransferStorage = 0 THEN CS.intTicketId
											ELSE TSS.intTransferStorageId
										END
								END
	,strTransactionNumber		= CASE 
									WHEN SS.intParentSettleStorageId IS NULL THEN ''
									ELSE
										CASE
											WHEN CS.intDeliverySheetId IS NOT NULL AND CS.ysnTransferStorage = 0 THEN DeliverySheet.strDeliverySheetNumber
											WHEN CS.intTicketId IS NOT NULL AND CS.ysnTransferStorage = 0 THEN SC.strTicketNumber
											ELSE TS.strTransferStorageTicket
										END
								END COLLATE Latin1_General_CI_AS
	,strTransactionCode			= CASE 
									WHEN SS.intParentSettleStorageId IS NULL THEN ''
									ELSE
										CASE
											WHEN CS.intDeliverySheetId IS NOT NULL AND CS.ysnTransferStorage = 0 THEN 'DS' --DELIVERY SHEET
											WHEN CS.intTicketId IS NOT NULL AND CS.ysnTransferStorage = 0 THEN 'SC' --SCALE TICKET
											ELSE 'TS' --TRANSFER STORAGE
										END
								END COLLATE Latin1_General_CI_AS
	, strCommodityCode
	, strCategoryCode			= Category.strCategoryCode
FROM tblGRSettleStorage SS
JOIN tblGRSettleStorageTicket ST
	ON ST.intSettleStorageId = SS.intSettleStorageId
JOIN tblGRCustomerStorage CS
	ON CS.intCustomerStorageId = ST.intCustomerStorageId
JOIN tblEMEntity E 
	ON E.intEntityId = SS.intEntityId
JOIN ( tblICItem Item 
		INNER JOIN tblICItemUOM ItemUOM
			ON ItemUOM.intItemId = Item.intItemId
				AND ItemUOM.ysnStockUnit = 1
		INNER JOIN tblICUnitMeasure UOM
			ON UOM.intUnitMeasureId = ItemUOM.intUnitMeasureId
	) ON Item.intItemId = SS.intItemId
JOIN tblICCommodity Commodity
	ON Item.intCommodityId = Commodity.intCommodityId
JOIN tblICCategory Category
	ON Item.intCategoryId = Category.intCategoryId
JOIN tblSMUserSecurity Entity 
	ON Entity.intEntityId = SS.intCreatedUserId
LEFT JOIN tblSMCompanyLocation L 
	ON L.intCompanyLocationId = SS.intCompanyLocationId
LEFT JOIN tblAPBill Bill 
	ON Bill.intBillId = SS.intBillId
LEFT JOIN tblSCTicket SC
	ON SC.intTicketId = CS.intTicketId
LEFT JOIN (tblSCDeliverySheet DeliverySheet 
			INNER JOIN tblSCDeliverySheetSplit DSS	
				ON DSS.intDeliverySheetId = DeliverySheet.intDeliverySheetId
		) ON DeliverySheet.intDeliverySheetId = CS.intDeliverySheetId
			AND DSS.intEntityId = E.intEntityId
			AND DSS.intStorageScheduleTypeId = CS.intStorageTypeId
            AND DSS.intStorageScheduleRuleId = CS.intStorageScheduleId
LEFT JOIN (tblGRTransferStorageSplit TSS
			INNER JOIN tblGRTransferStorage TS
				ON TS.intTransferStorageId = TSS.intTransferStorageId
		) ON TSS.intTransferToCustomerStorageId = CS.intCustomerStorageId
CROSS APPLY (
	SELECT (
		SELECT ',' + (CH.strContractNumber + '-' + CONVERT(VARCHAR(20), CD.intContractSeq))
		FROM tblCTContractDetail CD
		INNER JOIN tblGRSettleContract SC
			ON CD.intContractDetailId = SC.intContractDetailId
				AND SC.intSettleStorageId = SS.intSettleStorageId
		INNER JOIN tblCTContractHeader CH
			ON CH.intContractHeaderId = CD.intContractHeaderId
		WHERE SS.intParentSettleStorageId IS NOT NULL
			AND CASE WHEN (CD.intPricingTypeId = 2 AND (CD.dblTotalCost = 0)) THEN 0 ELSE 1 END = 1
		FOR XML PATH('')) COLLATE Latin1_General_CI_AS as strContractNumbers
) AS _strContractNumbers
CROSS APPLY (
	SELECT (
		SELECT CONVERT(VARCHAR(20), CH.intContractHeaderId) + '|^|'
		FROM tblCTContractDetail CD
		INNER JOIN tblGRSettleContract SC
			ON CD.intContractDetailId = SC.intContractDetailId
				AND SC.intSettleStorageId = SS.intSettleStorageId
		INNER JOIN tblCTContractHeader CH
			ON CH.intContractHeaderId = CD.intContractHeaderId
		WHERE SS.intParentSettleStorageId IS NOT NULL
			AND CASE WHEN (CD.intPricingTypeId = 2 AND (CD.dblTotalCost = 0)) THEN 0 ELSE 1 END = 1
		FOR XML PATH('')) COLLATE Latin1_General_CI_AS as strContractIds
) AS _strContractIds
OUTER APPLY (
	SELECT 
		SUM(CD.dblCashPrice) AS dblCashPrice
	FROM tblCTContractDetail CD
	INNER JOIN tblGRSettleContract SC
		ON CD.intContractDetailId = SC.intContractDetailId
			AND SC.intSettleStorageId = SS.intSettleStorageId
	INNER JOIN tblCTContractHeader CH
		ON CH.intContractHeaderId = CD.intContractHeaderId
	WHERE SS.intParentSettleStorageId IS NOT NULL
		AND CD.intPricingTypeId <> 2
) AS _dblCashPrice