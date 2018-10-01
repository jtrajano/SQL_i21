﻿CREATE VIEW [dbo].[vyuGRGetSettleStorage]
AS     
SELECT 
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
	,dblCashPrice				= SS.dblCashPrice
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
	,strContractNumbers          = STUFF(_strContractNumbers.strContractNumbers,1,1,'') 
	,strUnits                   = CONVERT(VARCHAR(MAX), dbo.fnRemoveTrailingZeroes(dbo.fnCTConvertQtyToTargetItemUOM(ISNULL(SS.intItemUOMId, CS.intItemUOMId), ItemUOM.intItemUOMId, ST.dblUnits))) + ' ' + UOM.strSymbol
	,intTicketId				= ISNULL(CS.intTicketId, CS.intDeliverySheetId)
	,strTicketNumber			= CASE
									WHEN CS.intTicketId IS NOT NULL THEN (SELECT strTicketNumber FROM tblSCTicket WHERE intTicketId = CS.intTicketId)
									ELSE (SELECT strDeliverySheetNumber FROM tblSCDeliverySheet WHERE intDeliverySheetId = CS.intDeliverySheetId)
								END
	,ysnIsScaleTicket			= CAST(CASE WHEN CS.intTicketId IS NOT NULL THEN 1 ELSE 0 END AS BIT)
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
JOIN tblSMUserSecurity Entity 
	ON Entity.intEntityId = SS.intCreatedUserId
LEFT JOIN tblSMCompanyLocation L 
	ON L.intCompanyLocationId = SS.intCompanyLocationId
LEFT JOIN tblAPBill Bill 
	ON Bill.intBillId = SS.intBillId
CROSS APPLY (
	SELECT strContractNumbers = (
		SELECT ',' + (CH.strContractNumber + '-' + CONVERT(VARCHAR(20), CD.intContractSeq))
		FROM tblCTContractDetail CD
		INNER JOIN tblGRSettleContract SC
			ON CD.intContractDetailId = SC.intContractDetailId
				AND SC.intSettleStorageId = SS.intSettleStorageId
		INNER JOIN tblCTContractHeader CH
			ON CH.intContractHeaderId = CD.intContractHeaderId
		WHERE SS.intParentSettleStorageId IS NOT NULL
		FOR XML PATH(''))
) AS _strContractNumbers
CROSS APPLY (
	SELECT strContractIds = (
		SELECT CONVERT(VARCHAR(20), CH.intContractHeaderId) + '|^|'
		FROM tblCTContractDetail CD
		INNER JOIN tblGRSettleContract SC
			ON CD.intContractDetailId = SC.intContractDetailId
				AND SC.intSettleStorageId = SS.intSettleStorageId
		INNER JOIN tblCTContractHeader CH
			ON CH.intContractHeaderId = CD.intContractHeaderId
		WHERE SS.intParentSettleStorageId IS NOT NULL
		FOR XML PATH(''))
) AS _strContractIds
