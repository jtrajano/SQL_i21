CREATE PROCEDURE [dbo].[uspGRRiskSummaryLog]
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
			,intTransactionRecordHeaderId
			,strDistributionType 		
			,strTransactionNumber 		
			,dtmTransactionDate 		
			,intContractHeaderId
			--,intContractDetailId
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
												WHEN intTransactionTypeId = 3 THEN 'Transfer Storage'
												WHEN intTransactionTypeId = 4 THEN 'Storage Settlement'
												WHEN intTransactionTypeId = 9 THEN 'Inventory Adjustment' 
											END
			,intTransactionRecordId 		= CASE 
												WHEN intTransactionTypeId IN (1, 5)
													THEN
														nullif(coalesce(sh.intInventoryReceiptId, sh.intInventoryShipmentId, sh.intTicketId, -99), -99)
												WHEN intTransactionTypeId = 3 THEN sh.intTransferStorageId
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
												WHEN intTransactionTypeId = 3 THEN sh.strTransferTicket
												WHEN intTransactionTypeId = 4 THEN sh.strSettleTicket
												WHEN intTransactionTypeId = 9 THEN sh.strAdjustmentNo 
											END
			,dtmTransactionDate 			= sh.dtmDistributionDate
			,intContractHeaderId			= sh.intContractHeaderId
			,intTicketId					= sh.intTicketId				
			,intCommodityId					= cs.intCommodityId
			,intCommodityUOMId				= cum.intCommodityUnitMeasureId
			,intItemId						= cs.intItemId			
			,intLocationId					= cs.intCompanyLocationId
			,dblQty 						= (CASE WHEN sh.strType ='Reduced By Inventory Shipment' OR sh.strType = 'Settlement' THEN - sh.dblUnits ELSE sh.dblUnits END)
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
												WHEN intTransactionTypeId = 3 THEN 'Transfer Storage'
												WHEN intTransactionTypeId = 4 THEN 'Storage Settlement'
												WHEN intTransactionTypeId = 9 THEN 'Inventory Adjustment' 
											END
			,intTransactionRecordId 		= CASE 
												WHEN intTransactionTypeId IN (1, 5)
													THEN 
														nullif(coalesce(sh.intInventoryReceiptId, sh.intInventoryShipmentId, sh.intTicketId, -99), -99)
												WHEN intTransactionTypeId = 3 THEN sh.intTransferStorageId
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
												WHEN intTransactionTypeId = 3 THEN sh.strTransferTicket
												WHEN intTransactionTypeId = 4 THEN sh.strSettleTicket
												WHEN intTransactionTypeId = 9 THEN sh.strAdjustmentNo 
											END
			,dtmTransactionDate				= sh.dtmDistributionDate
			,intContractHeaderId			= sh.intContractHeaderId
			,intTicketId 					= sh.intTicketId
			,intCommodityId					= cs.intCommodityId			
			,intCommodityUOMId				= cum.intCommodityUnitMeasureId
			,intItemId						= cs.intItemId
			,intLocationId					= sh.intCompanyLocationId
			,dblQty 						= (CASE WHEN sh.strType ='Reduced By Inventory Shipment' OR sh.strType = 'Settlement' THEN - sh.dblUnits ELSE sh.dblUnits END)			
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
		WHERE sh.intStorageHistoryId = @intStorageHistoryId
		--STORAGE SETTELEMENT AND TRANSFER FROM OP TO DP
		UNION ALL
		SELECT 
			strBucketType	 				= 'Company Owned'
			,strTransactionType 			= CASE 
												WHEN intTransactionTypeId = 3 THEN 'Transfer Storage'
												WHEN intTransactionTypeId = 4 THEN 'Storage Settlement'
											END
			,intTransactionRecordId 		= CASE 
												WHEN intTransactionTypeId = 3 THEN sh.intTransferStorageId
												WHEN intTransactionTypeId = 4 THEN sh.intSettleStorageId
											END
			,intTransactionRecordHeaderId	= CASE 
												WHEN intTransactionTypeId = 3 THEN sh.intTransferCustomerStorageId
												WHEN intTransactionTypeId = 4 THEN sh.intCustomerStorageId
											END
			,strDistributionType 			= st.strStorageTypeDescription
			,strTransactionNumber 			= CASE 
												WHEN intTransactionTypeId = 3 THEN sh.strTransferTicket
												WHEN intTransactionTypeId = 4 THEN sh.strSettleTicket
											END
			,dtmTransactionDate				= sh.dtmDistributionDate
			,intContractHeaderId			= sh.intContractHeaderId
			,intTicketId					= sh.intTicketId
			,intCommodityId					= cs.intCommodityId
			,intCommodityUOMId				= cum.intCommodityUnitMeasureId
			,intItemId						= cs.intItemId			
			,intLocationId					= sh.intCompanyLocationId
			,dblQty 						= CASE 
												WHEN intTransactionTypeId = 3 THEN sh.dblUnits * -1
												WHEN intTransactionTypeId = 4 THEN (CASE WHEN sh.strType = 'Reverse Settlement' THEN - sh.dblUnits ELSE sh.dblUnits END)
											END
			,intEntityId					= cs.intEntityId
			,ysnDelete						= 0
			,intUserId						= sh.intUserId
			,strMiscFields 					= NULL
			,strNotes						= 'intStorageHistoryId = ' + CAST(sh.intStorageHistoryId AS NVARCHAR)
		FROM vyuGRStorageHistory sh
		JOIN tblGRCustomerStorage cs 
			ON cs.intCustomerStorageId = sh.intCustomerStorageId
		JOIN tblGRStorageType st 
			ON st.intStorageScheduleTypeId = cs.intStorageTypeId 
				--AND st.ysnDPOwnedType = 0
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
			AND ((sh.intTransactionTypeId = 4 AND st.ysnDPOwnedType = 0) OR (sh.intTransactionTypeId = 3 AND st.ysnDPOwnedType = 1))
		--SELECT 
		--	strBucketType	 				= 'Company Owned'
		--	,strTransactionType 			= 'Storage Settlement'
		--	,intTransactionRecordId 		= sh.intSettleStorageId
		--	,intTransactionRecordHeaderId	= sh.intCustomerStorageId
		--	,strDistributionType 			= st.strStorageTypeDescription
		--	,strTransactionNumber 			= sh.strSettleTicket
		--	,dtmTransactionDate				= (CASE WHEN sh.strType = 'Transfer' THEN RIGHT(CONVERT(VARCHAR(11), sh.dtmHistoryDate, 106), 8) ELSE RIGHT(CONVERT(VARCHAR(11), cs.dtmDeliveryDate, 106), 8) END) COLLATE Latin1_General_CI_AS
		--	,intContractHeaderId			= sh.intContractHeaderId
		--	,intTicketId					= sh.intTicketId
		--	,intCommodityId					= cs.intCommodityId
		--	,intCommodityUOMId				= cum.intCommodityUnitMeasureId
		--	,intItemId						= cs.intItemId			
		--	,intLocationId					= sh.intCompanyLocationId
		--	,dblQty 						= (CASE WHEN sh.strType = 'Reverse Settlement' THEN - sh.dblUnits ELSE sh.dblUnits END)
		--	,intEntityId					= cs.intEntityId
		--	,ysnDelete						= 0
		--	,intUserId						= sh.intUserId
		--	,strMiscFields 					= NULL
		--	,strNotes						= 'intStorageHistoryId=' + CAST(sh.intStorageHistoryId AS NVARCHAR)
		--FROM vyuGRStorageHistory sh
		--JOIN tblGRCustomerStorage cs 
		--	ON cs.intCustomerStorageId = sh.intCustomerStorageId
		--JOIN tblGRStorageType st 
		--	ON st.intStorageScheduleTypeId = cs.intStorageTypeId 
		--		AND ysnDPOwnedType = 0
		--JOIN tblICItemUOM iuom 
		--	ON iuom.intItemUOMId = cs.intItemUOMId
		--JOIN tblICCommodityUnitMeasure cum 
		--	ON cum.intUnitMeasureId = iuom.intUnitMeasureId 
		--		AND cum.intCommodityId = cs.intCommodityId
		--LEFT JOIN tblSCTicket t 
		--	ON t.intTicketId = sh.intTicketId
		--LEFT JOIN tblSMCompanyLocationSubLocation sl 
		--	ON sl.intCompanyLocationSubLocationId = t.intSubLocationId 
		--		AND sl.intCompanyLocationId = t.intProcessingLocationId
		--WHERE sh.intTransactionTypeId = 4
		--	AND sh.intStorageHistoryId = @intStorageHistoryId
		
		UPDATE @SummaryLogs set strTransactionNumber = '' where strTransactionNumber is null
		EXEC uspRKLogRiskPosition @SummaryLogs
	END

END TRY
BEGIN CATCH
	SET @ErrMsg = ERROR_MESSAGE()
	RAISERROR (@ErrMsg,16,1,'WITH NOWAIT')
END CATCH