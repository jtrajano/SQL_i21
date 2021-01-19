﻿CREATE PROCEDURE [dbo].[uspGRUnPostSettleStorage]
(
	@strXml NVARCHAR(MAX)
)
AS
BEGIN TRY
	SET NOCOUNT ON

	DECLARE @idoc INT
	DECLARE @ErrMsg NVARCHAR(MAX)
	DECLARE @intSettleStorageId INT
	DECLARE @UserId INT
	DECLARE @BillId INT
	DECLARE @strBillId VARCHAR(MAX)
	DECLARE @dblUnits DECIMAL(24, 10)
	DECLARE @dblUnitsUnposted DECIMAL(24, 10)
	DECLARE @ItemId INT
	DECLARE @intCustomerStorageId AS INT
	DECLARE @STARTING_NUMBER_BATCH AS INT = 3
	DECLARE @strBatchId AS NVARCHAR(20)
	DECLARE @TicketNo NVARCHAR(50)
	DECLARE @LocationId INT
	DECLARE @intParentSettleStorageId INT
	DECLARE @GLEntries AS RecapTableType
	DECLARE @DummyGLEntries AS RecapTableType
	DECLARE @intReturnValue AS INT
	DECLARE @strOwnedPhysicalStock NVARCHAR(20)	
	DECLARE @ItemLocationId INT
	DECLARE @dblUOMQty DECIMAL(24, 10)
	DECLARE @intInventoryItemStockUOMId INT
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
	DECLARE @dblCost DECIMAL(24, 10)

	EXEC sp_xml_preparedocument @idoc OUTPUT
		,@strXml

	SELECT 
		@intSettleStorageId = intSettleStorageId
		,@UserId			= intEntityUserSecurityId
	FROM OPENXML(@idoc, 'root', 2) WITH (intSettleStorageId INT,intEntityUserSecurityId INT)
	
	SET @intParentSettleStorageId = @intSettleStorageId

	DECLARE @tblContractIncrement AS TABLE 
	(
		 intDepletionKey INT IDENTITY(1, 1)
		,strDepletionType NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
		,intSettleStorageTicketId INT
		,intPricingTypeId INT
		,intContractHeaderId INT
		,intContractDetailId INT
		,dblUnits DECIMAL(24, 10)
	)

	DECLARE @billList AS Id
	INSERT INTO @billList 
	SELECT DISTINCT intBillId 
	FROM tblGRSettleStorageBillDetail 
	WHERE intSettleStorageId = @intSettleStorageId 
		AND intBillId IS NOT NULL
		
	--check first if the settle storage being deleted is the parent, then its children should be deleted first
	SELECT @isParentSettleStorage = CASE WHEN MIN(intSettleStorageId) > 0 THEN 1 ELSE 0 END
	FROM tblGRSettleStorage
	WHERE intParentSettleStorageId = @intParentSettleStorageId
	
	--IF (SELECT ysnImposeReversalTransaction FROM tblRKCompanyPreference) = 0
	BEGIN
		--1. Unpost the Voucher
		SELECT 
			@BillId					= intBillId
			,@TicketNo				= strStorageTicket
			,@ItemId				= intItemId
			,@LocationId			= intCompanyLocationId
		FROM tblGRSettleStorage
		WHERE intSettleStorageId = @intSettleStorageId

		--SELECT @strBillId = strBillId FROM tblAPBill WHERE intBillId = @BillId

		IF ISNULL(@BillId,0) = 0 AND @isParentSettleStorage = 1
		BEGIN
			SELECT @intSettleStorageId = MIN(intSettleStorageId)
			FROM tblGRSettleStorage
			WHERE intParentSettleStorageId = @intParentSettleStorageId
			
			WHILE @intSettleStorageId >0
			BEGIN
				
				SET @strXml = NULL				
				SET @strXml = N'<root><intSettleStorageId>'+LTRIM(@intSettleStorageId)+'</intSettleStorageId><intEntityUserSecurityId>'+LTRIM(@UserId)+'</intEntityUserSecurityId></root>'
				EXEC uspGRUnPostSettleStorage @strXml

				SELECT @intSettleStorageId = MIN(intSettleStorageId)
				FROM tblGRSettleStorage
				WHERE intParentSettleStorageId = @intParentSettleStorageId
					AND intSettleStorageId > @intSettleStorageId
			END
			--UPDATE tblGRStorageHistory set intSettleStorageId  = null where intSettleStorageId = @intParentSettleStorageId
			--DELETE FROM tblGRSettleStorage WHERE intSettleStorageId = @intParentSettleStorageId
			EXEC [uspGRDeleteStorageHistoryWithLog] @intParentSettleStorageId, @UserId
		END
		ELSE
		BEGIN
			--DELETE FROM @GLEntries
			SELECT TOP 1 @intCustomerStorageId = intCustomerStorageId FROM tblGRStorageHistory
			WHERE intSettleStorageId = @intSettleStorageId

			SELECT 
				@dblUOMQty						= dblUnitQty
				,@intInventoryItemStockUOMId	= intItemUOMId
			FROM tblICItemUOM 
			WHERE intItemId = @ItemId
				AND ysnStockUnit = 1

			SELECT @ItemLocationId = intItemLocationId
			FROM tblICItemLocation
			WHERE intItemId = @ItemId 
				AND intLocationId = @LocationId
				
			IF NOT EXISTS (SELECT TOP 1 1 FROM @billList WHERE intId = @BillId) AND @BillId IS NOT NULL
				INSERT INTO @billList SELECT @BillId
			-- this will loop to all the voucher associated in the settlement
			begin
				select @BillId = min(intId) from @billList
				while isnull(@BillId, 0) > 0
				begin
					--5. NEW REQUIREMENT: include the payment when unposting the settle storage
					IF EXISTS(SELECT 1 FROM vyuAPBillPayment WHERE intBillId = @BillId)
					BEGIN
						EXEC uspAPDeletePayment @BillId, @UserId
					END

					IF EXISTS (
								SELECT 1
								FROM tblAPBill
								WHERE intBillId = @BillId AND ISNULL(ysnPosted, 0) = 1
							)
					BEGIN
						EXEC uspAPPostBill 
							@post = 0
							,@recap = 0
							,@isBatch = 0
							,@param = @BillId
							,@transactionType = 'Settle Storage'
							,@userId = @UserId
							,@success = @success OUTPUT
					END

					IF(@success = 0)
					BEGIN
						SELECT TOP 1 @ErrMsg = strMessage FROM tblAPPostResult WHERE intTransactionId = @intSettleStorageId;
						RAISERROR (@ErrMsg, 16, 1);
						GOTO SettleStorage_Exit;
					END

					select @BillId = min(intId) from @billList where intId > @BillId
				end
			end

			

			--2. DP Contract, Purchase Contract and Ticket Balance Increment
			DELETE FROM @tblContractIncrement

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

			UNION ALL
		
			SELECT DISTINCT
				 intSettleStorageTicketId  = UH.intExternalId
				,intPricingTypeId		   = 1 
				,strDepletionType		   = 'Purchase Contract' 
				,intContractHeaderId	   = UH.intContractHeaderId 
				,intContractDetailId       = UH.intContractDetailId 
				,dblUnits                  = UH.dblTransactionQuantity
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

			BEGIN
				SELECT @intDepletionKey = MIN(intDepletionKey)
				FROM @tblContractIncrement

				WHILE @intDepletionKey > 0
				BEGIN
					SET @intSettleStorageTicketId = NULL
					SET @intPricingTypeId = NULL
					SET @intContractDetailId = NULL
				
					SET @dblUnits = NULL
					SET @intItemUOMId = NULL

					SELECT 
						 @intSettleStorageTicketId	= intSettleStorageTicketId
						,@intPricingTypeId			= intPricingTypeId
						,@intContractDetailId		= intContractDetailId
						,@dblUnits					= dblUnits
					FROM @tblContractIncrement
					WHERE intDepletionKey = @intDepletionKey

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
				SET CS.dblOpenBalance = CS.dblOpenBalance + ROUND(dbo.fnCTConvertQuantityToTargetItemUOM(CS.intItemId,IU.intUnitMeasureId,CS.intUnitMeasureId,SH.dblUnit),6)
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
				EXEC dbo.uspSMGetStartingNumber 
					 @STARTING_NUMBER_BATCH
					,@strBatchId OUTPUT

				IF @@ERROR <> 0
					GOTO SettleStorage_Exit;

				DELETE FROM @GLEntries				

				--IF EXISTS (SELECT TOP 1 1 FROM @GLEntries) 
				--BEGIN 
				--	EXEC dbo.uspGLBookEntries @GLEntries, 0 
				--END
				DELETE FROM @ItemsToStorage
				DELETE FROM @ItemsToPost
				DELETE FROM @GLEntries

				-- Unpost storage stocks. 
				 EXEC	
				 @intReturnValue = dbo.uspICUnpostStorage
				 @intSettleStorageId
				,@TicketNo
				,@strBatchId
				,@UserId
				,0
		
				IF @intReturnValue < 0 GOTO SettleStorage_Exit;

				--DELETE FROM @GLEntries
				SET @intCustomerStorageId = NULL				

				SELECT TOP 1 @intCustomerStorageId = intCustomerStorageId FROM tblGRStorageHistory
				WHERE intSettleStorageId = @intSettleStorageId

				SELECT @strOwnedPhysicalStock = ST.strOwnedPhysicalStock
				FROM tblGRCustomerStorage CS 
				JOIN tblGRStorageType ST 
					ON ST.intStorageScheduleTypeId = CS.intStorageTypeId
				WHERE CS.intCustomerStorageId = @intCustomerStorageId

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
			END

			--get first the parent settle storage id before the deletion
			IF @isParentSettleStorage = 0
			BEGIN
				SELECT @intParentSettleStorageId = intParentSettleStorageId FROM tblGRSettleStorage WHERE intSettleStorageId = @intSettleStorageId				

				--if child settle storage; recompute the units settled of the parent settle storage
				UPDATE SS
				SET
					SS.dblStorageDue		= SS.dblStorageDue - CS.dblStorageDue
					,SS.dblSelectedUnits	= SS.dblSelectedUnits - CS.dblSelectedUnits
					,SS.dblSettleUnits		= SS.dblSettleUnits - CS.dblSettleUnits
					,SS.dblDiscountsDue		= SS.dblDiscountsDue - CS.dblDiscountsDue
					,SS.dblNetSettlement	= SS.dblNetSettlement - CS.dblNetSettlement
					,SS.dblSpotUnits		= SS.dblSpotUnits - CS.dblSpotUnits
					,SS.dblCashPrice		= SS.dblCashPrice - CS.dblCashPrice
				FROM tblGRSettleStorage SS
				OUTER APPLY (
					SELECT 
						dblStorageDue
						,dblSelectedUnits
						,dblSettleUnits
						,dblDiscountsDue
						,dblNetSettlement
						,dblSpotUnits
						,dblCashPrice
					FROM tblGRSettleStorage
					WHERE intSettleStorageId = @intSettleStorageId
				) CS
				WHERE intSettleStorageId = @intParentSettleStorageId


				UPDATE tblGRSettleContract SET dblUnits = dblUnits - ABS(@dblUnits) WHERE intSettleStorageId = @intParentSettleStorageId
			END

			SELECT @dblUnitsUnposted = dblUnits FROM tblGRSettleStorageTicket WHERE intSettleStorageId = @intSettleStorageId			
			EXEC [uspGRDeleteStorageHistoryWithLog] @intSettleStorageId, @UserId
			--DELETE FROM tblGRSettleStorage WHERE intSettleStorageId = @intSettleStorageId
			--if child settle storage; delete the customer storage id in tblGRSettleStorageTicket table
			-- IF (SELECT COUNT(*) FROM tblGRSettleStorageTicket WHERE intCustomerStorageId = @intCustomerStorageId) = 2
			-- BEGIN
			-- 	--if child settle storage; delete the customer storage id in tblGRSettleStorageTicket table		
			-- 	DELETE FROM tblGRSettleStorageTicket WHERE intCustomerStorageId = @intCustomerStorageId AND intSettleStorageId = (SELECT intParentSettleStorageId FROM tblGRSettleStorage WHERE intSettleStorageId = @intSettleStorageId)
			-- END

			IF NOT EXISTS(SELECT 1 FROM tblGRSettleStorage WHERE intParentSettleStorageId = @intParentSettleStorageId)
			BEGIN
				DELETE FROM tblGRSettleStorage WHERE intSettleStorageId = @intParentSettleStorageId
			END
			ELSE
			BEGIN
				IF(SELECT dblUnits FROM tblGRSettleStorageTicket WHERE intSettleStorageId = @intParentSettleStorageId AND intCustomerStorageId = @intCustomerStorageId) <> @dblUnitsUnposted
				BEGIN
					UPDATE tblGRSettleStorageTicket SET dblUnits = dblUnits - @dblUnitsUnposted WHERE intCustomerStorageId = @intCustomerStorageId AND intSettleStorageId = @intParentSettleStorageId
				END
				ELSE
				BEGIN
					DELETE FROM tblGRSettleStorageTicket WHERE intCustomerStorageId = @intCustomerStorageId AND intSettleStorageId = @intParentSettleStorageId
				END
			END

			---This is just to insure that the parent is delete if there is no child in existence
			IF @isParentSettleStorage = 0
			BEGIN
				IF NOT EXISTS(SELECT 1 FROM tblGRSettleStorage WHERE intParentSettleStorageId = @intParentSettleStorageId)
				BEGIN					
					--UPDATE tblGRStorageHistory set intSettleStorageId  = null where intSettleStorageId = @intParentSettleStorageId				
					--DELETE FROM tblGRSettleStorage WHERE intSettleStorageId = @intParentSettleStorageId			
					EXEC [uspGRDeleteStorageHistoryWithLog] @intParentSettleStorageId, @UserId
				END
			END

			--reverse logged data in tblGRStorageInventoryReceipt when unposting a settlement
			DECLARE @ysnDPOwnedType BIT
			SELECT @ysnDPOwnedType = ISNULL(ST.ysnDPOwnedType,0) FROM tblGRCustomerStorage CS INNER JOIN tblGRStorageType ST ON ST.intStorageScheduleTypeId = CS.intStorageTypeId AND ST.ysnDPOwnedType = 1
			IF @ysnDPOwnedType = 1
			BEGIN
				--GRN-2138 - COST ADJUSTMENT LOGIC FOR DELIVERY SHEETS
				UPDATE tblGRStorageInventoryReceipt SET ysnUnposted = 1 WHERE intSettleStorageId = @intSettleStorageId
			END

			--5. Removing Voucher
			begin
				select @BillId = min(intId) from @billList
				while isnull(@BillId, 0) > 0
				begin

					EXEC uspAPDeleteVoucher 
						 @BillId
						,@UserId
						,@callerModule = 1					

					select @BillId = min(intId) from @billList where intId > @BillId
				end
			end
		
		END		
	END
	SettleStorage_Exit:
END TRY

BEGIN CATCH
	SET @ErrMsg = ERROR_MESSAGE()
	RAISERROR (@ErrMsg,16,1,'WITH NOWAIT')
END CATCH
