CREATE PROCEDURE uspGRCreateCustomerStorage
	@CustomerStorageStagingTable AS CustomerStorageStagingTable READONLY
	,@intCustomerStorageId INT = 0 OUTPUT
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

DECLARE @intEntityId INT = NULL
DECLARE @intItemId INT = NULL
DECLARE @intLocationId INT = NULL
DECLARE @dblBalance NUMERIC(38,20)
DECLARE @intDeliverySheetId INT = NULL
DECLARE @ErrMsg NVARCHAR(MAX)
DECLARE @intHoldCustomerStorageId INT
DECLARE @newBalance DECIMAL(38,20) = 0
DECLARE @storageHistoryData AS [StorageHistoryStagingTable]
DECLARE @intStorageHistoryId INT
DECLARE @intStorageTypeId INT
DECLARE @intStorageScheduleId INT
DECLARE @intShipFromLocationId INT
DECLARE @intShipFromEntityId INT
DECLARE @ysnDPOwnedType BIT

BEGIN TRY
	--check if a storage already exists 
	SELECT 
		@intEntityId				= CS.intEntityId
		, @intItemId				= CS.intItemId
		, @intLocationId			= CS.intCompanyLocationId
		, @dblBalance				= CS.dblQuantity
		, @intDeliverySheetId		= CS.intDeliverySheetId
		, @intStorageTypeId			= CS.intStorageTypeId
		, @intStorageScheduleId		= CS.intStorageScheduleId
		, @intShipFromLocationId	= CS.intShipFromLocationId
		, @intShipFromEntityId		= CS.intShipFromEntityId
	FROM @CustomerStorageStagingTable CS	

	SELECT @ysnDPOwnedType = ysnDPOwnedType FROM tblGRStorageType WHERE intStorageScheduleTypeId = @intStorageTypeId

	IF EXISTS(SELECT 1 FROM tblGRCustomerStorage WHERE intEntityId = @intEntityId AND intItemId = @intItemId AND intCompanyLocationId = @intLocationId AND intDeliverySheetId = @intDeliverySheetId AND intStorageTypeId = @intStorageTypeId)
	BEGIN
		SELECT @intCustomerStorageId = intCustomerStorageId FROM tblGRCustomerStorage WHERE intEntityId = @intEntityId AND intItemId = @intItemId AND intCompanyLocationId = @intLocationId AND intDeliverySheetId = @intDeliverySheetId AND intStorageTypeId = @intStorageTypeId

		EXEC uspGRCustomerStorageBalance
				@intEntityId = NULL
				,@intItemId = NULL
				,@intLocationId = NULL
				,@intDeliverySheetId = NULL
				,@intCustomerStorageId = @intCustomerStorageId
				,@dblBalance = @dblBalance
				,@intStorageTypeId = @intStorageTypeId
				,@intStorageScheduleId = @intStorageScheduleId
				,@ysnDistribute = 1
				,@intShipFromLocationId = @intShipFromLocationId
				,@intShipFromEntityId = @intShipFromEntityId
				,@newBalance = @newBalance OUT
	END
	ELSE
	BEGIN
		-- Insert the Customer Storage Record if the ticket has no delivery sheet or split vendor entity was newly added in the delivery sheet
		INSERT INTO [dbo].[tblGRCustomerStorage]
				   ([intConcurrencyId]
				   ,[intEntityId]
				   ,[intCommodityId]
				   ,[intStorageScheduleId]
				   ,[intStorageTypeId]
				   ,[intCompanyLocationId]
				   ,[intTicketId]
				   ,[intDeliverySheetId]
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
				   ,[intCurrencyId]
				   ,[strStorageTicketNumber]
				   ,[intItemId]
				   ,[intCompanyLocationSubLocationId]
				   ,[intStorageLocationId]
				   ,[intUnitMeasureId]
				   ,[intItemUOMId]
				   ,[dblGrossQuantity]
				   ,[dblBasis]
				   ,[dblSettlementPrice])
		SELECT 	[intConcurrencyId]					= 1
				,[intEntityId]						= CS.intEntityId
				,[intCommodityId]					= CS.intCommodityId
				,[intStorageScheduleId]				= CS.intStorageScheduleId
				,[intStorageTypeId]					= CS.intStorageTypeId
				,[intCompanyLocationId]				= CS.intCompanyLocationId
				,[intTicketId]						= CASE WHEN CS.intDeliverySheetId > 0 THEN NULL ELSE CS.intTicketId END
				,[intDeliverySheetId]				= CS.intDeliverySheetId
				,[intDiscountScheduleId]			= CS.intDiscountScheduleId
				,[dblTotalPriceShrink]				= 0
				,[dblTotalWeightShrink]				= 0 
				,[dblOriginalBalance]				= CS.dblQuantity
				,[dblOpenBalance]					= CS.dblQuantity
				,[dtmDeliveryDate]					= CS.dtmDeliveryDate
				,[dtmZeroBalanceDate]				= NULL
				,[strDPARecieptNumber]				= NULL
				,[dtmLastStorageAccrueDate]			= NULL 
				,[dblStorageDue]					= 0 --to do 
				,[dblStoragePaid]					= 0
				,[dblInsuranceRate]					= 0 
				,[strOriginState]					= NULL 
				,[strInsuranceState]				= NULL
				,[dblFeesDue]						= CS.dblFeesDue
				,[dblFeesPaid]						= 0 
				,[dblFreightDueRate]				= CS.dblFreightDueRate
				,[ysnPrinted]						= 0 
				,[dblCurrencyRate]					= 1
				,[intCurrencyId]					= CS.intCurrencyId
				,[strStorageTicketNumber]			= CS.strTransactionNumber
				,[intItemId]						= CS.[intItemId]
				,[intCompanyLocationSubLocationId]	= CS.[intCompanyLocationSubLocationId]
				,[intStorageLocationId]				= CS.[intStorageLocationId]
				,[intUnitMeasureId]					= CS.[intUnitMeasureId]
				,[intItemUOMId]						= CS.[intItemUOMId]
				,[dblGrossQuantity]					= CASE WHEN CS.intDeliverySheetId > 0 THEN NULL ELSE CS.dblGrossQuantity END
				,[dblBasis]							= CS.dblBasis
				,[dblSettlementPrice]				= CS.dblSettlementPrice
		FROM	@CustomerStorageStagingTable CS

		SELECT @intCustomerStorageId = SCOPE_IDENTITY()
	END

	IF @intCustomerStorageId IS NULL 
	BEGIN
		RAISERROR('Unable to get Identity value from Customer Storage', 16, 1);
		RETURN;
	END

	--always insert a record in storage history	
	INSERT INTO @storageHistoryData
			([intCustomerStorageId]
			,[intTicketId]
			,[intDeliverySheetId]
			,[intContractHeaderId]
			,[dblUnits]
			,[dtmHistoryDate]
			,[strPaidDescription]
			,[dblCurrencyRate]
			,[intTransactionTypeId]
			,[intUserId]
			,[ysnPost],
			[strType])
	SELECT 	[intCustomerStorageId]				= @intCustomerStorageId				
			,[intTicketId]						= CS.intTicketId
			,[intDeliverySheetId]				= CS.intDeliverySheetId
			,[intContractHeaderId]				= CASE WHEN @ysnDPOwnedType = 1 THEN CS.intContractHeaderId ELSE NULL END
			,[dblUnits]							= CS.dblQuantity
			,[dtmHistoryDate]					= dbo.fnRemoveTimeOnDate(CS.dtmDeliveryDate)
			,[strPaidDescription]				= CASE WHEN CS.intDeliverySheetId > 0 THEN 'Generated From Scale Ticket with Delivery Sheet' ELSE 'Generated From Scale' END
			,[dblCurrencyRate]					= 1
			,[intTransactionTypeId]				= CASE WHEN CS.intDeliverySheetId > 0 THEN 5 ELSE 1 END
			,[intUserId]						= CS.intUserId --strUserName will be replaced by intUserId
			,[ysnPost]							= 1
			,[strType]							= CASE WHEN CS.intDeliverySheetId > 0 THEN 'From Delivery Sheet' ELSE 'From Scale' END
	FROM	@CustomerStorageStagingTable CS

	EXEC uspGRInsertStorageHistoryRecord @storageHistoryData, @intStorageHistoryId OUTPUT

	--update the discounts due, storage due
	--calculate total discounts for [dblDiscountsDue]
	SET @intHoldCustomerStorageId = NULL
	SELECT @intHoldCustomerStorageId = SD.intTicketFileId from tblQMTicketDiscount SD 
	WHERE SD.intTicketFileId = @intCustomerStorageId and SD.[strSourceType]= 'Storage'
	
	IF @intHoldCustomerStorageId IS NULL AND @intDeliverySheetId IS NULL
	BEGIN
		INSERT INTO [dbo].[tblQMTicketDiscount]
           ([intConcurrencyId]         
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
		   ,[strDiscountChargeType])
		SELECT	 
			[intConcurrencyId]			= 1       
           ,[dblGradeReading]			= SD.[dblGradeReading]
           ,[strCalcMethod]				= SD.[strCalcMethod]
           ,[strShrinkWhat]				= SD.[strShrinkWhat]			
           ,[dblShrinkPercent]			= CASE WHEN ISNULL(DCode.intUnitMeasureId,0) = 0 THEN SD.[dblShrinkPercent]  ELSE dbo.fnCTConvertQuantityToTargetItemUOM(@intItemId,CS.intUnitMeasureId,DCode.intUnitMeasureId,SD.[dblShrinkPercent])  END
           ,[dblDiscountAmount]			= CASE WHEN ISNULL(DCode.intUnitMeasureId,0) = 0 THEN SD.[dblDiscountAmount] ELSE dbo.fnCTConvertQuantityToTargetItemUOM(@intItemId,CS.intUnitMeasureId,DCode.intUnitMeasureId,SD.[dblDiscountAmount]) END
           ,[dblDiscountDue]			= CASE WHEN ISNULL(DCode.intUnitMeasureId,0) = 0 THEN SD.[dblDiscountAmount] ELSE dbo.fnCTConvertQuantityToTargetItemUOM(@intItemId,CS.intUnitMeasureId,DCode.intUnitMeasureId,SD.[dblDiscountAmount]) END
           ,[dblDiscountPaid]			= ISNULL(SD.[dblDiscountPaid],0)
           ,[ysnGraderAutoEntry]		= SD.[ysnGraderAutoEntry]
           ,[intDiscountScheduleCodeId] = SD.[intDiscountScheduleCodeId]
           ,[dtmDiscountPaidDate]		= SD.[dtmDiscountPaidDate]
           ,[intTicketId]				= NULL
           ,[intTicketFileId]			= @intCustomerStorageId
           ,[strSourceType]				= 'Storage'
		   ,[intSort]					= SD.[intSort]
		   ,[strDiscountChargeType]		= SD.[strDiscountChargeType]
		FROM dbo.[tblQMTicketDiscount] SD
		JOIN @CustomerStorageStagingTable CS ON CS.intTicketId = SD.intTicketId
		JOIN tblGRDiscountScheduleCode DCode ON DCode.intDiscountScheduleCodeId = SD.intDiscountScheduleCodeId
		WHERE SD.strSourceType = 'Scale'
		
		UPDATE CS
		SET  CS.dblDiscountsDue = QM.dblDiscountsDue
			,CS.dblDiscountsPaid = QM.dblDiscountsPaid
		FROM tblGRCustomerStorage CS
		JOIN (
				SELECT intTicketFileId 
					, SUM(dblDiscountDue) dblDiscountsDue 
					, SUM(dblDiscountPaid)dblDiscountsPaid 
				FROM dbo.[tblQMTicketDiscount] 
				WHERE intTicketFileId = @intCustomerStorageId 
						AND strSourceType = 'Storage' 
						AND strDiscountChargeType = 'Dollar' 
				GROUP BY intTicketFileId
			) QM ON CS.intCustomerStorageId = QM.intTicketFileId
	END
END TRY
BEGIN CATCH
	SET @ErrMsg = ERROR_MESSAGE()
	RAISERROR (@ErrMsg,16,1,'WITH NOWAIT')
END CATCH