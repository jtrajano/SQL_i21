CREATE PROCEDURE [dbo].[uspGRUnpostTransfer]
(
	@intTransferStorageId INT,
	@intUserId INT,
	@dtmTransferStorageDate DATETIME = NULL
)
AS
BEGIN
	SET QUOTED_IDENTIFIER OFF
	SET ANSI_NULLS ON
	SET NOCOUNT ON
	SET XACT_ABORT ON
	SET ANSI_WARNINGS OFF	

	DECLARE @ErrMsg AS NVARCHAR(MAX)
	DECLARE @intTransferContractDetailId INT
	DECLARE @dblTransferUnits NUMERIC(18,6)
	DECLARE @intSourceItemUOMId INT
	DECLARE @intCustomerStorageId INT
	DECLARE @intDecimalPrecision INT	
	DECLARE @strTransferStorageId VARCHAR(MAX)	
	DECLARE @intEntityId INT
	DECLARE @_intStorageHistoryId INT
	DECLARE @ysnFromDS BIT
	DECLARE @GLForItem AS GLForItem
	DECLARE @ysnIsStorage BIT

	SELECT @intDecimalPrecision = intCurrencyDecimal FROM tblSMCompanyPreference
	
	SELECT @strTransferStorageId = strTransferStorageTicket FROM tblGRTransferStorage WHERE intTransferStorageId = @intTransferStorageId

	IF OBJECT_ID (N'tempdb.dbo.#tmpTransferCustomerStorage') IS NOT NULL
		DROP TABLE #tmpTransferCustomerStorage
	CREATE TABLE #tmpTransferCustomerStorage (
		[intCustomerStorageId] INT,
		[intToCustomerStorage] INT,
		[dblUnits] DECIMAL(18,6))
	INSERT INTO #tmpTransferCustomerStorage
	SELECT 
		 TSR.intSourceCustomerStorageId		 
		 ,ISNULL(intToCustomerStorageId,intTransferToCustomerStorageId)
		,ISNULL(TSR.dblUnitQty,TSS.dblUnits)
	FROM tblGRTransferStorageSplit TSS
	LEFT JOIN tblGRTransferStorageReference TSR
	ON TSR.intTransferStorageSplitId = TSS.intTransferStorageSplitId
	WHERE TSS.intTransferStorageId = @intTransferStorageId   AND (CASE WHEN (TSR.intTransferStorageId IS NULL) THEN 1 ELSE CASE WHEN TSR.intTransferStorageId = @intTransferStorageId THEN 1 ELSE 0 END END) = 1

	BEGIN
		DECLARE @TicketNo VARCHAR(50)

		SELECT @TicketNo = STUFF((
			SELECT ',' + strStorageTicketNumber
			FROM tblGRCustomerStorage A 
			INNER JOIN tblGRTransferStorageReference F
				ON F.intToCustomerStorageId = A.intCustomerStorageId
			WHERE A.dblOriginalBalance <> A.dblOpenBalance
				AND F.intTransferStorageId = @intTransferStorageId
			FOR XML PATH('')
		),1,1,'')
		
		IF @TicketNo IS NOT NULL
		BEGIN
			SET @ErrMsg = 'The Open balance of ticket ' + @TicketNo + ' has been modified by another user. Reversal of transfer cannot proceed.'
		
			RAISERROR(@ErrMsg,16,1)
			RETURN;
		END
	END

	IF EXISTS(SELECT TOP 1 1 
			FROM tblGRStorageHistory A 
			INNER JOIN #tmpTransferCustomerStorage B 
				ON B.intCustomerStorageId = A.intCustomerStorageId 
			WHERE A.intInvoiceId IS NOT NULL
	)
	BEGIN
		SET @ErrMsg = 'Unable to reverse this transaction. The storage/discount/fees due of one or more customer storage has been invoiced.'
		
		RAISERROR(@ErrMsg,16,1)
		RETURN;
	END

	BEGIN TRY
	BEGIN
		DECLARE @transCount INT = @@TRANCOUNT;
		IF @transCount = 0 BEGIN TRANSACTION

		--integration to IC
		DECLARE @cnt INT = 0

		SET @cnt = (SELECT COUNT(*) FROM tblGRTransferStorageSplit WHERE intTransferStorageId = @intTransferStorageId AND intContractDetailId IS NOT NULL)

		DECLARE c CURSOR LOCAL STATIC READ_ONLY FORWARD_ONLY
		FOR
		WITH transferStorageDetails (
			intTransferContractDetailId 
			,dblTransferUnits			
			,intSourceItemUOMId			
			,intCustomerStorageId
		) AS (
			SELECT 
				intTransferContractDetailId		= TSplit.intContractDetailId,
				dblTransferUnits				= -(TSplit.dblUnits),
				intSourceItemUOMId				= TransferStorage.intItemUOMId,
				intCustomerStorageId			= TSplit.intTransferToCustomerStorageId
			FROM tblGRTransferStorageSplit TSplit
			INNER JOIN tblGRTransferStorage TransferStorage
				ON TransferStorage.intTransferStorageId = TSplit.intTransferStorageId
			WHERE TSplit.intTransferStorageId = @intTransferStorageId
				AND TSplit.intContractDetailId IS NOT NULL
		)
		SELECT
			intTransferContractDetailId 
			,dblTransferUnits			
			,intSourceItemUOMId			
			,intCustomerStorageId
		FROM ( SELECT * FROM transferStorageDetails ) icParams
		
		OPEN c;

		FETCH c INTO @intTransferContractDetailId, @dblTransferUnits, @intSourceItemUOMId, @intCustomerStorageId
	--END
	--CLOSE c; DEALLOCATE c;

	--GRN-2138 - COST ADJUSTMENT LOGIC FOR DELIVERY SHEETS
	BEGIN			
		UPDATE SIR SET ysnUnposted = 1
		FROM tblGRStorageInventoryReceipt SIR 
		INNER JOIN tblGRTransferStorageReference SR ON SR.intTransferStorageReferenceId = SIR.intTransferStorageReferenceId
		WHERE SR.intTransferStorageId = @intTransferStorageId
	END

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

		-- Reverse original	risk summary logs
		DECLARE @StorageHistoryIds AS Id
		DELETE FROM @StorageHistoryIds
		INSERT INTO @StorageHistoryIds
		SELECT intStorageHistoryId FROM tblGRStorageHistory WHERE intTransferStorageId = @intTransferStorageId

		EXEC [dbo].[uspGRRiskSummaryLog2]
			@StorageHistoryIds = @StorageHistoryIds
			,@strAction = 'UNPOST'

		--DELETE HISTORY
		DELETE FROM tblGRStorageHistory WHERE intTransferStorageId = @intTransferStorageId
		DELETE FROM tblGRStorageHistory WHERE intCustomerStorageId IN (SELECT [intToCustomerStorage] FROM #tmpTransferCustomerStorage)
		--DELETE DISCOUNTS
		DELETE FROM tblQMTicketDiscount WHERE intTicketFileId IN (SELECT [intToCustomerStorage] FROM #tmpTransferCustomerStorage) AND strSourceType = 'Storage'

		--integration to IC
		SET @cnt = 0

		SET @cnt = (SELECT COUNT(*) FROM tblGRTransferStorageSourceSplit WHERE intTransferStorageId = @intTransferStorageId AND intContractDetailId IS NOT NULL)

		DECLARE c CURSOR LOCAL STATIC READ_ONLY FORWARD_ONLY
		FOR
		WITH storageDetails (
			intTransferContractDetailId 
			,dblTransferUnits			
			,intSourceItemUOMId			
			,intCustomerStorageId
		) AS (
			SELECT intTransferContractDetailId	= SSplit.intContractDetailId,
				dblTransferUnits				= SSplit.dblDeductedUnits,
				intSourceItemUOMId				= TransferStorage.intItemUOMId,
				intCustomerStorageId			= SSplit.intSourceCustomerStorageId
			FROM tblGRTransferStorageSourceSplit SSplit
			INNER JOIN tblGRTransferStorage TransferStorage
				ON TransferStorage.intTransferStorageId = SSplit.intTransferStorageId
			WHERE SSplit.intTransferStorageId = @intTransferStorageId
				AND SSplit.intContractDetailId IS NOT NULL
		)
		SELECT
			intTransferContractDetailId 
			,dblTransferUnits			
			,intSourceItemUOMId			
			,intCustomerStorageId
		FROM ( SELECT * FROM storageDetails ) icParams
		
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
		--UPDATE X
		--SET X.dblOpenBalance = Y.dblQty
		--FROM
		--tblGRCustomerStorage X
		--INNER JOIN  (SELECT A.intCustomerStorageId,B.intSourceCustomerStorageId,TSS.intTransferStorageId,  ROUND(A.dblOpenBalance + SUM(ISNULL(TSR.dblUnitQty,B.dblDeductedUnits)),6) dblQty
		--FROM tblGRCustomerStorage A 
		--INNER JOIN tblGRTransferStorageSourceSplit B 
		--	ON B.intSourceCustomerStorageId = A.intCustomerStorageId
		--LEFT JOIN tblGRTransferStorageReference TSR
		--	ON TSR.intSourceCustomerStorageId = B.intSourceCustomerStorageId
		--LEFT JOIN tblGRTransferStorageSplit TSS
		--	ON TSS.intTransferStorageSplitId = TSR.intTransferStorageSplitId
		--WHERE B.intTransferStorageId = @intTransferStorageId AND (CASE WHEN (TSR.intTransferStorageId IS NULL) THEN 1 ELSE CASE WHEN TSR.intTransferStorageId = @intTransferStorageId THEN 1 ELSE 0 END END) = 1
		--GROUP BY  A.intCustomerStorageId,B.intSourceCustomerStorageId, TSS.intTransferStorageId,A.dblOpenBalance) Y
		--	ON Y.intCustomerStorageId = X.intCustomerStorageId

		/* REVERSE TRANSACTION POSTED TO Inventory */
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
			,dbo.fnCTConvertQuantityToTargetItemUOM(ToStorage.intItemId, IU.intUnitMeasureId, ToStorage.intUnitMeasureId, SR.dblUnitQty) * CASE WHEN (FromType.ysnDPOwnedType = 0 AND ToType.ysnDPOwnedType = 1) THEN -1 ELSE 1 END
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

					
		DECLARE @strBatchId AS NVARCHAR(40);
		DECLARE @GLEntries AS RecapTableType;
		DECLARE @GLEntriesCharges AS RecapTableType;
		DECLARE @cursorId INT					
		DECLARE @intTransactionDetailId INT

		IF EXISTS(SELECT 1 FROM @ItemsToPost)
		BEGIN
			EXEC uspSMGetStartingNumber 3, @strBatchId OUT
		END

		DECLARE _CURSOR CURSOR
		FOR
		SELECT intId, intTransactionDetailId,ysnIsStorage FROM @ItemsToPost

		OPEN _CURSOR
		FETCH NEXT FROM _CURSOR INTO @cursorId, @intTransactionDetailId, @ysnIsStorage
		WHILE @@FETCH_STATUS = 0
		BEGIN
			--Check if Transfer is DP To Other Storage (Disregard Risk Error)
			SELECT @ysnFromDS = CASE WHEN FromStorage.intDeliverySheetId IS NOT NULL THEN 1 ELSE 0 END
			FROM tblGRTransferStorageReference SR
			INNER JOIN tblGRCustomerStorage FromStorage
				ON FromStorage.intCustomerStorageId = SR.intSourceCustomerStorageId
			WHERE SR.intTransferStorageReferenceId = @intTransactionDetailId	

			DELETE FROM @GLEntriesCharges

			IF @ysnFromDS = 0						
			BEGIN
				INSERT INTO @GLEntriesCharges 
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
					,@dblCost = 0
					,@ysnPost = 0

				IF @ysnIsStorage = 1
				BEGIN
					UPDATE @GLEntriesCharges
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
				)
				SELECT [dtmDate], [strBatchId], [intAccountId], [dblDebit], [dblCredit], [dblDebitUnit], [dblCreditUnit]
					,[strDescription], [strCode], [strReference], [intCurrencyId], [dblExchangeRate], [dtmDateEntered]
					,[dtmTransactionDate], [strJournalLineDescription], [intJournalLineNo], [ysnIsUnposted], [intUserId]
					,[intEntityId], [strTransactionId], [intTransactionId], [strTransactionType], [strTransactionForm]
					,[strModuleName], [intConcurrencyId], [dblDebitForeign], [dblDebitReport], [dblCreditForeign]
					,[dblCreditReport], [dblReportingRate], [dblForeignRate], [strRateType]
				FROM @GLEntriesCharges
			END
			/*UNPOST STORAGE*/						
			
		FETCH NEXT FROM _CURSOR INTO @cursorId, @intTransactionDetailId, @ysnIsStorage
		END
		CLOSE _CURSOR;
		DEALLOCATE _CURSOR;	

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
			,[intCommodityId]
		)
		EXEC dbo.uspICUnpostCosting @intTransferStorageId,@strTransferStorageId,@strBatchId,@intUserId,0	
							 	
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
			@strBatchId = @strBatchId
			,@GLEntries = @GLForItem
			,@AccountCategory_ContraInventory = 'AP Clearing'
			,@intEntityUserSecurityId = @intUserId
			,@ysnUnpostInvAdj = 1
		
		-- SELECT '@GLEntries',* FROM @GLEntries
		-- SELECT * FROM tblICInventoryTransaction WHERE strBatchId = @strBatchId
								
		EXEC dbo.uspICUnpostStorage @intTransferStorageId,@strTransferStorageId,@strBatchId,@intUserId,0

		IF EXISTS (SELECT TOP 1 1 FROM @GLEntries)
		BEGIN 
			EXEC dbo.uspGLBookEntries @GLEntries, 1 
		END

		--unpost all transactions in GL
		UPDATE tblGLDetail SET ysnIsUnposted = 1 WHERE intTransactionId = @intTransferStorageId AND strTransactionId = @strTransferStorageId	
							
		/* END REVERSAL */

		--/*start === FOR DP to DP only*/
		DECLARE @intTransferStorageReferenceId INT
		DECLARE @strBatchId2 AS NVARCHAR(40);

		DELETE FROM @GLEntries

		DECLARE c CURSOR LOCAL STATIC READ_ONLY FORWARD_ONLY
		FOR
		WITH storageTransfers (
			intTranferStorageReferenceId
		) AS (
			SELECT SR.intTransferStorageReferenceId
			FROM tblGRTransferStorageReference SR
			INNER JOIN tblGRCustomerStorage CS_FROM ON CS_FROM.intCustomerStorageId = SR.intSourceCustomerStorageId
			INNER JOIN tblGRStorageType ST_FROM ON ST_FROM.intStorageScheduleTypeId = CS_FROM.intStorageTypeId AND ST_FROM.ysnDPOwnedType = 1
			INNER JOIN tblGRCustomerStorage CS_TO ON CS_TO.intCustomerStorageId = SR.intToCustomerStorageId
			INNER JOIN tblGRStorageType ST_TO ON ST_TO.intStorageScheduleTypeId = CS_TO.intStorageTypeId AND ST_TO.ysnDPOwnedType = 1
			WHERE SR.intTransferStorageId = @intTransferStorageId
		)
		SELECT
			intTranferStorageReferenceId
		FROM ( SELECT * FROM storageTransfers ) params
		OPEN c;

		FETCH c INTO @intTransferStorageReferenceId

		WHILE @@FETCH_STATUS = 0
		BEGIN
			SELECT TOP 1 @strBatchId2 = strBatchId FROM tblGRTransferGLEntriesCTE WHERE intSourceTransactionDetailId = @intTransferStorageReferenceId
			
			UPDATE tblGLDetail SET ysnIsUnposted = 1 WHERE strBatchId = @strBatchId2
			UPDATE tblGRTransferGLEntriesCTE SET ysnIsUnposted = 1 WHERE strBatchId = @strBatchId2

			FETCH c INTO @intTransferStorageReferenceId
		END
		CLOSE c; DEALLOCATE c;
		--/*end === FOR DP to DP only*/

		-- Unpost AP clearing entries from tblAPClearing
		EXEC uspGRUnpostAPClearingTransfer @intTransferStorageId;

		DELETE FROM tblGRTransferStorage WHERE intTransferStorageId = @intTransferStorageId
		DELETE FROM tblGRCustomerStorage WHERE intCustomerStorageId IN (SELECT [intToCustomerStorage] FROM #tmpTransferCustomerStorage)
		--DELETE FROM tblGRTransferStorageReference WHERE intToCustomerStorageId IN (SELECT [intToCustomerStorage] FROM #tmpTransferCustomerStorage)

		UPDATE CS
		SET dblOpenBalance = SH.dblRunningBalance
		FROM tblGRCustomerStorage CS
		INNER JOIN #tmpTransferCustomerStorage TCS
			ON TCS.intCustomerStorageId = CS.intCustomerStorageId
		OUTER APPLY (
			SELECT dblRunningBalance = SUM(CASE 
						WHEN (strType = 'Settlement' OR strType ='Reduced By Inventory Shipment') AND dblUnits > 0 THEN - dblUnits 
						ELSE dblUnits 
					END)
			FROM tblGRStorageHistory
			WHERE intTransactionTypeId NOT IN (2,6)
				AND intCustomerStorageId = CS.intCustomerStorageId
		) SH

		DONE:
		IF @transCount = 0 COMMIT TRANSACTION
	END
	
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
		IF @transCount = 0 AND XACT_STATE() <> 0 ROLLBACK TRANSACTION
		RAISERROR (@ErrorMessage , @ErrorSeverity, @ErrorState, @ErrorNumber)
	END CATCH	
END