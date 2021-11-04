CREATE PROCEDURE [dbo].[uspGRTransferStorage_DPtoOS_InventoryPost]
(
	@ItemsToPost ItemCostingTableType READONLY
	,@intTransferStorageId INT
	,@intUserId INT    
)
AS

SET ANSI_WARNINGS ON

BEGIN
	DECLARE @errorAdjustment NVARCHAR(MAX)
	DECLARE @ItemsToPostCopy AS ItemCostingTableType
	DECLARE @dblBasisCost DECIMAL(38,20)
	DECLARE @dblSettlementPrice DECIMAL(38,20)
	DECLARE @intTransactionDetailId INT
	DECLARE @cursorId INT
	DECLARE @intOwnerShipId INT = 1
	DECLARE @intReturnValue INT	

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
			DECLARE @dblGLCost AS DECIMAL(24,10)
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
				,-dblQty
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
			FROM @ItemsToPost WHERE intTransactionDetailId = @intTransactionDetailId

			DECLARE @intItemId INT
				,@intLocationId INT
				,@intSubLocationId INT
				,@intStorageLocationId INT
				,@dtmDate DATETIME				
				,@strRKError VARCHAR(MAX)
				,@ysnDPtoOtherStorage BIT
				,@ysnFromDS BIT
			--Check if Transfer is DP To Other Storage (Disregard Risk Error)
			SELECT 
				@ysnFromDS				= CASE WHEN FromStorage.intDeliverySheetId IS NOT NULL THEN 1 ELSE 0 END
				,@dblBasisCost			= FromStorage.dblBasis
				,@dblSettlementPrice	= FromStorage.dblSettlementPrice
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

			SET @dblInventoryItemCost =ISNULL(@dblSettlementPrice,0) + ISNULL(@dblBasisCost,0)
			SET @dblOriginalCost = @dblInventoryItemCost
	
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
			DELETE FROM @OtherChargesDetail
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
														ROUND((CS.dblGrossQuantity  * (ISNULL(SR.dblSplitPercent, 100) / 100)) ,10)
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
				,intItemId					= DItem.intItemId 
				,intItemType				= 3 
				,IsProcessed				= 0
				,intTicketDiscountId		= QM.intTicketDiscountId
				,ysnDiscountFromGrossWeight	= CASE
												WHEN DCO.strDiscountCalculationOption = 'Gross Weight' THEN 1
												ELSE 0
											END
				,ysnIsPercent				= CASE WHEN QM.strDiscountChargeType = 'Percent' THEN 1 ELSE 0 END							
			FROM @ItemsToPostCopy ITP
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
			WHERE (ISNULL(QM.dblDiscountDue, 0) - ISNULL(QM.dblDiscountPaid, 0)) <> 0
				AND ITP.intId = @cursorId
							
			--add discount cost in item cost if tblICItem.ysnInventoryCost = 1
			SELECT @dblInventoryItemCost = @dblInventoryItemCost + ISNULL(SUM(dblCashPrice),0) 
			FROM @OtherChargesDetail OCD 
			INNER JOIN tblICItem IC
				ON IC.intItemId = OCD.intItemId
			WHERE IC.ysnInventoryCost = 1

			UPDATE @OtherChargesDetail SET dblExactCashPrice = ROUND(dblUnits*dblCashPrice,2)
			
			IF @dblOriginalCost <> @dblInventoryItemCost
			BEGIN
				SET @dblGLCost = (@dblOriginalCost - @dblInventoryItemCost) * (@dblUnits)
			END
			ELSE
			BEGIN
				SET @dblGLCost = NULL
			END

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
			SELECT intItemId,intItemLocationId,intItemUOMId,dtmDate,dblQty,dblUOMQty,@dblGLCost,dblSalesPrice,intCurrencyId,dblExchangeRate,intTransactionId,intTransactionDetailId,strTransactionId,intTransactionTypeId,intLotId,intSubLocationId,intStorageLocationId,ysnIsStorage,intStorageScheduleTypeId 
			FROM @ItemsToPostCopy WHERE intId = @cursorId

			--select '@GLForItem',* from @GLForItem

			UPDATE @ItemsToPostCopy SET dblCost = @dblInventoryItemCost

			--Post Inventory items in Inventory valuation
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
			EXEC dbo.uspICPostCosting 
				@ItemsToPost	= @ItemsToPostCopy
				,@strBatchId	= @strBatchId
				,@strAccountToCounterInventory	= 'AP Clearing'
				,@intEntityUserSecurityId	= @intUserId
				
			IF @ysnFromDS = 0
			BEGIN
				--discounts
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
					 @intTransferStorageId = @intTransferStorageId
					,@intTransactionDetailId = @intTransactionDetailId
					,@strBatchId = @strBatchId
					,@dblCost = @dblOriginalCost
					,@ysnPost = 1

				UPDATE @GLEntries 
				SET dblDebit		= dblCredit
					,dblDebitUnit	= dblCreditUnit
					,dblCredit		= dblDebit
					,dblCreditUnit  = dblDebitUnit
			END

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
				,@ysnDPtoOS = 1
			--SELECT '@GLForItem',* FROM @GLForItem
			-- SELECT '@GLEntries',* FROM @GLEntries
			-- SELECT 'tblICInventoryTransaction',* FROM tblICInventoryTransaction WHERE strBatchId = @strBatchId
			IF EXISTS(SELECT 1 FROM @GLEntries)
			BEGIN 
				EXEC uspGLBookEntries @GLEntries, 1
			END

			UPDATE @ItemsToPostCopy SET dblQty = dblQty * -1
			EXEC dbo.uspICPostStorage @ItemsToPostCopy,@strBatchId,@intUserId
			
	FETCH NEXT FROM _CURSOR INTO @cursorId, @intTransactionDetailId
	END
	CLOSE _CURSOR;
	DEALLOCATE _CURSOR;
END