CREATE VIEW [dbo].[vyuGRStorageSearchView]
AS    
SELECT
	intCustomerStorageId		  	= CS.intCustomerStorageId
	,intTransactionId			  	= CASE 
										WHEN CS.intDeliverySheetId IS NOT NULL AND CS.ysnTransferStorage = 0 THEN CS.intDeliverySheetId
										WHEN CS.intTicketId IS NOT NULL AND CS.ysnTransferStorage = 0 THEN CS.intTicketId
										ELSE TSS.intTransferStorageId
									END
	,CASE 
										WHEN CS.intDeliverySheetId IS NOT NULL AND CS.ysnTransferStorage = 0 THEN 'DS' --DELIVERY SHEET
										WHEN CS.intTicketId IS NOT NULL AND CS.ysnTransferStorage = 0 THEN 'SC' --SCALE TICKET
										ELSE 'TS' --TRANSFER STORAGE
									END COLLATE Latin1_General_CI_AS as strTransactionCode
	,CASE 
										WHEN CS.intDeliverySheetId IS NOT NULL AND CS.ysnTransferStorage = 0 THEN DeliverySheet.strDeliverySheetNumber
										WHEN CS.intTicketId IS NOT NULL AND CS.ysnTransferStorage = 0 THEN SC.strTicketNumber
										ELSE TS.strTransferStorageTicket
									END COLLATE Latin1_General_CI_AS as strTransaction
	,intEntityId				  	= CS.intEntityId
	,strName					  	= E.strName  
	,strStorageTicketNumber		  = CASE WHEN CS.ysnTransferStorage = 1 THEN TS.strTransferStorageTicket ELSE CS.strStorageTicketNumber END
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
	,dblOriginalBalance			  	= dbo.fnCTConvertQtyToTargetItemUOM(CS.intItemUOMId,ItemUOM.intItemUOMId,CS.dblOriginalBalance) 
	,dblOpenBalance				  	= dbo.fnCTConvertQtyToTargetItemUOM(CS.intItemUOMId,ItemUOM.intItemUOMId,CS.dblOpenBalance) 
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
	,strSplitDescription			= CASE 
										WHEN CS.intDeliverySheetId IS NOT NULL AND CS.ysnTransferStorage = 0 THEN ISNULL(NULLIF(DeliverySheet.strSplitDescription, ''),EMSplit.strDescription) --DELIVERY SHEET
										WHEN CS.intTicketId IS NOT NULL AND CS.ysnTransferStorage = 0 THEN EMSplit.strDescription --SCALE TICKET
										ELSE '' --TRANSFER STORAGE
									END COLLATE Latin1_General_CI_AS
	--,intContractHeaderId          	= CASE WHEN ST.ysnDPOwnedType = 1 THEN CH.intContractHeaderId ELSE NULL END
 --   ,intContractDetailId		  	= CASE WHEN ST.ysnDPOwnedType = 1  THEN SC.intContractId ELSE NULL END
 --   ,strContractNumber			  	= CASE WHEN ST.ysnDPOwnedType = 1  THEN CH.strContractNumber ELSE NULL END
	,intContractHeaderId            = CASE 
										WHEN CS.ysnTransferStorage = 0 AND ST.ysnDPOwnedType = 1 THEN CH.intContractHeaderId 
										WHEN CS.ysnTransferStorage = 1 AND ST.ysnDPOwnedType = 1 THEN CH_Transfer.intContractHeaderId
										ELSE NULL
									END
    ,intContractDetailId			= CASE 
										WHEN CS.ysnTransferStorage = 0 AND ST.ysnDPOwnedType = 1 THEN CD.intContractDetailId
										WHEN CS.ysnTransferStorage = 1 AND ST.ysnDPOwnedType = 1 THEN CD_Transfer.intContractDetailId 
										ELSE NULL
									END
    ,strContractNumber				= CASE 
										WHEN CS.ysnTransferStorage = 0 AND ST.ysnDPOwnedType = 1 THEN CH.strContractNumber 
										WHEN CS.ysnTransferStorage = 1 AND ST.ysnDPOwnedType = 1 THEN CH_Transfer.strContractNumber 
										ELSE NULL
									END
	,strDeliverySheetNumber		  	= DeliverySheet.strDeliverySheetNumber
	,dtmLastStorageAccrueDate	  	= CS.dtmLastStorageAccrueDate
	,dblSplitPercent			  	= CASE WHEN SCTicketSplit.dblSplitPercent IS NULL		
										THEN 
											CASE 
												WHEN DSS.dblSplitPercent IS NOT NULL THEN DSS.dblSplitPercent 
												WHEN TSS.dblSplitPercent IS NOT NULL THEN TSS.dblSplitPercent
												ELSE 100
											END
										ELSE SCTicketSplit.dblSplitPercent
									END
	,intSplitId					   	= EMSplit.intSplitId
	,intItemUOMId				 	= CS.intItemUOMId
	,ysnDeliverySheetPosted		 	= ISNULL(DeliverySheet.ysnPost,1)
    ,ysnShowInStorage			 	= CAST(
										CASE
											WHEN ST.ysnCustomerStorage = 0 THEN 1
											WHEN ST.ysnCustomerStorage = 1 AND ST.strOwnedPhysicalStock = 'Customer' THEN 1
											ELSE 0
										END AS BIT
									)
	,Category.strCategoryCode
	,strTransactionStatus           = CASE 
										WHEN CS.ysnTransferStorage = 1 OR CS.intTicketId IS NOT NULL OR DeliverySheet.ysnPost = 1 THEN 'Posted'
										ELSE 'Open'
									END
	,TSR.intSourceCustomerStorageId
	,CS.ysnTransferStorage
	,strStorageTransactionNumber = CS.strStorageTicketNumber
	,CS.dblBasis
	,CS.dblSettlementPrice
