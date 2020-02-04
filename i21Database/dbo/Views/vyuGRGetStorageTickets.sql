CREATE VIEW [dbo].[vyuGRGetStorageTickets]  
AS  
SELECT DISTINCT
    intCustomerStorageId				= CS.intCustomerStorageId  
    ,strStorageTicketNumber				= CS.strStorageTicketNumber
    ,intEntityId						= CS.intEntityId  
    ,strName							= E.strName  
    ,intStorageTypeId					= CS.intStorageTypeId  
    ,strStorageTypeDescription			= ST.strStorageTypeDescription
    ,ysnCustomerStorage					= ST.ysnCustomerStorage
    ,intStorageScheduleId				= CS.intStorageScheduleId
    ,strScheduleId						= SR.strScheduleId
    ,intItemId							= CS.intItemId
    ,strItemNo							= Item.strItemNo   
    ,intCompanyLocationId				= CS.intCompanyLocationId  
    ,strLocationName					= LOC.strLocationName
    ,intCompanyLocationSubLocationId	= ISNULL(CS.intCompanyLocationSubLocationId,0)
    ,strSubLocationName					= ISNULL(SLOC.strSubLocationName,'')
    ,dtmDeliveryDate					= CS.dtmDeliveryDate  
    ,strDPARecieptNumber				= ISNULL(CS.strDPARecieptNumber,'')
    ,dblOpenBalance						= ROUND(dbo.fnCTConvertQtyToTargetItemUOM(CS.intItemUOMId, ItemUOM.intItemUOMId, CS.dblOpenBalance), 6)
    ,ysnDPOwnedType						= ST.ysnDPOwnedType
    ,intContractHeaderId                = case when (CS.intStorageTypeId = 2 and GHistory.intContractHeaderId is not null) then GHistory.intContractHeaderId else CASE WHEN CS.ysnTransferStorage = 0 THEN CH_Ticket.intContractHeaderId ELSE CH_Transfer.intContractHeaderId END end
    ,intContractDetailId				= case when (CS.intStorageTypeId = 2 and GHistory.intContractDetailId is not null) then GHistory.intContractDetailId else CASE WHEN CS.ysnTransferStorage = 0 THEN SC.intContractId ELSE CD_Transfer.intContractDetailId END end
    ,strContractNumber					= case when (CS.intStorageTypeId = 2 and GHistory.intContractHeaderId is not null) then GHistory.strContractNumber else CASE WHEN CS.ysnTransferStorage = 0 THEN CH_Ticket.strContractNumber ELSE CH_Transfer.strContractNumber END end
    ,intTicketId						= ISNULL(SC.intTicketId,0)
    ,dblDiscountUnPaid					= ISNULL(dblDiscountsDue,0) - ISNULL(dblDiscountsPaid,0)
    ,dblStorageUnPaid					= ISNULL(dblStorageDue,0) - ISNULL(dblStoragePaid,0)
    ,strReceiptNumber					= IR.strReceiptNumber
    ,ysnReadyForTransfer				= CAST(
											CASE 
												WHEN DS.ysnPost = 1 THEN 1
												WHEN CS.intTicketId IS NOT NULL THEN 1
												ELSE 0
											END AS BIT
										)
    ,ysnShowInStorage			        = CAST(
                                            CASE
                                                WHEN ST.ysnCustomerStorage = 0 THEN 1
                                                WHEN ST.ysnCustomerStorage = 1 AND ST.strOwnedPhysicalStock = 'Customer' THEN 1
                                                ELSE 0
                                            END AS BIT
                                        )
FROM tblGRCustomerStorage CS  
JOIN tblGRStorageType ST 
    ON ST.intStorageScheduleTypeId = CS.intStorageTypeId  
JOIN tblSMCompanyLocation LOC 
    ON LOC.intCompanyLocationId = CS.intCompanyLocationId  
JOIN tblEMEntity E 
    ON E.intEntityId = CS.intEntityId
JOIN tblGRStorageScheduleRule SR 
    ON SR.intStorageScheduleRuleId = CS.intStorageScheduleId
JOIN tblICItem Item 
    ON Item.intItemId = CS.intItemId
JOIN tblICItemUOM ItemUOM
	ON ItemUOM.intItemId = Item.intItemId
		AND ItemUOM.ysnStockUnit = 1
LEFT JOIN tblSMCompanyLocationSubLocation SLOC 
    ON SLOC.intCompanyLocationSubLocationId = CS.intCompanyLocationSubLocationId
LEFT JOIN 
(
    SELECT 
		GSH.intCustomerStorageId
		,GCH.intContractHeaderId
		,GCH.strContractNumber
		,GCD.intContractDetailId 
	FROM tblGRStorageHistory GSH
	INNER JOIN tblCTContractHeader GCH
		ON GCH.intContractHeaderId = GSH.intContractHeaderId
	INNER JOIN tblCTContractDetail GCD
		ON GCH.intContractHeaderId = GCD.intContractHeaderId
	WHERE GSH.strType IN ('From Transfer','From Delivery Sheet','From Scale')
)GHistory
    on GHistory.intCustomerStorageId = CS.intCustomerStorageId 
        and CS.intStorageTypeId = 2
LEFT JOIN tblSCTicket SC
	ON SC.intTicketId = CS.intTicketId
LEFT JOIN tblCTContractDetail CD_Ticket
    ON CD_Ticket.intContractDetailId = SC.intContractId
		AND CS.ysnTransferStorage = 0
LEFT JOIN tblCTContractHeader CH_Ticket 
    ON CH_Ticket.intContractHeaderId = CD_Ticket.intContractHeaderId
LEFT JOIN tblGRTransferStorageSplit TSS
	ON TSS.intTransferToCustomerStorageId = CS.intCustomerStorageId
LEFT JOIN tblCTContractDetail CD_Transfer
    ON CD_Transfer.intContractDetailId = TSS.intContractDetailId
		AND CS.ysnTransferStorage = 1
LEFT JOIN tblCTContractHeader CH_Transfer
    ON CH_Transfer.intContractHeaderId = CD_Transfer.intContractHeaderId  
LEFT JOIN tblICInventoryReceipt IR 
    ON IR.intInventoryReceiptId = SC.intInventoryReceiptId
LEFT JOIN tblSCDeliverySheet DS
    ON DS.intDeliverySheetId = CS.intDeliverySheetId
WHERE CS.dblOpenBalance > 0