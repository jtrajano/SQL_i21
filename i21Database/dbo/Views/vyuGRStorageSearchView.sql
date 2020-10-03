CREATE VIEW [dbo].[vyuGRStorageSearchView]
AS    
SELECT DISTINCT 
	intCustomerStorageId		  	= CS.intCustomerStorageId
	,intTransactionId			  	= CASE 
										WHEN CS.intDeliverySheetId IS NOT NULL AND CS.ysnTransferStorage = 0 THEN CS.intDeliverySheetId
										WHEN CS.intTicketId IS NOT NULL AND CS.ysnTransferStorage = 0 THEN CS.intTicketId
										ELSE TRANSFERSTORAGE.intTransferStorageId
									END
	,CASE 
										WHEN CS.intDeliverySheetId IS NOT NULL AND CS.ysnTransferStorage = 0 THEN 'DS' --DELIVERY SHEET
										WHEN CS.intTicketId IS NOT NULL AND CS.ysnTransferStorage = 0 THEN 'SC' --SCALE TICKET
										ELSE 'TS' --TRANSFER STORAGE
									END COLLATE Latin1_General_CI_AS as strTransactionCode
	,CASE 
										WHEN CS.intDeliverySheetId IS NOT NULL AND CS.ysnTransferStorage = 0 THEN DELIVERYSHEET.strDeliverySheetNumber
										WHEN CS.intTicketId IS NOT NULL AND CS.ysnTransferStorage = 0 THEN SC.strTicketNumber
										ELSE TRANSFERSTORAGE.strTransferStorageTicket
									END COLLATE Latin1_General_CI_AS as strTransaction
	,intEntityId				  	= CS.intEntityId
	,strName					  	= E.strName  
	,strStorageTicketNumber		  = CASE WHEN CS.ysnTransferStorage = 1 THEN TRANSFERSTORAGE.strTransferStorageTicket ELSE CS.strStorageTicketNumber END
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
	--,intContractHeaderId          	= CASE WHEN ST.ysnDPOwnedType = 1 THEN CH.intContractHeaderId ELSE NULL END
 --   ,intContractDetailId		  	= CASE WHEN ST.ysnDPOwnedType = 1  THEN SC.intContractId ELSE NULL END
 --   ,strContractNumber			  	= CASE WHEN ST.ysnDPOwnedType = 1  THEN CH.strContractNumber ELSE NULL END
	,intContractHeaderId            = case when (CS.intStorageTypeId = 2 and GHistory.intContractHeaderId is not null) then GHistory.intContractHeaderId else
										CASE 
											WHEN CS.ysnTransferStorage = 0 AND ST.ysnDPOwnedType = 1 THEN CH.intContractHeaderId 
											WHEN CS.ysnTransferStorage = 1 AND ST.ysnDPOwnedType = 1 THEN CH_Transfer.intContractHeaderId
											ELSE NULL
										END
									end
    ,intContractDetailId			= case when (CS.intStorageTypeId = 2 and GHistory.intContractDetailId is not null) then GHistory.intContractDetailId else 
										CASE 
											WHEN CS.ysnTransferStorage = 0 AND ST.ysnDPOwnedType = 1 THEN SC.intContractId 
											WHEN CS.ysnTransferStorage = 1 AND ST.ysnDPOwnedType = 1 THEN CD_Transfer.intContractDetailId 
											ELSE NULL
										END
									end
    ,strContractNumber				= case when (CS.intStorageTypeId = 2 and GHistory.intContractHeaderId is not null) then GHistory.strContractNumber else 
										CASE 
											WHEN CS.ysnTransferStorage = 0 AND ST.ysnDPOwnedType = 1 THEN CH.strContractNumber 
											WHEN CS.ysnTransferStorage = 1 AND ST.ysnDPOwnedType = 1 THEN CH_Transfer.strContractNumber 
											ELSE NULL
										END
									end
	,strDeliverySheetNumber		  	= DELIVERYSHEET.strDeliverySheetNumber
	,dtmLastStorageAccrueDate	  	= CS.dtmLastStorageAccrueDate
	,dblSplitPercent			  	= CASE WHEN SCTicketSplit.dblSplitPercent IS NULL		
										THEN 
											CASE 
												WHEN DELIVERYSHEET.dblSplitPercent IS NOT NULL THEN DELIVERYSHEET.dblSplitPercent 
												WHEN TRANSFERSTORAGE.dblSplitPercent IS NOT NULL THEN TRANSFERSTORAGE.dblSplitPercent
												ELSE 100
											END
										ELSE SCTicketSplit.dblSplitPercent
									END
	,intSplitId					   	= EMSplit.intSplitId
	,intItemUOMId				 	= CS.intItemUOMId
	,ysnDeliverySheetPosted		 	= ISNULL(DELIVERYSHEET.ysnPost,1)
    ,ysnShowInStorage			 	= CAST(
										CASE
											WHEN ST.ysnCustomerStorage = 0 THEN 1
											WHEN ST.ysnCustomerStorage = 1 AND ST.strOwnedPhysicalStock = 'Customer' THEN 1
											ELSE 0
										END AS BIT
									)
	,Category.strCategoryCode
	,strTransactionStatus           = CASE 
										WHEN CS.ysnTransferStorage = 1 OR (CS.intTicketId IS NOT NULL AND SC.strTicketStatus = 'C') OR DELIVERYSHEET.ysnPost = 1 THEN 'Posted'
										ELSE 'Open'
									END
	,TRANSFERSTORAGE.intSourceCustomerStorageId
	,CS.ysnTransferStorage
	,strStorageTransactionNumber = CS.strStorageTicketNumber
