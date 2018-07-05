CREATE PROCEDURE [dbo].[uspGRPostSettleStorage]
	 @intSettleStorageId INT
	,@ysnPosted BIT
AS
BEGIN TRY
	SET NOCOUNT ON

	DECLARE @ErrMsg NVARCHAR(MAX)
	DECLARE @SettleStorageId INT
	DECLARE @EntityId INT
	DECLARE @LocationId INT
	DECLARE @ItemId INT
	DECLARE @strItemNo NVARCHAR(20)
	DECLARE @intUnitMeasureId INT
	DECLARE @CommodityStockUomId INT
	DECLARE @TicketNo NVARCHAR(20)
	DECLARE @strVoucher NVARCHAR(20)
	DECLARE @intCreatedUserId INT
	DECLARE @UserName NVARCHAR(100)
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
	DECLARE @intExternalId INT
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
	DECLARE @FeeItemId INT
	DECLARE @strFeeItem NVARCHAR(40)
	DECLARE @intCurrencyId INT
	DECLARE @intDefaultCurrencyId INT
	DECLARE @strOrderType NVARCHAR(50)
	DECLARE @dblUOMQty NUMERIC(38, 20)
	DECLARE @detailCreated AS Id
	DECLARE @intInventoryItemStockUOMId INT
	DECLARE @dtmDate AS DATETIME
	DECLARE @STARTING_NUMBER_BATCH AS INT = 3
	DECLARE @voucherDetailStorage AS [VoucherDetailStorage]
	DECLARE @ItemsToStorage AS ItemCostingTableType
	DECLARE @ItemsToPost AS ItemCostingTableType
	DECLARE @strBatchId AS NVARCHAR(20)
	DECLARE @intReceiptId AS INT
	DECLARE @intInventoryReceiptItemId AS INT
	DECLARE @intScaleTicketId AS INT
	DECLARE @intScaleFreightItemId AS INT
	DECLARE @intScaleContractId INT
	DECLARE @itemUOMIdFrom INT
	DECLARE @itemUOMIdTo INT
	DECLARE @dblFreightRate NUMERIC(38, 20)
	DECLARE @dblFreightAdjustment DECIMAL(7, 2)
	DECLARE @dblGrossUnits NUMERIC(38, 20)
	DECLARE @dblPerUnitFreight NUMERIC(38, 20)
	DECLARE @dblContractCostConvertedUOM NUMERIC(38, 20)
	DECLARE @intCreatedBillId AS INT
	DECLARE @success AS BIT
	DECLARE @intDepletionKey INT
	DECLARE @intPricingTypeId INT
	DECLARE @dblUnits DECIMAL(24, 10)
	DECLARE @dblCost DECIMAL(24, 10)
	DECLARE @intFutureMarketId INT
	DECLARE @dblFutureMarkePrice DECIMAL(24, 10)
	DECLARE @dblContractBasis DECIMAL(24, 10)
	DECLARE @intParentSettleStorageId INT
	DECLARE @GLEntries AS RecapTableType
	DECLARE @intReturnValue AS INT
	DECLARE @intLotId INT
	DECLARE @requireApproval AS BIT
	DECLARE @dblTotal AS DECIMAL(18,6)

	DECLARE @intCashPriceUOMId INT

  DECLARE @strOwnedPhysicalStock NVARCHAR(20)
	DECLARE @dblSettlementRatio DECIMAL(24, 10)
	DECLARE @dblOriginalInventoryGLAmount DECIMAL(24, 10)
	
	DECLARE @GLAccounts AS dbo.ItemGLAccount;
	DECLARE @AccountCategory_Inventory AS NVARCHAR(30) = 'Inventory'
	DECLARE @AccountCategory_Auto_Variance AS NVARCHAR(30) = 'Inventory Adjustment'
	DECLARE @OtherChargesGLAccounts AS dbo.ItemOtherChargesGLAccount
	DECLARE @ACCOUNT_CATEGORY_APClearing AS NVARCHAR(30) = 'AP Clearing'
	DECLARE @ACCOUNT_CATEGORY_OtherChargeExpense AS NVARCHAR(30) = 'Other Charge Expense'
	DECLARE @ACCOUNT_CATEGORY_OtherChargeIncome AS NVARCHAR(30) = 'Other Charge Income'

	DECLARE @adjustCostOfDelayedPricingStock AS ItemCostAdjustmentTableType

	SET @dtmDate = GETDATE()

	SELECT @intDefaultCurrencyId = intDefaultCurrencyId
	FROM tblSMCompanyPreference

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
	
	DECLARE @SettleVoucherCreate AS TABLE 
	(
		intSettleVoucherKey INT IDENTITY(1, 1)
		,strOrderType NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
		,intCustomerStorageId INT
		,intCompanyLocationId INT
		,intContractHeaderId INT NULL
		,intContractDetailId INT NULL
		,dblUnits DECIMAL(24, 10)
		,dblCashPrice DECIMAL(24, 10)
		,intItemId INT NULL
		,intItemType INT NULL
		,IsProcessed BIT
		,intTicketDiscountId INT NULL
		,intPricingTypeId INT
		,dblBasis DECIMAL(24, 10)
	)

	/*	intItemType
			------------
			1-Inventory
			2-Storage Charge
			3-Discount
			4-Fee
	   */
	
	SET @intParentSettleStorageId = @intSettleStorageId
	EXEC uspGRCreateSettleStorage @intSettleStorageId

	SELECT @intSettleStorageId = MIN(intSettleStorageId)
	FROM tblGRSettleStorage
	WHERE intParentSettleStorageId =@intParentSettleStorageId

	WHILE @intSettleStorageId >0
	BEGIN
		
		DELETE FROM @SettleStorage
		DELETE FROM @SettleContract
		DELETE FROM @tblDepletion
		DELETE FROM @SettleVoucherCreate

		SELECT @intCreatedUserId = intCreatedUserId
			,@EntityId = intEntityId
			,@LocationId = intCompanyLocationId
			,@ItemId = intItemId
			,@TicketNo = strStorageTicket
			,@strStorageAdjustment = strStorageAdjustment
			,@dtmCalculateStorageThrough = dtmCalculateStorageThrough
			,@dblAdjustPerUnit = dblAdjustPerUnit
			,@dblSpotUnits = dblSpotUnits
			,@dblSpotCashPrice = dblCashPrice
			,@IntCommodityId = intCommodityId
			,@CommodityStockUomId = intCommodityStockUomId
			,@intCashPriceUOMId = intItemUOMId
		FROM tblGRSettleStorage
		WHERE intSettleStorageId = @intSettleStorageId
	
		SELECT
		@intFutureMarketId=ISNULL(Com.intFutureMarketId,0),@strItemNo = Item.strItemNo
		FROM tblICItem Item
		JOIN tblICCommodity Com ON Com.intCommodityId=Item.intCommodityId
		WHERE Item.intItemId = @ItemId
	
		IF @intFutureMarketId >0
		BEGIN
			SELECT TOP 1 @dblFutureMarkePrice=
			a.dblLastSettle
			FROM tblRKFutSettlementPriceMarketMap a 
			JOIN tblRKFuturesSettlementPrice b ON b.intFutureSettlementPriceId=a.intFutureSettlementPriceId
			JOIN tblRKFuturesMonth c ON c.intFutureMonthId=a.intFutureMonthId
			JOIN tblRKFutureMarket d ON d.intFutureMarketId=b.intFutureMarketId
			WHERE b.intFutureMarketId=@intFutureMarketId 
			ORDER by b.dtmPriceDate DESC
		END
		SET @dblFutureMarkePrice=ISNULL(@dblFutureMarkePrice,0)
	
		SELECT @ItemLocationId = intItemLocationId
		FROM tblICItemLocation
		WHERE intItemId = @ItemId AND intLocationId = @LocationId

		SET @intCurrencyId = ISNULL(
										(
											SELECT intCurrencyId
											FROM tblAPVendor
											WHERE [intEntityId] = @EntityId
										)
									, @intDefaultCurrencyId
									)

		SET @strUpdateType = 'estimate'

		SET @strProcessType = CASE 
								   WHEN @strStorageAdjustment IN ('No additional','Override') THEN 'Unpaid'
								   ELSE 'calculate'
							  END

		SELECT @UserName = strUserName
		FROM tblSMUserSecurity
		WHERE [intEntityId] = @intCreatedUserId

		SELECT @FeeItemId = intItemId
		FROM tblGRCompanyPreference

		SELECT @strFeeItem = strItemNo
		FROM tblICItem
		WHERE intItemId = @FeeItemId

		SELECT @dblUOMQty = dblUnitQty
			,@intUnitMeasureId = intUnitMeasureId
		FROM tblICItemUOM
		WHERE intItemUOMId = @CommodityStockUomId

		IF @intUnitMeasureId IS NULL
		BEGIN
			RAISERROR ('The stock UOM of the commodity must be set for item',16,1);
			RETURN;
		END

		IF NOT EXISTS (
						SELECT 1
						FROM tblICItemUOM
						WHERE intItemId = @ItemId AND intUnitMeasureId = @intUnitMeasureId
					  )
		BEGIN
			RAISERROR ('The stock UOM of the commodity must exist in the conversion table of the item',16,1);
		END

		SELECT @intInventoryItemStockUOMId = intItemUOMId
		FROM tblICItemUOM
		WHERE intItemId = @ItemId AND ysnStockUnit=1

		IF @ysnPosted = 1
		BEGIN

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
			JOIN vyuGRStorageSearchView SSV ON SSV.intCustomerStorageId = SST.intCustomerStorageId
			WHERE SST.intSettleStorageId = @intSettleStorageId AND SST.dblUnits > 0
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
			)
			SELECT 
				 intSettleContractId = SSC.intSettleContractId 
				,intContractDetailId = SSC.intContractDetailId 
				,dblContractUnits    = SSC.dblUnits
				,ContractEntityId    = CD.intEntityId
				,dblCashPrice		 = CD.dblCashPriceInCommodityStockUOM
				,intPricingTypeId    = CD.intPricingTypeId
				,dblBasis			 = CD.dblBasisInCommodityStockUOM
			FROM tblGRSettleContract SSC
			JOIN vyuGRGetContracts CD ON CD.intContractDetailId = SSC.intContractDetailId
			WHERE intSettleStorageId = @intSettleStorageId AND SSC.dblUnits > 0
			ORDER BY SSC.intSettleContractId

			SELECT TOP 1 @intStorageChargeItemId = intItemId
			FROM tblICItem
			WHERE strType = 'Other Charge' AND strCostType = 'Storage Charge' AND intCommodityId = @IntCommodityId

			IF @intStorageChargeItemId IS NULL
			BEGIN
				SELECT TOP 1 @intStorageChargeItemId = intItemId
				FROM tblICItem
				WHERE strType = 'Other Charge' AND strCostType = 'Storage Charge' AND intCommodityId IS NULL
			END

			SELECT @StorageChargeItemDescription = strDescription
			FROM tblICItem
			WHERE intItemId = @intStorageChargeItemId

			--Discount
			IF EXISTS (
						SELECT 1
						FROM tblQMTicketDiscount QM
						JOIN tblGRSettleStorageTicket SST ON SST.intCustomerStorageId = QM.intTicketFileId
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
				)
				SELECT 
					 intCustomerStorageId  = CS.intCustomerStorageId
					,intCompanyLocationId  = CS.intCompanyLocationId 
					,intContractHeaderId   = NULL
					,intContractDetailId   = NULL
					,dblUnits			   = SST.dblUnits
					,dblCashPrice		   = CASE WHEN QM.strDiscountChargeType = 'Percent'
														THEN (dbo.fnCTConvertQuantityToTargetItemUOM(CS.intItemId, CU.intUnitMeasureId, CS.intUnitMeasureId, ISNULL(QM.dblDiscountPaid, 0)) - dbo.fnCTConvertQuantityToTargetItemUOM(CS.intItemId, CU.intUnitMeasureId, CS.intUnitMeasureId, ISNULL(QM.dblDiscountDue, 0))) * (SELECT dblFuturesPrice + dblFuturesBasis FROM tblGRSettleStorage WHERE intSettleStorageId = @intSettleStorageId)
											ELSE --Dollar
												dbo.fnCTConvertQuantityToTargetItemUOM(CS.intItemId, CU.intUnitMeasureId, CS.intUnitMeasureId, ISNULL(QM.dblDiscountPaid, 0)) - dbo.fnCTConvertQuantityToTargetItemUOM(CS.intItemId, CU.intUnitMeasureId, CS.intUnitMeasureId, ISNULL(QM.dblDiscountDue, 0))
											END
					,intItemId             = DItem.intItemId 
					,intItemType           = 3 
					,IsProcessed           = 0
					,intTicketDiscountId   = QM.intTicketDiscountId
				FROM tblGRCustomerStorage CS
				JOIN tblGRSettleStorageTicket SST ON SST.intCustomerStorageId = CS.intCustomerStorageId AND SST.intSettleStorageId = @intSettleStorageId AND SST.dblUnits > 0
				JOIN tblICCommodityUnitMeasure CU ON CU.intCommodityId = CS.intCommodityId AND CU.ysnStockUnit = 1
				JOIN tblQMTicketDiscount QM ON QM.intTicketFileId = CS.intCustomerStorageId AND QM.strSourceType = 'Storage'
				JOIN tblGRDiscountScheduleCode a ON a.intDiscountScheduleCodeId = QM.intDiscountScheduleCodeId
				JOIN tblICItem DItem ON DItem.intItemId = a.intItemId
				WHERE ISNULL(CS.strStorageType, '') <> 'ITR' AND (ISNULL(QM.dblDiscountDue, 0) - ISNULL(QM.dblDiscountPaid, 0)) <> 0
			END

			--Unpaid Fee		
			IF EXISTS (
						SELECT 1
						FROM tblGRCustomerStorage CS
						JOIN tblGRSettleStorageTicket SST ON SST.intCustomerStorageId = CS.intCustomerStorageId AND SST.intSettleStorageId = @intSettleStorageId AND SST.dblUnits > 0
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
				SELECT 
					 intCustomerStorageId = SST.intCustomerStorageId
					,intCompanyLocationId = CS.intCompanyLocationId
					,intContractHeaderId  = NULL
					,intContractDetailId  = NULL
					,dblUnits             = SST.dblUnits
					,dblCashPrice         = CS.dblFeesDue
					,intItemId            = @FeeItemId
					,intItemType          = 4
					,IsProcessed          = 0
				FROM tblGRCustomerStorage CS
				INNER JOIN tblGRSettleStorageTicket SST 
					ON 	SST.intCustomerStorageId = CS.intCustomerStorageId 
						AND SST.intSettleStorageId = @intSettleStorageId AND SST.dblUnits > 0
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
					 @intSettleStorageTicketId = intSettleStorageTicketId
					,@intCustomerStorageId = intCustomerStorageId
					,@dblStorageUnits = dblRemainingUnits
					,@intCompanyLocationId = intCompanyLocationId
					,@DPContractHeaderId = CASE 
												WHEN dblStorageUnits = dblRemainingUnits THEN intContractHeaderId
												ELSE 0
										   END
				FROM @SettleStorage
				WHERE intSettleStorageKey = @SettleStorageKey
				

				IF @LocationId IS NULL
				BEGIN
					SET @LocationId = @intCompanyLocationId

					SELECT @ItemLocationId = intItemLocationId
					FROM tblICItemLocation
					WHERE intItemId = @ItemId AND intLocationId = @LocationId

					DECLARE @intTicketCompanyLocationId INT
					DECLARE @intTempSettleStorageId INT

					SELECT 
						@intTicketCompanyLocationId  = SS.intCompanyLocationId
						, @intTempSettleStorageId = SST.intSettleStorageId
					FROM @SettleStorage SS
					LEFT JOIN tblGRSettleStorageTicket SST ON SST.intCustomerStorageId = SS.intCustomerStorageId
					WHERE intSettleStorageKey = @SettleStorageKey

					UPDATE tblGRSettleStorage SET intCompanyLocationId = @intCompanyLocationId WHERE intSettleStorageId = @intTempSettleStorageId
				END

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
								WHERE intCustomerStorageId = @intCustomerStorageId AND intItemId = @intStorageChargeItemId
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
							 @intContractDetailId = intContractDetailId
							,@dblContractUnits = dblContractUnits
							,@dblCashPrice = dblCashPrice
							,@intPricingTypeId = intPricingTypeId
							,@dblContractBasis=dblBasis
						FROM @SettleContract
						WHERE intSettleContractKey = @SettleContractKey

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
							)
							SELECT 
								 intCustomerStorageId = @intCustomerStorageId
								,strOrderType		  = 'Contract'
								,intCompanyLocationId = @intCompanyLocationId
								,intContractHeaderId  = @intContractHeaderId
								,intContractDetailId  = @intContractDetailId
								,dblUnits			  = @dblStorageUnits
								,dblCashPrice		  = @dblCashPrice
								,intItemId			  = @ItemId
								,intItemType		  = 1
								,IsProcessed		  = 0
								,intPricingTypeId     = @intPricingTypeId
								,dblBasis             = @dblContractBasis

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

							BREAK;
						END

						SELECT @SettleContractKey = MIN(intSettleContractKey)
						FROM @SettleContract
						WHERE intSettleContractKey > @SettleContractKey AND dblContractUnits > 0
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
					WHERE intSettleStorageKey >= @SettleStorageKey AND dblRemainingUnits > 0
				END
				ELSE
					BREAK;
			END

			BEGIN
				EXEC dbo.uspSMGetStartingNumber 
					 @STARTING_NUMBER_BATCH
					,@strBatchId OUTPUT
				
				SET @intLotId = NULL
				
				SELECT @intLotId = ReceiptItemLot.intLotId
				FROM tblICInventoryReceiptItemLot ReceiptItemLot
				JOIN tblICInventoryReceiptItem ReceiptItem ON ReceiptItem.intInventoryReceiptItemId = ReceiptItemLot.intInventoryReceiptItemId
				JOIN tblICItem Item ON Item.intItemId = ReceiptItem.intItemId
				JOIN tblGRStorageHistory SH ON SH.intInventoryReceiptId=ReceiptItem.intInventoryReceiptId AND SH.strType='FROM Scale'
				JOIN tblGRSettleStorageTicket SST ON SST.intCustomerStorageId=SH.intCustomerStorageId  AND SST.dblUnits > 0
				JOIN tblGRSettleStorage SS ON SS.intSettleStorageId=SST.intSettleStorageId 
				JOIN tblSCTicket SC ON SC.intTicketId=SH.intTicketId
				WHERE SST.intSettleStorageId =@intSettleStorageId

				IF @@ERROR <> 0
				GOTO SettleStorage_Exit;

				DELETE
				FROM @ItemsToStorage

				DELETE
				FROM @ItemsToPost

				DELETE 
				FROM @GLEntries

				SELECT @strOwnedPhysicalStock = ST.strOwnedPhysicalStock
				FROM tblGRCustomerStorage CS 
				JOIN tblGRStorageType ST ON ST.intStorageScheduleTypeId = CS.intStorageTypeId
				WHERE CS.intCustomerStorageId = @intCustomerStorageId
				
				SELECT TOP 1 @intReceiptId = intInventoryReceiptId
				FROM tblGRStorageHistory
				WHERE strType = 'FROM Scale' AND intCustomerStorageId = @intCustomerStorageId

				INSERT INTO @ItemsToStorage 
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
				)
				SELECT intItemId				=  SV.[intItemId]
					,intItemLocationId			=  @ItemLocationId
					,intItemUOMId				=  @intInventoryItemStockUOMId
					,dtmDate					=  GETDATE()
					,dblQty						= CASE 
														WHEN @strOwnedPhysicalStock ='Customer' THEN
																										CASE 
														WHEN 
															dbo.fnCTConvertQuantityToTargetItemUOM(CS.intItemId, CU.intUnitMeasureId, CS.intUnitMeasureId, SV.[dblUnits])-ItemStock.dblUnitStorage >0 
															AND dbo.fnCTConvertQuantityToTargetItemUOM(CS.intItemId, CU.intUnitMeasureId, CS.intUnitMeasureId, SV.[dblUnits])-ItemStock.dblUnitStorage < 0.00001
															THEN - ROUND(dbo.fnCTConvertQuantityToTargetItemUOM(CS.intItemId, CU.intUnitMeasureId, CS.intUnitMeasureId, SV.[dblUnits]),5)
														ELSE
																-dbo.fnCTConvertQuantityToTargetItemUOM(CS.intItemId, CU.intUnitMeasureId, CS.intUnitMeasureId, SV.[dblUnits])
													END
														ELSE 0 
												  END			
					,dblUOMQty					=  @dblUOMQty
					,dblCost					=  CASE 
														WHEN SV.intPricingTypeId=1 OR SV.intPricingTypeId IS NULL THEN SV.[dblCashPrice]
														ELSE @dblFutureMarkePrice + ISNULL(SV.dblBasis,0)
												   END
					,dblSalesPrice				= 0.00
					,intCurrencyId				= @intCurrencyId
					,dblExchangeRate			= 1
					,intTransactionId			= @intSettleStorageId
					,intTransactionDetailId		= @intSettleStorageId
					,strTransactionId			= @TicketNo
					,intTransactionTypeId		= 44
					,intLotId					= @intLotId
					,intSubLocationId			= CS.intCompanyLocationSubLocationId
					,intStorageLocationId		= CS.intStorageLocationId
					,ysnIsStorage				= 1
				FROM @SettleVoucherCreate SV
				JOIN tblGRCustomerStorage CS ON CS.intCustomerStorageId = SV.intCustomerStorageId
				JOIN tblICCommodityUnitMeasure CU ON CU.intCommodityId = CS.intCommodityId AND CU.ysnStockUnit = 1
				JOIN tblGRStorageType St ON St.intStorageScheduleTypeId = CS.intStorageTypeId AND SV.intItemType = 1			
				JOIN tblICItemStock ItemStock ON ItemStock.intItemId=CS.intItemId AND ItemStock.intItemLocationId = @ItemLocationId

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
				 )
				SELECT 
					 intItemId					= SV.[intItemId]
					,intItemLocationId			= @ItemLocationId
					,intItemUOMId				= @intInventoryItemStockUOMId
					,dtmDate					= GETDATE()
					,dblQty						= CASE 
														WHEN @strOwnedPhysicalStock ='Customer' THEN dbo.fnCTConvertQuantityToTargetItemUOM(CS.intItemId, CU.intUnitMeasureId, CS.intUnitMeasureId, SV.[dblUnits])
												        ELSE 0
												  END
					,dblUOMQty					= @dblUOMQty
					,dblCost					= CASE 
														WHEN SV.intPricingTypeId=1 OR SV.intPricingTypeId IS NULL THEN SV.[dblCashPrice]
														ELSE @dblFutureMarkePrice + ISNULL(SV.dblBasis,0)
												   END
					,dblSalesPrice				= 0.00
					,intCurrencyId				= @intCurrencyId
					,dblExchangeRate			= 1
					,intTransactionId			= @intSettleStorageId
					,intTransactionDetailId		= @intSettleStorageId
					,strTransactionId			= @TicketNo
					,intTransactionTypeId		= 44
					,intLotId					= @intLotId
					,intSubLocationId			= CS.intCompanyLocationSubLocationId
					,intStorageLocationId		= CS.intStorageLocationId
					,ysnIsStorage				= 0
				FROM @SettleVoucherCreate SV
				JOIN tblGRCustomerStorage CS ON CS.intCustomerStorageId = SV.intCustomerStorageId
				JOIN tblICCommodityUnitMeasure CU ON CU.intCommodityId = CS.intCommodityId AND CU.ysnStockUnit = 1
				WHERE SV.intItemType = 1

				--Reduce the On-Storage Quantity		
				BEGIN
					EXEC uspICPostStorage 
						 @ItemsToStorage
						,@strBatchId
						,@intCreatedUserId

					IF @@ERROR <> 0
						GOTO SettleStorage_Exit;
				END

				BEGIN
					  SELECT @dblUnits = SUM(dblUnits) FROM @SettleVoucherCreate WHERE intItemType = 1
					  
					  SELECT @dblSettlementRatio = @dblUnits / dblOriginalBalance 
					  FROM vyuGRStorageSearchView WHERE intCustomerStorageId = @intCustomerStorageId
					  
					  SELECT @dblOriginalInventoryGLAmount = SUM(dblOpenReceive*dblUnitCost) 
					  FROM tblICInventoryReceiptItem WHERE intInventoryReceiptId = @intReceiptId

				END
				
				BEGIN
									
						IF @strOwnedPhysicalStock ='Customer' 
						BEGIN

							DELETE FROM @GLEntries

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
					EXEC	@intReturnValue = dbo.uspICPostCosting  
							@ItemsToPost  
							,@strBatchId  
							,'AP Clearing'
							,@intCreatedUserId
					
					IF @intReturnValue < 0
						GOTO SettleStorage_Exit;

					IF EXISTS (SELECT TOP 1 1 FROM @GLEntries)
					BEGIN 
							EXEC dbo.uspGLBookEntries @GLEntries, @ysnPosted 
					END 
						    
							DELETE FROM @GLEntries
							
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
							EXEC uspGRCreateGLEntries 
							 'Storage Settlement'
							,'OtherCharges'
							,@intSettleStorageId
							,@strBatchId
							,@intCreatedUserId
							,@ysnPosted
							IF EXISTS (SELECT TOP 1 1 FROM @GLEntries) 
							BEGIN 
									EXEC dbo.uspGLBookEntries @GLEntries, @ysnPosted 
							END
					END
				END
			END

			---5.Voucher Creation, Update Bill, Tax Computation, Post Bill
			BEGIN
				DELETE
				FROM @voucherDetailStorage

				SET @intCreatedBillId = 0
				UPDATE a
				SET a.dblUnits=ISNULL(b.dblSettleUnits,0)
				FROM @SettleVoucherCreate a
				LEFT JOIN 
				(
					SELECT intCustomerStorageId,SUM(dblUnits) dblSettleUnits FROM @SettleVoucherCreate WHERE intItemType=1 AND (intPricingTypeId=1 OR intPricingTypeId IS NULL)
					GROUP BY intCustomerStorageId
				)b ON b.intCustomerStorageId=a.intCustomerStorageId
				WHERE a.intItemType=3
		     
			 IF EXISTS(SELECT 1 FROM @SettleVoucherCreate WHERE ISNULL(dblCashPrice,0) <> 0 AND ISNULL(dblUnits,0) <> 0 )
			 BEGIN

				INSERT INTO @voucherDetailStorage 
				(
					 [intCustomerStorageId]
					,[intItemId]
					,[intAccountId]
					,[dblQtyReceived]
					,[strMiscDescription]
					,[dblCost]
					,[intContractHeaderId]
					,[intContractDetailId]
					,[intUnitOfMeasureId]
					,[intCostUOMId]
					,[dblWeightUnitQty]
					,[dblCostUnitQty]
					,[dblUnitQty]
					,[dblNetWeight]
				 )
				SELECT 
					 [intCustomerStorageId]		= a.[intCustomerStorageId]
					,[intItemId]				= a.[intItemId]
					,[intAccountId]				= NULL
					--,[dblQtyReceived]			= a.dblUnits
					,[dblQtyReceived]			= ROUND(dbo.fnCalculateQtyBetweenUOM(b.intItemUOMId,@intCashPriceUOMId,a.dblUnits),2)
					,[strMiscDescription]		= c.[strItemNo]
					,[dblCost]					= a.[dblCashPrice]
					,[intContractHeaderId]		= a.[intContractHeaderId]
					,[intContractDetailId]		= a.[intContractDetailId]
					--,[intUnitOfMeasureId]		= b.intItemUOMId
					,[intUnitOfMeasureId]		= @intCashPriceUOMId
					,[intCostUOMId]				= @intCashPriceUOMId --b.intItemUOMId
					,[dblWeightUnitQty]			= 1 
					,[dblCostUnitQty]			= 1 
					,[dblUnitQty]				= 1
					,[dblNetWeight]				= 0 
				FROM @SettleVoucherCreate a
				JOIN tblICItemUOM b ON b.intItemId = a.intItemId AND b.intUnitMeasureId = @intUnitMeasureId
				JOIN tblICItem c ON c.intItemId = a.intItemId
				JOIN tblGRSettleStorageTicket SST ON SST.intCustomerStorageId = a.intCustomerStorageId			
				WHERE a.dblCashPrice <> 0 AND a.dblUnits <> 0 AND SST.intSettleStorageId=@intSettleStorageId 
				ORDER BY SST.intSettleStorageTicketId,a.intItemType
	 
				---Adding Freight Charges.
				INSERT INTO @voucherDetailStorage 
				(
					 [intCustomerStorageId]
					,[intItemId]
					,[intAccountId]
					,[dblQtyReceived]
					,[strMiscDescription]
					,[dblCost]
					,[intContractHeaderId]
					,[intContractDetailId]
					,[intUnitOfMeasureId]
					,[intCostUOMId]
					,[dblWeightUnitQty]
					,[dblCostUnitQty]
					,[dblUnitQty]
					,[dblNetWeight]
				 )
				 SELECT 
				 intCustomerStorageId = SST.intCustomerStorageId
				,intItemId = ReceiptCharge.[intChargeId]
				,[intAccountId] = NULL
				,[dblQtyReceived]	  = CASE WHEN ISNULL(Item.strCostMethod,'')='Gross Unit' THEN (SC.dblGrossUnits/SC.dblNetUnits) * SST.dblUnits ELSE SST.dblUnits END
				,[strMiscDescription] = Item.[strItemNo]
				,[dblCost] = CASE 
  											WHEN ReceiptCharge.intEntityVendorId = SS.intEntityId AND ISNULL(ReceiptCharge.ysnAccrue, 0) = 1 AND ISNULL(ReceiptCharge.ysnPrice, 0) = 0 THEN    ROUND(dbo.fnCTConvertQuantityToTargetItemUOM(CS.intItemId, CU.intUnitMeasureId, CS.intUnitMeasureId, SC.dblFreightRate),2)
  											WHEN ReceiptCharge.intEntityVendorId = SS.intEntityId AND ISNULL(ReceiptCharge.ysnAccrue, 0) = 0 AND ISNULL(ReceiptCharge.ysnPrice, 0) = 1 THEN -  ROUND(dbo.fnCTConvertQuantityToTargetItemUOM(CS.intItemId, CU.intUnitMeasureId, CS.intUnitMeasureId, SC.dblFreightRate), 2)
  											WHEN ReceiptCharge.intEntityVendorId <> SS.intEntityId AND ISNULL(ReceiptCharge.ysnAccrue, 0) = 1 AND ISNULL(ReceiptCharge.ysnPrice, 0) = 1 THEN - ROUND(dbo.fnCTConvertQuantityToTargetItemUOM(CS.intItemId, CU.intUnitMeasureId, CS.intUnitMeasureId, SC.dblFreightRate), 2)
											  WHEN ReceiptCharge.intEntityVendorId = SS.intEntityId  AND  ISNULL(ReceiptCharge.ysnAccrue, 0) = 0 AND ISNULL(SC.ysnFarmerPaysFreight, 0) = 1 THEN	- ROUND(dbo.fnCTConvertQuantityToTargetItemUOM(CS.intItemId, CU.intUnitMeasureId, CS.intUnitMeasureId, SC.dblFreightRate), 2)
											  WHEN ReceiptCharge.intEntityVendorId <> SS.intEntityId AND  ISNULL(ReceiptCharge.ysnAccrue, 0) = 1 AND ISNULL(SC.ysnFarmerPaysFreight, 0) = 1 THEN	- ROUND(dbo.fnCTConvertQuantityToTargetItemUOM(CS.intItemId, CU.intUnitMeasureId, CS.intUnitMeasureId, SC.dblFreightRate), 2)
							        END
				,[intContractHeaderId] = NULL
				,[intContractDetailId] = NULL
				--,[intUnitOfMeasureId] = ReceiptCharge.intCostUOMId
				,[intUnitOfMeasureId] = @intCashPriceUOMId
				,[intCostUOMId]	= @intCashPriceUOMId --ReceiptCharge.intCostUOMId
				,[dblWeightUnitQty] = 1
				,[dblCostUnitQty] = 1
				,[dblUnitQty] =1
				,[dblNetWeight] = 0	
				FROM tblICInventoryReceiptCharge ReceiptCharge
				JOIN tblICItem Item ON Item.intItemId = ReceiptCharge.intChargeId
				JOIN tblGRStorageHistory SH ON SH.intInventoryReceiptId=ReceiptCharge.intInventoryReceiptId AND SH.strType='FROM Scale'
				JOIN tblGRSettleStorageTicket SST ON SST.intCustomerStorageId=SH.intCustomerStorageId  AND SST.dblUnits > 0
				JOIN tblGRSettleStorage SS ON SS.intSettleStorageId=SST.intSettleStorageId 
				JOIN tblSCTicket SC ON SC.intTicketId=SH.intTicketId
				JOIN tblGRCustomerStorage CS ON CS.intCustomerStorageId=SST.intCustomerStorageId
				JOIN tblICCommodityUnitMeasure CU ON CU.intCommodityId = CS.intCommodityId AND CU.ysnStockUnit = 1
				JOIN tblSCScaleSetup ScaleSetup ON ScaleSetup.intScaleSetupId = SC.intScaleSetupId AND ScaleSetup.intFreightItemId=ReceiptCharge.[intChargeId]
				WHERE SST.intSettleStorageId = @intSettleStorageId
				AND 
				(
				 (ReceiptCharge.intEntityVendorId = SS.intEntityId AND ISNULL(ReceiptCharge.ysnAccrue, 0) = 1 AND ISNULL(ReceiptCharge.ysnPrice, 0) = 0)
				 OR
				 (ReceiptCharge.intEntityVendorId = SS.intEntityId AND ISNULL(ReceiptCharge.ysnAccrue, 0) = 0 AND ISNULL(ReceiptCharge.ysnPrice, 0) = 1)
				  OR
				 (ReceiptCharge.intEntityVendorId <> SS.intEntityId AND ISNULL(ReceiptCharge.ysnAccrue, 0) = 1 AND ISNULL(ReceiptCharge.ysnPrice, 0) = 1)
				  OR
				 (ReceiptCharge.intEntityVendorId <> SS.intEntityId AND  ISNULL(ReceiptCharge.ysnAccrue, 0) = 1 AND ISNULL(SC.ysnFarmerPaysFreight, 0) = 1)
				 OR
				 (ReceiptCharge.intEntityVendorId <> SS.intEntityId AND  ISNULL(ReceiptCharge.ysnAccrue, 0) = 1 AND ISNULL(SC.ysnFarmerPaysFreight, 0) = 1)
				)
								
				---Adding Contract Other Charges.
				INSERT INTO @voucherDetailStorage 
				(
					 [intCustomerStorageId]
					,[intItemId]
					,[intAccountId]
					,[dblQtyReceived]
					,[strMiscDescription]
					,[dblCost]
					,[intContractHeaderId]
					,[intContractDetailId]
					,[intUnitOfMeasureId]
					,[intCostUOMId]
					,[dblWeightUnitQty]
					,[dblCostUnitQty]
					,[dblUnitQty]
					,[dblNetWeight]
				 )
				 SELECT 
				  [intCustomerStorageId]  = SV.[intCustomerStorageId]
				 ,[intItemId]			  = CC.[intItemId]
				 ,[intAccountId]		  = NULL
				 ,[dblQtyReceived]		  = CASE 
												WHEN CC.intItemUOMId IS NOT NULL THEN  dbo.fnCTConvertQuantityToTargetItemUOM(CC.intItemId,UOM.intUnitMeasureId,@intUnitMeasureId,SV.dblUnits)
												ELSE SV.dblUnits 
											END
				 ,[strMiscDescription]	  = Item.[strItemNo]
				 ,[dblCost]				  = (
											  CASE 
											  		WHEN CC.intCurrencyId IS NOT NULL AND ISNULL(CC.intCurrencyId,0)<> ISNULL(CD.intInvoiceCurrencyId, CD.intCurrencyId) THEN [dbo].[fnCTCalculateAmountBetweenCurrency](CC.intCurrencyId, ISNULL(CD.intInvoiceCurrencyId, CD.intCurrencyId), CC.dblRate, 1)
											  		ELSE  CC.dblRate
											  END
											 )
											 /											
											 (CASE 
												WHEN CC.strCostMethod ='Per Unit' THEN 1
												WHEN CC.strCostMethod ='Amount'	  THEN 
																					   CASE 
																							WHEN CC.intItemUOMId IS NOT NULL THEN  dbo.fnCTConvertQuantityToTargetItemUOM(CC.intItemId,UOM.intUnitMeasureId,@intUnitMeasureId,SV.dblUnits)
																							ELSE SV.dblUnits 
																						END
											 END)
				 ,[intContractHeaderId]	  = CD.[intContractHeaderId]
				 ,[intContractDetailId]	  = CD.[intContractDetailId]
				 --,[intUnitOfMeasureId]	  = CC.intItemUOMId
				 ,[intUnitOfMeasureId]	  = @intCashPriceUOMId
				 ,[intCostUOMId]		  = @intCashPriceUOMId --CC.intItemUOMId
				 ,[dblWeightUnitQty]	  = 1 
				 ,[dblCostUnitQty]		  = 1 
				 ,[dblUnitQty]			  = 1
				 ,[dblNetWeight]		  = 0 
				 FROM 
				 tblCTContractCost CC 
				 JOIN tblCTContractDetail CD ON CD.intContractDetailId =  CC.intContractDetailId
				 JOIN @SettleVoucherCreate SV ON SV.intContractDetailId = CD.intContractDetailId AND SV.intItemType = 1
				 JOIN tblICItem Item ON Item.intItemId = CC.intItemId
				 LEFT JOIN tblICItemUOM UOM ON UOM.intItemUOMId = CC.intItemUOMId
				
				UPDATE @voucherDetailStorage SET dblQtyReceived = dblQtyReceived* -1 WHERE ISNULL(dblCost,0) < 0
				UPDATE @voucherDetailStorage SET dblCost = dblCost* -1 WHERE ISNULL(dblCost,0) < 0
				 
				EXEC [dbo].[uspAPCreateBillData] 
					 @userId = @intCreatedUserId
					,@vendorId = @EntityId
					,@type = 1
					,@voucherDetailStorage = @voucherDetailStorage
					,@shipTo = @LocationId
					,@vendorOrderNumber = NULL
					,@voucherDate = @dtmDate
					,@billId = @intCreatedBillId OUTPUT

				IF @intCreatedBillId IS NOT NULL
				BEGIN
					SELECT @strVoucher = strBillId
					FROM tblAPBill
					WHERE intBillId = @intCreatedBillId

					DELETE
					FROM @detailCreated

					INSERT INTO @detailCreated
					SELECT intBillDetailId
					FROM tblAPBillDetail
					WHERE intBillId = @intCreatedBillId

					EXEC [uspAPUpdateVoucherDetailTax] @detailCreated

					IF @@ERROR <> 0
						GOTO SettleStorage_Exit;

					UPDATE bd
					SET bd.dblRate = CASE 
											WHEN ISNULL(bd.dblRate, 0) = 0 THEN 1
											ELSE bd.dblRate
									 END
					FROM tblAPBillDetail bd
					WHERE bd.intBillId = @intCreatedBillId

					UPDATE tblAPBill
					SET strVendorOrderNumber = @TicketNo
						,dblTotal = (
										SELECT ROUND(SUM(bd.dblTotal) + SUM(bd.dblTax), 2)
										FROM tblAPBillDetail bd
										WHERE bd.intBillId = @intCreatedBillId
									)
					WHERE intBillId = @intCreatedBillId

					IF @@ERROR <> 0
						GOTO SettleStorage_Exit;
                    
					SELECT @dblTotal = SUM(dblTotal) FROM tblAPBillDetail WHERE intBillId = @intCreatedBillId
					
					EXEC [dbo].[uspSMTransactionCheckIfRequiredApproval]
								@type = N'AccountsPayable.view.Voucher',
								@transactionEntityId = @EntityId,
								@currentUserEntityId = @intCreatedUserId,
								@locationId = @LocationId,
								@amount = @dblTotal,
								@requireApproval = @requireApproval OUTPUT
					
					IF ISNULL(@dblTotal,0) > 0 AND ISNULL(@requireApproval , 0) = 0
					BEGIN
							EXEC [dbo].[uspAPPostBill] 
								 @post = 1
								,@recap = 0
								,@isBatch = 0
								,@param = @intCreatedBillId
								,@userId = @intCreatedUserId
								,@success = @success OUTPUT
					END

					IF @@ERROR <> 0
						GOTO SettleStorage_Exit;
				END
			
			END

			END

			-------------------------xxxxxxxxxxxxxxxxxx------------------------------
			---6.DP Contract Depletion, Purchase Contract Depletion,Storage Ticket Depletion
			BEGIN

				SELECT @intDepletionKey = MIN(intDepletionKey)
				FROM @tblDepletion

				WHILE @intDepletionKey > 0
				BEGIN
					SET @intSettleStorageTicketId = NULL
					SET @intPricingTypeId = NULL
					SET @intContractDetailId = NULL
					SET @intCustomerStorageId = NULL
					SET @dblUnits = NULL
					SET @CommodityStockUomId = NULL
					SET @dblCost = NULL

					SELECT 
						 @intSettleStorageTicketId = intSettleStorageTicketId
						,@intPricingTypeId = intPricingTypeId
						,@intContractDetailId = intContractDetailId
						,@intCustomerStorageId = intCustomerStorageId
						,@dblUnits = dblUnits
						,@CommodityStockUomId = intSourceItemUOMId
						,@dblCost = dblCost
					FROM @tblDepletion
					WHERE intDepletionKey = @intDepletionKey

					IF @intPricingTypeId = 5
					BEGIN
						EXEC uspCTUpdateSequenceQuantityUsingUOM 
							 @intContractDetailId = @intContractDetailId
							,@dblQuantityToUpdate = @dblUnits
							,@intUserId = @intCreatedUserId
							,@intExternalId = @intSettleStorageTicketId
							,@strScreenName = 'Settle Storage'
							,@intSourceItemUOMId = @CommodityStockUomId
					END
					ELSE
					BEGIN
						EXEC uspCTUpdateSequenceBalance 
							 @intContractDetailId = @intContractDetailId
							,@dblQuantityToUpdate = @dblUnits
							,@intUserId = @intCreatedUserId
							,@intExternalId = @intSettleStorageTicketId
							,@strScreenName = 'Settle Storage'
					END

					SELECT @intDepletionKey = MIN(intDepletionKey)
					FROM @tblDepletion
					WHERE intDepletionKey > @intDepletionKey
				END

				UPDATE CS
				SET CS.dblOpenBalance 
					 = CASE 
							WHEN ROUND(CS.dblOpenBalance - dbo.fnCTConvertQuantityToTargetItemUOM(CS.intItemId,CU.intUnitMeasureId,CS.intUnitMeasureId,SH.dblUnit),4,1) > 0.0009 
									THEN ROUND(CS.dblOpenBalance - dbo.fnCTConvertQuantityToTargetItemUOM(CS.intItemId,CU.intUnitMeasureId,CS.intUnitMeasureId,SH.dblUnit),4)
							ELSE 0
					   END				    
				FROM tblGRCustomerStorage CS
				JOIN tblICCommodityUnitMeasure CU ON CU.intCommodityId=CS.intCommodityId AND CU.ysnStockUnit=1
				JOIN (
						SELECT intCustomerStorageId
							,SUM(dblUnits) dblUnit
						FROM @SettleVoucherCreate
						WHERE intItemType = 1
						GROUP BY intCustomerStorageId
					 ) SH ON SH.intCustomerStorageId = CS.intCustomerStorageId
			END

			--7. HiStory Creation
			BEGIN
				INSERT INTO [dbo].[tblGRStorageHistory] 
				(
					[intConcurrencyId]
					,[intCustomerStorageId]
					,[intContractHeaderId]
					,[dblUnits]
					,[dtmHistoryDate]
					,[strType]
					,[strUserName]
					,[intEntityId]
					,[strSettleTicket]
					,[intTransactionTypeId]
					,[dblPaidAmount]
					,[intBillId]
					,[intSettleStorageId]
					,[strVoucher]
				)
				SELECT 
					 [intConcurrencyId]     = 1 
					,[intCustomerStorageId] = SV.[intCustomerStorageId]
					,[intContractHeaderId]  = SV.[intContractHeaderId]
					,[dblUnits]				= dbo.fnCTConvertQuantityToTargetItemUOM(CS.intItemId,CU.intUnitMeasureId,CS.intUnitMeasureId,SV.[dblUnits])
					,[dtmHistoryDate]		= GETDATE()
					,[strType]				= 'Settlement'
					,[strUserName]			= @UserName 
					,[intEntityId]			= @EntityId
					,[strSettleTicket]		= @TicketNo
					,[intTransactionTypeId]	= 4 
					,[dblPaidAmount]		= SV.dblCashPrice
					,[intBillId]			= CASE WHEN @intCreatedBillId=0 THEN NULL ELSE @intCreatedBillId END
					,intSettleStorageId		= @intSettleStorageId
					,strVoucher				= @strVoucher
				FROM @SettleVoucherCreate SV
				JOIN tblGRCustomerStorage CS ON CS.intCustomerStorageId=SV.intCustomerStorageId
				JOIN tblICCommodityUnitMeasure CU ON CU.intCommodityId=CS.intCommodityId AND CU.ysnStockUnit=1
				WHERE SV.intItemType = 1
			END

			UPDATE tblGRSettleStorage
			SET ysnPosted = 1,intBillId = CASE WHEN @intCreatedBillId=0 THEN NULL ELSE @intCreatedBillId END
			WHERE intSettleStorageId = @intSettleStorageId
		END

	SELECT @intSettleStorageId = MIN(intSettleStorageId)
	FROM tblGRSettleStorage
	WHERE intParentSettleStorageId =@intParentSettleStorageId AND intSettleStorageId > @intSettleStorageId

	END

	UPDATE tblGRSettleStorage
	SET ysnPosted = 1
	WHERE intSettleStorageId = @intParentSettleStorageId

	SettleStorage_Exit:
END TRY

BEGIN CATCH
	SET @ErrMsg = ERROR_MESSAGE()
	RAISERROR (@ErrMsg,16,1,'WITH NOWAIT')
END CATCH
