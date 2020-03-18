﻿CREATE PROCEDURE [dbo].[uspGRRiskSummaryLog]
(
	@intStorageHistoryId INT
)
AS
BEGIN TRY
	DECLARE @ErrMsg NVARCHAR(MAX)
	DECLARE @SummaryLogs AS RKSummaryLog

	IF (SELECT 1 FROM tblGRStorageHistory WHERE intStorageHistoryId = @intStorageHistoryId AND intTransactionTypeId IN (1,3,4,5,9)) = 1
	BEGIN
		INSERT INTO @SummaryLogs
		(
			strBucketType 				
			,strTransactionType								
			,intTransactionRecordId 	
			,strDistributionType 		
			,strTransactionNumber 		
			,dtmTransactionDate 		
			,intContractHeaderId	
			,intTicketId			
			,intCommodityId			
			,intCommodityUOMId		
			,intItemId				
			,intLocationId			
			,dblQty 				
			,intEntityId			
			,ysnDelete				
			,intUserId					
		)
		--CUSTOMER OWNED STORAGE
		SELECT
			strBucketType 				= 'Customer Owned'
			,strTransactionType 		= CASE 
											WHEN intTransactionTypeId IN (1, 5)
												THEN CASE 
														WHEN sh.intInventoryReceiptId IS NOT NULL THEN 'Inventory Receipt'
														WHEN sh.intInventoryShipmentId IS NOT NULL THEN 'Inventory Shipment'
														ELSE 'NONE' 
													END
											WHEN intTransactionTypeId = 3 THEN 'Transfer Storage'
											WHEN intTransactionTypeId = 4 THEN 'Storage Settlement'
											WHEN intTransactionTypeId = 9 THEN 'Inventory Adjustment' 
										END
			,intTransactionRecordId 	= CASE 
											WHEN intTransactionTypeId IN (1, 5)
												THEN CASE 
														WHEN sh.intInventoryReceiptId IS NOT NULL THEN sh.intInventoryReceiptId
														WHEN sh.intInventoryShipmentId IS NOT NULL THEN sh.intInventoryShipmentId
														ELSE NULL 
													END
											WHEN intTransactionTypeId = 3 THEN sh.intTransferStorageId
											WHEN intTransactionTypeId = 4 THEN sh.intSettleStorageId
											WHEN intTransactionTypeId = 9 THEN sh.intInventoryAdjustmentId 
										END
			,strDistributionType 		= st.strStorageTypeDescription
			,strTransactionNumber 		= CASE 
											WHEN intTransactionTypeId IN (1, 5)
												THEN CASE 
														WHEN sh.intInventoryReceiptId IS NOT NULL THEN sh.strReceiptNumber
														WHEN sh.intInventoryShipmentId IS NOT NULL THEN sh.strShipmentNumber
														ELSE NULL 
													END
											WHEN intTransactionTypeId = 3 THEN sh.strTransferTicket
											WHEN intTransactionTypeId = 4 THEN sh.strSettleTicket
											WHEN intTransactionTypeId = 9 THEN sh.strAdjustmentNo 
										END
			,dtmTransactionDate 		= (CASE WHEN sh.strType = 'Transfer' THEN RIGHT(CONVERT(VARCHAR(11), sh.dtmHistoryDate, 106), 8) ELSE RIGHT(CONVERT(VARCHAR(11), cs.dtmDeliveryDate, 106), 8) END) COLLATE Latin1_General_CI_AS			
			,intContractHeaderId		= sh.intContractHeaderId
			,intTicketId				= sh.intTicketId				
			,intCommodityId				= cs.intCommodityId
			,intCommodityUOMId			= cum.intCommodityUnitMeasureId
			,intItemId					= cs.intItemId			
			,intLocationId				= cs.intCompanyLocationId
			,dblQty 					= (CASE WHEN sh.strType ='Reduced By Inventory Shipment' OR sh.strType = 'Settlement' THEN - sh.dblUnits ELSE sh.dblUnits END)
			,intEntityId				= cs.intEntityId			
			,ysnDelete					= 0
			,intUserId					= sh.intUserId
		FROM vyuGRStorageHistory sh
		JOIN tblGRCustomerStorage cs 
			ON cs.intCustomerStorageId = sh.intCustomerStorageId
		JOIN tblGRStorageType st 
			ON st.intStorageScheduleTypeId = cs.intStorageTypeId and ysnDPOwnedType = 0
		JOIN tblICItemUOM iuom 
			ON iuom.intItemUOMId = cs.intItemUOMId
		JOIN tblICCommodityUnitMeasure cum 
			ON cum.intUnitMeasureId = iuom.intUnitMeasureId 
				AND cum.intCommodityId = cs.intCommodityId
		LEFT JOIN tblSCTicket t 
			ON t.intTicketId = sh.intTicketId
		LEFT JOIN tblSMCompanyLocationSubLocation sl 
			ON sl.intCompanyLocationSubLocationId = t.intSubLocationId 
				AND sl.intCompanyLocationId = t.intProcessingLocationId
		WHERE sh.intStorageHistoryId = @intStorageHistoryId
		--COMPANY OWNED STORAGE (DP/PRICED LATER)
		UNION ALL
		SELECT 
			strBucketType	 			= 'Delayed Pricing'
			,strTransactionType 		= CASE 
											WHEN intTransactionTypeId IN (1, 5)
												THEN CASE 
														WHEN sh.intInventoryReceiptId IS NOT NULL THEN 'Inventory Receipt'
														WHEN sh.intInventoryShipmentId IS NOT NULL THEN 'Inventory Shipment'
														ELSE 'NONE' 
													END
											WHEN intTransactionTypeId = 3 THEN 'Transfer Storage'
											WHEN intTransactionTypeId = 4 THEN 'Storage Settlement'
											WHEN intTransactionTypeId = 9 THEN 'Inventory Adjustment' 
										END
			,intTransactionRecordId 	= CASE 
											WHEN intTransactionTypeId IN (1, 5)
												THEN CASE 
														WHEN sh.intInventoryReceiptId IS NOT NULL THEN sh.intInventoryReceiptId
														WHEN sh.intInventoryShipmentId IS NOT NULL THEN sh.intInventoryShipmentId
														ELSE NULL 
													END
											WHEN intTransactionTypeId = 3 THEN sh.intTransferStorageId
											WHEN intTransactionTypeId = 4 THEN sh.intSettleStorageId
											WHEN intTransactionTypeId = 9 THEN sh.intInventoryAdjustmentId 
										END
			,strDistributionType 		= st.strStorageTypeDescription
			,strTransactionNumber		= CASE 
											WHEN intTransactionTypeId IN (1, 5)
												THEN CASE 
														WHEN sh.intInventoryReceiptId IS NOT NULL THEN sh.strReceiptNumber
														WHEN sh.intInventoryShipmentId IS NOT NULL THEN sh.strShipmentNumber
														ELSE NULL 
													END
											WHEN intTransactionTypeId = 3 THEN sh.strTransferTicket
											WHEN intTransactionTypeId = 4 THEN sh.strSettleTicket
											WHEN intTransactionTypeId = 9 THEN sh.strAdjustmentNo 
										END
			,dtmTransactionDate			= (CASE WHEN sh.strType = 'Transfer' THEN RIGHT(CONVERT(VARCHAR(11), sh.dtmHistoryDate, 106), 8) ELSE RIGHT(CONVERT(VARCHAR(11), cs.dtmDeliveryDate, 106), 8) END) COLLATE Latin1_General_CI_AS		
			,intContractHeaderId		= sh.intContractHeaderId
			,intTicketId 				= sh.intTicketId
			,intCommodityId				= cs.intCommodityId			
			,intCommodityUOMId			= cum.intCommodityUnitMeasureId
			,intItemId					= cs.intItemId
			,intLocationId				= sh.intCompanyLocationId
			,dblQty 					= (CASE WHEN sh.strType ='Reduced By Inventory Shipment' OR sh.strType = 'Settlement' THEN - sh.dblUnits ELSE sh.dblUnits END)			
			,intEntityId				=  cs.intEntityId
			,ysnDelete					= 0
			,intUserId					= sh.intUserId
		FROM vyuGRStorageHistory sh
		JOIN tblGRCustomerStorage cs 
			ON cs.intCustomerStorageId = sh.intCustomerStorageId
		JOIN tblGRStorageType st 
			ON st.intStorageScheduleTypeId = cs.intStorageTypeId 
				AND ysnDPOwnedType = 1
		JOIN tblICItemUOM iuom 
			ON iuom.intItemUOMId = cs.intItemUOMId
		JOIN tblICCommodityUnitMeasure cum 
			ON cum.intUnitMeasureId = iuom.intUnitMeasureId 
				AND cum.intCommodityId = cs.intCommodityId
		LEFT JOIN tblSCTicket t 
			ON t.intTicketId = sh.intTicketId
		LEFT JOIN tblSMCompanyLocationSubLocation sl 
			ON sl.intCompanyLocationSubLocationId = t.intSubLocationId 
				AND sl.intCompanyLocationId = t.intProcessingLocationId
		WHERE sh.intStorageHistoryId = @intStorageHistoryId
		--STORAGE SETTELEMENT
		UNION ALL
		SELECT 
			strBucketType	 			= 'Company Owned'
			,strTransactionType 		= 'Storage Settlement'
			,intTransactionRecordId 	= sh.intSettleStorageId
			,strDistributionType 		= st.strStorageTypeDescription
			,strTransactionNumber 		= sh.strSettleTicket
			,dtmTransactionDate			= (CASE WHEN sh.strType = 'Transfer' THEN RIGHT(CONVERT(VARCHAR(11), sh.dtmHistoryDate, 106), 8) ELSE RIGHT(CONVERT(VARCHAR(11), cs.dtmDeliveryDate, 106), 8) END) COLLATE Latin1_General_CI_AS
			,intContractHeaderId		= sh.intContractHeaderId
			,intTicketId				= sh.intTicketId
			,intCommodityId				= cs.intCommodityId
			,intCommodityUOMId			= cum.intCommodityUnitMeasureId
			,intItemId					= cs.intItemId			
			,intLocationId				= sh.intCompanyLocationId
			,dblQty 					= (CASE WHEN sh.strType = 'Reverse Settlement' THEN - sh.dblUnits ELSE sh.dblUnits END)			
			,intEntityId				= cs.intEntityId
			,ysnDelete					= 0
			,intUserId					= sh.intUserId
		FROM vyuGRStorageHistory sh
		JOIN tblGRCustomerStorage cs 
			ON cs.intCustomerStorageId = sh.intCustomerStorageId
		JOIN tblGRStorageType st 
			ON st.intStorageScheduleTypeId = cs.intStorageTypeId 
				AND ysnDPOwnedType = 0
		JOIN tblICItemUOM iuom 
			ON iuom.intItemUOMId = cs.intItemUOMId
		JOIN tblICCommodityUnitMeasure cum 
			ON cum.intUnitMeasureId = iuom.intUnitMeasureId 
				AND cum.intCommodityId = cs.intCommodityId
		LEFT JOIN tblSCTicket t 
			ON t.intTicketId = sh.intTicketId
		LEFT JOIN tblSMCompanyLocationSubLocation sl 
			ON sl.intCompanyLocationSubLocationId = t.intSubLocationId 
				AND sl.intCompanyLocationId = t.intProcessingLocationId
		WHERE sh.intTransactionTypeId = 4
			AND sh.intStorageHistoryId = @intStorageHistoryId
		
		EXEC uspRKLogRiskPosition @SummaryLogs
	END

END TRY
BEGIN CATCH
	SET @ErrMsg = ERROR_MESSAGE()
	RAISERROR (@ErrMsg,16,1,'WITH NOWAIT')
END CATCH