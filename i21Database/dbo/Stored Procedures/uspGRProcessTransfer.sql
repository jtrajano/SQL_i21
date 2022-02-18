CREATE PROCEDURE [dbo].[uspGRProcessTransfer]
(
	@intTransferStorageId INT,
	@intUserId INT
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
	DECLARE @intTransferStorageSplitId INT
	DECLARE @intTransactionDetailId INT
	DECLARE @XML NVARCHAR(MAX)
	DECLARE @strScreenName NVARCHAR(50)
	DECLARE @intNewContractHeaderId INT
	DECLARE @intNewContractDetailId INT
	DECLARE @intEntityId INT
	DECLARE @intToEntityId INT
	DECLARE @intTransferStorageReferenceId INT

	DECLARE @StorageHistoryStagingTable2 AS StorageHistoryStagingTable
	DECLARE @intIdentityId INT
	DECLARE @HistoryIds AS Id

	DECLARE @newCustomerStorageIds AS TABLE 
	(
		intId INT IDENTITY(1,1)
		,intToCustomerStorageId INT
		,intTransferStorageSplitId INT
		,intSourceCustomerStorageId INT
		,dblUnitQty NUMERIC(38,20)
		,dblSplitPercent NUMERIC(38,20)
		,dtmProcessDate DATETIME NOT NULL DEFAULT(GETDATE())
	)
	DECLARE @GLForItem AS GLForItem
	
	DECLARE @CustomerStorageIds AS Id
	DECLARE @intId2 AS INT
	DECLARE @dblTotalUnits AS DECIMAL(24,10)
	DECLARE @dblTransferTotal AS DECIMAL(24,10)
	DECLARE @TicketNo VARCHAR(50)
	DECLARE @TicketNo2 VARCHAR(50)

	DECLARE @Transfers TABLE
	(
		intSourceCustomerStorageId INT
		,dblOriginalBalance DECIMAL(24,10)
		,dblOpenBalance DECIMAL(24,10)
		,dblTotalTransactions DECIMAL(24,10)
		,ysnTransferStorage BIT
	)

	DELETE FROM @CustomerStorageIds
	INSERT INTO @CustomerStorageIds
	SELECT DISTINCT intSourceCustomerStorageId FROM tblGRTransferStorageSourceSplit WHERE intTransferStorageId = @intTransferStorageId

	WHILE EXISTS(SELECT 1 FROM @CustomerStorageIds)
	BEGIN
		SET @intId2 = NULL
		SET @dblTotalUnits = NULL
		SET @dblTransferTotal = NULL

		SELECT TOP 1 @intId2 = intId FROM @CustomerStorageIds

		SELECT @TicketNo				= strStorageTicketNo
			,@dblTotalUnits			= ISNULL(dblHistoryTotalUnits,0)
			,@dblTransferTotal		= ISNULL(dblTransferTotal,0)
		FROM [dbo].[fnGRCheckStorageBalance](@intId2, @intTransferStorageId)

		IF ROUND(@dblTransferTotal,4) > ROUND(@dblTotalUnits,4)
		BEGIN
			SELECT @TicketNo2 = STUFF((
				SELECT ',' + @TicketNo
				FOR XML PATH('')
			),1,1,'')
		END

		DELETE FROM @CustomerStorageIds WHERE intId = @intId2
	END

	IF ISNULL(@TicketNo2,'') <> ''
	BEGIN
		SET @ErrMsg = 'The Open balance of ticket ' + @TicketNo2 + ' has been modified by another user. Transfer process cannot proceed.'
		
		RAISERROR(@ErrMsg,16,1)
		RETURN;
	END
	-----START---TRANSACTIONS FOR THE SOURCE-----
	--IF EXISTS(SELECT TOP 1 1 
	--		FROM tblGRCustomerStorage A 
	--		INNER JOIN tblGRTransferStorageSourceSplit B 
	--			ON B.intSourceCustomerStorageId = A.intCustomerStorageId 
	--		WHERE B.intTransferStorageId = @intTransferStorageId AND B.dblOriginalUnits <> A.dblOpenBalance
	--)
	--BEGIN
	--	DECLARE @TicketNo VARCHAR(50)

	--	SELECT @TicketNo = STUFF((
	--		SELECT ',' + strStorageTicketNumber 
	--		FROM tblGRCustomerStorage A 
	--		INNER JOIN tblGRTransferStorageSourceSplit B 
	--			ON B.intSourceCustomerStorageId = A.intCustomerStorageId 
	--		WHERE B.intTransferStorageId = @intTransferStorageId AND B.dblOriginalUnits <> A.dblOpenBalance
	--		FOR XML PATH('')
	--	),1,1,'')
		
	--	SET @ErrMsg = 'The Open balance of ticket ' + @TicketNo + ' has been modified by another user. Transfer process cannot proceed.'
		
	--	RAISERROR(@ErrMsg,16,1)
	--	RETURN;
	--END
	
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
		SET A.dblOpenBalance 	= CASE WHEN (ROUND(B.dblOriginalUnits - B.dblDeductedUnits,6)) > A.dblOriginalBalance THEN A.dblOriginalBalance ELSE ROUND(B.dblOriginalUnits - B.dblDeductedUnits,6) END
		FROM tblGRCustomerStorage A 
		INNER JOIN tblGRTransferStorageSourceSplit B 
			ON B.intSourceCustomerStorageId = A.intCustomerStorageId
		WHERE B.intTransferStorageId = @intTransferStorageId
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
			,[intShipFromLocationId]
			,[intShipFromEntityId]
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
			,[dblGrossQuantity]					= ROUND(((SourceStorage.dblOriginalUnits * (TransferStorageSplit.dblSplitPercent / 100)) / CS.dblOriginalBalance) * CS.dblGrossQuantity,20)
			,[intSourceCustomerStorageId]		= CS.intCustomerStorageId
			,[dblUnitQty]						= SourceStorage.dblOriginalUnits * (TransferStorageSplit.dblSplitPercent / 100)
			,[intSplitPercent]					= TransferStorageSplit.dblSplitPercent
			,[intShipFromLocationId]			= CS.intShipFromLocationId
			,[intShipFromEntityId]				= CS.intShipFromEntityId
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
			,[intShipFromLocationId]
			,[intShipFromEntityId]
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
			,[intShipFromLocationId]
			,[intShipFromEntityId]
		)
		OUTPUT
			inserted.intCustomerStorageId,
			SourceData.intTransferStorageSplitId,
			SourceData.intSourceCustomerStorageId,
			SourceData.dblUnitQty,
			SourceData.dblSplitPercent,
			GETDATE()
		INTO @newCustomerStorageIds;

		--NEW: HISTORY AND REFERENCE FOR THE SOURCE CUSTOMER STORAGE
		DECLARE @intId INT
		DECLARE @intInsertedId INT
		DECLARE c CURSOR LOCAL STATIC READ_ONLY FORWARD_ONLY
		FOR
			SELECT intId FROM @newCustomerStorageIds
		OPEN c;
		FETCH NEXT FROM c INTO @intId

		DELETE FROM @HistoryIds
		WHILE @@FETCH_STATUS = 0
		BEGIN
			INSERT INTO tblGRTransferStorageReference
			SELECT intSourceCustomerStorageId,intToCustomerStorageId,intTransferStorageSplitId,@intTransferStorageId,dblUnitQty,dblSplitPercent,dtmProcessDate,null FROM @newCustomerStorageIds WHERE intId = @intId

			SET @intTransferStorageReferenceId = CASE WHEN ISNULL(@intTransferStorageReferenceId,0) = 0 THEN @@ROWCOUNT ELSE @intTransferStorageReferenceId + 1 END

			SET @intInsertedId = SCOPE_IDENTITY()

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
				,[intTransferStorageReferenceId]
				,[strTransferTicket]
			)
			SELECT
				[intCustomerStorageId]				= TSR.intSourceCustomerStorageId
				,[intTransferStorageId]				= TSR.intTransferStorageId
				,[intContractHeaderId]				= CD.intContractHeaderId
				,[dblUnits]							= -TSR.dblUnitQty
				,[dtmHistoryDate]					= GETDATE()
				,[intUserId]						= @intUserId
				,[ysnPost]							= 1
				,[intTransactionTypeId]				= 3
				,[strPaidDescription]				= 'Generated from Transfer Storage'
				,[strType]							= 'Transfer'
				,[intTransferStorageReferenceId]	= @intInsertedId
				,[strTransferTicket]				= TS.strTransferStorageTicket
			FROM tblGRTransferStorageReference TSR
			INNER JOIN tblGRTransferStorage TS
				ON TS.intTransferStorageId = TSR.intTransferStorageId
			INNER JOIN tblGRTransferStorageSourceSplit T_SOURCE
				ON T_SOURCE.intTransferStorageId = TSR.intTransferStorageId
					AND TSR.intSourceCustomerStorageId = T_SOURCE.intSourceCustomerStorageId
			LEFT JOIN tblCTContractDetail CD
				ON CD.intContractDetailId = T_SOURCE.intContractDetailId
			WHERE TSR.intTransferStorageReferenceId = @intInsertedId
			
			WHILE EXISTS(SELECT TOP 1 1 FROM @StorageHistoryStagingTable)
			BEGIN
				SELECT TOP 1 @intIdentityId = intId FROM @StorageHistoryStagingTable

				DELETE FROM @StorageHistoryStagingTable2
				INSERT INTO @StorageHistoryStagingTable2
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
					,[intTransferStorageReferenceId]
					,[strTransferTicket]
				)
				SELECT TOP 1
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
					,[intTransferStorageReferenceId]
					,[strTransferTicket]
				FROM @StorageHistoryStagingTable
				WHERE intId = @intIdentityId

				EXEC uspGRInsertStorageHistoryRecord @StorageHistoryStagingTable2, @intStorageHistoryId OUTPUT

				IF NOT EXISTS(SELECT TOP 1 1 FROM @HistoryIds WHERE intId = @intStorageHistoryId)
				BEGIN
					INSERT INTO @HistoryIds SELECT @intStorageHistoryId
				END
			
				DELETE FROM @StorageHistoryStagingTable WHERE intId = @intIdentityId
			END
			FETCH c INTO @intId
		END
		CLOSE c; DEALLOCATE c;

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

		IF(ISNULL(@intTransferStorageReferenceId,0) > 0)
		BEGIN
			DECLARE @ItemsToPost AS ItemCostingTableType
			DECLARE @ItemsToPost_DPtoOS AS ItemCostingTableType
			DECLARE @ItemsToPost_OStoDP AS ItemCostingTableType
			
			DELETE FROM @ItemsToPost
			DELETE FROM @ItemsToPost_DPtoOS
			DELETE FROM @ItemsToPost_OStoDP

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
  			) 
			SELECT intItemId
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
  			) 
			SELECT intItemId
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

				-- Copy the intOrigCostCustomerStorageId from the source DP to DP transaction(if it exists).
				UPDATE TSR
				SET TSR.intCostBucketCustomerStorageId = TSR_SOURCE.intCostBucketCustomerStorageId
				FROM tblGRTransferStorageReference TSR
				INNER JOIN tblGRTransferStorageReference TSR_SOURCE
					ON TSR_SOURCE.intToCustomerStorageId = TSR.intSourceCustomerStorageId
				WHERE TSR.intTransferStorageReferenceId = @intTransferStorageReferenceId
				AND TSR_SOURCE.intCostBucketCustomerStorageId IS NOT NULL

				-- If the intCostBucketCustomerStorageId is still blank, it means that this is the first DP to DP transaction
				IF(EXISTS(
					SELECT TOP 1 1 FROM tblGRTransferStorageReference
					WHERE intTransferStorageReferenceId = @intTransferStorageReferenceId
					AND intCostBucketCustomerStorageId IS NULL)
				)
				BEGIN
					UPDATE tblGRTransferStorageReference
					SET intCostBucketCustomerStorageId = @intSourceCustomerStorageId
					WHERE intTransferStorageReferenceId = @intTransferStorageReferenceId
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
					
				--remove records with 0 Dr/Cr
				DELETE FROM @GLEntries WHERE dblDebit = 0 AND dblCredit = 0

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
			,[intTransferStorageReferenceId]
      		,[strTransferTicket]
		)
		SELECT DISTINCT	
		     [intCustomerStorageId]				= SR.intToCustomerStorageId
			,[intTransferStorageId]				= SR.intTransferStorageId
			,[intContractHeaderId]				= CD.intContractHeaderId
			,[dblUnits]							= SR.dblUnitQty
			,[dtmHistoryDate]					= GETDATE()
			,[intUserId]						= @intUserId
			,[ysnPost]							= 1
			,[intTransactionTypeId]				= 3
			,[strPaidDescription]				= 'Generated from Transfer Storage'
			,[strType]							= 'From Transfer'
			,[intInventoryReceiptId]			= case when FromType.ysnDPOwnedType = 1 AND ToType.ysnDPOwnedType = 1 then SourceHistory.intInventoryReceiptId else null end
			,[intTransferStorageReferenceId]	= SR.intTransferStorageReferenceId
      		,[strTransferTicket] = TS.strTransferStorageTicket
		FROM tblGRTransferStorageReference SR
    	INNER JOIN tblGRTransferStorage TS
			ON TS.intTransferStorageId = SR.intTransferStorageId
		INNER JOIN tblGRCustomerStorage FromStorage
			ON FromStorage.intCustomerStorageId = SR.intSourceCustomerStorageId
		INNER JOIN tblGRCustomerStorage ToStorage
			ON ToStorage.intCustomerStorageId = SR.intToCustomerStorageId
				AND FromStorage.intTicketId IS NOT NULL --SCALE TICKET ONLY
		
		INNER JOIN tblGRStorageType FromType
			ON FromType.intStorageScheduleTypeId = FromStorage.intStorageTypeId
		INNER JOIN tblGRStorageType ToType
			ON ToType.intStorageScheduleTypeId = ToStorage.intStorageTypeId

		INNER JOIN tblGRTransferStorageSplit TSS
			ON TSS.intTransferStorageSplitId = SR.intTransferStorageSplitId
		LEFT JOIN tblGRStorageHistory SourceHistory
			ON SourceHistory.intCustomerStorageId = FromStorage.intCustomerStorageId 
				AND SourceHistory.intInventoryReceiptId IS NOT NULL
		LEFT JOIN tblCTContractDetail CD
			ON CD.intContractDetailId = TSS.intContractDetailId
		WHERE SR.intTransferStorageId = @intTransferStorageId
		UNION ALL
		SELECT
			[intCustomerStorageId]				= A.intToCustomerStorageId
			,[intTransferStorageId]				= TransferStorageSplit.intTransferStorageId
			,[intContractHeaderId]				= CD.intContractHeaderId
			,[dblUnits]							= A.dblUnitQty
			,[dtmHistoryDate]					= GETDATE()
			,[intUserId]						= @intUserId
			,[ysnPost]							= 1
			,[intTransactionTypeId]				= 3
			,[strPaidDescription]				= 'Generated from Transfer Storage'
			,[strType]							= 'From Transfer'
			,[intInventoryReceiptId]			= NULL
			,[intTransferStorageReferenceId] 	= TSR.intTransferStorageReferenceId  
			,[strTransferTicket]				= TS.strTransferStorageTicket
		FROM tblGRTransferStorageSplit TransferStorageSplit
		INNER JOIN tblGRTransferStorage TS
			ON TS.intTransferStorageId = TransferStorageSplit.intTransferStorageId
		INNER JOIN @newCustomerStorageIds A
			ON A.intTransferStorageSplitId = TransferStorageSplit.intTransferStorageSplitId
		INNER JOIN tblGRTransferStorageReference TSR
			ON TSR.intToCustomerStorageId = A.intToCustomerStorageId
		INNER JOIN tblGRCustomerStorage CS
			ON CS.intCustomerStorageId = A.intSourceCustomerStorageId
				AND CS.intTicketId IS NULL --DELIVERY SHEET ONLY
		LEFT JOIN tblCTContractDetail CD
			ON CD.intContractDetailId = TransferStorageSplit.intContractDetailId

		WHILE EXISTS(SELECT TOP 1 1 FROM @StorageHistoryStagingTable)
		BEGIN
			SELECT TOP 1 @intIdentityId = intId FROM @StorageHistoryStagingTable

			DELETE FROM @StorageHistoryStagingTable2
			INSERT INTO @StorageHistoryStagingTable2
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
				,[intTransferStorageReferenceId]
				,[strTransferTicket]
			)
			SELECT TOP 1
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
				,[intTransferStorageReferenceId]
				,[strTransferTicket]
			FROM @StorageHistoryStagingTable
			WHERE intId = @intIdentityId

			EXEC uspGRInsertStorageHistoryRecord @StorageHistoryStagingTable2, @intStorageHistoryId OUTPUT

			IF NOT EXISTS(SELECT TOP 1 1 FROM @HistoryIds WHERE intId = @intStorageHistoryId)
			BEGIN
				INSERT INTO @HistoryIds SELECT @intStorageHistoryId
			END

			DELETE FROM @StorageHistoryStagingTable WHERE intId = @intIdentityId
		END
		
		--integration to CT
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
		
		-- Start Booking AP Clearing to tblAPClearing
		DECLARE
			@intTransferStorageReferenceId3 INT
			,@ysnIsSourceDP BIT
			,@ysnIsTargetDP BIT;

		DECLARE CC CURSOR LOCAL FAST_FORWARD
		FOR
		SELECT TSR.intTransferStorageReferenceId, ST_FROM.ysnDPOwnedType, ST_TO.ysnDPOwnedType
		FROM tblGRTransferStorageReference TSR
		INNER JOIN tblGRTransferStorage TS
			ON TSR.intTransferStorageId = TS.intTransferStorageId
		INNER JOIN tblGRCustomerStorage CS_FROM
			ON TSR.intSourceCustomerStorageId = CS_FROM.intCustomerStorageId
		INNER JOIN tblGRStorageType ST_FROM
			ON ST_FROM.intStorageScheduleTypeId = CS_FROM.intStorageTypeId
		INNER JOIN tblGRCustomerStorage  CS_TO
			ON TSR.intToCustomerStorageId = CS_TO.intCustomerStorageId
		INNER JOIN tblGRStorageType ST_TO
			ON ST_TO.intStorageScheduleTypeId = CS_TO.intStorageTypeId
		WHERE TS.intTransferStorageId = @intTransferStorageId
		
		OPEN CC;
		FETCH CC INTO @intTransferStorageReferenceId3, @ysnIsSourceDP, @ysnIsTargetDP

		WHILE @@FETCH_STATUS = 0
		BEGIN
			-- DP to OS
			IF @ysnIsSourceDP = 1 AND @ysnIsTargetDP = 0
				EXEC uspGRBookAPClearingTransferToOS @intTransferStorageReferenceId3
			-- OS to DP
			ELSE IF @ysnIsSourceDP = 0 AND @ysnIsTargetDP = 1
				EXEC uspGRBookAPClearingTransferToDP @intTransferStorageReferenceId3
			-- DP to DP
			ELSE IF @ysnIsSourceDP = 1 AND @ysnIsTargetDP = 1
			BEGIN
				EXEC uspGRBookAPClearingTransferToOS @intTransferStorageReferenceId3 -- Offset APC from source vendor
				EXEC uspGRBookAPClearingTransferToDP @intTransferStorageReferenceId3 -- Book APC to target vendor
			END
			FETCH CC INTO @intTransferStorageReferenceId3, @ysnIsSourceDP, @ysnIsTargetDP
		END
		CLOSE CC; DEALLOCATE CC;
		-- End booking AP clearing



		-- Adding Transaction links
		exec [uspSCAddTransactionLinks]
			@intTransactionType = 7
			,@intTransactionId = @intTransferStorageId
			,@intAction = 1

		--RISK SUMMARY LOG
		EXEC [dbo].[uspGRRiskSummaryLog2]
			@StorageHistoryIds = @HistoryIds

		DONE:
		COMMIT TRANSACTION

	END TRY
	BEGIN CATCH
	ROLLBACK TRANSACTION
	SET @ErrMsg = ERROR_MESSAGE()
	RAISERROR (@ErrMsg,16,1,'WITH NOWAIT')
	END CATCH
	
END
