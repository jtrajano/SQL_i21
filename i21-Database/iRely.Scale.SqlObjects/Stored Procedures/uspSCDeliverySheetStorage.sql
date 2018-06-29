CREATE PROCEDURE [dbo].[uspSCDeliverySheetStorage]
	 @intDeliverySheetId AS INT
	,@intUserId AS INT
	,@dblNetUnits AS DECIMAL (13,3)
	,@intEntityId AS INT
	,@strDistributionOption AS NVARCHAR(3)
	,@intDPContractId AS INT
	,@intStorageScheduleId AS INT = NULL
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

DECLARE @intCustomerStorageId AS INT
DECLARE @ysnAddDiscount BIT
DECLARE @intHoldCustomerStorageId AS INT
DECLARE @intGRStorageId AS INT
DECLARE @intScaleStationId AS INT
DECLARE @strGRStorage AS nvarchar(3)
DECLARE @ItemsForItemReceipt AS ItemCostingTableType
DECLARE @intDirectType AS INT = 3
DECLARE @intCommodityUOMId INT
DECLARE @intCommodityUnitMeasureId INT
DECLARE @intTicketItemUOMId INT
DECLARE @strTransactionId NVARCHAR(40) = NULL
DECLARE @InventoryReceiptId AS INT
DECLARE @dblUnits AS DECIMAL (13,3)
DECLARE @intStorageEntityId AS INT
DECLARE @intStorageCommodityId AS INT
DECLARE @intStorageTypeId AS INT
DECLARE @intStorageLocationId AS INT
DECLARE @dblRunningBalance AS DECIMAL (13,3)
DECLARE @strUserName AS NVARCHAR (50)
DECLARE @ysnDPStorage BIT
DECLARE @LineItems AS ScaleTransactionTableType
DECLARE @dblRemainingUnits AS DECIMAL (13,3)
DECLARE @intDefaultStorageSchedule AS INT
DECLARE @intCommodityId AS INT
DECLARE @matchStorageType AS INT
DECLARE @ysnIsStorage AS INT
DECLARE @intContractHeaderId INT
DECLARE @strLotTracking NVARCHAR(4000)
DECLARE @dblAvailableGrainOpenBalance DECIMAL(24, 10)

DECLARE @ErrorMessage NVARCHAR(4000);
DECLARE @ErrorSeverity INT;
DECLARE @ErrorState INT;
DECLARE @PostShipment INT = 1;
DECLARE @total AS INT;

DECLARE @ItemsForItemShipment AS ItemCostingTableType 
DECLARE @ItemsForItemShipmentContract AS ItemCostingTableType

DECLARE @SALES_CONTRACT AS NVARCHAR(50) = 'Sales Contract'
		,@SALES_ORDER AS NVARCHAR(50) = 'SalesOrder'
		,@TRANSFER_ORDER AS NVARCHAR(50) = 'Transfer Order'
		,@strSourceType AS NVARCHAR(100) = 'SalesOrder'
		,@InventoryShipmentId AS INT

DECLARE @ErrMsg                    NVARCHAR(MAX),
              @dblBalance          NUMERIC(12,4),                    
              @intItemId           INT,
              @dblNewBalance       NUMERIC(12,4),
              @strInOutFlag        NVARCHAR(4),
              @dblQuantity         NUMERIC(12,4),
              @strAdjustmentNo     NVARCHAR(50)

