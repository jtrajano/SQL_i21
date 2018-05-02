CREATE PROCEDURE [dbo].[uspSCStorageUpdate]
	 @intTicketId AS INT
	,@intUserId AS INT
	,@dblNetUnits AS DECIMAL (38,20)
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
DECLARE @intUnitMeasureId INT
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
	
	SELECT @intDefaultStorageSchedule = TIC.intStorageScheduleId, @intCommodityId = TIC.intCommodityId,
	@intScaleStationId = TIC.intScaleSetupId, @intItemId = TIC.intItemId FROM tblSCTicket TIC
	WHERE TIC.intTicketId = @intTicketId

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
	IF @strDistributionOption = 'CNT' OR @strDistributionOption = 'LOD'
		SET @ysnIsStorage = 0
	ELSE
		SET @ysnIsStorage = 1
	IF @dblNetUnits < 0
	BEGIN
		SET @PostShipment = 2
		BEGIN 
			SELECT	@intCommodityUnitMeasureId = CommodityUOM.intUnitMeasureId
			FROM	dbo.tblSCTicket SC	        
					INNER JOIN dbo.tblICCommodityUnitMeasure CommodityUOM On SC.intCommodityId  = CommodityUOM.intCommodityId
			WHERE	SC.intTicketId = @intTicketId AND CommodityUOM.ysnStockUnit = 1		
		END
		BEGIN 
			SELECT	@intCommodityUOMId = UM.intItemUOMId
				FROM dbo.tblICItemUOM UM	
				  JOIN tblSCTicket SC ON SC.intItemId = UM.intItemId  
			WHERE UM.intUnitMeasureId = @intCommodityUnitMeasureId AND SC.intTicketId = @intTicketId
		END
		IF @intCommodityUOMId IS NULL 
		BEGIN 			
			RAISERROR('The stock UOM of the commodity must exist in the conversion table of the item', 16, 1);
			RETURN;
		END

		SET @dblUnits = @dblNetUnits * -1
		SELECT @intStorageEntityId = SC.intEntityId, @intStorageCommodityId = SC.intCommodityId,
		@intStorageLocationId =  SC.intProcessingLocationId , @intItemId = SC.intItemId
		FROM dbo.tblSCTicket SC
		WHERE SC.intTicketId = @intTicketId

		SELECT  @intTicketItemUOMId = ItemUOM.intItemUOMId
		FROM    dbo.tblICItemUOM ItemUOM
		WHERE   ItemUOM.intItemId = @intItemId AND ItemUOM.ysnStockUnit = 1

		SELECT @intStorageTypeId = ST.intStorageScheduleTypeId
		FROM dbo.tblGRStorageType ST
		WHERE ST.strStorageTypeCode = @strDistributionOption
		
		IF ISNULL(@intStorageTypeId,0) <= 0 
		BEGIN
	   		SELECT	@intStorageTypeId = ST.intDefaultStorageTypeId
			FROM	dbo.tblSCScaleSetup ST	        
			WHERE	ST.intScaleSetupId = @intScaleStationId
		END

		SELECT @dblAvailableGrainOpenBalance = SUM(dblOpenBalance)
		FROM vyuGRGetStorageTransferTicket
		WHERE intEntityId = @intEntityId
			AND intItemId = @intItemId
			AND intCompanyLocationId = @intStorageLocationId
			AND intStorageTypeId = @intStorageTypeId
			AND ysnDPOwnedType = 0
			AND ysnCustomerStorage = 0
		IF (@dblAvailableGrainOpenBalance > 0)
		BEGIN			  
			WHILE @dblAvailableGrainOpenBalance > 0
			BEGIN
				SELECT	intItemId = ScaleTicket.intItemId
						,intLocationId = ItemLocation.intItemLocationId 
						,intItemUOMId = ItemUOM.intItemUOMId
						,dtmDate = dbo.fnRemoveTimeOnDate(ScaleTicket.dtmTicketDateTime)
						,dblQty = CASE
									WHEN @dblUnits >= @dblAvailableGrainOpenBalance THEN @dblAvailableGrainOpenBalance
									ELSE @dblUnits
								END
						,dblUOMQty = ItemUOM.dblUnitQty
						,dblCost = 0
						,dblSalesPrice = 0
						,intCurrencyId = ScaleTicket.intCurrencyId
						,dblExchangeRate = 1 -- TODO: Not yet implemented in PO. Default to 1 for now. 
						,intTransactionId = ScaleTicket.intTicketId
						,intTransactionDetailId = NULL
						,strTransactionId = ScaleTicket.strTicketNumber
						,intTransactionTypeId = @intDirectType 
						,intLotId = NULL 
						,intSubLocationId = ScaleTicket.intSubLocationId
						,intStorageLocationId = ScaleTicket.intStorageLocationId
						,ysnIsStorage = 1
						,intStorageScheduleTypeId = @intStorageTypeId
				FROM	dbo.tblSCTicket ScaleTicket
						INNER JOIN dbo.tblICItemUOM ItemUOM ON ScaleTicket.intItemId = ItemUOM.intItemId
						INNER JOIN dbo.tblICItemLocation ItemLocation ON ScaleTicket.intItemId = ItemLocation.intItemId 
						AND ScaleTicket.intProcessingLocationId = ItemLocation.intLocationId
				WHERE	ScaleTicket.intTicketId = @intTicketId AND ItemUOM.ysnStockUnit = 1
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

	
	SELECT	@intCommodityUnitMeasureId = CommodityUOM.intUnitMeasureId
	FROM	dbo.tblSCTicket SC	        
	JOIN dbo.tblICCommodityUnitMeasure CommodityUOM On SC.intCommodityId  = CommodityUOM.intCommodityId
	WHERE	SC.intTicketId = @intTicketId AND CommodityUOM.ysnStockUnit = 1
	
	SELECT	@intCommodityUOMId = UM.intItemUOMId
	FROM dbo.tblICItemUOM UM	
	JOIN tblSCTicket SC ON SC.intItemId = UM.intItemId  
	WHERE UM.intUnitMeasureId = @intCommodityUnitMeasureId AND SC.intTicketId = @intTicketId

	IF @intCommodityUOMId IS NULL 
	BEGIN		
		RAISERROR('The stock UOM of the commodity must exist in the conversion table of the item', 16, 1);
		RETURN;
	END
	
	SELECT  @intTicketItemUOMId = ItemUOM.intItemUOMId ,@intUnitMeasureId = ItemUOM.intUnitMeasureId
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
	           ,[intTicketId]
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
	SELECT 	[intConcurrencyId]		= 1
			,[intEntityId]			= @intEntityId
			,[intCommodityId]		= SC.intCommodityId
			,[intStorageScheduleId]	= @intDefaultStorageSchedule -- TODO Storage Schedule
			,[intStorageTypeId]		= @intGRStorageId
			,[intCompanyLocationId]= SC.intProcessingLocationId
			,[intTicketId]= SC.intTicketId
			,[intDiscountScheduleId]= SC.intDiscountSchedule
			,[dblTotalPriceShrink]= 0
			,[dblTotalWeightShrink]= 0 
			,[dblOriginalBalance]= @dblNetUnits
			,[dblOpenBalance]= @dblNetUnits
			,[dtmDeliveryDate]= SC.dtmTicketDateTime
			,[dtmZeroBalanceDate]= NULL
			,[strDPARecieptNumber]= NULL
			,[dtmLastStorageAccrueDate]= NULL 
			,[dblStorageDue]= 0 
			,[dblStoragePaid]= 0
			,[dblInsuranceRate]= 0 
			,[strOriginState]= NULL 
			,[strInsuranceState]= NULL
			,[dblFeesDue]=ROUND(SC.dblTicketFees,6) 
			,[dblFeesPaid]= 0 
			,[dblFreightDueRate]= 0 
			,[ysnPrinted]= 0 
			,[dblCurrencyRate]= 1
			,[intCurrencyId] = SC.intCurrencyId
			,[intStorageTicketNumber] = SC.strTicketNumber
			,SC.[intItemId]
			,SC.[intSubLocationId]
			,SC.[intStorageLocationId]
			,@intUnitMeasureId
			,@intTicketItemUOMId
	FROM	dbo.tblSCTicket SC
	WHERE	SC.intTicketId = @intTicketId

	SELECT @intCustomerStorageId = SCOPE_IDENTITY()
	
	IF @intCustomerStorageId IS NULL 
	BEGIN
		RAISERROR('Unable to get Identity value from Customer Storage', 16, 1);
		RETURN;
	END

	INSERT INTO [dbo].[tblGRStorageHistory]
		   ([intConcurrencyId]
		   ,[intCustomerStorageId]
		   ,[intTicketId]
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
		   ,@intTicketId
		   ,NULL
		   ,NULL
		   ,@intContractHeaderId
		   ,@dblNetUnits
		   ,dbo.fnRemoveTimeOnDate((SELECT dtmTicketDateTime FROM tblSCTicket WHERE intTicketId = @intTicketId))
		   ,0
		   ,'Generated From Scale'
		   ,1
		   ,'From Scale'
		   ,@strUserName
		   ,1)
	
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
			[intConcurrencyId]			= 1       
           ,[dblGradeReading]			= SD.[dblGradeReading]
           ,[strCalcMethod]				= SD.[strCalcMethod]
           ,[strShrinkWhat]				= SD.[strShrinkWhat]			
           ,[dblShrinkPercent]			= CASE WHEN ISNULL(DCode.intUnitMeasureId,0) = 0 THEN SD.[dblShrinkPercent]  ELSE dbo.fnCTConvertQuantityToTargetItemUOM(@intItemId,@intUnitMeasureId,DCode.intUnitMeasureId,SD.[dblShrinkPercent])  END
           ,[dblDiscountAmount]			= CASE WHEN ISNULL(DCode.intUnitMeasureId,0) = 0 THEN SD.[dblDiscountAmount] ELSE dbo.fnCTConvertQuantityToTargetItemUOM(@intItemId,@intUnitMeasureId,DCode.intUnitMeasureId,SD.[dblDiscountAmount]) END
           ,[dblDiscountDue]			= CASE WHEN ISNULL(DCode.intUnitMeasureId,0) = 0 THEN SD.[dblDiscountAmount] ELSE dbo.fnCTConvertQuantityToTargetItemUOM(@intItemId,@intUnitMeasureId,DCode.intUnitMeasureId,SD.[dblDiscountAmount]) END
           ,[dblDiscountPaid]			= ISNULL(SD.[dblDiscountPaid],0)
           ,[ysnGraderAutoEntry]		= SD.[ysnGraderAutoEntry]
           ,[intDiscountScheduleCodeId] = SD.[intDiscountScheduleCodeId]
           ,[dtmDiscountPaidDate]		= SD.[dtmDiscountPaidDate]
           ,[intTicketId]				= NULL
           ,[intTicketFileId]			= @intCustomerStorageId
           ,[strSourceType]				= 'Storage'
		   ,[intSort]					= SD.[intSort]
		   ,[strDiscountChargeType]		= SD.[strDiscountChargeType]
		FROM	  dbo.[tblQMTicketDiscount] SD
		JOIN      tblGRDiscountScheduleCode DCode ON DCode.intDiscountScheduleCodeId = SD.intDiscountScheduleCodeId
		LEFT JOIN tblICUnitMeasure UOM ON UOM.intUnitMeasureId = DCode.intUnitMeasureId
		WHERE	SD.intTicketId = @intTicketId AND SD.strSourceType = 'Scale'
		
		UPDATE CS
		SET  CS.dblDiscountsDue=QM.dblDiscountsDue
			,CS.dblDiscountsPaid=QM.dblDiscountsPaid
		FROM tblGRCustomerStorage CS
		JOIN (SELECT intTicketFileId,SUM(dblDiscountDue) dblDiscountsDue ,SUM(dblDiscountPaid)dblDiscountsPaid FROM dbo.[tblQMTicketDiscount] WHERE intTicketFileId = @intCustomerStorageId AND strSourceType = 'Storage' GROUP BY intTicketFileId)QM
		ON CS.intCustomerStorageId=QM.intTicketFileId

	END
	
	IF @intGRStorageId > 0
	 BEGIN
			SELECT @strDistributionOption = GR.strStorageTypeCode FROM tblGRStorageType GR WHERE intStorageScheduleTypeId = @intGRStorageId
		END

		SELECT intItemId = ScaleTicket.intItemId
				,intLocationId = ItemLocation.intItemLocationId 
				,intItemUOMId = ItemUOM.intItemUOMId
				,dtmDate = dbo.fnRemoveTimeOnDate(GETDATE())
				,dblQty = @dblNetUnits 
				,dblUOMQty = ItemUOM.dblUnitQty
				,dblCost = 
				CASE 
					WHEN ISNULL(@intDPContractId,0) > 0 THEN 
					ISNULL(
						(SELECT dbo.fnCTConvertQtyToTargetItemUOM(ScaleTicket.intItemUOMIdTo,futureUOM.intItemUOMId,dblSettlementPrice) + dbo.fnCTConvertQtyToTargetItemUOM(ScaleTicket.intItemUOMIdTo,basisUOM.intItemUOMId,dblBasis)
						FROM dbo.fnRKGetFutureAndBasisPrice (1,ScaleTicket.intCommodityId,right(convert(varchar, CNT.dtmEndDate, 106),8),3,NULL,NULL,NULL,NULL,0,ScaleTicket.intItemId)
						LEFT JOIN tblICItemUOM futureUOM ON futureUOM.intUnitMeasureId = intSettlementUOMId AND futureUOM.intItemId = ScaleTicket.intItemId
						LEFT JOIN tblICItemUOM basisUOM ON basisUOM.intUnitMeasureId = intBasisUOMId AND basisUOM.intItemId = ScaleTicket.intItemId),0
					)
					WHEN ISNULL(@intDPContractId,0) = 0 THEN 0
				END
				
				,dblSalesPrice = 0
				,intCurrencyId = ScaleTicket.intCurrencyId
				,dblExchangeRate = 1 -- TODO: Not yet implemented in PO. Default to 1 for now. 
				,intTransactionId = ScaleTicket.intTicketId
				,intTransactionDetailId =
				CASE 
					WHEN ISNULL(@intDPContractId,0) > 0 THEN @intDPContractId
					WHEN ISNULL(@intDPContractId,0) = 0 THEN NULL
				END
				,strTransactionId = ScaleTicket.strTicketNumber
				,intTransactionTypeId = @intDirectType 
				,intLotId = NULL 
				,intSubLocationId = ScaleTicket.intSubLocationId
				,intStorageLocationId = ScaleTicket.intStorageLocationId
				,ysnIsStorage = 
				CASE 
					WHEN ISNULL(@intDPContractId,0) > 0 THEN 0
					WHEN ISNULL(@intDPContractId,0) = 0 THEN 
					CASE 
						WHEN ISNULL(GR.strOwnedPhysicalStock, 'Company') = 'Customer' THEN 1
						ELSE 0
					END
				END
				,strSourceTransactionId  = @strDistributionOption
		FROM	dbo.tblSCTicket ScaleTicket
				INNER JOIN tblICItemUOM ItemUOM ON ScaleTicket.intItemId = ItemUOM.intItemId
				INNER JOIN tblICItemLocation ItemLocation ON ScaleTicket.intItemId = ItemLocation.intItemId AND ScaleTicket.intProcessingLocationId = ItemLocation.intLocationId
				LEFT JOIN tblICCommodity IC ON IC.intCommodityId = ScaleTicket.intCommodityId
				OUTER APPLY(
					SELECT dtmEndDate,intContractDetailId,intContractHeaderId FROM tblCTContractDetail WHERE intContractDetailId = ISNULL(@intDPContractId,0)
				) CNT
				OUTER APPLY(
					SELECT strOwnedPhysicalStock FROM tblGRStorageType WHERE strStorageTypeCode = @strDistributionOption
				) GR
		WHERE	ScaleTicket.intTicketId = @intTicketId AND ItemUOM.ysnStockUnit = 1
	
	CONTINUEISH:

	--IF @PostShipment = 2
	--	BEGIN			
	--		EXEC dbo.uspICValidateProcessToInventoryShipment @ItemsForItemShipment; 
			
	--		IF @strSourceType = @SALES_ORDER
	--		BEGIN 
	--			EXEC dbo.uspSCAddScaleTicketToItemShipment 
	--				  @intTicketId
	--				 ,@intUserId
	--				 ,@ItemsForItemShipment
	--				 ,@intEntityId
	--				 ,4
	--				 ,@InventoryShipmentId OUTPUT;
	--		END
	--		BEGIN 
	--		SELECT	@strTransactionId = ship.strShipmentNumber
	--		FROM	dbo.tblICInventoryShipment ship	        
	--		WHERE	ship.intInventoryShipmentId = @InventoryShipmentId		
	--		END
	--		SELECT @strLotTracking = strLotTracking FROM tblICItem WHERE intItemId = @intItemId
	--		IF @strLotTracking = 'No'
	--		BEGIN
	--			EXEC dbo.uspICPostInventoryShipment 1, 0, @strTransactionId, @intUserId;
	--		END
		
	--	END
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