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
DECLARE @dblBalance INT = 0
DECLARE @intDeliverySheetId INT = NULL
DECLARE @ErrMsg NVARCHAR(MAX)
DECLARE @intHoldCustomerStorageId INT
DECLARE @newBalance DECIMAL(18,6) = 0
BEGIN TRY
	--check if a storage already exists 
	SELECT 
		@intEntityId			= CS.intEntityId
		, @intItemId			= CS.intItemId
		, @intLocationId		= CS.intCompanyLocationId
		, @dblBalance			= CS.dblQuantity
		, @intDeliverySheetId	= CS.intDeliverySheetId
	FROM @CustomerStorageStagingTable CS	

	IF EXISTS(SELECT 1 FROM tblGRCustomerStorage WHERE intEntityId = @intEntityId AND intItemId = @intItemId AND intCompanyLocationId = @intLocationId AND intDeliverySheetId = @intDeliverySheetId)
	BEGIN
		SELECT @intCustomerStorageId = intCustomerStorageId FROM tblGRCustomerStorage WHERE intEntityId = @intEntityId AND intItemId = @intItemId AND intCompanyLocationId = @intLocationId AND intDeliverySheetId = @intDeliverySheetId

		EXEC uspGRCustomerStorageBalance
				@intEntityId = NULL
				,@intItemId = NULL
				,@intLocationId = NULL
				,@intDeliverySheetId = NULL
				,@intCustomerStorageId = @intCustomerStorageId
				,@dblBalance = @dblBalance
				,@ysnDistribute = 1
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
				   ,[intItemUOMId])
		SELECT 	[intConcurrencyId]					= 1
				,[intEntityId]						= CS.intEntityId
				,[intCommodityId]					= CS.intCommodityId
				,[intStorageScheduleId]				= CS.intStorageScheduleId
				,[intStorageTypeId]					= CS.intStorageTypeId
				,[intCompanyLocationId]				= CS.intCompanyLocationId
				,[intTicketId]						= CS.intTicketId
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
		FROM	@CustomerStorageStagingTable CS

		SELECT @intCustomerStorageId = SCOPE_IDENTITY()
	END

	IF @intCustomerStorageId IS NULL 
	BEGIN
		RAISERROR('Unable to get Identity value from Customer Storage', 16, 1);
		RETURN;
	END

	--always insert a record in storage history
	INSERT INTO [dbo].[tblGRStorageHistory]
			([intConcurrencyId]
			,[intCustomerStorageId]
			,[intTicketId]
			,[intDeliverySheetId]
			,[intInventoryReceiptId]
			,[intInvoiceId]
			,[intContractHeaderId]
			,[dblUnits]
			,[dtmHistoryDate]
			,[dblPaidAmount]
			,[strPaidDescription]
			,[dblCurrencyRate]
			,[strType]
			,[intUserId]
			,[intTransactionTypeId])
	SELECT 	[intConcurrencyId]					= 1
			,[intCustomerStorageId]				= @intCustomerStorageId				
			,[intTicketId]						= CS.intTicketId
			,[intDeliverySheetId]				= CS.intDeliverySheetId
			,[intInventoryReceiptId]			= NULL
			,[intInvoiceId]						= NULL
			,[intContractHeaderId]				= CS.intContractHeaderId
			,[dblUnits]							= CASE WHEN @newBalance > 0 THEN @newBalance ELSE CS.dblQuantity END
			,[dtmHistoryDate]					= dbo.fnRemoveTimeOnDate(CS.dtmDeliveryDate)
			,[dblPaidAmount]					= 0
			,[strPaidDescription]				= 'Generated From Scale'
			,[dblCurrencyRate]					= 1
			,[strType]							= 'From Scale'
			,[intUserId]						= CS.intUserId --strUserName will be replaced by intUserId
			,[intTransactionTypeId]				= 1
	FROM	@CustomerStorageStagingTable CS

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
		LEFT JOIN @CustomerStorageStagingTable CS ON CS.intTicketId = SD.intTicketId
		JOIN tblGRDiscountScheduleCode DCode ON DCode.intDiscountScheduleCodeId = SD.intDiscountScheduleCodeId
		LEFT JOIN tblICUnitMeasure UOM ON UOM.intUnitMeasureId = DCode.intUnitMeasureId
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

	SELECT @intCustomerStorageId AS 'intCustomerStorageId'
END TRY
BEGIN CATCH
	SET @ErrMsg = ERROR_MESSAGE()
	RAISERROR (@ErrMsg,16,1,'WITH NOWAIT')
END CATCH