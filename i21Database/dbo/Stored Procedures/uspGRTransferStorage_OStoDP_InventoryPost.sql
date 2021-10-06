CREATE PROCEDURE [dbo].[uspGRTransferStorage_OStoDP_InventoryPost]
(
	@ItemsToPost AS ItemCostingTableType READONLY
	,@intTransferStorageId INT
	,@intUserId INT
)
AS
SET ANSI_WARNINGS ON

BEGIN
	DECLARE @ItemsToPostCopy AS ItemCostingTableType
	DECLARE @dblBasisCost DECIMAL(38,20)
	DECLARE @dblSettlementPrice DECIMAL(38,20)
	DECLARE @intTransactionDetailId INT
	DECLARE @cursorId INT
	DECLARE @intOwnerShipId INT = 1	

	DECLARE _CURSOR CURSOR
	FOR
	SELECT intId, intTransactionDetailId FROM @ItemsToPost
	
	OPEN _CURSOR
	FETCH NEXT FROM _CURSOR INTO @cursorId, @intTransactionDetailId
	WHILE @@FETCH_STATUS = 0
	BEGIN		
			DECLARE @GLEntries AS RecapTableType
			DECLARE @DummyGLEntries AS RecapTableType
			DECLARE @dblInventoryItemCost AS DECIMAL(24,10)
			DECLARE @dblOriginalCost AS DECIMAL(24,10)
			DECLARE @dblDiscountCost AS DECIMAL(24,10)
			DECLARE @dblUnits AS DECIMAL(24,10)
			DECLARE @strBatchId AS NVARCHAR(40)
			DECLARE @GLForItem AS GLForItem

			EXEC uspSMGetStartingNumber 3, @strBatchId OUT

			DELETE FROM @ItemsToPostCopy
			INSERT INTO @ItemsToPostCopy 
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
			WHERE intTransactionDetailId = @intTransactionDetailId

			DECLARE @intItemId INT
				,@intCommodityId INT
				,@intFutureMarketId INT
				,@intFutureMonthId INT
				,@intLocationId INT
				,@intSubLocationId INT
				,@intStorageLocationId INT
				,@dtmDate DATETIME						
				,@strRKError VARCHAR(MAX)
				,@ysnDPtoOtherStorage BIT
				,@ysnFromDS BIT

			--Check if Transfer is DP To Other Storage (Disregard Risk Error)
			SELECT 
				@ysnFromDS = CASE WHEN FromStorage.intDeliverySheetId IS NOT NULL THEN 1 ELSE 0 END
			FROM tblGRTransferStorageReference SR
			INNER JOIN tblGRCustomerStorage FromStorage
				ON FromStorage.intCustomerStorageId = SR.intSourceCustomerStorageId
			WHERE SR.intTransferStorageReferenceId = @intTransactionDetailId		

			SELECT @intItemId			= ITP.intItemId
				,@intLocationId			= IL.intLocationId
				,@intSubLocationId		= ITP.intSubLocationId
				,@intStorageLocationId	= ITP.intStorageLocationId
				,@dtmDate				= ITP.dtmDate				
				,@dblUnits				= ITP.dblQty	
			FROM @ItemsToPostCopy ITP
			INNER JOIN tblICItemLocation IL
				ON IL.intItemLocationId = ITP.intItemLocationId
			WHERE intId = @cursorId

			SELECT @intCommodityId = intCommodityId FROM tblICItem WHERE intItemId = @intItemId
			-- Get default futures market and month for the commodity
			EXEC uspSCGetDefaultFuturesMarketAndMonth @intCommodityId, @intFutureMarketId OUTPUT, @intFutureMonthId OUTPUT;
						
			/*NOTE: OS to DP >> get the current basis and settlement price in Risk*/	
			SELECT @dblBasisCost = (SELECT dblBasis FROM dbo.fnRKGetFutureAndBasisPrice (1,I.intCommodityId,right(convert(varchar, dtmDate, 106),8),3,@intFutureMarketId,@intFutureMonthId,@intLocationId,NULL,0,I.intItemId,intCurrencyId))
				,@dblSettlementPrice  = (SELECT dblSettlementPrice FROM dbo.fnRKGetFutureAndBasisPrice (1,I.intCommodityId,right(convert(varchar, dtmDate, 106),8),3,@intFutureMarketId,@intFutureMonthId,@intLocationId,NULL,0,I.intItemId,intCurrencyId))
			FROM @ItemsToPostCopy ITP
			INNER JOIN tblICItem I
				ON ITP.intItemId = I.intItemId
			INNER JOIN tblICCommodity ICC
				ON ICC.intCommodityId = I.intCommodityId
			INNER JOIN tblICItemLocation IL
				ON IL.intItemLocationId = ITP.intItemLocationId
			WHERE intId = @cursorId

			SELECT @strRKError = CASE 
								WHEN @dblBasisCost IS NULL AND @dblSettlementPrice > 0 THEN 'Basis in Risk Management is not available.'
								WHEN @dblSettlementPrice IS NULL AND @dblBasisCost > 0 THEN 'Settlement Price in Risk Management is not available.'
								WHEN @dblBasisCost IS NULL AND @dblSettlementPrice IS NULL THEN 'Basis and Settlement Price in Risk Management are not available.'
							END

			IF @strRKError IS NOT NULL
			BEGIN
				RAISERROR (@strRKError,16,1,'WITH NOWAIT') 
			END

			--update the Basis and Settlement Price of the new customer storage
			UPDATE CS
			SET dblBasis = @dblBasisCost
				,dblSettlementPrice = @dblSettlementPrice
			FROM tblGRCustomerStorage CS
			INNER JOIN tblGRTransferStorageReference SR
				ON SR.intTransferStorageReferenceId = @intTransactionDetailId
			WHERE CS.intCustomerStorageId = SR.intToCustomerStorageId

			--select '@dblBasisCost3',@dblBasisCost,'@dblSettlementPrice3',@dblSettlementPrice

			SET @dblInventoryItemCost =ISNULL(@dblSettlementPrice,0) + ISNULL(@dblBasisCost,0)
			set @dblOriginalCost = @dblInventoryItemCost
							
			/*start >> other charges*/	
			DECLARE @OtherChargesDetail AS TABLE(
				intOtherChargesDetailId INT IDENTITY(1, 1)
				,strOrderType NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
				,intCustomerStorageId INT
				,intCompanyLocationId INT
				,dblUnits DECIMAL(24, 10)
				,dblCashPrice DECIMAL(24, 10)
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
														--ROUND((SR.dblUnitQty / CS.dblOriginalBalance) * CS.dblGrossQuantity,10)
														ROUND((CS.dblGrossQuantity  * (isnull(SR.dblSplitPercent, 100) / 100)) ,10)
													END
												ELSE SR.dblUnitQty
											END
				,dblCashPrice				= CASE 
												WHEN QM.strDiscountChargeType = 'Percent'
															THEN (dbo.fnCTConvertQuantityToTargetItemUOM(CS.intItemId, IU.intUnitMeasureId, CS.intUnitMeasureId, ISNULL(QM.dblDiscountPaid, 0)) - dbo.fnCTConvertQuantityToTargetItemUOM(CS.intItemId, IU.intUnitMeasureId, CS.intUnitMeasureId, ISNULL(QM.dblDiscountDue, 0)))
																*
																@dblInventoryItemCost
												ELSE --Dollar
													dbo.fnCTConvertQuantityToTargetItemUOM(CS.intItemId, IU.intUnitMeasureId, CS.intUnitMeasureId, ISNULL(QM.dblDiscountPaid, 0)) - dbo.fnCTConvertQuantityToTargetItemUOM(CS.intItemId, IU.intUnitMeasureId, CS.intUnitMeasureId, ISNULL(QM.dblDiscountDue, 0))
											END
				,dblExactCashPrice			= 0
				,intItemId					= ITP.intItemId
				,intItemType				= 3 
				,IsProcessed				= 0
				,intTicketDiscountId		= QM.intTicketDiscountId
				,ysnDiscountFromGrossWeight	= CASE
												WHEN DCO.strDiscountCalculationOption = 'Gross Weight' THEN 1
												ELSE 0
											END
				,ysnIsPercent				=  CASE WHEN QM.strDiscountChargeType = 'Percent' THEN 1 ELSE 0 END							
			FROM @ItemsToPostCopy ITP
			JOIN tblGRTransferStorageReference SR
				ON ITP.intTransactionId = SR.intTransferStorageId
				AND ITP.intTransactionDetailId = SR.intTransferStorageReferenceId
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
			WHERE (ISNULL(QM.dblDiscountDue, 0) - ISNULL(QM.dblDiscountPaid, 0)) <> 0
				AND ITP.intId = @cursorId
							
			--add discount cost in item cost if tblICItem.ysnInventoryCost = 1	
			SELECT @dblInventoryItemCost = @dblInventoryItemCost + ISNULL(SUM(dblCashPrice),0) 
			FROM @OtherChargesDetail OCD 
			INNER JOIN tblICItem IC
				ON IC.intItemId = OCD.intItemId
			WHERE IC.ysnInventoryCost = 1

			update @OtherChargesDetail set dblExactCashPrice = ROUND(dblUnits*dblCashPrice,2)
			/*end >> other charges*/

			DELETE FROM @GLEntries
			DELETE FROM @GLForItem
									
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
			FROM @ItemsToPostCopy WHERE intId = @cursorId

			UPDATE @ItemsToPostCopy SET dblCost = @dblInventoryItemCost

			EXEC dbo.uspICPostStorage @ItemsToPostCopy,@strBatchId,@intUserId

			UPDATE @ItemsToPostCopy SET dblQty = dblQty*-1

			DELETE FROM @DummyGLEntries
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
				,[intSourceEntityId]
				,[intCommodityId]
			)
			EXEC dbo.uspICPostCosting @ItemsToPostCopy,@strBatchId,'AP Clearing',@intUserId

			--Used total discount cost on @GLForItem to get the correct decimal
			--inventory items
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
				@strBatchId	= @strBatchId
				,@GLEntries	= @GLForItem
				,@AccountCategory_ContraInventory ='AP Clearing'
				,@intEntityUserSecurityId = @intUserId
				,@ysnDPtoOS = 0

			--discounts and charges
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
				EXEC [dbo].[uspGRCreateGLEntriesForTransferStorage] 
					@intTransferStorageId
					,@intTransactionDetailId
					,@strBatchId
					,@dblOriginalCost
					,1
									
			END
			--select '@GLEntries',* from @GLEntries
			IF EXISTS (SELECT TOP 1 1 FROM @GLEntries)
			BEGIN 
				EXEC dbo.uspGLBookEntries @GLEntries, 1 
			END

			
	FETCH NEXT FROM _CURSOR INTO @cursorId, @intTransactionDetailId
	END
	CLOSE _CURSOR;
	DEALLOCATE _CURSOR;
END