BEGIN TRY

	SELECT @strUserName = US.strUserName FROM tblSMUserSecurity US
	WHERE US.[intEntityId] = @intUserId
	
	SELECT @intContractHeaderId=intContractHeaderId FROM vyuCTContractDetailView Where intContractDetailId=@intDPContractId
	
	SELECT DISTINCT @intDefaultStorageSchedule = TIC.intStorageScheduleId, @intCommodityId = TIC.intCommodityId,
	@intScaleStationId = TIC.intScaleSetupId, @intItemId = TIC.intItemId FROM tblSCTicket TIC
	WHERE TIC.intDeliverySheetId = @intDeliverySheetId

	IF @intStorageScheduleId IS NOT NULL
	BEGIN
		SET @intDefaultStorageSchedule = @intStorageScheduleId
	END

	IF @intDefaultStorageSchedule is NULL
	BEGIN
	   	SELECT	@intDefaultStorageSchedule = COM.intScheduleStoreId
		FROM	dbo.tblICCommodity COM	        
		WHERE	COM.intCommodityId = @intCommodityId
	END

    BEGIN
	IF @strDistributionOption = 'CNT'
		SET @ysnIsStorage = 0
	ELSE
		SET @ysnIsStorage = 1
	IF @dblNetUnits < 0
	BEGIN
		SET @PostShipment = 2
		BEGIN 
			SELECT	DISTINCT @intCommodityUnitMeasureId = CommodityUOM.intUnitMeasureId
			FROM	dbo.tblSCTicket SC	        
					INNER JOIN dbo.tblICCommodityUnitMeasure CommodityUOM On SC.intCommodityId  = CommodityUOM.intCommodityId
			WHERE	SC.intDeliverySheetId = @intDeliverySheetId AND CommodityUOM.ysnStockUnit = 1		
		END
		BEGIN 
			SELECT	DISTINCT @intCommodityUOMId = UM.intItemUOMId
				FROM dbo.tblICItemUOM UM	
				  JOIN tblSCTicket SC ON SC.intItemId = UM.intItemId  
			WHERE UM.intUnitMeasureId = @intCommodityUnitMeasureId AND SC.intDeliverySheetId = @intDeliverySheetId
		END
		IF @intCommodityUOMId IS NULL 
		BEGIN 			
			RAISERROR('The stock UOM of the commodity must exist in the conversion table of the item', 16, 1);
			RETURN;
		END

		SET @dblUnits = @dblNetUnits * -1
		SELECT	DISTINCT @intStorageEntityId = SC.intEntityId, @intStorageCommodityId = SC.intCommodityId,
		@intStorageLocationId =  SC.intProcessingLocationId , @intItemId = SC.intItemId
		FROM dbo.tblSCTicket SC
		WHERE SC.intDeliverySheetId = @intDeliverySheetId

		SELECT  @intTicketItemUOMId = ItemUOM.intItemUOMId
		FROM    dbo.tblICItemUOM ItemUOM
		WHERE   ItemUOM.intItemId = @intItemId AND ItemUOM.ysnStockUnit = 1

		SELECT @intStorageTypeId = ST.intStorageScheduleTypeId
		FROM dbo.tblGRStorageType ST
		WHERE ST.strStorageTypeCode = @strDistributionOption
		
		IF @intStorageTypeId is NULL
		BEGIN
	   		SELECT	@intStorageTypeId = ST.intDefaultStorageTypeId
			FROM	dbo.tblSCScaleSetup ST	        
			WHERE	ST.intScaleSetupId = @intScaleStationId
		END

		SELECT @dblAvailableGrainOpenBalance = SUM(dblOpenBalance)
		FROM vyuGRGetStorageTransferTicket
		WHERE intEntityId = @intEntityId
			AND intItemId = @intItemId
			AND intStorageTypeId = @intStorageTypeId
			AND ysnDPOwnedType = 0
			AND ysnCustomerStorage = 0
		IF (@dblAvailableGrainOpenBalance > 0)
		BEGIN			  
			WHILE @dblAvailableGrainOpenBalance > 0
			BEGIN
				SELECT	intItemId = SCD.intItemId
						,intLocationId = ItemLocation.intItemLocationId 
						,intItemUOMId = ItemUOM.intItemUOMId
						,dtmDate = dbo.fnRemoveTimeOnDate(GETDATE())
						,dblQty = CASE
									WHEN @dblUnits >= @dblAvailableGrainOpenBalance THEN @dblAvailableGrainOpenBalance
									ELSE @dblUnits
								END
						,dblUOMQty = ItemUOM.dblUnitQty
						,dblCost = 0
						,dblSalesPrice = 0
						,intCurrencyId = SCD.intCurrencyId
						,dblExchangeRate = 1 -- TODO: Not yet implemented in PO. Default to 1 for now. 
						,intTransactionId = SCD.intDeliverySheetId
						,intTransactionDetailId = NULL
						,strTransactionId = SCD.strDeliverySheetNumber
						,intTransactionTypeId = @intDirectType 
						,intLotId = NULL 
						,intSubLocationId = NULL -- set to null delivery sheet
						,intStorageLocationId = NULL -- set to null delivery sheet
						,ysnIsStorage = 1
				FROM	dbo.tblSCDeliverySheet SCD
						INNER JOIN dbo.tblICItemUOM ItemUOM ON SCD.intItemId = ItemUOM.intItemId
						INNER JOIN dbo.tblICItemLocation ItemLocation ON SCD.intItemId = ItemLocation.intItemId 
						AND SCD.intCompanyLocationId = ItemLocation.intLocationId
				WHERE	SCD.intDeliverySheetId = @intDeliverySheetId AND ItemUOM.ysnStockUnit = 1
				SET @dblAvailableGrainOpenBalance = @dblAvailableGrainOpenBalance-@dblUnits
				GOTO CONTINUEISH
			END
		END
		ELSE
			RETURN;
	END

	SELECT	@intGRStorageId = ST.intStorageScheduleTypeId
	FROM	dbo.tblGRStorageType ST	        
	WHERE	ST.strStorageTypeCode = @strDistributionOption

	IF ISNULL(@intGRStorageId,0) <= 0
	BEGIN
	   	SELECT	@intGRStorageId = ST.intDefaultStorageTypeId
		FROM	dbo.tblSCScaleSetup ST	        
		WHERE	ST.intScaleSetupId = @intScaleStationId
	END
	
	IF ISNULL(@intGRStorageId,0) = 0
	BEGIN 
		-- Raise the error:
		--RAISERROR('Invalid Default Storage Setup - uspSCStorageUpdate', 16, 1);
		RETURN;
	END

	IF @intDefaultStorageSchedule IS NULL 
	BEGIN 
		-- Raise the error:
		--RAISERROR('Invalid Default Schedule Storage in Inventory Commodity - uspSCStorageUpdate', 16, 1);
		RETURN;
	END
	
	SELECT	@matchStorageType = SSR.intStorageType
	FROM	dbo.tblGRStorageScheduleRule SSR	        
	WHERE	SSR.intStorageScheduleRuleId = @intDefaultStorageSchedule		
	
	IF @matchStorageType !=  @intGRStorageId
	BEGIN 
		-- Raise the error:
		--RAISERROR('Storage type / Storage Schedule Mismatch - uspSCStorageUpdate', 16, 1);
		RETURN;
	END

	
	SELECT	DISTINCT @intCommodityUnitMeasureId = CommodityUOM.intUnitMeasureId
	FROM	dbo.tblSCTicket SC	        
	JOIN dbo.tblICCommodityUnitMeasure CommodityUOM On SC.intCommodityId  = CommodityUOM.intCommodityId
	WHERE	SC.intDeliverySheetId = @intDeliverySheetId AND CommodityUOM.ysnStockUnit = 1
	
	SELECT DISTINCT	@intCommodityUOMId = UM.intItemUOMId
	FROM dbo.tblICItemUOM UM	
	JOIN tblSCTicket SC ON SC.intItemId = UM.intItemId  
	WHERE UM.intUnitMeasureId = @intCommodityUnitMeasureId AND SC.intDeliverySheetId = @intDeliverySheetId

	IF @intCommodityUOMId IS NULL 
	BEGIN		
		RAISERROR('The stock UOM of the commodity must exist in the conversion table of the item', 16, 1);
		RETURN;
	END
	
	SELECT  @intTicketItemUOMId = ItemUOM.intItemUOMId
	FROM    dbo.tblICItemUOM ItemUOM
	WHERE   ItemUOM.intItemId = @intItemId AND ItemUOM.ysnStockUnit = 1

	-- Insert the Customer Storage Record 
	INSERT INTO [dbo].[tblGRCustomerStorage]
	           ([intConcurrencyId]
	           ,[intEntityId]
	           ,[intCommodityId]
	           ,[intStorageScheduleId]
	           ,[intStorageTypeId]
	           ,[intCompanyLocationId]
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
			   ,[intUnitMeasureId])
	SELECT DISTINCT 
			[intConcurrencyId]		= 1
			,[intEntityId]			= @intEntityId
			,[intCommodityId]		= IC.intCommodityId
			,[intStorageScheduleId]	= @intDefaultStorageSchedule -- TODO Storage Schedule
			,[intStorageTypeId]		= @intGRStorageId
			,[intCompanyLocationId]= SCD.intCompanyLocationId
			,[intDeliverySheetId]= SCD.intDeliverySheetId
			,[intDiscountScheduleId]= GRDS.intDiscountScheduleId
			,[dblTotalPriceShrink]= 0
			,[dblTotalWeightShrink]= 0 
			,[dblOriginalBalance]= @dblNetUnits
			,[dblOpenBalance]= @dblNetUnits
			,[dtmDeliveryDate]= GETDATE()
			,[dtmZeroBalanceDate]= NULL
			,[strDPARecieptNumber]= NULL
			,[dtmLastStorageAccrueDate]= NULL 
			,[dblStorageDue]= 0 
			,[dblStoragePaid]= 0
			,[dblInsuranceRate]= 0 
			,[strOriginState]= NULL 
			,[strInsuranceState]= NULL
			,[dblFeesDue]= 0 
			,[dblFeesPaid]= 0 
			,[dblFreightDueRate]= 0 
			,[ysnPrinted]= 0 
			,[dblCurrencyRate]= 1
			,[intCurrencyId] = SCD.intCurrencyId
			,[intStorageTicketNumber] = SCD.strDeliverySheetNumber
			,SCD.[intItemId]
			,NULL -- SET to null delivery sheet has no requirements yet for sub location
			,NULL -- SET to null delivery sheet has no requirements yet for storage location
			,(SELECT intUnitMeasureId FROM tblICItemUOM WHERE intItemUOMId = @intTicketItemUOMId)
	FROM	dbo.tblSCDeliverySheet SCD 
	INNER JOIN dbo.tblICItem IC ON IC.intItemId = SCD.intItemId
	INNER JOIN tblGRDiscountId GRD ON GRD.intDiscountId = SCD.intDiscountId
	INNER JOIN tblGRDiscountCrossReference GRDCR ON GRDCR.intDiscountId = GRD.intDiscountId
	INNER JOIN tblGRDiscountSchedule GRDS ON GRDS.intDiscountScheduleId = GRDCR.intDiscountScheduleId AND GRDS.intCommodityId = IC.intCommodityId
	WHERE	SCD.intDeliverySheetId = @intDeliverySheetId

	SELECT @intCustomerStorageId = SCOPE_IDENTITY()
	
	IF @intCustomerStorageId IS NULL 
	BEGIN
		RAISERROR('Unable to get Identity value from Customer Storage', 16, 1);
		RETURN;
	END

	INSERT INTO [dbo].[tblGRStorageHistory]
		   ([intConcurrencyId]
		   ,[intCustomerStorageId]
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
		   ,[strUserName]
		   ,[intTransactionTypeId])
	VALUES
		   (1
		   ,@intCustomerStorageId
		   ,@intDeliverySheetId
		   ,NULL
		   ,NULL
		   ,@intContractHeaderId
		   ,@dblNetUnits
		   ,dbo.fnRemoveTimeOnDate(GETDATE())
		   ,0
		   ,'Generated From Delivery Sheet'
		   ,1
		   ,'From Delivery Sheet'
		   ,@strUserName
		   ,5)
	
	SET @intHoldCustomerStorageId = NULL
	SELECT @intHoldCustomerStorageId = SD.intTicketFileId from tblQMTicketDiscount SD 
	WHERE SD.intTicketFileId = @intCustomerStorageId and SD.[strSourceType]= 'Storage'
	
	IF @intHoldCustomerStorageId IS NULL
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
			[intConcurrencyId]= 1       
           ,[dblGradeReading]= SD.[dblGradeReading]
           ,[strCalcMethod]= SD.[strCalcMethod]
           ,[strShrinkWhat]= SD.[strShrinkWhat]			
           ,[dblShrinkPercent]= SD.[dblShrinkPercent]
           ,[dblDiscountAmount]= SD.[dblDiscountAmount]
           ,[dblDiscountDue]= SD.[dblDiscountAmount]
           ,[dblDiscountPaid]= ISNULL(SD.[dblDiscountPaid],0)
           ,[ysnGraderAutoEntry]= SD.[ysnGraderAutoEntry]
           ,[intDiscountScheduleCodeId]= SD.[intDiscountScheduleCodeId]
           ,[dtmDiscountPaidDate]= SD.[dtmDiscountPaidDate]
           ,[intTicketId]= NULL
           ,[intTicketFileId]= @intCustomerStorageId
           ,[strSourceType]= 'Storage'
		   ,[intSort]=SD.[intSort]
		   ,[strDiscountChargeType]=SD.[strDiscountChargeType]
		FROM dbo.[tblQMTicketDiscount] SD
		WHERE SD.intTicketFileId = @intDeliverySheetId AND SD.strSourceType = 'Delivery Sheet'
		
		UPDATE CS
		SET  CS.dblDiscountsDue=QM.dblDiscountsDue
			,CS.dblDiscountsPaid=QM.dblDiscountsPaid
		FROM tblGRCustomerStorage CS
		OUTER APPLY (
			SELECT SUM(dblDiscountDue) dblDiscountsDue ,SUM(dblDiscountPaid)dblDiscountsPaid FROM dbo.[tblQMTicketDiscount] WHERE intTicketFileId = @intCustomerStorageId AND strSourceType = 'Storage'
		) QM
		WHERE CS.intCustomerStorageId = @intCustomerStorageId

	END
	
	IF @intGRStorageId > 0
	BEGIN
		SELECT @strDistributionOption = GR.strStorageTypeCode FROM tblGRStorageType GR WHERE intStorageScheduleTypeId = @intGRStorageId
	END

	SELECT
	intItemId = SCD.intItemId
	,intLocationId = ItemLocation.intItemLocationId 
	,intItemUOMId = ItemUOM.intItemUOMId
	,dtmDate = dbo.fnRemoveTimeOnDate(GETDATE())
	,dblQty = @dblNetUnits 
	,dblUOMQty = ItemUOM.dblUnitQty
	,dblCost = 0
	,dblSalesPrice = 0
	,intCurrencyId = SCD.intCurrencyId
	,dblExchangeRate = 1 -- TODO: Not yet implemented in PO. Default to 1 for now. 
	,intTransactionId = SCD.intDeliverySheetId
	,intTransactionDetailId =
	CASE 
		WHEN ISNULL(@intDPContractId,0) > 0 THEN @intDPContractId
		WHEN ISNULL(@intDPContractId,0) = 0 THEN NULL
	END
	,strTransactionId = SCD.strDeliverySheetNumber
	,intTransactionTypeId = 3 
	,intLotId = NULL 
	,intSubLocationId = NULL
	,intStorageLocationId = NULL
	,ysnIsStorage = 1
	,strSourceTransactionId  = @strDistributionOption
	FROM tblSCDeliverySheet SCD 
	INNER JOIN tblICItem IC ON IC.intItemId = SCD.intItemId
	INNER JOIN tblICItemUOM ItemUOM ON IC.intItemId = ItemUOM.intItemId
	INNER JOIN dbo.tblICItemLocation ItemLocation ON SCD.intItemId = ItemLocation.intItemId AND SCD.intCompanyLocationId = ItemLocation.intLocationId
	INNER JOIN dbo.tblICCommodity ICC ON ICC.intCommodityId = IC.intCommodityId
	WHERE SCD.intDeliverySheetId = @intDeliverySheetId AND ItemUOM.ysnStockUnit = 1
	
	CONTINUEISH:

	END

END TRY

BEGIN CATCH
BEGIN
	SELECT 
		@ErrorMessage = ERROR_MESSAGE(),
		@ErrorSeverity = ERROR_SEVERITY(),
		@ErrorState = ERROR_STATE();

	-- Use RAISERROR inside the CATCH block to return error
	-- information about the original error that caused
	-- execution to jump to the CATCH block.
	RAISERROR (
		@ErrorMessage, -- Message text.
		@ErrorSeverity, -- Severity.
		@ErrorState -- State.
	);
	END
END CATCH

GO