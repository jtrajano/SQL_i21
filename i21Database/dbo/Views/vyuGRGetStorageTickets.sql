CREATE VIEW [dbo].[vyuGRGetStorageTickets]  
AS  
SELECT TOP 100 PERCENT   
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
    ,dblOpenBalance						= dbo.fnCTConvertQtyToTargetItemUOM(CS.intItemUOMId, ItemUOM.intItemUOMId, CS.dblOpenBalance)  
    ,ysnDPOwnedType						= ST.ysnDPOwnedType
    ,intContractHeaderId				= SC.intContractId
    ,strContractNumber					= CH.strContractNumber   
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
LEFT JOIN tblSCTicket SC
	ON SC.intTicketId = CS.intTicketId
LEFT JOIN tblCTContractHeader CH 
    ON CH.intContractHeaderId = SC.intContractId  
LEFT JOIN tblICInventoryReceipt IR 
    ON IR.intInventoryReceiptId = SC.intInventoryReceiptId
LEFT JOIN tblSCDeliverySheet DS
    ON DS.intDeliverySheetId = CS.intDeliverySheetId
WHERE CS.dblOpenBalance > 0 
    AND ISNULL(CS.strStorageType,'') <> 'ITR'
ORDER BY CS.dtmDeliveryDate