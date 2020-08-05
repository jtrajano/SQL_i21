CREATE PROCEDURE [dbo].[uspGRProcessTransfer]
(
	@intTransferStorageId INT,
	@intUserId INT
)
AS
BEGIN TRY
	--return	
	SET NOCOUNT ON

	DECLARE @ErrMsg AS NVARCHAR(MAX)
	DECLARE @StorageHistoryStagingTable AS [StorageHistoryStagingTable]	
	DECLARE @CustomerStorageStagingTable AS CustomerStorageStagingTable
	DECLARE @CurrentItemOpenBalance DECIMAL(38,20)
	DECLARE @intTransferContractDetailId INT
	DECLARE @dblTransferUnits NUMERIC(18,6)
	DECLARE @intSourceItemUOMId INT
	DECLARE @intCustomerStorageId INT --new customer storage id
	DECLARE @intStorageHistoryId INT = 0
	DECLARE @intTransferStorageSplitId INT
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
	DECLARE @dblBasisCost DECIMAL(18,6)
	DECLARE @dblSettlementPrice DECIMAL(18,6)

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
		
		SET @ErrMsg = 'The Open balance of ticket ' + @TicketNo + ' has been modified by another user. Transfer process cannot proceed.'
		
		RAISERROR(@ErrMsg,16,1)
		RETURN;
	END
	
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
				dblTransferUnits				= -CASE WHEN (SourceSplit.dblOriginalUnits - SourceSplit.dblDeductedUnits) = 0 THEN SourceSplit.dblOriginalUnits ELSE (SourceSplit.dblOriginalUnits - SourceSplit.dblDeductedUnits) END ,
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
			,[dblQuantity]						= ROUND(SourceStorage.dblOriginalUnits * (TransferStorageSplit.dblSplitPercent / 100),6)
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
			,[dblGrossQuantity]					= ROUND(((SourceStorage.dblOriginalUnits * (TransferStorageSplit.dblSplitPercent / 100)) / CS.dblOriginalBalance) * CS.dblGrossQuantity,6)
			,[intSourceCustomerStorageId]		= CS.intCustomerStorageId
			,[dblUnitQty]						= ROUND(SourceStorage.dblOriginalUnits * (TransferStorageSplit.dblSplitPercent / 100),6)
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
			SELECT intSourceCustomerStorageId,intToCustomerStorageId,intTransferStorageSplitId,@intTransferStorageId,dblUnitQty,dblSplitPercent,dtmProcessDate FROM @newCustomerStorageIds WHERE intId = @intId

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
			FROM tblGRTransferStorageReference TSR
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
			INNER JOIN tblGRCustomerStorage CS ON CS.intCustomerStorageId = SR.intSourceCustomerStorageId
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
					,dbo.fnCTConvertQuantityToTargetItemUOM(ToStorage.intItemId, IU.intUnitMeasureId, ToStorage.intUnitMeasureId, SR.dblUnitQty) 
						* CASE WHEN (FromType.ysnDPOwnedType = 0 AND ToType.ysnDPOwnedType = 1) THEN -1 ELSE 1 END
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
					ON IL.intItemId = ToStorage.intItemId AND IL.intLocationId = ToStorage.intCompanyLocationId
				INNER JOIN tblGRTransferStorage TS
					ON SR.intTransferStorageId = TS.intTransferStorageId
				WHERE  ((FromType.ysnDPOwnedType = 0 AND ToType.ysnDPOwnedType = 1) OR (FromType.ysnDPOwnedType = 1 AND ToType.ysnDPOwnedType = 0)) AND SR.intTransferStorageId = @intTransferStorageId
				ORDER BY dtmTransferStorageDate
				
				DECLARE @cursorId INT, @intTransactionDetailId INT
				--DP TO DP TRANSFER
				--DP TRANSFER STORAGE SHOULD HAVE dblBasis AND dblSettlementPrice
				--SET @intTransferStorageReferenceId = NULL
				IF NOT EXISTS(SELECT TOP 1 1 FROM @ItemsToPost)
				BEGIN
					DECLARE c CURSOR LOCAL STATIC READ_ONLY FORWARD_ONLY
					FOR
					WITH storageTransfers (
						intTranferStorageReferenceId
					) AS (
						SELECT SR.intTransferStorageReferenceId
						FROM tblGRTransferStorageReference SR
						INNER JOIN tblGRCustomerStorage CS ON CS.intCustomerStorageId = SR.intSourceCustomerStorageId
						INNER JOIN tblGRStorageType ST ON ST.intStorageScheduleTypeId = CS.intStorageTypeId AND ST.ysnDPOwnedType = 1
						WHERE SR.intTransferStorageId = @intTransferStorageId
					)
					SELECT
						intTranferStorageReferenceId
					FROM ( SELECT * FROM storageTransfers ) params
					OPEN c;

					FETCH c INTO @intTransferStorageReferenceId

					WHILE @@FETCH_STATUS = 0
					BEGIN
			
						-- SELECT @dblBasisCost = (SELECT dblBasis FROM dbo.fnRKGetFutureAndBasisPrice (1,I.intCommodityId,right(convert(varchar, SR.dtmProcessDate, 106),8),1,NULL,NULL,CS_TO.intCompanyLocationId,NULL,0,I.intItemId,CS_TO.intCurrencyId))
						-- 	,@dblSettlementPrice  = (SELECT dblSettlementPrice FROM dbo.fnRKGetFutureAndBasisPrice (1,I.intCommodityId,right(convert(varchar, SR.dtmProcessDate, 106),8),2,NULL,NULL,CS_TO.intCompanyLocationId,NULL,0,I.intItemId,CS_TO.intCurrencyId))
						-- FROM tblGRTransferStorageReference SR
						-- INNER JOIN tblGRCustomerStorage CS_FROM ON CS_FROM.intCustomerStorageId = SR.intSourceCustomerStorageId
						-- INNER JOIN tblGRStorageType ST_FROM ON ST_FROM.intStorageScheduleTypeId = CS_FROM.intStorageTypeId AND ST_FROM.ysnDPOwnedType = 1
						-- INNER JOIN tblGRCustomerStorage CS_TO ON CS_TO.intCustomerStorageId = SR.intToCustomerStorageId
						-- INNER JOIN tblGRStorageType ST_TO ON ST_TO.intStorageScheduleTypeId = CS_TO.intStorageTypeId AND ST_TO.ysnDPOwnedType = 1
						-- INNER JOIN tblICItem I ON CS_TO.intItemId = I.intItemId
						-- INNER JOIN tblICCommodity ICC ON CS_TO.intCommodityId = I.intCommodityId
						-- WHERE SR.intTransferStorageReferenceId = @intTransferStorageReferenceId

						--update the Basis and Settlement Price of the new customer storage
						UPDATE CS
						SET dblBasis = ISNULL(CS_FROM.dblBasis,0)
							,dblSettlementPrice = ISNULL(CS_FROM.dblSettlementPrice,0)
						FROM tblGRCustomerStorage CS
						INNER JOIN tblGRTransferStorageReference SR ON SR.intToCustomerStorageId = CS.intCustomerStorageId
						INNER JOIN tblGRCustomerStorage CS_FROM	ON CS_FROM.intCustomerStorageId = SR.intSourceCustomerStorageId
						INNER JOIN tblGRStorageType ST_FROM ON ST_FROM.intStorageScheduleTypeId = CS_FROM.intStorageTypeId AND ST_FROM.ysnDPOwnedType = 1
						WHERE SR.intTransferStorageReferenceId = @intTransferStorageReferenceId

						FETCH c INTO @intTransferStorageReferenceId
					END
					CLOSE c; DEALLOCATE c;						
				END

				DECLARE _CURSOR CURSOR
				FOR
				SELECT intId, intTransactionDetailId FROM @ItemsToPost
	
				OPEN _CURSOR
				FETCH NEXT FROM _CURSOR INTO @cursorId, @intTransactionDetailId
				WHILE @@FETCH_STATUS = 0
				BEGIN		
						DECLARE @GLEntries AS RecapTableType;
						DECLARE @DummyGLEntries AS RecapTableType;
						DECLARE @Entry as ItemCostingTableType;
						DECLARE @dblCost AS DECIMAL(24,10);
						DECLARE @dblOriginalCost AS DECIMAL(24,10);
						DECLARE @dblDiscountCost AS DECIMAL(24,10);
						DECLARE @dblUnits AS DECIMAL(24,10);
						DECLARE @strBatchId AS NVARCHAR(40);
						IF OBJECT_ID('tempdb..#tblICItemRunningStock') IS NOT NULL DROP TABLE  #tblICItemRunningStock
						CREATE TABLE #tblICItemRunningStock(
						intKey INT
						, intItemId INT
						, strItemNo VARCHAR(MAX)
						, intItemUOMId INT
						, strItemUOM VARCHAR(MAX)
						, strItemUOMType VARCHAR(MAX)
						, ysnStockUnit BIT
						, dblUnitQty DECIMAL(32,20)
						, strCostingMethod VARCHAR(MAX)
						, intCostingMethodId INT
						, intLocationId INT
						, strLocationName	VARCHAR(MAX)
						, intSubLocationId INT
						, strSubLocationName VARCHAR(MAX)
						, intStorageLocationId INT
						, strStorageLocationName VARCHAR(MAX)
						, intOwnershipType INT
						, strOwnershipType VARCHAR(MAX)
						, dblRunningAvailableQty DECIMAL(32,20)
						, dblStorageAvailableQty DECIMAL(32,20)
						, dblCost DECIMAL(32,20)
						)
						
						EXEC uspSMGetStartingNumber 3, @strBatchId OUT

						DECLARE @intItemId INT
							,@intLocationId INT
							,@intSubLocationId INT
							,@intStorageLocationId INT
							,@dtmDate DATETIME
							,@intOwnerShipId INT							
							,@strRKError VARCHAR(MAX)
							,@ysnDPtoOtherStorage BIT

						--Check if Transfer is DP To Other Storage (Disregard Risk Error)
						SELECT 
							@ysnDPtoOtherStorage = CASE WHEN FromStorage.intStorageTypeId = 2 AND ToStorage.intStorageTypeId != 2 THEN 1 ELSE 0 END
						FROM tblGRTransferStorageReference SR
						INNER JOIN tblGRCustomerStorage FromStorage
							ON FromStorage.intCustomerStorageId = SR.intSourceCustomerStorageId
						INNER JOIN tblGRStorageType FromType
							ON FromType.intStorageScheduleTypeId = FromStorage.intStorageTypeId
						INNER JOIN tblGRCustomerStorage ToStorage
							ON ToStorage.intCustomerStorageId = SR.intToCustomerStorageId
						INNER JOIN tblGRStorageType ToType
							ON ToType.intStorageScheduleTypeId = ToStorage.intStorageTypeId
						INNER JOIN tblGRTransferStorage TS
							ON SR.intTransferStorageId = TS.intTransferStorageId
						WHERE  ((FromType.ysnDPOwnedType = 0 AND ToType.ysnDPOwnedType = 1) OR (FromType.ysnDPOwnedType = 1 AND ToType.ysnDPOwnedType = 0)) AND SR.intTransferStorageId = @intTransferStorageId
						ORDER BY dtmTransferStorageDate

						SELECT @intItemId = ITP.intItemId,@intLocationId = IL.intLocationId,@intSubLocationId = ITP.intSubLocationId, @intStorageLocationId = ITP.intStorageLocationId, @dtmDate = ITP.dtmDate, @intOwnerShipId = CASE WHEN ITP.ysnIsStorage = 1 THEN 2 ELSE 1 END
							,@dblUnits = ITP.dblQty
						FROM @ItemsToPost ITP
						INNER JOIN tblICItem I
							ON ITP.intItemId = I.intItemId
						INNER JOIN tblICCommodity ICC
							ON ICC.intCommodityId = I.intCommodityId
						INNER JOIN tblICItemLocation IL
							ON IL.intItemLocationId = ITP.intItemLocationId
						WHERE intId = @cursorId
						
						SELECT @dblBasisCost = (SELECT dblBasis FROM dbo.fnRKGetFutureAndBasisPrice (1,I.intCommodityId,right(convert(varchar, dtmDate, 106),8),1,NULL,NULL,@intLocationId,NULL,0,I.intItemId,intCurrencyId))
							,@dblSettlementPrice  = (SELECT dblSettlementPrice FROM dbo.fnRKGetFutureAndBasisPrice (1,I.intCommodityId,right(convert(varchar, dtmDate, 106),8),2,NULL,NULL,@intLocationId,NULL,0,I.intItemId,intCurrencyId))
						FROM @ItemsToPost ITP
						INNER JOIN tblICItem I
							ON ITP.intItemId = I.intItemId
						INNER JOIN tblICCommodity ICC
							ON ICC.intCommodityId = I.intCommodityId
						INNER JOIN tblICItemLocation IL
							ON IL.intItemLocationId = ITP.intItemLocationId
						WHERE intId = @cursorId

						--update the Basis and Settlement Price of the new customer storage
						UPDATE CS
						SET dblBasis = ISNULL(@dblBasisCost,0)
							,dblSettlementPrice = ISNULL(@dblSettlementPrice,0)
						FROM tblGRCustomerStorage CS
						INNER JOIN tblGRTransferStorageReference SR
							ON SR.intToCustomerStorageId = CS.intCustomerStorageId
						INNER JOIN @ItemsToPost IC
							ON IC.intTransactionDetailId = SR.intTransferStorageReferenceId
						INNER JOIN tblGRStorageType ST
							ON ST.intStorageScheduleTypeId = CS.intStorageTypeId
								AND ST.ysnDPOwnedType = 1
						WHERE IC.intId = @cursorId

						IF @ysnDPtoOtherStorage = 0
						SELECT @strRKError = CASE 
							WHEN @dblBasisCost IS NULL AND @dblSettlementPrice > 0 THEN 'Basis in Risk Management is not available.'
							WHEN @dblSettlementPrice IS NULL AND @dblBasisCost > 0 THEN 'Settlement Price in Risk Management is not available.'
							WHEN @dblBasisCost IS NULL AND @dblSettlementPrice IS NULL THEN 'Basis and Settlement Price in Risk Management are not available.'
							WHEN @dblSettlementPrice = 0 THEN 'Settlement Price is 0. Please update its price in Risk Management.'
							END
					
						IF @strRKError IS NOT NULL
						BEGIN
						RAISERROR (@strRKError,16,1,'WITH NOWAIT') 
						RETURN;
						END

						SET @dblCost =ISNULL(@dblSettlementPrice,0) + ISNULL(@dblBasisCost,0)
						set @dblOriginalCost = @dblCost

						DECLARE @OtherChargesDetail AS TABLE(
							intOtherChargesDetailId INT IDENTITY(1, 1)
							,strOrderType NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
							,intCustomerStorageId INT
							,intCompanyLocationId INT
							,dblUnits DECIMAL(24, 10)
							,dblCashPrice DECIMAL(36, 20)
							,dblExactCashPrice DECIMAL (24,10)
							,intItemId INT NULL
							,intItemType INT NULL
							,IsProcessed BIT
							,intTicketDiscountId INT NULL
							,ysnDiscountFromGrossWeight BIT NULL
							,ysnIsPercent bit null
						)
						delete from @OtherChargesDetail
						INSERT INTO @OtherChargesDetail
						(
							intCustomerStorageId
							,intCompanyLocationId
							,dblUnits
							,dblCashPrice
							,dblExactCashPrice
							,intItemId
							,intItemType
							,IsProcessed
							,intTicketDiscountId
							,ysnDiscountFromGrossWeight
							,ysnIsPercent
						)
						SELECT 
							 intCustomerStorageId		= CS.intCustomerStorageId
							,intCompanyLocationId		= CS.intCompanyLocationId 
							,dblUnits					= CASE
															WHEN DCO.strDiscountCalculationOption = 'Gross Weight' THEN 
																CASE WHEN CS.dblGrossQuantity IS NULL THEN SR.dblUnitQty
																ELSE
																	--(SR.dblUnitQty / CS.dblOriginalBalance) * 
																	ROUND((CS.dblGrossQuantity  * (isnull(SR.dblSplitPercent, 100) / 100)) ,10)
																END
															ELSE SR.dblUnitQty
														END
							,dblCashPrice				= CASE 
															WHEN QM.strDiscountChargeType = 'Percent'
																		THEN (dbo.fnCTConvertQuantityToTargetItemUOM(CS.intItemId, IU.intUnitMeasureId, CS.intUnitMeasureId, ISNULL(QM.dblDiscountPaid, 0)) - dbo.fnCTConvertQuantityToTargetItemUOM(CS.intItemId, IU.intUnitMeasureId, CS.intUnitMeasureId, ISNULL(QM.dblDiscountDue, 0)))
																			*
																			@dblCost
															ELSE --Dollar
																dbo.fnCTConvertQuantityToTargetItemUOM(CS.intItemId, IU.intUnitMeasureId, CS.intUnitMeasureId, ISNULL(QM.dblDiscountPaid, 0)) - dbo.fnCTConvertQuantityToTargetItemUOM(CS.intItemId, IU.intUnitMeasureId, CS.intUnitMeasureId, ISNULL(QM.dblDiscountDue, 0))
														END
							,dblExactCashPrice			= 0
							,intItemId					= DItem.intItemId 
							,intItemType				= 3 
							,IsProcessed				= 0
							,intTicketDiscountId		= QM.intTicketDiscountId
							,ysnDiscountFromGrossWeight	= CASE
															WHEN DCO.strDiscountCalculationOption = 'Gross Weight' THEN 1
															ELSE 0
														END
							,ysnIsPercent				=  CASE WHEN QM.strDiscountChargeType = 'Percent' THEN 1 ELSE 0 END
							FROM @ItemsToPost ITP
							JOIN tblGRTransferStorageReference SR
							  ON ITP.intTransactionId = SR.intTransferStorageId
							 AND ITP. intTransactionDetailId = SR.intTransferStorageReferenceId
							JOIN tblGRCustomerStorage CS
								ON SR.intSourceCustomerStorageId = CS.intCustomerStorageId
							JOIN tblICItemUOM IU
							ON IU.intItemId = CS.intItemId
								AND IU.ysnStockUnit = 1
							JOIN tblQMTicketDiscount QM 
							ON QM.intTicketFileId = CS.intCustomerStorageId 
								AND QM.strSourceType = 'Storage'
							JOIN tblGRDiscountScheduleCode DSC
							ON DSC.intDiscountScheduleCodeId = QM.intDiscountScheduleCodeId
							JOIN tblGRDiscountCalculationOption DCO
							ON DCO.intDiscountCalculationOptionId = DSC.intDiscountCalculationOptionId
							JOIN tblICItem DItem 
							ON DItem.intItemId = DSC.intItemId
							WHERE (ISNULL(QM.dblDiscountDue, 0) - ISNULL(QM.dblDiscountPaid, 0)) <> 0 and ITP.intId = @cursorId
						
						SELECT @dblCost = @dblCost + ISNULL(SUM(dblCashPrice),0) FROM @OtherChargesDetail OCD 
						INNER JOIN tblICItem IC
							ON IC.intItemId = OCD.intItemId
						WHERE IC.ysnInventoryCost = 1

						update @OtherChargesDetail set dblExactCashPrice = ROUND(dblUnits*dblCashPrice,2)

						SELECT @dblDiscountCost = ISNULL(SUM(round(dblUnits*dblCashPrice, 2)),0) FROM @OtherChargesDetail OCD 
						INNER JOIN tblICItem IC
							ON IC.intItemId = OCD.intItemId
						WHERE IC.ysnInventoryCost = 1

						DELETE FROM @Entry
						DELETE FROM @GLEntries
						DELETE FROM @GLForItem
						INSERT INTO @Entry 
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
						SELECT intItemId,intItemLocationId,intItemUOMId,dtmDate,dblQty,dblUOMQty,@dblOriginalCost,dblSalesPrice,intCurrencyId,dblExchangeRate,intTransactionId,intTransactionDetailId,strTransactionId,intTransactionTypeId,intLotId,intSubLocationId,intStorageLocationId,ysnIsStorage,intStorageScheduleTypeId 
						FROM @ItemsToPost WHERE intId = @cursorId

						INSERT INTO @GLForItem
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
						SELECT intItemId,intItemLocationId,intItemUOMId,dtmDate,dblQty,dblUOMQty,@dblDiscountCost,dblSalesPrice,intCurrencyId,dblExchangeRate,intTransactionId,intTransactionDetailId,strTransactionId,intTransactionTypeId,intLotId,intSubLocationId,intStorageLocationId,ysnIsStorage,intStorageScheduleTypeId 
						FROM @ItemsToPost WHERE intId = @cursorId

						IF(SELECT dblQty FROM @Entry) > 0
						BEGIN
							UPDATE @Entry
							SET dblQty = dblQty*-1

							INSERT INTO @DummyGLEntries 
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
							,[intSourceEntityId] --MOD
							,[intCommodityId]--MOD
							)
							EXEC	dbo.uspICPostCosting @Entry,@strBatchId,'AP Clearing',@intUserId

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
							EXEC [dbo].[uspGRCreateGLEntriesForTransferStorage] @intTransferStorageId,@intTransactionDetailId,@strBatchId,@dblCost,1
							UPDATE @GLEntries 
							SET dblDebit		= dblCredit
								,dblDebitUnit	= dblCreditUnit
								,dblCredit		= dblDebit
								,dblCreditUnit  = dblDebitUnit

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
							EXEC dbo.uspGRCreateItemGLEntriesTransfer
								@strBatchId
								,@GLForItem
								,'AP Clearing'
								,1

							IF EXISTS (SELECT TOP 1 1 FROM @GLEntries)
							BEGIN 
								EXEC dbo.uspGLBookEntries @GLEntries, 1 
							END
							
							UPDATE @Entry SET dblQty = dblQty*-1
							
							EXEC dbo.uspICPostStorage @Entry,@strBatchId,@intUserId

						END
						ELSE
						BEGIN
							EXEC dbo.uspICPostStorage @Entry,@strBatchId,@intUserId

							UPDATE @Entry SET dblQty = dblQty*-1

							INSERT INTO @DummyGLEntries 
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
							,[intSourceEntityId] --MOD
							,[intCommodityId]--MOD
							)
							EXEC	dbo.uspICPostCosting @Entry,@strBatchId,'AP Clearing',@intUserId
							--Used total discount cost on @GLForItem to get the correct decimal					

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
							EXEC dbo.uspGRCreateItemGLEntriesTransfer
								@strBatchId
								,@GLForItem
								,'AP Clearing'
								,1

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
							EXEC [dbo].[uspGRCreateGLEntriesForTransferStorage] @intTransferStorageId,@intTransactionDetailId,@strBatchId,@dblOriginalCost,1

							IF EXISTS (SELECT TOP 1 1 FROM @GLEntries)
							BEGIN 
									EXEC dbo.uspGLBookEntries @GLEntries, 1 
							END
						END

			
				FETCH NEXT FROM _CURSOR INTO @cursorId, @intTransactionDetailId
				END
				CLOSE _CURSOR;
				DEALLOCATE _CURSOR;
		END

		--(intToCustomerStorageId INT, intTransferStorageSplitId INT, intSourceCustomerStorageId INT,dblUnitQty NUMERIC(38,20),dblSplitPercent NUMERIC(38,20),dtmProcessDate DATETIME NOT NULL DEFAULT(GETDATE()))

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
			,[intInventoryReceiptId]			= SourceHistory.intInventoryReceiptId
			,[intTransferStorageReferenceId]	= SR.intTransferStorageReferenceId
		FROM tblGRTransferStorageReference SR
		INNER JOIN tblGRCustomerStorage FromStorage
			ON FromStorage.intCustomerStorageId = SR.intSourceCustomerStorageId
		INNER JOIN tblGRCustomerStorage ToStorage
			ON ToStorage.intCustomerStorageId = SR.intToCustomerStorageId
		INNER JOIN tblGRTransferStorageSplit TSS
			ON TSS.intTransferStorageSplitId = SR.intTransferStorageSplitId
		LEFT JOIN tblGRStorageHistory SourceHistory
			ON SourceHistory.intCustomerStorageId = FromStorage.intCustomerStorageId 
				AND SourceHistory.intInventoryReceiptId IS NOT NULL
		LEFT JOIN tblCTContractDetail CD
			ON CD.intContractDetailId = TSS.intContractDetailId
		WHERE SR.intTransferStorageId = @intTransferStorageId
		-- FromType.ysnDPOwnedType = 1 AND ToType.ysnDPOwnedType = 1 AND 

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
		DECLARE @intSourceCustomerStorageId INT;
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

		--strTransferTicket is being used by RM, we need to update the strTransferTicket so that they won't to look at our table just to get its corresponding string
		UPDATE tblGRStorageHistory 
		SET strTransferTicket = (SELECT strTransferStorageTicket FROM tblGRTransferStorage WHERE intTransferStorageId = @intTransferStorageId) 
		WHERE intTransferStorageId = @intTransferStorageId		
		
		--RISK SUMMARY LOG
		SET @intStorageHistoryId = NULL
		DECLARE c CURSOR LOCAL STATIC READ_ONLY FORWARD_ONLY
		FOR
			SELECT intId FROM @HistoryIds
		OPEN c;
		FETCH NEXT FROM c INTO @intStorageHistoryId

		WHILE @@FETCH_STATUS = 0
		BEGIN
			EXEC uspGRRiskSummaryLog @intStorageHistoryId
			FETCH NEXT FROM c INTO @intStorageHistoryId
		END
		CLOSE c; DEALLOCATE c;

	END TRY
	BEGIN CATCH
	SET @ErrMsg = ERROR_MESSAGE()
	RAISERROR (@ErrMsg,16,1,'WITH NOWAIT')
	END CATCH	