FROM tblGRCustomerStorage CS  
JOIN (
	SELECT intCompanyLocationId
		,strLocationName
	FROM tblSMCompanyLocation WITH (NOLOCK)
) LOC
	ON LOC.intCompanyLocationId = CS.intCompanyLocationId  
LEFT JOIN (
	SELECT intStorageScheduleTypeId
		,ysnDPOwnedType
		,ysnCustomerStorage
		,strOwnedPhysicalStock
		,strStorageTypeDescription
	FROM tblGRStorageType WITH (NOLOCK)
)ST
	ON ST.intStorageScheduleTypeId = CS.intStorageTypeId  
JOIN (
	SELECT intItemId
		,strItemNo
		,intCategoryId
	FROM tblICItem WITH (NOLOCK)
) Item 
	ON Item.intItemId = CS.intItemId
JOIN (
	SELECT intCommodityId
		,strCommodityCode
	FROM tblICCommodity WITH (NOLOCK)
) Commodity
    ON Commodity.intCommodityId = CS.intCommodityId
JOIN (
	SELECT intCategoryId
		,strCategoryCode
	FROM tblICCategory WITH (NOLOCK)
) Category
	ON Item.intCategoryId = Category.intCategoryId
JOIN (
	SELECT intItemId
		,ysnStockUnit
		,intItemUOMId
	FROM tblICItemUOM WITH (NOLOCK)
) ItemUOM
	ON ItemUOM.intItemId = Item.intItemId
		AND ItemUOM.ysnStockUnit = 1
JOIN (
	SELECT intEntityId
		,strName
	FROM tblEMEntity WITH (NOLOCK)
) E
	ON E.intEntityId = CS.intEntityId
LEFT JOIN (
	SELECT intStorageScheduleRuleId
		,strScheduleDescription
	FROM tblGRStorageScheduleRule WITH (NOLOCK)
) SR
	ON SR.intStorageScheduleRuleId = CS.intStorageScheduleId
JOIN (
	SELECT intDiscountScheduleId
		,strDiscountDescription
	FROM tblGRDiscountSchedule WITH (NOLOCK)
) DS 
	ON DS.intDiscountScheduleId = CS.intDiscountScheduleId
LEFT JOIN (
	SELECT DeliverySheet.intDeliverySheetId
		,DeliverySheet.strDeliverySheetNumber
		,DeliverySheet.intSplitId
		,DeliverySheet.ysnPost
		,DSS.intEntityId
		,DSS.intStorageScheduleTypeId
		,DSS.intStorageScheduleRuleId		
		,DSS.dblSplitPercent		
	FROM tblSCDeliverySheet DeliverySheet WITH (NOLOCK)
	INNER JOIN (
		SELECT intDeliverySheetId
			,intEntityId
			,intStorageScheduleTypeId
			,intStorageScheduleRuleId
			,dblSplitPercent
		FROM tblSCDeliverySheetSplit WITH (NOLOCK)
	) DSS
		ON DSS.intDeliverySheetId = DeliverySheet.intDeliverySheetId
) DELIVERYSHEET ON DELIVERYSHEET.intDeliverySheetId = CS.intDeliverySheetId
	AND DELIVERYSHEET.intEntityId = E.intEntityId
	AND DELIVERYSHEET.intStorageScheduleTypeId = CS.intStorageTypeId
	AND DELIVERYSHEET.intStorageScheduleRuleId = CS.intStorageScheduleId
