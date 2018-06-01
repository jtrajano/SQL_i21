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
	DECLARE @UserName NVARCHAR(100)
	DECLARE @intParentSettleStorageId INT
	DECLARE @GLEntries AS RecapTableType
	DECLARE @intReturnValue AS INT
	
	EXEC sp_xml_preparedocument @idoc OUTPUT
		,@strXml

	SELECT @intSettleStorageId = intSettleStorageId,@UserId=intEntityUserSecurityId
	FROM OPENXML(@idoc, 'root', 2) WITH (intSettleStorageId INT,intEntityUserSecurityId INT)
	
	SET @intParentSettleStorageId = @intSettleStorageId

	SELECT @UserName = strUserName
	FROM tblSMUserSecurity
	WHERE [intEntityId] = @UserId

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
		SELECT @BillId = intBillId
			,@TicketNo = strStorageTicket
			,@ItemId = intItemId
			,@LocationId = intCompanyLocationId
			,@CommodityStockUomId=intCommodityStockUomId
		FROM tblGRSettleStorage
		WHERE intSettleStorageId = @intSettleStorageId

		IF ISNULL(@BillId,0) = 0
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

				INSERT INTO @ItemsToStorage 
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
					,intSubLocationId
					,intStorageLocationId
					,ysnIsStorage
				)
				SELECT 
					 intItemId					= @ItemId
					,intItemLocationId			= @ItemLocationId
					,intItemUOMId				= @intInventoryItemStockUOMId
					,dtmDate					= GETDATE()
					,dblQty						= CASE WHEN ST.strOwnedPhysicalStock ='Customer' THEN SH.dblUnits ELSE 0 END
					,dblUOMQty					= @dblUOMQty
					,dblCost					= SH.dblPaidAmount
					,dblSalesPrice				= 0.00
					,intCurrencyId				= @intCurrencyId
					,dblExchangeRate			= 1
					,intTransactionId			= @intSettleStorageId
					,intTransactionDetailId		= @intSettleStorageId
					,strTransactionId			= @TicketNo
					,intTransactionTypeId		= 44
					,intSubLocationId			= CS.intCompanyLocationSubLocationId
					,intStorageLocationId		= CS.intStorageLocationId
					,ysnIsStorage				= 1
				FROM tblGRStorageHistory SH
				JOIN tblGRCustomerStorage CS ON CS.intCustomerStorageId = SH.intCustomerStorageId
				JOIN tblGRStorageType ST ON ST.intStorageScheduleTypeId = CS.intStorageTypeId
				WHERE SH.intSettleStorageId = @intSettleStorageId

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
					,intSubLocationId
					,intStorageLocationId
					,ysnIsStorage
				)
				SELECT 
					 intItemId					= @ItemId
					,intItemLocationId			= @ItemLocationId
					,intItemUOMId				= @intInventoryItemStockUOMId
					,dtmDate					= GETDATE()
					,dblQty						= CASE WHEN ST.strOwnedPhysicalStock ='Customer' THEN SH.dblUnits ELSE 0 END
					,dblUOMQty					= @dblUOMQty
					,dblCost					= SH.dblPaidAmount + ISNULL(OtherCharge.dblCashPrice,0) 
					,dblSalesPrice				= 0.00
					,intCurrencyId				= @intCurrencyId
					,dblExchangeRate			= 1
					,intTransactionId			= @intSettleStorageId
					,intTransactionDetailId		= @intSettleStorageId
					,strTransactionId			= @TicketNo
					,intTransactionTypeId		= 44
					,intSubLocationId			= CS.intCompanyLocationSubLocationId
					,intStorageLocationId		= CS.intStorageLocationId
					,ysnIsStorage = 0
				FROM tblGRStorageHistory SH
				JOIN tblGRCustomerStorage CS ON CS.intCustomerStorageId = SH.intCustomerStorageId
				JOIN tblGRStorageType ST ON ST.intStorageScheduleTypeId = CS.intStorageTypeId
				JOIN
				(
					SELECT 
					CS.intCustomerStorageId
					,SUM(dbo.fnCTConvertQuantityToTargetItemUOM(CS.intItemId, CU.intUnitMeasureId, CS.intUnitMeasureId, ISNULL(QM.dblDiscountPaid, 0)) - dbo.fnCTConvertQuantityToTargetItemUOM(CS.intItemId, CU.intUnitMeasureId, CS.intUnitMeasureId, ISNULL(QM.dblDiscountDue, 0))) AS dblCashPrice
					FROM tblGRCustomerStorage CS
					JOIN tblGRSettleStorageTicket SST ON SST.intCustomerStorageId = CS.intCustomerStorageId AND SST.intSettleStorageId = @intSettleStorageId AND SST.dblUnits > 0
					JOIN tblICCommodityUnitMeasure CU ON CU.intCommodityId = CS.intCommodityId AND CU.ysnStockUnit = 1
					JOIN tblQMTicketDiscount QM ON QM.intTicketFileId = CS.intCustomerStorageId AND QM.strSourceType = 'Storage'
					WHERE ISNULL(CS.strStorageType, '') <> 'ITR' AND (ISNULL(QM.dblDiscountDue, 0) - ISNULL(QM.dblDiscountPaid, 0)) <> 0
					GROUP BY CS.intCustomerStorageId
				)OtherCharge ON OtherCharge.intCustomerStorageId = CS.intCustomerStorageId

				WHERE SH.intSettleStorageId = @intSettleStorageId

				BEGIN
					EXEC uspICPostStorage 
						 @ItemsToStorage
						,@strBatchId
						,@UserId

					IF @@ERROR <> 0
						GOTO SettleStorage_Exit;
				END

				BEGIN
					--EXEC uspICPostCosting 
					--	 @ItemsToPost
					--	,@strBatchId
					--	,'Cost of Goods'
					--	,@UserId

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
					EXEC	@intReturnValue = dbo.uspICPostCosting  
							@ItemsToPost  
							,@strBatchId  
							,'AP Clearing'
							,@UserId
					
					IF @intReturnValue < 0
						GOTO SettleStorage_Exit;
					
					UPDATE @GLEntries 
					SET dblDebit = CASE WHEN dblCredit > 0 THEN dblCredit ELSE 0 END
					,dblCredit   = CASE WHEN dblDebit > 0  THEN dblDebit ELSE 0 END

					IF EXISTS (SELECT TOP 1 1 FROM @GLEntries)
					BEGIN 
							EXEC dbo.uspGLBookEntries @GLEntries, 0 
					END

					IF @@ERROR <> 0
						GOTO SettleStorage_Exit;
				END
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
					,[strUserName]			= @UserName
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
