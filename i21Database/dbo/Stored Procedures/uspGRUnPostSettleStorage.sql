CREATE PROCEDURE [dbo].[uspGRUnPostSettleStorage]
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
	DECLARE @ItemId INT

	DECLARE @STARTING_NUMBER_BATCH AS INT = 3
		,@strBatchId AS NVARCHAR(20)
	DECLARE @ItemsToStorage AS ItemCostingTableType
	DECLARE @ItemsToPost AS ItemCostingTableType
	DECLARE @TicketNo NVARCHAR(50)
	DECLARE @intCurrencyId INT
	DECLARE @LocationId INT
	DECLARE @ItemLocationId INT
	DECLARE @dblUOMQty DECIMAL(24, 10)
	DECLARE @CommodityStockUomId INT
	DECLARE @intInventoryItemStockUOMId INT
	--DECLARE @UserName NVARCHAR(100)
	DECLARE @intParentSettleStorageId INT
	DECLARE @GLEntries AS RecapTableType
	DECLARE @intReturnValue AS INT
	
	DECLARE @isParentSettleStorage AS BIT

	DECLARE @dtmCreated AS DATETIME

	EXEC sp_xml_preparedocument @idoc OUTPUT
		,@strXml

	SELECT @intSettleStorageId = intSettleStorageId,@UserId=intEntityUserSecurityId
	FROM OPENXML(@idoc, 'root', 2) WITH (intSettleStorageId INT,intEntityUserSecurityId INT)
	
	SET @intParentSettleStorageId = @intSettleStorageId

	-- SELECT @UserName = strUserName
	-- FROM tblSMUserSecurity
	-- WHERE [intEntityId] = @UserId

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

	BEGIN
		--1. Unpost the Voucher
		
		--check first if the settle storage being deleted is the parent, then its children should be deleted first
		SELECT @isParentSettleStorage = CASE WHEN MIN(intSettleStorageId) > 0 THEN 1 ELSE 0 END
		FROM tblGRSettleStorage
		WHERE intParentSettleStorageId =@intParentSettleStorageId

		SELECT @BillId = intBillId
			,@TicketNo = strStorageTicket
			,@ItemId = intItemId
			,@LocationId = intCompanyLocationId
			,@CommodityStockUomId=intCommodityStockUomId
			,@dtmCreated = dbo.fnRemoveTimeOnDate(dtmCreated)
		FROM tblGRSettleStorage
		WHERE intSettleStorageId = @intSettleStorageId

		SELECT @strBillId = strBillId FROM tblAPBill WHERE intBillId = @BillId

		IF ISNULL(@BillId,0) = 0 AND @isParentSettleStorage = 1
		BEGIN
			SELECT @intSettleStorageId = MIN(intSettleStorageId)
			FROM tblGRSettleStorage
			WHERE intParentSettleStorageId =@intParentSettleStorageId
			
			WHILE @intSettleStorageId >0
			BEGIN
				
				SET @strXml=NULL				
				SET @strXml=N'<root><intSettleStorageId>'+LTRIM(@intSettleStorageId)+'</intSettleStorageId><intEntityUserSecurityId>'+LTRIM(@UserId)+'</intEntityUserSecurityId></root>'
				EXEC uspGRUnPostSettleStorage @strXml

				SELECT @intSettleStorageId = MIN(intSettleStorageId)
				FROM tblGRSettleStorage
				WHERE intParentSettleStorageId =@intParentSettleStorageId AND intSettleStorageId > @intSettleStorageId
			END
			DELETE tblGRSettleStorage WHERE intSettleStorageId=@intParentSettleStorageId
		END
		ELSE
		BEGIN

			SELECT @dblUOMQty=dblUnitQty 
			FROM tblICItemUOM 
			WHERE intItemUOMId=@CommodityStockUomId

			SELECT @ItemLocationId = intItemLocationId
			FROM tblICItemLocation
			WHERE intItemId = @ItemId AND intLocationId = @LocationId

			SELECT @intInventoryItemStockUOMId = intItemUOMId
			FROM tblICItemUOM
			WHERE intItemId = @ItemId AND ysnStockUnit=1

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
					,@userId = @UserId
			END

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
			JOIN tblGRSettleStorageTicket SST ON SST.intSettleStorageTicketId = UH.intExternalId AND SST.intSettleStorageId = UH.intExternalHeaderId
			JOIN tblGRStorageHistory SH ON SH.intContractHeaderId = UH.intContractHeaderId AND SH.intCustomerStorageId = SST.intCustomerStorageId
			WHERE UH.intExternalHeaderId = @intSettleStorageId AND UH.strScreenName = 'Settle Storage' AND UH.strFieldName = 'Balance' AND SH.strType IN ('From Scale','From Delivery Sheet')
		
			UNION ALL
		
			SELECT 
				 intSettleStorageTicketId  = UH.intExternalId
				,intPricingTypeId		   = 1 
				,strDepletionType		   = 'Purchase Contract' 
				,intContractHeaderId	   = UH.intContractHeaderId 
				,intContractDetailId       = UH.intContractDetailId 
				,dblUnits                  = UH.dblTransactionQuantity
			FROM tblCTSequenceUsageHistory UH
			JOIN tblGRSettleStorageTicket SST ON SST.intSettleStorageTicketId = UH.intExternalId AND SST.intSettleStorageId = UH.intExternalHeaderId
			JOIN tblGRStorageHistory SH ON SH.intContractHeaderId = UH.intContractHeaderId AND SH.intCustomerStorageId = SST.intCustomerStorageId AND SH.intSettleStorageId = UH.intExternalHeaderId
			WHERE UH.intExternalHeaderId = @intSettleStorageId AND UH.strScreenName = 'Settle Storage' AND UH.strFieldName = 'Balance' AND SH.strType = 'Settlement'

			BEGIN
				DECLARE @intDepletionKey INT
				DECLARE @intPricingTypeId INT
				DECLARE @intSettleStorageTicketId INT
				DECLARE @intContractDetailId INT
				DECLARE @intItemUOMId INT
				DECLARE @dblCost DECIMAL(24, 10)

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
						 @intSettleStorageTicketId = intSettleStorageTicketId
						,@intPricingTypeId = intPricingTypeId
						,@intContractDetailId = intContractDetailId
						,@dblUnits = dblUnits
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
				SET CS.dblOpenBalance = CS.dblOpenBalance + SH.dblUnit
				FROM tblGRCustomerStorage CS
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

				DELETE
				FROM @ItemsToStorage

				DELETE
				FROM @ItemsToPost

				DELETE 
				FROM @GLEntries

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

		-- Unpost storage stocks. 
				 EXEC	
				 @intReturnValue = dbo.uspICUnpostStorage
				 @intSettleStorageId
				,@TicketNo
				,@strBatchId
				,@UserId
				,0
		
				IF @intReturnValue < 0 GOTO SettleStorage_Exit;

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
				EXEC uspGRCreateGLEntries 
					 'Storage Settlement'
					,'OtherCharges'
					,@intSettleStorageId
					,@strBatchId
					,@UserId
					,0
					,@dtmCreated
				UPDATE @GLEntries 
				SET dblDebit = dblCredit
				,dblCredit   = dblDebit
						
				IF EXISTS (SELECT TOP 1 1 FROM @GLEntries) 
				BEGIN 
							EXEC dbo.uspGLBookEntries @GLEntries, 0 
				END

				/* UNPOST STORAGE Cost adjustment */

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
				SELECT 
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
				FROM(SELECT 
								item.intItemId
							,item.strItemNo
							,strBatchId = @strBatchId
							,dtmDate = GS.dtmDeliveryDate
							,[intAccountId] = [dbo].[fnGetItemGLAccount](item.intItemId, @LocationId,'Inventory')
							,dblDebit = CASE WHEN Debit.Value < 0 THEN Debit.Value * -1 ELSE Debit.Value END
							,dblCredit = CASE WHEN Credit.Value < 0 THEN Credit.Value * -1 ELSE Credit.Value END
							,dblDebitUnit = 0
							,dblCreditUnit = 0
							,strDescription = GL.strDescription + ', Cost Adjustment'
							,strCode = 'GR'
							,strReference = 'A'
							,intCurrencyId = GS.intCurrencyId
							,dtmDateEntered    = GETDATE()
							,dtmTransactionDate = GS.dtmDeliveryDate
							,strJournalLineDescription = ''
							,intJournalLineNo   = GS.intCustomerStorageId
							,ysnIsUnposted    = 0
							,intUserId     = NULL
							,intEntityId    = GS.intEntityId
							,strTransactionId   = SS.strStorageTicket
							,intTransactionId   = SS.intSettleStorageId
							,strTransactionType   = 'Storage Settlement'
							,strTransactionForm   = 'Storage Settlement'
							,strModuleName    = 'Grain'
							,intConcurrencyId   = 1
							,dblDebitForeign   = CASE WHEN B.intCurrencyId <> 1 THEN Debit.Value ELSE 0 END
							,dblDebitReport    = NULL
							,dblCreditForeign   = CASE WHEN B.intCurrencyId <> 1 THEN Credit.Value ELSE 0 END
							,dblCreditReport   = NULL
							,dblReportingRate   = NULL
							,dblExchangeRate = GS.dblCurrencyRate
							,dblForeignRate    =  B.dblRate
							,strRateType    = EXR.strCurrencyExchangeRateType
					FROM tblAPBill A 
					INNER JOIN tblAPBillDetail B
						ON A.intBillId = B.intBillId
					INNER JOIN tblGRCustomerStorage GS 
						ON GS.intCustomerStorageId = B.intCustomerStorageId
					INNER JOIN (
						tblICInventoryReceipt E1 INNER JOIN tblICInventoryReceiptItem E2 
							ON E1.intInventoryReceiptId = E2.intInventoryReceiptId
						LEFT JOIN tblICItemLocation sourceLocation
							ON sourceLocation.intItemId = E2.intItemId
							AND sourceLocation.intLocationId = E1.intLocationId
						LEFT JOIN tblSMFreightTerms ft
							ON ft.intFreightTermId = E1.intFreightTermId
						LEFT JOIN tblICFobPoint fp
							ON fp.strFobPoint = ft.strFreightTerm
					)
						ON GS.intTicketId= E2.intSourceId
					INNER JOIN tblICItem item 
						ON B.intItemId = item.intItemId
					INNER JOIN tblICItemLocation D
						ON D.intLocationId = A.intShipToId AND D.intItemId = item.intItemId
					LEFT JOIN tblICItemUOM itemUOM
						ON itemUOM.intItemUOMId = B.intUnitOfMeasureId
					LEFT JOIN tblICItemUOM voucherCostUOM
						ON voucherCostUOM.intItemUOMId = ISNULL(B.intCostUOMId, B.intUnitOfMeasureId)
					LEFT JOIN tblICItemUOM receiptCostUOM
						ON receiptCostUOM.intItemUOMId = ISNULL(E2.intCostUOMId, E2.intUnitMeasureId)
					LEFT JOIN tblICInventoryTransactionType transType
						ON transType.strName = 'Bill'
					LEFT JOIN tblSMCurrencyExchangeRateType EXR
						ON EXR.intCurrencyExchangeRateTypeId = B.intCurrencyExchangeRateTypeId
					LEFT JOIN tblGRSettleStorage SS
						ON SS.intBillId = A.intBillId
					INNER JOIN tblGLAccount GL
						ON GL.intAccountId = [dbo].[fnGetItemGLAccount](item.intItemId, @LocationId, 'Inventory')
					CROSS APPLY (SELECT CASE WHEN dbo.fnCalculateCostBetweenUOM(voucherCostUOM.intItemUOMId,receiptCostUOM.intItemUOMId,B.dblCost) > B.dblQtyReceived - (E2.dblUnitCost * E2.dblReceived) THEN dbo.fnCalculateCostBetweenUOM(voucherCostUOM.intItemUOMId,receiptCostUOM.intItemUOMId,B.dblCost) * B.dblQtyReceived - (E2.dblUnitCost * E2.dblReceived) ELSE 0 END Value) as Debit
					CROSS APPLY (SELECT CASE WHEN dbo.fnCalculateCostBetweenUOM(voucherCostUOM.intItemUOMId,receiptCostUOM.intItemUOMId,B.dblCost) > B.dblQtyReceived - (E2.dblUnitCost * E2.dblReceived) THEN 0 ELSE dbo.fnCalculateCostBetweenUOM(voucherCostUOM.intItemUOMId,receiptCostUOM.intItemUOMId,B.dblCost) * B.dblQtyReceived - (E2.dblUnitCost * E2.dblReceived) END Value) as Credit
					WHERE A.intBillId = @BillId
					AND B.intInventoryReceiptItemId IS NULL 
					AND E2.intOwnershipType != 2
					AND (
						dbo.fnCalculateCostBetweenUOM(
							voucherCostUOM.intItemUOMId
							,receiptCostUOM.intItemUOMId
							,B.dblCost - (B.dblCost * (B.dblDiscount / 100))
							) <> E2.dblUnitCost
						OR E2.dblForexRate <> B.dblRate
					) AND item.intItemId = E2.intItemId

					UNION
					SELECT 
									item.intItemId
								,item.strItemNo
								,strBatchId = @strBatchId
								,dtmDate = GS.dtmDeliveryDate
								,[intAccountId] = [dbo].[fnGetItemGLAccount](item.intItemId, @LocationId,'AP Clearing')
								,dblDebit = CASE WHEN Credit.Value < 0 THEN Credit.Value * -1 ELSE Credit.Value END
								,dblCredit = CASE WHEN Debit.Value < 0 THEN Debit.Value * -1 ELSE Debit.Value END
								,dblDebitUnit = 0
								,dblCreditUnit = 0
								,strDescription = GL.strDescription + ', Cost Adjustment'
								,strCode = 'GR'
								,strReference = 'A'
								,intCurrencyId = GS.intCurrencyId
								,dtmDateEntered    = GETDATE()
								,dtmTransactionDate = GS.dtmDeliveryDate
								,strJournalLineDescription = ''
								,intJournalLineNo   = GS.intCustomerStorageId
								,ysnIsUnposted    = 0
								,intUserId     = NULL
								,intEntityId    = GS.intEntityId
								,strTransactionId   = SS.strStorageTicket
								,intTransactionId   = SS.intSettleStorageId
								,strTransactionType   = 'Storage Settlement'
								,strTransactionForm   = 'Storage Settlement'
								,strModuleName    = 'Grain'
								,intConcurrencyId   = 1
								,dblDebitForeign   = CASE WHEN B.intCurrencyId <> 1 THEN Debit.Value ELSE 0 END
								,dblDebitReport    = NULL
								,dblCreditForeign   = CASE WHEN B.intCurrencyId <> 1 THEN Credit.Value ELSE 0 END
								,dblCreditReport   = NULL
								,dblReportingRate   = NULL
								,dblExchangeRate = GS.dblCurrencyRate
								,dblForeignRate    =  B.dblRate
								,strRateType    = EXR.strCurrencyExchangeRateType
					FROM tblAPBill A 
					INNER JOIN tblAPBillDetail B
						ON A.intBillId = B.intBillId
					INNER JOIN tblGRCustomerStorage GS 
						ON GS.intCustomerStorageId = B.intCustomerStorageId
					INNER JOIN (
						tblICInventoryReceipt E1 INNER JOIN tblICInventoryReceiptItem E2 
							ON E1.intInventoryReceiptId = E2.intInventoryReceiptId
						LEFT JOIN tblICItemLocation sourceLocation
							ON sourceLocation.intItemId = E2.intItemId
							AND sourceLocation.intLocationId = E1.intLocationId
						LEFT JOIN tblSMFreightTerms ft
							ON ft.intFreightTermId = E1.intFreightTermId
						LEFT JOIN tblICFobPoint fp
							ON fp.strFobPoint = ft.strFreightTerm
					)
						ON GS.intTicketId= E2.intSourceId
					INNER JOIN tblICItem item 
						ON B.intItemId = item.intItemId
					INNER JOIN tblICItemLocation D
						ON D.intLocationId = A.intShipToId AND D.intItemId = item.intItemId
					LEFT JOIN tblICItemUOM itemUOM
						ON itemUOM.intItemUOMId = B.intUnitOfMeasureId
					LEFT JOIN tblICItemUOM voucherCostUOM
						ON voucherCostUOM.intItemUOMId = ISNULL(B.intCostUOMId, B.intUnitOfMeasureId)
					LEFT JOIN tblICItemUOM receiptCostUOM
						ON receiptCostUOM.intItemUOMId = ISNULL(E2.intCostUOMId, E2.intUnitMeasureId)
					LEFT JOIN tblICInventoryTransactionType transType
						ON transType.strName = 'Bill'
					LEFT JOIN tblSMCurrencyExchangeRateType EXR
						ON EXR.intCurrencyExchangeRateTypeId = B.intCurrencyExchangeRateTypeId
					LEFT JOIN tblGRSettleStorage SS
						ON SS.intBillId = A.intBillId
					INNER JOIN tblGLAccount GL
						ON GL.intAccountId = [dbo].[fnGetItemGLAccount](item.intItemId, @LocationId,'AP Clearing')
					CROSS APPLY (SELECT CASE WHEN dbo.fnCalculateCostBetweenUOM(voucherCostUOM.intItemUOMId,receiptCostUOM.intItemUOMId,B.dblCost) > B.dblQtyReceived - (E2.dblUnitCost * E2.dblReceived) THEN dbo.fnCalculateCostBetweenUOM(voucherCostUOM.intItemUOMId,receiptCostUOM.intItemUOMId,B.dblCost) * B.dblQtyReceived - (E2.dblUnitCost * E2.dblReceived) ELSE 0 END Value) as Debit
					CROSS APPLY (SELECT CASE WHEN dbo.fnCalculateCostBetweenUOM(voucherCostUOM.intItemUOMId,receiptCostUOM.intItemUOMId,B.dblCost) > B.dblQtyReceived - (E2.dblUnitCost * E2.dblReceived) THEN 0 ELSE dbo.fnCalculateCostBetweenUOM(voucherCostUOM.intItemUOMId,receiptCostUOM.intItemUOMId,B.dblCost) * B.dblQtyReceived - (E2.dblUnitCost * E2.dblReceived) END Value) as Credit
					WHERE A.intBillId = @BillId
					AND B.intInventoryReceiptItemId IS NULL 
					AND E2.intOwnershipType != 2
					AND (
						dbo.fnCalculateCostBetweenUOM(
							voucherCostUOM.intItemUOMId
							,receiptCostUOM.intItemUOMId
							,B.dblCost - (B.dblCost * (B.dblDiscount / 100))
							) <> E2.dblUnitCost
						OR E2.dblForexRate <> B.dblRate
					) AND item.intItemId = E2.intItemId
				) GLEntries

				UPDATE @GLEntries 
				SET dblDebit = dblCredit
				,dblCredit   = dblDebit

				IF EXISTS (SELECT TOP 1 1 FROM @GLEntries) 
				BEGIN 
						EXEC dbo.uspGLBookEntries @GLEntries, 0 
				END

				/* END UNPOST STORAGE Cost adjustment */

			END

			--4. Deleting History
			BEGIN
				--EXEC uspGRDeleteStorageHistory 
				--	 'Voucher'
				--	,@BillId			
				INSERT INTO [dbo].[tblGRStorageHistory] 
				(
					 [intConcurrencyId]
					,[intCustomerStorageId]
					,[intContractHeaderId]
					,[dblUnits]
					,[dtmHistoryDate]
					,[strType]
					,[strUserName]
					,[intUserId]
					,[intEntityId]
					,[strSettleTicket]
					,[intTransactionTypeId]
					,[dblPaidAmount]
					,[intBillId]
					,[intSettleStorageId]
					,[strVoucher]
				)
				SELECT 
					 [intConcurrencyId]		= 1 
					,[intCustomerStorageId] = [intCustomerStorageId]
					,[intContractHeaderId]  = [intContractHeaderId]
					,[dblUnits]				= [dblUnits]
					,[dtmHistoryDate]		= GETDATE()
					,[strType]				= 'Reverse Settlement'
					,[strUserName]			= NULL
					,[intUserId]			= @UserId
					,[intEntityId]			= [intEntityId]
					,[strSettleTicket]		= [strSettleTicket]
					,[intTransactionTypeId]	= 4
					,[dblPaidAmount]		= [dblPaidAmount]
					,[intBillId]			= NULL
					,[intSettleStorageId]   = NULL
					,[strVoucher]           = strVoucher
				FROM tblGRStorageHistory
				WHERE intSettleStorageId=@intSettleStorageId

				UPDATE tblGRStorageHistory SET intSettleStorageId=NULL,intBillId=NULL WHERE intSettleStorageId=@intSettleStorageId

			END
			DELETE tblGRSettleStorage WHERE intSettleStorageId=@intSettleStorageId
		
			EXEC uspICUnpostCostAdjustment @BillId, @strBillId, @strBatchId, @UserId, DEFAULT
			
			--5. Removing Voucher
			BEGIN
				EXEC uspAPDeleteVoucher 
					 @BillId
					,@UserId
			END
		
		END		
	END

	SettleStorage_Exit:
END TRY

BEGIN CATCH
	SET @ErrMsg = ERROR_MESSAGE()
	RAISERROR (@ErrMsg,16,1,'WITH NOWAIT')
END CATCH
