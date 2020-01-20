﻿CREATE PROCEDURE [dbo].[uspGRProcessTransfer]
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

	--debug point--
	declare @debug_point bit = 0
	--debug point

	DECLARE @ErrMsg AS NVARCHAR(MAX)
	DECLARE @StorageHistoryStagingTable AS [StorageHistoryStagingTable]	
	DECLARE @CustomerStorageStagingTable AS CustomerStorageStagingTable
	DECLARE @CurrentItemOpenBalance DECIMAL(38,20)
	DECLARE @intTransferContractDetailId INT
	DECLARE @dblTransferUnits NUMERIC(18,6)
	DECLARE @intSourceItemUOMId INT
	DECLARE @intCustomerStorageId INT --new customer storage id
	DECLARE @intStorageHistoryId INT = 0
	DECLARE @intDecimalPrecision INT = 20
	DECLARE @intTransferStorageSplitId INT
	DECLARE @XML NVARCHAR(MAX)
	DECLARE @strScreenName NVARCHAR(50)
	DECLARE @intNewContractHeaderId INT
	DECLARE @intNewContractDetailId INT
	DECLARE @intEntityId INT
	DECLARE @intToEntityId INT

	DECLARE @newCustomerStorageIds AS TABLE 
	(
		intToCustomerStorageId INT
		,intTransferStorageSplitId INT
		,intSourceCustomerStorageId INT
		,dblUnitQty NUMERIC(38,20)
		,dblSplitPercent NUMERIC(38,20)
		,dtmProcessDate DATETIME NOT NULL DEFAULT(GETDATE())
	)
	DECLARE @GLForItem AS GLForItem
	SELECT @intDecimalPrecision = intCurrencyDecimal FROM tblSMCompanyPreference
	DECLARE @intTransferStorageReferenceId INT

	--return

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
	
	BEGIN TRANSACTION
	BEGIN TRY
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
				dblTransferUnits				= -CASE WHEN (SourceSplit.dblOriginalUnits - SourceSplit.dblDeductedUnits) = 0 THEN SourceSplit.dblOriginalUnits ELSE (SourceSplit.dblOriginalUnits - SourceSplit.dblDeductedUnits) END ,
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
		FROM ( SELECT * FROM sourceStorageDetails ) params
		
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
					,dbo.fnCTConvertQuantityToTargetItemUOM(ToStorage.intItemId, IU.intUnitMeasureId, ToStorage.intUnitMeasureId, SR.dblUnitQty) 
						* CASE WHEN (FromType.ysnDPOwnedType = 0 AND ToType.ysnDPOwnedType = 1) THEN -1 ELSE 1 END
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

				--debug point
				if @debug_point = 1  and 1 = 0
				begin
					select 'fresh item to post '
					select * from @ItemsToPost
					select 'transfer storage reference '
					select * from tblGRTransferStorageReference SR
						where SR.intTransferStorageId = @intTransferStorageId
					select 'transfer storage reference '

				end
				--debug point

				DECLARE @cursorId INT

				DECLARE _CURSOR CURSOR
				FOR
				SELECT intId FROM @ItemsToPost
	
				OPEN _CURSOR
				FETCH NEXT FROM _CURSOR INTO @cursorId
				WHILE @@FETCH_STATUS = 0
				BEGIN		
						DECLARE @GLEntries AS RecapTableType;
						DECLARE @DummyGLEntries AS RecapTableType;
						DECLARE @Entry as ItemCostingTableType;
						DECLARE @dblCost AS DECIMAL(24,10);
						DECLARE @dblOriginalCost AS DECIMAL(24,10);
						DECLARE @dblDiscountCost AS DECIMAL(24,10);
						DECLARE @dblUnits AS DECIMAL(24,10);
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
							,@dblBasisCost DECIMAL(18,6)
							,@dblSettlementPrice DECIMAL(18,6)
							,@strRKError VARCHAR(MAX)


						SELECT @intItemId = ITP.intItemId,@intLocationId = IL.intLocationId,@intSubLocationId = ITP.intSubLocationId, @intStorageLocationId = ITP.intStorageLocationId, @dtmDate = ITP.dtmDate, @intOwnerShipId = CASE WHEN ITP.ysnIsStorage = 1 THEN 2 ELSE 1 END
							,@dblUnits = ITP.dblQty
						FROM @ItemsToPost ITP
						INNER JOIN tblICItem I
							ON ITP.intItemId = I.intItemId
						INNER JOIN tblICCommodity ICC
							ON ICC.intCommodityId = I.intCommodityId
						INNER JOIN tblICItemLocation IL
							ON IL.intItemLocationId = ITP.intItemLocationId
						WHERE intId = @cursorId
						
						SELECT @dblBasisCost = (SELECT dblBasis FROM dbo.fnRKGetFutureAndBasisPrice (1,I.intCommodityId,right(convert(varchar, dtmDate, 106),8),1,NULL,NULL,@intLocationId,NULL,0,I.intItemId,intCurrencyId))
							,@dblSettlementPrice  = (SELECT dblSettlementPrice FROM dbo.fnRKGetFutureAndBasisPrice (1,I.intCommodityId,right(convert(varchar, dtmDate, 106),8),2,NULL,NULL,@intLocationId,NULL,0,I.intItemId,intCurrencyId))
						FROM @ItemsToPost ITP
						INNER JOIN tblICItem I
							ON ITP.intItemId = I.intItemId
						INNER JOIN tblICCommodity ICC
							ON ICC.intCommodityId = I.intCommodityId
						INNER JOIN tblICItemLocation IL
							ON IL.intItemLocationId = ITP.intItemLocationId
						WHERE intId = @cursorId

						SELECT @strRKError = CASE WHEN ISNULL(@dblBasisCost,0) = 0 AND ISNULL(@dblSettlementPrice,0) = 0 THEN 'Basis and Settlement Price' WHEN  ISNULL(@dblBasisCost,0) = 0 THEN 'Basis Price' WHEN ISNULL(@dblSettlementPrice,0) = 0 THEN 'Settlement Price' END +  ' in risk management is not available.'

						IF @strRKError IS NOT NULL
						BEGIN
							RAISERROR (@strRKError,16,1,'WITH NOWAIT') 
						END

						SET @dblCost =ISNULL(@dblSettlementPrice,0) + ISNULL(@dblBasisCost,0)
						set @dblOriginalCost = @dblCost

						DECLARE @OtherChargesDetail AS TABLE(
							intOtherChargesDetailId INT IDENTITY(1, 1)
							,strOrderType NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
							,intCustomerStorageId INT
							,intCompanyLocationId INT
							,dblUnits DECIMAL(24, 10)
							,dblCashPrice DECIMAL(36, 20)
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
																	--(SR.dblUnitQty / CS.dblOriginalBalance) * 
																	ROUND((CS.dblGrossQuantity  * (isnull(SR.dblSplitPercent, 100) / 100)) ,10)
																END
															ELSE SR.dblUnitQty
														END
							,dblCashPrice				= CASE 
															WHEN QM.strDiscountChargeType = 'Percent'
																		THEN (dbo.fnCTConvertQuantityToTargetItemUOM(CS.intItemId, IU.intUnitMeasureId, CS.intUnitMeasureId, ISNULL(QM.dblDiscountPaid, 0)) - dbo.fnCTConvertQuantityToTargetItemUOM(CS.intItemId, IU.intUnitMeasureId, CS.intUnitMeasureId, ISNULL(QM.dblDiscountDue, 0)))
																			*
																			@dblCost
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
							,ysnIsPercent				=  CASE WHEN QM.strDiscountChargeType = 'Percent' THEN 1 ELSE 0 END
							FROM @ItemsToPost ITP
							JOIN tblGRTransferStorageReference SR
							  ON ITP.intTransactionId = SR.intTransferStorageId
							 AND ITP. intTransactionDetailId = SR.intTransferStorageSplitId
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
							WHERE (ISNULL(QM.dblDiscountDue, 0) - ISNULL(QM.dblDiscountPaid, 0)) <> 0 and ITP.intId = @cursorId
							
						

						--debug point--
						if @debug_point = 1  and 1 = 0
						begin
							select 'start item to post'
							select * from @ItemsToPost
							select 'end item to post '

							select 'start debug point other charges detail'
							select * from @OtherChargesDetail
							select 'end debug point other charges detail'

							select
							CS.dblGrossQuantity * (isnull(SR.dblSplitPercent, 100) / 100),
							dblCashPrice				= CASE 
															WHEN QM.strDiscountChargeType = 'Percent'
																		THEN (dbo.fnCTConvertQuantityToTargetItemUOM(CS.intItemId, IU.intUnitMeasureId, CS.intUnitMeasureId, ISNULL(QM.dblDiscountPaid, 0)) - dbo.fnCTConvertQuantityToTargetItemUOM(CS.intItemId,	IU.intUnitMeasureId, CS.intUnitMeasureId, ISNULL(QM.dblDiscountDue, 0)))
																			*
																			@dblCost
															ELSE --Dollar
																dbo.fnCTConvertQuantityToTargetItemUOM(CS.intItemId, IU.intUnitMeasureId, CS.intUnitMeasureId, ISNULL(QM.dblDiscountPaid, 0)) - dbo.fnCTConvertQuantityToTargetItemUOM(CS.intItemId, IU.intUnitMeasureId, CS.intUnitMeasureId, ISNULL(QM.dblDiscountDue, 0))
														END,
							QM.strDiscountChargeType,
							QM.dblDiscountPaid,
							QM.dblDiscountDue,
							dbo.fnCTConvertQuantityToTargetItemUOM(CS.intItemId, IU.intUnitMeasureId, CS.intUnitMeasureId, ISNULL(QM.dblDiscountPaid, 0)),
							dbo.fnCTConvertQuantityToTargetItemUOM(CS.intItemId, IU.intUnitMeasureId, CS.intUnitMeasureId, ISNULL(QM.dblDiscountDue, 0)),
							@dblCost

							FROM @ItemsToPost ITP
							JOIN tblGRTransferStorageReference SR
							  ON ITP.intTransactionId = SR.intTransferStorageId
							 AND ITP. intTransactionDetailId = SR.intTransferStorageSplitId
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
							WHERE (ISNULL(QM.dblDiscountDue, 0) - ISNULL(QM.dblDiscountPaid, 0)) <> 0 and ITP.intId = @cursorId



						end
						--debug point--


						SELECT @dblCost = @dblCost + ISNULL(SUM(dblCashPrice),0) FROM @OtherChargesDetail OCD 
						INNER JOIN tblICItem IC
							ON IC.intItemId = OCD.intItemId
						WHERE IC.ysnInventoryCost = 1

						update @OtherChargesDetail set dblExactCashPrice = ROUND(dblUnits*dblCashPrice,2)

						SELECT @dblDiscountCost = ISNULL(SUM(round(dblUnits*dblCashPrice, 2)),0) FROM @OtherChargesDetail OCD 
						INNER JOIN tblICItem IC
							ON IC.intItemId = OCD.intItemId
						WHERE IC.ysnInventoryCost = 1

						--debug point 
						if @debug_point = 1 and 1 = 0
						begin
							select 'start checking variable data used in the query below'
							select @dblCost, @dblDiscountCost
							select * from @OtherChargesDetail
							select 'end checking variable used '
						end
						--debug point

						DELETE FROM @Entry
						DELETE FROM @GLEntries
						DELETE FROM @GLForItem
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
						SELECT intItemId,intItemLocationId,intItemUOMId,dtmDate,dblQty,dblUOMQty,@dblOriginalCost,dblSalesPrice,intCurrencyId,dblExchangeRate,intTransactionId,intTransactionDetailId,strTransactionId,intTransactionTypeId,intLotId,intSubLocationId,intStorageLocationId,ysnIsStorage,intStorageScheduleTypeId 
						FROM @ItemsToPost WHERE intId = @cursorId

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
						FROM @ItemsToPost WHERE intId = @cursorId


						IF @debug_point = 1 and 1 = 0
						begin
							select 'start checking the quantity for the entry temp table'
								
								select dblQty, * from @Entry
							
							select 'end checking the quantity for the entry temp table'
						end


						IF(SELECT dblQty FROM @Entry) > 0
						BEGIN
							UPDATE @Entry
							SET dblQty = dblQty*-1

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
							,[intSourceEntityId] --MOD
							,[intCommodityId]--MOD
							)
							EXEC	dbo.uspICPostCosting @Entry,@strBatchId,'AP Clearing',@intUserId


							--debug point 
							if @debug_point = 1  and 1 = 0
							begin
								select 'start dummy gl entries'
								select * from @DummyGLEntries
								select 'end dummy gl entries'

								select 'start gl for item'
								select * from @GLForItem
								select 'end gl for item'
								
								select 'start entry'
								select * from @Entry
								select 'end entry ssss' 
							end
							--debug point

							--debug point--
							if @debug_point = 1 and 1 = 0
							begin
								select 'start checking the gl entries for transfer'

								EXEC dbo.uspGRCreateItemGLEntriesTransfer
								@strBatchId
								,@GLForItem
								,'AP Clearing'
								,1

								select 'end checking the gl entries for transfer'
							end
							--debug point--


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
								@strBatchId
								,@GLForItem
								,'AP Clearing'
								,1

							--debug point--
							if @debug_point = 1 and 1 = 1
							begin
								select 'start checking the gl entries for transfer storage 1'
								EXEC [dbo].[uspGRCreateGLEntriesForTransferStorage] @intTransferStorageId,@strBatchId,@dblOriginalCost,1
								select 'end checking the gl entries for transfer storage'
							end
							--debug point--
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
							EXEC [dbo].[uspGRCreateGLEntriesForTransferStorage] @intTransferStorageId,@strBatchId,@dblOriginalCost,1


							if @debug_point = 1 and 1 = 0
							begin
								select 'start checking gl entries before booking'
								select * from @GLEntries
								select 'end checking gl entries before booking'
							end

							IF EXISTS (SELECT TOP 1 1 FROM @GLEntries)
							BEGIN 
									EXEC dbo.uspGLBookEntries @GLEntries, 1 
							END
							
							UPDATE @Entry
							SET dblQty = dblQty*-1
							
							EXEC	dbo.uspICPostStorage @Entry,@strBatchId,@intUserId

						END
						ELSE
						BEGIN
							EXEC	dbo.uspICPostStorage @Entry,@strBatchId,@intUserId

							UPDATE @Entry
							SET dblQty = dblQty*-1

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
							,[intSourceEntityId] --MOD
							,[intCommodityId]--MOD
							)
							EXEC	dbo.uspICPostCosting @Entry,@strBatchId,'AP Clearing',@intUserId
							--Used total discount cost on @GLForItem to get the correct decimal

							--debug point 
							if @debug_point = 1
							begin
								if 1 = 0
								begin
									select 'start gl for item'
									select * from @GLForItem
									select 'end gl for item'

								
								
									select 'start entry'
									select * from @Entry
									select 'end entry'

									
									select 'start create item gl entries transfer '
									EXEC dbo.uspGRCreateItemGLEntriesTransfer
									@strBatchId
									,@GLForItem
									,'AP Clearing'
									,1
								end



								select 'dummy gl'
								select * from @GLForItem
								select ''
			SELECT	t.*
	FROM dbo.tblICInventoryTransaction t 
	INNER JOIN dbo.tblICInventoryTransactionType TransType
		ON t.intTransactionTypeId = TransType.intTransactionTypeId
	INNER JOIN tblICItem i
		ON i.intItemId = t.intItemId
	LEFT JOIN tblSMCurrencyExchangeRateType currencyRateType
		ON currencyRateType.intCurrencyExchangeRateTypeId = t.intForexRateTypeId
	OUTER APPLY (
		SELECT 
			SV.dblCost as dblTotalDiscountCost
		FROM @GLForItem SV
	) DiscountCost
	WHERE t.strBatchId = @strBatchId
		--AND t.intItemId = ISNULL(@intRebuildItemId, t.intItemId) 
		--AND ISNULL(i.intCategoryId, 0) = COALESCE(@intRebuildCategoryId, i.intCategoryId, 0) 
		AND t.intInTransitSourceLocationId IS NULL -- If there is a value in intInTransitSourceLocationId, then it is for In-Transit costing. Use uspICCreateGLEntriesForInTransitCosting instead of this sp.


		
								select 'end create item gl entries transfer '

							end
							--debug point


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
								@strBatchId
								,@GLForItem
								,'AP Clearing'
								,1

							--debug point--
							if @debug_point = 1 and 1 = 0
							begin
								select 'start checking the gl entries for transfer storage'
								EXEC [dbo].[uspGRCreateGLEntriesForTransferStorage] @intTransferStorageId,@strBatchId,@dblOriginalCost,1
								select 'end checking the gl entries for transfer storage'
							end

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
							EXEC [dbo].[uspGRCreateGLEntriesForTransferStorage] @intTransferStorageId,@strBatchId,@dblOriginalCost,1

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
			,A.intContractDetailId = CT.intContractDetailId
		FROM tblGRTransferStorageSplit A		
		INNER JOIN @newCustomerStorageIds B
			ON B.intTransferStorageSplitId = A.intTransferStorageSplitId
		INNER JOIN tblGRCustomerStorage CS
			ON CS.intCustomerStorageId = B.intToCustomerStorageId
		OUTER APPLY (
			SELECT TOP 1 intContractDetailId
			FROM vyuCTGetContractForScaleTicket
			WHERE intPricingTypeId = 5
				AND intEntityId = CS.intEntityId
				AND intCompanyLocationId = CS.intCompanyLocationId
				AND intItemId = CS.intItemId
				AND ysnEarlyDayPassed = 1
				AND intContractTypeId = 1
				AND ysnAllowedToShow = 1
		) CT		
		
		SET @cnt = 0
		SET @cnt = (SELECT COUNT(*) FROM tblGRTransferStorageSplit WHERE intTransferStorageId = @intTransferStorageId AND intContractDetailId IS NULL)

		DECLARE c CURSOR LOCAL STATIC READ_ONLY FORWARD_ONLY
		FOR
		WITH storageDetails (
			intTransferStorageSplitId
			,intEntityId
			,intToEntityId
		) AS (
			SELECT 
				intTransferStorageSplitId	= TransferStorageSplit.intTransferStorageSplitId
				,intEntityId				= CS.intEntityId
				,intToEntityId				= TransferStorageSplit.intEntityId
			FROM tblGRTransferStorageSplit TransferStorageSplit
			INNER JOIN tblGRTransferStorage TransferStorage
				ON TransferStorage.intTransferStorageId = TransferStorageSplit.intTransferStorageId
			INNER JOIN tblGRCustomerStorage CS
				ON CS.intCustomerStorageId = TransferStorageSplit.intTransferToCustomerStorageId
			INNER JOIN tblGRStorageType ST
				ON ST.intStorageScheduleTypeId = CS.intStorageTypeId
			WHERE TransferStorageSplit.intTransferStorageId = @intTransferStorageId
				AND TransferStorageSplit.intContractDetailId IS NULL
				AND ST.ysnDPOwnedType = 1
		)
		SELECT
			intTransferStorageSplitId
			,intEntityId
			,intToEntityId
		FROM ( SELECT * FROM storageDetails ) params
		
		--if there are no contracts and the selected storage is DP
		--(Transfer to DP) if there is no available contract for the selected entity, location and item, create a new contract
		OPEN c;

		FETCH c INTO @intTransferStorageSplitId, @intEntityId, @intToEntityId

		WHILE @@FETCH_STATUS = 0 AND @cnt > 0
		BEGIN
			SET @XML = '<overrides><intEntityId>' + LTRIM(@intToEntityId) + '</intEntityId></overrides>'

			IF @intTransferStorageSplitId IS NOT NULL
			BEGIN
				EXEC uspCTCreateContract
					@intExternalId = @intTransferStorageSplitId,
					@strScreenName = 'Transfer Storage',
					@intUserId = @intUserId,
					@XML = @XML,
					@intContractHeaderId = @intNewContractHeaderId OUTPUT

				UPDATE TSS
				SET TSS.intContractDetailId = CD.intContractDetailId
				FROM tblGRTransferStorageSplit TSS
				OUTER APPLY (
					SELECT intContractDetailId
					FROM tblCTContractDetail
					WHERE intContractHeaderId = @intNewContractHeaderId
				) CD
				WHERE intTransferStorageSplitId = @intTransferStorageSplitId
			END

			FETCH c INTO @intTransferStorageSplitId, @intEntityId, @intToEntityId
		END
		CLOSE c; DEALLOCATE c;

		--(for new customer storage) insert to storage history table
		DELETE FROM @StorageHistoryStagingTable
		
		-- INSERT INTO @StorageHistoryStagingTable
		-- (
		-- 	[intCustomerStorageId]
		-- 	,[intTransferStorageId]
		-- 	,[intContractHeaderId]
		-- 	,[dblUnits]
		-- 	,[dtmHistoryDate]
		-- 	,[intUserId]
		-- 	,[ysnPost]
		-- 	,[intTransactionTypeId]
		-- 	,[strPaidDescription]
		-- 	,[strType]
		-- )
		-- SELECT
		-- 	[intCustomerStorageId]	= A.intToCustomerStorageId
		-- 	,[intTransferStorageId]	= TransferStorageSplit.intTransferStorageId
		-- 	,[intContractHeaderId]	= CD.intContractHeaderId
		-- 	,[dblUnits]				= A.dblUnitQty
		-- 	,[dtmHistoryDate]		= GETDATE()
		-- 	,[intUserId]			= @intUserId
		-- 	,[ysnPost]				= 1
		-- 	,[intTransactionTypeId]	= 3
		-- 	,[strPaidDescription]	= 'Generated from Transfer Storage'
		-- 	,[strType]				= 'From Transfer'
		-- FROM tblGRTransferStorageSplit TransferStorageSplit
		-- INNER JOIN @newCustomerStorageIds A
		-- 	ON A.intTransferStorageSplitId = TransferStorageSplit.intTransferStorageSplitId		
		-- LEFT JOIN tblCTContractDetail CD
		-- 	ON CD.intContractDetailId = TransferStorageSplit.intContractDetailId
		
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
			,[intInventoryReceiptId]
		)
		SELECT DISTINCT	
		     [intCustomerStorageId]	= SR.intToCustomerStorageId
			,[intTransferStorageId]	= SR.intTransferStorageId
			,[intContractHeaderId]	= CD.intContractHeaderId
			,[dblUnits]				= SR.dblUnitQty
			,[dtmHistoryDate]		= GETDATE()
			,[intUserId]			= @intUserId
			,[ysnPost]				= 1
			,[intTransactionTypeId]	= 3
			,[strPaidDescription]	= 'Generated from Transfer Storage'
			,[strType]				= 'From Transfer'
			,[intInventoryReceiptId] = SourceHistory.intInventoryReceiptId
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
		INNER JOIN tblGRStorageHistory SourceHistory
			ON SourceHistory.intCustomerStorageId = FromStorage.intCustomerStorageId AND SourceHistory.intInventoryReceiptId IS NOT NULL
		INNER JOIN tblGRTransferStorageSplit TSS
			ON TSS.intTransferStorageSplitId = SR.intTransferStorageSplitId
		LEFT JOIN tblCTContractDetail CD
			ON CD.intContractDetailId = TSS.intContractDetailId
		WHERE  FromType.ysnDPOwnedType = 1 AND ToType.ysnDPOwnedType = 1
		AND SR.intTransferStorageId = @intTransferStorageId

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
			SELECT 
				intTransferContractDetailId	= TransferStorageSplit.intContractDetailId,
				dblTransferUnits			= TransferStorageSplit.dblUnits,
				intSourceItemUOMId			= TransferStorage.intItemUOMId,
				intCustomerStorageId		= TransferStorageSplit.intTransferToCustomerStorageId
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
		FROM ( SELECT * FROM storageDetails ) params
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
		
		DONE:
		COMMIT TRANSACTION
	
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
	
		ROLLBACK TRANSACTION
	
		RAISERROR (@ErrorMessage , @ErrorSeverity, @ErrorState, @ErrorNumber)
	END CATCH	
	
END