CREATE PROCEDURE [dbo].[uspGRCalculateSettleStorageFeeForContract]
	@intParentSettleStorageId INT
AS
BEGIN TRY
	SET NOCOUNT ON

	DECLARE @ErrMsg NVARCHAR(MAX)
	DECLARE @voucherDetailStorage AS [VoucherDetailStorage]
	DECLARE @VoucherDetailReceiptCharge as [VoucherDetailReceiptCharge]
	DECLARE @EntityId INT
	DECLARE @LocationId INT
	DECLARE @ItemId INT
	DECLARE @strItemNo NVARCHAR(20)
	DECLARE @intUnitMeasureId INT
	DECLARE @CommodityStockUomId INT
	DECLARE @TicketNo NVARCHAR(20)
	DECLARE @intCreatedUserId INT
	DECLARE @ItemLocationId INT
	DECLARE @SettleStorageKey INT
	DECLARE @intSettleStorageTicketId INT
	DECLARE @intCustomerStorageId INT
	DECLARE @dblStorageUnits DECIMAL(24, 10)
	DECLARE @intCompanyLocationId INT
	DECLARE @DPContractHeaderId INT
	DECLARE @ContractDetailId INT
	DECLARE @SettleContractKey INT
	DECLARE @intContractDetailId INT
	DECLARE @intContractHeaderId INT
	DECLARE @dblContractUnits DECIMAL(24, 10)
	DECLARE @dblUnitsForContract DECIMAL(24, 10)
	DECLARE @dblCashPrice DECIMAL(24, 10)
	DECLARE @dblSpotUnits DECIMAL(24, 10)
	DECLARE @dblSpotCashPrice DECIMAL(24, 10)
	DECLARE @strStorageAdjustment NVARCHAR(50)
	DECLARE @dtmCalculateStorageThrough DATETIME
	DECLARE @dblAdjustPerUnit DECIMAL(24, 10)
	DECLARE @strProcessType NVARCHAR(30)
	DECLARE @strUpdateType NVARCHAR(30)
	DECLARE @IntCommodityId INT
	DECLARE @intStorageChargeItemId INT
	DECLARE @StorageChargeItemDescription NVARCHAR(100)
	DECLARE @dblStorageDuePerUnit DECIMAL(24, 10)
	DECLARE @dblStorageDueAmount DECIMAL(24, 10)
	DECLARE @dblStorageDueTotalPerUnit DECIMAL(24, 10)
	DECLARE @dblStorageDueTotalAmount DECIMAL(24, 10)
	DECLARE @dblStorageBilledPerUnit DECIMAL(24, 10)
	DECLARE @dblStorageBilledAmount DECIMAL(24, 10)
	DECLARE @dblFlatFeeTotal		DECIMAL(24, 10)
	DECLARE @dblTicketStorageDue DECIMAL(24, 10)
	DECLARE @intCurrencyId INT
	DECLARE @dblUOMQty NUMERIC(38, 20)
	DECLARE @intInventoryItemStockUOMId INT
	DECLARE @dtmDate AS DATETIME
	DECLARE @intCreatedBillId AS INT
	DECLARE @intPricingTypeId INT
	DECLARE @dblUnits DECIMAL(24, 10)
	DECLARE @dblCost DECIMAL(24, 10)
	DECLARE @intFutureMarketId INT
	DECLARE @dblFutureMarkePrice DECIMAL(24, 10)
	DECLARE @dblContractBasis DECIMAL(24, 10)
	DECLARE @intSettleStorageId INT
	--DECLARE @intParentSettleStorageId INT
	DECLARE @intDecimalPrecision INT 
	--UOM for Spot Settle Storage 
	DECLARE @intCashPriceUOMId INT
	--Cost UOM in contract
	DECLARE @intContractUOMId INT
	DECLARE @dblCostUnitQty DECIMAL(24, 10)
	DECLARE @ysnExchangeTraded BIT
	--get the original value of Spot Units before settlement
	DECLARE @origdblSpotUnits DECIMAL(24, 10) 

	DECLARE @intShipFrom INT
	DECLARE @shipFromEntityId INT	
	DECLARE @strCommodityCode NVARCHAR(50)

	DECLARE @voucherPayable VoucherPayable
	DECLARE @voucherPayableTax VoucherDetailTax
	DECLARE @createdVouchersId NVARCHAR(MAX)
	DECLARE @ysnDPOwnedType AS BIT

	DECLARE @SettleStorage AS TABLE 
	(
		 intSettleStorageKey INT IDENTITY(1, 1)
		,intSettleStorageTicketId INT
		,intCustomerStorageId INT
		,dblStorageUnits DECIMAL(24, 10)
		,dblRemainingUnits DECIMAL(24, 10)
		,dblOpenBalance DECIMAL(24, 10)
		,strStorageTicketNumber NVARCHAR(40) COLLATE Latin1_General_CI_AS NULL
		,intCompanyLocationId INT
		,intStorageTypeId INT
		,intStorageScheduleId INT
		,intContractHeaderId INT
	)
	
	DECLARE @SettleContract AS TABLE 
	(
		 intSettleContractKey INT IDENTITY(1, 1)
		,intSettleContractId INT
		,intContractDetailId INT
		,dblContractUnits DECIMAL(24, 10)
		,ContractEntityId INT
		,dblCashPrice DECIMAL(24, 10)
		,intPricingTypeId INT
		,dblBasis DECIMAL(24, 10)
		,intContractUOMId INT
		,dblCostUnitQty DECIMAL(24, 10)
		,strPricingType NVARCHAR(40) COLLATE Latin1_General_CI_AS NULL
	)
	
	DECLARE @tblDepletion AS TABLE 
	(
		 intDepletionKey INT IDENTITY(1, 1)
		,strDepletionType NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
		,intSettleStorageTicketId INT
		,intPricingTypeId INT
		,intContractHeaderId INT
		,intContractDetailId INT
		,intCustomerStorageId INT
		,dblUnits DECIMAL(24, 10)
		,intSourceItemUOMId INT
		,dblCost DECIMAL(24, 10)
	)
	
	DECLARE @SettleVoucherCreate AS SettleVoucherCreate

	SELECT @intDecimalPrecision = intCurrencyDecimal FROM tblSMCompanyPreference

	SET @dtmDate = GETDATE()
	--SET @intParentSettleStorageId = @intSettleStorageId	
	
	SELECT @intSettleStorageId = MIN(intSettleStorageId)
	FROM tblGRSettleStorage
	WHERE intParentSettleStorageId = @intParentSettleStorageId

	WHILE @intSettleStorageId > 0
	BEGIN		
		DELETE FROM @SettleStorage
		DELETE FROM @SettleContract
		DELETE FROM @tblDepletion
		DELETE FROM @SettleVoucherCreate

		SELECT 
			@intCreatedUserId 				= intCreatedUserId
			,@EntityId 						= intEntityId
			,@LocationId 					= intCompanyLocationId
			,@ItemId 						= intItemId
			,@TicketNo 						= strStorageTicket
			,@strStorageAdjustment 			= strStorageAdjustment
			,@dtmCalculateStorageThrough 	= dtmCalculateStorageThrough
			,@dblAdjustPerUnit 				= dblAdjustPerUnit
			,@dblSpotUnits 					= dblSpotUnits
			,@dblSpotCashPrice 				= dblCashPrice
			,@IntCommodityId 				= intCommodityId
			,@CommodityStockUomId 			= intCommodityStockUomId
			,@intCashPriceUOMId 			= intItemUOMId
			,@origdblSpotUnits				= dblSpotUnits
		FROM tblGRSettleStorage
		WHERE intSettleStorageId = @intSettleStorageId
	
		SELECT
			@intFutureMarketId 	= ISNULL(Com.intFutureMarketId,0)
			,@strItemNo 		= Item.strItemNo
			,@ItemLocationId	= IL.intItemLocationId
			,@strCommodityCode	= Com.strCommodityCode
			,@ysnExchangeTraded = Com.ysnExchangeTraded
		FROM tblICItem Item
		JOIN tblICCommodity Com 
			ON Com.intCommodityId = Item.intCommodityId
		LEFT JOIN tblICItemLocation IL
			ON IL.intItemId = Item.intItemId
				AND IL.intLocationId = @LocationId
		WHERE Item.intItemId = @ItemId
		
		IF @intFutureMarketId > 0
		BEGIN
			SELECT TOP 1 
				@dblFutureMarkePrice = ISNULL(a.dblLastSettle,0)
			FROM tblRKFutSettlementPriceMarketMap a 
			JOIN tblRKFuturesSettlementPrice b 
				ON b.intFutureSettlementPriceId = a.intFutureSettlementPriceId
			JOIN tblRKFuturesMonth c 
				ON c.intFutureMonthId = a.intFutureMonthId
			JOIN tblRKFutureMarket d 
				ON d.intFutureMarketId = b.intFutureMarketId
			WHERE b.intFutureMarketId = @intFutureMarketId 
			ORDER by b.dtmPriceDate DESC
		END

		SET @intCurrencyId = ISNULL(
										(
											SELECT intCurrencyId
											FROM tblAPVendor
											WHERE [intEntityId] = @EntityId
										)
									,	
										(
											SELECT intDefaultCurrencyId
											FROM tblSMCompanyPreference
										)
								)

		SET @strUpdateType = 'estimate'

		SET @strProcessType = CASE 
								   WHEN @strStorageAdjustment IN ('No additional','Override') THEN 'Unpaid'
								   ELSE 'calculate'
							  END

		SELECT 
			@intInventoryItemStockUOMId = intItemUOMId
			,@dblUOMQty					= dblUnitQty
			,@intUnitMeasureId			= intUnitMeasureId
		FROM tblICItemUOM
		WHERE intItemId = @ItemId 
			AND ysnStockUnit = 1

		INSERT INTO @SettleStorage 
		(
			intSettleStorageTicketId
			,intCustomerStorageId
			,dblStorageUnits
			,dblRemainingUnits
			,dblOpenBalance
			,strStorageTicketNumber
			,intCompanyLocationId
			,intStorageTypeId
			,intStorageScheduleId
			,intContractHeaderId
		)
		SELECT 
			intSettleStorageTicketId = SST.intSettleStorageTicketId
			,intCustomerStorageId	  = SST.intCustomerStorageId
			,dblStorageUnits          = SST.dblUnits
			,dblRemainingUnits        = SST.dblUnits
			,dblOpenBalance           = SSV.dblOpenBalance
			,strStorageTicketNumber   = SSV.strStorageTicketNumber
			,intCompanyLocationId     = SSV.intCompanyLocationId
			,intStorageTypeId         = SSV.intStorageTypeId
			,intStorageScheduleId     = SSV.intStorageScheduleId
			,intContractHeaderId      = SSV.intContractHeaderId
		FROM tblGRSettleStorageTicket SST
		JOIN vyuGRStorageSearchView SSV 
			ON SSV.intCustomerStorageId = SST.intCustomerStorageId
		WHERE SST.intSettleStorageId = @intSettleStorageId 
			AND SST.dblUnits > 0
		ORDER BY SST.intSettleStorageTicketId

		INSERT INTO @SettleContract 
		(
			intSettleContractId
			,intContractDetailId
			,dblContractUnits
			,ContractEntityId
			,dblCashPrice
			,intPricingTypeId
			,dblBasis
			,intContractUOMId
			,dblCostUnitQty
			,strPricingType
		)
		SELECT 
			intSettleContractId 	= SSC.intSettleContractId 
			,intContractDetailId 	= SSC.intContractDetailId 
			,dblContractUnits    	= SSC.dblUnits
			,ContractEntityId    	= CD.intEntityId
			,dblCashPrice		 	= CD.dblCashPrice
			,intPricingTypeId    	= CD.intPricingTypeId
			,dblBasis			 	= CD.dblBasisInItemStockUOM
			,intContractUOMId	 	= CD.intContractUOMId
			,dblCostUnitQty		 	= CD.dblCostUnitQty
			,strPricingType			= CD.strPricingType
		FROM tblGRSettleContract SSC
		JOIN vyuGRGetContracts CD 
			ON CD.intContractDetailId = SSC.intContractDetailId
		WHERE intSettleStorageId = @intSettleStorageId 
			AND SSC.dblUnits > 0
		ORDER BY SSC.intSettleContractId

		IF EXISTS(SELECT TOP 1 1 FROM @SettleContract WHERE strPricingType = 'Basis')
		BEGIN
			IF @intFutureMarketId = 0 AND @ysnExchangeTraded = 1
			BEGIN
				SET @ErrMsg = 'There is no <b>Futures Market</b> setup yet in Risk Management for <b>' + @strCommodityCode + '</b> commodity.'
				RAISERROR(@ErrMsg,16,1,1)
				RETURN;
			END

			IF @dblFutureMarkePrice <= 0
			BEGIN
				SET @ErrMsg = 'There is no <b>Futures Price</b> yet in Risk Management for <b>' + @strCommodityCode + '</b> commodity.'
				RAISERROR(@ErrMsg,16,1,1)
				RETURN;
			END
		END			

		SELECT TOP 1 
			@intStorageChargeItemId = intItemId
			,@StorageChargeItemDescription = strDescription
		FROM tblICItem
		WHERE strType = 'Other Charge' 
			AND strCostType = 'Storage Charge' 
			AND (intCommodityId = @IntCommodityId OR intCommodityId IS NULL)

		--Discount
		IF EXISTS (
					SELECT 1
					FROM tblQMTicketDiscount QM
					JOIN tblGRSettleStorageTicket SST 
						ON SST.intCustomerStorageId = QM.intTicketFileId
							AND SST.intSettleStorageId = @intSettleStorageId
							AND QM.strSourceType = 'Storage'
							AND SST.dblUnits > 0
							AND ISNULL(QM.dblDiscountDue, 0) <> ISNULL(QM.dblDiscountPaid, 0)
					)
		BEGIN
			INSERT INTO @SettleVoucherCreate 
			(
				intCustomerStorageId
				,intCompanyLocationId
				,intContractHeaderId
				,intContractDetailId
				,dblUnits
				,dblCashPrice
				,intItemId
				,intItemType
				,IsProcessed
				,intTicketDiscountId
				,dblSettleContractUnits
				,ysnDiscountFromGrossWeight
				,intPricingTypeId
			)
			SELECT 
					intCustomerStorageId		= CS.intCustomerStorageId
				,intCompanyLocationId		= CS.intCompanyLocationId 
				,intContractHeaderId		= NULL
				,intContractDetailId		= NULL
				,dblUnits					= CASE
												WHEN DCO.strDiscountCalculationOption = 'Gross Weight' THEN 
													CASE WHEN CS.dblGrossQuantity IS NULL THEN SST.dblUnits
													ELSE
														ROUND((SST.dblUnits / CS.dblOriginalBalance) * CS.dblGrossQuantity,10)
													END
												ELSE SST.dblUnits
											END
				,dblCashPrice				= CASE 
												WHEN QM.strDiscountChargeType = 'Percent'
															THEN (dbo.fnCTConvertQuantityToTargetItemUOM(CS.intItemId, IU.intUnitMeasureId, CS.intUnitMeasureId, ISNULL(QM.dblDiscountPaid, 0)) - dbo.fnCTConvertQuantityToTargetItemUOM(CS.intItemId, IU.intUnitMeasureId, CS.intUnitMeasureId, ISNULL(QM.dblDiscountDue, 0)))
																*
																(CASE WHEN SS.dblCashPrice <> 0 THEN SS.dblCashPrice ELSE SC.dblCashPrice END)
												ELSE --Dollar
													dbo.fnCTConvertQuantityToTargetItemUOM(CS.intItemId, IU.intUnitMeasureId, CS.intUnitMeasureId, ISNULL(QM.dblDiscountPaid, 0)) - dbo.fnCTConvertQuantityToTargetItemUOM(CS.intItemId, IU.intUnitMeasureId, CS.intUnitMeasureId, ISNULL(QM.dblDiscountDue, 0))
											END
				,intItemId					= DItem.intItemId 
				,intItemType				= 3 
				,IsProcessed				= 0
				,intTicketDiscountId		= QM.intTicketDiscountId
				,dblSettleContractUnits		= SC.dblContractUnits
				,ysnDiscountFromGrossWeight	= CASE
												WHEN DCO.strDiscountCalculationOption = 'Gross Weight' THEN 1
												ELSE 0
											END
				,intPricingTypeId				= CD.intPricingTypeId
			FROM tblGRCustomerStorage CS
			JOIN tblGRSettleStorageTicket SST 
				ON SST.intCustomerStorageId = CS.intCustomerStorageId 
					AND SST.intSettleStorageId = @intSettleStorageId 
					AND SST.dblUnits > 0
			JOIN tblGRSettleStorage SS
				ON SS.intSettleStorageId = SST.intSettleStorageId
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
			LEFT JOIN @SettleContract SC 
				ON SC.ContractEntityId = CS.intEntityId
			LEFT JOIN tblCTContractDetail CD
				ON CD.intContractDetailId = SC.intContractDetailId
			WHERE (ISNULL(QM.dblDiscountDue, 0) - ISNULL(QM.dblDiscountPaid, 0)) <> 0
				--AND CASE WHEN (CD.intPricingTypeId = 2 AND (ISNULL(CD.dblTotalCost, 0) = 0)) THEN 0 ELSE 1 END = 1
		END

		--Unpaid Fee		
		IF EXISTS (
					SELECT 1
					FROM tblGRCustomerStorage CS
					JOIN tblGRSettleStorageTicket SST 
						ON SST.intCustomerStorageId = CS.intCustomerStorageId 
							AND SST.intSettleStorageId = @intSettleStorageId 
							AND SST.dblUnits > 0
					WHERE ISNULL(CS.dblFeesDue, 0) < > ISNULL(CS.dblFeesPaid, 0)
					)
		BEGIN
			INSERT INTO @SettleVoucherCreate 
			(
				intCustomerStorageId
				,intCompanyLocationId
				,intContractHeaderId
				,intContractDetailId
				,dblUnits
				,dblCashPrice
				,intItemId
				,intItemType
				,IsProcessed
			)
			SELECT DISTINCT
					intCustomerStorageId = SST.intCustomerStorageId
				,intCompanyLocationId = CS.intCompanyLocationId
				,intContractHeaderId  = NULL
				,intContractDetailId  = NULL
				,dblUnits             = CASE 
											WHEN CS.intDeliverySheetId IS NOT NULL THEN CASE WHEN IC.ysnPrice = 1 THEN -SST.dblUnits ELSE SST.dblUnits END
											ELSE CASE WHEN SC.ysnCusVenPaysFees = 1 THEN -SST.dblUnits ELSE SST.dblUnits END
										END
				,dblCashPrice         = CS.dblFeesDue
				,intItemId            = IC.intItemId
				,intItemType          = 4
				,IsProcessed          = 0
			FROM tblGRCustomerStorage CS
			INNER JOIN tblGRSettleStorageTicket SST 
				ON 	SST.intCustomerStorageId = CS.intCustomerStorageId 
					AND SST.intSettleStorageId = @intSettleStorageId 
					AND SST.dblUnits > 0
			INNER JOIN tblSCTicket SC 
				ON 	SC.intTicketId = CS.intTicketId 
					OR SC.intDeliverySheetId = CS.intDeliverySheetId
			INNER JOIN tblSCScaleSetup SCSetup 
				ON SCSetup.intScaleSetupId = SC.intScaleSetupId
			INNER JOIN tblICItem IC 
				ON IC.intItemId = SCSetup.intDefaultFeeItemId
		END

		SELECT @SettleStorageKey = MIN(intSettleStorageKey)
		FROM @SettleStorage
		WHERE dblRemainingUnits > 0

		SET @intSettleStorageTicketId = NULL
		SET @intCustomerStorageId = NULL
		SET @dblStorageUnits = NULL
		SET @intCompanyLocationId = NULL
		SET @DPContractHeaderId = NULL
		SET @ContractDetailId = NULL

		WHILE @SettleStorageKey > 0
		BEGIN
			SELECT 
					@intSettleStorageTicketId	= intSettleStorageTicketId
				,@intCustomerStorageId		= intCustomerStorageId
				,@dblStorageUnits			= dblRemainingUnits
				,@intCompanyLocationId		= intCompanyLocationId
				,@DPContractHeaderId		= CASE 
												WHEN dblStorageUnits = dblRemainingUnits THEN intContractHeaderId
												ELSE 0
											END
			FROM @SettleStorage
			WHERE intSettleStorageKey = @SettleStorageKey				
			
			--Storage Due		
			SET @dblStorageDuePerUnit = 0
			SET @dblStorageDueAmount = 0
			SET @dblStorageDueTotalPerUnit = 0
			SET @dblStorageDueTotalAmount = 0
			SET @dblStorageBilledPerUnit = 0
			SET @dblStorageBilledAmount = 0
			SET @dblFlatFeeTotal = 0
			SET @dblTicketStorageDue = 0

			EXEC uspGRCalculateStorageCharge 
				@strProcessType
				,@strUpdateType
				,@intCustomerStorageId
				,NULL
				,NULL
				,@dblStorageUnits
				,@dtmCalculateStorageThrough
				,@intCreatedUserId
				,0
				,NULL
				,@dblStorageDuePerUnit OUTPUT
				,@dblStorageDueAmount OUTPUT
				,@dblStorageDueTotalPerUnit OUTPUT
				,@dblStorageDueTotalAmount OUTPUT
				,@dblStorageBilledPerUnit OUTPUT
				,@dblStorageBilledAmount OUTPUT
				,@dblFlatFeeTotal OUTPUT

			IF @strStorageAdjustment = 'Override'
				SET @dblTicketStorageDue = @dblAdjustPerUnit + @dblStorageDuePerUnit + @dblStorageDueTotalPerUnit - @dblStorageBilledPerUnit
			ELSE
				SET @dblTicketStorageDue = @dblStorageDuePerUnit + @dblStorageDueTotalPerUnit - @dblStorageBilledPerUnit

			IF NOT EXISTS (
							SELECT 1
							FROM @SettleVoucherCreate
							WHERE intCustomerStorageId = @intCustomerStorageId 
								AND intItemId = @intStorageChargeItemId
							)
							AND @dblTicketStorageDue > 0
			BEGIN
				INSERT INTO @SettleVoucherCreate 
				(
						intCustomerStorageId
					,intCompanyLocationId
					,intContractHeaderId
					,intContractDetailId
					,dblUnits
					,dblCashPrice
					,intItemId
					,intItemType
					,IsProcessed
				)
				SELECT 
						intCustomerStorageId  = @intCustomerStorageId
					,intCompanyLocationId  = @intCompanyLocationId
					,intContractHeaderId   = NULL
					,intContractDetailId   = NULL
					,dblUnits              = @dblStorageUnits
					,dblCashPrice          = - @dblTicketStorageDue -(ISNULL(@dblFlatFeeTotal,0)/@dblStorageUnits)
					,intItemId             = @intStorageChargeItemId
					,intItemType           = 2
					,IsProcessed           = 0
			END

			IF ISNULL(@DPContractHeaderId, 0) > 0
			BEGIN
				SELECT @ContractDetailId = intContractDetailId
				FROM tblCTContractDetail
				WHERE intContractHeaderId = @DPContractHeaderId

				INSERT INTO @tblDepletion 
				(
						intSettleStorageTicketId
					,intPricingTypeId
					,strDepletionType
					,intContractHeaderId
					,intContractDetailId
					,intCustomerStorageId
					,dblUnits
					,intSourceItemUOMId
				)
				SELECT 
						intSettleStorageTicketId = @intSettleStorageTicketId
					,intPricingTypeId		  = 5
					,strDepletionType		  = 'DP Contract'
					,intContractHeaderId      = @DPContractHeaderId
					,intContractDetailId      = @ContractDetailId
					,intCustomerStorageId     = @intCustomerStorageId
					,dblUnits                 = - @dblStorageUnits
					,intSourceItemUOMId       = @CommodityStockUomId
			END

			IF EXISTS (
						SELECT 1
						FROM @SettleContract
						WHERE dblContractUnits > 0
						)
			BEGIN
				SELECT @SettleContractKey = MIN(intSettleContractKey)
				FROM @SettleContract
				WHERE dblContractUnits > 0

				SET @intContractDetailId = NULL
				SET @dblContractUnits = NULL
				SET @dblCashPrice = NULL
				SET @intContractHeaderId = NULL
				SET @dblUnitsForContract = NULL
				SET @intPricingTypeId = NULL
				SET @dblContractBasis = NULL

				WHILE @SettleContractKey > 0
				BEGIN
					SELECT 
						@intContractDetailId 	= intContractDetailId
						,@dblContractUnits 		= dblContractUnits
						,@dblCashPrice 			= dblCashPrice
						,@intPricingTypeId 		= intPricingTypeId
						,@dblContractBasis		= dblBasis
						,@intContractUOMId		= intContractUOMId
						,@dblCostUnitQty		= dblCostUnitQty
					FROM @SettleContract
					WHERE intSettleContractKey 	= @SettleContractKey

					SELECT @intContractHeaderId = intContractHeaderId
					FROM tblCTContractDetail
					WHERE intContractDetailId = @intContractDetailId

					IF @dblStorageUnits <= @dblContractUnits
					BEGIN
						UPDATE @SettleContract
						SET dblContractUnits = dblContractUnits - @dblStorageUnits
						WHERE intSettleContractKey = @SettleContractKey

						UPDATE @SettleStorage
						SET dblRemainingUnits = 0
						WHERE intSettleStorageKey = @SettleStorageKey

						SELECT @dblUnitsForContract = dbo.fnCTConvertQtyToTargetItemUOM(@CommodityStockUomId, intItemUOMId, @dblStorageUnits)
						FROM tblCTContractDetail
						WHERE intContractDetailId = @intContractDetailId

						INSERT INTO @tblDepletion 
						(
							intSettleStorageTicketId
							,intPricingTypeId
							,strDepletionType
							,intContractHeaderId
							,intContractDetailId
							,intCustomerStorageId
							,dblUnits
							)
						SELECT 
							intSettleStorageTicketId = @intSettleStorageTicketId
							,intPricingTypeId		  = @intPricingTypeId
							,strDepletionType		 = 'Contract'
							,intContractHeaderId      = 0 
							,intContractDetailId      = @intContractDetailId
							,intCustomerStorageId     = @intCustomerStorageId
							,dblUnits                 = @dblUnitsForContract

						INSERT INTO @SettleVoucherCreate 
						(
							intCustomerStorageId
							,strOrderType
							,intCompanyLocationId
							,intContractHeaderId
							,intContractDetailId
							,dblUnits
							,dblCashPrice
							,intItemId
							,intItemType
							,IsProcessed
							,intPricingTypeId
							,dblBasis
							,intContractUOMId
							,dblCostUnitQty
						)
						SELECT 
							intCustomerStorageId	= @intCustomerStorageId
							,strOrderType			= 'Contract'
							,intCompanyLocationId	= @intCompanyLocationId
							,intContractHeaderId	= @intContractHeaderId
							,intContractDetailId	= @intContractDetailId
							,dblUnits				= @dblStorageUnits
							,dblCashPrice			= @dblCashPrice
							,intItemId				= @ItemId
							,intItemType			= 1
							,IsProcessed			= 0
							,intPricingTypeId		= @intPricingTypeId
							,dblBasis				= @dblContractBasis
							,intContractUOMId		= @intContractUOMId
							,dblCostUnitQty			= @dblCostUnitQty
						BREAK;
					END
					ELSE
					BEGIN
						UPDATE @SettleContract
						SET dblContractUnits = dblContractUnits - @dblContractUnits
						WHERE intSettleContractKey = @SettleContractKey

						UPDATE @SettleStorage
						SET dblRemainingUnits = dblRemainingUnits - @dblContractUnits
						WHERE intSettleStorageKey = @SettleStorageKey

						SELECT @dblUnitsForContract = dbo.fnCTConvertQtyToTargetItemUOM(@CommodityStockUomId, intItemUOMId, @dblContractUnits)
						FROM tblCTContractDetail
						WHERE intContractDetailId = @intContractDetailId

						INSERT INTO @tblDepletion 
						(
							intSettleStorageTicketId
							,intPricingTypeId
							,strDepletionType
							,intContractHeaderId
							,intContractDetailId
							,intCustomerStorageId
							,dblUnits
						)
						SELECT 
							intSettleStorageTicketId = @intSettleStorageTicketId
							,intPricingTypeId		  = 1 
							,strDepletionType         = 'Contract' 
							,intContractHeaderId      = 0
							,intContractDetailId      = @intContractDetailId 
							,intCustomerStorageId     = @intCustomerStorageId 
							,dblUnits                 = @dblUnitsForContract

						INSERT INTO @SettleVoucherCreate 
						(
							intCustomerStorageId
							,strOrderType
							,intCompanyLocationId
							,intContractHeaderId
							,intContractDetailId
							,dblUnits
							,dblCashPrice
							,intItemId
							,intItemType
							,IsProcessed
							,intPricingTypeId
							,dblBasis
							,intContractUOMId
							,dblCostUnitQty
						)
						SELECT 
							intCustomerStorageId   = @intCustomerStorageId
							,strOrderType           = 'Purchase Contract'
							,intCompanyLocationId   = @intCompanyLocationId
							,intContractHeaderId    = @intContractHeaderId
							,intContractDetailId    = @intContractDetailId
							,dblUnits               = @dblContractUnits
							,dblCashPrice           = @dblCashPrice
							,intItemId              = @ItemId
							,intItemType            = 1
							,IsProcessed            = 0
							,intPricingTypeId		= @intPricingTypeId
							,dblBasis				= @dblContractBasis
							,intContractUOMId		= @intContractUOMId
							,dblCostUnitQty			= @dblCostUnitQty
						BREAK;
					END

					SELECT @SettleContractKey = MIN(intSettleContractKey)
					FROM @SettleContract
					WHERE intSettleContractKey > @SettleContractKey 
						AND dblContractUnits > 0
				END

				SELECT @SettleStorageKey = MIN(intSettleStorageKey)
				FROM @SettleStorage
				WHERE intSettleStorageKey >= @SettleStorageKey AND dblRemainingUnits > 0
			END
			ELSE IF @dblSpotUnits > 0
			BEGIN
				IF @dblStorageUnits <= @dblSpotUnits
				BEGIN
					UPDATE @SettleStorage
					SET dblRemainingUnits = dblRemainingUnits - @dblStorageUnits
					WHERE intSettleStorageKey = @SettleStorageKey

					SET @dblSpotUnits = @dblSpotUnits - @dblStorageUnits

					INSERT INTO @SettleVoucherCreate 
					(
						intCustomerStorageId
						,strOrderType
						,intCompanyLocationId
						,intContractHeaderId
						,intContractDetailId
						,dblUnits
						,dblCashPrice
						,intItemId
						,intItemType
						,IsProcessed
						)
					SELECT 
						intCustomerStorageId = @intCustomerStorageId
						,strOrderType		  = 'Direct'
						,intCompanyLocationId = @intCompanyLocationId
						,intContractHeaderId  = NULL
						,intContractDetailId  = NULL
						,dblUnits             = @dblStorageUnits
						,dblCashPrice         = @dblSpotCashPrice
						,intItemId            = @ItemId
						,intItemType          = 1
						,IsProcessed          = 0
				END
				ELSE
				BEGIN
					UPDATE @SettleStorage
					SET dblRemainingUnits = dblRemainingUnits - @dblSpotUnits
					WHERE intSettleStorageKey = @SettleStorageKey

					INSERT INTO @SettleVoucherCreate 
					(
						intCustomerStorageId
						,strOrderType
						,intCompanyLocationId
						,intContractHeaderId
						,intContractDetailId
						,dblUnits
						,dblCashPrice
						,intItemId
						,intItemType
						,IsProcessed
					)
					SELECT 
						intCustomerStorageId = @intCustomerStorageId
						,strOrderType		  = 'Direct'
						,intCompanyLocationId = @intCompanyLocationId
						,intContractHeaderId  = NULL
						,intContractDetailId  = NULL
						,dblUnits             = @dblSpotUnits
						,dblCashPrice         = @dblSpotCashPrice
						,intItemId            = @ItemId
						,intItemType          = 1
						,IsProcessed          = 0

					SET @dblSpotUnits = 0
				END
				SELECT @SettleStorageKey = MIN(intSettleStorageKey)
				FROM @SettleStorage
				WHERE intSettleStorageKey >= @SettleStorageKey 
					AND dblRemainingUnits > 0
			END
			ELSE
			BEGIN
				BREAK;
			END
		END
		BEGIN
			DELETE FROM @voucherDetailStorage
			DELETE FROM @VoucherDetailReceiptCharge

			DELETE FROM @voucherPayable
			DELETE FROM @voucherPayableTax

			SET @createdVouchersId = NULL

			SET @intCreatedBillId = 0

			UPDATE a
			SET a.dblUnits = CASE 
								WHEN a.ysnDiscountFromGrossWeight = 0 THEN
									CASE 
										WHEN ISNULL(a.dblSettleContractUnits,0) > 0 THEN a.dblSettleContractUnits
										ELSE ISNULL(b.dblSettleUnits,0)
									END
								ELSE a.dblUnits
							END
			FROM @SettleVoucherCreate a
			LEFT JOIN 
			(
				SELECT 
					intCustomerStorageId
					,SUM(dblUnits) dblSettleUnits 
				FROM @SettleVoucherCreate 
				WHERE intItemType = 1 
					AND (intPricingTypeId = 1 OR intPricingTypeId IS NULL)
				GROUP BY intCustomerStorageId
			)b ON b.intCustomerStorageId = a.intCustomerStorageId
			INNER JOIN tblGRCustomerStorage CS
				ON CS.intCustomerStorageId = a.intCustomerStorageId
			WHERE a.intItemType = 3
		    
			SELECT TOP 1 @ysnDPOwnedType = ISNULL(ST.ysnDPOwnedType,0) 
			FROM @SettleVoucherCreate A
			JOIN tblGRSettleStorageTicket SST 
				ON SST.intCustomerStorageId = A.intCustomerStorageId
			LEFT JOIN tblGRCustomerStorage CS
				ON CS.intCustomerStorageId = A.intCustomerStorageId
			JOIN tblGRStorageType ST
				ON ST.intStorageScheduleTypeId = CS.intStorageTypeId
			WHERE SST.intSettleStorageId = @intSettleStorageId
			 
			 IF EXISTS(SELECT 1 FROM @SettleVoucherCreate WHERE ISNULL(dblCashPrice,0) <> 0 AND ISNULL(dblUnits,0) <> 0 )
			 BEGIN
				--Inventory Item and Discounts
				INSERT INTO @voucherPayable
				(
					[intEntityVendorId]
					,[intTransactionType]
					,[intLocationId]
					,[intShipToId]
					,[intShipFromId]
					,[intShipFromEntityId]
					,[strVendorOrderNumber]
					,[strMiscDescription]
					,[intItemId]
					,[intAccountId]					
					,[intContractHeaderId]
					,[intContractDetailId]
					,[intInventoryReceiptItemId]
					,[intCustomerStorageId]
					,[dblOrderQty]
					,[dblOrderUnitQty]
					,[intOrderUOMId]	
					,[dblQuantityToBill]
					,[intQtyToBillUOMId]
					,[dblCost]
					,[dblCostUnitQty]
					,[intCostUOMId]
					,[dblNetWeight]
					,[dblWeightUnitQty]
					,[intWeightUOMId]
				 )
				SELECT 
					[intEntityVendorId]				= @EntityId
					,[intTransactionType]			= 1
					,[intLocationId]				= @LocationId
					,[intShipToId]					= @LocationId
					,[intShipFromId]				= @intShipFrom	
					,[intShipFromEntityId]			= @shipFromEntityId
					,[strVendorOrderNumber]			= @TicketNo
					,[strMiscDescription]			= c.[strItemNo]
					,[intItemId]					= a.[intItemId]
					,[intAccountId]					= [dbo].[fnGetItemGLAccount](a.intItemId,@ItemLocationId, 
																			CASE 
																				WHEN ((a.intItemType = 3 AND DSC.strDiscountChargeType = 'Dollar') OR a.intItemType = 2) AND @ysnDPOwnedType = 0 THEN 'AP Clearing'
																				WHEN a.intItemType = 1 THEN 'AP Clearing'
																				ELSE 'Other Charge Expense' 
																			END
																				)
					,[intContractHeaderId]			= a.[intContractHeaderId]
					,[intContractDetailId]			= a.[intContractDetailId]
					,[intInventoryReceiptItemId] = 													
																CASE 
																		WHEN ST.ysnDPOwnedType = 0 THEN NULL
																		ELSE 
																				CASE 
																						WHEN a.intItemType = 1 THEN RI.intInventoryReceiptItemId
																						ELSE NULL
																				END
																END
					,[intCustomerStorageId]			= a.[intCustomerStorageId]
					,[dblOrderQty]					= CASE 
														WHEN @origdblSpotUnits > 0 THEN ROUND(dbo.fnCalculateQtyBetweenUOM(b.intItemUOMId,@intCashPriceUOMId,a.dblUnits),6) 
														ELSE a.dblUnits 
													END
					,[dblOrderUnitQty]				= 1
					,[intOrderUOMId]				= CASE
														WHEN @origdblSpotUnits > 0 THEN @intCashPriceUOMId
														ELSE b.intItemUOMId
													END
					,[dblQuantityToBill]			= 													
													CASE
														WHEN a.intItemType = 1 AND ST.ysnDPOwnedType = 1 THEN RI.dblOpenReceive
														ELSE
																CASE 
																		WHEN @origdblSpotUnits > 0 THEN ROUND(dbo.fnCalculateQtyBetweenUOM(b.intItemUOMId,@intCashPriceUOMId,a.dblUnits),6)
																		ELSE a.dblUnits
																END
													END
					,[intQtyToBillUOMId]			= CASE
														WHEN @origdblSpotUnits > 0 THEN @intCashPriceUOMId
														ELSE b.intItemUOMId
													END
					,[dblCost]						= CASE
																WHEN a.[intContractHeaderId] IS NOT NULL THEN dbo.fnCTConvertQtyToTargetItemUOM(a.intContractUOMId,b.intItemUOMId,a.dblCashPrice)
																ELSE a.dblCashPrice 
														END * -1
					,[dblCostUnitQty]				= ISNULL(a.dblCostUnitQty,1)
					,[intCostUOMId]					= CASE
														WHEN @origdblSpotUnits > 0 THEN @intCashPriceUOMId 
														WHEN a.[intContractHeaderId] IS NOT NULL THEN a.intContractUOMId
														ELSE b.intItemUOMId
													END
					,[dblNetWeight]					= CASE 
														WHEN a.[intContractHeaderId] IS NOT NULL THEN a.dblUnits 
														ELSE 0 
													END
					,[dblWeightUnitQty]				= 1 
					,[intWeightUOMId]				= CASE
														WHEN a.[intContractHeaderId] IS NOT NULL THEN b.intItemUOMId
														ELSE NULL
													END	
				FROM @SettleVoucherCreate a
				JOIN tblICItemUOM b 
					ON b.intItemId = a.intItemId 
						AND b.ysnStockUnit = 1
				JOIN tblICItem c 
					ON c.intItemId = a.intItemId
				JOIN tblGRSettleStorageTicket SST 
					ON SST.intCustomerStorageId = a.intCustomerStorageId
				LEFT JOIN tblGRCustomerStorage CS
					ON CS.intCustomerStorageId = a.intCustomerStorageId
				LEFT JOIN tblGRDiscountScheduleCode DSC
					ON DSC.intDiscountScheduleId = CS.intDiscountScheduleId 
						AND DSC.intItemId = a.intItemId
				JOIN tblGRStorageType ST
					ON ST.intStorageScheduleTypeId = CS.intStorageTypeId
				LEFT JOIN (
						tblICInventoryReceiptItem RI
						INNER JOIN tblGRStorageHistory SH
								ON SH.intInventoryReceiptId = RI.intInventoryReceiptId
										AND RI.intContractHeaderId = ISNULL(SH.intContractHeaderId,RI.intContractHeaderId)
				) 
						ON SH.intCustomerStorageId = CS.intCustomerStorageId
								AND a.intItemType = 1
				LEFT JOIN tblCTContractDetail CD
					ON CD.intContractDetailId = a.intContractDetailId
				WHERE a.dblCashPrice <> 0 
					AND a.dblUnits <> 0 
					AND SST.intSettleStorageId = @intSettleStorageId
				AND CASE WHEN (a.intPricingTypeId = 2) THEN 0 ELSE 1 END = 1
				AND c.[strItemNo] LIKE '%Storage'
				ORDER BY SST.intSettleStorageTicketId
					,a.intItemType	
					
				--IF EXISTS(SELECT * FROM @voucherPayable vp INNER JOIN tblICItem I ON I.intItemId = vp.intItemId)
				--BEGIN 
				--	--EXEC uspAPCreateVoucher @voucherPayable, @voucherPayableTax, @intCreatedUserId, 1, @ErrMsg, @createdVouchersId OUTPUT	
				--	SELECT * FROM @voucherPayable
				--	RETURN
				--END
			END
		END
			
		SELECT @intSettleStorageId = MIN(intSettleStorageId)
		FROM tblGRSettleStorage
		WHERE intParentSettleStorageId = @intParentSettleStorageId 
		AND intSettleStorageId > @intSettleStorageId

	END
	
	SELECT [intCustomerStorageId]
		,[intItemId]
		,[intAccountId]
		,[dblQuantityToBill]
		,[strMiscDescription]
		,[dblOldCost]
		,[dblCost]
		--,[intContractHeaderId]
		--,[intContractDetailId]
		,[dblOrderQty]
		,[intQtyToBillUOMId]
		,[intCostUOMId]
		,[dblWeightUnitQty]
		,[dblCostUnitQty]
		,[dblQtyToBillUnitQty]
		,[dblNetWeight]
		,[intShipToId]
		,[intEntityVendorId]
		,[intTransactionType]
		,[dtmVoucherDate]
	 FROM @voucherPayable

	SettleStorage_Exit:
END TRY

BEGIN CATCH
	SET @ErrMsg = ERROR_MESSAGE()
	RAISERROR (@ErrMsg,16,1,'WITH NOWAIT')
END CATCH