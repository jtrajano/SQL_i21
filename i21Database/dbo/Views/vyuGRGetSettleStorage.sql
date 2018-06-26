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
,intContractId				= SH.intContractHeaderId
,strContractNumber			= CASE WHEN SC.intContractId IS NOT NULL AND SC.intTicketId IS NOT NULL
										THEN CH.strContractNumber + '-' + CONVERT(VARCHAR(MAX),SC.intContractSequence)
							ELSE
									CASE WHEN SC.intContractId IS NULL AND SC.intTicketId IS NOT NULL
											THEN CH.strContractNumber + '-' + CONVERT(VARCHAR(MAX),CD.intContractSeq)
									END
							END
,intTicketId				= SC.intTicketId
,strTicketNumber			= SC.strTicketNumber
,strUnits					= CONVERT(VARCHAR(MAX),dbo.fnRemoveTrailingZeroes(T.dblUnits)) + ' ' + UOM.strSymbol
FROM tblGRSettleStorage SS
JOIN tblEMEntity E 
	ON E.intEntityId = SS.intEntityId
LEFT JOIN tblSMCompanyLocation L 
	ON L.intCompanyLocationId = SS.intCompanyLocationId  
JOIN tblICItem Item 
	ON Item.intItemId = SS.intItemId
LEFT JOIN tblICItemUOM ItemUOM 
	ON SS.intItemId = ItemUOM.intItemId 
		AND ItemUOM.ysnStockUOM = 1
LEFT JOIN tblICUnitMeasure UOM 
	ON ItemUOM.intUnitMeasureId = UOM.intUnitMeasureId
JOIN tblSMUserSecurity Entity 
	ON Entity.intEntityId = SS.intCreatedUserId
LEFT JOIN tblAPBill Bill 
	ON Bill.intBillId = SS.intBillId
LEFT JOIN tblGRSettleStorageTicket T 
	ON T.intSettleStorageId = SS.intSettleStorageId 
		AND SS.intParentSettleStorageId IS NOT NULL
LEFT JOIN tblGRCustomerStorage CS 
	ON T.intCustomerStorageId = CS.intCustomerStorageId
LEFT JOIN tblGRStorageHistory SH 
	ON CS.intCustomerStorageId = SH.intCustomerStorageId 
		AND SH.intSettleStorageId IS NOT NULL
LEFT JOIN tblGRSettleContract SCT
	ON SS.intSettleStorageId = SCT.intSettleStorageId
LEFT JOIN tblCTContractDetail CD 
	ON SCT.intContractDetailId = CD.intContractDetailId
LEFT JOIN tblSCTicket SC				
	ON SC.intTicketId = CS.intTicketId
LEFT JOIN tblCTContractHeader CH 
	ON CH.intContractHeaderId = ISNULL(SC.intContractId, CD.intContractHeaderId)
