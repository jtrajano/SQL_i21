CREATE PROCEDURE [dbo].[uspGRUnPostSettleStorage]
(
	@intSettleStorageId INT
	,@UserId INT	
	,@dtmClientPostDate DATETIME = NULL
)
AS
BEGIN TRY
	SET NOCOUNT ON

	DECLARE @ErrMsg NVARCHAR(MAX)
	DECLARE @BillId INT
	DECLARE @dblUnits DECIMAL(24, 10)
	DECLARE @dblUnitsUnposted DECIMAL(24, 10)
	DECLARE @intCustomerStorageId AS INT
	DECLARE @STARTING_NUMBER_BATCH AS INT = 3
	DECLARE @strBatchId AS NVARCHAR(40)
	DECLARE @TicketNo NVARCHAR(50)
	DECLARE @intParentSettleStorageId INT
	DECLARE @GLEntries AS RecapTableType
	DECLARE @DummyGLEntries AS RecapTableType
	DECLARE @intReturnValue AS INT
	DECLARE @strOwnedPhysicalStock NVARCHAR(20)
	DECLARE @isParentSettleStorage AS BIT
	DECLARE @success BIT
	DECLARE @StorageHistoryStagingTable AS [StorageHistoryStagingTable]
	DECLARE @ItemsToStorage AS ItemCostingTableType
	DECLARE @ItemsToPost AS ItemCostingTableType
	DECLARE @intStorageHistoryId INT
	DECLARE @intDepletionKey INT
	DECLARE @intPricingTypeId INT
	DECLARE @intSettleStorageTicketId INT
	DECLARE @intContractDetailId INT
	DECLARE @intItemUOMId INT	
	DECLARE @ysnDPOwnedType BIT
	DECLARE @BillIdParams NVARCHAR(MAX)
	DECLARE @billList AS Id
	DECLARE @billListForDeletion AS Id

	DECLARE @dtmDate DATETIME = ISNULL(@dtmClientPostDate, GETDATE())

	DECLARE @tblContractIncrement AS TABLE 
	(
		 intDepletionKey INT IDENTITY(1, 1)
		,strDepletionType NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
		,intSettleStorageTicketId INT
		,intPricingTypeId INT
		,intContractHeaderId INT
		,intContractDetailId INT
		,dblUnits DECIMAL(24, 10)
		,intContractSeq INT
	)

	DECLARE @SettleStorages AS TABLE
	(
		intId INT --intSettleStorageId
		,intParentSettleStorageId INT
		,strSettleTicket NVARCHAR(20) COLLATE Latin1_General_CI_AS
		,intCustomerStorageId INT
		,dblUnitsUnposted DECIMAL(24,10)
		,strOwnedPhysicalStock NVARCHAR(20) COLLATE Latin1_General_CI_AS
		,ysnDPOwnedType BIT
		,intContractDetailId INT NULL
	)	

	DECLARE @strContractNumber NVARCHAR(50)
	DECLARE @intContractSeq INT
	DECLARE @intContractHeaderId INT
	-- Call Starting number for Receipt Detail Update to prevent deadlocks. 
	BEGIN
		DECLARE @strUpdateRIDetail AS NVARCHAR(50)
		EXEC dbo.uspSMGetStartingNumber 155, @strUpdateRIDetail OUTPUT
	END
		
	--check first if the settle storage being deleted is the parent, then its children should be deleted first
	SELECT @isParentSettleStorage = CASE WHEN MIN(intSettleStorageId) > 0 THEN 1 ELSE 0 END
	FROM tblGRSettleStorage
	WHERE intParentSettleStorageId = @intSettleStorageId

	INSERT INTO @SettleStorages
	SELECT SS.intSettleStorageId
		,SS.intParentSettleStorageId
		,SS.strStorageTicket
		,CS.intCustomerStorageId
		,SST.dblUnits
		,ST.strOwnedPhysicalStock
		,ST.ysnDPOwnedType
		,SC.intContractDetailId
	FROM tblGRSettleStorage SS
	INNER JOIN tblGRSettleStorageTicket SST
		ON SST.intSettleStorageId = SS.intSettleStorageId
	INNER JOIN tblGRCustomerStorage CS
		ON CS.intCustomerStorageId = SST.intCustomerStorageId
	INNER JOIN tblGRStorageType ST
		ON ST.intStorageScheduleTypeId = CS.intStorageTypeId
	OUTER APPLY (
		SELECT intContractDetailId 
		FROM tblGRSettleContract
		WHERE intSettleStorageId = SS.intSettleStorageId
	) SC
	WHERE (SS.intParentSettleStorageId = @intSettleStorageId AND @isParentSettleStorage = 1) 
		OR (SS.intSettleStorageId = @intSettleStorageId AND @isParentSettleStorage = 0)
		--SELECT '@SettleStorages',* FROM @SettleStorages

	INSERT INTO @billList 
	SELECT DISTINCT ISNULL(SS.intBillId,SSB.intSettleStorageBillDetailId)
	FROM tblGRSettleStorage SS
	INNER JOIN @SettleStorages _SS
		ON _SS.intId = SS.intSettleStorageId
	LEFT JOIN tblGRSettleStorageBillDetail SSB
		ON SSB.intSettleStorageId = SS.intSettleStorageId
	WHERE SS.intBillId IS NOT NULL OR SSB.intBillId IS NOT NULL
	
	DELETE FROM @billList WHERE intId IS NULL

	--will be used at the end of the loop to delete the vouchers
	INSERT INTO @billListForDeletion
	SELECT intId FROM @billList

	-- select '@billList',* from @billList
	-- select '@billListForDeletion',* from @billListForDeletion
	--1. Unpost the voucher
	SELECT @BillIdParams = STUFF(
					(
						SELECT ',' + CAST(intId AS NVARCHAR)
						FROM @billList B
						INNER JOIN tblAPBill AP
							ON AP.intBillId = B.intId
								AND AP.ysnPosted = 1 --include only the posted vouchers
						FOR XML PATH('')
					),1,1,'')
	
	--a. unpost the payments first before unposting the voucher
	WHILE EXISTS(SELECT 1 FROM @billList)
	BEGIN
		SELECT TOP 1 @BillId = intId FROM @billList
		
		IF EXISTS(SELECT 1 FROM vyuAPBillPayment WHERE intBillId = @BillId)
		BEGIN
			EXEC uspAPDeletePayment @BillId, @UserId
		END		

		DELETE FROM @billList WHERE intId = @BillId
	END

	--b. start unposting the vouchers
	IF @BillIdParams IS NOT NULL
	BEGIN
		EXEC uspAPPostBill 
			@post = 0
			,@recap = 0
			,@isBatch = 0
			,@param = @BillIdParams
			,@transactionType = 'Settle Storage'
			,@userId = @UserId
			,@success = @success OUTPUT

		SELECT TOP 1 @ErrMsg = strMessage 
		FROM tblAPPostResult 
		WHERE intTransactionId IN (SELECT * FROM [dbo].fnGetRowsFromDelimitedValues(@BillIdParams))
			AND strMessage NOT IN ('Transaction successfully posted.','Transaction successfully unposted.');

		IF ISNULL(@ErrMsg,'') <> ''
		BEGIN
			RAISERROR (@ErrMsg, 16, 1);
			GOTO SettleStorage_Exit;
		END
	END

	WHILE EXISTS(SELECT 1 FROM @SettleStorages)
	BEGIN
		--WE SHOULD CLEAR THE STORAGE HISTORY STAGING TABLE
		DELETE FROM @StorageHistoryStagingTable

		SET @intSettleStorageId = NULL
		SET @intParentSettleStorageId = NULL
		SET @TicketNo = NULL
		SET @intCustomerStorageId = NULL
		SET @dblUnitsUnposted = NULL
		SET @strOwnedPhysicalStock = NULL
		SET @ysnDPOwnedType = NULL
		SET @intContractDetailId = NULL

		SELECT TOP 1 
			@intSettleStorageId = intId
			,@intParentSettleStorageId = intParentSettleStorageId
			,@TicketNo = strSettleTicket
			,@intCustomerStorageId = intCustomerStorageId
			,@dblUnitsUnposted = dblUnitsUnposted
			,@strOwnedPhysicalStock = strOwnedPhysicalStock
			,@ysnDPOwnedType = ysnDPOwnedType
			,@intContractDetailId = intContractDetailId 
		FROM @SettleStorages

		--2. Return the units to DP Contract, Purchase Contract and Customer Storage 
		DELETE FROM @tblContractIncrement

		--a. Insert only if the storage is a DP storage
		IF @ysnDPOwnedType = 1
		BEGIN
			INSERT INTO @tblContractIncrement 
			(
				intSettleStorageTicketId
				,intPricingTypeId
				,strDepletionType
				,intContractHeaderId
				,intContractDetailId
				,dblUnits
			)
			SELECT 
				intSettleStorageTicketId = UH.intExternalId
				,intPricingTypeId		  = 5 
				,strDepletionType		  = 'DP Contract'
				,intContractHeaderId	  = UH.intContractHeaderId 
				,intContractDetailId	  = UH.intContractDetailId 
				,dblUnits				  = UH.dblTransactionQuantity
			FROM tblCTSequenceUsageHistory UH
			JOIN tblGRSettleStorageTicket SST 
				ON SST.intSettleStorageTicketId = UH.intExternalId 
					AND SST.intSettleStorageId = UH.intExternalHeaderId
			OUTER APPLY (
				SELECT DISTINCT
					intContractHeaderId
				FROM tblGRStorageHistory SH
				INNER JOIN tblGRCustomerStorage CS
					ON CS.intCustomerStorageId = SH.intCustomerStorageId
				INNER JOIN tblGRStorageType ST
					ON ST.intStorageScheduleTypeId = CS.intStorageTypeId
						AND ST.ysnDPOwnedType = 1
				WHERE SH.intCustomerStorageId = SST.intCustomerStorageId
					AND SH.intContractHeaderId IS NOT NULL
					--AND intInventoryReceiptId IS NOT NULL
					AND SH.intContractHeaderId = UH.intContractHeaderId
					AND SH.strType IN ('From Scale','From Delivery Sheet','From Transfer')
			) SH
			WHERE UH.intExternalHeaderId = @intSettleStorageId 
				AND UH.strScreenName = 'Settle Storage' 
				AND UH.strFieldName = 'Balance' 
				AND SH.intContractHeaderId IS NOT NULL
		END
		
		--b. Insert only if the storage was settled against a contract
		IF @intContractDetailId IS NOT NULL
		BEGIN
			INSERT INTO @tblContractIncrement 
			(
				intSettleStorageTicketId
				,intPricingTypeId
				,strDepletionType
				,intContractHeaderId
				,intContractDetailId
				,dblUnits
				,intContractSeq
			)
			SELECT DISTINCT
				intSettleStorageTicketId  = UH.intExternalId
				,intPricingTypeId		  = 1 
				,strDepletionType		  = 'Purchase Contract' 
				,intContractHeaderId	  = UH.intContractHeaderId 
				,intContractDetailId      = UH.intContractDetailId 
				,dblUnits                 = UH.dblTransactionQuantity
				,intContractSeq			= CD.intContractSeq
			FROM tblCTSequenceUsageHistory UH
			JOIN tblGRSettleStorageTicket SST 
				ON SST.intSettleStorageTicketId = UH.intExternalId 
					AND SST.intSettleStorageId = UH.intExternalHeaderId
			JOIN tblGRStorageHistory SH 
				ON SH.intContractHeaderId = UH.intContractHeaderId 
					AND SH.intCustomerStorageId = SST.intCustomerStorageId 
					AND SH.intSettleStorageId = UH.intExternalHeaderId
			LEFT JOIN tblCTContractDetail CD 
				ON CD.intContractDetailId = UH.intContractDetailId
			WHERE UH.intExternalHeaderId = @intSettleStorageId 
				AND UH.strScreenName = 'Settle Storage' 
				AND UH.strFieldName = 'Balance' 
				AND SH.strType = 'Settlement'
		END

		BEGIN
			SELECT @intDepletionKey = MIN(intDepletionKey) FROM @tblContractIncrement

			WHILE @intDepletionKey > 0
			BEGIN
				SET @intSettleStorageTicketId = NULL
				SET @intPricingTypeId = NULL
				SET @intContractDetailId = NULL				
				SET @dblUnits = NULL
				SET @intItemUOMId = NULL
				SET @intContractHeaderId = NULL
				SET @intContractSeq = NULL

				SELECT 
					@intSettleStorageTicketId	= intSettleStorageTicketId
					,@intPricingTypeId			= intPricingTypeId
					,@intContractDetailId		= intContractDetailId
					,@dblUnits					= dblUnits
					,@intContractHeaderId		= intContractHeaderId
					,@intContractSeq			= intContractSeq
				FROM @tblContractIncrement
				WHERE intDepletionKey = @intDepletionKey

				SELECT @strContractNumber = strContractNumber
				FROM tblCTContractHeader
				WHERE intContractHeaderId = @intContractHeaderId

				IF(SELECT intContractStatusId FROM tblCTContractDetail WHERE intContractDetailId = @intContractDetailId) = 6 --SHORT-CLOSED
				BEGIN
					SET @ErrMsg = 'Contract '+ @strContractNumber +'-sequence '+ CAST(@intContractSeq AS NVARCHAR(50)) +' has been short-closed.  Please reopen contract sequence in order to un-post settle storage.'

					RAISERROR(@ErrMsg,16,1,1)
					RETURN;
				END

				IF @intPricingTypeId = 5
				BEGIN
					SELECT @intItemUOMId = intItemUOMId
					FROM tblCTContractDetail
					WHERE intContractDetailId = @intContractDetailId
					
					SET @dblUnits = -@dblUnits

					EXEC uspCTUpdateSequenceQuantityUsingUOM 
						@intContractDetailId = @intContractDetailId
						,@dblQuantityToUpdate = @dblUnits
						,@intUserId = @UserId
						,@intExternalId = @intSettleStorageTicketId
						,@strScreenName = 'Settle Storage'
						,@intSourceItemUOMId = @intItemUOMId
				END
				ELSE
				BEGIN
					EXEC uspCTUpdateSequenceBalance 
						@intContractDetailId = @intContractDetailId
						,@dblQuantityToUpdate = @dblUnits
						,@intUserId = @UserId
						,@intExternalId = @intSettleStorageTicketId
						,@strScreenName = 'Settle Storage'
				END

				SELECT @intDepletionKey = MIN(intDepletionKey)
				FROM @tblContractIncrement
				WHERE intDepletionKey > @intDepletionKey
			END

			UPDATE CS
			SET dblOpenBalance = CASE 
										WHEN dblOpenBalance = dblOriginalBalance 
											THEN dblOpenBalance 
										ELSE CS.dblOpenBalance + ROUND(dbo.fnCTConvertQuantityToTargetItemUOM(CS.intItemId,IU.intUnitMeasureId,CS.intUnitMeasureId,SH.dblUnit),6)
								END
			FROM tblGRCustomerStorage CS
			JOIN tblICItemUOM IU
				ON IU.intItemId = CS.intItemId
					AND IU.ysnStockUnit = 1
			JOIN (
					SELECT intCustomerStorageId
						,SUM(dblUnits) dblUnit
					FROM tblGRStorageHistory
					WHERE intSettleStorageId = @intSettleStorageId
					GROUP BY intCustomerStorageId
				) SH ON SH.intCustomerStorageId = CS.intCustomerStorageId
		END

		--3. OnHand and OnStore Increment
		BEGIN
			SET @strBatchId = NULL
			EXEC dbo.uspSMGetStartingNumber 
				@STARTING_NUMBER_BATCH
				,@strBatchId OUTPUT

			IF @@ERROR <> 0
				GOTO SettleStorage_Exit;

			DELETE FROM @ItemsToStorage
			DELETE FROM @ItemsToPost
			DELETE FROM @GLEntries

			-- Unpost storage stocks. 
			EXEC @intReturnValue = dbo.uspICUnpostStorage
				@intSettleStorageId
				,@TicketNo
				,@strBatchId
				,@UserId
				,0
		
			IF @intReturnValue < 0 GOTO SettleStorage_Exit;

			IF @strOwnedPhysicalStock = 'Customer' 
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
				EXEC uspGRCreateGLEntries 
					'Storage Settlement'
					,'OtherCharges'
					,@intSettleStorageId
					,@strBatchId
					,@UserId
					,@dtmDate
					,0

				UPDATE @GLEntries 
				SET dblDebit		= dblCredit
					,dblDebitUnit	= dblCreditUnit
					,dblCredit		= dblDebit
					,dblCreditUnit  = dblDebitUnit
			END

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
				,[intSourceEntityId]
				,[intCommodityId]--MOD
			)
			EXEC
				@intReturnValue = dbo.uspICUnpostCosting
					@intSettleStorageId
					,@TicketNo
					,@strBatchId
					,@UserId
					,0				

			IF @intReturnValue < 0 GOTO SettleStorage_Exit;				

			IF EXISTS (SELECT TOP 1 1 FROM @GLEntries) 
			BEGIN 
				EXEC dbo.uspGLBookEntries @GLEntries, 0 

				-- Unpost AP Clearing
				DECLARE @APClearing AS APClearing;
				DELETE FROM @APClearing
				INSERT INTO @APClearing
				(
					[intTransactionId],
					[strTransactionId],
					[intTransactionType],
					[strReferenceNumber],
					[dtmDate],
					[intEntityVendorId],
					[intLocationId],
					--DETAIL
					[intTransactionDetailId],
					[intAccountId],
					[intItemId],
					[intItemUOMId],
					[dblQuantity],
					[dblAmount],
					--OTHER INFORMATION
					[strCode]
				)
				SELECT
					-- HEADER
					[intTransactionId]
					,[strTransactionId]
					,[intTransactionType]
					,[strReferenceNumber]
					,[dtmDate]
					,[intEntityVendorId]
					,[intLocationId]
					-- DETAIL
					,[intTransactionDetailId]
					,[intAccountId]
					,[intItemId]
					,[intItemUOMId]
					,[dblQuantity]
					,[dblAmount]
					,[strCode]
				FROM tblAPClearing
				WHERE intTransactionId = @intSettleStorageId
				AND intTransactionType = 6 --Grain
				AND intOffsetId IS NULL

				EXEC uspAPClearing @APClearing = @APClearing, @post = 0;
			END
		END

		--4. Inserting in History
		BEGIN
			INSERT INTO @StorageHistoryStagingTable
			(
				[intCustomerStorageId]
				,[intContractHeaderId]
				,[dblUnits]
				,[dtmHistoryDate]
				,[strType]
				,[intUserId]
				,[strSettleTicket]
				,[intTransactionTypeId]
				,[dblPaidAmount]
				,[strVoucher]
				,[ysnPost]
			)
			SELECT 
				[intCustomerStorageId] = [intCustomerStorageId]
				,[intContractHeaderId]  = [intContractHeaderId]
				,[dblUnits]				= [dblUnits]
				,[dtmHistoryDate]		= GETDATE()
				,[strType]				= 'Reverse Settlement'
				,[intUserId]			= @UserId
				,[strSettleTicket]		= [strSettleTicket]
				,[intTransactionTypeId]	= 4
				,[dblPaidAmount]		= [dblPaidAmount]
				,[strVoucher]           = strVoucher
				,1
			FROM tblGRStorageHistory
			WHERE intSettleStorageId = @intSettleStorageId

			EXEC uspGRInsertStorageHistoryRecord @StorageHistoryStagingTable, @intStorageHistoryId OUTPUT

			--Remove Transaction linking
			exec uspSCAddTransactionLinks 
				@intTransactionType = 4
				,@intTransactionId = @intSettleStorageId
				,@intAction = 2
		END

		--get first the parent settle storage id before the deletion
		IF @isParentSettleStorage = 0
		BEGIN
			--if child settle storage; recompute the units settled of the parent settle storage
			UPDATE SS
			SET
				dblStorageDue		= ISNULL(SS.dblStorageDue,0) - CS.dblStorageDue
				,dblSelectedUnits	= ISNULL(SS.dblSelectedUnits,0) - CS.dblSelectedUnits
				,dblSettleUnits		= ISNULL(SS.dblSettleUnits,0) - CS.dblSettleUnits
				,dblDiscountsDue	= ISNULL(SS.dblDiscountsDue,0) - CS.dblDiscountsDue
				,dblNetSettlement	= ISNULL(SS.dblNetSettlement,0) - CS.dblNetSettlement
				,dblSpotUnits		= ISNULL(SS.dblSpotUnits,0) - CS.dblSpotUnits
				,dblCashPrice		= ISNULL(SS.dblCashPrice,0) - CS.dblCashPrice
			FROM tblGRSettleStorage SS
			OUTER APPLY (
				SELECT 
					dblStorageDue		= ISNULL(dblStorageDue,0)
					,dblSelectedUnits	= ISNULL(dblSelectedUnits,0)
					,dblSettleUnits		= ISNULL(dblSettleUnits,0)
					,dblDiscountsDue	= ISNULL(dblDiscountsDue,0)
					,dblNetSettlement	= ISNULL(dblNetSettlement,0)
					,dblSpotUnits		= ISNULL(dblSpotUnits,0)
					,dblCashPrice		= ISNULL(dblCashPrice,0)
				FROM tblGRSettleStorage
				WHERE intSettleStorageId = @intSettleStorageId
			) CS
			WHERE intSettleStorageId = @intParentSettleStorageId

			UPDATE tblGRSettleContract SET dblUnits = dblUnits - ABS(@dblUnits) WHERE intSettleStorageId = @intParentSettleStorageId
			UPDATE tblGRSettleStorageTicket SET dblUnits = dblUnits - @dblUnitsUnposted WHERE intCustomerStorageId = @intCustomerStorageId AND intSettleStorageId = @intParentSettleStorageId
		END
		-- Delete, the storage tickets that does not have units left
		DELETE FROM tblGRSettleStorageTicket 
			where intSettleStorageId = @intParentSettleStorageId 
				and intCustomerStorageId = @intCustomerStorageId 
				and dblUnits = 0
				
		--DELETE THE SETTLE STORAGE
		UPDATE tblGRStorageHistory SET intSettleStorageId = NULL, intBillId = NULL WHERE intSettleStorageId = @intSettleStorageId
		DELETE FROM tblGRSettleStorage WHERE intSettleStorageId = @intSettleStorageId

		--DELETE THE PARENT IF ALL SETTLED STORAGES HAVE BEEN UNPOSTED
		IF NOT EXISTS(SELECT 1 FROM tblGRSettleStorage WHERE intParentSettleStorageId = @intParentSettleStorageId)
		BEGIN
			DELETE FROM tblGRSettleStorage WHERE intSettleStorageId = @intParentSettleStorageId
		END

		--reverse logged data in tblGRStorageInventoryReceipt when unposting a settlement
		IF @ysnDPOwnedType = 1
		BEGIN
			--GRN-2138 - COST ADJUSTMENT LOGIC FOR DELIVERY SHEETS
			UPDATE tblGRStorageInventoryReceipt SET ysnUnposted = 1 WHERE intSettleStorageId = @intSettleStorageId
		END

		--LAST
		DELETE FROM @SettleStorages WHERE intId = @intSettleStorageId
	END

	--5. Voucher deletion
	BEGIN
		WHILE EXISTS(SELECT 1 FROM @billListForDeletion)
		BEGIN
			SELECT @BillId = intId FROM @billListForDeletion

			EXEC uspAPDeleteVoucher 
				@BillId
				,@UserId
				,@callerModule = 1					

			DELETE FROM @billListForDeletion WHERE intId = @BillId
		END
	END

	SettleStorage_Exit:
END TRY

BEGIN CATCH
	SET @ErrMsg = ERROR_MESSAGE()
	RAISERROR (@ErrMsg,16,1,'WITH NOWAIT')
END CATCH