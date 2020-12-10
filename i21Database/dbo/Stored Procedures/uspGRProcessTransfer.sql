﻿CREATE PROCEDURE [dbo].[uspGRProcessTransfer]
(
	@intTransferStorageId INT,
	@intUserId INT,
	@intFutureMarketId INT = NULL,
	@intFutureMonthId INT = NULL
)
AS
BEGIN
	SET QUOTED_IDENTIFIER OFF
	SET ANSI_NULLS ON
	SET NOCOUNT ON
	SET XACT_ABORT ON
	SET ANSI_WARNINGS OFF	

	DECLARE @ErrMsg AS NVARCHAR(MAX)
	DECLARE @StorageHistoryStagingTable AS StorageHistoryStagingTable
	DECLARE @CustomerStorageStagingTable AS CustomerStorageStagingTable
	DECLARE @CurrentItemOpenBalance DECIMAL(38,20)
	DECLARE @intTransferContractDetailId INT
	DECLARE @dblTransferUnits NUMERIC(18,6)
	DECLARE @intSourceItemUOMId INT
	DECLARE @intCustomerStorageId INT --new customer storage id
	DECLARE @intStorageHistoryId INT = 0
	DECLARE @intDecimalPrecision INT = 20
	DECLARE @intTransferStorageSplitId INT
	DECLARE @intTransactionDetailId INT
	DECLARE @XML NVARCHAR(MAX)
	DECLARE @strScreenName NVARCHAR(50)
	DECLARE @intNewContractHeaderId INT
	DECLARE @intNewContractDetailId INT
	DECLARE @intEntityId INT
	DECLARE @intToEntityId INT
	
	DECLARE @newCustomerStorageIds AS TABLE 
	(
		intToCustomerStorageId INT
		,intTransferStorageSplitId INT
		,intSourceCustomerStorageId INT
		,dblUnitQty NUMERIC(38,20)
		,dblSplitPercent NUMERIC(38,20)
		,dtmProcessDate DATETIME NOT NULL DEFAULT(GETDATE())
	)
	DECLARE @GLForItem AS GLForItem
	SELECT @intDecimalPrecision = intCurrencyDecimal FROM tblSMCompanyPreference
	DECLARE @intTransferStorageReferenceId INT
	
	---START---TRANSACTIONS FOR THE SOURCE-----	
	IF EXISTS(SELECT TOP 1 1 
			FROM tblGRCustomerStorage A 
			INNER JOIN tblGRTransferStorageSourceSplit B 
				ON B.intSourceCustomerStorageId = A.intCustomerStorageId 
			WHERE B.intTransferStorageId = @intTransferStorageId AND B.dblOriginalUnits <> A.dblOpenBalance
	)
	BEGIN
		DECLARE @TicketNo VARCHAR(50)

		SELECT @TicketNo = STUFF((
			SELECT ',' + strStorageTicketNumber 
			FROM tblGRCustomerStorage A 
			INNER JOIN tblGRTransferStorageSourceSplit B 
				ON B.intSourceCustomerStorageId = A.intCustomerStorageId 
			WHERE B.intTransferStorageId = @intTransferStorageId AND B.dblOriginalUnits <> A.dblOpenBalance
			FOR XML PATH('')
		),1,1,'')
		
		SET @ErrMsg = 'The Open balance of ticket ' + @TicketNo + ' has been modified by another user.  Transfer process cannot proceed.'
		
		RAISERROR(@ErrMsg,16,1)
		RETURN;
	END
	
	BEGIN TRANSACTION
	BEGIN TRY
		DECLARE @cnt INT = 0

		SET @cnt = (SELECT COUNT(*) FROM tblGRTransferStorageSourceSplit WHERE intTransferStorageId = @intTransferStorageId AND intContractDetailId IS NOT NULL)

		DECLARE c CURSOR LOCAL STATIC READ_ONLY FORWARD_ONLY
		FOR
		WITH sourceStorageDetails (
			intTransferContractDetailId 
			,dblTransferUnits			
			,intSourceItemUOMId			
			,intCustomerStorageId
		) AS (
			SELECT intTransferContractDetailId	= SourceSplit.intContractDetailId,
				dblTransferUnits				= -CASE WHEN (SourceSplit.dblOriginalUnits - SourceSplit.dblDeductedUnits) = 0 THEN SourceSplit.dblOriginalUnits ELSE SourceSplit.dblDeductedUnits END ,
				intSourceItemUOMId				= TransferStorage.intItemUOMId,
				intCustomerStorageId			= SourceSplit.intSourceCustomerStorageId
			FROM tblGRTransferStorageSourceSplit SourceSplit
			INNER JOIN tblGRTransferStorage TransferStorage
				ON TransferStorage.intTransferStorageId = SourceSplit.intTransferStorageId
			WHERE SourceSplit.intTransferStorageId = @intTransferStorageId
				AND SourceSplit.intContractDetailId IS NOT NULL
		)
		SELECT
			intTransferContractDetailId 
			,dblTransferUnits			
			,intSourceItemUOMId			
			,intCustomerStorageId
		FROM ( SELECT * FROM sourceStorageDetails ) params
		
		OPEN c;

		FETCH c INTO @intTransferContractDetailId, @dblTransferUnits, @intSourceItemUOMId, @intCustomerStorageId

		WHILE @@FETCH_STATUS = 0 AND @cnt > 0
		BEGIN
			EXEC uspCTUpdateSequenceQuantityUsingUOM 
				@intContractDetailId	= @intTransferContractDetailId
				,@dblQuantityToUpdate	= @dblTransferUnits
				,@intUserId				= @intUserId
				,@intExternalId			= @intTransferStorageId
				,@strScreenName			= 'Transfer Storage'
				,@intSourceItemUOMId	= @intSourceItemUOMId

			FETCH c INTO @intTransferContractDetailId, @dblTransferUnits, @intSourceItemUOMId, @intCustomerStorageId
		END
		CLOSE c; DEALLOCATE c;
		
		--update the source's customer storage open balance
		UPDATE A
		SET A.dblOpenBalance 	= ROUND(B.dblOriginalUnits - B.dblDeductedUnits,6)
		FROM tblGRCustomerStorage A 
		INNER JOIN tblGRTransferStorageSourceSplit B 
			ON B.intSourceCustomerStorageId = A.intCustomerStorageId
		WHERE B.intTransferStorageId = @intTransferStorageId
		
		DELETE FROM @StorageHistoryStagingTable
		--insert history for the old (source) customer storage		
		INSERT INTO @StorageHistoryStagingTable
		(
			[intCustomerStorageId]
			,[intTransferStorageId]
			,[intContractHeaderId]
			,[dblUnits]
			,[dtmHistoryDate]
			,[intUserId]
			,[ysnPost]
			,[intTransactionTypeId]
			,[strPaidDescription]
			,[strType]
			,[strTransferTicket]
		)
		SELECT
			[intCustomerStorageId]	= SourceSplit.intSourceCustomerStorageId
			,[intTransferStorageId]	= SourceSplit.intTransferStorageId
			,[intContractHeaderId]	= CD.intContractHeaderId
			,[dblUnits]				= -(SourceSplit.dblOriginalUnits * (TransferStorageSplit.dblSplitPercent / 100))
			,[dtmHistoryDate]		= GETDATE()
			,[intUserId]			= @intUserId
			,[ysnPost]				= 1
			,[intTransactionTypeId]	= 3
			,[strPaidDescription]	= 'Generated from Transfer Storage'
			,[strType]				= 'Transfer'
			,[strTransferTicket]	= TS.strTransferStorageTicket
		FROM tblGRTransferStorageSourceSplit SourceSplit
		LEFT JOIN tblCTContractDetail CD
			ON CD.intContractDetailId = SourceSplit.intContractDetailId
		INNER JOIN tblGRTransferStorage TS
			ON TS.intTransferStorageId = SourceSplit.intTransferStorageId
		INNER JOIN tblGRTransferStorageSplit TransferStorageSplit
			ON TransferStorageSplit.intTransferStorageId = SourceSplit.intTransferStorageId	
		WHERE SourceSplit.intTransferStorageId = @intTransferStorageId	
		
		EXEC uspGRInsertStorageHistoryRecord @StorageHistoryStagingTable, @intStorageHistoryId		
		----END----TRANSACTIONS FOR THE SOURCE---------
		
		----START--TRANSACTIONS FOR THE NEW CUSTOMER STORAGE-------
		DELETE FROM @StorageHistoryStagingTable
		
		INSERT INTO @CustomerStorageStagingTable
		(
			[intEntityId]				
			,[intCommodityId]			
			,[intStorageScheduleId]		
			,[intStorageTypeId]			
			,[intCompanyLocationId]		
			,[intDiscountScheduleId]	
			,[dblTotalPriceShrink]		
			,[dblTotalWeightShrink]		
			,[dblQuantity]				
			,[dtmDeliveryDate]			
			,[dtmZeroBalanceDate]		
			,[strDPARecieptNumber]		
			,[dtmLastStorageAccrueDate]	
			,[dblStorageDue]			
			,[dblStoragePaid]			
			,[dblInsuranceRate]			
			,[strOriginState]			
			,[strInsuranceState]		
			,[dblFeesDue]				
			,[dblFeesPaid]				
			,[dblFreightDueRate]		
			,[ysnPrinted]				
			,[dblCurrencyRate]			
			,[strDiscountComment]		
			,[dblDiscountsDue]			
			,[dblDiscountsPaid]			
			,[strCustomerReference]		
			,[intCurrencyId]			
			,[strTransactionNumber]		
			,[intItemId]				
			,[intItemUOMId]
			,[intTransferStorageSplitId]
			,[intUnitMeasureId]
			,[intCompanyLocationSubLocationId]
			,[intStorageLocationId]
			,[intTicketId]
			,[intDeliverySheetId]
			,[ysnTransferStorage]
			,[dblGrossQuantity]
			,[intSourceCustomerStorageId]
			,[dblUnitQty]
			,[dblSplitPercent]
		)	
		SELECT 
			[intEntityId]						= TransferStorageSplit.intEntityId
			,[intCommodityId]					= CS.intCommodityId
			,[intStorageScheduleId]				= TransferStorageSplit.intStorageScheduleId
			,[intStorageTypeId]					= TransferStorageSplit.intStorageTypeId
			,[intCompanyLocationId]				= TransferStorageSplit.intCompanyLocationId
			,[intDiscountScheduleId]			= CS.intDiscountScheduleId
			,[dblTotalPriceShrink]				= CS.dblTotalPriceShrink		
			,[dblTotalWeightShrink]				= CS.dblTotalWeightShrink		
			,[dblQuantity]						= SourceStorage.dblOriginalUnits * (TransferStorageSplit.dblSplitPercent / 100)
			,[dtmDeliveryDate]					= CS.dtmDeliveryDate
			,[dtmZeroBalanceDate]				= CS.dtmZeroBalanceDate			
			,[strDPARecieptNumber]				= CS.strDPARecieptNumber		
			,[dtmLastStorageAccrueDate]			= CS.dtmLastStorageAccrueDate	
			,[dblStorageDue]					= CS.dblStorageDue				--storage charge will have its own computation
			,[dblStoragePaid]					= 0
			,[dblInsuranceRate]					= 0
			,[strOriginState]					= CS.strOriginState
			,[strInsuranceState]				= CS.strInsuranceState
			,[dblFeesDue]						= CS.dblFeesDue					
			,[dblFeesPaid]						= CS.dblFeesPaid				
			,[dblFreightDueRate]				= CS.dblFreightDueRate			
			,[ysnPrinted]						= CS.ysnPrinted					
			,[dblCurrencyRate]					= CS.dblCurrencyRate
			,[strDiscountComment]				= CS.strDiscountComment			
			,[dblDiscountsDue]					= CS.dblDiscountsDue			
			,[dblDiscountsPaid]					= CS.dblDiscountsPaid			
			,[strCustomerReference]				= CS.strCustomerReference		
			,[intCurrencyId]					= CS.intCurrencyId
			,[strTransactionNumber]				= CS.strStorageTicketNumber--TS.strTransferStorageTicket
			,[intItemId]						= CS.intItemId
			,[intItemUOMId]						= CS.intItemUOMId
			,[intTransferStorageSplitId]		= TransferStorageSplit.intTransferStorageSplitId
			,[intUnitMeasureId]					= (SELECT intUnitMeasureId FROM tblICItemUOM WHERE intItemUOMId = CS.intItemUOMId)
			,[intCompanyLocationSubLocationId]	= CASE WHEN CS.intCompanyLocationId = TransferStorageSplit.intCompanyLocationId THEN CS.intCompanyLocationSubLocationId ELSE NULL END
			,[intStorageLocationId]				= CASE WHEN CS.intCompanyLocationId = TransferStorageSplit.intCompanyLocationId THEN CS.intStorageLocationId ELSE NULL END
			,[intTicketId]						= CS.intTicketId
			,[intDeliverySheetId]				= CS.intDeliverySheetId
			,[ysnTransferStorage]				= 1
			,[dblGrossQuantity]					= ROUND(((SourceStorage.dblOriginalUnits * (TransferStorageSplit.dblSplitPercent / 100)) / CS.dblOriginalBalance) * CS.dblGrossQuantity,@intDecimalPrecision)
			,[intSourceCustomerStorageId]		= CS.intCustomerStorageId
			,[dblUnitQty]						= SourceStorage.dblOriginalUnits * (TransferStorageSplit.dblSplitPercent / 100)
			,[intSplitPercent]					= TransferStorageSplit.dblSplitPercent
		FROM tblGRCustomerStorage CS
		INNER JOIN tblGRTransferStorageSourceSplit SourceStorage
			ON SourceStorage.intSourceCustomerStorageId = CS.intCustomerStorageId
		INNER JOIN tblGRTransferStorage TS
			ON TS.intTransferStorageId = SourceStorage.intTransferStorageId
		INNER JOIN tblGRTransferStorageSplit TransferStorageSplit
			ON TransferStorageSplit.intTransferStorageId = SourceStorage.intTransferStorageId
		WHERE SourceStorage.intTransferStorageId = @intTransferStorageId

		--SELECT * FROM @CustomerStorageStagingTable

		MERGE INTO tblGRCustomerStorage AS destination
		USING
		(
			SELECT * FROM @CustomerStorageStagingTable
		) AS SourceData
		ON (1=0)
		WHEN NOT MATCHED THEN
		INSERT
		(
			[intConcurrencyId]
			,[intEntityId]
			,[intCommodityId]
			,[intStorageScheduleId]
			,[intStorageTypeId]
			,[intCompanyLocationId]
			,[intDiscountScheduleId]
			,[dblTotalPriceShrink]
			,[dblTotalWeightShrink]
			,[dblOriginalBalance]
			,[dblOpenBalance]
			,[dtmDeliveryDate]
			,[dtmZeroBalanceDate]
			,[strDPARecieptNumber]
			,[dtmLastStorageAccrueDate]					
			,[dblStorageDue]
			,[dblStoragePaid]
			,[dblInsuranceRate]
			,[strOriginState]
			,[strInsuranceState]
			,[dblFeesDue]
			,[dblFeesPaid]
			,[dblFreightDueRate]
			,[ysnPrinted]
			,[dblCurrencyRate]
			,[strDiscountComment]
			,[dblDiscountsDue]
			,[dblDiscountsPaid]
			,[strCustomerReference]
			,[intCurrencyId]
			,[strStorageTicketNumber]
			,[intItemId]
			,[intItemUOMId]
			,[intUnitMeasureId]
			,[intCompanyLocationSubLocationId]
			,[intStorageLocationId]
			,[intTicketId]
			,[intDeliverySheetId]
			,[ysnTransferStorage]
			,[dblGrossQuantity]
		)
		VALUES
		(
			1
			,[intEntityId]				
			,[intCommodityId]			
			,[intStorageScheduleId]		
			,[intStorageTypeId]			
			,[intCompanyLocationId]		
			,[intDiscountScheduleId]	
			,[dblTotalPriceShrink]		
			,[dblTotalWeightShrink]		
			,[dblQuantity]				
			,[dblQuantity]
			,[dtmDeliveryDate]			
			,[dtmZeroBalanceDate]		
			,[strDPARecieptNumber]		
			,[dtmLastStorageAccrueDate]	
			,[dblStorageDue]			
			,[dblStoragePaid]			
			,[dblInsuranceRate]			
			,[strOriginState]			
			,[strInsuranceState]		
			,[dblFeesDue]				
			,[dblFeesPaid]				
			,[dblFreightDueRate]		
			,[ysnPrinted]				
			,[dblCurrencyRate]			
			,[strDiscountComment]		
			,[dblDiscountsDue]			
			,[dblDiscountsPaid]			
			,[strCustomerReference]		
			,[intCurrencyId]			
			,[strTransactionNumber]		
			,[intItemId]				
			,[intItemUOMId]		
			,[intUnitMeasureId]
			,[intCompanyLocationSubLocationId]
			,[intStorageLocationId]
			,[intTicketId]
			,[intDeliverySheetId]
			,[ysnTransferStorage]
			,[dblGrossQuantity]
		)
		OUTPUT
			inserted.intCustomerStorageId,
			SourceData.intTransferStorageSplitId,
			SourceData.[intSourceCustomerStorageId],
			SourceData.dblUnitQty,
			SourceData.dblSplitPercent,
			GETDATE()
		INTO @newCustomerStorageIds;


		INSERT INTO tblGRTransferStorageReference
		SELECT intSourceCustomerStorageId,intToCustomerStorageId,intTransferStorageSplitId,@intTransferStorageId,dblUnitQty,dblSplitPercent,dtmProcessDate FROM @newCustomerStorageIds
		SET @intTransferStorageReferenceId = SCOPE_IDENTITY()

		--GRN-2138 - COST ADJUSTMENT LOGIC FOR DELIVERY SHEETS
		DECLARE @SettleVoucherCreate AS SettleVoucherCreate
		DECLARE @intTransferStorageReferenceId2 INT
		DECLARE c CURSOR LOCAL STATIC READ_ONLY FORWARD_ONLY
		FOR
		WITH storageTransfers (
			intTranferStorageReferenceId
		) AS (
			SELECT SR.intTransferStorageReferenceId
			FROM tblGRTransferStorageReference SR
			INNER JOIN tblGRCustomerStorage CS 
				ON CS.intCustomerStorageId = SR.intSourceCustomerStorageId AND CS.intDeliverySheetId IS NOT NULL
			INNER JOIN tblGRStorageType ST
				ON ST.intStorageScheduleTypeId = CS.intStorageTypeId
					AND ST.ysnDPOwnedType = 1
			WHERE SR.intTransferStorageId = @intTransferStorageId
		)
		SELECT
			intTranferStorageReferenceId
		FROM ( SELECT * FROM storageTransfers ) params
		OPEN c;

		FETCH c INTO @intTransferStorageReferenceId2

		WHILE @@FETCH_STATUS = 0
		BEGIN
			EXEC uspGRStorageInventoryReceipt 
				@SettleVoucherCreate = @SettleVoucherCreate
				,@intTransferStorageReferenceId = @intTransferStorageReferenceId2
				,@ysnUnpost = 0

			FETCH c INTO @intTransferStorageReferenceId2
		END
		CLOSE c; DEALLOCATE c;
		--
		IF(ISNULL(@intTransferStorageReferenceId,0) > 0)
		BEGIN
			DECLARE @ItemsToPost AS ItemCostingTableType
			DECLARE @ItemsToPost_DPtoOS AS ItemCostingTableType
			DECLARE @ItemsToPost_OStoDP AS ItemCostingTableType
				
			INSERT INTO @ItemsToPost 
			(
				intItemId
				,intItemLocationId
				,intItemUOMId
				,dtmDate
				,dblQty
				,dblUOMQty
				,dblCost
				,dblSalesPrice
				,intCurrencyId
				,dblExchangeRate
				,intTransactionId
				,intTransactionDetailId
				,strTransactionId
				,intTransactionTypeId
				,intLotId
				,intSubLocationId
				,intStorageLocationId
				,ysnIsStorage
				,intStorageScheduleTypeId
			)
			SELECT 
				ToStorage.intItemId				
				,IL.intItemLocationId 
				,ToStorage.intItemUOMId
				,dtmTransferStorageDate
				,dbo.fnCTConvertQuantityToTargetItemUOM(ToStorage.intItemId, IU.intUnitMeasureId, ToStorage.intUnitMeasureId, SR.dblUnitQty) * CASE WHEN (FromType.ysnDPOwnedType = 0 AND ToType.ysnDPOwnedType = 1) THEN -1 ELSE 1 END
				,IU.dblUnitQty
				,0
				,dblSalesPrice = 0
				,ToStorage.intCurrencyId
				,dblExchangeRate = 1
				,intTransactionId = SR.intTransferStorageId
				,intTransactionDetailId = SR.intTransferStorageReferenceId
				,strTransactionId = TS.strTransferStorageTicket
				,intTransactionTypeId = 56
				,intLotId = NULL
				,intSubLocationId = ToStorage.intCompanyLocationSubLocationId
				,intStorageLocationId = ToStorage.intStorageLocationId
				,ysnIsStorage = CASE WHEN (FromType.ysnDPOwnedType = 0 AND ToType.ysnDPOwnedType = 1) THEN 1 ELSE 0 END
				,ToStorage.intStorageTypeId
			FROM tblGRTransferStorageReference SR
			INNER JOIN tblGRCustomerStorage FromStorage
				ON FromStorage.intCustomerStorageId = SR.intSourceCustomerStorageId
			INNER JOIN tblGRStorageType FromType
				ON FromType.intStorageScheduleTypeId = FromStorage.intStorageTypeId
			INNER JOIN tblGRCustomerStorage ToStorage
				ON ToStorage.intCustomerStorageId = SR.intToCustomerStorageId
			INNER JOIN tblGRStorageType ToType
				ON ToType.intStorageScheduleTypeId = ToStorage.intStorageTypeId
			JOIN tblICItemUOM IU
				ON IU.intItemId = ToStorage.intItemId
					AND IU.ysnStockUnit = 1
			INNER JOIN tblICItemLocation IL
				ON IL.intItemId = ToStorage.intItemId 
					AND IL.intLocationId = ToStorage.intCompanyLocationId
			INNER JOIN tblGRTransferStorage TS
				ON SR.intTransferStorageId = TS.intTransferStorageId
			WHERE  ((FromType.ysnDPOwnedType = 0 AND ToType.ysnDPOwnedType = 1) OR (FromType.ysnDPOwnedType = 1 AND ToType.ysnDPOwnedType = 0)) AND SR.intTransferStorageId = @intTransferStorageId
			ORDER BY dtmTransferStorageDate

			INSERT INTO @ItemsToPost_DPtoOS
			(
				intItemId
				,intItemLocationId
				,intItemUOMId
				,dtmDate
				,dblQty
				,dblUOMQty
				,dblCost
				,dblSalesPrice
				,intCurrencyId
				,dblExchangeRate
				,intTransactionId
				,intTransactionDetailId
				,strTransactionId
				,intTransactionTypeId
				,intLotId
				,intSubLocationId
				,intStorageLocationId
				,ysnIsStorage
				,intStorageScheduleTypeId
			) SELECT intItemId
				,intItemLocationId
				,intItemUOMId
				,dtmDate
				,dblQty
				,dblUOMQty
				,dblCost
				,dblSalesPrice
				,intCurrencyId
				,dblExchangeRate
				,intTransactionId
				,intTransactionDetailId
				,strTransactionId
				,intTransactionTypeId
				,intLotId
				,intSubLocationId
				,intStorageLocationId
				,ysnIsStorage
				,intStorageScheduleTypeId 
			FROM @ItemsToPost
			WHERE ysnIsStorage = 0

			INSERT INTO @ItemsToPost_OStoDP
			(
				intItemId
				,intItemLocationId
				,intItemUOMId
				,dtmDate
				,dblQty
				,dblUOMQty
				,dblCost
				,dblSalesPrice
				,intCurrencyId
				,dblExchangeRate
				,intTransactionId
				,intTransactionDetailId
				,strTransactionId
				,intTransactionTypeId
				,intLotId
				,intSubLocationId
				,intStorageLocationId
				,ysnIsStorage
				,intStorageScheduleTypeId
			) SELECT intItemId
				,intItemLocationId
				,intItemUOMId
				,dtmDate
				,dblQty
				,dblUOMQty
				,dblCost
				,dblSalesPrice
				,intCurrencyId
				,dblExchangeRate
				,intTransactionId
				,intTransactionDetailId
				,strTransactionId
				,intTransactionTypeId
				,intLotId
				,intSubLocationId
				,intStorageLocationId
				,ysnIsStorage
				,intStorageScheduleTypeId 
			FROM @ItemsToPost
			WHERE ysnIsStorage = 1

			EXEC uspGRTransferStorage_DPtoOS_InventoryPost
				@ItemsToPost = @ItemsToPost_DPtoOS
				,@intTransferStorageId = @intTransferStorageId
				,@intUserId = @intUserId
				
			EXEC uspGRTransferStorage_OStoDP_InventoryPost
				@ItemsToPost = @ItemsToPost_OStoDP
				,@intTransferStorageId = @intTransferStorageId
				,@intUserId = @intUserId
				,@intFutureMarketId = @intFutureMarketId
				,@intFutureMonthId = @intFutureMonthId
			
			--/*start === FOR DP to DP only*/
			DECLARE @strBatchId NVARCHAR(500)
			DECLARE @dblBasis DECIMAL(38,20)
			DECLARE @dblSettlementPrice DECIMAL(38,20)
			DECLARE @GLEntries RecapTableType
			DECLARE @strRKError NVARCHAR(150)
			DECLARE @intSourceTransactionDetailId INT
			DECLARE @intSourceCustomerStorageId INT
			DECLARE @ysnFromDS BIT
			DECLARE @GLValidation AS TABLE (
				strText nvarchar(150)  COLLATE Latin1_General_CI_AS NULL,
				intErrorCode int, 
				strModuleName nvarchar(100)  COLLATE Latin1_General_CI_AS NULL
			)
			SET @intTransferStorageReferenceId = NULL

			DECLARE c CURSOR LOCAL STATIC READ_ONLY FORWARD_ONLY
			FOR
			WITH storageTransfers (
				intTranferStorageReferenceId
				,dblBasis
				,dblSettlementPrice
				,intSourceCustomerStorageId
				,ysnFromDS
			) AS (
				SELECT SR.intTransferStorageReferenceId, CS_FROM.dblBasis,CS_FROM.dblSettlementPrice,CS_FROM.intCustomerStorageId,CASE WHEN CS_FROM.intDeliverySheetId IS NULL THEN 0 ELSE 1 END
				FROM tblGRTransferStorageReference SR
				INNER JOIN tblGRCustomerStorage CS_FROM ON CS_FROM.intCustomerStorageId = SR.intSourceCustomerStorageId
				INNER JOIN tblGRStorageType ST_FROM ON ST_FROM.intStorageScheduleTypeId = CS_FROM.intStorageTypeId AND ST_FROM.ysnDPOwnedType = 1
				INNER JOIN tblGRCustomerStorage CS_TO ON CS_TO.intCustomerStorageId = SR.intToCustomerStorageId
				INNER JOIN tblGRStorageType ST_TO ON ST_TO.intStorageScheduleTypeId = CS_TO.intStorageTypeId AND ST_TO.ysnDPOwnedType = 1
				WHERE SR.intTransferStorageId = @intTransferStorageId
			)
			SELECT
				intTranferStorageReferenceId
				,dblBasis
				,dblSettlementPrice
				,intSourceCustomerStorageId
				,ysnFromDS
			FROM ( SELECT * FROM storageTransfers ) params
			OPEN c;

			FETCH c INTO @intTransferStorageReferenceId,@dblBasis,@dblSettlementPrice,@intSourceCustomerStorageId,@ysnFromDS

			WHILE @@FETCH_STATUS = 0
			BEGIN
				EXEC uspSMGetStartingNumber 3, @strBatchId OUT
				--update the Basis and Settlement Price of the new customer storage
				--just get the basis and settlement priced from the source storages

				IF @dblBasis IS NULL AND @dblSettlementPrice IS NULL
				BEGIN
					SELECT @dblSettlementPrice	 = IRI.dblUnitCost
					FROM tblICInventoryReceiptItem IRI
					INNER JOIN tblICInventoryReceipt IR
						ON IR.intInventoryReceiptId = IRI.intInventoryReceiptId
					INNER JOIN tblGRStorageHistory SH
						ON SH.intInventoryReceiptId = IR.intInventoryReceiptId
							AND SH.intTransactionTypeId = 1 --From Scale
					WHERE SH.intCustomerStorageId = @intSourceCustomerStorageId
				END

				UPDATE CS
				SET dblBasis = ISNULL(@dblBasis,0)
					,dblSettlementPrice = ISNULL(@dblSettlementPrice,0)
				FROM tblGRCustomerStorage CS
				INNER JOIN tblGRTransferStorageReference SR ON SR.intToCustomerStorageId = CS.intCustomerStorageId
				WHERE SR.intTransferStorageReferenceId = @intTransferStorageReferenceId

				SELECT DISTINCT @intSourceTransactionDetailId = TSR.intTransferStorageReferenceId
				FROM tblGRTransferStorage TS
				INNER JOIN tblGRTransferStorageReference TSR
					ON TSR.intTransferStorageId = TS.intTransferStorageId
						AND TSR.intToCustomerStorageId = @intSourceCustomerStorageId

				--GET IR# IF STORAGE IS FROM SCALE TICKET
				IF @intSourceTransactionDetailId IS NULL
				BEGIN
					SELECT @intSourceTransactionDetailId = intInventoryReceiptId
					FROM tblGRStorageHistory
					WHERE intCustomerStorageId = @intSourceCustomerStorageId
						AND intTransactionTypeId = 1
				END

				--inventory items
				DELETE FROM @GLEntries
				INSERT INTO @GLEntries 
				(
					[dtmDate]
					,[strBatchId]
					,[intAccountId]
					,[dblDebit]
					,[dblCredit]
					,[dblDebitUnit]
					,[dblCreditUnit]
					,[strDescription]
					,[strCode]
					,[strReference]
					,[intCurrencyId]
					,[dblExchangeRate]
					,[dtmDateEntered]
					,[dtmTransactionDate]
					,[strJournalLineDescription]
					,[intJournalLineNo]
					,[ysnIsUnposted]
					,[intUserId]
					,[intEntityId]
					,[strTransactionId]
					,[intTransactionId]
					,[strTransactionType]
					,[strTransactionForm]
					,[strModuleName]
					,[intConcurrencyId]
					,[dblDebitForeign]
					,[dblDebitReport]
					,[dblCreditForeign]
					,[dblCreditReport]
					,[dblReportingRate]
					,[dblForeignRate]
					,[strRateType]
				)
				EXEC uspGRCreateItemGLEntriesTransfer_DPtoDP 
					@strBatchId  = @strBatchId
					,@intEntityUserSecurityId = @intUserId
					,@intTransactionDetailId = @intTransferStorageReferenceId
					,@intSourceTransactionDetailId = @intSourceTransactionDetailId

				IF @ysnFromDS = 0 
				BEGIN
					INSERT INTO @GLEntries 
					(
						[dtmDate]
						,[strBatchId]
						,[intAccountId]
						,[dblDebit]
						,[dblCredit]
						,[dblDebitUnit]
						,[dblCreditUnit]
						,[strDescription]
						,[strCode]
						,[strReference]
						,[intCurrencyId]
						,[dblExchangeRate]
						,[dtmDateEntered]
						,[dtmTransactionDate]
						,[strJournalLineDescription]
						,[intJournalLineNo]
						,[ysnIsUnposted]
						,[intUserId]
						,[intEntityId]
						,[strTransactionId]
						,[intTransactionId]
						,[strTransactionType]
						,[strTransactionForm]
						,[strModuleName]
						,[intConcurrencyId]
						,[dblDebitForeign]
						,[dblDebitReport]
						,[dblCreditForeign]
						,[dblCreditReport]
						,[dblReportingRate]
						,[dblForeignRate]
						,[strRateType]
					)
					EXEC uspGRCreateDiscountGLEntriesTransfer_DPtoDP
						@strBatchId	= @strBatchId
						,@intEntityUserSecurityId = @intUserId
						,@intTransactionDetailId = @intTransferStorageReferenceId
						,@intSourceTransactionDetailId = @intSourceTransactionDetailId
				END

					--SELECT '@GLEntries1',* FROM @GLEntries
					--delete from @GLEntries where strDescription like '%Qty: 286.29, Cost: 6.1725%' and dblCredit = 0
					--SELECT '@GLEntries',* FROM @GLEntries

				INSERT INTO @GLValidation
				SELECT * FROM dbo.fnGRGetGLEntriesErrors_DPtoDP(@GLEntries,1)
					
					--select 'validation',* from @GLValidation

				IF EXISTS(SELECT 1 FROM @GLValidation)
				BEGIN
					SELECT TOP 1 @strRKError = strText FROM @GLValidation
					RAISERROR (@strRKError,16,1,'WITH NOWAIT') 
				END
				
				IF EXISTS(SELECT 1 FROM @GLEntries)
				BEGIN 
					EXEC uspGLBookEntries @GLEntries, 1, 1, 1
				END

				FETCH c INTO @intTransferStorageReferenceId,@dblBasis,@dblSettlementPrice,@intSourceCustomerStorageId,@ysnFromDS
			END
			CLOSE c; DEALLOCATE c;
			--/*end === FOR DP to DP only*/
		END

		--update tblGRTransferStorageSplit's intCustomerStorageId
		UPDATE A
		SET A.intTransferToCustomerStorageId = B.intToCustomerStorageId
			,A.intContractDetailId = CASE WHEN ST.ysnDPOwnedType = 1 THEN 
										CASE 
											WHEN A.intContractDetailId IS NULL THEN CT.intContractDetailId 
											ELSE A.intContractDetailId
										END
									ELSE NULL END
		FROM tblGRTransferStorageSplit A		
		INNER JOIN @newCustomerStorageIds B
			ON B.intTransferStorageSplitId = A.intTransferStorageSplitId
		INNER JOIN tblGRCustomerStorage CS
			ON CS.intCustomerStorageId = B.intToCustomerStorageId
		INNER JOIN tblGRStorageType ST
			ON ST.intStorageScheduleTypeId = A.intStorageTypeId
		OUTER APPLY (
			SELECT TOP 1 intContractDetailId
			FROM vyuCTGetContractForScaleTicket
			WHERE intPricingTypeId = 5
				AND intEntityId = CS.intEntityId
				AND intCompanyLocationId = CS.intCompanyLocationId
				AND intItemId = CS.intItemId
				AND ysnEarlyDayPassed = 1
				AND intContractTypeId = 1
				AND ysnAllowedToShow = 1
		) CT
		
		SET @cnt = 0
		SET @cnt = (SELECT COUNT(*) 
					FROM tblGRTransferStorageSplit TSS
					INNER JOIN tblGRStorageType ST
						ON ST.intStorageScheduleTypeId = TSS.intStorageTypeId
					WHERE intTransferStorageId = @intTransferStorageId 
						AND ST.ysnDPOwnedType = 1
						AND intContractDetailId IS NULL)

		DECLARE c CURSOR LOCAL STATIC READ_ONLY FORWARD_ONLY
		FOR
		WITH storageDetails (
			intTransferStorageSplitId
			,intEntityId
			,intToEntityId
		) AS (
			SELECT 
				intTransferStorageSplitId	= TransferStorageSplit.intTransferStorageSplitId
				,intEntityId				= CS.intEntityId
				,intToEntityId				= TransferStorageSplit.intEntityId
			FROM tblGRTransferStorageSplit TransferStorageSplit
			INNER JOIN tblGRTransferStorage TransferStorage
				ON TransferStorage.intTransferStorageId = TransferStorageSplit.intTransferStorageId
			INNER JOIN tblGRCustomerStorage CS
				ON CS.intCustomerStorageId = TransferStorageSplit.intTransferToCustomerStorageId
			INNER JOIN tblGRStorageType ST
				ON ST.intStorageScheduleTypeId = CS.intStorageTypeId
			WHERE TransferStorageSplit.intTransferStorageId = @intTransferStorageId
				AND TransferStorageSplit.intContractDetailId IS NULL
				AND ST.ysnDPOwnedType = 1
		)
		SELECT
			intTransferStorageSplitId
			,intEntityId
			,intToEntityId
		FROM ( SELECT * FROM storageDetails ) params
		
		--if there are no contracts and the selected storage is DP
		--(Transfer to DP) if there is no available contract for the selected entity, location and item, create a new contract
		OPEN c;

		FETCH c INTO @intTransferStorageSplitId, @intEntityId, @intToEntityId

		WHILE @@FETCH_STATUS = 0 AND @cnt > 0
		BEGIN
			SET @XML = '<overrides><intEntityId>' + LTRIM(@intToEntityId) + '</intEntityId></overrides>'

			IF @intTransferStorageSplitId IS NOT NULL
			BEGIN
				EXEC uspCTCreateContract
					@intExternalId = @intTransferStorageSplitId,
					@strScreenName = 'Transfer Storage',
					@intUserId = @intUserId,
					@XML = @XML,
					@intContractHeaderId = @intNewContractHeaderId OUTPUT

				UPDATE TSS
				SET TSS.intContractDetailId = CD.intContractDetailId
				FROM tblGRTransferStorageSplit TSS
				OUTER APPLY (
					SELECT intContractDetailId
					FROM tblCTContractDetail
					WHERE intContractHeaderId = @intNewContractHeaderId
				) CD
				WHERE intTransferStorageSplitId = @intTransferStorageSplitId
			END

			FETCH c INTO @intTransferStorageSplitId, @intEntityId, @intToEntityId
		END
		CLOSE c; DEALLOCATE c;

		--(for new customer storage) insert to storage history table
		DELETE FROM @StorageHistoryStagingTable
		
		DECLARE @intIRId INT;
		SELECT TOP 1	
		    @intIRId = SourceHistory.intInventoryReceiptId
		FROM tblGRTransferStorageReference SR
		INNER JOIN tblGRCustomerStorage FromStorage
			ON FromStorage.intCustomerStorageId = SR.intSourceCustomerStorageId
		INNER JOIN tblGRStorageType FromType
			ON FromType.intStorageScheduleTypeId = FromStorage.intStorageTypeId
		INNER JOIN tblGRCustomerStorage ToStorage
			ON ToStorage.intCustomerStorageId = SR.intToCustomerStorageId
		INNER JOIN tblGRStorageType ToType
			ON ToType.intStorageScheduleTypeId = ToStorage.intStorageTypeId
		JOIN tblICItemUOM IU
			ON IU.intItemId = ToStorage.intItemId
				AND IU.ysnStockUnit = 1
		INNER JOIN tblICItemLocation IL
			ON IL.intItemId = ToStorage.intItemId AND IL.intLocationId = ToStorage.intCompanyLocationId
		INNER JOIN tblGRTransferStorage TS
			ON SR.intTransferStorageId = TS.intTransferStorageId
		INNER JOIN tblGRStorageHistory SourceHistory
			ON SourceHistory.intCustomerStorageId = FromStorage.intCustomerStorageId AND SourceHistory.intInventoryReceiptId IS NOT NULL
		INNER JOIN tblGRTransferStorageSplit TSS
			ON TSS.intTransferStorageSplitId = SR.intTransferStorageSplitId
		LEFT JOIN tblCTContractDetail CD
			ON CD.intContractDetailId = TSS.intContractDetailId
		WHERE  FromType.ysnDPOwnedType = 1 AND ToType.ysnDPOwnedType = 1
		AND SR.intTransferStorageId = @intTransferStorageId

		INSERT INTO @StorageHistoryStagingTable
		(
			[intCustomerStorageId]
			,[intTransferStorageId]
			,[intContractHeaderId]
			,[dblUnits]
			,[dtmHistoryDate]
			,[intUserId]
			,[ysnPost]
			,[intTransactionTypeId]
			,[strPaidDescription]
			,[strType]
			,[intInventoryReceiptId]
			,[strTransferTicket]
		)
		SELECT
			[intCustomerStorageId]	= A.intToCustomerStorageId
			,[intTransferStorageId]	= TransferStorageSplit.intTransferStorageId
			,[intContractHeaderId]	= CD.intContractHeaderId
			,[dblUnits]				= A.dblUnitQty
			,[dtmHistoryDate]		= GETDATE()
			,[intUserId]			= @intUserId
			,[ysnPost]				= 1
			,[intTransactionTypeId]	= 3
			,[strPaidDescription]	= 'Generated from Transfer Storage'
			,[strType]				= 'From Transfer'
			,[intInventoryReceiptId]= @intIRId
			,[strTransferTicket]	= TS.strTransferStorageTicket
		FROM tblGRTransferStorageSplit TransferStorageSplit
		INNER JOIN tblGRTransferStorage TS
			ON TS.intTransferStorageId = TransferStorageSplit.intTransferStorageId
		INNER JOIN @newCustomerStorageIds A
			ON A.intTransferStorageSplitId = TransferStorageSplit.intTransferStorageSplitId		
		LEFT JOIN tblCTContractDetail CD
			ON CD.intContractDetailId = TransferStorageSplit.intContractDetailId

		EXEC uspGRInsertStorageHistoryRecord @StorageHistoryStagingTable, @intStorageHistoryId
		--integration to IC
		SET @cnt = 0
		SET @cnt = (SELECT COUNT(*) FROM tblGRTransferStorageSplit WHERE intTransferStorageId = @intTransferStorageId AND intContractDetailId IS NOT NULL)

		DECLARE c CURSOR LOCAL STATIC READ_ONLY FORWARD_ONLY
		FOR
		WITH storageDetails (
			intTransferContractDetailId 
			,dblTransferUnits			
			,intSourceItemUOMId			
			,intCustomerStorageId
		) AS (
			SELECT 
				intTransferContractDetailId	= TransferStorageSplit.intContractDetailId,
				dblTransferUnits			= TransferStorageSplit.dblUnits,
				intSourceItemUOMId			= TransferStorage.intItemUOMId,
				intCustomerStorageId		= TransferStorageSplit.intTransferToCustomerStorageId
			FROM tblGRTransferStorageSplit TransferStorageSplit
			INNER JOIN tblGRTransferStorage TransferStorage
				ON TransferStorage.intTransferStorageId = TransferStorageSplit.intTransferStorageId
			WHERE TransferStorageSplit.intTransferStorageId = @intTransferStorageId
				AND TransferStorageSplit.intContractDetailId IS NOT NULL
		)
		SELECT
			intTransferContractDetailId 
			,dblTransferUnits			
			,intSourceItemUOMId			
			,intCustomerStorageId
		FROM ( SELECT * FROM storageDetails ) params
		OPEN c;

		FETCH c INTO @intTransferContractDetailId, @dblTransferUnits, @intSourceItemUOMId, @intCustomerStorageId

		WHILE @@FETCH_STATUS = 0 AND @cnt > 0
		BEGIN
			EXEC uspCTUpdateSequenceQuantityUsingUOM 
				@intContractDetailId	= @intTransferContractDetailId
				,@dblQuantityToUpdate	= @dblTransferUnits
				,@intUserId				= @intUserId
				,@intExternalId			= @intTransferStorageId
				,@strScreenName			= 'Transfer Storage'
				,@intSourceItemUOMId	= @intSourceItemUOMId

			FETCH c INTO @intTransferContractDetailId, @dblTransferUnits, @intSourceItemUOMId, @intCustomerStorageId
		END
		CLOSE c; DEALLOCATE c;	

		--DISCOUNTS
		SET @intSourceCustomerStorageId = NULL
		DECLARE c CURSOR LOCAL STATIC READ_ONLY FORWARD_ONLY
		FOR
			SELECT intToCustomerStorageId,intSourceCustomerStorageId FROM @newCustomerStorageIds
		OPEN c;
		FETCH NEXT FROM c INTO @intCustomerStorageId,@intSourceCustomerStorageId

		WHILE @@FETCH_STATUS = 0
		BEGIN
		INSERT INTO [dbo].[tblQMTicketDiscount]
			(
				[intConcurrencyId]         
				,[dblGradeReading]
				,[strCalcMethod]
				,[strShrinkWhat]
				,[dblShrinkPercent]
				,[dblDiscountAmount]
				,[dblDiscountDue]
				,[dblDiscountPaid]
				,[ysnGraderAutoEntry]
				,[intDiscountScheduleCodeId]
				,[dtmDiscountPaidDate]
				,[intTicketId]
				,[intTicketFileId]
				,[strSourceType]
				,[intSort]
				,[strDiscountChargeType]
			)
			SELECT 
				[intConcurrencyId] 				= 1
				,[dblGradeReading] 				= [dblGradeReading]
				,[strCalcMethod] 				= [strCalcMethod]
				,[strShrinkWhat] 				= [strShrinkWhat]
				,[dblShrinkPercent] 			= [dblShrinkPercent]
				,[dblDiscountAmount] 			= [dblDiscountAmount]
				,[dblDiscountDue] 				= [dblDiscountDue]
				,[dblDiscountPaid] 				= [dblDiscountPaid]
				,[ysnGraderAutoEntry] 			= [ysnGraderAutoEntry]
				,[intDiscountScheduleCodeId] 	= [intDiscountScheduleCodeId]
				,[dtmDiscountPaidDate] 			= [dtmDiscountPaidDate]
				,[intTicketId] 					= NULL
				,[intTicketFileId] 				= @intCustomerStorageId
				,[strSourceType] 				= 'Storage'
				,[intSort] 						= [intSort]
				,[strDiscountChargeType] 		= [strDiscountChargeType]
			FROM tblQMTicketDiscount Discount
			WHERE intTicketFileId = @intSourceCustomerStorageId AND Discount.strSourceType = 'Storage'

			FETCH NEXT FROM c INTO @intCustomerStorageId,@intSourceCustomerStorageId
		END
		CLOSE c; DEALLOCATE c;	
		
		DONE:
		COMMIT TRANSACTION
	
	END TRY
	BEGIN CATCH
		DECLARE @ErrorSeverity INT,
				@ErrorNumber   INT,
				@ErrorMessage nvarchar(4000),
				@ErrorState INT,
				@ErrorLine  INT,
				@ErrorProc nvarchar(200);
		-- Grab error information from SQL functions
		SET @ErrorSeverity = ERROR_SEVERITY()
		SET @ErrorNumber   = ERROR_NUMBER()
		SET @ErrorMessage  = ERROR_MESSAGE()
		SET @ErrorState    = ERROR_STATE()
		SET @ErrorLine     = ERROR_LINE()
	
		ROLLBACK TRANSACTION
	
		RAISERROR (@ErrorMessage , @ErrorSeverity, @ErrorState, @ErrorNumber)
	END CATCH	
	
END