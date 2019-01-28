CREATE PROCEDURE [dbo].[uspGRProcessTransfer]
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
	DECLARE @StorageHistoryStagingTable AS [StorageHistoryStagingTable]
	DECLARE @newCustomerStorageIds AS TABLE (storageId INT, transferSplitId INT)
	DECLARE @CustomerStorageStagingTable AS CustomerStorageStagingTable
	DECLARE @CurrentItemOpenBalance DECIMAL(38,20)
	DECLARE @intTransferContractDetailId INT
	DECLARE @dblTransferUnits NUMERIC(18,6)
	DECLARE @intSourceItemUOMId INT
	DECLARE @intCustomerStorageId INT --new customer storage id
	DECLARE @intStorageHistoryId INT = 0
	DECLARE @intDecimalPrecision INT	
	SELECT @intDecimalPrecision = intCurrencyDecimal FROM tblSMCompanyPreference

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

	BEGIN TRY
	
		DECLARE @transCount INT = @@TRANCOUNT;
		IF @transCount = 0 BEGIN TRANSACTION

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
			,[dblUnits]				= -(SourceSplit.dblDeductedUnits)
			,[dtmHistoryDate]		= GETDATE()
			,[intUserId]			= @intUserId
			,[ysnPost]				= 1
			,[intTransactionTypeId]	= 3
			,[strPaidDescription]	= 'Generated from Transfer Storage'
			,[strType]				= 'Transfer'
		FROM tblGRTransferStorageSourceSplit SourceSplit
		LEFT JOIN tblCTContractDetail CD
			ON CD.intContractDetailId = SourceSplit.intContractDetailId
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
			,[dblQuantity]						= TransferStorageSplit.dblUnits
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
			,[strTransactionNumber]				= TS.strTransferStorageTicket
			,[intItemId]						= CS.intItemId
			,[intItemUOMId]						= CS.intItemUOMId
			,[intTransferStorageSplitId]		= TransferStorageSplit.intTransferStorageSplitId
			,[intUnitMeasureId]					= (SELECT intUnitMeasureId FROM tblICItemUOM WHERE intItemUOMId = CS.intItemUOMId)
			,[intCompanyLocationSubLocationId]	= CASE WHEN CS.intCompanyLocationId = TransferStorageSplit.intCompanyLocationId THEN CS.intCompanyLocationSubLocationId ELSE NULL END
			,[intStorageLocationId]				= CASE WHEN CS.intCompanyLocationId = TransferStorageSplit.intCompanyLocationId THEN CS.intStorageLocationId ELSE NULL END
			,[intTicketId]						= CS.intTicketId
			,[intDeliverySheetId]				= CS.intDeliverySheetId
			,[ysnTransferStorage]				= 1
			,[dblGrossQuantity]					= ROUND((TransferStorageSplit.dblUnits / CS.dblOriginalBalance) * CS.dblGrossQuantity,@intDecimalPrecision)
		FROM tblGRCustomerStorage CS
		INNER JOIN tblGRTransferStorageSourceSplit SourceStorage
			ON SourceStorage.intSourceCustomerStorageId = CS.intCustomerStorageId
		INNER JOIN tblGRTransferStorage TS
			ON TS.intTransferStorageId = SourceStorage.intTransferStorageId
		INNER JOIN tblGRTransferStorageSplit TransferStorageSplit
			ON TransferStorageSplit.intTransferStorageId = SourceStorage.intTransferStorageId		
		WHERE SourceStorage.intTransferStorageId = @intTransferStorageId

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
			SourceData.intTransferStorageSplitId
		INTO @newCustomerStorageIds;
		
		--update tblGRTransferStorageSplit's intCustomerStorageId
		UPDATE A
		SET A.intTransferToCustomerStorageId = B.storageId
		FROM tblGRTransferStorageSplit A
		INNER JOIN @newCustomerStorageIds B
			ON B.transferSplitId = A.intTransferStorageSplitId

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
			[intCustomerStorageId]	= A.storageId
			,[intTransferStorageId]	= TransferStorageSplit.intTransferStorageId
			,[intContractHeaderId]	= CD.intContractHeaderId
			,[dblUnits]				= TransferStorageSplit.dblUnits
			,[dtmHistoryDate]		= GETDATE()
			,[intUserId]			= @intUserId
			,[ysnPost]				= 1
			,[intTransactionTypeId]	= 3
			,[strPaidDescription]	= 'Generated from Transfer Storage'
			,[strType]				= 'From Transfer'
		FROM tblGRTransferStorageSplit TransferStorageSplit
		INNER JOIN @newCustomerStorageIds A
			ON A.transferSplitId = TransferStorageSplit.intTransferStorageSplitId
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
		DECLARE c CURSOR LOCAL STATIC READ_ONLY FORWARD_ONLY
		FOR
			SELECT storageId FROM @newCustomerStorageIds
		OPEN c;
		FETCH NEXT FROM c INTO @intCustomerStorageId	

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
			INNER JOIN tblGRTransferStorageSourceSplit SourceSplit
				ON SourceSplit.intSourceCustomerStorageId = Discount.intTicketFileId
					AND SourceSplit.intTransferStorageId = @intTransferStorageId
					AND Discount.strSourceType = 'Storage'
			
			FETCH NEXT FROM c INTO @intCustomerStorageId
		END
		CLOSE c; DEALLOCATE c;

		--strTransferTicket is being used by RM, we need to update the strTransferTicket so that they won't to look at our table just to get its corresponding string
		UPDATE tblGRStorageHistory 
		SET strTransferTicket = (SELECT strTransferStorageTicket FROM tblGRTransferStorage WHERE intTransferStorageId = @intTransferStorageId) 
		WHERE intTransferStorageId = @intTransferStorageId

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