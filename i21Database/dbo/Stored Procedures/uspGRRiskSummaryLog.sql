CREATE PROCEDURE [dbo].[uspGRRiskSummaryLog]
(
	@intStorageHistoryId INT
	,@strAction NVARCHAR(50) = NULL
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
			,intTransactionRecordHeaderId
			,strDistributionType 		
			,strTransactionNumber 		
			,dtmTransactionDate 		
			,intContractHeaderId
			,intContractDetailId
			,intTicketId			
			,intCommodityId			
			,intCommodityUOMId		
			,intItemId				
			,intLocationId	
			,dblQty 				
			,intEntityId			
			,ysnDelete				
			,intUserId
			,strMiscFields
			,strNotes
			,intActionId
		)
		--CUSTOMER OWNED STORAGE
		SELECT
			strBucketType 					= 'Customer Owned'
			,strTransactionType 			= CASE 
												WHEN intTransactionTypeId IN (1, 5)
													THEN CASE 
															WHEN sh.intInventoryReceiptId IS NOT NULL THEN 'Inventory Receipt'
															WHEN sh.intInventoryShipmentId IS NOT NULL THEN 'Inventory Shipment'
															ELSE 'NONE' 
														END
												WHEN intTransactionTypeId = 4 THEN 'Storage Settlement'
												WHEN intTransactionTypeId = 9 THEN 'Inventory Adjustment' 
											END
			,intTransactionRecordId 		= CASE 
												WHEN intTransactionTypeId IN (1, 5)
													THEN
														nullif(coalesce(sh.intInventoryReceiptId, sh.intInventoryShipmentId, sh.intTicketId, -99), -99)
												WHEN intTransactionTypeId = 4 THEN sh.intSettleStorageId
												WHEN intTransactionTypeId = 9 THEN sh.intInventoryAdjustmentId 
											END
			,intTransactionRecordHeaderId	= sh.intCustomerStorageId
			,strDistributionType 			= st.strStorageTypeDescription
			,strTransactionNumber 			= CASE 
												WHEN intTransactionTypeId IN (1, 5)
													THEN CASE 
															WHEN sh.intInventoryReceiptId IS NOT NULL THEN sh.strReceiptNumber
															WHEN sh.intInventoryShipmentId IS NOT NULL THEN sh.strShipmentNumber
															WHEN sh.intTicketId is not null then t.strTicketNumber
															ELSE NULL 
														END
												WHEN intTransactionTypeId = 4 THEN sh.strSettleTicket
												WHEN intTransactionTypeId = 9 THEN sh.strAdjustmentNo 
											END
			,dtmTransactionDate 			= sh.dtmHistoryDate
			,intContractHeaderId			= sh.intContractHeaderId
			,intContractDetailId			= NULL
			,intTicketId					= sh.intTicketId				
			,intCommodityId					= cs.intCommodityId
			,intCommodityUOMId				= cum.intCommodityUnitMeasureId
			,intItemId						= cs.intItemId			
			,intLocationId					= cs.intCompanyLocationId
			,dblQty 						= CASE 
												WHEN ISNULL(@strAction,'') = '' THEN (CASE WHEN sh.strType ='Reduced By Inventory Shipment' OR sh.strType = 'Settlement' THEN - sh.dblUnits ELSE sh.dblUnits END)
												ELSE sh.dblUnits * -1
											END									
			,intEntityId					= cs.intEntityId			
			,ysnDelete						= 0
			,intUserId						= sh.intUserId
			,strMiscFields					= CASE WHEN ISNULL(strStorageTypeCode, '') = '' THEN '' ELSE '{ strStorageTypeCode = "' + strStorageTypeCode + '" }' END
											+ CASE WHEN ISNULL(ysnReceiptedStorage, '') = '' THEN '' ELSE '{ ysnReceiptedStorage = "' + CAST(ysnReceiptedStorage AS NVARCHAR) + '" }' END
											+ CASE WHEN ISNULL(sh.intTransactionTypeId, '') = '' THEN '' ELSE '{ intTypeId = "' + CAST(sh.intTransactionTypeId AS NVARCHAR) + '" }' END
											+ CASE WHEN ISNULL(strStorageType, '') = '' THEN '' ELSE '{ strStorageType = "' + strStorageType + '" }' END
											+ CASE WHEN ISNULL(cs.intDeliverySheetId, '') = '' THEN '' ELSE '{ intDeliverySheetId = "' + CAST(cs.intDeliverySheetId AS NVARCHAR) + '" }' END
											+ CASE WHEN ISNULL(strTicketStatus, '') = '' THEN '' ELSE '{ strTicketStatus = "' + strTicketStatus + '" }' END
											+ CASE WHEN ISNULL(strOwnedPhysicalStock, '') = '' THEN '' ELSE '{ strOwnedPhysicalStock = "' + strOwnedPhysicalStock + '" }' END
											+ CASE WHEN ISNULL(strStorageTypeDescription, '') = '' THEN '' ELSE '{ strStorageTypeDescription = "' + strStorageTypeDescription + '" }' END
											+ CASE WHEN ISNULL(ysnActive, '') = '' THEN '' ELSE '{ ysnActive = "' + CAST(ysnActive AS NVARCHAR) + '" }' END
											+ CASE WHEN ISNULL(ysnExternal, '') = '' THEN '' ELSE '{ ysnExternal = "' + CAST(ysnExternal AS NVARCHAR) + '" }' END
			,strNotes						= 'intStorageHistoryId=' + CAST(sh.intStorageHistoryId AS NVARCHAR)
			,intActionId					= CASE 
												WHEN intTransactionTypeId IN (1, 5)
													THEN CASE 
															WHEN sh.intInventoryReceiptId IS NOT NULL THEN 40
															WHEN sh.intInventoryShipmentId IS NOT NULL THEN 41
															ELSE NULL
														END
												WHEN sh.strType = 'Settlement' THEN 9
												WHEN sh.strType = 'Reverse Settlement' THEN 33
												WHEN intTransactionTypeId = 9 THEN 20
											END
		FROM vyuGRStorageHistory sh
		JOIN tblGRCustomerStorage cs 
			ON cs.intCustomerStorageId = sh.intCustomerStorageId
		JOIN tblGRStorageType st 
			ON st.intStorageScheduleTypeId = cs.intStorageTypeId 
				and st.ysnDPOwnedType = 0
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
			AND intTransactionTypeId <> 3
		--COMPANY OWNED STORAGE (DP/PRICED LATER)
		UNION ALL
		SELECT 
			strBucketType	 				= 'Delayed Pricing'
			,strTransactionType 			= CASE 
												WHEN intTransactionTypeId IN (1, 5)
													THEN CASE 
															WHEN sh.intInventoryReceiptId IS NOT NULL THEN 'Inventory Receipt'
															WHEN sh.intInventoryShipmentId IS NOT NULL THEN 'Inventory Shipment'
															ELSE 'NONE' 
														END
												WHEN intTransactionTypeId = 4 THEN 'Storage Settlement'
												WHEN intTransactionTypeId = 9 THEN 'Inventory Adjustment' 
											END
			,intTransactionRecordId 		= CASE 
												WHEN intTransactionTypeId IN (1, 5)
													THEN 
														nullif(coalesce(sh.intInventoryReceiptId, sh.intInventoryShipmentId, sh.intTicketId, -99), -99)
												WHEN intTransactionTypeId = 4 THEN sh.intSettleStorageId
												WHEN intTransactionTypeId = 9 THEN sh.intInventoryAdjustmentId 
											END
			,intTransactionRecordHeaderId	= sh.intCustomerStorageId
			,strDistributionType 			= st.strStorageTypeDescription
			,strTransactionNumber			= CASE 
												WHEN intTransactionTypeId IN (1, 5)
													THEN CASE 
															WHEN sh.intInventoryReceiptId IS NOT NULL THEN sh.strReceiptNumber
															WHEN sh.intInventoryShipmentId IS NOT NULL THEN sh.strShipmentNumber
															WHEN sh.intTicketId is not null then t.strTicketNumber
															ELSE NULL 
														END
												WHEN intTransactionTypeId = 4 THEN sh.strSettleTicket
												WHEN intTransactionTypeId = 9 THEN sh.strAdjustmentNo 
											END
			,dtmTransactionDate				= sh.dtmHistoryDate
			,intContractHeaderId			= sh.intContractHeaderId
			,intContractDetailId			= CD.intContractDetailId
			,intTicketId 					= sh.intTicketId
			,intCommodityId					= cs.intCommodityId			
			,intCommodityUOMId				= cum.intCommodityUnitMeasureId
			,intItemId						= cs.intItemId
			,intLocationId					= sh.intCompanyLocationId
			,dblQty 						= CASE 
												WHEN ISNULL(@strAction,'') = '' THEN (CASE WHEN sh.strType ='Reduced By Inventory Shipment' OR sh.strType = 'Settlement' THEN - sh.dblUnits ELSE sh.dblUnits END)
												ELSE sh.dblUnits * -1
											END
			,intEntityId					=  cs.intEntityId
			,ysnDelete						= 0
			,intUserId						= sh.intUserId
			,strMiscFields					= CASE WHEN ISNULL(strStorageTypeCode, '') = '' THEN '' ELSE '{ strStorageTypeCode = "' + strStorageTypeCode + '" }' END
											+ CASE WHEN ISNULL(ysnReceiptedStorage, '') = '' THEN '' ELSE '{ ysnReceiptedStorage = "' + CAST(ysnReceiptedStorage AS NVARCHAR) + '" }' END
											+ CASE WHEN ISNULL(sh.intTransactionTypeId, '') = '' THEN '' ELSE '{ intTypeId = "' + CAST(sh.intTransactionTypeId AS NVARCHAR) + '" }' END
											+ CASE WHEN ISNULL(strStorageType, '') = '' THEN '' ELSE '{ strStorageType = "' + strStorageType + '" }' END
											+ CASE WHEN ISNULL(cs.intDeliverySheetId, '') = '' THEN '' ELSE '{ intDeliverySheetId = "' + CAST(cs.intDeliverySheetId AS NVARCHAR) + '" }' END
											+ CASE WHEN ISNULL(strTicketStatus, '') = '' THEN '' ELSE '{ strTicketStatus = "' + strTicketStatus + '" }' END
											+ CASE WHEN ISNULL(strOwnedPhysicalStock, '') = '' THEN '' ELSE '{ strOwnedPhysicalStock = "' + strOwnedPhysicalStock + '" }' END
											+ CASE WHEN ISNULL(strStorageTypeDescription, '') = '' THEN '' ELSE '{ strStorageTypeDescription = "' + strStorageTypeDescription + '" }' END
											+ CASE WHEN ISNULL(ysnActive, '') = '' THEN '' ELSE '{ ysnActive = "' + CAST(ysnActive AS NVARCHAR) + '" }' END
											+ CASE WHEN ISNULL(ysnExternal, '') = '' THEN '' ELSE '{ ysnExternal = "' + CAST(ysnExternal AS NVARCHAR) + '" }' END
			,strNotes						= 'intStorageHistoryId=' + CAST(sh.intStorageHistoryId AS NVARCHAR)
			,intActionId					= CASE 
												WHEN intTransactionTypeId IN (1, 5)
													THEN CASE 
															WHEN sh.intInventoryReceiptId IS NOT NULL THEN 7
															WHEN sh.intInventoryShipmentId IS NOT NULL THEN 41
															ELSE NULL
														END
												WHEN intTransactionTypeId = 4 THEN 37
												WHEN intTransactionTypeId = 9 THEN 20
											END
		FROM vyuGRStorageHistory sh
		JOIN tblGRCustomerStorage cs 
			ON cs.intCustomerStorageId = sh.intCustomerStorageId
		JOIN tblGRStorageType st 
			ON st.intStorageScheduleTypeId = cs.intStorageTypeId 
				AND st.ysnDPOwnedType = 1
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
		LEFT JOIN tblCTContractDetail CD
			ON CD.intContractHeaderId = sh.intContractHeaderId
		WHERE sh.intStorageHistoryId = @intStorageHistoryId
			AND sh.intTransactionTypeId <> 3
		--STORAGE SETTELEMENT AND TRANSFER FROM OP TO DP
		UNION ALL
		SELECT 
			strBucketType	 				= 'Company Owned'
			,strTransactionType 			= 'Storage Settlement'
			,intTransactionRecordId 		= sh.intSettleStorageId
			,intTransactionRecordHeaderId	= sh.intCustomerStorageId
			,strDistributionType 			= st.strStorageTypeDescription
			,strTransactionNumber 			= sh.strSettleTicket
			,dtmTransactionDate				= sh.dtmHistoryDate
			,intContractHeaderId			= sh.intContractHeaderId
			,intContractDetailId			= NULL
			,intTicketId					= sh.intTicketId
			,intCommodityId					= cs.intCommodityId
			,intCommodityUOMId				= cum.intCommodityUnitMeasureId
			,intItemId						= cs.intItemId			
			,intLocationId					= sh.intCompanyLocationId
			,dblQty 						= (CASE WHEN sh.strType = 'Reverse Settlement' THEN - sh.dblUnits ELSE sh.dblUnits END)
			,intEntityId					= cs.intEntityId
			,ysnDelete						= 0
			,intUserId						= sh.intUserId
			,strMiscFields 					= NULL
			,strNotes						= 'intStorageHistoryId = ' + CAST(sh.intStorageHistoryId AS NVARCHAR)
			,intActionId					= 37
		FROM vyuGRStorageHistory sh
		JOIN tblGRCustomerStorage cs 
			ON cs.intCustomerStorageId = sh.intCustomerStorageId
		JOIN tblGRStorageType st 
			ON st.intStorageScheduleTypeId = cs.intStorageTypeId
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
			AND (sh.intTransactionTypeId = 4 AND st.ysnDPOwnedType = 0)
		UNION ALL
		/**TRANSFER STORAGE TRANSACTIONS**/
		--CUSTOMER OWNED STORAGE (FOR TRANSFER STORAGE)
		SELECT
			strBucketType 					= 'Customer Owned'
			,strTransactionType 			= 'Transfer Storage'
			,intTransactionRecordId 		= sh.intTransferStorageReferenceId
			,intTransactionRecordHeaderId	= sh.intTransferStorageId
			,strDistributionType 			= st.strStorageTypeDescription
			,strTransactionNumber 			= sh.strTransferTicket
			,dtmTransactionDate 			= sh.dtmHistoryDate
			,intContractHeaderId			= sh.intContractHeaderId
			,intContractDetailId			= NULL
			,intTicketId					= sh.intTicketId				
			,intCommodityId					= cs.intCommodityId
			,intCommodityUOMId				= cum.intCommodityUnitMeasureId
			,intItemId						= cs.intItemId			
			,intLocationId					= cs.intCompanyLocationId
			,dblQty 						= CASE WHEN ISNULL(@strAction,'') = '' THEN sh.dblUnits ELSE (sh.dblUnits * -1) END
			,intEntityId					= cs.intEntityId			
			,ysnDelete						= 0
			,intUserId						= sh.intUserId
			,strMiscFields					= CASE WHEN ISNULL(strStorageTypeCode, '') = '' THEN '' ELSE '{ strStorageTypeCode = "' + strStorageTypeCode + '" }' END
											+ CASE WHEN ISNULL(ysnReceiptedStorage, '') = '' THEN '' ELSE '{ ysnReceiptedStorage = "' + CAST(ysnReceiptedStorage AS NVARCHAR) + '" }' END
											+ CASE WHEN ISNULL(sh.intTransactionTypeId, '') = '' THEN '' ELSE '{ intTypeId = "' + CAST(sh.intTransactionTypeId AS NVARCHAR) + '" }' END
											+ CASE WHEN ISNULL(strStorageType, '') = '' THEN '' ELSE '{ strStorageType = "' + strStorageType + '" }' END
											+ CASE WHEN ISNULL(cs.intDeliverySheetId, '') = '' THEN '' ELSE '{ intDeliverySheetId = "' + CAST(cs.intDeliverySheetId AS NVARCHAR) + '" }' END
											+ CASE WHEN ISNULL(strTicketStatus, '') = '' THEN '' ELSE '{ strTicketStatus = "' + strTicketStatus + '" }' END
											+ CASE WHEN ISNULL(strOwnedPhysicalStock, '') = '' THEN '' ELSE '{ strOwnedPhysicalStock = "' + strOwnedPhysicalStock + '" }' END
											+ CASE WHEN ISNULL(strStorageTypeDescription, '') = '' THEN '' ELSE '{ strStorageTypeDescription = "' + strStorageTypeDescription + '" }' END
											+ CASE WHEN ISNULL(ysnActive, '') = '' THEN '' ELSE '{ ysnActive = "' + CAST(ysnActive AS NVARCHAR) + '" }' END
											+ CASE WHEN ISNULL(ysnExternal, '') = '' THEN '' ELSE '{ ysnExternal = "' + CAST(ysnExternal AS NVARCHAR) + '" }' END
			,strNotes						= 'intStorageHistoryId=' + CAST(sh.intStorageHistoryId AS NVARCHAR)
			,intActionId					= CASE 
												WHEN ISNULL(@strAction,'') = '' THEN CASE WHEN sh.dblUnits > -1 THEN 33 ELSE 9 END 
												ELSE CASE WHEN sh.dblUnits > -1 THEN 9 ELSE 33 END 
											END
		FROM tblGRStorageHistory sh
		JOIN tblGRCustomerStorage cs 
			ON cs.intCustomerStorageId = sh.intCustomerStorageId
		JOIN tblGRStorageType st 
			ON st.intStorageScheduleTypeId = cs.intStorageTypeId 
				and st.ysnDPOwnedType = 0
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
			AND intTransactionTypeId = 3
		--COMPANY OWNED STORAGE (DP/PRICED LATER)
		UNION ALL
		SELECT 
			strBucketType	 				= 'Delayed Pricing'
			,strTransactionType 			= 'Transfer Storage'
			,intTransactionRecordId 		= sh.intTransferStorageReferenceId
			,intTransactionRecordHeaderId	= sh.intTransferStorageId
			,strDistributionType 			= st.strStorageTypeDescription
			,strTransactionNumber			= sh.strTransferTicket
			,dtmTransactionDate				= sh.dtmHistoryDate
			,intContractHeaderId			= sh.intContractHeaderId
			,intContractDetailId			= CD.intContractDetailId
			,intTicketId 					= sh.intTicketId
			,intCommodityId					= cs.intCommodityId			
			,intCommodityUOMId				= cum.intCommodityUnitMeasureId
			,intItemId						= cs.intItemId
			,intLocationId					= cs.intCompanyLocationId
			,dblQty 						= CASE WHEN ISNULL(@strAction,'') = '' THEN sh.dblUnits ELSE (sh.dblUnits * -1) END
			,intEntityId					= cs.intEntityId
			,ysnDelete						= 0
			,intUserId						= sh.intUserId
			,strMiscFields					= CASE WHEN ISNULL(strStorageTypeCode, '') = '' THEN '' ELSE '{ strStorageTypeCode = "' + strStorageTypeCode + '" }' END
											+ CASE WHEN ISNULL(ysnReceiptedStorage, '') = '' THEN '' ELSE '{ ysnReceiptedStorage = "' + CAST(ysnReceiptedStorage AS NVARCHAR) + '" }' END
											+ CASE WHEN ISNULL(sh.intTransactionTypeId, '') = '' THEN '' ELSE '{ intTypeId = "' + CAST(sh.intTransactionTypeId AS NVARCHAR) + '" }' END
											+ CASE WHEN ISNULL(strStorageType, '') = '' THEN '' ELSE '{ strStorageType = "' + strStorageType + '" }' END
											+ CASE WHEN ISNULL(cs.intDeliverySheetId, '') = '' THEN '' ELSE '{ intDeliverySheetId = "' + CAST(cs.intDeliverySheetId AS NVARCHAR) + '" }' END
											+ CASE WHEN ISNULL(strTicketStatus, '') = '' THEN '' ELSE '{ strTicketStatus = "' + strTicketStatus + '" }' END
											+ CASE WHEN ISNULL(strOwnedPhysicalStock, '') = '' THEN '' ELSE '{ strOwnedPhysicalStock = "' + strOwnedPhysicalStock + '" }' END
											+ CASE WHEN ISNULL(strStorageTypeDescription, '') = '' THEN '' ELSE '{ strStorageTypeDescription = "' + strStorageTypeDescription + '" }' END
											+ CASE WHEN ISNULL(ysnActive, '') = '' THEN '' ELSE '{ ysnActive = "' + CAST(ysnActive AS NVARCHAR) + '" }' END
											+ CASE WHEN ISNULL(ysnExternal, '') = '' THEN '' ELSE '{ ysnExternal = "' + CAST(ysnExternal AS NVARCHAR) + '" }' END
			,strNotes						= 'intStorageHistoryId=' + CAST(sh.intStorageHistoryId AS NVARCHAR)
			,intActionId					= CASE 
												WHEN ISNULL(@strAction,'') = '' THEN CASE WHEN sh.dblUnits > -1 THEN 9 ELSE 33 END 
												ELSE CASE WHEN sh.dblUnits > -1 THEN 33 ELSE 9 END 
											END
		FROM tblGRStorageHistory sh
		JOIN tblGRCustomerStorage cs 
			ON cs.intCustomerStorageId = sh.intCustomerStorageId
		JOIN tblGRStorageType st 
			ON st.intStorageScheduleTypeId = cs.intStorageTypeId 
				AND st.ysnDPOwnedType = 1
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
		LEFT JOIN tblCTContractDetail CD
			ON CD.intContractHeaderId = sh.intContractHeaderId
		WHERE sh.intStorageHistoryId = @intStorageHistoryId
			AND sh.intTransactionTypeId = 3
		--STORAGE SETTELEMENT AND TRANSFER FROM OP TO DP
		UNION ALL
		SELECT 
			strBucketType	 				= 'Company Owned'
			,strTransactionType 			= 'Transfer Storage'
			,intTransactionRecordId 		= sh.intTransferStorageReferenceId
			,intTransactionRecordHeaderId	= sh.intTransferStorageId
			,strDistributionType 			= st.strStorageTypeDescription
			,strTransactionNumber 			= sh.strTransferTicket
			,dtmTransactionDate				= sh.dtmHistoryDate
			,intContractHeaderId			= sh.intContractHeaderId
			,intContractDetailId			= CD.intContractDetailId
			,intTicketId					= sh.intTicketId
			,intCommodityId					= cs.intCommodityId
			,intCommodityUOMId				= cum.intCommodityUnitMeasureId
			,intItemId						= cs.intItemId			
			,intLocationId					= cs.intCompanyLocationId
			,dblQty 						= CASE WHEN ISNULL(@strAction,'') = '' THEN sh.dblUnits ELSE (sh.dblUnits * -1 ) END
			,intEntityId					= cs.intEntityId
			,ysnDelete						= 0
			,intUserId						= sh.intUserId
			,strMiscFields 					= NULL
			,strNotes						= 'intStorageHistoryId = ' + CAST(sh.intStorageHistoryId AS NVARCHAR)
			,intActionId					= CASE 
												WHEN ISNULL(@strAction,'') = '' THEN CASE WHEN sh.dblUnits > -1 THEN 9 ELSE 33 END 
												ELSE CASE WHEN sh.dblUnits > -1 THEN 33 ELSE 9 END 
											END
 		FROM tblGRStorageHistory sh
		JOIN tblGRCustomerStorage cs 
			ON cs.intCustomerStorageId = sh.intCustomerStorageId
		JOIN tblGRStorageType st 
			ON st.intStorageScheduleTypeId = cs.intStorageTypeId
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
		LEFT JOIN tblCTContractDetail CD
			ON CD.intContractHeaderId = sh.intContractHeaderId
		WHERE sh.intStorageHistoryId = @intStorageHistoryId
			AND (sh.intTransactionTypeId = 3 AND st.ysnDPOwnedType = 1)

		UPDATE @SummaryLogs set strTransactionNumber = '' where strTransactionNumber is null
		EXEC uspRKLogRiskPosition @SummaryLogs
	END

END TRY
BEGIN CATCH
	SET @ErrMsg = ERROR_MESSAGE()
	RAISERROR (@ErrMsg,16,1,'WITH NOWAIT')
END CATCH