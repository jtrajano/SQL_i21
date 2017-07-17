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
	)

	/*	intItemType
			------------
			1-Inventory
			2-Storage Charge
			3-Discount
			4-Fee
	   */
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
	FROM tblGRSettleStorage
	WHERE intSettleStorageId = @intSettleStorageId

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
	FROM tblICItemStockUOM
	WHERE intItemId = @ItemId

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
			 SST.intSettleStorageTicketId
			,SST.intCustomerStorageId
			,SST.dblUnits
			,SST.dblUnits
			,SSV.dblOpenBalance
			,SSV.strStorageTicketNumber
			,SSV.intCompanyLocationId
			,SSV.intStorageTypeId
			,SSV.intStorageScheduleId
			,SSV.intContractHeaderId
		FROM tblGRSettleStorageTicket SST
		JOIN vyuGRStorageSearchView SSV ON SSV.intCustomerStorageId = SST.intCustomerStorageId
		WHERE SST.intSettleStorageId = @intSettleStorageId
		ORDER BY SST.intSettleStorageTicketId

		INSERT INTO @SettleContract 
		(
			intSettleContractId
			,intContractDetailId
			,dblContractUnits
			,ContractEntityId
			,dblCashPrice
		)
		SELECT 
			 SSC.intSettleContractId AS intSettleContractId
			,SSC.intContractDetailId AS intContractDetailId
			,SSC.dblUnits AS dblContractUnits
			,CD.intEntityId AS ContractEntityId
			,CD.dblCashPriceInCommodityStockUOM AS dblCashPrice
		FROM tblGRSettleContract SSC
		JOIN vyuGRGetContracts CD ON CD.intContractDetailId = SSC.intContractDetailId
		WHERE intSettleStorageId = @intSettleStorageId
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
				 CS.intCustomerStorageId AS intCustomerStorageId
				,CS.intCompanyLocationId AS intCompanyLocationId
				,NULL AS intContractHeaderId
				,NULL AS intContractDetailId
				,SST.dblUnits AS dblUnits
				,dbo.fnCTConvertQuantityToTargetItemUOM(CS.intItemId, CU.intUnitMeasureId, CS.intUnitMeasureId, ISNULL(QM.dblDiscountPaid, 0)) - dbo.fnCTConvertQuantityToTargetItemUOM(CS.intItemId, CU.intUnitMeasureId, CS.intUnitMeasureId, ISNULL(QM.dblDiscountDue, 0)) AS dblCashPrice
				,DItem.intItemId AS intItemId
				,3 AS intItemType
				,0 AS IsProcessed
				,QM.intTicketDiscountId AS intTicketDiscountId
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
				 SST.intCustomerStorageId AS intCustomerStorageId
				,CS.intCompanyLocationId AS intCompanyLocationId
				,NULL AS intContractHeaderId
				,NULL AS intContractDetailId
				,SST.dblUnits AS dblUnits
				,(ISNULL(dblFeesPaid, 0) - ISNULL(dblFeesDue, 0)) AS dblCashPrice
				,@FeeItemId AS intItemId
				,4 AS intItemType
				,0 AS IsProcessed
			FROM tblGRCustomerStorage CS
			JOIN tblGRSettleStorageTicket SST ON SST.intCustomerStorageId = CS.intCustomerStorageId AND SST.intSettleStorageId = @intSettleStorageId AND SST.dblUnits > 0
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

			--Storage Due		
			SET @dblStorageDuePerUnit = 0
			SET @dblStorageDueAmount = 0
			SET @dblStorageDueTotalPerUnit = 0
			SET @dblStorageDueTotalAmount = 0
			SET @dblStorageBilledPerUnit = 0
			SET @dblStorageBilledAmount = 0
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
					 @intCustomerStorageId
					,@intCompanyLocationId
					,NULL
					,NULL
					,@dblStorageUnits
					,- @dblTicketStorageDue
					,@intStorageChargeItemId
					,2
					,0
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
					 @intSettleStorageTicketId AS intSettleStorageTicketId
					,5 AS intPricingTypeId
					,'DP Contract' AS strDepletionType
					,@DPContractHeaderId AS intContractHeaderId
					,@ContractDetailId AS intContractDetailId
					,@intCustomerStorageId AS intCustomerStorageId
					,- @dblStorageUnits AS dblUnits
					,@CommodityStockUomId AS intSourceItemUOMId
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

				WHILE @SettleContractKey > 0
				BEGIN
					SELECT 
						 @intContractDetailId = intContractDetailId
						,@dblContractUnits = dblContractUnits
						,@dblCashPrice = dblCashPrice
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
							@intSettleStorageTicketId AS intSettleStorageTicketId
							,1 AS intPricingTypeId
							,'Purchase Contract' AS strDepletionType
							,0 AS intContractHeaderId
							,@intContractDetailId AS intContractDetailId
							,@intCustomerStorageId AS intCustomerStorageId
							,@dblUnitsForContract AS dblUnits

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
							 @intCustomerStorageId
							,'Purchase Contract'
							,@intCompanyLocationId
							,@intContractHeaderId
							,@intContractDetailId
							,@dblStorageUnits
							,@dblCashPrice
							,@ItemId
							,1
							,0

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
							 @intSettleStorageTicketId AS intSettleStorageTicketId
							,1 AS intPricingTypeId
							,'Purchase Contract' AS strDepletionType
							,0 AS intContractHeaderId
							,@intContractDetailId AS intContractDetailId
							,@intCustomerStorageId AS intCustomerStorageId
							,@dblUnitsForContract AS dblUnits

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
							 @intCustomerStorageId
							,'Purchase Contract'
							,@intCompanyLocationId
							,@intContractHeaderId
							,@intContractDetailId
							,@dblContractUnits
							,@dblCashPrice
							,@ItemId
							,1
							,0

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
						 @intCustomerStorageId
						,'Direct'
						,@intCompanyLocationId
						,NULL
						,NULL
						,@dblStorageUnits
						,@dblSpotCashPrice
						,@ItemId
						,1
						,0
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
						 @intCustomerStorageId
						,'Direct'
						,@intCompanyLocationId
						,NULL
						,NULL
						,@dblSpotUnits
						,@dblSpotCashPrice
						,@ItemId
						,1
						,0

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

			IF @@ERROR <> 0
			GOTO SettleStorage_Exit;

			DELETE
			FROM @ItemsToStorage

			DELETE
			FROM @ItemsToPost

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
				,intSubLocationId
				,intStorageLocationId
				,ysnIsStorage
			)
			SELECT intItemId = SV.[intItemId]
				,intItemLocationId = @ItemLocationId
				,intItemUOMId = @intInventoryItemStockUOMId
				,dtmDate = GETDATE()
				,dblQty = - dbo.fnCTConvertQuantityToTargetItemUOM(CS.intItemId, CU.intUnitMeasureId, CS.intUnitMeasureId, SV.[dblUnits])
				,dblUOMQty = @dblUOMQty
				,dblCost = CASE 
								WHEN St.ysnDPOwnedType = 0 THEN SV.[dblCashPrice]
								ELSE 0
						   END
				,dblSalesPrice = 0.00
				,intCurrencyId = @intCurrencyId
				,dblExchangeRate = 1
				,intTransactionId = @intSettleStorageId
				,intTransactionDetailId = @intSettleStorageId
				,strTransactionId = @TicketNo
				,intTransactionTypeId = 44
				,intSubLocationId = CS.intCompanyLocationSubLocationId
				,intStorageLocationId = CS.intStorageLocationId
				,ysnIsStorage = 1
			FROM @SettleVoucherCreate SV
			JOIN tblGRCustomerStorage CS ON CS.intCustomerStorageId = SV.intCustomerStorageId
			JOIN tblICCommodityUnitMeasure CU ON CU.intCommodityId = CS.intCommodityId AND CU.ysnStockUnit = 1
			JOIN tblGRStorageType St ON St.intStorageScheduleTypeId = CS.intStorageTypeId AND SV.intItemType = 1

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
				,intSubLocationId
				,intStorageLocationId
				,ysnIsStorage
			 )
			SELECT 
				 intItemId = SV.[intItemId]
				,intItemLocationId = @ItemLocationId
				,intItemUOMId = @intInventoryItemStockUOMId
				,dtmDate = GETDATE()
				,dblQty = dbo.fnCTConvertQuantityToTargetItemUOM(CS.intItemId, CU.intUnitMeasureId, CS.intUnitMeasureId, SV.[dblUnits])
				,dblUOMQty = @dblUOMQty
				,dblCost = CASE 
								WHEN St.ysnDPOwnedType = 0 THEN SV.[dblCashPrice]
								ELSE 0
						   END
				,dblSalesPrice = 0.00
				,intCurrencyId = @intCurrencyId
				,dblExchangeRate = 1
				,intTransactionId = @intSettleStorageId
				,intTransactionDetailId = @intSettleStorageId
				,strTransactionId = @TicketNo
				,intTransactionTypeId = 44
				,intSubLocationId = CS.intCompanyLocationSubLocationId
				,intStorageLocationId = CS.intStorageLocationId
				,ysnIsStorage = 0
			FROM @SettleVoucherCreate SV
			JOIN tblGRCustomerStorage CS ON CS.intCustomerStorageId = SV.intCustomerStorageId
			JOIN tblICCommodityUnitMeasure CU ON CU.intCommodityId = CS.intCommodityId AND CU.ysnStockUnit = 1
			JOIN tblGRStorageType St ON St.intStorageScheduleTypeId = CS.intStorageTypeId
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
				EXEC uspICPostCosting 
					 @ItemsToPost
					,@strBatchId
					,'Cost of Goods'
					,@intCreatedUserId

				IF @@ERROR <> 0
					GOTO SettleStorage_Exit;
			END
		END

		---5.Voucher Creation, Update Bill, Tax Computation, Post Bill
		BEGIN
			DELETE
			FROM @voucherDetailStorage

			SET @intCreatedBillId = 0

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
				,[dblWeightUnitQty]
				,[dblCostUnitQty]
				,[dblUnitQty]
				,[dblNetWeight]
			 )
			SELECT 
				 a.[intCustomerStorageId] AS [intCustomerStorageId]
				,a.[intItemId] AS [intItemId]
				,NULL AS [intAccountId]
				,a.dblUnits AS [dblQtyReceived]
				,c.[strItemNo] AS [strMiscDescription]
				,a.[dblCashPrice] AS [dblCost]
				,a.[intContractHeaderId] AS [intContractHeaderId]
				,a.[intContractDetailId] AS [intContractDetailId]
				,b.intItemUOMId AS [intUnitOfMeasureId]
				,1 AS [dblWeightUnitQty]
				,1 AS [dblCostUnitQty]
				,1 AS [dblUnitQty]
				,0 AS [dblNetWeight]
			FROM @SettleVoucherCreate a
			JOIN tblICItemUOM b ON b.intItemId = a.intItemId AND b.intUnitMeasureId = @intUnitMeasureId
			JOIN tblICItem c ON c.intItemId = a.intItemId --AND c.intItemId=b.intItemId
			JOIN tblGRSettleStorageTicket SST ON SST.intCustomerStorageId = a.intCustomerStorageId
			ORDER BY SST.intSettleStorageTicketId,a.intItemType

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

				EXEC [dbo].[uspAPPostBill] 
					 @post = 1
					,@recap = 0
					,@isBatch = 0
					,@param = @intCreatedBillId
					,@userId = @intCreatedUserId
					,@success = @success OUTPUT

				IF @@ERROR <> 0
					GOTO SettleStorage_Exit;
			END
		END

		-------------------------xxxxxxxxxxxxxxxxxx------------------------------
		---6.DP Contract Depletion, Purchase Contract Depletion,Storage Ticket Depletion
		BEGIN
			DECLARE @intDepletionKey INT
			DECLARE @intPricingTypeId INT
			DECLARE @dblUnits DECIMAL(24, 10)
			DECLARE @dblCost DECIMAL(24, 10)

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
			SET CS.dblOpenBalance = CS.dblOpenBalance - SH.dblUnit
			FROM tblGRCustomerStorage CS
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
				 1 AS [intConcurrencyId]
				,[intCustomerStorageId]
				,[intContractHeaderId]
				,[dblUnits]
				,GETDATE() AS [dtmHistoryDate]
				,'Settlement' AS [strType]
				,@UserName AS [strUserName]
				,@EntityId AS [intEntityId]
				,@TicketNo AS [strSettleTicket]
				,4 AS [intTransactionTypeId]
				,dblCashPrice AS [dblPaidAmount]
				,@intCreatedBillId AS [intBillId]
				,@intSettleStorageId AS intSettleStorageId
				,@strVoucher AS strVoucher
			FROM @SettleVoucherCreate
			WHERE intItemType = 1
		END

		UPDATE tblGRSettleStorage
		SET ysnPosted = 1,intBillId = @intCreatedBillId
		WHERE intSettleStorageId = @intSettleStorageId
	END

	SettleStorage_Exit:
END TRY

BEGIN CATCH
	SET @ErrMsg = ERROR_MESSAGE()
	RAISERROR (@ErrMsg,16,1,'WITH NOWAIT')
END CATCH
