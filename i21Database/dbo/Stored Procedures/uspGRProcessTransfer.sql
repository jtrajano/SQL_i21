﻿CREATE PROCEDURE [dbo].[uspGRProcessTransfer]
(
	@intTransferStorageId INT,
	@intUserId INT
)
AS

BEGIN TRY
	
	SET QUOTED_IDENTIFIER OFF
	SET ANSI_NULLS ON
	SET NOCOUNT ON
	SET XACT_ABORT ON
	SET ANSI_WARNINGS OFF


	DECLARE @ErrMsg AS NVARCHAR(MAX)
	DECLARE @StorageHistoryStagingTable AS [StorageHistoryStagingTable]
	DECLARE @newCustomerStorageIds AS TABLE (intToCustomerStorageId INT, intTransferStorageSplitId INT, intSourceCustomerStorageId INT,dblUnitQty NUMERIC(38,20),dblSplitPercent NUMERIC(38,20),dtmProcessDate DATETIME NOT NULL DEFAULT(GETDATE()))
	DECLARE @CustomerStorageStagingTable AS CustomerStorageStagingTable
	DECLARE @CurrentItemOpenBalance DECIMAL(38,20)
	DECLARE @intTransferContractDetailId INT
	DECLARE @dblTransferUnits NUMERIC(18,6)
	DECLARE @intSourceItemUOMId INT
	DECLARE @intCustomerStorageId INT --new customer storage id
	DECLARE @intStorageHistoryId INT = 0
	DECLARE @intDecimalPrecision INT	
	SELECT @intDecimalPrecision = intCurrencyDecimal FROM tblSMCompanyPreference
	DECLARE @intTransferStorageReferenceId INT
	---START---TRANSACTIONS FOR THE SOURCE-----	
	IF EXISTS(SELECT TOP 1 1 
			FROM tblGRCustomerStorage A 
			INNER JOIN tblGRTransferStorageSourceSplit B 
				ON B.intSourceCustomerStorageId = A.intCustomerStorageId 
			WHERE B.intTransferStorageId = @intTransferStorageId AND B.dblOriginalUnits <> A.dblOpenBalance
	)
	BEGIN
		DECLARE @TicketNo VARCHAR(50)

		SELECT @TicketNo = STUFF((
			SELECT ',' + strStorageTicketNumber 
			FROM tblGRCustomerStorage A 
			INNER JOIN tblGRTransferStorageSourceSplit B 
				ON B.intSourceCustomerStorageId = A.intCustomerStorageId 
			WHERE B.intTransferStorageId = @intTransferStorageId AND B.dblOriginalUnits <> A.dblOpenBalance
			FOR XML PATH('')
		),1,1,'')
		
		SET @ErrMsg = 'The Open balance of ticket ' + @TicketNo + ' has been modified by another user.  Transfer process cannot proceed.'
		
		RAISERROR(@ErrMsg,16,1)
		RETURN;
	END
	
	-- BEGIN TRANSACTION	
		--integration to IC
		DECLARE @cnt INT = 0

		SET @cnt = (SELECT COUNT(*) FROM tblGRTransferStorageSourceSplit WHERE intTransferStorageId = @intTransferStorageId AND intContractDetailId IS NOT NULL)

		DECLARE c CURSOR LOCAL STATIC READ_ONLY FORWARD_ONLY
		FOR
		WITH sourceStorageDetails (
			intTransferContractDetailId 
			,dblTransferUnits			
			,intSourceItemUOMId			
			,intCustomerStorageId
		) AS (
			SELECT intTransferContractDetailId	= SourceSplit.intContractDetailId,
				dblTransferUnits				= -(SourceSplit.dblOriginalUnits - SourceSplit.dblDeductedUnits),
				intSourceItemUOMId				= TransferStorage.intItemUOMId,
				intCustomerStorageId			= SourceSplit.intSourceCustomerStorageId
			FROM tblGRTransferStorageSourceSplit SourceSplit
			INNER JOIN tblGRTransferStorage TransferStorage
				ON TransferStorage.intTransferStorageId = SourceSplit.intTransferStorageId
			WHERE SourceSplit.intTransferStorageId = @intTransferStorageId
				AND SourceSplit.intContractDetailId IS NOT NULL
		)
		SELECT
			intTransferContractDetailId 
			,dblTransferUnits			
			,intSourceItemUOMId			
			,intCustomerStorageId
		FROM ( SELECT * FROM sourceStorageDetails ) icParams
		
		OPEN c;

		FETCH c INTO @intTransferContractDetailId, @dblTransferUnits, @intSourceItemUOMId, @intCustomerStorageId

		WHILE @@FETCH_STATUS = 0 AND @cnt > 0
		BEGIN
			EXEC uspCTUpdateSequenceQuantityUsingUOM 
				@intContractDetailId	= @intTransferContractDetailId
				,@dblQuantityToUpdate	= @dblTransferUnits
				,@intUserId				= @intUserId
				,@intExternalId			= @intCustomerStorageId
				,@strScreenName			= 'Transfer Storage'
				,@intSourceItemUOMId	= @intSourceItemUOMId

			FETCH c INTO @intTransferContractDetailId, @dblTransferUnits, @intSourceItemUOMId, @intCustomerStorageId
		END
		CLOSE c; DEALLOCATE c;

		--update the source's customer storage open balance
		UPDATE A
		SET A.dblOpenBalance 	= ROUND(B.dblOriginalUnits - B.dblDeductedUnits,@intDecimalPrecision)
		FROM tblGRCustomerStorage A 
		INNER JOIN tblGRTransferStorageSourceSplit B 
			ON B.intSourceCustomerStorageId = A.intCustomerStorageId
		WHERE B.intTransferStorageId = @intTransferStorageId
		
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
		)
		SELECT
			[intCustomerStorageId]	= SourceSplit.intSourceCustomerStorageId
			,[intTransferStorageId]	= SourceSplit.intTransferStorageId
			,[intContractHeaderId]	= CD.intContractHeaderId
			,[dblUnits]				= -(SourceSplit.dblOriginalUnits * (TransferStorageSplit.dblSplitPercent / 100))
			,[dtmHistoryDate]		= GETDATE()
			,[intUserId]			= @intUserId
			,[ysnPost]				= 1
			,[intTransactionTypeId]	= 3
			,[strPaidDescription]	= 'Generated from Transfer Storage'
			,[strType]				= 'Transfer'
		FROM tblGRTransferStorageSourceSplit SourceSplit
		LEFT JOIN tblCTContractDetail CD
			ON CD.intContractDetailId = SourceSplit.intContractDetailId
		INNER JOIN tblGRTransferStorage TS
			ON TS.intTransferStorageId = SourceSplit.intTransferStorageId
		INNER JOIN tblGRTransferStorageSplit TransferStorageSplit
			ON TransferStorageSplit.intTransferStorageId = SourceSplit.intTransferStorageId	
		WHERE SourceSplit.intTransferStorageId = @intTransferStorageId	

		EXEC uspGRInsertStorageHistoryRecord @StorageHistoryStagingTable, @intStorageHistoryId		
		----END----TRANSACTIONS FOR THE SOURCE---------

		----START--TRANSACTIONS FOR THE NEW CUSTOMER STORAGE-------
		DELETE FROM @StorageHistoryStagingTable
		INSERT INTO @CustomerStorageStagingTable
		(
			[intEntityId]				
			,[intCommodityId]			
			,[intStorageScheduleId]		
			,[intStorageTypeId]			
			,[intCompanyLocationId]		
			,[intDiscountScheduleId]	
			,[dblTotalPriceShrink]		
			,[dblTotalWeightShrink]		
			,[dblQuantity]				
			,[dtmDeliveryDate]			
			,[dtmZeroBalanceDate]		
			,[strDPARecieptNumber]		
			,[dtmLastStorageAccrueDate]	
			,[dblStorageDue]			
			,[dblStoragePaid]			
			,[dblInsuranceRate]			
			,[strOriginState]			
			,[strInsuranceState]		
			,[dblFeesDue]				
			,[dblFeesPaid]				
			,[dblFreightDueRate]		
			,[ysnPrinted]				
			,[dblCurrencyRate]			
			,[strDiscountComment]		
			,[dblDiscountsDue]			
			,[dblDiscountsPaid]			
			,[strCustomerReference]		
			,[intCurrencyId]			
			,[strTransactionNumber]		
			,[intItemId]				
			,[intItemUOMId]
			,[intTransferStorageSplitId]
			,[intUnitMeasureId]
			,[intCompanyLocationSubLocationId]
			,[intStorageLocationId]
			,[intTicketId]
			,[intDeliverySheetId]
			,[ysnTransferStorage]
			,[dblGrossQuantity]
			,[intSourceCustomerStorageId]
			,[dblUnitQty]
			,[dblSplitPercent]
		)	
		SELECT 
			[intEntityId]						= TransferStorageSplit.intEntityId
			,[intCommodityId]					= CS.intCommodityId
			,[intStorageScheduleId]				= TransferStorageSplit.intStorageScheduleId
			,[intStorageTypeId]					= TransferStorageSplit.intStorageTypeId
			,[intCompanyLocationId]				= TransferStorageSplit.intCompanyLocationId
			,[intDiscountScheduleId]			= CS.intDiscountScheduleId
			,[dblTotalPriceShrink]				= CS.dblTotalPriceShrink		
			,[dblTotalWeightShrink]				= CS.dblTotalWeightShrink		
			,[dblQuantity]						= SourceStorage.dblOriginalUnits * (TransferStorageSplit.dblSplitPercent / 100)
			,[dtmDeliveryDate]					= CS.dtmDeliveryDate
			,[dtmZeroBalanceDate]				= CS.dtmZeroBalanceDate			
			,[strDPARecieptNumber]				= CS.strDPARecieptNumber		
			,[dtmLastStorageAccrueDate]			= CS.dtmLastStorageAccrueDate	
			,[dblStorageDue]					= CS.dblStorageDue				--storage charge will have its own computation
			,[dblStoragePaid]					= 0
			,[dblInsuranceRate]					= 0
			,[strOriginState]					= CS.strOriginState
			,[strInsuranceState]				= CS.strInsuranceState
			,[dblFeesDue]						= CS.dblFeesDue					
			,[dblFeesPaid]						= CS.dblFeesPaid				
			,[dblFreightDueRate]				= CS.dblFreightDueRate			
			,[ysnPrinted]						= CS.ysnPrinted					
			,[dblCurrencyRate]					= CS.dblCurrencyRate
			,[strDiscountComment]				= CS.strDiscountComment			
			,[dblDiscountsDue]					= CS.dblDiscountsDue			
			,[dblDiscountsPaid]					= CS.dblDiscountsPaid			
			,[strCustomerReference]				= CS.strCustomerReference		
			,[intCurrencyId]					= CS.intCurrencyId
			,[strTransactionNumber]				= CS.strStorageTicketNumber--TS.strTransferStorageTicket
			,[intItemId]						= CS.intItemId
			,[intItemUOMId]						= CS.intItemUOMId
			,[intTransferStorageSplitId]		= TransferStorageSplit.intTransferStorageSplitId
			,[intUnitMeasureId]					= (SELECT intUnitMeasureId FROM tblICItemUOM WHERE intItemUOMId = CS.intItemUOMId)
			,[intCompanyLocationSubLocationId]	= CASE WHEN CS.intCompanyLocationId = TransferStorageSplit.intCompanyLocationId THEN CS.intCompanyLocationSubLocationId ELSE NULL END
			,[intStorageLocationId]				= CASE WHEN CS.intCompanyLocationId = TransferStorageSplit.intCompanyLocationId THEN CS.intStorageLocationId ELSE NULL END
			,[intTicketId]						= CS.intTicketId
			,[intDeliverySheetId]				= CS.intDeliverySheetId
			,[ysnTransferStorage]				= 1
			,[dblGrossQuantity]					= ROUND(((SourceStorage.dblOriginalUnits * (TransferStorageSplit.dblSplitPercent / 100)) / CS.dblOriginalBalance) * CS.dblGrossQuantity,@intDecimalPrecision)
			,[intSourceCustomerStorageId]		= CS.intCustomerStorageId
			,[dblUnitQty]						= SourceStorage.dblOriginalUnits * (TransferStorageSplit.dblSplitPercent / 100)
			,[intSplitPercent]					= TransferStorageSplit.dblSplitPercent
		FROM tblGRCustomerStorage CS
		INNER JOIN tblGRTransferStorageSourceSplit SourceStorage
			ON SourceStorage.intSourceCustomerStorageId = CS.intCustomerStorageId
		INNER JOIN tblGRTransferStorage TS
			ON TS.intTransferStorageId = SourceStorage.intTransferStorageId
		INNER JOIN tblGRTransferStorageSplit TransferStorageSplit
			ON TransferStorageSplit.intTransferStorageId = SourceStorage.intTransferStorageId		
		WHERE SourceStorage.intTransferStorageId = @intTransferStorageId

		--SELECT * FROM @CustomerStorageStagingTable

		MERGE INTO tblGRCustomerStorage AS destination
		USING
		(
			SELECT * FROM @CustomerStorageStagingTable
		) AS SourceData
		ON (1=0)
		WHEN NOT MATCHED THEN
		INSERT
		(
			[intConcurrencyId]
			,[intEntityId]
			,[intCommodityId]
			,[intStorageScheduleId]
			,[intStorageTypeId]
			,[intCompanyLocationId]
			,[intDiscountScheduleId]
			,[dblTotalPriceShrink]
			,[dblTotalWeightShrink]
			,[dblOriginalBalance]
			,[dblOpenBalance]
			,[dtmDeliveryDate]
			,[dtmZeroBalanceDate]
			,[strDPARecieptNumber]
			,[dtmLastStorageAccrueDate]					
			,[dblStorageDue]
			,[dblStoragePaid]
			,[dblInsuranceRate]
			,[strOriginState]
			,[strInsuranceState]
			,[dblFeesDue]
			,[dblFeesPaid]
			,[dblFreightDueRate]
			,[ysnPrinted]
			,[dblCurrencyRate]
			,[strDiscountComment]
			,[dblDiscountsDue]
			,[dblDiscountsPaid]
			,[strCustomerReference]
			,[intCurrencyId]
			,[strStorageTicketNumber]
			,[intItemId]
			,[intItemUOMId]
			,[intUnitMeasureId]
			,[intCompanyLocationSubLocationId]
			,[intStorageLocationId]
			,[intTicketId]
			,[intDeliverySheetId]
			,[ysnTransferStorage]
			,[dblGrossQuantity]
		)
		VALUES
		(
			1
			,[intEntityId]				
			,[intCommodityId]			
			,[intStorageScheduleId]		
			,[intStorageTypeId]			
			,[intCompanyLocationId]		
			,[intDiscountScheduleId]	
			,[dblTotalPriceShrink]		
			,[dblTotalWeightShrink]		
			,[dblQuantity]				
			,[dblQuantity]
			,[dtmDeliveryDate]			
			,[dtmZeroBalanceDate]		
			,[strDPARecieptNumber]		
			,[dtmLastStorageAccrueDate]	
			,[dblStorageDue]			
			,[dblStoragePaid]			
			,[dblInsuranceRate]			
			,[strOriginState]			
			,[strInsuranceState]		
			,[dblFeesDue]				
			,[dblFeesPaid]				
			,[dblFreightDueRate]		
			,[ysnPrinted]				
			,[dblCurrencyRate]			
			,[strDiscountComment]		
			,[dblDiscountsDue]			
			,[dblDiscountsPaid]			
			,[strCustomerReference]		
			,[intCurrencyId]			
			,[strTransactionNumber]		
			,[intItemId]				
			,[intItemUOMId]		
			,[intUnitMeasureId]
			,[intCompanyLocationSubLocationId]
			,[intStorageLocationId]
			,[intTicketId]
			,[intDeliverySheetId]
			,[ysnTransferStorage]
			,[dblGrossQuantity]
		)
		OUTPUT
			inserted.intCustomerStorageId,
			SourceData.intTransferStorageSplitId,
			SourceData.[intSourceCustomerStorageId],
			SourceData.dblUnitQty,
			SourceData.dblSplitPercent,
			GETDATE()
			--SourceData.
		INTO @newCustomerStorageIds;

		INSERT INTO tblGRTransferStorageReference
		SELECT intSourceCustomerStorageId,intToCustomerStorageId,intTransferStorageSplitId,@intTransferStorageId,dblUnitQty,dblSplitPercent,dtmProcessDate FROM @newCustomerStorageIds
		SET @intTransferStorageReferenceId = @@ROWCOUNT

		--
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
					,dbo.fnCTConvertQuantityToTargetItemUOM(ToStorage.intItemId, IU.intUnitMeasureId, ToStorage.intUnitMeasureId, SR.dblUnitQty) * CASE WHEN (FromType.strStorageTypeDescription = 'OPEN STORAGE' AND ToType.strStorageTypeDescription = 'DELAYED PRICING') THEN -1 ELSE 1 END
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
					,ysnIsStorage = CASE WHEN (FromType.strStorageTypeDescription = 'OPEN STORAGE' AND ToType.strStorageTypeDescription = 'DELAYED PRICING') THEN 1 ELSE 0 END
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
				WHERE  ((FromType.strStorageTypeDescription = 'OPEN STORAGE' AND ToType.strStorageTypeDescription = 'DELAYED PRICING') OR (FromType.strStorageTypeDescription = 'DELAYED PRICING' AND ToType.strStorageTypeDescription = 'OPEN STORAGE')) AND SR.intTransferStorageId = @intTransferStorageId
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
						DECLARE @Entry as ItemCostingTableType;
						DECLARE @dblCost AS DECIMAL(24,10);
						DECLARE @strBatchId AS NVARCHAR(40);
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
						
						EXEC uspSMGetStartingNumber 3, @strBatchId OUT

						DECLARE @intItemId INT
							,@intLocationId INT
							,@intSubLocationId INT
							,@intStorageLocationId INT
							,@dtmDate DATETIME
							,@intOwnerShipId INT				   
							,@dblBasisCost DECIMAL(18,6);


						SELECT @intItemId = ITP.intItemId,@intLocationId = IL.intLocationId,@intSubLocationId = ITP.intSubLocationId, @intStorageLocationId = ITP.intStorageLocationId, @dtmDate = ITP.dtmDate, @intOwnerShipId = CASE WHEN ITP.ysnIsStorage = 1 THEN 2 ELSE 1 END
							,@dblBasisCost = (SELECT dblBasis FROM dbo.fnRKGetFutureAndBasisPrice (1,I.intCommodityId,right(convert(varchar, dtmDate, 106),8),1,NULL,NULL,@intLocationId,NULL,0,I.intItemId,intCurrencyId))
						FROM @ItemsToPost ITP
						INNER JOIN tblICItem I
							ON ITP.intItemId = I.intItemId
						INNER JOIN tblICCommodity ICC
							ON ICC.intCommodityId = I.intCommodityId
						INNER JOIN tblICItemLocation IL
							ON IL.intItemLocationId = ITP.intItemLocationId
						WHERE intId = @cursorId
						
						INSERT INTO #tblICItemRunningStock
						EXEC [dbo].[uspICGetItemRunningStock] @intItemId = @intItemId, @intLocationId = @intLocationId, @intSubLocationId = @intSubLocationId, @intStorageLocationId = @intStorageLocationId, @dtmDate = @dtmDate, @intOwnershipType = @intOwnerShipId

						
						SELECT @dblCost = dblCost + (ISNULL(@dblBasisCost,0)) FROM #tblICItemRunningStock
						DELETE FROM @Entry
						DELETE FROM @GLEntries
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
						SELECT intItemId,intItemLocationId,intItemUOMId,dtmDate,dblQty,dblUOMQty,@dblCost,dblSalesPrice,intCurrencyId,dblExchangeRate,intTransactionId,intTransactionDetailId,strTransactionId,intTransactionTypeId,intLotId,intSubLocationId,intStorageLocationId,ysnIsStorage,intStorageScheduleTypeId 
						FROM @ItemsToPost WHERE intId = @cursorId

						IF(SELECT dblQty FROM @Entry) > 0
						BEGIN
							UPDATE @Entry
							SET dblQty = dblQty*-1

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
							EXEC	dbo.uspICPostCosting @Entry,@strBatchId,'AP Clearing',1

							IF EXISTS (SELECT TOP 1 1 FROM @GLEntries)
							BEGIN 
									EXEC dbo.uspGLBookEntries @GLEntries, 1 
							END
							
							UPDATE @Entry
							SET dblQty = dblQty*-1

							EXEC	dbo.uspICPostStorage @Entry,@strBatchId,1

						END
						ELSE
						BEGIN
							EXEC	dbo.uspICPostStorage @Entry,@strBatchId,1

							UPDATE @Entry
							SET dblQty = dblQty*-1

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
							EXEC	dbo.uspICPostCosting @Entry,@strBatchId,'AP Clearing',1

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

		--(intToCustomerStorageId INT, intTransferStorageSplitId INT, intSourceCustomerStorageId INT,dblUnitQty NUMERIC(38,20),dblSplitPercent NUMERIC(38,20),dtmProcessDate DATETIME NOT NULL DEFAULT(GETDATE()))

		--update tblGRTransferStorageSplit's intCustomerStorageId
		UPDATE A
		SET A.intTransferToCustomerStorageId = B.intToCustomerStorageId
		FROM tblGRTransferStorageSplit A
		INNER JOIN @newCustomerStorageIds B
			ON B.intTransferStorageSplitId = A.intTransferStorageSplitId

		DELETE FROM @StorageHistoryStagingTable
		--for new customer storage
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
		SELECT
			[intCustomerStorageId]	= A.intToCustomerStorageId
			,[intTransferStorageId]	= TransferStorageSplit.intTransferStorageId
			,[intContractHeaderId]	= CD.intContractHeaderId
			,[dblUnits]				= A.dblUnitQty
			,[dtmHistoryDate]		= GETDATE()
			,[intUserId]			= @intUserId
			,[ysnPost]				= 1
			,[intTransactionTypeId]	= 3
			,[strPaidDescription]	= 'Generated from Transfer Storage'
			,[strType]				= 'From Transfer'
		FROM tblGRTransferStorageSplit TransferStorageSplit
		INNER JOIN @newCustomerStorageIds A
			ON A.intTransferStorageSplitId = TransferStorageSplit.intTransferStorageSplitId
		LEFT JOIN tblCTContractDetail CD
			ON CD.intContractDetailId = TransferStorageSplit.intContractDetailId
		
		EXEC uspGRInsertStorageHistoryRecord @StorageHistoryStagingTable, @intStorageHistoryId

		--integration to IC
		SET @cnt = 0

		SET @cnt = (SELECT COUNT(*) FROM tblGRTransferStorageSplit WHERE intTransferStorageId = @intTransferStorageId AND intContractDetailId IS NOT NULL)

		DECLARE c CURSOR LOCAL STATIC READ_ONLY FORWARD_ONLY
		FOR
		WITH storageDetails (
			intTransferContractDetailId 
			,dblTransferUnits			
			,intSourceItemUOMId			
			,intCustomerStorageId
		) AS (
			SELECT intTransferContractDetailId	= TransferStorageSplit.intContractDetailId,
				dblTransferUnits				= TransferStorageSplit.dblUnits,
				intSourceItemUOMId			= TransferStorage.intItemUOMId,
				intCustomerStorageId			= TransferStorageSplit.intTransferToCustomerStorageId
			FROM tblGRTransferStorageSplit TransferStorageSplit
			INNER JOIN tblGRTransferStorage TransferStorage
				ON TransferStorage.intTransferStorageId = TransferStorageSplit.intTransferStorageId
			WHERE TransferStorageSplit.intTransferStorageId = @intTransferStorageId
				AND TransferStorageSplit.intContractDetailId IS NOT NULL
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
				,@intExternalId			= @intCustomerStorageId
				,@strScreenName			= 'Transfer Storage'
				,@intSourceItemUOMId	= @intSourceItemUOMId

			FETCH c INTO @intTransferContractDetailId, @dblTransferUnits, @intSourceItemUOMId, @intCustomerStorageId
		END
		CLOSE c; DEALLOCATE c;
		--DISCOUNTS
		DECLARE @intSourceCustomerStorageId INT;
		DECLARE c CURSOR LOCAL STATIC READ_ONLY FORWARD_ONLY
		FOR
			SELECT intToCustomerStorageId,intSourceCustomerStorageId FROM @newCustomerStorageIds
		OPEN c;
		FETCH NEXT FROM c INTO @intCustomerStorageId,@intSourceCustomerStorageId

		WHILE @@FETCH_STATUS = 0
		BEGIN
		INSERT INTO [dbo].[tblQMTicketDiscount]
			(
				[intConcurrencyId]         
				,[dblGradeReading]
				,[strCalcMethod]
				,[strShrinkWhat]
				,[dblShrinkPercent]
				,[dblDiscountAmount]
				,[dblDiscountDue]
				,[dblDiscountPaid]
				,[ysnGraderAutoEntry]
				,[intDiscountScheduleCodeId]
				,[dtmDiscountPaidDate]
				,[intTicketId]
				,[intTicketFileId]
				,[strSourceType]
				,[intSort]
				,[strDiscountChargeType]
			)
			SELECT 
				[intConcurrencyId] 				= 1
				,[dblGradeReading] 				= [dblGradeReading]
				,[strCalcMethod] 				= [strCalcMethod]
				,[strShrinkWhat] 				= [strShrinkWhat]
				,[dblShrinkPercent] 			= [dblShrinkPercent]
				,[dblDiscountAmount] 			= [dblDiscountAmount]
				,[dblDiscountDue] 				= [dblDiscountDue]
				,[dblDiscountPaid] 				= [dblDiscountPaid]
				,[ysnGraderAutoEntry] 			= [ysnGraderAutoEntry]
				,[intDiscountScheduleCodeId] 	= [intDiscountScheduleCodeId]
				,[dtmDiscountPaidDate] 			= [dtmDiscountPaidDate]
				,[intTicketId] 					= NULL
				,[intTicketFileId] 				= @intCustomerStorageId
				,[strSourceType] 				= 'Storage'
				,[intSort] 						= [intSort]
				,[strDiscountChargeType] 		= [strDiscountChargeType]
			FROM tblQMTicketDiscount Discount
			WHERE intTicketFileId = @intSourceCustomerStorageId AND Discount.strSourceType = 'Storage'

			FETCH NEXT FROM c INTO @intCustomerStorageId,@intSourceCustomerStorageId
		END
		CLOSE c; DEALLOCATE c;

		--strTransferTicket is being used by RM, we need to update the strTransferTicket so that they won't to look at our table just to get its corresponding string
		UPDATE tblGRStorageHistory 
		SET strTransferTicket = (SELECT strTransferStorageTicket FROM tblGRTransferStorage WHERE intTransferStorageId = @intTransferStorageId) 
		WHERE intTransferStorageId = @intTransferStorageId

		-- COMMIT TRANSACTION


END TRY

BEGIN CATCH
	SET @ErrMsg = ERROR_MESSAGE()
	RAISERROR (@ErrMsg,16,1,'WITH NOWAIT')

	-- ROLLBACK TRANSACTION
END CATCH