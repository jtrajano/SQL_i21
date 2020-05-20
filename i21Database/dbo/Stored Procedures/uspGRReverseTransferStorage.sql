CREATE PROCEDURE [dbo].[uspGRReverseTransfer]
(
	@intTransferStorageId INT,
	@intUserId INT,
	@dtmTransferStorageDate DATETIME
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
	DECLARE @XML NVARCHAR(MAX)
	DECLARE @strScreenName NVARCHAR(50)
	DECLARE @intNewContractHeaderId INT
	DECLARE @intNewContractDetailId INT
	DECLARE @intEntityId INT
	DECLARE @intToEntityId INT
	DECLARE @intNewTransferStorageId INT
	DECLARE @intNewTransferStorageSplitId INT

	DECLARE @StorageHistoryStagingTable2 AS StorageHistoryStagingTable
	DECLARE @intIdentityId INT
	DECLARE @HistoryIds AS Id

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

	DECLARE @TransferStorageReference AS TABLE (
		intId INT IDENTITY(1,1)
		,intToCustomerStorageId INT
		,intSourceCustomerStorageId INT 
		,intTransferStorageSplitId INT 
		,dblUnitQty DECIMAL(18,6)
		,dblSplitPercent DECIMAL(18,6)
		,dtmProcessDate DATETIME
	)

	--return
	
	BEGIN TRANSACTION
	BEGIN TRY
		DECLARE @cnt INT = 0
		
		--/*START	--DUPLICATE THE TRANSFER STORAGE RECORDS-- */
		INSERT INTO tblGRTransferStorage
		(
			strTransferStorageTicket
			,intEntityId
			,intCompanyLocationId
			,intStorageScheduleTypeId
			,intItemId
			,intItemUOMId
			,dblTotalUnits
			,dtmTransferStorageDate
			,intConcurrencyId
			,intUserId
			,intTransferLocationId
			,ysnReversed
		)
		SELECT 
			strTransferStorageTicket	= strTransferStorageTicket + '-R'
			,intEntityId
			,intCompanyLocationId
			,intStorageScheduleTypeId
			,intItemId
			,intItemUOMId
			,dblTotalUnits				= dblTotalUnits * -1
			,dtmTransferStorageDate		= @dtmTransferStorageDate
			,intConcurrencyId
			,intUserId					= @intUserId
			,intTransferLocationId
			,ysnReversed				= 1
		FROM tblGRTransferStorage
		WHERE intTransferStorageId = @intTransferStorageId

		SET @intNewTransferStorageId = SCOPE_IDENTITY()

		INSERT INTO tblGRTransferStorageSourceSplit
		(
			intTransferStorageId
			,intSourceCustomerStorageId
			,intStorageTypeId
			,intStorageScheduleId
			,intContractDetailId
			,dblSplitPercent
			,dblOriginalUnits
			,dblDeductedUnits
			,intConcurrencyId
		)		
		SELECT 
			@intNewTransferStorageId
			,TSR.intToCustomerStorageId
			,intStorageTypeId
			,intStorageScheduleId
			,intContractDetailId
			,100
			,TSR.dblUnitQty
			,TSR.dblUnitQty
			,1
		FROM tblGRTransferStorageSplit  TSS
		INNER JOIN tblGRTransferStorageReference TSR
			ON TSR.intTransferStorageSplitId = TSS.intTransferStorageSplitId
		WHERE TSS.intTransferStorageId = @intTransferStorageId

		--SELECT 'tblGRTransferStorageSourceSplit1' ,* FROM tblGRTransferStorageSourceSplit WHERE intTransferStorageId = @intTransferStorageId
		--SELECT 'tblGRTransferStorageSourceSplit2' ,* FROM tblGRTransferStorageSourceSplit WHERE intTransferStorageId = @intNewTransferStorageId

		INSERT INTO tblGRTransferStorageSplit
		(
			intTransferStorageId
			,intTransferToCustomerStorageId
			,intEntityId
			,intCompanyLocationId
			,intStorageTypeId
			,intStorageScheduleId
			,intContractDetailId
			,dblSplitPercent
			,dblUnits
			,intConcurrencyId
		)
		SELECT 
			@intNewTransferStorageId
			,TSS.intSourceCustomerStorageId
			,TS.intEntityId
			,TS.intCompanyLocationId
			,TSS.intStorageTypeId
			,TSS.intStorageScheduleId
			,TSS.intContractDetailId
			,TSS.dblSplitPercent
			,TSS.dblDeductedUnits
			,TSS.intConcurrencyId
		FROM tblGRTransferStorageSourceSplit TSS
		INNER JOIN tblGRTransferStorage TS
			ON TS.intTransferStorageId = TSS.intTransferStorageId
		WHERE TSS.intTransferStorageId = @intTransferStorageId

		--SELECT 'tblGRTransferStorageSplit',* FROM tblGRTransferStorageSplit WHERE intTransferStorageId = @intNewTransferStorageId		
		--SELECT 'tblGRTransferStorageReference',* FROM tblGRTransferStorageReference WHERE intTransferStorageId = @intNewTransferStorageId
		--/*END	--DUPLICATE THE TRANSFER STORAGE-- */			

		SET @cnt = (SELECT COUNT(*) FROM tblGRTransferStorageSourceSplit WHERE intTransferStorageId = @intNewTransferStorageId AND intContractDetailId IS NOT NULL)

		DECLARE c CURSOR LOCAL STATIC READ_ONLY FORWARD_ONLY
		FOR
		WITH sourceStorageDetails (
			intTransferContractDetailId 
			,dblTransferUnits			
			,intSourceItemUOMId			
			,intCustomerStorageId
		) AS (
			SELECT intTransferContractDetailId	= SourceSplit.intContractDetailId,
				dblTransferUnits				= -(CASE WHEN (SourceSplit.dblOriginalUnits - SourceSplit.dblDeductedUnits) = 0 THEN SourceSplit.dblOriginalUnits ELSE (SourceSplit.dblOriginalUnits - SourceSplit.dblDeductedUnits) END),
				intSourceItemUOMId				= TransferStorage.intItemUOMId,
				intCustomerStorageId			= SourceSplit.intSourceCustomerStorageId
			FROM tblGRTransferStorageSourceSplit SourceSplit
			INNER JOIN tblGRTransferStorage TransferStorage
				ON TransferStorage.intTransferStorageId = SourceSplit.intTransferStorageId
			WHERE SourceSplit.intTransferStorageId = @intNewTransferStorageId
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
				,@intExternalId			= @intNewTransferStorageId
				,@strScreenName			= 'Transfer Storage'
				,@intSourceItemUOMId	= @intSourceItemUOMId

			FETCH c INTO @intTransferContractDetailId, @dblTransferUnits, @intSourceItemUOMId, @intCustomerStorageId
		END
		CLOSE c; DEALLOCATE c;

		--update the source's customer storage open balance
		UPDATE A
		SET A.dblOpenBalance 	= 0
		FROM tblGRCustomerStorage A 
		INNER JOIN tblGRTransferStorageSourceSplit B 
			ON B.intSourceCustomerStorageId = A.intCustomerStorageId
		WHERE B.intTransferStorageId = @intNewTransferStorageId
		
		INSERT INTO @TransferStorageReference
		SELECT intToCustomerStorageId
			,intSourceCustomerStorageId
			,TS.intTransferStorageSplitId
			,-dblUnitQty
			,SR.dblSplitPercent
			,dtmProcessDate
		FROM tblGRTransferStorageReference SR
		INNER JOIN tblGRTransferStorageSplit TS 
			ON TS.intTransferToCustomerStorageId = intSourceCustomerStorageId
				AND TS.intTransferStorageId = @intNewTransferStorageId 
		WHERE SR.intTransferStorageId = @intTransferStorageId
		
		--NEW: HISTORY AND REFERENCE FOR THE SOURCE CUSTOMER STORAGE
		DECLARE @intId INT
		DECLARE @intInsertedId INT
		DECLARE c CURSOR LOCAL STATIC READ_ONLY FORWARD_ONLY
		FOR
			SELECT intId FROM @TransferStorageReference
		OPEN c;
		FETCH NEXT FROM c INTO @intId

		DELETE FROM @HistoryIds
		WHILE @@FETCH_STATUS = 0
		BEGIN
			INSERT INTO tblGRTransferStorageReference
			SELECT intToCustomerStorageId,intSourceCustomerStorageId,intTransferStorageSplitId,@intNewTransferStorageId,dblUnitQty,dblSplitPercent,dtmProcessDate FROM @TransferStorageReference WHERE intId = @intId

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
				,[dblUnits]							= TSR.dblUnitQty
				,[dtmHistoryDate]					= GETDATE()
				,[intUserId]						= @intUserId
				,[ysnPost]							= 1
				,[intTransactionTypeId]				= 3
				,[strPaidDescription]				= 'Generated from Transfer Storage'
				,[strType]							= 'Reversed Transfer'
				,[intTransferStorageReferenceId]	= @intInsertedId
			FROM tblGRTransferStorageReference TSR
			INNER JOIN tblGRTransferStorageSourceSplit T_SOURCE
				ON T_SOURCE.intTransferStorageId = TSR.intTransferStorageId
					AND TSR.intSourceCustomerStorageId = T_SOURCE.intSourceCustomerStorageId
			INNER JOIN tblGRTransferStorage TS
				ON TS.intTransferStorageId = TSR.intTransferStorageId
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

		--SELECT * FROM tblGRStorageHistory WHERE intTransferStorageId = @intNewTransferStorageId
		----END----TRANSACTIONS FOR THE SOURCE---------

		----START--TRANSACTIONS FOR THE NEW CUSTOMER STORAGE-------
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
						* CASE WHEN (FromType.ysnDPOwnedType = 0 AND ToType.ysnDPOwnedType = 1) THEN 1 ELSE -1 END
					,IU.dblUnitQty
					,0
					,dblSalesPrice = 0
					, ToStorage.intCurrencyId
					,dblExchangeRate = 1
					,intTransactionId = SR.intTransferStorageId
					,intTransactionDetailId = SR.intTransferStorageReferenceId
					,strTransactionId = TS.strTransferStorageTicket
					,intTransactionTypeId = 56
					,intLotId = NULL
					,intSubLocationId = ToStorage.intCompanyLocationSubLocationId
					,intStorageLocationId = ToStorage.intStorageLocationId
					,ysnIsStorage = CASE WHEN (FromType.ysnDPOwnedType = 0 AND ToType.ysnDPOwnedType = 1) THEN 0 ELSE 1 END
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
				WHERE  ((FromType.ysnDPOwnedType = 0 AND ToType.ysnDPOwnedType = 1) OR (FromType.ysnDPOwnedType = 1 AND ToType.ysnDPOwnedType = 0)) AND SR.intTransferStorageId = @intNewTransferStorageId
				ORDER BY dtmTransferStorageDate
				--select '@ItemsToPost',* from @ItemsToPost
				DECLARE @cursorId INT, @intTransactionDetailId INT

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
							,intItemId INT
							,strItemNo VARCHAR(MAX)
							,intItemUOMId INT
							,strItemUOM VARCHAR(MAX)
							,strItemUOMType VARCHAR(MAX)
							,ysnStockUnit BIT
							,dblUnitQty DECIMAL(32,20)
							,strCostingMethod VARCHAR(MAX)
							,intCostingMethodId INT
							,intLocationId INT
							,strLocationName	VARCHAR(MAX)
							,intSubLocationId INT
							,strSubLocationName VARCHAR(MAX)
							,intStorageLocationId INT
							,strStorageLocationName VARCHAR(MAX)
							,intOwnershipType INT
							,strOwnershipType VARCHAR(MAX)
							,dblRunningAvailableQty DECIMAL(32,20)
							,dblStorageAvailableQty DECIMAL(32,20)
							,dblCost DECIMAL(32,20)
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
							@ysnDPtoOtherStorage = CASE WHEN FromType.ysnDPOwnedType = 1 AND ToType.ysnDPOwnedType = 0 THEN 1 ELSE 0 END
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
						WHERE ((FromType.ysnDPOwnedType = 0 AND ToType.ysnDPOwnedType = 1) OR (FromType.ysnDPOwnedType = 1 AND ToType.ysnDPOwnedType = 0)) AND SR.intTransferStorageId = @intNewTransferStorageId
						ORDER BY dtmTransferStorageDate

						SET @dblCost = (SELECT top 1 dblCost FROM tblICInventoryTransaction WHERE intTransactionId = @intTransferStorageId AND strTransactionForm = 'Transfer Storage' AND strTransactionId = (SELECT strTransferStorageTicket FROM tblGRTransferStorage WHERE intTransferStorageId = @intTransferStorageId))
						set @dblOriginalCost = @dblCost						
						select 'test'
						DELETE FROM @Entry
						DELETE FROM @GLEntries
						DELETE FROM @GLForItem

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
							,ysnIsPercent BIT NULL
							,ysnInventoryCost BIT NULL
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
							,ysnInventoryCost
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
							,ysnInventoryCost			= DItem.ysnInventoryCost
						FROM @ItemsToPost ITP
						JOIN tblGRTransferStorageReference SR
							ON ITP.intTransactionId = SR.intTransferStorageId
							AND ITP. intTransactionDetailId = SR.intTransferStorageSplitId
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
						WHERE (ISNULL(QM.dblDiscountDue, 0) - ISNULL(QM.dblDiscountPaid, 0)) <> 0 
							AND ITP.intId = @cursorId

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
						SELECT intItemId
							,intItemLocationId
							,intItemUOMId
							,dtmDate
							,dblQty
							,dblUOMQty
							,@dblOriginalCost
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
						WHERE intId = @cursorId

						SELECT @dblDiscountCost = ISNULL(SUM(round(dblUnits * dblCashPrice, 2)),0) FROM @OtherChargesDetail WHERE ysnInventoryCost = 1
						
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
						SELECT intItemId
							,intItemLocationId
							,intItemUOMId
							,dtmDate
							,dblQty
							,dblUOMQty
							,@dblDiscountCost
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
						WHERE intId = @cursorId
						select '@GLForItem',* from @GLForItem
						--IF(SELECT dblQty FROM @Entry) > 0
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
							EXEC dbo.uspICPostCosting 
								@Entry
								,@strBatchId
								,'AP Clearing'
								,@intUserId

							--INSERT INTO @GLEntries 
							--(
							--	 [dtmDate] 
							--	,[strBatchId]
							--	,[intAccountId]
							--	,[dblDebit]
							--	,[dblCredit]
							--	,[dblDebitUnit]
							--	,[dblCreditUnit]
							--	,[strDescription]
							--	,[strCode]
							--	,[strReference]
							--	,[intCurrencyId]
							--	,[dblExchangeRate]
							--	,[dtmDateEntered]
							--	,[dtmTransactionDate]
							--	,[strJournalLineDescription]
							--	,[intJournalLineNo]
							--	,[ysnIsUnposted]
							--	,[intUserId]
							--	,[intEntityId]
							--	,[strTransactionId]
							--	,[intTransactionId]
							--	,[strTransactionType]
							--	,[strTransactionForm]
							--	,[strModuleName]
							--	,[intConcurrencyId]
							--	,[dblDebitForeign]	
							--	,[dblDebitReport]	
							--	,[dblCreditForeign]	
							--	,[dblCreditReport]	
							--	,[dblReportingRate]	
							--	,[dblForeignRate]
							--	,[strRateType]
							--)
							--SELECT
							--	GETDATE() 
							--	,@strBatchId
							--	,[intAccountId]
							--	,[dblDebit]			= CASE WHEN dblDebit <> 0 THEN 0 ELSE dblCredit END
							--	,[dblCredit]		= CASE WHEN dblCredit <> 0 THEN 0 ELSE dblDebit END
							--	,[dblDebitUnit]		= CASE WHEN dblDebitUnit <> 0 THEN 0 ELSE dblCreditUnit END
							--	,[dblCreditUnit]	= CASE WHEN dblCreditUnit <> 0 THEN 0 ELSE dblDebitUnit END
							--	,[strDescription]
							--	,[strCode]
							--	,[strReference]
							--	,[intCurrencyId]
							--	,[dblExchangeRate]
							--	,[dtmDateEntered]
							--	,[dtmTransactionDate]
							--	,[strJournalLineDescription]
							--	,[intJournalLineNo]
							--	,[ysnIsUnposted]
							--	,[intUserId]
							--	,[intEntityId]
							--	,[strTransactionId]	= strTransactionId + '-R'
							--	,[intTransactionId]	= @intNewTransferStorageId
							--	,[strTransactionType]
							--	,[strTransactionForm]
							--	,[strModuleName]
							--	,[intConcurrencyId]
							--	,[dblDebitForeign]	= CASE WHEN dblDebitForeign <> 0 THEN 0 ELSE dblCreditForeign END
							--	,[dblDebitReport]	= CASE WHEN dblDebitReport <> 0 THEN 0 ELSE dblCreditReport END
							--	,[dblCreditForeign]	= CASE WHEN dblCreditForeign <> 0 THEN 0 ELSE dblDebitForeign END
							--	,[dblCreditReport]	= CASE WHEN dblCreditReport <> 0 THEN 0 ELSE dblDebitReport END
							--	,[dblReportingRate]	
							--	,[dblForeignRate]
							--	,[strRateType]
							--FROM tblGLDetail A
							--OUTER APPLY (
							--	SELECT strRateType = currencyRateType.strCurrencyExchangeRateType
							--	FROM tblSMCurrencyExchangeRateType currencyRateType
							--	JOIN tblICInventoryTransaction t
							--		ON t.intForexRateTypeId = currencyRateType.intCurrencyExchangeRateTypeId
							--	WHERE t.intTransactionId = @intTransferStorageId
							--		AND t.strTransactionForm = 'Transfer Storage'
							--) S
							--WHERE intTransactionId = @intTransferStorageId
							--	AND strTransactionForm = 'Transfer Storage'
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
							EXEC [dbo].[uspGRCreateGLEntriesForTransferStorage] @intNewTransferStorageId,@intTransactionDetailId,@strBatchId,@dblCost,1
							UPDATE @GLEntries 
							SET dblDebit		= dblCredit
								,dblDebitUnit	= ABS(dblCreditUnit)
								,dblCredit		= dblDebit
								,dblCreditUnit  = ABS(dblDebitUnit)

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

							select 'test2',* from @GLEntries

							IF EXISTS (SELECT TOP 1 1 FROM @GLEntries)
							BEGIN 
								EXEC dbo.uspGLBookEntries @GLEntries, 1 
							END
							
							UPDATE @Entry SET dblQty = dblQty*-1

							EXEC dbo.uspICPostStorage @Entry,@strBatchId,@intUserId

						END

			
				FETCH NEXT FROM _CURSOR INTO @cursorId, @intTransactionDetailId
				END
				CLOSE _CURSOR;
				DEALLOCATE _CURSOR;
		END

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
			,[intTransferStorageReferenceId]
		)
		SELECT DISTINCT	
		     [intCustomerStorageId]				= SR.intToCustomerStorageId
			,[intTransferStorageId]				= SR.intTransferStorageId
			,[intContractHeaderId]				= CD.intContractHeaderId
			,[dblUnits]							= -SR.dblUnitQty
			,[dtmHistoryDate]					= GETDATE()
			,[intUserId]						= @intUserId
			,[ysnPost]							= 1
			,[intTransactionTypeId]				= 3
			,[strPaidDescription]				= 'Generated from Transfer Storage'
			,[strType]							= 'Reversed Transfer'
			,[intTransferStorageReferenceId]	= SR.intTransferStorageReferenceId
		FROM tblGRTransferStorageReference SR
		INNER JOIN tblGRCustomerStorage ToStorage
			ON ToStorage.intCustomerStorageId = SR.intToCustomerStorageId
		INNER JOIN tblGRTransferStorageSplit TSS
			ON TSS.intTransferStorageSplitId = SR.intTransferStorageSplitId
		LEFT JOIN tblCTContractDetail CD
			ON CD.intContractDetailId = TSS.intContractDetailId
		WHERE SR.intTransferStorageId = @intNewTransferStorageId

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
		SET @cnt = (SELECT COUNT(*) FROM tblGRTransferStorageSplit WHERE intTransferStorageId = @intNewTransferStorageId AND intContractDetailId IS NOT NULL)

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
			WHERE TransferStorageSplit.intTransferStorageId = @intNewTransferStorageId
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
				,@intExternalId			= @intNewTransferStorageId
				,@strScreenName			= 'Transfer Storage'
				,@intSourceItemUOMId	= @intSourceItemUOMId

			FETCH c INTO @intTransferContractDetailId, @dblTransferUnits, @intSourceItemUOMId, @intCustomerStorageId
		END
		CLOSE c; DEALLOCATE c;
		
		UPDATE tblGRTransferStorage SET ysnReversed = 1 WHERE intTransferStorageId = @intTransferStorageId

		--return the units to the original source storage
		UPDATE CS
		SET dblOpenBalance = dblOpenBalance + TSS.dblUnits
		FROM tblGRCustomerStorage CS
		INNER JOIN tblGRTransferStorageSplit TSS
			ON TSS.intTransferToCustomerStorageId = CS.intCustomerStorageId
		WHERE intTransferStorageId = @intNewTransferStorageId

		--strTransferTicket is being used by RM, we need to update the strTransferTicket so that they won't to look at our table just to get its corresponding string
		UPDATE tblGRStorageHistory 
		SET strTransferTicket = (SELECT strTransferStorageTicket FROM tblGRTransferStorage WHERE intTransferStorageId = @intNewTransferStorageId) 
		WHERE intTransferStorageId = @intNewTransferStorageId

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