FROM tblGRCustomerStorage CS  
JOIN tblSMCompanyLocation LOC
	ON LOC.intCompanyLocationId = CS.intCompanyLocationId  
LEFT JOIN tblGRStorageType ST
	ON ST.intStorageScheduleTypeId = CS.intStorageTypeId  
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
LEFT JOIN (tblSCDeliverySheet DeliverySheet 
			INNER JOIN tblSCDeliverySheetSplit DSS	
				ON DSS.intDeliverySheetId = DeliverySheet.intDeliverySheetId
		) ON DeliverySheet.intDeliverySheetId = CS.intDeliverySheetId
			AND DSS.intEntityId = E.intEntityId
			AND DSS.intStorageScheduleTypeId = CS.intStorageTypeId
			AND DSS.intStorageScheduleRuleId = CS.intStorageScheduleId
LEFT JOIN (
	tblSCTicket SC 		
	LEFT JOIN tblGRStorageHistory SH
		ON SH.intTicketId = SC.intTicketId
	LEFT JOIN tblICInventoryReceiptItem IRI
		ON IRI.intInventoryReceiptId = SH.intInventoryReceiptId
	) 
	ON SC.intTicketId = CS.intTicketId
		AND SH.intCustomerStorageId = CS.intCustomerStorageId
LEFT JOIN tblSCTicketSplit SCTicketSplit	
	ON SCTicketSplit.intTicketId = CS.intTicketId 
		AND SCTicketSplit.intCustomerId = CS.intEntityId
LEFT JOIN tblEMEntitySplit EMSplit
	ON EMSplit.intSplitId = SC.intSplitId 
		OR EMSplit.intSplitId = DeliverySheet.intSplitId
LEFT JOIN tblCTContractDetail CD
	ON CD.intContractDetailId = IRI.intContractDetailId
LEFT JOIN tblCTContractHeader CH 
    ON CH.intContractHeaderId = CD.intContractHeaderId  
LEFT JOIN (
		tblGRTransferStorageSplit TSS
		INNER JOIN tblGRTransferStorage TS
			ON TS.intTransferStorageId = TSS.intTransferStorageId
		LEFT JOIN tblGRTransferStorageReference TSR
			ON TSR.intTransferStorageSplitId  = TSS.intTransferStorageSplitId
	) ON ISNULL(TSR.intToCustomerStorageId,TSS.intTransferToCustomerStorageId) = CS.intCustomerStorageId
LEFT JOIN tblCTContractDetail CD_Transfer
    ON CD_Transfer.intContractDetailId = TSS.intContractDetailId
		AND CS.ysnTransferStorage = 1
LEFT JOIN tblCTContractHeader CH_Transfer
    ON CH_Transfer.intContractHeaderId = CD_Transfer.intContractHeaderId