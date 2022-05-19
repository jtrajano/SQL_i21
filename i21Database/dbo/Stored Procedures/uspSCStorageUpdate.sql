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
DECLARE @intDirectType AS INT = 3
DECLARE @intCommodityUOMId INT
DECLARE @intCommodityUnitMeasureId INT
DECLARE @intTicketItemUOMId INT
DECLARE @intUnitMeasureId INT
DECLARE @strTransactionId NVARCHAR(40) = NULL
DECLARE @InventoryReceiptId AS INT
DECLARE @dblUnits AS DECIMAL (38,20)
DECLARE @intStorageEntityId AS INT
DECLARE @intStorageCommodityId AS INT
DECLARE @intStorageTypeId AS INT
DECLARE @intStorageLocationId AS INT
DECLARE @dblRunningBalance AS DECIMAL (13,3)
--DECLARE @strUserName AS NVARCHAR (50)
DECLARE @ysnDPStorage BIT
DECLARE @LineItems AS ScaleTransactionTableType
DECLARE @dblRemainingUnits AS DECIMAL (13,3)
DECLARE @intDefaultStorageSchedule AS INT
DECLARE @intCommodityId AS INT
DECLARE @matchStorageType AS INT
DECLARE @ysnIsStorage AS INT
DECLARE @strLotTracking NVARCHAR(4000)
DECLARE @dblAvailableGrainOpenBalance DECIMAL(38, 20)
DECLARE @intTicketType INT
DECLARE @strSeqMonth NVARCHAR (10)
DECLARE @dtmContractEndDate DATETIME
DECLARE @intTicketProcessingLocationId INT
DECLARE @intTicketCurrencyId INT
DECLARE @dblBasis NUMERIC(18,6)
DECLARE @dblFutures NUMERIC(18,6)
DECLARE @intTicketDeliverySheetId INT
DECLARE @intTicketItemUOMIdTo INT
DECLARE @intFutureMarketId INT
DECLARE @intFutureMonthId INT


DECLARE @ErrorMessage NVARCHAR(4000);
DECLARE @ErrorSeverity INT;
DECLARE @ErrorState INT;
DECLARE @PostShipment INT = 1;
DECLARE @total AS INT;

DECLARE @RoundOff AS INT = 4;

DECLARE @ItemsForItemShipment AS ItemCostingTableType
		,@ItemsForItemShipmentContract AS ItemCostingTableType
		,@CustomerStorageStagingTable AS CustomerStorageStagingTable
		,@InventoryShipmentId	INT
		,@ErrMsg				NVARCHAR(MAX)
        ,@dblBalance			NUMERIC(12,4)
        ,@intItemId				INT
        ,@dblNewBalance			NUMERIC(12,4)
        ,@strInOutFlag			NVARCHAR(4)
        ,@dblQuantity			NUMERIC(12,4)
        ,@strAdjustmentNo		NVARCHAR(50)
		,@strCostMethod			NVARCHAR(50)