LEFT JOIN (
	SELECT intTicketId
		,strTicketNumber
		,intContractId
		,strTicketStatus
		,intSplitId
	FROM tblSCTicket WITH (NOLOCK)
) SC 
	ON SC.intTicketId = CS.intTicketId
LEFT JOIN (
	SELECT intTicketId
		,intCustomerId
		,dblSplitPercent
	FROM tblSCTicketSplit WITH (NOLOCK)
) SCTicketSplit
	ON SCTicketSplit.intTicketId = CS.intTicketId 
		AND SCTicketSplit.intCustomerId = CS.intEntityId
LEFT JOIN (
	SELECT intSplitId
		,strSplitNumber
	FROM tblEMEntitySplit WITH (NOLOCK)
) EMSplit
	ON (EMSplit.intSplitId = SC.intSplitId OR EMSplit.intSplitId = DELIVERYSHEET.intSplitId)
LEFT JOIN (
	SELECT intContractDetailId
		,intContractHeaderId
	FROM tblCTContractDetail WITH (NOLOCK)
)  CD
    ON CD.intContractDetailId = SC.intContractId  
LEFT JOIN (
	SELECT intContractHeaderId
		,strContractNumber
	FROM tblCTContractHeader WITH (NOLOCK)
) CH 
    ON CH.intContractHeaderId = CD.intContractHeaderId  
LEFT JOIN (
		SELECT 
			TSS.intTransferStorageId
			,TSS.intTransferToCustomerStorageId
			,TSR.intToCustomerStorageId
			,TSS.intContractDetailId
			,TSR.intSourceCustomerStorageId
			,TSS.dblSplitPercent
			,TS.strTransferStorageTicket
		FROM tblGRTransferStorageSplit TSS WITH (NOLOCK)
		INNER JOIN (
			SELECT intTransferStorageId
				,strTransferStorageTicket
			FROM tblGRTransferStorage WITH (NOLOCK)
		) TS
			ON TS.intTransferStorageId = TSS.intTransferStorageId
		LEFT JOIN (
			SELECT intTransferStorageSplitId
				,intToCustomerStorageId
				,intSourceCustomerStorageId
			FROM tblGRTransferStorageReference WITH (NOLOCK)
		) TSR
			ON TSR.intTransferStorageSplitId  = TSS.intTransferStorageSplitId
	) TRANSFERSTORAGE ON ISNULL(TRANSFERSTORAGE.intToCustomerStorageId,TRANSFERSTORAGE.intTransferToCustomerStorageId) = CS.intCustomerStorageId
LEFT JOIN (
	SELECT intContractDetailId
		,intContractHeaderId
	FROM tblCTContractDetail WITH (NOLOCK)
) CD_Transfer
    ON CD_Transfer.intContractDetailId = TRANSFERSTORAGE.intContractDetailId
		AND CS.ysnTransferStorage = 1
LEFT JOIN (
	SELECT intContractHeaderId
		,strContractNumber
	FROM tblCTContractHeader WITH (NOLOCK)
) CH_Transfer
    ON CH_Transfer.intContractHeaderId = CD_Transfer.intContractHeaderId  
LEFT JOIN (
	SELECT GSH.intCustomerStorageId, GCH.intContractHeaderId, GCH.strContractNumber, GCD.intContractDetailId 
	FROM tblGRStorageHistory GSH WITH (NOLOCK)
	JOIN (
		SELECT intContractHeaderId
			,strContractNumber
		FROM tblCTContractHeader WITH (NOLOCK)
	) GCH
		ON GCH.intContractHeaderId = GSH.intContractHeaderId
	JOIN (
		SELECT intContractDetailId
			,intContractHeaderId
		FROM tblCTContractDetail WITH (NOLOCK)
	) GCD
		ON GCH.intContractHeaderId = GCD.intContractHeaderId
	WHERE GSH.intTransactionTypeId IN (1,3,5) --Scale, Transfer, Delivery Sheet
) GHistory
    on GHistory.intCustomerStorageId = CS.intCustomerStorageId 
        and ST.ysnDPOwnedType = 1