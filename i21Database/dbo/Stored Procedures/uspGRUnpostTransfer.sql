﻿CREATE PROCEDURE [dbo].[uspGRUnpostTransfer]
(
	@intTransferStorageId INT,
	@intUserId INT
)
AS
BEGIN

	----- DEBUG POINT -----
	declare @d_a_v int = 0
	----- DEBUG POINT -----
	
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
	DECLARE @intSourceCustomerStorageId INT
	DECLARE @dblOriginalStorageUnits NUMERIC(38,20)
	DECLARE @dblTotalDeductedUnits NUMERIC(38,20)

	SELECT @intDecimalPrecision = intCurrencyDecimal FROM tblSMCompanyPreference

	SELECT @strTransferStorageId = strTransferStorageTicket FROM tblGRTransferStorage WHERE intTransferStorageId = @intTransferStorageId
	select @intSourceCustomerStorageId = intSourceCustomerStorageId from tblGRTransferStorageSourceSplit where intTransferStorageId = @intTransferStorageId
	select @dblOriginalStorageUnits = dblOriginalBalance from tblGRCustomerStorage where intCustomerStorageId = @intSourceCustomerStorageId


	select @dblTotalDeductedUnits  = sum(dblDeductedUnits) from tblGRTransferStorageSourceSplit where intSourceCustomerStorageId  = @intSourceCustomerStorageId

	----- DEBUG POINT -----
	if @d_a_v = 1 and 1 = 0
	begin
		---select 	
		
		select @dblTotalDeductedUnits as [total deducted units], @intSourceCustomerStorageId as [source customer storage], @dblOriginalStorageUnits as [original storage units ]


	end
	----- DEBUG POINT -----

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


	----- DEBUG POINT -----
	IF @d_a_v = 1 and 1 = 0
	begin

		SELECT 
		 TSR.intSourceCustomerStorageId		 
		 ,ISNULL(intToCustomerStorageId,intTransferToCustomerStorageId)
		,ISNULL(TSR.dblUnitQty,TSS.dblUnits)
	FROM tblGRTransferStorageSplit TSS
	LEFT JOIN tblGRTransferStorageReference TSR
	ON TSR.intTransferStorageSplitId = TSS.intTransferStorageSplitId
	WHERE TSS.intTransferStorageId = @intTransferStorageId   AND (CASE WHEN (TSR.intTransferStorageId IS NULL) THEN 1 ELSE CASE WHEN TSR.intTransferStorageId = @intTransferStorageId THEN 1 ELSE 0 END END) = 1




		SELECT  B.dblUnits, A.dblOriginalBalance, *
			FROM tblGRCustomerStorage A 
			INNER JOIN #tmpTransferCustomerStorage B 
				ON B.intCustomerStorageId = A.intCustomerStorageId 
			--WHERE B.dblUnits <> A.dblOriginalBalance


		select 'reference 1'
		SELECT A.dblOriginalBalance, dblUnits
			FROM tblGRCustomerStorage A 
			INNER JOIN #tmpTransferCustomerStorage B 
			ON B.intCustomerStorageId = A.intCustomerStorageId

		select 'reference 2'
		SELECT  sum(B.dblUnits)
			FROM tblGRCustomerStorage A 
			INNER JOIN #tmpTransferCustomerStorage B 
				ON B.intCustomerStorageId = A.intCustomerStorageId

		select 'temp table reference'
		select * from #tmpTransferCustomerStorage

	end
	----- DEBUG POINT -----



	--IF (SELECT TOP 1 A.dblOriginalBalance
	--		FROM tblGRCustomerStorage A 
	--		INNER JOIN #tmpTransferCustomerStorage B 
	--		ON B.intCustomerStorageId = A.intCustomerStorageId) <>	
	--	(SELECT  sum(B.dblUnits)
	--		FROM tblGRCustomerStorage A 
	--		INNER JOIN #tmpTransferCustomerStorage B 
	--			ON B.intCustomerStorageId = A.intCustomerStorageId)
	if @dblOriginalStorageUnits < @dblTotalDeductedUnits
	BEGIN
		SET @ErrMsg = 'Unable to reverse this transaction. The open balance of one or more customer storage/s no longer match its original balance.'
		
		RAISERROR(@ErrMsg,16,1)
		RETURN;
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
		if @d_a_v = 1 and 1 = 0
		begin
		
			select 'check contract details transfercontractdetail,transferunits,customerstorageid,sourceitemuom', @intTransferContractDetailId,@dblTransferUnits,@intCustomerStorageId,@intSourceItemUOMId
		end

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

		--GRN-2138 - COST ADJUSTMENT LOGIC FOR DELIVERY SHEETS
		BEGIN			
			UPDATE SIR SET ysnUnposted = 1
			FROM tblGRStorageInventoryReceipt SIR 
			INNER JOIN tblGRTransferStorageReference SR ON SR.intTransferStorageReferenceId = SIR.intTransferStorageReferenceId
			WHERE SR.intTransferStorageId = @intTransferStorageId
		END
		
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

		UPDATE CS
		SET dblOpenBalance = CS.dblOpenBalance + TS.dblDeductedUnits
		FROM tblGRCustomerStorage CS
		INNER JOIN  (
			SELECT intSourceCustomerStorageId
				,dblDeductedUnits 
			FROM tblGRTransferStorageSourceSplit 
			WHERE intTransferStorageId = @intTransferStorageId
		) TS
			ON TS.intSourceCustomerStorageId = CS.intCustomerStorageId

		/* REVERSE TRANSACTION POSTED TO Inventory */
				DECLARE @GLEntries AS RecapTableType;
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

				DECLARE @cursorId INT
				DECLARE @intTransactionDetailId INT

				
				DECLARE @strBatchId AS NVARCHAR(40);
				EXEC uspSMGetStartingNumber 3, @strBatchId OUT

				DECLARE _CURSOR CURSOR
				FOR
				SELECT intId, intTransactionDetailId FROM @ItemsToPost
	
				OPEN _CURSOR
				FETCH NEXT FROM _CURSOR INTO @cursorId, @intTransactionDetailId
				WHILE @@FETCH_STATUS = 0
				BEGIN		
						
						DECLARE @Entry as ItemCostingTableType;
						DECLARE @dblCost AS DECIMAL(24,10);

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
						

						DECLARE @intItemId INT
							,@intLocationId INT
							,@intSubLocationId INT
							,@intStorageLocationId INT
							,@dtmDate DATETIME
							,@intOwnerShipId INT				   
							,@dblBasisCost DECIMAL(18,6)
							,@dblSettlementPrice DECIMAL(18,6)
							,@strRKError VARCHAR(MAX)

						SELECT @intItemId = ITP.intItemId,@intLocationId = IL.intLocationId,@intSubLocationId = ITP.intSubLocationId, @intStorageLocationId = ITP.intStorageLocationId, @dtmDate = ITP.dtmDate, @intOwnerShipId = CASE WHEN ITP.ysnIsStorage = 1 THEN 2 ELSE 1 END
							
						FROM @ItemsToPost ITP
						INNER JOIN tblICItem I
							ON ITP.intItemId = I.intItemId
						INNER JOIN tblICCommodity ICC
							ON ICC.intCommodityId = I.intCommodityId
						INNER JOIN tblICItemLocation IL
							ON IL.intItemLocationId = ITP.intItemLocationId
						WHERE intId = @cursorId					
						
						DELETE FROM @Entry
						--DELETE FROM @GLEntries
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
						SELECT intItemId,intItemLocationId,intItemUOMId,dtmDate,dblQty,dblUOMQty,0,dblSalesPrice,intCurrencyId,dblExchangeRate,intTransactionId,intTransactionDetailId,strTransactionId,intTransactionTypeId,intLotId,intSubLocationId,intStorageLocationId,ysnIsStorage,intStorageScheduleTypeId 
						FROM @ItemsToPost WHERE intId = @cursorId

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
							EXEC [dbo].[uspGRCreateGLEntriesForTransferStorage] @intTransferStorageId,@strBatchId,0,1,@intEntityId,@intTransferStorageReferenceId = @intTransactionDetailId

							
							--IF(select dblQty from @Entry) < 0
							--BEGIN
							--	UPDATE @GLEntries 
							--	SET dblDebit		= dblCredit
							--		,dblDebitUnit	= dblCreditUnit
							--		,dblCredit		= dblDebit
							--			,dblCreditUnit  = dblDebitUnit
							--END
							----debug point
							--select * from @Entry
							----debug point
							
							
							/*UNPOST STORAGE*/

						
			
				FETCH NEXT FROM _CURSOR INTO @cursorId, @intTransactionDetailId
				END
				CLOSE _CURSOR;
				DEALLOCATE _CURSOR;

		/* END REVERSAL */

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
		EXEC dbo.uspICUnpostCosting @intTransferStorageId,@strTransferStorageId,@strBatchId,@intUserId,0	
							 							
		EXEC dbo.uspICUnpostStorage @intTransferStorageId,@strTransferStorageId,@strBatchId,@intUserId,0
		--DEBUG POINT
		SELECT * FROM @GLEntries
		--DEBUG POINT
		IF EXISTS (SELECT TOP 1 1 FROM @GLEntries)
		BEGIN 
				EXEC dbo.uspGLBookEntries @GLEntries, 1 
		END

							






		DELETE FROM tblGRTransferStorage WHERE intTransferStorageId = @intTransferStorageId
		DELETE FROM tblGRCustomerStorage WHERE intCustomerStorageId IN (SELECT [intToCustomerStorage] FROM #tmpTransferCustomerStorage)
		DELETE FROM tblGRTransferStorageReference WHERE intToCustomerStorageId IN (SELECT [intToCustomerStorage] FROM #tmpTransferCustomerStorage)

		DONE:
		IF @transCount = 0 COMMIT TRANSACTION
	
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