BEGIN TRY

	SELECT @intDefaultStorageSchedule = SC.intStorageScheduleId
		, @intCommodityId = SC.intCommodityId
		, @intScaleStationId = SC.intScaleSetupId
		, @intItemId = SC.intItemId 
		, @intTicketType = CASE WHEN strInOutFlag = 'I' THEN 1 ELSE 2 END
		, @intTicketCurrencyId = intCurrencyId
		, @intTicketDeliverySheetId = ISNULL(intDeliverySheetId,0)
		, @intTicketItemUOMIdTo = intItemUOMIdTo
		, @intTicketProcessingLocationId = intProcessingLocationId
	FROM tblSCTicket SC
	WHERE SC.intTicketId = @intTicketId

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

	-- Get default futures market and month for the commodity
	EXEC uspSCGetDefaultFuturesMarketAndMonth @intCommodityId, @intFutureMarketId OUTPUT, @intFutureMonthId OUTPUT;

    BEGIN
	IF @strDistributionOption = 'CNT' OR @strDistributionOption = 'LOD'
		SET @ysnIsStorage = 0
	ELSE
		SET @ysnIsStorage = 1
	IF @dblNetUnits < 0
	BEGIN
		SET @PostShipment = 2
		IF ISNULL(@intDPContractId, 0) = 0
		BEGIN
			SELECT	@intCommodityUnitMeasureId = CommodityUOM.intUnitMeasureId
			FROM	dbo.tblSCTicket SC	        
					INNER JOIN dbo.tblICCommodityUnitMeasure CommodityUOM On SC.intCommodityId  = CommodityUOM.intCommodityId
			WHERE	SC.intTicketId = @intTicketId AND CommodityUOM.ysnStockUnit = 1	
				
			SELECT	@intCommodityUOMId = UM.intItemUOMId
			FROM dbo.tblICItemUOM UM	
			INNER JOIN tblSCTicket SC ON SC.intItemId = UM.intItemId  
			WHERE UM.intUnitMeasureId = @intCommodityUnitMeasureId AND SC.intTicketId = @intTicketId

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
			FROM vyuGRGetStorageTickets
			WHERE intEntityId = @intEntityId
				AND intItemId = @intItemId
				AND intCompanyLocationId = @intStorageLocationId
				AND intStorageTypeId = @intStorageTypeId
				AND ysnDPOwnedType = 0
			IF (@dblAvailableGrainOpenBalance > 0)
			BEGIN			  
				WHILE @dblAvailableGrainOpenBalance > 0
				BEGIN
					SELECT	intItemId = ScaleTicket.intItemId
							,intLocationId = ItemLocation.intItemLocationId 
							,intItemUOMId = ScaleTicket.intItemUOMIdTo
							,dtmDate = dbo.fnRemoveTimeOnDate(ScaleTicket.dtmTicketDateTime)
							,dblQty = CASE
										WHEN @dblUnits >= @dblAvailableGrainOpenBalance THEN @dblAvailableGrainOpenBalance
										ELSE @dblUnits
									END
							,dblUOMQty = ScaleTicket.dblConvertedUOMQty
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
							,ysnIsStorage = CASE WHEN GR.strOwnedPhysicalStock = 'Customer' THEN 1 ELSE 0 END
							,strSourceTransactionId = @strDistributionOption
							,intStorageScheduleTypeId = @intStorageTypeId
							,ysnAllowVoucher = 0
					FROM	dbo.tblSCTicket ScaleTicket
							INNER JOIN dbo.tblICItemLocation ItemLocation ON ItemLocation.intItemId = ScaleTicket.intItemId 
								AND ScaleTicket.intProcessingLocationId = ItemLocation.intLocationId
							OUTER APPLY(
								SELECT * FROM tblGRStorageType WHERE intStorageScheduleTypeId = @intStorageTypeId
							)GR
					WHERE	ScaleTicket.intTicketId = @intTicketId
					SET @dblAvailableGrainOpenBalance = @dblAvailableGrainOpenBalance-@dblUnits
					GOTO CONTINUEISH
				END
			END
			ELSE
				RETURN;
		END
		ELSE
		BEGIN 
			SET @dblNetUnits = @dblNetUnits * -1
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
							FROM dbo.fnRKGetFutureAndBasisPrice (2,ScaleTicket.intCommodityId,right(convert(varchar, CNT.dtmEndDate, 106),8),3,@intFutureMarketId,@intFutureMonthId,NULL,NULL,0,ScaleTicket.intItemId,ScaleTicket.intCurrencyId)
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
					,intStorageScheduleTypeId = @intGRStorageId
					,ysnAllowVoucher = 0
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
			RETURN
		END
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

	--CREATING OF CUSTOMER STORAGE
	INSERT INTO @CustomerStorageStagingTable(
		[strTransactionNumber]
		,[intEntityId]
		,[intItemId]
		,[intCommodityId]
		,[intCompanyLocationId]
		,[intCompanyLocationSubLocationId]
		,[intStorageLocationId]
		,[dblQuantity]
		,[intStorageTypeId]
		,[intStorageScheduleId]
		,[intDiscountScheduleId]
		,[dtmDeliveryDate]
		,[dblFreightDueRate]
		,[dblFeesDue]
		,[intDeliverySheetId]
		,[intTicketId]
		,[intContractHeaderId]
		,[intContractDetailId]
		,[intUnitMeasureId]						
		,[intItemUOMId]
		,[intCurrencyId]
		,[intUserId]
		,[dblGrossQuantity]
	)
	SELECT 
		[strTransactionNumber]					= CASE WHEN ISNULL(SC.intDeliverySheetId,0) > 0 THEN SC.strDeliverySheetNumber ELSE SC.strTicketNumber END
		,[intEntityId]							= @intEntityId
		,[intItemId]							= SC.intItemId
		,[intCommodityId]						= SC.intCommodityId
		,[intCompanyLocationId]					= SC.intProcessingLocationId
		,[intCompanyLocationSubLocationId]		= SC.intSubLocationId
		,[intStorageLocationId]					= SC.intStorageLocationId
		,[dblQuantity]							= @dblNetUnits
		,[intStorageTypeId]						= @intGRStorageId
		,[intStorageScheduleId]					= @intDefaultStorageSchedule
		,[intDiscountScheduleId]				= SC.intDiscountSchedule
		,[dtmDeliveryDate]						= dbo.fnRemoveTimeOnDate(SC.dtmTicketDateTime)
		,[dblFreightDueRate]					= 0
		,[dblFeesDue]							= CASE WHEN ICFees.strCostMethod = 'Amount' THEN ROUND(SC.dblTicketFees / SC.dblNetUnits ,6) ELSE SC.dblTicketFees END
		,[intDeliverySheetId]					= SC.intDeliverySheetId
		,[intTicketId]							= SC.intTicketId
		,[intContractHeaderId]					= case when @intDPContractId is null then  CT.intContractHeaderId else fp.intContractHeaderId end
		,[intContractDetailId]					= case when @intDPContractId is null then  SC.intContractId else fp.intContractDetailId end
		,[intUnitMeasureId]						= UOM.intUnitMeasureId
		,[intItemUOMId]							= SC.intItemUOMIdTo
		,[intCurrencyId]						= SC.intCurrencyId
		,[intUserId]							= @intUserId
		,[dblGrossQuantity]						= (@dblNetUnits / SC.dblNetUnits) * SC.dblGrossUnits
	FROM vyuSCTicketScreenView SC
	INNER JOIN tblSCScaleSetup SCSetup ON SCSetup.intScaleSetupId = SC.intScaleSetupId
	LEFT JOIN tblICItem ICFees ON ICFees.intItemId = SCSetup.intDefaultFeeItemId
	LEFT JOIN tblICItemUOM UOM ON UOM.intItemId = SC.intItemId AND UOM.intItemUOMId = SC.intItemUOMIdTo
	LEFT JOIN tblCTContractDetail CT ON CT.intContractDetailId = SC.intContractId
	OUTER APPLY (select intContractDetailId, intContractHeaderId from tblCTContractDetail where intContractDetailId = isnull(@intDPContractId, 0)) fp
	WHERE SC.intTicketId = @intTicketId

	EXEC uspGRCreateCustomerStorage @CustomerStorageStagingTable, @intHoldCustomerStorageId OUTPUT

	IF(ISNULL(@intTicketDeliverySheetId,0) = 0)
	BEGIN
		UPDATE tblGRCustomerStorage
		SET intTicketId = @intTicketId
		WHERE intCustomerStorageId = @intHoldCustomerStorageId
	END

	IF EXISTS(SELECT * FROM @CustomerStorageStagingTable WHERE ISNULL(intDeliverySheetId,0) > 0)
	BEGIN
		DECLARE @intId INT
				,@finalGrossWeight NUMERIC (38,20)
				,@wsGrossShrinkWeight NUMERIC (38,20)
				,@wsWetShrinkWeight NUMERIC (38,20)
				,@wsNetShrinkWeight NUMERIC (38,20)
				,@wetWeight NUMERIC (38,20)
				,@wsWetWeight NUMERIC (38,20)
				,@totalWetShrink NUMERIC (38,20)
				,@totalNetShrink NUMERIC (38,20)
				,@totalShrinkPrice NUMERIC (38,20)
				,@dblShrinkPercent NUMERIC(38,20)
				,@finalShrinkUnits NUMERIC(38,20)
				,@strShrinkWhat NVARCHAR(40)
				,@dblTotalFees NUMERIC(38,20);

		DECLARE @CalculatedDiscount TABLE
		(
			[intExtendedKey] INT
			,[dblFrom] NUMERIC(38, 20) NULL
			,[dblTo] NUMERIC(38, 20) NULL
			,[dblDiscountAmount] NUMERIC(38, 20) NULL
			,[dblShrink] NUMERIC(38, 20) NULL
			,[strMessage] NVARCHAR(40)
			,[intDiscountCalculationOptionId] INT NULL
			,[strCalculationDiscountOption] NVARCHAR(40)
			,[strDiscountChargeType] NVARCHAR(40)
			,[intShrinkCalculationOptionId] INT NULL
			,[strCalculationShrinkOption] NVARCHAR(40)
			,[intDiscountUOMId] INT NULL
			,[intDeliverySheetId] INT NULL
			,[intDiscountScheduleCodeId] INT NULL
		)

		DELETE FROM @CalculatedDiscount

		INSERT INTO @CalculatedDiscount(
			[intExtendedKey]
			,[dblFrom]
			,[dblTo]
			,[dblDiscountAmount]
			,[dblShrink]
			,[strMessage]
			,[intDiscountCalculationOptionId]
			,[strCalculationDiscountOption]
			,[strDiscountChargeType]
			,[intShrinkCalculationOptionId]
			,[strCalculationShrinkOption]
			,[intDiscountUOMId]
			,[intDeliverySheetId]
			,[intDiscountScheduleCodeId]
		)
		SELECT 
			[intExtendedKey]						= Discount.intExtendedKey
			,[dblFrom]								= Discount.dblFrom
			,[dblTo]								= Discount.dblTo
			,[dblDiscountAmount]					= Discount.dblDiscountAmount
			,[dblShrink]							= Discount.dblShrink
			,[strMessage]							= Discount.strMessage
			,[intDiscountCalculationOptionId]		= Discount.intDiscountCalculationOptionId
			,[strCalculationDiscountOption]			= Discount.strCalculationDiscountOption
			,[strDiscountChargeType]				= Discount.strDiscountChargeType
			,[intShrinkCalculationOptionId]			= Discount.intShrinkCalculationOptionId
			,[strCalculationShrinkOption]			= Discount.strCalculationShrinkOption
			,[intDiscountUOMId] 					= Discount.intDiscountUOMId
			,[intDeliverySheetId]					= CS.intDeliverySheetId
			,[intDiscountScheduleCodeId]			= QM.intDiscountScheduleCodeId
		FROM @CustomerStorageStagingTable CS
		LEFT JOIN tblQMTicketDiscount QM ON QM.intTicketFileId = CS.intDeliverySheetId AND QM.strSourceType = 'Delivery Sheet'
		LEFT JOIN tblGRDiscountScheduleCode GR ON GR.intDiscountScheduleCodeId = QM.intDiscountScheduleCodeId
		OUTER APPLY (
			SELECT * FROM dbo.fnGRCalculateDiscountandShrink(QM.intDiscountScheduleCodeId, QM.dblGradeReading , 0, GR.intItemId)
		) Discount
		
		SELECT @finalGrossWeight = (SCD.dblGross + CS.dblQuantity) FROM tblSCDeliverySheet SCD
		INNER JOIN @CustomerStorageStagingTable CS ON CS.intDeliverySheetId = SCD.intDeliverySheetId

		SELECT @intId = MIN(intDiscountScheduleCodeId) FROM @CalculatedDiscount WHERE intDiscountScheduleCodeId > 0
		WHILE ISNULL(@intId,0) > 0
		BEGIN
			SELECT @strShrinkWhat = strCalculationShrinkOption, @dblShrinkPercent = dblShrink FROM @CalculatedDiscount WHERE intDiscountScheduleCodeId = @intId
			IF @strShrinkWhat = 'Wet Weight'
                SET @totalWetShrink = ISNULL(@totalWetShrink,0) + @dblShrinkPercent;
            ELSE IF @strShrinkWhat = 'Net Weight'
                SET @totalNetShrink = ISNULL(@totalNetShrink,0) + @dblShrinkPercent
            ELSE IF @strShrinkWhat = 'Gross Weight'
                SET @totalShrinkPrice = ISNULL(@totalShrinkPrice,0) + @dblShrinkPercent;
			SELECT @intId = MIN(intDiscountScheduleCodeId) FROM @CalculatedDiscount WHERE intDiscountScheduleCodeId > @intId
		END

		SET @wsGrossShrinkWeight = round(     (ISNULL(@finalGrossWeight, 0) * ISNULL(@totalShrinkPrice, 0)) / 100,     @RoundOff)
        SET @wetWeight = (@finalGrossWeight - @wsGrossShrinkWeight)
        SET @wsWetShrinkWeight = round(     (ISNULL(@wetWeight, 0) * ISNULL(@totalWetShrink, 0) ) / 100,     @RoundOff)
        SET @wsWetWeight = (@wetWeight - @wsWetShrinkWeight)
        SET @wsNetShrinkWeight = round(     (ISNULL(@wsWetWeight, 0) * ISNULL(@totalNetShrink, 0)) / 100,     @RoundOff)
        SET @finalShrinkUnits = (@wsGrossShrinkWeight + @wsWetShrinkWeight + @wsNetShrinkWeight)

		UPDATE SCD SET SCD.dblGross = @finalGrossWeight, SCD.dblShrink = @finalShrinkUnits , SCD.dblNet = (@finalGrossWeight - @finalShrinkUnits)
		FROM tblSCDeliverySheet SCD
		INNER JOIN @CustomerStorageStagingTable CS ON CS.intDeliverySheetId = SCD.intDeliverySheetId
		WHERE CS.intTicketId = @intTicketId AND ISNULL(CS.intDeliverySheetId, 0) > 0
	END

	IF @intGRStorageId > 0
	BEGIN
		SELECT @strDistributionOption = GR.strStorageTypeCode FROM tblGRStorageType GR WHERE intStorageScheduleTypeId = @intGRStorageId
	END

	SELECT	
		@dtmContractEndDate = dtmEndDate
	FROM tblCTContractDetail 
	WHERE intContractDetailId = ISNULL(@intDPContractId,0)

	SELECT TOP 1
		@dblFutures = dbo.fnCTConvertQtyToTargetItemUOM(@intTicketItemUOMIdTo,futureUOM.intItemUOMId,dblSettlementPrice) 
		,@dblBasis = dbo.fnCTConvertQtyToTargetItemUOM(@intTicketItemUOMIdTo,basisUOM.intItemUOMId,dblBasis)
	FROM dbo.fnRKGetFutureAndBasisPrice (1,@intCommodityId,right(convert(varchar, @dtmContractEndDate, 106),8),3,@intFutureMarketId,@intFutureMonthId,@intTicketProcessingLocationId,NULL,0,@intItemId,@intTicketCurrencyId)
	LEFT JOIN tblICItemUOM futureUOM ON futureUOM.intUnitMeasureId = intSettlementUOMId AND futureUOM.intItemId = @intItemId
	LEFT JOIN tblICItemUOM basisUOM ON basisUOM.intUnitMeasureId = intBasisUOMId AND basisUOM.intItemId = @intItemId


	--IF(ISNULL(@intTicketDeliverySheetId,0) > 0)
	BEGIN
		IF EXISTS (SELECT TOP 1 1 FROM tblGRCustomerStorage 
					WHERE intCustomerStorageId = @intHoldCustomerStorageId 
						AND ISNULL(dblBasis,0) = 0 
						AND ISNULL(dblSettlementPrice,0) = 0)
			AND ISNULL(@intDPContractId,0) > 0
		BEGIN
			UPDATE tblGRCustomerStorage
			SET dblBasis = ISNULL(@dblBasis,0)
				,dblSettlementPrice = ISNULL(@dblFutures,0)
			WHERE intCustomerStorageId = @intHoldCustomerStorageId
		END
		ELSE
		BEGIN
			SELECT TOP 1 
				@dblBasis = dblBasis
				,@dblFutures = dblSettlementPrice
			FROM tblGRCustomerStorage
			WHERE intCustomerStorageId = @intHoldCustomerStorageId
		END
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
					(ISNULL(@dblFutures,0) + ISNULL(@dblBasis,0)),0
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
			,intStorageScheduleTypeId = @intGRStorageId
			,ysnAllowVoucher = 0
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
