CREATE VIEW [dbo].[vyuGRGetStorageTicketsFromDPLoadOut]  
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
    ,intContractHeaderId                = GHistory.intContractHeaderId
    ,intContractDetailId				= GHistory.intContractDetailId
    ,strContractNumber					= GHistory.strContractNumber
    ,intTicketId						= SC.intTicketId
    ,dblDiscountUnPaid					= ISNULL(dblDiscountsDue,0) - ISNULL(dblDiscountsPaid,0)
    ,dblStorageUnPaid					= ISNULL(dblStorageDue,0) - ISNULL(dblStoragePaid,0)
    ,strShipmentNumber					= _IS.strShipmentNumber
    ,ysnShowInStorage			        = CAST(
                                            CASE
                                                WHEN ST.ysnCustomerStorage = 0 THEN 1
                                                WHEN ST.ysnCustomerStorage = 1 AND ST.strOwnedPhysicalStock = 'Customer' THEN 1
                                                ELSE 0
                                            END AS BIT
                                        )
    ,CAP.intChargeAndPremiumId
	,CAP.strChargeAndPremiumId
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
LEFT JOIN tblGRChargeAndPremiumId CAP
	ON CAP.intChargeAndPremiumId = CS.intChargeAndPremiumId
LEFT JOIN tblSMCompanyLocationSubLocation SLOC 
    ON SLOC.intCompanyLocationSubLocationId = CS.intCompanyLocationSubLocationId
JOIN 
(
    SELECT 
		GSH.intCustomerStorageId
		,GCH.intContractHeaderId
		,GCH.strContractNumber
		,GCD.intContractDetailId 
	FROM tblGRStorageHistory GSH
	INNER JOIN tblCTContractHeader GCH
		ON GCH.intContractHeaderId = GSH.intContractHeaderId
			and GCH.intPricingTypeId = 5
	INNER JOIN tblCTContractDetail GCD
		ON GCH.intContractHeaderId = GCD.intContractHeaderId
			and GCD.intPricingTypeId = 5
	WHERE GSH.strType IN ('From Scale')		
)GHistory
    on GHistory.intCustomerStorageId = CS.intCustomerStorageId
		AND ST.ysnDPOwnedType = 1
JOIN (
	tblSCTicket SC 		
	JOIN tblGRStorageHistory SH
		ON SH.intTicketId = SC.intTicketId
	JOIN tblICInventoryShipmentItem ISI
		ON ISI.intInventoryShipmentId = SH.intInventoryShipmentId
	) 
	ON SC.intTicketId = CS.intTicketId
		AND SH.intCustomerStorageId = CS.intCustomerStorageId
LEFT JOIN tblCTContractDetail CD_Ticket
    --ON CD_Ticket.intContractDetailId = SC.intContractId
	ON CD_Ticket.intContractDetailId = ISI.intItemContractDetailId
		and CD_Ticket.intPricingTypeId = 5
LEFT JOIN tblCTContractHeader CH_Ticket 
    ON CH_Ticket.intContractHeaderId = CD_Ticket.intContractHeaderId
		and CH_Ticket.intPricingTypeId = 5
LEFT JOIN tblICInventoryShipment _IS
    ON _IS.intInventoryShipmentId= SC.intInventoryShipmentId
WHERE CS.dblOpenBalance > 0