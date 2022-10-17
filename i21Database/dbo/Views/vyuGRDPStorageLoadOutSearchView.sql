CREATE VIEW [dbo].[vyuGRDPStorageLoadOutSearchView]
AS    
SELECT 
	intCustomerStorageId		  	= CS.intCustomerStorageId
	,intTransactionId			  	= CS.intTicketId
	,intEntityId				  	= CS.intEntityId
	,strName					  	= E.strName  
	,strStorageTicketNumber			= CS.strStorageTicketNumber
	,intStorageTypeId			  	= CS.intStorageTypeId
	,strStorageTypeDescription	  	= ST.strStorageTypeDescription
	,intCommodityId				  	= CS.intCommodityId
	,strCommodityCode			  	= Commodity.strCommodityCode
	,intItemId					  	= CS.intItemId
	,strItemNo					  	= Item.strItemNo
	,intCompanyLocationId		  	= CS.intCompanyLocationId
	,strLocationName			  	= LOC.strLocationName
	,intStorageScheduleId		  	= CS.intStorageScheduleId
	,strScheduleId				  	= SR.strScheduleDescription
	,strDPARecieptNumber		  	= CS.strDPARecieptNumber
	,strCustomerReference		  	= ISNULL(CS.strCustomerReference,'')  
	,dblOriginalBalance			  	= dbo.fnCalculateQtyBetweenUOM (CS.intItemUOMId,ItemUOM.intItemUOMId,CS.dblOriginalBalance) 
	,dblOpenBalance				  	= dbo.fnCalculateQtyBetweenUOM (CS.intItemUOMId,ItemUOM.intItemUOMId,CS.dblOpenBalance) 
	,dtmDeliveryDate			  	= CS.dtmDeliveryDate
	,strDiscountComment			  	= CS.strDiscountComment
	,dblInsuranceRate			  	= ISNULL(CS.dblInsuranceRate,0)
	,dblStorageDue				  	= ISNULL(CS.dblStorageDue,0)
	,dblStoragePaid				  	= ISNULL(CS.dblStoragePaid,0)
	,dblFeesDue					  	= ISNULL(CS.dblFeesDue,0)
	,dblFeesPaid				  	= ISNULL(CS.dblFeesPaid,0)
	,dblDiscountsDue			  	= ISNULL(CS.dblDiscountsDue,0)
	,dblDiscountsPaid			  	= ISNULL(CS.dblDiscountsPaid,0)
	,intDiscountScheduleId		  	= CS.intDiscountScheduleId
	,strDiscountDescription		  	= DS.strDiscountDescription
	,dblDiscountUnPaid			  	= ISNULL(CS.dblDiscountsDue,0) - ISNULL(CS.dblDiscountsPaid,0)
	,dblStorageUnPaid			  	= ISNULL(CS.dblStorageDue,0) - ISNULL(CS.dblStoragePaid,0)
	,strSplitNumber				  	= EMSplit.strSplitNumber
	,strSplitDescription			= EMSplit.strDescription COLLATE Latin1_General_CI_AS
	,intContractHeaderId            = SH.intContractHeaderId
    ,intContractDetailId			= CD.intContractDetailId--ISI.intItemContractDetailId
    ,strContractNumber				= CH.strContractNumber
	,dtmLastStorageAccrueDate	  	= CS.dtmLastStorageAccrueDate
	,dblSplitPercent			  	= SCTicketSplit.dblSplitPercent
	,intSplitId					   	= EMSplit.intSplitId
	,intItemUOMId				 	= CS.intItemUOMId
	,strCategoryCode				= Category.strCategoryCode
	,strTransactionStatus           = 'Posted'
	,strStorageTransactionNumber	= CS.strStorageTicketNumber
	,CS.dblBasis
	,CS.dblSettlementPrice
	,intTicketPricingTypeId = ISNULL(CH.intPricingTypeId, -99)
	,CAP.intChargeAndPremiumId
	,CAP.strChargeAndPremiumId
FROM tblGRCustomerStorage CS  
JOIN tblSMCompanyLocation LOC
	ON LOC.intCompanyLocationId = CS.intCompanyLocationId  
JOIN tblGRStorageType ST
	ON ST.intStorageScheduleTypeId = CS.intStorageTypeId
		AND ST.ysnDPOwnedType = 1
LEFT JOIN tblGRChargeAndPremiumId CAP
	ON CAP.intChargeAndPremiumId = CS.intChargeAndPremiumId
JOIN tblICItem Item 
	ON Item.intItemId = CS.intItemId
JOIN tblICCommodity Commodity
    ON Commodity.intCommodityId = CS.intCommodityId
JOIN tblICCategory Category
	ON Item.intCategoryId = Category.intCategoryId
JOIN tblICItemUOM ItemUOM
	ON ItemUOM.intItemId = Item.intItemId
		AND ItemUOM.ysnStockUnit = 1
JOIN tblEMEntity E
	ON E.intEntityId = CS.intEntityId
LEFT JOIN tblGRStorageScheduleRule SR
	ON SR.intStorageScheduleRuleId = CS.intStorageScheduleId
JOIN tblGRDiscountSchedule DS 
	ON DS.intDiscountScheduleId = CS.intDiscountScheduleId
JOIN (
	tblSCTicket SC 		
	LEFT JOIN tblGRStorageHistory SH
		ON SH.intTicketId = SC.intTicketId
	--LEFT JOIN tblICInventoryShipment ICS
	--	ON ICS.intInventoryShipmentId = SH.intInventoryShipmentId
	--LEFT JOIN tblICInventoryShipmentItem ISI
	--	ON ISI.intInventoryShipmentId = SH.intInventoryShipmentId
	--		AND ISI.intItemContractHeaderId = SH.intContractHeaderId
	) 
	ON SC.intTicketId = CS.intTicketId
		--AND ICS.intEntityCustomerId = CS.intEntityId	
		AND SC.strInOutFlag = 'O'
LEFT JOIN tblSCTicketSplit SCTicketSplit	
	ON SCTicketSplit.intTicketId = CS.intTicketId 
		AND SCTicketSplit.intCustomerId = CS.intEntityId
LEFT JOIN tblEMEntitySplit EMSplit
	ON EMSplit.intSplitId = SC.intSplitId
LEFT JOIN tblCTContractDetail CD
    --ON CD.intContractDetailId = ISI.intItemContractDetailId
	ON CD.intContractHeaderId = SH.intContractHeaderId
LEFT JOIN tblCTContractHeader CH 
    --ON CH.intContractHeaderId = CD.intContractHeaderId 
	ON CH.intContractHeaderId = SH.intContractHeaderId