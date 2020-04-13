CREATE PROCEDURE [dbo].[uspGRReverseTransfer]
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

	--return

	---START---TRANSACTIONS FOR THE SOURCE-----	
	IF EXISTS(SELECT TOP 1 1 
			FROM tblGRCustomerStorage A 
			OUTER APPLY (
				SELECT dblUnitQty = SUM(dblUnitQty)
					,intTransferStorageId
				FROM tblGRTransferStorageReference
				WHERE intTransferStorageId = @intTransferStorageId
					AND intToCustomerStorageId = A.intCustomerStorageId
				GROUP BY intToCustomerStorageId,intTransferStorageId
			) F
			WHERE F.intTransferStorageId = @intTransferStorageId AND F.dblUnitQty <> A.dblOpenBalance
	)
	BEGIN
		DECLARE @TicketNo VARCHAR(50)

		SELECT @TicketNo = STUFF((
			SELECT ',' + strStorageTicketNumber 
			FROM tblGRCustomerStorage A 
			OUTER APPLY (
				SELECT dblUnitQty = SUM(dblUnitQty)
					,intTransferStorageId
				FROM tblGRTransferStorageReference
				WHERE intTransferStorageId = @intTransferStorageId
					AND intToCustomerStorageId = A.intCustomerStorageId
				GROUP BY intToCustomerStorageId,intTransferStorageId
			) F
			WHERE F.intTransferStorageId = @intTransferStorageId AND F.dblUnitQty <> A.dblOpenBalance
			FOR XML PATH('')
		),1,1,'')
		
		SET @ErrMsg = 'The Open balance of ticket ' + @TicketNo + ' has been modified by another user. Reversal of transfer cannot proceed.'
		
		RAISERROR(@ErrMsg,16,1)
		RETURN;
	END
	
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
			,dtmTransferStorageDate		= GETDATE()
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

		INSERT INTO tblGRTransferStorageReference
		(
			intSourceCustomerStorageId
			,intToCustomerStorageId
			,intTransferStorageSplitId
			,intTransferStorageId
			,dblUnitQty
			,dblSplitPercent
			,dtmProcessDate
		)
		SELECT intToCustomerStorageId
			,intSourceCustomerStorageId
			,TS.intTransferStorageSplitId
			,@intNewTransferStorageId
			,-dblUnitQty
			,SR.dblSplitPercent
			,dtmProcessDate
		FROM tblGRTransferStorageReference SR
		INNER JOIN tblGRTransferStorageSplit TS 
			ON TS.intTransferToCustomerStorageId = intSourceCustomerStorageId
				AND TS.intTransferStorageId = @intNewTransferStorageId 
		WHERE SR.intTransferStorageId = @intTransferStorageId
		
		SET @intTransferStorageReferenceId = @@ROWCOUNT
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
				dblTransferUnits				= (CASE WHEN (SourceSplit.dblOriginalUnits - SourceSplit.dblDeductedUnits) = 0 THEN SourceSplit.dblOriginalUnits ELSE (SourceSplit.dblOriginalUnits - SourceSplit.dblDeductedUnits) END),
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
			,[dblUnits]				= -SourceSplit.dblOriginalUnits
			,[dtmHistoryDate]		= GETDATE()
			,[intUserId]			= @intUserId
			,[ysnPost]				= 1
			,[intTransactionTypeId]	= 3
			,[strPaidDescription]	= 'Generated from Transfer Storage'
			,[strType]				= 'Reversed Transfer'
			,[strTransferTicket]	= TS.strTransferStorageTicket
		FROM tblGRTransferStorageSourceSplit SourceSplit
		LEFT JOIN tblCTContractDetail CD
			ON CD.intContractDetailId = SourceSplit.intContractDetailId
		CROSS APPLY (
			SELECT strTransferStorageTicket FROM tblGRTransferStorage WHERE intTransferStorageId = @intNewTransferStorageId
		) TS
		WHERE SourceSplit.intTransferStorageId = @intNewTransferStorageId

		DELETE FROM @HistoryIds
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
			FROM @StorageHistoryStagingTable
			WHERE intId = @intIdentityId

			EXEC uspGRInsertStorageHistoryRecord @StorageHistoryStagingTable2, @intStorageHistoryId OUTPUT

			IF NOT EXISTS(SELECT TOP 1 1 FROM @HistoryIds WHERE intId = @intStorageHistoryId)
			BEGIN
				INSERT INTO @HistoryIds SELECT @intStorageHistoryId
			END
			
			DELETE FROM @StorageHistoryStagingTable WHERE intId = @intIdentityId
		END

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
						* CASE WHEN (FromType.ysnDPOwnedType = 0 AND ToType.ysnDPOwnedType = 1) THEN -1 ELSE 1 END
					,IU.dblUnitQty
					,0
					,dblSalesPrice = 0
					, ToStorage.intCurrencyId
					,dblExchangeRate = 1
					,intTransactionId = SR.intTransferStorageId
					,intTransactionDetailId = SR.intTransferStorageSplitId
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
				WHERE  ((FromType.ysnDPOwnedType = 0 AND ToType.ysnDPOwnedType = 1) OR (FromType.ysnDPOwnedType = 1 AND ToType.ysnDPOwnedType = 0)) AND SR.intTransferStorageId = @intNewTransferStorageId
				ORDER BY dtmTransferStorageDate

				DECLARE @cursorId INT

				DECLARE _CURSOR CURSOR
				FOR
				SELECT intId FROM @ItemsToPost
	
				OPEN _CURSOR
				FETCH NEXT FROM _CURSOR INTO @cursorId
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
							,@dblBasisCost DECIMAL(18,6)
							,@dblSettlementPrice DECIMAL(18,6)
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
						WHERE  ((FromType.ysnDPOwnedType = 0 AND ToType.ysnDPOwnedType = 1) OR (FromType.ysnDPOwnedType = 1 AND ToType.ysnDPOwnedType = 0)) AND SR.intTransferStorageId = @intNewTransferStorageId
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

						IF @ysnDPtoOtherStorage = 0
						SELECT @strRKError = CASE WHEN ISNULL(@dblBasisCost,0) = 0 AND ISNULL(@dblSettlementPrice,0) = 0 THEN 'Basis and Settlement Price' WHEN  ISNULL(@dblBasisCost,0) = 0 THEN 'Basis Price' WHEN ISNULL(@dblSettlementPrice,0) = 0 THEN 'Settlement Price' END +  ' in risk management is not available.'

						IF @strRKError IS NOT NULL
						BEGIN
							RAISERROR (@strRKError,16,1,'WITH NOWAIT') 
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
							EXEC [dbo].[uspGRCreateGLEntriesForTransferStorage] @intTransferStorageId,@strBatchId,@dblCost,1
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
							EXEC dbo.uspICPostCosting @Entry,@strBatchId,'AP Clearing',@intUserId
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
							EXEC [dbo].[uspGRCreateGLEntriesForTransferStorage] @intNewTransferStorageId,@strBatchId,@dblOriginalCost,1

							IF EXISTS (SELECT TOP 1 1 FROM @GLEntries)
							BEGIN 
									EXEC dbo.uspGLBookEntries @GLEntries, 1 
							END
						END

			
				FETCH NEXT FROM _CURSOR INTO @cursorId
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
		)
		SELECT DISTINCT	
		     [intCustomerStorageId]	= TSS.intTransferToCustomerStorageId
			,[intTransferStorageId]	= @intNewTransferStorageId
			,[intContractHeaderId]	= CD.intContractHeaderId
			,[dblUnits]				= TSS.dblUnits
			,[dtmHistoryDate]		= GETDATE()
			,[intUserId]			= @intUserId
			,[ysnPost]				= 1
			,[intTransactionTypeId]	= 3
			,[strPaidDescription]	= 'Generated from Transfer Storage'
			,[strType]				= 'Reversed Transfer'
		FROM tblGRTransferStorageSplit TSS
		LEFT JOIN tblCTContractDetail CD
			ON CD.intContractDetailId = TSS.intContractDetailId
		WHERE intTransferStorageId = @intNewTransferStorageId

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