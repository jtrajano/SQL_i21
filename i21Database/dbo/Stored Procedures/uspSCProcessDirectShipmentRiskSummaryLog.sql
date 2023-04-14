CREATE PROCEDURE [dbo].[uspSCProcessDirectShipmentRiskSummaryLog]
	@IN_OUT_FLAG NVARCHAR(1), --= 'I'
	@TICKET_ID INT, -- = 9992
	@REVERSE BIT,
	@DEBUG_MODE BIT = 0
AS
BEGIN
	DECLARE @SummaryLogs AS RKSummaryLog
	DECLARE @TICKET_TYPE INT = 6	
	DECLARE @MULTIPLIER INT 

	
	SELECT @MULTIPLIER = CASE WHEN @IN_OUT_FLAG = 'I' THEN 1
							WHEN @IN_OUT_FLAG = 'O' THEN -1
							ELSE 1
							END * CASE WHEN @REVERSE = 1 THEN -1 ELSE 1 END
	
	IF @DEBUG_MODE = 1
		SELECT @MULTIPLIER AS [MULTIPLIER]

		--SELECT * FROM tblRKSummaryLog WHERE strBucketType LIKE '%Transit%'
		--SELECT DISTINCT strTransactionType FROM tblRKSummaryLog
		--Sales In-Transit
	-- DPR RELATED VARIABLE
	DECLARE @BUCKET_TYPE NVARCHAR(50) = 'Dropship In-Transit'
	DECLARE @TRANSACTION_TYPE NVARCHAR(50)  -- Direct In // Direct Out
	
	SELECT @TRANSACTION_TYPE = CASE WHEN @IN_OUT_FLAG = 'I' THEN 'Direct In'
									WHEN @IN_OUT_FLAG = 'O' THEN 'Direct Out'
									ELSE 'NONE'
								END 


	DECLARE @ACTION_ID INT = 20


	SELECT @ACTION_ID = CASE WHEN @REVERSE = 0 THEN
							CASE WHEN @IN_OUT_FLAG = 'I' THEN 69
								WHEN @IN_OUT_FLAG = 'O' THEN 70
								ELSE NULL
							END 
						ELSE
							CASE WHEN @IN_OUT_FLAG = 'I' THEN 71
								WHEN @IN_OUT_FLAG = 'O' THEN 72
								ELSE NULL
							END 
						END

	/*
		UNION ALL SELECT 69, 'Distribute Direct In', 'Distribute Direct In.'
		UNION ALL SELECT 70, 'Distribute Direct Out', 'Distribute Direct Out.'
		UNION ALL SELECT 71, 'Undistribute Direct In', 'Undistribute Direct In.'
		UNION ALL SELECT 72, 'Undistribute Direct Out', 'Undistribute Direct Out.'
	*/
	/*
		-- strActionIn
		DIRECT IN / OUT -- ACTION -- Distribute Direct In / Direct Out
		UNDISTRIBUTION -- ACTION -- Undistribute Direct In / Direct Out 
	*/
	
	DECLARE @AFFECTED_CONTRACT TABLE 
	(
		ID INT IDENTITY(1,1),
		CONTRACT_ID INT NOT NULL,
		QUANTITY DECIMAL(30,18),
		TICKET_ID INT NOT NULL
	)


	INSERT INTO @AFFECTED_CONTRACT(
		CONTRACT_ID, 
		QUANTITY,
		TICKET_ID
	)
	SELECT 
		intContractDetailId,
		dblScheduleQty,
		intTicketId

	FROM tblSCTicketContractUsed 
		WHERE intTicketId = @TICKET_ID

	IF @IN_OUT_FLAG = 'I' 
	BEGIN
		INSERT INTO @AFFECTED_CONTRACT(
			CONTRACT_ID, 
			QUANTITY,
			TICKET_ID
		)	
		SELECT
			LOAD_DETAIL.intPContractDetailId,
			LOAD_USED.dblQty,
			LOAD_USED.intTicketId

		FROM tblSCTicketLoadUsed LOAD_USED
			JOIN tblLGLoadDetail LOAD_DETAIL
				ON LOAD_USED.intLoadDetailId = LOAD_DETAIL.intLoadDetailId
			WHERE intTicketId = @TICKET_ID
	END
	ELSE IF @IN_OUT_FLAG = 'O' 
	BEGIN
		INSERT INTO @AFFECTED_CONTRACT(
			CONTRACT_ID, 
			QUANTITY,
			TICKET_ID
		)	
		SELECT
			LOAD_DETAIL.intSContractDetailId,
			LOAD_USED.dblQty,
			LOAD_USED.intTicketId

		FROM tblSCTicketLoadUsed LOAD_USED
			JOIN tblLGLoadDetail LOAD_DETAIL
				ON LOAD_USED.intLoadDetailId = LOAD_DETAIL.intLoadDetailId
			WHERE intTicketId = @TICKET_ID
	END

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
			--,strNotes
			,intActionId
			,strStorageTypeCode 		
			,ysnReceiptedStorage 		
			,intTypeId 					
			,strStorageType 			
			,intDeliverySheetId			
			,strTicketStatus 			
			,strOwnedPhysicalStock 		
			,strStorageTypeDescription 	
			,ysnActive 					
			,ysnExternal 				
			,intStorageHistoryId
		)
		SELECT
			strBucketType 					= @BUCKET_TYPE
			,strTransactionType 			= @TRANSACTION_TYPE
			,intTransactionRecordId 		= TICKET.intTicketId
			,intTransactionRecordHeaderId	= TICKET.intTicketId
			,strDistributionType 			= STORAGE_TYPE.strStorageTypeDescription
			,strTransactionNumber 			= TICKET.strTicketNumber
			,dtmTransactionDate 			= TICKET.dtmTicketDateTime
			,intContractHeaderId			= CONTRACT_DETAIL.intContractHeaderId
			,intContractDetailId			= CONTRACT_DETAIL.intContractDetailId
			,intTicketId					= TICKET.intTicketId				
			,intCommodityId					= ITEM.intCommodityId
			,intCommodityUOMId				= COMMODITY_UOM.intCommodityUnitMeasureId
			,intItemId						= TICKET.intItemId			
			,intLocationId					= TICKET.intProcessingLocationId
			,dblQty 						= TICKET_CONTRACT_USED.QUANTITY * @MULTIPLIER --
			,intEntityId					= TICKET.intEntityId			
			,ysnDelete						= 0
			,intUserId						= TICKET.intEntityScaleOperatorId
			,strMiscFields					= NULL			
			,intActionId					= @ACTION_ID
			,strStorageTypeCode 			= STORAGE_TYPE.strStorageTypeCode
			,ysnReceiptedStorage 			= STORAGE_TYPE.ysnReceiptedStorage
			,intTypeId 						= 1 --sh.intTransactionTypeId
			,strStorageType 				= NULL--strStorageType
			,intDeliverySheetId				= NULL
			,strTicketStatus 				= TICKET.strTicketStatus
			,strOwnedPhysicalStock 			= STORAGE_TYPE.strOwnedPhysicalStock
			,strStorageTypeDescription 		= STORAGE_TYPE.strStorageTypeDescription
			,ysnActive 						= STORAGE_TYPE.ysnActive
			,ysnExternal 					= COMPANY_LOCATION_SUB_LOCATION.ysnExternal
			,intStorageHistoryId 			= NULL
		FROM tblSCTicket TICKET
			JOIN @AFFECTED_CONTRACT TICKET_CONTRACT_USED
				ON TICKET.intTicketId = TICKET_CONTRACT_USED.TICKET_ID
			JOIN tblGRStorageType STORAGE_TYPE
				ON TICKET.intStorageScheduleTypeId = STORAGE_TYPE.intStorageScheduleTypeId
			JOIN tblCTContractDetail CONTRACT_DETAIL
				ON TICKET_CONTRACT_USED.CONTRACT_ID = CONTRACT_DETAIL.intContractDetailId
			JOIN tblICItem ITEM
				ON TICKET.intItemId = ITEM.intItemId 
			JOIN tblICItemUOM ITEM_UOM
				ON TICKET.intItemId = ITEM_UOM.intItemId 
					AND TICKET.intItemUOMIdTo = ITEM_UOM.intItemUOMId					
			JOIN tblICCommodityUnitMeasure COMMODITY_UOM 
				ON ITEM_UOM.intUnitMeasureId = COMMODITY_UOM.intUnitMeasureId 
					AND ITEM.intCommodityId = COMMODITY_UOM.intCommodityId
			LEFT JOIN tblSMCompanyLocationSubLocation COMPANY_LOCATION_SUB_LOCATION
				ON TICKET.intSubLocationId = COMPANY_LOCATION_SUB_LOCATION.intCompanyLocationSubLocationId 
				AND TICKET.intProcessingLocationId = COMPANY_LOCATION_SUB_LOCATION.intCompanyLocationId 
			
		
		WHERE TICKET.intTicketId = @TICKET_ID
			AND TICKET.intTicketType = @TICKET_TYPE
			AND TICKET.strInOutFlag = @IN_OUT_FLAG


	
	IF @DEBUG_MODE = 0
	BEGIN
		EXEC uspRKLogRiskPosition @SummaryLogs, 0 , 0
	END
	ELSE
	BEGIN
		
		SELECT * FROM @SummaryLogs

	END

		
		
END
