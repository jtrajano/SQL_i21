CREATE PROCEDURE [dbo].[uspGRPostSettleStorage]
	@intSettleStorageId INT
	,@ysnPosted BIT
	,@ysnFromPriceBasisContract BIT = 0
	,@dblCashPriceFromCt DECIMAL(24, 10) = 0
	,@dblQtyFromCt DECIMAL(24,10) = 0
	,@dtmClientPostDate DATETIME = NULL
AS
BEGIN TRY
	SET NOCOUNT ON
	SET ANSI_WARNINGS ON

	DECLARE @ErrMsg NVARCHAR(MAX)
	DECLARE @EntityId INT
	DECLARE @LocationId INT
	DECLARE @ItemId INT
	DECLARE @ysnInventoryCost_ItemId bit
	DECLARE @strItemNo NVARCHAR(20)
	DECLARE @intUnitMeasureId INT
	DECLARE @CommodityStockUomId INT
	DECLARE @TicketNo NVARCHAR(20)
	DECLARE @strVoucher NVARCHAR(20)
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
	DECLARE @intExternalId INT
	DECLARE @strProcessType NVARCHAR(30)
	DECLARE @strUpdateType NVARCHAR(30)
	DECLARE @IntCommodityId INT
	DECLARE @intStorageChargeItemId INT
	DECLARE @ysnInventoryCost_StorageChargeItem bit
	DECLARE @StorageChargeItemDescription NVARCHAR(100)
	DECLARE @dblStorageDuePerUnit DECIMAL(24, 10)
	DECLARE @dblStorageDueAmount DECIMAL(24, 10)
	DECLARE @dblStorageDueTotalPerUnit DECIMAL(24, 10)
	DECLARE @dblStorageDueTotalAmount DECIMAL(24, 10)
	DECLARE @dblStorageBilledPerUnit DECIMAL(24, 10)
	DECLARE @dblStorageBilledAmount DECIMAL(24, 10)
	DECLARE @dblFlatFeeTotal		DECIMAL(24, 10)
	DECLARE @dblTicketStorageDue DECIMAL(24, 10)
	DECLARE @strFeeItem NVARCHAR(40)
	DECLARE @intCurrencyId INT
	DECLARE @strOrderType NVARCHAR(50)
	DECLARE @dblUOMQty NUMERIC(38, 20)
	DECLARE @detailCreated AS Id
	DECLARE @intInventoryItemStockUOMId INT
	DECLARE @dtmDate AS DATETIME
	DECLARE @STARTING_NUMBER_BATCH AS INT = 3	
	DECLARE @ItemsToStorage AS ItemCostingTableType
	DECLARE @ItemsToStorageStaging AS ItemCostingTableType
	DECLARE @ItemsToPost AS ItemCostingTableType
	DECLARE @ItemsToPostStaging AS ItemCostingTableType
	DECLARE @strBatchId AS NVARCHAR(40)
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
	DECLARE @dblFutureMarketPrice DECIMAL(24, 10)
	DECLARE @dblContractBasis DECIMAL(24, 10)
	DECLARE @intParentSettleStorageId INT
	DECLARE @GLEntries AS RecapTableType
	DECLARE @DummyGLEntries AS RecapTableType
	DECLARE @intReturnValue AS INT
	DECLARE @intLotId INT
	DECLARE @requireApproval AS BIT
	DECLARE @dblTotal AS DECIMAL(18,6)
	DECLARE @strOwnedPhysicalStock NVARCHAR(20)
	DECLARE @dblSettlementRatio DECIMAL(24, 10)
	DECLARE @dblOriginalInventoryGLAmount DECIMAL(24, 10)	
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
    DECLARE @intPayToEntityId INT

	DECLARE @voucherPayable VoucherPayable
	DECLARE @voucherPayableTax VoucherDetailTax
	DECLARE @createdVouchersId NVARCHAR(MAX)
	DECLARE @ysnDPOwnedType AS BIT
	DECLARE @ysnFromTransferStorage AS BIT
	DECLARE @IdOutputs nvarchar(max)
	--Get vouchered quantity
	DECLARE @dblTotalVoucheredQuantity AS DECIMAL(24,10)
	-- THIS IS THE STORAGE UNIT
	DECLARE @dblSelectedUnits AS DECIMAL(24,10)
	declare @doPartialHistory bit = 0

	DECLARE @strSettleTicket NVARCHAR(40)

	DECLARE @intStorageHistoryIds AS Id

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
		,ysnTransferStorage BIT
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
		,strPricingTypeHeader NVARCHAR(40) COLLATE Latin1_General_CI_AS NULL
		,intFuturesMonthId int null
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
	DECLARE @SettleVoucherCreate2 AS SettleVoucherCreate
	DECLARE @StorageHistoryStagingTable AS StorageHistoryStagingTable
	DECLARE @intStorageHistoryId AS INT
	DECLARE @VoucherIds AS Id
	DECLARE @dblTotalUnits AS DECIMAL(24,10)

	DECLARE @ysnDeliverySheet AS BIT
		,@ysnStorageChargeAccountUseIncome BIT = 1
	
	--select @ysnStorageChargeAccountUseIncome = ysnStorageChargeAccountUseIncome from tblGRCompanyPreference

	/*	intItemType
		------------
		1-Inventory
		2-Storage Charge
		3-Discount
		4-Fee
   */

	DECLARE @tblGRCustomerOwnedSettleStorageVoucher AS TABLE 
	(
		intSettleStorageId INT
		,strOrderType NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
		,intCustomerStorageId INT
		,intCompanyLocationId INT NULL
		,intContractHeaderId INT NULL
		,intContractDetailId INT NULL
		,dblUnits DECIMAL(24, 10)
		,dblCashPrice DECIMAL(24, 10) NULL
		,intItemId INT NULL
		,intItemType INT NULL
		,IsProcessed BIT NULL
		,intTicketDiscountId INT NULL
		,intPricingTypeId INT NULL
		,dblBasis DECIMAL(24, 10) NULL
		,intContractUOMId INT NULL
		,dblCostUnitQty DECIMAL(24, 10) NULL
		,dblSettleContractUnits DECIMAL(24,10) NULL
		,ysnDiscountFromGrossWeight BIT NULL
		,ysnPercentChargeType BIT NULL
		,dblCashPriceUsed DECIMAL(24,10) --to determine the cash price used in Percent discounts
		,intSettleContractId int null
		,ysnInventoryCost bit null
	)	

   DECLARE @tblCustomerOwnedSettleStorage AS TABLE 
	(
		intSettleStorageId INT
		,dblSelectedUnits DECIMAL(24, 10)
		,dblFutureMarketPrice DECIMAL(24, 10)
	)

	-- Get the Batch Id 
	EXEC dbo.uspSMGetStartingNumber 
		@STARTING_NUMBER_BATCH
		,@strBatchId OUTPUT

	-- Call Starting number for Receipt Detail Update to prevent deadlocks. 
	BEGIN 
		DECLARE @strUpdateRIDetail AS NVARCHAR(50)
		EXEC dbo.uspSMGetStartingNumber 155, @strUpdateRIDetail OUTPUT
	END
			   
	SELECT @intDecimalPrecision = intCurrencyDecimal FROM tblSMCompanyPreference

	SET @dtmDate = GETDATE()
	SET @intParentSettleStorageId = @intSettleStorageId
	SET @dtmClientPostDate = ISNULL(@dtmClientPostDate, GETDATE());
	
	/*avoid the oversettling of storages*/
	IF(@ysnFromPriceBasisContract = 0)
	BEGIN
		DECLARE @CustomerStorageIds AS Id
		DECLARE @intId AS INT
		DECLARE @dblSettlementTotal AS DECIMAL(24,10)		

		DELETE FROM @CustomerStorageIds
		INSERT INTO @CustomerStorageIds
		SELECT intCustomerStorageId FROM tblGRSettleStorageTicket WHERE intSettleStorageId = @intSettleStorageId

		WHILE EXISTS(SELECT 1 FROM @CustomerStorageIds)
		BEGIN
			SELECT TOP 1 @intId = intId FROM @CustomerStorageIds

			SELECT @dblSettlementTotal = SUM(dblUnits) 
			FROM tblGRSettleStorageTicket A
			INNER JOIN tblGRSettleStorage B
				ON B.intSettleStorageId = A.intSettleStorageId
				AND B.intParentSettleStorageId IS NULL
			WHERE intCustomerStorageId = @intId
				--AND A.intSettleStorageId <> @intSettleStorageId

			SELECT @dblTotalUnits = SUM(dblUnits)
			FROM tblGRStorageHistory
			WHERE (intTransactionTypeId IN (5,1,9) OR (intTransactionTypeId = 3 AND strType = 'From Transfer'))
				AND intCustomerStorageId = @intId
			GROUP BY intCustomerStorageId

			IF @dblSettlementTotal > @dblTotalUnits AND ABS(@dblSettlementTotal - @dblTotalUnits) > 0.1
			BEGIN
				RAISERROR('The record has changed. Please refresh screen.',16,1,1)
				RETURN;
			END
			DELETE FROM @CustomerStorageIds WHERE intId = @intId
		END	
	END

	IF @ysnFromPriceBasisContract = 0 
	BEGIN
		DECLARE @invalid_tickets_with_special_discount NVARCHAR(500)
		SET @invalid_tickets_with_special_discount = ''

		SELECT @invalid_tickets_with_special_discount = @invalid_tickets_with_special_discount + d.strTicketNumber + ','
		FROM tblGRSettleStorageTicket  a
		JOIN tblGRSettleStorage b
			ON a.intSettleStorageId= b.intSettleStorageId 
				AND b.intParentSettleStorageId IS NULL
		JOIN tblGRCustomerStorage c
			ON a.intCustomerStorageId = c.intCustomerStorageId
		JOIN tblSCTicket d
			ON c.intTicketId = d.intTicketId
				AND d.ysnHasSpecialDiscount = 1
				AND d.ysnSpecialGradePosted = 0		 
		WHERE a.intSettleStorageId = @intSettleStorageId

		IF REPLACE(LTRIM(RTRIM(@invalid_tickets_with_special_discount)),',', '') <> ''
		BEGIN
			SET @ErrMsg = 'The following Tickets have special discount that is not yet posted ( ' + substring(@invalid_tickets_with_special_discount, 1, len(@invalid_tickets_with_special_discount) - 1) +  ' )'
			RAISERROR(@ErrMsg, 16,1,1)
			RETURN;
		END
	END

	/* create child settle storage (with voucher) 
	NOTE: parent settle storage doesn't have a voucher associated in it */
	IF(@ysnFromPriceBasisContract = 0)
		EXEC uspGRCreateSettleStorage @intSettleStorageId

	SELECT @intSettleStorageId = MIN(intSettleStorageId)
	FROM tblGRSettleStorage
	WHERE CASE WHEN @ysnFromPriceBasisContract = 1 THEN CASE WHEN intSettleStorageId = @intSettleStorageId THEN 1 ELSE 0 END ELSE CASE WHEN intParentSettleStorageId = @intParentSettleStorageId THEN 1 ELSE 0 END END = 1

	SELECT @intPricingTypeId = CD.intPricingTypeId
	FROM tblGRSettleContract SSC
	JOIN vyuGRGetContracts CD 
		ON CD.intContractDetailId = SSC.intContractDetailId
	WHERE intSettleStorageId = @intSettleStorageId

	DELETE FROM @intStorageHistoryIds

	WHILE @intSettleStorageId > 0
	BEGIN		
		DELETE FROM @SettleStorage
		DELETE FROM @SettleContract
		DELETE FROM @tblDepletion
		DELETE FROM @SettleVoucherCreate

		select @TicketNo = dbo.fnGRGetStorageTicket(@intSettleStorageId)

		SELECT 
			@intCreatedUserId 				= intCreatedUserId
			,@EntityId 						= intEntityId
			,@LocationId 					= intCompanyLocationId
			,@ItemId 						= intItemId
			,@TicketNo 						= case when isnull(@TicketNo , '') = '' then strStorageTicket else @TicketNo end 
			,@strStorageAdjustment 			= strStorageAdjustment
			,@dtmCalculateStorageThrough 	= dtmCalculateStorageThrough
			,@dblAdjustPerUnit 				= dblAdjustPerUnit
			,@dblSpotUnits 					= dblSpotUnits
			,@dblSpotCashPrice 				= dblCashPrice
			,@IntCommodityId 				= intCommodityId
			,@CommodityStockUomId 			= intCommodityStockUomId
			,@intCashPriceUOMId 			= intItemUOMId
			,@origdblSpotUnits				= dblSpotUnits
			,@dblSelectedUnits				= dblSelectedUnits
			,@strSettleTicket				= strStorageTicket
		FROM tblGRSettleStorage
		WHERE intSettleStorageId = @intSettleStorageId
	
		SET @dblTotalVoucheredQuantity = isnull([dbo].[fnGRGetVoucheredUnits](@intSettleStorageId), 0)

		IF @dblTotalVoucheredQuantity > = @dblSelectedUnits
			RETURN 
		
		SELECT
			@intFutureMarketId 	= ISNULL(Com.intFutureMarketId,0)
			,@strItemNo 		= Item.strItemNo
			,@ItemLocationId	= IL.intItemLocationId
			,@strCommodityCode	= Com.strCommodityCode
			,@ysnExchangeTraded = Com.ysnExchangeTraded
			,@ysnInventoryCost_ItemId = Item.ysnInventoryCost
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
				@dblFutureMarketPrice = ISNULL(a.dblLastSettle,0)
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
		
		SELECT @intPayToEntityId =  intEntityLocationId FROM tblEMEntityLocation WHERE intEntityId = @EntityId and ysnDefaultLocation = 1

		SELECT 
			@intInventoryItemStockUOMId = intItemUOMId
			,@dblUOMQty					= dblUnitQty
			,@intUnitMeasureId			= intUnitMeasureId
		FROM tblICItemUOM
		WHERE intItemId = @ItemId 
			AND ysnStockUnit = 1

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
				,ysnTransferStorage
			)
			SELECT 
				 intSettleStorageTicketId = SST.intSettleStorageTicketId
				,intCustomerStorageId	  = SST.intCustomerStorageId
				,dblStorageUnits          = SST.dblUnits
				,dblRemainingUnits        = SST.dblUnits
				,dblOpenBalance           = CS.dblOpenBalance
				,strStorageTicketNumber   = CS.strStorageTicketNumber
				,intCompanyLocationId     = CS.intCompanyLocationId
				,intStorageTypeId         = CS.intStorageTypeId
				,intStorageScheduleId     = CS.intStorageScheduleId
				,intContractHeaderId      = SH.intContractHeaderId
				,ysnTransferStorage		  = @ysnFromTransferStorage
			FROM tblGRSettleStorageTicket SST
			JOIN tblGRCustomerStorage CS
				ON CS.intCustomerStorageId = SST.intCustomerStorageId
			OUTER APPLY (
				SELECT DISTINCT
					CH.intContractHeaderId
				FROM tblGRStorageHistory SH
				INNER JOIN tblCTContractHeader CH
					ON CH.intContractHeaderId = SH.intContractHeaderId
						AND CH.intPricingTypeId = 5
				WHERE intCustomerStorageId = CS.intCustomerStorageId
			) SH 
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
				,strPricingTypeHeader
				,intFuturesMonthId
			)
			SELECT 
				 intSettleContractId 	= SSC.intSettleContractId 
				,intContractDetailId 	= SSC.intContractDetailId 
				,dblContractUnits    	= SSC.dblUnits -- ( isnull( b.dblVoucherQtyReceived, 0 ) )
				,ContractEntityId    	= CD.intEntityId
				,dblCashPrice		 	= case WHEN CD.strPricingType = 'Priced' AND CD.strPricingType = 'Priced' THEN CD.dblCashPrice ELSE CASE when ISNULL(@dblCashPriceFromCt,0) != 0 then @dblCashPriceFromCt else CD.dblCashPrice end END
				,intPricingTypeId    	= CD.intPricingTypeId
				,dblBasis			 	= CD.dblBasisInItemStockUOM
				,intContractUOMId	 	= CD.intContractUOMId
				,dblCostUnitQty		 	= CD.dblCostUnitQty
				,strPricingType			= CD.strPricingType
				,strPricingTypeHeader			= CD.strPricingTypeHeader
				,intFuturesMonthId		= CD.intGetContractDetailFutureMonthId
			FROM tblGRSettleContract SSC
			JOIN vyuGRGetContracts CD 
				ON CD.intContractDetailId = SSC.intContractDetailId
			WHERE intSettleStorageId = @intSettleStorageId 
				AND SSC.dblUnits > 0
			ORDER BY SSC.intSettleContractId
			
			--SELECT '@SettleContract',* FROM @SettleContract
			--SELECT 'tblGRSettleContract',* FROM tblGRSettleContract WHERE intSettleStorageId = @intSettleStorageId

			IF EXISTS(SELECT TOP 1 1 FROM @SettleContract WHERE strPricingType = 'Basis' OR (strPricingType = 'Priced' AND strPricingTypeHeader = 'Basis'))
			BEGIN
				IF @intFutureMarketId = 0 AND @ysnExchangeTraded = 1
				BEGIN
					SET @ErrMsg = 'There is no <b>Futures Market</b> setup yet in Risk Management for <b>' + @strCommodityCode + '</b> commodity.'
					RAISERROR(@ErrMsg,16,1,1)
					RETURN;
				END
				
				declare @intFuturesMonthId int 

				select @intFuturesMonthId = intFuturesMonthId from @SettleContract where intFuturesMonthId is not null

				if @intFuturesMonthId is not null
				begin
					select top 1 @dblFutureMarketPrice = a.dblLastSettle  FROM tblRKFutSettlementPriceMarketMap a 
					JOIN tblRKFuturesSettlementPrice b 
						ON b.intFutureSettlementPriceId = a.intFutureSettlementPriceId			
					WHERE b.intFutureMarketId = @intFutureMarketId 
						and a.intFutureMonthId = @intFuturesMonthId
					ORDER by b.dtmPriceDate DESC
				end

				IF isnull(@dblFutureMarketPrice, 0) <= 0
				BEGIN
					SET @ErrMsg = 'There is no <b>Futures Price</b> yet in Risk Management for <b>' + @strCommodityCode + '</b> commodity.'
					RAISERROR(@ErrMsg,16,1,1)
					RETURN;
				END
			END			

			SELECT TOP 1 
				@intStorageChargeItemId = intItemId
				,@StorageChargeItemDescription = strDescription
				,@ysnInventoryCost_StorageChargeItem = 0
			FROM tblICItem
			WHERE strType = 'Other Charge' 
				AND strCostType = 'Storage Charge' 
				AND (intCommodityId = @IntCommodityId OR intCommodityId IS NULL)
			

			---geting the available price that can be vouchered
			begin
				declare @avqty as table
				(
					intContractDetailId int,
					dblAvailableQuantity numeric(18, 6),
					intPriceFixationDetailId int,
					dblCashPrice numeric(18, 6),	
					ContractEntityId int,	
					dblContractUnits DECIMAL(24, 10),
					bb numeric(18, 6),
					cc numeric(18, 6),
					dd numeric(18, 6),
					ysnApplied bit null,
					id int identity(1,1),
					intBillDetailId int null,
					dblContractUnitGuard DECIMAL(24, 10),
					intPricingTypeId int null,
					intPricingTypeIdHeader int null
				)
				delete from @avqty				
				insert into @avqty
					( 
						intContractDetailId, 
						dblAvailableQuantity, 
						intPriceFixationDetailId,
						dblCashPrice,
						ContractEntityId,
						dblContractUnits,
						intPricingTypeId,
						intPricingTypeIdHeader
					)
				select 
						a.intContractDetailId, 
						case 
							when b.intPriceFixationDetailId is not null then
								case 
									when b.dblAvailableQuantity > b.dblQuantity then b.dblQuantity else b.dblAvailableQuantity 
								end							
							else c.dblAvailableQty
						end,
						b.intPriceFixationDetailId ,
						case when b.intPriceFixationDetailId is not null then b.dblCashPrice else c.dblCashPrice end,
						ContractEntityId,
						dblContractUnits,
						c.intPricingTypeId,
						c.intPricingTypeHeader
				from (
						select distinct intContractDetailId, ContractEntityId, dblContractUnits from @SettleContract
					) a
				left join vyuCTAvailableQuantityForVoucher b
					on b.intContractDetailId = a.intContractDetailId 
				left join vyuGRGetContracts c
					on c.intContractDetailId = a.intContractDetailId 
						
				outer apply (
					select sum(dblQtyReceived) as dblTotal
						from tblAPBillDetail 
							where intSettleStorageId = @intSettleStorageId
							and intContractDetailId = a.intContractDetailId
				) total_bill
					where a.dblContractUnits > isnull(total_bill.dblTotal, 0)
					and ((c.intPricingTypeHeader = 2 and c.intPricingTypeId = 1) --Priced Basis
								or (c.intPricingTypeHeader = 2 and c.intPricingTypeId = 2 and b.intPriceFixationDetailId is not null) --Basis and not fully priced yet
							)


				--select '@avqty1',* from @avqty

				declare @acd DECIMAL(24,10)
				set @acd = @dblSelectedUnits - isnull(@dblTotalVoucheredQuantity, 0)

				declare @cur_contract_id int				
				declare @cur_contract_max_units DECIMAL(24,10)
				declare @cur_billed_per_contract_id DECIMAL(24,10)
				declare @ysnPricedBasis BIT

				begin
					select top 1 @cur_contract_id = intContractDetailId
						,@cur_contract_max_units = dblContractUnits
						,@ysnPricedBasis = CAST(CASE WHEN strPricingType = 'Priced' AND strPricingTypeHeader = 'Basis' THEN 1 ELSE 0 END AS BIT)
					from @SettleContract order by intContractDetailId asc
					--select '@cur_contract_id',@cur_contract_id

					while @cur_contract_id is not null
					begin
						
						 select @cur_contract_max_units = dblContractUnits from @SettleContract where intContractDetailId = @cur_contract_id
						 --select '@cur_contract_max_units1',@cur_contract_max_units

						 select @cur_billed_per_contract_id = sum(ISNULL(dblQtyReceived,0))
							from tblAPBillDetail 
								where 
								intSettleStorageId = @intSettleStorageId
								and intContractDetailId = @cur_contract_id

						--select '@cur_billed_per_contract_id',@cur_billed_per_contract_id

						set @cur_contract_max_units = @cur_contract_max_units - isnull(@cur_billed_per_contract_id, 0)
						--select '@cur_contract_max_units2',@cur_contract_max_units

						update @avqty 
							set dblContractUnitGuard = @cur_contract_max_units, @cur_contract_max_units = @cur_contract_max_units - dblAvailableQuantity
						where intContractDetailId = @cur_contract_id --and ((intPriceFixationDetailId is null and @ysnPricedBasis = 0) or intPriceFixationDetailId is not null and @ysnPricedBasis = 1)
						
						select @cur_contract_id =  Min(intContractDetailId) from @SettleContract where intContractDetailId > @cur_contract_id
					end					

				end
				delete from @avqty where dblAvailableQuantity < 0.01
				delete from @avqty where not ( dblAvailableQuantity > abs(dblContractUnitGuard) or dblContractUnitGuard >= 0 )
				update @avqty set dblAvailableQuantity = case when dblContractUnitGuard >= 0 then dblAvailableQuantity else dblAvailableQuantity + dblContractUnitGuard end
				update @avqty set dd = dblAvailableQuantity + cc where cc < 0		

			end
			
			--SAVE IN tblGRSettleContractPriceFixationDetail IF THE CONTRACT USED IS A PRICED BASIS PURCHASE CONTRACT
			INSERT INTO tblGRSettleContractPriceFixationDetail
			SELECT 
				@intSettleStorageId
				,B.intSettleContractId
				,A.intPriceFixationDetailId
				,dblAvailableQuantity
				,A.dblCashPrice
				,B.intContractDetailId
			FROM @avqty A
			INNER JOIN tblGRSettleContract B
				ON B.intSettleStorageId = @intSettleStorageId
					AND B.intContractDetailId = A.intContractDetailId
			WHERE A.dblAvailableQuantity > 0
				AND A.intPriceFixationDetailId IS NOT NULL
				AND A.intPricingTypeId = 1 AND A.intPricingTypeIdHeader = 2

			--SELECT 'tblGRSettleContractPriceFixationDetail',* FROM tblGRSettleContractPriceFixationDetail
			
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
					,intContractUOMId
					,ysnPercentChargeType
					,dblCashPriceUsed
					,intSettleContractId
					,ysnInventoryCost
				)
				SELECT 
					 intCustomerStorageId		= CS.intCustomerStorageId
					,intCompanyLocationId		= CS.intCompanyLocationId 
					,intContractHeaderId		= NULL
					,intContractDetailId		= SC.intContractDetailId
					,dblUnits					= CASE 
													WHEN CS.intTicketId IS NOT NULL AND CS.ysnTransferStorage = 0 AND ST.ysnDPOwnedType = 1
														THEN SST.dblUnits
													ELSE
														CASE													
															WHEN DCO.strDiscountCalculationOption = 'Gross Weight' THEN 
																CASE WHEN CS.dblGrossQuantity IS NULL THEN SST.dblUnits
																ELSE
																	ROUND((SST.dblUnits / CS.dblOriginalBalance) * CS.dblGrossQuantity,10)
																END
															ELSE SST.dblUnits
														END
												END
					,dblCashPrice				= CASE 
													WHEN CS.intTicketId IS NOT NULL AND CS.ysnTransferStorage = 0 AND ST.ysnDPOwnedType = 1
													THEN dbo.fnCTConvertQuantityToTargetItemUOM(CS.intItemId, IU.intUnitMeasureId, CS.intUnitMeasureId, ISNULL(QM.dblDiscountPaid, 0)) - dbo.fnCTConvertQuantityToTargetItemUOM(CS.intItemId, IU.intUnitMeasureId, CS.intUnitMeasureId, ISNULL(QM.dblDiscountDue, 0))
													ELSE
												CASE 
													WHEN QM.strDiscountChargeType = 'Percent'
																THEN (dbo.fnCTConvertQuantityToTargetItemUOM(CS.intItemId, IU.intUnitMeasureId, CS.intUnitMeasureId, ISNULL(QM.dblDiscountPaid, 0)) - dbo.fnCTConvertQuantityToTargetItemUOM(CS.intItemId, IU.intUnitMeasureId, CS.intUnitMeasureId, ISNULL(QM.dblDiscountDue, 0)))
																	*
																	CASE WHEN SC.strPricingType = 'Basis' THEN
																		@dblFutureMarketPrice + SC.dblBasis
																	ELSE
																		(CASE WHEN SS.dblCashPrice <> 0 THEN SS.dblCashPrice ELSE SC.dblCashPrice END)
																	END
													ELSE --Dollar
														dbo.fnCTConvertQuantityToTargetItemUOM(CS.intItemId, IU.intUnitMeasureId, CS.intUnitMeasureId, ISNULL(QM.dblDiscountPaid, 0)) - dbo.fnCTConvertQuantityToTargetItemUOM(CS.intItemId, IU.intUnitMeasureId, CS.intUnitMeasureId, ISNULL(QM.dblDiscountDue, 0))
												END
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
					,intPricingTypeId			= CD.intPricingTypeId
					,intContractUOMId			= SC.intContractUOMId
					,ysnPercentChargeType		= CASE WHEN DSC.strDiscountChargeType = 'Dollar' THEN 0 ELSE 1 /* Percent */END
					,dblCashPriceUsed			= CASE WHEN SC.strPricingType = 'Basis' THEN @dblFutureMarketPrice + SC.dblBasis ELSE (CASE WHEN SS.dblCashPrice <> 0 THEN SS.dblCashPrice ELSE SC.dblCashPrice END) END
													
					,intSettleContractId		= intSettleContractKey
					
					,ysnInventoryCost 			= isnull(QMII.ysnInventoryCost, DItem.ysnInventoryCost)
				FROM tblGRCustomerStorage CS
				JOIN tblGRStorageType ST 
					ON ST.intStorageScheduleTypeId = CS.intStorageTypeId
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
				
				LEFT JOIN [tblGRTicketDiscountItemInfo] QMII
					ON QMII.intTicketDiscountId = QM.intTicketDiscountId

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
			END

			--select '@SettleVoucherCreate dsct',* from @SettleVoucherCreate
			
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
					,ysnInventoryCost
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
					,ysnInventoryCost	  = IC.ysnInventoryCost
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
					,@ysnFromTransferStorage	= ysnTransferStorage
				FROM @SettleStorage
				WHERE intSettleStorageKey = @SettleStorageKey
				
				IF @LocationId IS NULL
				BEGIN
					SET @LocationId = @intCompanyLocationId

					SELECT @ItemLocationId = intItemLocationId
					FROM tblICItemLocation
					WHERE intItemId = @ItemId 
						AND intLocationId = @LocationId

					DECLARE @intTicketCompanyLocationId INT
					DECLARE @intTempSettleStorageId INT

					SELECT 
						@intTicketCompanyLocationId  = SS.intCompanyLocationId
						, @intTempSettleStorageId = SST.intSettleStorageId
					FROM @SettleStorage SS
					LEFT JOIN tblGRSettleStorageTicket SST 
						ON SST.intCustomerStorageId = SS.intCustomerStorageId
					WHERE intSettleStorageKey = @SettleStorageKey

					UPDATE tblGRSettleStorage SET intCompanyLocationId = @intCompanyLocationId WHERE intSettleStorageId = @intTempSettleStorageId
				END

				SELECT @dblGrossUnits 		= CS.dblGrossQuantity 
					,@strOwnedPhysicalStock = ST.strOwnedPhysicalStock
					,@intShipFrom 			= CS.intShipFromLocationId
					,@shipFromEntityId 		= CS.intShipFromEntityId
					,@ysnDPOwnedType 		= ISNULL(ST.ysnDPOwnedType,0) 
					,@ysnDeliverySheet = CAST(CASE WHEN CS.intDeliverySheetId IS NULL THEN 0 ELSE 1 END AS BIT)
				FROM tblGRCustomerStorage CS
				JOIN tblGRStorageType ST 
					ON ST.intStorageScheduleTypeId = CS.intStorageTypeId
				WHERE CS.intCustomerStorageId = @intCustomerStorageId

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
						,ysnInventoryCost
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
						,ysnInventoryCost	   = @ysnInventoryCost_StorageChargeItem

					UPDATE SS
					SET dblStorageDue = ROUND(ABS(SF.dblUnits * SF.dblCashPrice),6)
					FROM tblGRSettleStorage SS
					OUTER APPLY (
						SELECT dblUnits
							,dblCashPrice
						FROM @SettleVoucherCreate
						WHERE intItemType = 2 --Storage Fee
					) SF
					WHERE SS.intSettleStorageId = @intSettleStorageId
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
								,intSettleContractId
								,ysnInventoryCost
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
								,intSettleContractId	= @SettleContractKey
								,ysnInventoryCost	    = @ysnInventoryCost_ItemId
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
								,intSettleContractId
								,ysnInventoryCost
							)
							SELECT 
								 intCustomerStorageId   = @intCustomerStorageId
								,strOrderType           = 'Purchase Contract' -- do not changes this to Contract! Mon Pogi
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
								,intSettleContractId	= @SettleContractKey
								,ysnInventoryCost	    = @ysnInventoryCost_ItemId
							BREAK;
						END

						SELECT @SettleContractKey = MIN(intSettleContractKey)
						FROM @SettleContract
						WHERE intSettleContractKey > @SettleContractKey 
							AND dblContractUnits > 0
					END

					SELECT @SettleStorageKey = MIN(intSettleStorageKey)
					FROM @SettleStorage
					WHERE intSettleStorageKey >= @SettleStorageKey 
						AND dblRemainingUnits > 0
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
							,intSettleContractId
							,ysnInventoryCost
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
							,intSettleContractId = -90
							,ysnInventoryCost	    = @ysnInventoryCost_ItemId
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
							,intSettleContractId
							,ysnInventoryCost
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
							,intSettleContractId = -90
							,ysnInventoryCost	    = @ysnInventoryCost_ItemId

						SET @dblSpotUnits = 0
					END

					SELECT @SettleStorageKey = MIN(intSettleStorageKey)
					FROM @SettleStorage
					WHERE intSettleStorageKey >= @SettleStorageKey 
						AND dblRemainingUnits > 0
				END
				ELSE
					BREAK;
			END
						
			DELETE FROM @SettleVoucherCreate2
			IF(SELECT TOP 1 1 FROM tblGRSettleContractPriceFixationDetail WHERE intSettleStorageId = @intSettleStorageId) > 0
			BEGIN
				INSERT INTO @SettleVoucherCreate2
				(
					strOrderType
					,intCustomerStorageId
					,intCompanyLocationId
					,intContractHeaderId
					,intContractDetailId
					,dblUnits
					,dblCashPrice
					,intItemId
					,intItemType
					,IsProcessed
					,intTicketDiscountId
					,intPricingTypeId
					,dblBasis
					,intContractUOMId
					,dblCostUnitQty
					,dblSettleContractUnits
					,ysnDiscountFromGrossWeight
					,ysnPercentChargeType	
					,dblCashPriceUsed
					,ysnInventoryCost
				)
				SELECT 
					strOrderType
					,intCustomerStorageId
					,intCompanyLocationId
					,intContractHeaderId
					,SVC.intContractDetailId
					,dblUnits				= CASE 
												WHEN A.intPriceFixationDetailId IS NOT NULL
													THEN CASE WHEN SVC.ysnDiscountFromGrossWeight = 1 THEN (SVC.dblUnits / SVC.dblSettleContractUnits) * A.dblUnits ELSE A.dblUnits END
												ELSE SVC.dblUnits
											END
					,dblCashPrice			= CASE 
												WHEN SVC.intItemType = 1 THEN CASE WHEN A.intPriceFixationDetailId IS NOT NULL THEN A.dblCashPrice ELSE SVC.dblCashPrice END
												ELSE 
													CASE 
														WHEN (intItemType = 3 and ysnPercentChargeType = 1) THEN ROUND((SVC.dblCashPrice / SVC.dblCashPriceUsed) * A.dblCashPrice,6)
														ELSE SVC.dblCashPrice 
													END
											END
					,intItemId
					,intItemType
					,IsProcessed
					,intTicketDiscountId
					,intPricingTypeId
					,dblBasis
					,intContractUOMId
					,dblCostUnitQty
					,dblSettleContractUnits
					,ysnDiscountFromGrossWeight
					,ysnPercentChargeType	
					,dblCashPriceUsed
					,ysnInventoryCost		
				FROM @SettleVoucherCreate SVC
				OUTER APPLY (
					SELECT * FROM tblGRSettleContractPriceFixationDetail WHERE intSettleStorageId = @intSettleStorageId AND intContractDetailId = SVC.intContractDetailId
				) A

				--SELECT 'TESTTTT', SS.* ,dblNetSettlement.*,dblDiscountDue.*
				--UPDATE THE NET SETTLEMENT AND DISCOUNT DUE BASED ON THE PRICING LAYERS
				UPDATE SS
				SET dblNetSettlement = ISNULL(A.dblNetSettlement,0)
					,dblDiscountsDue = ISNULL(B.dblDiscountDue,0)
				FROM tblGRSettleStorage SS
				OUTER APPLY (
					SELECT 
						dblNetSettlement = SUM(ISNULL(dblUnits,0) * ISNULL(dblCashPrice,0))
					FROM @SettleVoucherCreate2
				) A
				OUTER APPLY (
					SELECT 
						dblDiscountDue = ABS(SUM(ISNULL(dblUnits,0) * ISNULL(dblCashPrice,0)))
					FROM @SettleVoucherCreate2
					WHERE intItemType = 3
				) B
				WHERE SS.intSettleStorageId = @intSettleStorageId
			END			
			ELSE
			BEGIN
				INSERT INTO @SettleVoucherCreate2
				(
					strOrderType
					,intCustomerStorageId
					,intCompanyLocationId
					,intContractHeaderId
					,intContractDetailId
					,dblUnits
					,dblCashPrice
					,intItemId
					,intItemType
					,IsProcessed
					,intTicketDiscountId
					,intPricingTypeId
					,dblBasis
					,intContractUOMId
					,dblCostUnitQty
					,dblSettleContractUnits
					,ysnDiscountFromGrossWeight
					,ysnPercentChargeType	
					,dblCashPriceUsed
					,ysnInventoryCost
				)
				SELECT 
					strOrderType
					,intCustomerStorageId
					,intCompanyLocationId
					,intContractHeaderId
					,intContractDetailId
					,dblUnits
					,dblCashPrice
					,intItemId
					,intItemType
					,IsProcessed
					,intTicketDiscountId
					,intPricingTypeId
					,dblBasis
					,intContractUOMId
					,dblCostUnitQty
					,dblSettleContractUnits
					,ysnDiscountFromGrossWeight
					,ysnPercentChargeType	
					,dblCashPriceUsed		
					,ysnInventoryCost
				FROM @SettleVoucherCreate
			END		

				-- Note: A single Batch ID will be used across multiple settle storage tickets.
				-- -- Get the Batch Id 
				-- EXEC dbo.uspSMGetStartingNumber 
				-- 	@STARTING_NUMBER_BATCH
				-- 	,@strBatchId OUTPUT

				SET @intLotId = NULL
				
				SELECT @intLotId = ReceiptItemLot.intLotId
				FROM tblICInventoryReceiptItemLot ReceiptItemLot
				JOIN tblICInventoryReceiptItem ReceiptItem 
					ON ReceiptItem.intInventoryReceiptItemId = ReceiptItemLot.intInventoryReceiptItemId
				JOIN tblICItem Item 
					ON Item.intItemId = ReceiptItem.intItemId
				JOIN tblGRStorageHistory SH 
					ON SH.intInventoryReceiptId = ReceiptItem.intInventoryReceiptId 
						AND SH.strType = 'FROM Scale'
				JOIN tblGRSettleStorageTicket SST 
					ON SST.intCustomerStorageId = SH.intCustomerStorageId 
						AND SST.dblUnits > 0
				JOIN tblGRSettleStorage SS 
					ON SS.intSettleStorageId = SST.intSettleStorageId 
				JOIN tblSCTicket SC 
					ON SC.intTicketId = SH.intTicketId
				WHERE SST.intSettleStorageId = @intSettleStorageId

				IF @@ERROR <> 0
				GOTO SettleStorage_Exit;

				DELETE FROM @ItemsToStorage
				DELETE FROM @ItemsToPost
				DELETE FROM @GLEntries				
				
				SELECT TOP 1 
					@intReceiptId = intInventoryReceiptId
				FROM tblGRStorageHistory
				WHERE strType = 'FROM Scale' 
					AND intCustomerStorageId = @intCustomerStorageId		
				
				--this code will see the future	if there will be a discrepancy
				--	
				BEGIN
					declare @aa as decimal(36, 20)
					declare @ab as decimal(36, 20)
					declare @useUnits bit = 1;
					declare @additionalDiscrepancy as decimal(18, 10)
					set @additionalDiscrepancy = 0

					select @aa = sum(
										(
											CASE 
												WHEN SV.intPricingTypeId = 1 OR SV.intPricingTypeId = 6 OR SV.intPricingTypeId IS NULL THEN SV.[dblCashPrice]
													ELSE @dblFutureMarketPrice + ISNULL(SV.dblBasis,0)
											END
											+ (dbo.fnDivide(DiscountCost.dblTotalCashPrice, @dblSelectedUnits))
											
										) 		 
										* dblUnits
										)
					FROM @SettleVoucherCreate SV
					JOIN tblGRCustomerStorage CS 
						ON CS.intCustomerStorageId = SV.intCustomerStorageId					
					JOIN tblICItemUOM IU
						ON IU.intItemId = CS.intItemId
							AND IU.ysnStockUnit = 1
					OUTER APPLY (
						SELECT 
							ISNULL(
								SUM(
									ROUND(
										SV.dblCashPrice * CASE WHEN ISNULL(SV.dblSettleContractUnits,0) > 0 THEN SV.dblSettleContractUnits ELSE SV.dblUnits END
									, 2)
								)
							,0)  AS dblTotalCashPrice,
							sum(CASE WHEN ISNULL(SV.dblSettleContractUnits,0) > 0 THEN SV.dblSettleContractUnits ELSE SV.dblUnits END ) as dblTotalUnits 
						FROM @SettleVoucherCreate SV
							where SV.ysnInventoryCost = 1
								and SV.intItemType = 3
					) DiscountCost
					WHERE SV.intItemType = 1
							
					select  @ab = 
						sum(
							isnull(dblSettleContractUnits, dblUnits) * ( (CASE 
															when intItemType = 3 then SV.dblCashPrice
															WHEN SV.intPricingTypeId = 1 OR SV.intPricingTypeId = 6 OR SV.intPricingTypeId IS NULL THEN SV.[dblCashPrice]
															ELSE @dblFutureMarketPrice + ISNULL(SV.dblBasis,0)
													   END)
													   ) 	
						)
					FROM @SettleVoucherCreate SV
					JOIN tblGRCustomerStorage CS 
						ON CS.intCustomerStorageId = SV.intCustomerStorageId
					JOIN tblICItemUOM IU
						ON IU.intItemId = CS.intItemId
							AND IU.ysnStockUnit = 1					
					WHERE SV.intItemType in ( 1, 3)

					if abs(@aa - @ab) < 0.01 -- and abs(@aa - @ab) > 0.0001
					begin
						set @additionalDiscrepancy = abs(@aa - @ab) * case when @aa > @ab then  -1 else 1 end 
						--if @additionalDiscrepancy < 0.005
						--	set @additionalDiscrepancy = @additionalDiscrepancy * 2
						if round(@additionalDiscrepancy, 3) >= 0.005
						begin
							set @useUnits = 0
						end
					end
				END
				--select '@SettleVoucherCreate',* from @SettleVoucherCreate
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
				--Inventory Item
				SELECT intItemId				=  SV.[intItemId]
					,intItemLocationId			=  @ItemLocationId
					,intItemUOMId				=  @intInventoryItemStockUOMId
					,dtmDate					=  GETDATE()
					,dblQty						= CASE 
														WHEN @strOwnedPhysicalStock = 'Customer' THEN
															CASE 
																WHEN 
																	dbo.fnCTConvertQuantityToTargetItemUOM(CS.intItemId, IU.intUnitMeasureId, CS.intUnitMeasureId, SV.[dblUnits]) - ItemStock.dblUnitStorage > 0
																	AND dbo.fnCTConvertQuantityToTargetItemUOM(CS.intItemId, IU.intUnitMeasureId, CS.intUnitMeasureId, SV.[dblUnits]) - ItemStock.dblUnitStorage < 0.00001
																	THEN -ROUND(dbo.fnCTConvertQuantityToTargetItemUOM(CS.intItemId, IU.intUnitMeasureId, CS.intUnitMeasureId, SV.[dblUnits]),5)
																ELSE
																-dbo.fnCTConvertQuantityToTargetItemUOM(CS.intItemId, IU.intUnitMeasureId, CS.intUnitMeasureId, SV.[dblUnits])
															END
														ELSE 0 
												  END			
					,dblUOMQty					=  @dblUOMQty
					,dblCost					=  (CASE 
														WHEN SV.intPricingTypeId = 1 OR SV.intPricingTypeId = 6 OR SV.intPricingTypeId IS NULL THEN SV.[dblCashPrice]
														ELSE @dblFutureMarketPrice + ISNULL(SV.dblBasis,0)
												   END)
												   + (dbo.fnDivide(DiscountCost.dblTotalCashPrice, @dblSelectedUnits))-- + DiscountCost.dblTotalCashPrice
												   --+ (@additionalDiscrepancy /  case when @useUnits = 1 then SV.dblUnits else 1  end )
												   --+ @additionalDiscrepancy 
					,dblSalesPrice				= 0.00
					,intCurrencyId				= @intCurrencyId
					,dblExchangeRate			= 1
					,intTransactionId			= @intSettleStorageId
					,intTransactionDetailId		=  case when SC.intContractDetailId is not null then SC.intSettleContractId else @intSettleStorageTicketId end
					,strTransactionId			= @strSettleTicket--@TicketNo
					,intTransactionTypeId		= 44
					,intLotId					= @intLotId
					,intSubLocationId			= CS.intCompanyLocationSubLocationId
					,intStorageLocationId		= CS.intStorageLocationId
					,ysnIsStorage				= 1
				FROM @SettleVoucherCreate2 SV
				JOIN tblGRCustomerStorage CS 
					ON CS.intCustomerStorageId = SV.intCustomerStorageId
				left join @SettleContract SC
					on SV.intContractDetailId = SC.intContractDetailId
				JOIN tblICItemUOM IU
					ON IU.intItemId = CS.intItemId
						AND IU.ysnStockUnit = 1
				JOIN tblGRStorageType St 
					ON St.intStorageScheduleTypeId = CS.intStorageTypeId 
						AND SV.intItemType = 1			
				JOIN tblICItemStock ItemStock 
					ON ItemStock.intItemId = CS.intItemId 
						AND ItemStock.intItemLocationId = @ItemLocationId
				OUTER APPLY (
					SELECT 
						ISNULL(SUM(ROUND((SV2.dblCashPrice * SV2.dblUnits), 2)),0) AS dblTotalCashPrice
					FROM @SettleVoucherCreate SV2
					where SV2.ysnInventoryCost = 1 
							and SV2.intItemType = 3
							--and not(SV.intPricingTypeId = 1 OR SV.intPricingTypeId = 6 OR SV.intPricingTypeId IS NULL)
				) DiscountCost			

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
				 --Inventory Item
				SELECT 
					 intItemId					= SV.[intItemId]
					,intItemLocationId			= @ItemLocationId
					,intItemUOMId				= @intInventoryItemStockUOMId
					,dtmDate					= GETDATE()
					,dblQty						= CASE 
														WHEN @strOwnedPhysicalStock = 'Customer' THEN dbo.fnCTConvertQuantityToTargetItemUOM(CS.intItemId, IU.intUnitMeasureId, CS.intUnitMeasureId, SV.[dblUnits])
												        ELSE 0
												  END
					,dblUOMQty					= @dblUOMQty
					,dblCost					= (CASE 
														WHEN SV.intPricingTypeId = 1 OR SV.intPricingTypeId = 6 OR SV.intPricingTypeId IS NULL THEN SV.[dblCashPrice]
														ELSE @dblFutureMarketPrice + ISNULL(SV.dblBasis,0)
												   END)
												   + (dbo.fnDivide(DiscountCost.dblTotalCashPrice,@dblSelectedUnits))												   
												   --+ (@additionalDiscrepancy /  case when @useUnits = 1 then SV.dblUnits else 1  end )
					,dblSalesPrice				= 0.00
					,intCurrencyId				= @intCurrencyId
					,dblExchangeRate			= 1
					,intTransactionId			= @intSettleStorageId
					,intTransactionDetailId		= case when SC.intContractDetailId is not null then SC.intSettleContractId else @intSettleStorageTicketId end
					,strTransactionId			= @strSettleTicket--@TicketNo
					,intTransactionTypeId		= 44
					,intLotId					= @intLotId
					,intSubLocationId			= CS.intCompanyLocationSubLocationId
					,intStorageLocationId		= CS.intStorageLocationId
					,ysnIsStorage				= 0
				FROM @SettleVoucherCreate2 SV
				JOIN tblGRCustomerStorage CS 
					ON CS.intCustomerStorageId = SV.intCustomerStorageId
				left join @SettleContract SC
					on SV.intContractDetailId = SC.intContractDetailId
				JOIN tblICItemUOM IU
					ON IU.intItemId = CS.intItemId
						AND IU.ysnStockUnit = 1
				OUTER APPLY (
					SELECT 
						ISNULL(SUM(ROUND((SV2.dblCashPrice * SV2.dblUnits), 2)),0) AS dblTotalCashPrice
					FROM @SettleVoucherCreate SV2
					where SV2.ysnInventoryCost = 1 
							and SV2.intItemType = 3
							--and not(SV.intPricingTypeId = 1 OR SV.intPricingTypeId = 6 OR SV.intPricingTypeId IS NULL)
				) DiscountCost
				WHERE SV.intItemType = 1

				-- we should only execute the update price in the tblGRSettleContract upon settlement and not per pricing
				-- that field is being used in the ap clearing report and i think even if there is no report 
				-- we should not update it for every pricing.
				-- Mon PG 
				if @ysnFromPriceBasisContract = 0 
				begin
					--UPDATE the price in tblGRSettleContract
					IF EXISTS(SELECT 1 FROM tblGRSettleContract WHERE intSettleStorageId = @intSettleStorageId)
					BEGIN
						UPDATE SC1
						SET dblPrice = CASE
											WHEN SC2.strPricingType <> 'Basis' THEN SC2.dblCashPrice
											ELSE @dblFutureMarketPrice + SC2.dblBasis
										END
						FROM tblGRSettleContract SC1
						INNER JOIN @SettleContract SC2
							ON SC2.intSettleContractId = SC1.intSettleContractId
						JOIN tblCTContractDetail a
							on SC2.intContractDetailId = a.intContractDetailId
					END
				end
				
				
				--Reduce the On-Storage Quantity
				IF(@ysnFromPriceBasisContract = 0)		
				BEGIN
					-- EXEC uspICPostStorage 
					-- 	 @ItemsToStorage
					-- 	,@strBatchId
					-- 	,@intCreatedUserId

					-- IF @@ERROR <> 0
					-- 	GOTO SettleStorage_Exit;
					INSERT INTO @ItemsToStorageStaging (
						[intItemId]
						,[intItemLocationId]
						,[intItemUOMId]
						,[dtmDate]
						,[dblQty]
						,[dblUOMQty]
						,[dblCost]
						,[dblValue]
						,[dblSalesPrice]
						,[intCurrencyId]
						,[dblExchangeRate]
						,[intTransactionId]
						,[intTransactionDetailId]
						,[strTransactionId]
						,[intTransactionTypeId]
						,[intLotId]
						,[intSubLocationId]
						,[intStorageLocationId]
						,[ysnIsStorage]
						,[strActualCostId]
						,[intSourceTransactionId]
						,[strSourceTransactionId]
						,[intInTransitSourceLocationId]
						,[intForexRateTypeId]
						,[dblForexRate]
						,[intStorageScheduleTypeId]
						,[dblUnitRetail]
						,[intCategoryId]
						,[dblAdjustCostValue]
						,[dblAdjustRetailValue]
						,[intCostingMethod]
						,[ysnAllowVoucher]
						,[intSourceEntityId]
					)
					SELECT
						[intItemId]
						,[intItemLocationId]
						,[intItemUOMId]
						,[dtmDate]
						,[dblQty]
						,[dblUOMQty]
						,[dblCost]
						,[dblValue]
						,[dblSalesPrice]
						,[intCurrencyId]
						,[dblExchangeRate]
						,[intTransactionId]
						,[intTransactionDetailId]
						,[strTransactionId]
						,[intTransactionTypeId]
						,[intLotId]
						,[intSubLocationId]
						,[intStorageLocationId]
						,[ysnIsStorage]
						,[strActualCostId]
						,[intSourceTransactionId]
						,[strSourceTransactionId]
						,[intInTransitSourceLocationId]
						,[intForexRateTypeId]
						,[dblForexRate]
						,[intStorageScheduleTypeId]
						,[dblUnitRetail]
						,[intCategoryId]
						,[dblAdjustCostValue]
						,[dblAdjustRetailValue]
						,[intCostingMethod]
						,[ysnAllowVoucher]
						,[intSourceEntityId]
					FROM @ItemsToStorage
				END

				BEGIN
					  SELECT @dblUnits = SUM(dblUnits) FROM @SettleVoucherCreate2 WHERE intItemType = 1
					  
					  SELECT @dblSettlementRatio = @dblUnits / dblOriginalBalance 
					  FROM vyuGRStorageSearchView WHERE intCustomerStorageId = @intCustomerStorageId
					  
					  SELECT @dblOriginalInventoryGLAmount = SUM(dblOpenReceive*dblUnitCost) 
					  FROM tblICInventoryReceiptItem WHERE intInventoryReceiptId = @intReceiptId

				END
				IF(@ysnFromPriceBasisContract = 0)	
				BEGIN
									
						IF @strOwnedPhysicalStock ='Customer' 
						BEGIN
							
							-- DELETE FROM @DummyGLEntries

							-- INSERT INTO @DummyGLEntries 
							-- (
							-- 	[dtmDate] 
							-- 	,[strBatchId]
							-- 	,[intAccountId]
							-- 	,[dblDebit]
							-- 	,[dblCredit]
							-- 	,[dblDebitUnit]
							-- 	,[dblCreditUnit]
							-- 	,[strDescription]
							-- 	,[strCode]
							-- 	,[strReference]
							-- 	,[intCurrencyId]
							-- 	,[dblExchangeRate]
							-- 	,[dtmDateEntered]
							-- 	,[dtmTransactionDate]
							-- 	,[strJournalLineDescription]
							-- 	,[intJournalLineNo]
							-- 	,[ysnIsUnposted]
							-- 	,[intUserId]
							-- 	,[intEntityId]
							-- 	,[strTransactionId]
							-- 	,[intTransactionId]
							-- 	,[strTransactionType]
							-- 	,[strTransactionForm]
							-- 	,[strModuleName]
							-- 	,[intConcurrencyId]
							-- 	,[dblDebitForeign]	
							-- 	,[dblDebitReport]	
							-- 	,[dblCreditForeign]	
							-- 	,[dblCreditReport]	
							-- 	,[dblReportingRate]	
							-- 	,[dblForeignRate]
							-- 	,[strRateType]
							-- 	,[intSourceEntityId] --MOD
							-- 	,[intCommodityId]--MOD
							-- )
							-- EXEC @intReturnValue = dbo.uspICPostCosting  
							-- 	@ItemsToPost  
							-- 	,@strBatchId  
							-- 	,'AP Clearing'
							-- 	,@intCreatedUserId
	
							-- IF @intReturnValue < 0
							-- 	GOTO SettleStorage_Exit;
							INSERT INTO @ItemsToPostStaging (
								[intItemId]
								,[intItemLocationId]
								,[intItemUOMId]
								,[dtmDate]
								,[dblQty]
								,[dblUOMQty]
								,[dblCost]
								,[dblValue]
								,[dblSalesPrice]
								,[intCurrencyId]
								,[dblExchangeRate]
								,[intTransactionId]
								,[intTransactionDetailId]
								,[strTransactionId]
								,[intTransactionTypeId]
								,[intLotId]
								,[intSubLocationId]
								,[intStorageLocationId]
								,[ysnIsStorage]
								,[strActualCostId]
								,[intSourceTransactionId]
								,[strSourceTransactionId]
								,[intInTransitSourceLocationId]
								,[intForexRateTypeId]
								,[dblForexRate]
								,[intStorageScheduleTypeId]
								,[dblUnitRetail]
								,[intCategoryId]
								,[dblAdjustCostValue]
								,[dblAdjustRetailValue]
								,[intCostingMethod]
								,[ysnAllowVoucher]
								,[intSourceEntityId]
							)
							SELECT
								[intItemId]
								,[intItemLocationId]
								,[intItemUOMId]
								,[dtmDate]
								,[dblQty]
								,[dblUOMQty]
								,[dblCost]
								,[dblValue]
								,[dblSalesPrice]
								,[intCurrencyId]
								,[dblExchangeRate]
								,[intTransactionId]
								,[intTransactionDetailId]
								,[strTransactionId]
								,[intTransactionTypeId]
								,[intLotId]
								,[intSubLocationId]
								,[intStorageLocationId]
								,[ysnIsStorage]
								,[strActualCostId]
								,[intSourceTransactionId]
								,[strSourceTransactionId]
								,[intInTransitSourceLocationId]
								,[intForexRateTypeId]
								,[dblForexRate]
								,[intStorageScheduleTypeId]
								,[dblUnitRetail]
								,[intCategoryId]
								,[dblAdjustCostValue]
								,[dblAdjustRetailValue]
								,[intCostingMethod]
								,[ysnAllowVoucher]
								,[intSourceEntityId]
							FROM @ItemsToPost
							
							-- begin								
							-- 	IF EXISTS(SELECT 1 FROM tblGRSettleContract WHERE intSettleStorageId = @intSettleStorageId)
							-- 	BEGIN
							-- 		UPDATE SC1
							-- 		SET dblCost = (select top 1 IT.dblCost from tblICInventoryTransaction IT
							-- 							where IT.intTransactionId = @intSettleStorageId
							-- 								and IT.intTransactionTypeId = 44
							-- 								and IT.intItemId = a.intItemId
							-- 						)
							-- 		FROM tblGRSettleContract SC1
							-- 		INNER JOIN @SettleContract SC2
							-- 			ON SC2.intSettleContractId = SC1.intSettleContractId
							-- 		JOIN tblCTContractDetail a
							-- 			on SC2.intContractDetailId = a.intContractDetailId
							-- 	END
							-- end

							--INVENTORY items
							-- DELETE FROM @GLEntries
							-- INSERT INTO @GLEntries 
							-- (
							-- 	[dtmDate] 
							-- 	,[strBatchId]
							-- 	,[intAccountId]
							-- 	,[dblDebit]
							-- 	,[dblCredit]
							-- 	,[dblDebitUnit]
							-- 	,[dblCreditUnit]
							-- 	,[strDescription]
							-- 	,[strCode]
							-- 	,[strReference]
							-- 	,[intCurrencyId]
							-- 	,[dblExchangeRate]
							-- 	,[dtmDateEntered]
							-- 	,[dtmTransactionDate]
							-- 	,[strJournalLineDescription]
							-- 	,[intJournalLineNo]
							-- 	,[ysnIsUnposted]
							-- 	,[intUserId]
							-- 	,[intEntityId]
							-- 	,[strTransactionId]
							-- 	,[intTransactionId]
							-- 	,[strTransactionType]
							-- 	,[strTransactionForm]
							-- 	,[strModuleName]
							-- 	,[intConcurrencyId]
							-- 	,[dblDebitForeign]	
							-- 	,[dblDebitReport]	
							-- 	,[dblCreditForeign]	
							-- 	,[dblCreditReport]	
							-- 	,[dblReportingRate]	
							-- 	,[dblForeignRate]
							-- 	,[strRateType]
							-- 	--,[intSourceEntityId] --MOD
							-- 	--,[intCommodityId] --MOD
							-- )
							-- EXEC dbo.uspGRCreateItemGLEntries
							-- 	@strBatchId
							-- 	,@SettleVoucherCreate2
							-- 	,'AP Clearing'
							-- 	,@intCreatedUserId
							-- 	,@dblSelectedUnits = @dblSelectedUnits
							-- IF @intReturnValue < 0
							-- 	GOTO SettleStorage_Exit;
							INSERT INTO @tblCustomerOwnedSettleStorage
							SELECT @intSettleStorageId, @dblSelectedUnits, @dblFutureMarketPrice

							INSERT INTO @tblGRCustomerOwnedSettleStorageVoucher
							SELECT
								[intSettleStorageId] = @intSettleStorageId
								,[strOrderType] = strOrderType
								,[intCustomerStorageId] = intCustomerStorageId
								,[intCompanyLocationId] = intCompanyLocationId
								,[intContractHeaderId] = intContractHeaderId
								,[intContractDetailId] = intContractDetailId
								,[dblUnits] = dblUnits
								,[dblCashPrice] = dblCashPrice
								,[intItemId] = intItemId
								,[intItemType] = intItemType
								,[IsProcessed] = IsProcessed
								,[intTicketDiscountId] = intTicketDiscountId
								,[intPricingTypeId] = intPricingTypeId
								,[dblBasis] = dblBasis
								,[intContractUOMId] = intContractUOMId
								,[dblCostUnitQty] = dblCostUnitQty
								,[dblSettleContractUnits] = dblSettleContractUnits
								,[ysnDiscountFromGrossWeight] = ysnDiscountFromGrossWeight
								,[ysnPercentChargeType] = ysnPercentChargeType
								,[dblCashPriceUsed] = dblCashPriceUsed
								,[intSettleContractId] = intSettleContractId
								,[ysnInventoryCost] = ysnInventoryCost
							FROM @SettleVoucherCreate2

							--DISCOUNTS AND CHARGES
						-- 	INSERT INTO @GLEntries 
						-- 	(
						-- 		 [dtmDate] 
						-- 		,[strBatchId]
						-- 		,[intAccountId]
						-- 		,[dblDebit]
						-- 		,[dblCredit]
						-- 		,[dblDebitUnit]
						-- 		,[dblCreditUnit]
						-- 		,[strDescription]
						-- 		,[strCode]
						-- 		,[strReference]
						-- 		,[intCurrencyId]
						-- 		,[dblExchangeRate]
						-- 		,[dtmDateEntered]
						-- 		,[dtmTransactionDate]
						-- 		,[strJournalLineDescription]
						-- 		,[intJournalLineNo]
						-- 		,[ysnIsUnposted]
						-- 		,[intUserId]
						-- 		,[intEntityId]
						-- 		,[strTransactionId]
						-- 		,[intTransactionId]
						-- 		,[strTransactionType]
						-- 		,[strTransactionForm]
						-- 		,[strModuleName]
						-- 		,[intConcurrencyId]
						-- 		,[dblDebitForeign]	
						-- 		,[dblDebitReport]	
						-- 		,[dblCreditForeign]	
						-- 		,[dblCreditReport]	
						-- 		,[dblReportingRate]	
						-- 		,[dblForeignRate]
						-- 		,[strRateType]
						-- 	)

							
						-- 	EXEC uspGRCreateGLEntries 
						-- 	 'Storage Settlement'
						-- 	,'OtherCharges'
						-- 	,@intSettleStorageId
						-- 	,@strBatchId
						-- 	,@intCreatedUserId
						-- 	,@dtmClientPostDate
						-- 	,@ysnPosted
						-- 	,@dblFutureMarketPrice

						-- 	IF EXISTS (SELECT TOP 1 1 FROM @GLEntries) 
						-- 	BEGIN 
						-- 		EXEC dbo.uspGLBookEntries @GLEntries, @ysnPosted 
						-- 	END
						-- END
					END
				END
			END


			---5.Voucher Creation, Update Bill, Tax Computation, Post Bill
			BEGIN
				begin
					--the reason for this is to get the linking of the discount to the settlement voucher
					declare @DiscountSCRelation as table ( id int, intContractDetailId int)
				
					insert into @DiscountSCRelation( id, intContractDetailId)
					select intSettleVoucherKey, a.intContractDetailId
						from @SettleVoucherCreate a 						
							join tblCTContractDetail b
								on a.intContractDetailId = b.intContractDetailId
							join tblCTContractHeader c
								on c.intContractHeaderId = b.intContractHeaderId and c.intPricingTypeId = 2
							left join @avqty d
								on d.intContractDetailId = a.intContractDetailId
						where intItemType = 3 and d.id is null

					--update @SettleVoucherCreate set intContractDetailId = null where intItemType = 3

				end

				DELETE FROM @voucherPayable
				DELETE FROM @voucherPayableTax

				SET @createdVouchersId = NULL

				SET @intCreatedBillId = 0
				UPDATE a
				SET a.dblUnits = CASE 
									WHEN a.ysnDiscountFromGrossWeight = 0 OR (CS.intTicketId IS NOT NULL AND CS.ysnTransferStorage = 0 AND @ysnDPOwnedType = 1) THEN
										CASE 
											WHEN ISNULL(a.dblSettleContractUnits,0) > 0 THEN a.dblSettleContractUnits
											ELSE ISNULL(b.dblSettleUnits,0)
										END
									WHEN ISNULL(a.dblSettleContractUnits,0) > 0 AND a.ysnDiscountFromGrossWeight = 1 THEN
										ROUND((a.dblSettleContractUnits / CS.dblOriginalBalance) * CS.dblGrossQuantity,10)										
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
						AND (intPricingTypeId = 1 OR intPricingTypeId = 6 OR intPricingTypeId IS NULL)
					GROUP BY intCustomerStorageId
				)b ON b.intCustomerStorageId = a.intCustomerStorageId
				INNER JOIN tblGRCustomerStorage CS
					ON CS.intCustomerStorageId = a.intCustomerStorageId
				WHERE a.intItemType = 3
				
				--- this should update the 
				update a 
					set dblCashPrice = availableQtyForVoucher.dblCashPrice
				FROM @SettleVoucherCreate a
					outer apply(
						select  
							 intContractDetailId,	intPriceFixationDetailId, dblCashPrice, dblAvailableQuantity, intPricingTypeId						
							from @avqty 
						where intContractDetailId = a.intContractDetailId
					) availableQtyForVoucher
					WHERE availableQtyForVoucher.intContractDetailId is not null and (availableQtyForVoucher.intPriceFixationDetailId is not null or availableQtyForVoucher.intPricingTypeId = 1 )
						and a.intItemType = 1

				select @dblCashPriceFromCt = availableQtyForVoucher.dblCashPrice,
					@dblQtyFromCt = availableQtyForVoucher.dblAvailableQuantity,
					@doPartialHistory  = case when @ysnFromPriceBasisContract = 1 then 1 else 0 end
				FROM @SettleVoucherCreate a
				cross apply(
					select top 1 
						intContractDetailId,	intPriceFixationDetailId, dblCashPrice, dblAvailableQuantity, intPricingTypeId
						from @avqty  
					where intContractDetailId = a.intContractDetailId order by intPriceFixationDetailId desc
				) availableQtyForVoucher
				WHERE a.strOrderType = 'Contract' and availableQtyForVoucher.intContractDetailId is not null and ( availableQtyForVoucher.intPriceFixationDetailId is not null or availableQtyForVoucher.intPricingTypeId = 1 )
				and isnull(@dblQtyFromCt, 0) <= 0

				
			 IF EXISTS(SELECT 1 FROM @SettleVoucherCreate WHERE ISNULL(dblCashPrice,0) <> 0 AND ISNULL(dblUnits,0) <> 0 )
			 BEGIN
				
				select @dblTotalUnits = sum(case when @doPartialHistory = 1 then
											case WHEN @ysnFromPriceBasisContract = 1 and (intItemType = 2 or intItemType = 3)
													then a.dblUnits
												WHEN (intItemType = 2 or intItemType = 3)
													then a.dblUnits
												when availableQtyForVoucher.dblAvailableQuantity >  a.dblUnits then a.dblUnits 
												else isnull(availableQtyForVoucher.dblAvailableQuantity, @dblQtyFromCt) end
										else
											CASE 
												WHEN (a.intPricingTypeId = 2 or a.intPricingTypeId in (1, 6) ) and availableQtyForVoucher.intContractDetailId is not null and availableQtyForVoucher.dblAvailableQuantity > 0
													THEN availableQtyForVoucher.dblAvailableQuantity -- @dblQtyFromCt 																		
												WHEN @origdblSpotUnits > 0 
													THEN ROUND(dbo.fnCalculateQtyBetweenUOM(b.intItemUOMId,@intCashPriceUOMId,a.dblUnits),6) 
												WHEN a.intPricingTypeId  in (1, 6) and @ysnFromPriceBasisContract = 1 
													then a.dblUnits -- @dblTotalVoucheredQuantity
												WHEN @ysnFromPriceBasisContract = 1 and (intItemType = 2 or intItemType = 3)
													then a.dblUnits
												ELSE 
														case when @ysnFromPriceBasisContract = 1 and  availableQtyForVoucher.intContractDetailId is null  and c.strType = 'Inventory' then 0
														when @ysnFromPriceBasisContract = 1  AND (@dblQtyFromCt + @dblTotalVoucheredQuantity) > a.dblUnits 
															THEN a.dblUnits - @dblTotalVoucheredQuantity
														when @ysnFromPriceBasisContract = 1  AND (@dblQtyFromCt + @dblTotalVoucheredQuantity) < a.dblUnits 
															THEN @dblQtyFromCt - a.dblUnits
														else 
															a.dblUnits
														end
											END
										end) 
				FROM @SettleVoucherCreate a
					JOIN tblICItemUOM b 
						ON b.intItemId = a.intItemId 
							AND b.intUnitMeasureId = @intUnitMeasureId--AND b.ysnStockUnit = 1
					JOIN tblICItem c 
						ON c.intItemId = a.intItemId
					JOIN tblGRSettleStorageTicket SST 
						ON SST.intCustomerStorageId = a.intCustomerStorageId						
					LEFT JOIN tblCTContractDetail CD
						ON CD.intContractDetailId = a.intContractDetailId						
					left join (
						select						
							intContractDetailId,	intPriceFixationDetailId, dblCashPrice, dblAvailableQuantity						
							from @avqty  			
							--from vyuCTAvailableQuantityForVoucher 					
					) availableQtyForVoucher
						on availableQtyForVoucher.intContractDetailId = a.intContractDetailId
					
					WHERE a.dblCashPrice <> 0 
						AND a.dblUnits <> 0 
						AND SST.intSettleStorageId = @intSettleStorageId
					AND CASE WHEN (a.intPricingTypeId = 2 AND ISNULL(@dblCashPriceFromCt,0) = 0) THEN 0 ELSE 1 END = 1
					and a.intItemType = 1

					-- IF @ysnFromPriceBasisContract = 1
					-- BEGIN
					-- 	UPDATE SVC
					-- 	SET SVC.dblUnits = CASE WHEN SVC.ysnDiscountFromGrossWeight = 1 THEN (@dblTotalUnits / CS.dblOriginalBalance) * CS.dblGrossQuantity ELSE @dblTotalUnits END
					-- 	FROM @SettleVoucherCreate SVC
					-- 	INNER JOIN tblGRCustomerStorage CS
					-- 		ON CS.intCustomerStorageId = SVC.intCustomerStorageId
					-- 	WHERE SVC.intItemType in (2, 3) and SVC.dblUnits > @dblTotalUnits
					-- END
					
				
				--GRN-2138 - COST ADJUSTMENT LOGIC FOR DELIVERY SHEETS
				IF @ysnFromPriceBasisContract = 0 AND @ysnDPOwnedType = 1 AND @ysnDeliverySheet = 1
				BEGIN
					EXEC uspGRStorageInventoryReceipt 
						@SettleVoucherCreate = @SettleVoucherCreate
						,@intCustomerStorageId = @intCustomerStorageId
						,@intSettleStorageId = @intSettleStorageId
						,@ysnUnpost = 0

					--SELECT '@StorageInventoryReceipt',* FROM tblGRStorageInventoryReceipt
				END
								
				--Inventory Item and Discounts
				INSERT INTO @voucherPayable
				(
					[intEntityVendorId]
					,[intPayToAddressId]
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
					,[intInventoryReceiptChargeId]
					,[intCustomerStorageId]
					,[intSettleStorageId]
					,[dblOrderQty]
					,[dblOrderUnitQty]
					,[intOrderUOMId]	
					,[dblQuantityToBill]
					,[intQtyToBillUOMId]
					,[dblCost]
					,[dblOldCost]
					,[dblCostUnitQty]
					,[intCostUOMId]
					,[dblNetWeight]
					,[dblWeightUnitQty]
					,[intWeightUOMId]					
					,[intPurchaseTaxGroupId]
					,[dtmDate]
					,[dtmVoucherDate]
					,intLinkingId
				 )
				SELECT 
					[intEntityVendorId]				= @EntityId
					,[intPayToAddressId]			= @intPayToEntityId
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
														WHEN a.intItemType <> 1 AND @ysnDPOwnedType = 0 THEN 
															case WHEN @ysnFromPriceBasisContract = 1 and a.intItemType = 2 then 'Other Charge Expense' else  'AP Clearing' end 
														WHEN a.intItemType = 1 THEN 'AP Clearing'
														WHEN @ysnDPOwnedType = 1 and a.intItemType = 3 AND CS.intTicketId IS NOT NULL then 'AP Clearing'
														WHEN @ysnDPOwnedType = 1 and a.intItemType = 2 and @ysnStorageChargeAccountUseIncome = 1 THEN 'Other Charge Income'
														ELSE 'Other Charge Expense' 
													END
																				)
					,[intContractHeaderId]			= case WHEN a.intItemType = 1 then  a.[intContractHeaderId] else null end -- need to set the contract details to null for non item
					,[intContractDetailId]			= case WHEN a.intItemType = 1 then  a.[intContractDetailId] else null end -- need to set the contract details to null for non item
					,[intInventoryReceiptItemId] =  CASE 
														WHEN @ysnDPOwnedType = 0 THEN NULL
														ELSE 
															CASE 
																WHEN a.intItemType = 1 AND CS.intTicketId IS NOT NULL AND CS.ysnTransferStorage = 0 THEN RI.intInventoryReceiptItemId
																ELSE NULL
															END
													END
					,[intInventoryReceiptChargeId]	= CASE 
														WHEN @ysnDPOwnedType = 0 OR @ysnDeliverySheet = 1 THEN NULL
														ELSE 
																CASE 
																		WHEN a.intItemType = 3 AND CS.intTicketId IS NOT NULL AND CS.ysnTransferStorage = 0 THEN RC.intInventoryReceiptChargeId
																		ELSE NULL
																END
													END
					,[intCustomerStorageId]   = CASE 
													WHEN RI.intInventoryReceiptId IS NULL
														OR (RI.intInventoryReceiptId IS NOT NULL AND CS.intDeliverySheetId IS NOT NULL)
														OR (RI.intInventoryReceiptId IS NOT NULL AND CS.ysnTransferStorage = 1)
													THEN a.[intCustomerStorageId] 
													ELSE NULL END
					,[intSettleStorageId]			= @intSettleStorageId
					,[dblOrderQty]					= CASE 
													WHEN a.intItemType = 3 AND CS.intTicketId IS NOT NULL AND CS.ysnTransferStorage = 0 AND @ysnDPOwnedType = 1
														THEN a.dblUnits
													ELSE
														CASE	
															WHEN CD.intContractDetailId is not null and intItemType = 1 then ROUND(dbo.fnCalculateQtyBetweenUOM(CD.intItemUOMId, b.intItemUOMId, CD.dblQuantity),6) 
															WHEN ISNULL(availableQtyForVoucher.dblContractUnits,0) > 0 AND intItemType = 1 THEN availableQtyForVoucher.dblContractUnits
															WHEN @origdblSpotUnits > 0 THEN ROUND(dbo.fnCalculateQtyBetweenUOM(b.intItemUOMId,@intCashPriceUOMId,a.dblUnits),6) 
															ELSE a.dblUnits 
														END
													END
														
					,[dblOrderUnitQty]				= 1
					,[intOrderUOMId]				= CASE
														WHEN @origdblSpotUnits > 0 THEN @intCashPriceUOMId
														ELSE b.intItemUOMId
													END
					,[dblQuantityToBill]			= CASE 
													WHEN a.intItemType = 3 AND CS.intTicketId IS NOT NULL AND CS.ysnTransferStorage = 0 AND @ysnDPOwnedType = 1
														THEN a.dblUnits
														ELSE
													CASE 
														WHEN @doPartialHistory = 1 
															THEN
																CASE 
																	WHEN @ysnFromPriceBasisContract = 1 and (intItemType = 2 or intItemType = 3)
																		THEN a.dblUnits
																	WHEN (intItemType = 2 or intItemType = 3)
																		THEN a.dblUnits
																	WHEN availableQtyForVoucher.dblAvailableQuantity >  a.dblUnits 
																		THEN a.dblUnits
																	WHEN @origdblSpotUnits > 0 
																		THEN ROUND(dbo.fnCalculateQtyBetweenUOM(b.intItemUOMId,@intCashPriceUOMId,a.dblUnits),6)
																	ELSE isnull(availableQtyForVoucher.dblAvailableQuantity, @dblQtyFromCt)
																END
														ELSE
															CASE 
																WHEN (a.intPricingTypeId = 2 or a.intPricingTypeId in (1, 6) ) and availableQtyForVoucher.intContractDetailId is not null and availableQtyForVoucher.dblAvailableQuantity > 0
																	THEN 
																		CASE 
																			WHEN intItemType = 1 THEN availableQtyForVoucher.dblAvailableQuantity 
																			ELSE ROUND((availableQtyForVoucher.dblAvailableQuantity / a.dblSettleContractUnits) * a.dblUnits, 15)
																		END
																WHEN @origdblSpotUnits > 0 
																	THEN ROUND(dbo.fnCalculateQtyBetweenUOM(b.intItemUOMId,@intCashPriceUOMId,a.dblUnits),6) 
																WHEN a.intPricingTypeId in (1, 6) and @ysnFromPriceBasisContract = 1 
																	THEN a.dblUnits -- @dblTotalVoucheredQuantity
																WHEN @ysnFromPriceBasisContract = 1 and (intItemType = 2 or intItemType = 3)
																	THEN a.dblUnits
																ELSE 
																	CASE 
																		WHEN @ysnFromPriceBasisContract = 1 and  availableQtyForVoucher.intContractDetailId is null  and c.strType = 'Inventory' 
																			THEN 0
																		WHEN @ysnFromPriceBasisContract = 1  AND (@dblQtyFromCt + @dblTotalVoucheredQuantity) > a.dblUnits 
																			THEN a.dblUnits - @dblTotalVoucheredQuantity
																		WHEN @ysnFromPriceBasisContract = 1  AND (@dblQtyFromCt + @dblTotalVoucheredQuantity) < a.dblUnits 
																			THEN @dblQtyFromCt - a.dblUnits
																		ELSE a.dblUnits
																	END
															END
													END
													END
					,[intQtyToBillUOMId]			= CASE
														WHEN @origdblSpotUnits > 0 THEN @intCashPriceUOMId
														ELSE b.intItemUOMId
													END
					,[dblCost]						= CASE WHEN a.intItemType = 3 AND CS.intTicketId IS NOT NULL AND CS.ysnTransferStorage = 0 AND @ysnDPOwnedType = 1 THEN
														CASE
															WHEN a.ysnDiscountFromGrossWeight = 1 AND a.ysnPercentChargeType = 0 THEN (a.dblCashPrice * ((a.dblUnits/CS.dblOriginalBalance) * CS.dblGrossQuantity)) / a.dblUnits --gross weight/dollar
															WHEN a.ysnDiscountFromGrossWeight = 1 AND a.ysnPercentChargeType = 1 THEN ((a.dblCashPrice * a.dblCashPriceUsed) * ((a.dblUnits/CS.dblOriginalBalance) * CS.dblGrossQuantity)) / a.dblUnits --gross weight/percent
															WHEN a.ysnDiscountFromGrossWeight = 0 AND a.ysnPercentChargeType = 0 THEN a.dblCashPrice --net weight/dollar
															WHEN a.ysnDiscountFromGrossWeight = 0 AND a.ysnPercentChargeType = 1 THEN ((a.dblCashPrice * a.dblCashPriceUsed) * a.dblUnits) / a.dblUnits --net weight/percent
														END
													ELSE
														case 
															WHEN @doPartialHistory = 1 
																then
																	case 
																		WHEN intItemType = 1 then isnull(availableQtyForVoucher.dblCashPrice, a.dblCashPrice) 
																		else a.dblCashPrice 
																	end
														else
															CASE
																WHEN (availableQtyForVoucher.intContractDetailId is not null and @ysnFromPriceBasisContract = 1 and intItemType = 1) or (@ysnFromPriceBasisContract = 0 and availableQtyForVoucher.intPricingTypeIdHeader = 2 and availableQtyForVoucher.intPricingTypeId /*sequence*/ = 1 and intItemType = 1) 
																then dbo.fnCTConvertQtyToTargetItemUOM(a.intContractUOMId,b.intItemUOMId, availableQtyForVoucher.dblCashPrice) 
																WHEN a.[intContractHeaderId] IS NOT NULL THEN dbo.fnCTConvertQtyToTargetItemUOM(a.intContractUOMId,b.intItemUOMId,a.dblCashPrice) 

																ELSE case when (intItemType = 3 and ysnPercentChargeType = 1 and a.dblCashPriceUsed is not null and a.intContractUOMId is not null) then ROUND((a.dblCashPrice / a.dblCashPriceUsed) * dbo.fnCTConvertQtyToTargetItemUOM(a.intContractUOMId,b.intItemUOMId, a.dblCashPriceUsed),6) 
                												else a.dblCashPrice end
															END
														end					
													END		
					,[dblOldCost]					=  CASE WHEN @ysnFromPriceBasisContract = 0 THEN
																CASE
																	WHEN @ysnDPOwnedType = 1 AND a.intItemType = 1
																	THEN ISNULL(CS.dblSettlementPrice, 0) + ISNULL(CS.dblBasis, 0)
																	ELSE NULL
																END
															ELSE 
																CASE 
																	WHEN (a.intContractHeaderId IS NOT NULL AND a.intPricingTypeId = 1 AND CH.intPricingTypeId <> 2) OR (@origdblSpotUnits > 0) 
																		THEN NULL
																	WHEN a.[intContractHeaderId] IS NOT NULL AND @ysnFromPriceBasisContract = 1 
																		THEN 															
																			(
																				SELECT IT.dblCost FROM tblICInventoryTransaction IT
																					WHERE IT.intTransactionId = @intSettleStorageId
																						AND IT.intTransactionTypeId = 44
																						AND IT.intItemId = a.intItemId
																						AND IT.intTransactionDetailId = CC.intSettleContractId
																			)
																	WHEN @ysnDPOwnedType = 1
																		THEN (
																				SELECT IT.dblCost 
																				FROM tblICInventoryTransaction IT
																				INNER JOIN tblGRStorageHistory STH
																					ON STH.intTransferStorageId = IT.intTransactionId
																				WHERE IT.intTransactionTypeId = 56
																					AND IT.intItemId = a.intItemId
																			)
																	ELSE NULL 
																END
													END
					,[dblCostUnitQty]				= ISNULL(a.dblCostUnitQty,1)
					,[intCostUOMId]					= CASE
														WHEN @origdblSpotUnits > 0 THEN @intCashPriceUOMId 
														WHEN a.[intContractHeaderId] IS NOT NULL THEN a.intContractUOMId
														ELSE b.intItemUOMId
													END
					,[dblNetWeight]					= CASE 
														WHEN @doPartialHistory = 1 
															THEN
																CASE 
																	WHEN @ysnFromPriceBasisContract = 1 AND (intItemType = 2 OR intItemType = 3)
																		THEN a.dblUnits
																	WHEN (intItemType = 2 OR intItemType = 3)
																		THEN a.dblUnits
																	WHEN availableQtyForVoucher.dblAvailableQuantity >  a.dblUnits 
																		THEN a.dblUnits 															
																	WHEN @origdblSpotUnits > 0 
																		THEN ROUND(dbo.fnCalculateQtyBetweenUOM(b.intItemUOMId,@intCashPriceUOMId,a.dblUnits),6) 
																	ELSE ISNULL(availableQtyForVoucher.dblAvailableQuantity, @dblQtyFromCt) 
																END
														ELSE
															CASE 
																WHEN (a.intPricingTypeId = 2 OR a.intPricingTypeId IN (1, 6) ) AND availableQtyForVoucher.intContractDetailId IS NOT NULL AND availableQtyForVoucher.dblAvailableQuantity > 0
																	THEN 
																		CASE 
																			WHEN intItemType = 1 THEN availableQtyForVoucher.dblAvailableQuantity 
																			ELSE ROUND((availableQtyForVoucher.dblAvailableQuantity / a.dblSettleContractUnits) * a.dblUnits, 15)
																		END
																WHEN @origdblSpotUnits > 0 
																	THEN ROUND(dbo.fnCalculateQtyBetweenUOM(b.intItemUOMId,@intCashPriceUOMId,a.dblUnits),6) 
																WHEN a.intPricingTypeId in (1, 6) AND @ysnFromPriceBasisContract = 1 
																	THEN a.dblUnits -- @dblTotalVoucheredQuantity
																WHEN @ysnFromPriceBasisContract = 1 AND (intItemType = 2 OR intItemType = 3)
																	THEN a.dblUnits
																ELSE 
																	CASE 
																		WHEN @ysnFromPriceBasisContract = 1 AND  availableQtyForVoucher.intContractDetailId IS NULL  AND c.strType = 'Inventory' 
																			THEN 0
																		WHEN @ysnFromPriceBasisContract = 1  AND (@dblQtyFromCt + @dblTotalVoucheredQuantity) > a.dblUnits 
																			THEN a.dblUnits - @dblTotalVoucheredQuantity
																		WHEN @ysnFromPriceBasisContract = 1  AND (@dblQtyFromCt + @dblTotalVoucheredQuantity) < a.dblUnits 
																			THEN @dblQtyFromCt - a.dblUnits
																		ELSE a.dblUnits
																	END
															END
														END																							
					,[dblWeightUnitQty]				= 1 
					,[intWeightUOMId]				= CASE
														WHEN a.[intContractHeaderId] IS NOT NULL THEN b.intItemUOMId
														ELSE NULL
													END
					,[intPurchaseTaxGroupId]		= 
													CASE 
														WHEN RI.intTaxGroupId IS NULL THEN dbo.fnGetTaxGroupIdForVendor(
																								CASE WHEN @shipFromEntityId != @EntityId THEN @shipFromEntityId ELSE @EntityId END,
																								@LocationId,
																								a.intItemId,
																								coalesce(@intShipFrom, EM.intEntityLocationId),
																								EM.intFreightTermId
																							)
														ELSE RI.intTaxGroupId
													END
													--NULL
					,[dtmDate]						= @dtmClientPostDate
					,[dtmVoucherDate]				= @dtmClientPostDate

					, intLinkingId		= isnull(a.intSettleContractId, -90)
				FROM @SettleVoucherCreate a
				JOIN tblICItemUOM b 
					ON b.intItemId = a.intItemId 
						AND b.intUnitMeasureId = @intUnitMeasureId--AND b.ysnStockUnit = 1
				JOIN tblICItem c 
					ON c.intItemId = a.intItemId
				JOIN tblGRSettleStorageTicket SST 
					ON SST.intCustomerStorageId = a.intCustomerStorageId
				LEFT JOIN tblGRCustomerStorage CS
					ON CS.intCustomerStorageId = a.intCustomerStorageId
				LEFT JOIN tblGRDiscountScheduleCode DSC
					ON DSC.intDiscountScheduleId = CS.intDiscountScheduleId 
						AND DSC.intItemId = a.intItemId
				--LEFT JOIN tblGRStorageHistory STH
				--	ON STH.intCustomerStorageId = a.intCustomerStorageId
				LEFT JOIN (
						tblICInventoryReceiptItem RI
						INNER JOIN tblGRStorageHistory SH
								ON SH.intInventoryReceiptId = RI.intInventoryReceiptId
										AND CASE WHEN (SH.strType = 'From Transfer') THEN 1 ELSE (CASE WHEN RI.intContractHeaderId = ISNULL(SH.intContractHeaderId,RI.intContractHeaderId) THEN 1 ELSE 0 END) END = 1
				)  
						ON SH.intCustomerStorageId = CS.intCustomerStorageId
								AND a.intItemType = 1
								/*RI.intContractDetailId and a.intContractDetailId will never be equal
								RI.intContractDetailId - DP contract
								a.intContractDetailId - Contract used during the settlement*/
								-- and ((@ysnDPOwnedType = 1 and a.dblSettleContractUnits is null and RI.intContractDetailId = a.intContractDetailId) or (
								-- 				(RI.intContractDetailId is null or RI.intContractDetailId = a.intContractDetailId)))
								AND CS.intTicketId IS NOT NULL
				LEFT JOIN (
						tblICInventoryReceiptCharge RC
						INNER JOIN tblGRStorageHistory SHC
								ON SHC.intInventoryReceiptId = RC.intInventoryReceiptId
										AND CASE WHEN (SHC.strType = 'From Transfer') THEN 1 ELSE (CASE WHEN RC.intContractId = ISNULL(SHC.intContractHeaderId,RC.intContractId) THEN 1 ELSE 0 END) END = 1
				)  
						ON SHC.intCustomerStorageId = CS.intCustomerStorageId AND a.intItemType = 3 and @ysnDPOwnedType = 1 and a.intItemId = RC.intChargeId
				LEFT JOIN tblCTContractDetail CD
					ON CD.intContractDetailId = a.intContractDetailId				
				LEFT JOIN tblCTContractHeader CH
					ON CD.intContractHeaderId = CH.intContractHeaderId
				LEFT JOIN (
					select						
						intContractDetailId,intPriceFixationDetailId, dblCashPrice, dblAvailableQuantity, dblContractUnits, intPricingTypeId, intPricingTypeIdHeader
						from @avqty
						--from vyuCTAvailableQuantityForVoucher 					
				) availableQtyForVoucher
					on availableQtyForVoucher.intContractDetailId = a.intContractDetailId
				left join tblGRSettleContract CC
					on CC.intSettleStorageId = SST.intSettleStorageId
						and CC.intContractDetailId = availableQtyForVoucher.intContractDetailId
				LEFT JOIN tblEMEntityLocation EM 
					ON EM.intEntityId = @EntityId and EM.ysnDefaultLocation = 1
				WHERE a.dblCashPrice <> 0 
					AND a.dblUnits <> 0 
					AND SST.intSettleStorageId = @intSettleStorageId
				AND CASE WHEN (a.intPricingTypeId = 2 AND ISNULL(@dblCashPriceFromCt,0) = 0) THEN 0 ELSE 1 END = 1
				and (	a.intContractDetailId is null or  
						CH.intPricingTypeId in (1, 3, 6) or
							--(CH.intPricingTypeId = 3 and availableQtyForVoucher.intPricingTypeId = 1) or DEV's note: OBSOLETE; availableQtyForVoucher is empty WHEN HTA contract is used
							(CH.intPricingTypeId = 2 and 
								a.intContractDetailId is not null 
								and availableQtyForVoucher.dblAvailableQuantity > 0)
						or (availableQtyForVoucher.intContractDetailId is not null 
							and isnull(availableQtyForVoucher.intPricingTypeId, 0) = 1)
					)
				and a.intSettleVoucherKey not in ( select id from @DiscountSCRelation )
				ORDER BY SST.intSettleStorageTicketId
					,a.intItemType
				 
				update @voucherPayable set dblOldCost = null where dblCost = dblOldCost
				 ---we should delete priced contracts that has a voucher already
					delete from @voucherPayable 
						where intContractDetailId in (
							select c.intContractDetailId from @voucherPayable a
								join tblCTContractHeader b 
									on a.intContractHeaderId = b.intContractHeaderId and b.intPricingTypeId in (1, 6)
								join tblAPBillDetail c
									on a.intContractHeaderId = c.intContractHeaderId
										and a.intContractDetailId = c.intContractDetailId
										and c.intCustomerStorageId = a.intCustomerStorageId
										and a.intSettleStorageId = c.intSettleStorageId
								join tblAPBill d
									on c.intBillId = d.intBillId
										
							)
							
				---we should update the voucher payable to remove the contract detail that has a null contract header
					update @voucherPayable set intContractDetailId = null where intContractDetailId is not null and intContractHeaderId is null

					if @ysnFromPriceBasisContract = 1
					begin
						--this block will reupdate the total unit of the storage depending on the number of quantity of the item for the voucher payable
										
						declare @total_units_for_voucher  DECIMAL(24, 10)

						select @total_units_for_voucher  = sum(dblQuantityToBill) from @voucherPayable a
							JOIN tblICItem b
									ON b.intItemId = a.intItemId and b.strType = 'Inventory'

				
						update  a set 
								dblQuantityToBill = case when b.ysnDiscountFromGrossWeight = 1 then dblQuantityToBill else isnull(@total_units_for_voucher, dblQuantityToBill) end, 
								dblNetWeight = case when b.ysnDiscountFromGrossWeight = 1 then dblNetWeight else isnull(@total_units_for_voucher, dblNetWeight) end,
								dblOrderQty =  case when b.ysnDiscountFromGrossWeight = 1 then dblQuantityToBill else isnull(@total_units_for_voucher, dblOrderQty) end
							from @voucherPayable a
							join @SettleVoucherCreate b
								on a.intItemId = b.intItemId
							where b.intItemType in (2, 3)
													
					end

				---Adding Freight Charges.
				INSERT INTO @voucherPayable
				(
					[intEntityVendorId]
					,[intPayToAddressId]
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
					,[intInventoryReceiptChargeId]
					,[intCustomerStorageId]
					,[intSettleStorageId]
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
					,[intPurchaseTaxGroupId]
					,[dtmDate]
					,[dtmVoucherDate]
				)
				SELECT 
					[intEntityVendorId]				= @EntityId
					,[intPayToAddressId]			= @intPayToEntityId
					,[intTransactionType]			= 1
					,[intLocationId]				= @LocationId
					,[intShipToId]					= @LocationId
					,[intShipFromId]				= @intShipFrom	
					,[intShipFromEntityId]			= @shipFromEntityId					
					,[strVendorOrderNumber]			= @TicketNo
					,[strMiscDescription] 			= Item.[strItemNo]
					,[intItemId] 					= ReceiptCharge.[intChargeId]
					,[intAccountId] 				= [dbo].[fnGetItemGLAccount](ReceiptCharge.[intChargeId],CL.intItemLocationId,'AP Clearing')
					,[intContractHeaderId] 			= NULL
					,[intContractDetailId] 			= NULL
					,[intInventoryReceiptChargeId]	= CASE WHEN @ysnDPOwnedType = 0 THEN NULL ELSE ReceiptCharge.intInventoryReceiptChargeId END
					,[intCustomerStorageId] 		= SST.intCustomerStorageId
					,[intSettleStorageId]			= @intSettleStorageId
					,[dblOrderQty]					= CASE WHEN ISNULL(Item.strCostMethod,'') = 'Gross Unit' THEN (SC.dblGrossUnits/SC.dblNetUnits) * SST.dblUnits ELSE SST.dblUnits END
					,[dblOrderUnitQty]				= 1		
					,[intOrderUOMId] 				= CASE 
														WHEN @dblSpotUnits > 0 THEN @intCashPriceUOMId 
														ELSE ReceiptCharge.intCostUOMId 
													END	
					,[dblQuantityToBill]	  		= case when isnull(ReceiptCharge.ysnPrice, 0) = 1 then  -1 
														else 
															CASE WHEN ISNULL(Item.strCostMethod,'') = 'Gross Unit' THEN (SC.dblGrossUnits/SC.dblNetUnits) * SST.dblUnits ELSE SST.dblUnits END
														end
					,[intQtyToBillUOMId]			= CASE 
														WHEN @dblSpotUnits > 0 THEN @intCashPriceUOMId 
														ELSE ReceiptCharge.intCostUOMId 
													END	
					,[dblCost] 						= ISNULL(CASE
														WHEN ReceiptCharge.intEntityVendorId = SS.intEntityId AND ISNULL(ReceiptCharge.ysnAccrue, 0) = 1 AND ISNULL(ReceiptCharge.ysnPrice, 0) = 0 THEN ROUND(dbo.fnCTConvertQuantityToTargetItemUOM(CS.intItemId, CU.intUnitMeasureId, CS.intUnitMeasureId, SC.dblFreightRate),20)
														WHEN ReceiptCharge.intEntityVendorId = SS.intEntityId AND ISNULL(ReceiptCharge.ysnAccrue, 0) = 0 AND ISNULL(ReceiptCharge.ysnPrice, 0) = 1 THEN -ROUND(dbo.fnCTConvertQuantityToTargetItemUOM(CS.intItemId, CU.intUnitMeasureId, CS.intUnitMeasureId, SC.dblFreightRate), 20)
														WHEN ReceiptCharge.intEntityVendorId <> SS.intEntityId AND ISNULL(ReceiptCharge.ysnAccrue, 0) = 1 AND ISNULL(ReceiptCharge.ysnPrice, 0) = 1 THEN -ROUND(dbo.fnCTConvertQuantityToTargetItemUOM(CS.intItemId, CU.intUnitMeasureId, CS.intUnitMeasureId, SC.dblFreightRate), 20)
														WHEN ReceiptCharge.intEntityVendorId = SS.intEntityId  AND  ISNULL(ReceiptCharge.ysnAccrue, 0) = 0 AND ISNULL(SC.ysnFarmerPaysFreight, 0) = 1 THEN	-ROUND(dbo.fnCTConvertQuantityToTargetItemUOM(CS.intItemId, CU.intUnitMeasureId, CS.intUnitMeasureId, SC.dblFreightRate), 20)
														WHEN ReceiptCharge.intEntityVendorId <> SS.intEntityId AND  ISNULL(ReceiptCharge.ysnAccrue, 0) = 1 AND ISNULL(SC.ysnFarmerPaysFreight, 0) = 1 THEN	-ROUND(dbo.fnCTConvertQuantityToTargetItemUOM(CS.intItemId, CU.intUnitMeasureId, CS.intUnitMeasureId, SC.dblFreightRate), 20)
														WHEN isnull(ReceiptCharge.ysnPrice, 0) = 1 then  ReceiptCharge.dblAmount
													END, 0)
					,[dblCostUnitQty] 				= 1
					,[intCostUOMId]					= CASE
														WHEN @dblSpotUnits > 0 THEN @intCashPriceUOMId
														ELSE ReceiptCharge.intCostUOMId
													END
					,[dblNetWeight] 				= 0
					,[dblWeightUnitQty] 			= 1
					,[intWeightUOMId]				= NULL
					,[intPurchaseTaxGroupId]		= NULL--CASE WHEN @ysnDPOwnedType = 0 THEN NULL ELSE ReceiptCharge.intTaxGroupId END
					,[dtmDate]						= @dtmClientPostDate
					,[dtmVoucherDate]				= @dtmClientPostDate
				FROM tblICInventoryReceiptCharge ReceiptCharge
				JOIN tblICItem Item 
					ON Item.intItemId = ReceiptCharge.intChargeId
				JOIN tblGRStorageHistory SH 
					ON SH.intInventoryReceiptId = ReceiptCharge.intInventoryReceiptId 
						AND SH.strType = 'FROM Scale'
				JOIN tblGRSettleStorageTicket SST 
					ON SST.intCustomerStorageId = SH.intCustomerStorageId 
						AND SST.dblUnits > 0
				JOIN tblGRSettleStorage SS 
					ON SS.intSettleStorageId = SST.intSettleStorageId 
				JOIN tblSCTicket SC 
					ON SC.intTicketId = SH.intTicketId
				JOIN tblGRCustomerStorage CS 
					ON CS.intCustomerStorageId = SST.intCustomerStorageId
				JOIN tblICCommodityUnitMeasure CU 
					ON CU.intCommodityId = CS.intCommodityId 
						AND CU.ysnStockUnit = 1
				JOIN tblSCScaleSetup ScaleSetup 
					ON ScaleSetup.intScaleSetupId = SC.intScaleSetupId 
						AND ScaleSetup.intFreightItemId = ReceiptCharge.[intChargeId]
				LEFT JOIN tblICItemLocation CL
					ON CL.intItemId = Item.intItemId
						AND CL.intLocationId = @LocationId
				WHERE SST.intSettleStorageId = @intSettleStorageId
				AND 
				(
					(ReceiptCharge.intEntityVendorId = SS.intEntityId AND ISNULL(ReceiptCharge.ysnAccrue, 0) = 1 AND ISNULL(ReceiptCharge.ysnPrice, 0) = 0)
					OR
					(ISNULL(ReceiptCharge.ysnAccrue, 0) = 0 AND ISNULL(ReceiptCharge.ysnPrice, 0) = 1)
					OR
					(ReceiptCharge.intEntityVendorId <> SS.intEntityId AND ISNULL(ReceiptCharge.ysnAccrue, 0) = 1 AND ISNULL(ReceiptCharge.ysnPrice, 0) = 1)
					OR
					(ReceiptCharge.intEntityVendorId <> SS.intEntityId AND  ISNULL(ReceiptCharge.ysnAccrue, 0) = 1 AND ISNULL(SC.ysnFarmerPaysFreight, 0) = 1)
					OR
					(ReceiptCharge.intEntityVendorId <> SS.intEntityId AND  ISNULL(ReceiptCharge.ysnAccrue, 0) = 1 AND ISNULL(SC.ysnFarmerPaysFreight, 0) = 1)
				)
								
				---Adding Contract Other Charges.
				INSERT INTO @voucherPayable
				(
				 	[intEntityVendorId]
					,[intPayToAddressId]
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
					,[intCustomerStorageId]
					,[intSettleStorageId]
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
					,[intPurchaseTaxGroupId]
					,[dtmDate]
					,[dtmVoucherDate]
				)
				SELECT 
					[intEntityVendorId]		= @EntityId
					,[intPayToAddressId]	= @intPayToEntityId
					,[intTransactionType]	= 1
					,[intLocationId]		= @LocationId
					,[intShipToId]			= @LocationId
					,[intShipFromId]		= @intShipFrom	
					,[intShipFromEntityId]	= @shipFromEntityId					
					,[strVendorOrderNumber]	= @TicketNo
					,[strMiscDescription]	= Item.[strItemNo]
					,[intItemId]			= CC.[intItemId]
					,[intAccountId]			= [dbo].[fnGetItemGLAccount](CC.intItemId,ItemLocation.intItemLocationId,'Other Charge Expense')
					,[intContractHeaderId]	= CD.[intContractHeaderId]
					,[intContractDetailId]  = CD.[intContractDetailId]
					,[intCustomerStorageId]	= SV.[intCustomerStorageId]
					,[intSettleStorageId]	= @intSettleStorageId
					,[dblOrderQty]			= CASE 
												WHEN CC.intItemUOMId IS NOT NULL THEN  dbo.fnCTConvertQuantityToTargetItemUOM(CC.intItemId,UOM.intUnitMeasureId,@intUnitMeasureId,SV.dblUnits)
												ELSE SV.dblUnits 
											END
					,[dblOrderUnitQty]		= 1
					,[intOrderUOMId]	  	= CASE 
												WHEN @dblSpotUnits > 0 THEN @intCashPriceUOMId 
												ELSE CC.intItemUOMId 
											END
					,[dblQuantityToBill]	= CASE 
												WHEN CC.intItemUOMId IS NOT NULL THEN  dbo.fnCTConvertQuantityToTargetItemUOM(CC.intItemId,UOM.intUnitMeasureId,@intUnitMeasureId,SV.dblUnits)
												ELSE SV.dblUnits 
											END
					,[intQtyToBillUOMId]  	= CASE 
												WHEN @dblSpotUnits > 0 THEN @intCashPriceUOMId 
												ELSE CC.intItemUOMId 
											END
					,[dblCost]				= CASE
												WHEN ISNULL(CC.ysnPrice, 0) = 0  --this is the only field that needs to be checked when a contract that has a charge is applied to a storage
													THEN 
														( CASE 
															WHEN CC.intCurrencyId IS NOT NULL AND ISNULL(CC.intCurrencyId,0)<> ISNULL(CD.intInvoiceCurrencyId, CD.intCurrencyId) THEN [dbo].[fnCTCalculateAmountBetweenCurrency](CC.intCurrencyId, ISNULL(CD.intInvoiceCurrencyId, CD.intCurrencyId), CC.dblRate, 1) ELSE  CC.dblRate
														END
														)
														/											
														( CASE 
															WHEN CC.strCostMethod ='Per Unit' THEN 1
															WHEN CC.strCostMethod ='Amount'	  THEN 
																								CASE 
																									WHEN CC.intItemUOMId IS NOT NULL THEN  dbo.fnCTConvertQuantityToTargetItemUOM(CC.intItemId,UOM.intUnitMeasureId,@intUnitMeasureId,SV.dblUnits) ELSE SV.dblUnits 
																								END
														END)
												ELSE
													- (( CASE 
														WHEN CC.intCurrencyId IS NOT NULL AND ISNULL(CC.intCurrencyId,0)<> ISNULL(CD.intInvoiceCurrencyId, CD.intCurrencyId) THEN [dbo].[fnCTCalculateAmountBetweenCurrency](CC.intCurrencyId, ISNULL(CD.intInvoiceCurrencyId, CD.intCurrencyId), CC.dblRate, 1) ELSE  CC.dblRate
													END
													)
													/											
													( CASE 
														WHEN CC.strCostMethod ='Per Unit' THEN 1
														WHEN CC.strCostMethod ='Amount'	  THEN 
																							CASE 
																								WHEN CC.intItemUOMId IS NOT NULL THEN  dbo.fnCTConvertQuantityToTargetItemUOM(CC.intItemId,UOM.intUnitMeasureId,@intUnitMeasureId,SV.dblUnits) ELSE SV.dblUnits 
																							END
													END))
				 							END	 
					,[dblCostUnitQty]		= 1 
					,[intCostUOMId]			= CASE 
												WHEN @dblSpotUnits > 0 THEN @intCashPriceUOMId 
												ELSE CC.intItemUOMId 
											END
					,[dblNetWeight]		  	= 0
				 	,[dblWeightUnitQty]	  	= 1
					,[intPurchaseTaxGroupId] = NULL
					,[dtmDate]				= @dtmClientPostDate
					,[dtmVoucherDate]		= @dtmClientPostDate
				 FROM tblCTContractCost CC 
				 JOIN tblCTContractDetail CD 
					ON CD.intContractDetailId =  CC.intContractDetailId
				 JOIN @SettleVoucherCreate SV 
					ON SV.intContractDetailId = CD.intContractDetailId 
						AND SV.intItemType = 1
				 JOIN tblICItem Item 
					ON Item.intItemId = CC.intItemId
				 LEFT JOIN tblICItemUOM UOM 
					ON UOM.intItemUOMId = CC.intItemUOMId
				 LEFT JOIN tblICItemLocation ItemLocation ON ItemLocation.intItemId = CC.[intItemId]
				 WHERE ItemLocation.intLocationId = @LocationId
					AND CASE WHEN (SV.intPricingTypeId = 2 AND ISNULL(@dblCashPriceFromCt,0) = 0) THEN 0 ELSE 1 END = 1
					AND (CASE WHEN CC.intVendorId IS NOT NULL
							THEN 1
							ELSE (CASE WHEN ISNULL(CC.intContractCostId,0) = 0 OR CC.ysnPrice = 1
									THEN 1
									ELSE 0
								  END)
						END) = 1

				DECLARE @dblVoucherTotal DECIMAL(18,6)

				SELECT
					@dblVoucherTotal = SUM(dblOrderQty * dblCost)
				FROM @voucherPayable

				UPDATE @voucherPayable SET dblQuantityToBill = dblQuantityToBill * -1 WHERE ISNULL(dblCost,0) < 0
				UPDATE @voucherPayable SET dblCost = dblCost * -1 WHERE ISNULL(dblCost,0) < 0

				----- delete voucher payable that does not have quantity to bill -----
				delete from @voucherPayable where dblQuantityToBill = 0

				DECLARE @dblVoucherTotalPrecision DECIMAL(18,6) = round(@dblVoucherTotal,2)

				--IF @dblVoucherTotalPrecision > 0 AND EXISTS(SELECT NULL FROM @voucherPayable DS INNER JOIN tblICItem I on I.intItemId = DS.intItemId WHERE I.strType = 'Inventory'  and dblOrderQty <> 0)
				IF EXISTS(SELECT NULL FROM @voucherPayable DS INNER JOIN tblICItem I on I.intItemId = DS.intItemId WHERE I.strType = 'Inventory'  and dblOrderQty <> 0)
				BEGIN
					update @voucherPayable set ysnStage = 0
					EXEC uspAPCreateVoucher
						@voucherPayables = @voucherPayable
						,@voucherPayableTax = @voucherPayableTax
						,@userId = @intCreatedUserId
						,@throwError = 1
						,@error = @ErrMsg
						,@createdVouchersId = @createdVouchersId OUTPUT
				END
				--ELSE 
				--	IF(EXISTS(SELECT NULL FROM @voucherPayable DS INNER JOIN tblICItem I on I.intItemId = DS.intItemId WHERE I.strType = 'Inventory' and dblOrderQty <> 0))
				--	BEGIN
				--		BEGIN
				--		RAISERROR('Unable to post settlement. Voucher will have an invalid amount.',16,1)
				--		END
				--	END
				IF @createdVouchersId IS NOT NULL
				BEGIN
					SELECT @strVoucher = strBillId
					FROM tblAPBill
					WHERE intBillId = CAST(@createdVouchersId AS INT)

					--insert data to the closure table
					BEGIN
						insert into tblGRSettleStorageBillDetail(intConcurrencyId, intSettleStorageId, intBillId)
						select 1, @intSettleStorageId, @createdVouchersId
					END

					DELETE FROM @detailCreated

					INSERT INTO @detailCreated
					SELECT intBillDetailId
					FROM tblAPBillDetail
					WHERE intBillId = CAST(@createdVouchersId AS INT)
						AND (CASE 
								WHEN @ysnDPOwnedType = 1 THEN 
									CASE WHEN intInventoryReceiptChargeId IS NULL THEN 1 ELSE 0 END 
								ELSE 1 
							END = 1)
					

					UPDATE APD
					SET APD.intTaxGroupId = dbo.fnGetTaxGroupIdForVendor(
							CASE WHEN APB.intShipFromEntityId != APB.intEntityVendorId THEN APB.intShipFromEntityId ELSE APB.intEntityVendorId END,
							APB.intShipToId,
							APD.intItemId,
							APB.intShipFromId,
							EM.intFreightTermId
						)
					FROM tblAPBillDetail APD 
					INNER JOIN tblAPBill APB
						ON APD.intBillId = APB.intBillId
					LEFT JOIN tblEMEntityLocation EM ON EM.intEntityId = APB.intEntityId
					INNER JOIN @detailCreated ON intBillDetailId = intId
					WHERE APD.intTaxGroupId IS NULL AND CASE WHEN @ysnDPOwnedType = 1 THEN CASE WHEN intInventoryReceiptChargeId IS NULL THEN 1 ELSE 0 END ELSE 1 END = 1

					EXEC [uspAPUpdateVoucherDetailTax] @detailCreated


					--this will update the cost
					begin
						
						declare @cur_id as int
						declare @cur_cid as int 
						declare @cur_bid as int 
						declare @cur_cost as numeric(18,6)
						declare @cur_qty as numeric(18,6)

						declare @used_bill_id table(id int)
						while exists(select top 1 1 from @avqty where ysnApplied is null)
						begin
							select top 1 
								@cur_id = id,
								@cur_cid = intContractDetailId,
								@cur_cost = dblCashPrice,
								@cur_qty = dblAvailableQuantity,
								@cur_bid = null
							from @avqty where ysnApplied is null
							
							if exists(select top 1 1 from tblCTContractDetail where intContractDetailId = @cur_cid and intPricingTypeId  in( 1 , 2, 6) )
							begin
								select top 1 @cur_bid = intBillDetailId from tblAPBillDetail 
									where 
										intBillId = CAST(@createdVouchersId AS INT) and
										intContractDetailId = @cur_cid and 
										dblQtyReceived = @cur_qty and 
										intBillDetailId not in ( select id from @used_bill_id)
								
								if @cur_bid is not null
								begin
									declare @ysn_have_receipt_item_id bit 
									set @ysn_have_receipt_item_id = 0 
									if exists(select top 1 1 from @voucherPayable where isnull(intInventoryReceiptItemId, 0) > 0)
										set @ysn_have_receipt_item_id = 1
										
									exec uspAPUpdateCost @billDetailId = @cur_bid,  @cost = @cur_cost, @costAdjustment = @ysn_have_receipt_item_id

									insert into @used_bill_id(id) values(@cur_bid)

								end
							end

							update @avqty set ysnApplied = 1, intBillDetailId = @cur_bid where id = @cur_id
						end

						--EXEC [uspAPUpdateVoucherDetailTax] @detailCreated
					end

					if @ysnDPOwnedType = 1 and exists(select top 1 1 from @voucherPayable where isnull(intInventoryReceiptItemId, 0) > 0)
						update 
							voucherPayable
								set dblOldCost = ReceiptItem.dblUnitCost
						from @voucherPayable voucherPayable
							join tblICInventoryReceiptItem ReceiptItem
								on voucherPayable.intInventoryReceiptItemId = ReceiptItem.intInventoryReceiptItemId


					IF @@ERROR <> 0
						GOTO SettleStorage_Exit;                  
					
					SELECT @dblTotal = SUM(dblTotal) FROM tblAPBillDetail WHERE intBillId = CAST(@createdVouchersId AS INT)
					
					EXEC [dbo].[uspSMTransactionCheckIfRequiredApproval]
								@type = N'AccountsPayable.view.Voucher',
								@transactionEntityId = @EntityId,
								@currentUserEntityId = @intCreatedUserId,
								@locationId = @LocationId,
								@amount = @dblTotal,
								@requireApproval = @requireApproval OUTPUT

					DECLARE @intVoucherId INT
					SET @intVoucherId = CAST(@createdVouchersId AS INT)

					declare @sum_e DECIMAL(38,20)
						select @sum_e = sum(abs (dblCost))
								from @voucherPayable a 
									join tblICItem b on 
										a.intItemId = b.intItemId
									left join @SettleVoucherCreate SettleVoucher
										on a.intItemId = SettleVoucher.intItemId
									where isnull(SettleVoucher.ysnInventoryCost, b.ysnInventoryCost) = 1 and strType = 'Other Charge'

					--IF ISNULL(@dblTotal,0) > 0
					BEGIN							
						UPDATE tblGRSettleStorage
						SET intBillId = @createdVouchersId
							WHERE intSettleStorageId = @intSettleStorageId  and @createdVouchersId is not null
										
						UPDATE a
						SET dblPaidAmount = ROUND((b.dblOldCost + ISNULL(@sum_e, 0)) * a.dblUnits , 2),
							dblPaidAmountRaw = (b.dblOldCost + ISNULL(@sum_e, 0)) * a.dblUnits,
							dblOldCost = b.dblOldCost
						FROM tblGRStorageHistory a
						JOIN @voucherPayable b 
							ON a.intContractHeaderId = b.intContractHeaderId
								AND a.intCustomerStorageId = b.intCustomerStorageId											
						WHERE strType = 'Settlement'
								
						--IF @ysnFromTransferStorage = 0
						IF ISNULL(@intVoucherId,0) > 0 AND ISNULL(@requireApproval , 0) = 0
						BEGIN
							INSERT INTO @VoucherIds
							SELECT @intVoucherId
						END
					END
					
					--Inserting data to price fixation detail 
					begin
						insert into tblCTPriceFixationDetailAPAR(intPriceFixationDetailId, intBillId, intBillDetailId, intConcurrencyId)
						select intPriceFixationDetailId, @intVoucherId, intBillDetailId, 1  from @avqty where intBillDetailId is not null and intPriceFixationDetailId is not null
					end

				END
			
			END

			END
						-------------------------xxxxxxxxxxxxxxxxxx------------------------------
			---6.DP Contract Depletion, Purchase Contract Depletion,Storage Ticket Depletion
			IF(@ysnFromPriceBasisContract = 0)	
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
						 @intSettleStorageTicketId 	= intSettleStorageTicketId
						,@intPricingTypeId 			= intPricingTypeId
						,@intContractDetailId 		= intContractDetailId
						,@intCustomerStorageId 		= intCustomerStorageId
						,@dblUnits 					= dblUnits
						,@CommodityStockUomId 		= intSourceItemUOMId
						,@dblCost 					= dblCost
					FROM @tblDepletion
					WHERE intDepletionKey = @intDepletionKey					

					
					IF @intPricingTypeId = 5
					BEGIN

						declare @dblCurrentContractBalance DECIMAL(24, 10)
						select @dblCurrentContractBalance = dblBalance 
							from tblCTContractDetail where intContractDetailId = @intContractDetailId						
							
						if( (@dblCurrentContractBalance) + (@dblUnits)  < 0.01)
						begin
							set @dblUnits = @dblCurrentContractBalance * -1
						end
						

						IF (SELECT dblDetailQuantity FROM vyuCTContractDetailView WHERE intContractDetailId = @intContractDetailId) > 0
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
				SET CS.dblOpenBalance = CASE 
											WHEN ROUND(CS.dblOpenBalance - dbo.fnCTConvertQuantityToTargetItemUOM(CS.intItemId,IU.intUnitMeasureId,CS.intUnitMeasureId,SH.dblUnit),4,1) > 0.0009 
													THEN ROUND(CS.dblOpenBalance - dbo.fnCTConvertQuantityToTargetItemUOM(CS.intItemId,IU.intUnitMeasureId,CS.intUnitMeasureId,SH.dblUnit),6)
											ELSE 0
									   END
				FROM tblGRCustomerStorage CS
				JOIN tblICItemUOM IU
					ON IU.intItemId = CS.intItemId
						AND IU.ysnStockUnit = 1
				JOIN (
						SELECT intCustomerStorageId
							,SUM(dblUnits) dblUnit
						FROM @SettleVoucherCreate
						WHERE intItemType = 1
						GROUP BY intCustomerStorageId
					 ) SH ON SH.intCustomerStorageId = CS.intCustomerStorageId
			END

			--7. HiStory Creation
			IF(@ysnFromPriceBasisContract = 0)	
			BEGIN
				DELETE FROM @StorageHistoryStagingTable
				INSERT INTO @StorageHistoryStagingTable
				(
					  intCustomerStorageId
					, intUserId
					, ysnPost
					, intTransactionTypeId
					, strType
					, dblUnits
					, intContractHeaderId
					, dtmHistoryDate
					, intSettleStorageId
					, strSettleTicket
					, dblPaidAmount
					, dblCost
					, intBillId
				)
				SELECT
					  SV.intCustomerStorageId
					, @intCreatedUserId
					, 1
					, 4
					, 'Settlement'
					, dbo.fnCTConvertQuantityToTargetItemUOM(CS.intItemId,IU.intUnitMeasureId,CS.intUnitMeasureId,SV.[dblUnits])
					, SV.intContractHeaderId
					, GETDATE()
					, @intSettleStorageId
					, @strSettleTicket
					,[dblPaidAmount]		= ISNULL(((select top 1 dblOldCost from @voucherPayable where intItemId = CS.intItemId AND dblOldCost > 0) + isnull(@sum_e, 0)) * SV.[dblUnits]
												, SV.dblCashPrice * SV.[dblUnits] )
					,[dblCost]				= SV.dblCashPrice
					, CASE WHEN ISNULL(CAST(@createdVouchersId AS INT), 0) = 0 THEN NULL ELSE CAST(@createdVouchersId AS INT) END
				FROM @SettleVoucherCreate SV
					INNER JOIN tblGRCustomerStorage CS ON CS.intCustomerStorageId = SV.intCustomerStorageId
					INNER JOIN tblICItemUOM IU ON IU.intItemId = CS.intItemId
						AND IU.ysnStockUnit = 1
				WHERE SV.intItemType = 1
			   				
				SET @IdOutputs = ''
				EXEC uspGRInsertStorageHistoryRecord @StorageHistoryStagingTable, @intStorageHistoryId OUTPUT, @IdOutputs OUTPUT

				if @IdOutputs <> '' and @IdOutputs like '%,%'
				begin
					INSERT INTO @intStorageHistoryIds
					select distinct cast(Record as int) from dbo.fnCFSplitString(@IdOutputs , ',')		
				end
				else
					INSERT INTO @intStorageHistoryIds
					SELECT @intStorageHistoryId

							

				--Add traceability for contract settlement transaction
				exec uspSCAddTransactionLinks 
					@intTransactionType = 6
					,@intTransactionId = @intSettleStorageId
					,@intAction = 1


			END

			UPDATE tblGRSettleStorage
			SET ysnPosted = 1
				,intBillId = @createdVouchersId
			WHERE (intSettleStorageId = @intSettleStorageId  ) and @createdVouchersId is not null
		--END

	--8 Book AP clearing for Customer Owned storage settlement
	IF @strOwnedPhysicalStock ='Customer' AND @ysnFromPriceBasisContract = 0
	BEGIN		
		DECLARE @APClearing AS APClearing;
		DELETE FROM @APClearing;
		INSERT INTO @APClearing
		(
			[intTransactionId],
			[strTransactionId],
			[intTransactionType],
			[strReferenceNumber],
			[dtmDate],
			[intEntityVendorId],
			[intLocationId],
			--DETAIL
			[intTransactionDetailId],
			[intAccountId],
			[intItemId],
			[intItemUOMId],
			[dblQuantity],
			[dblAmount],
			--OTHER INFORMATION
			[strCode]
		)
		SELECT
			-- HEADER
			[intTransactionId]          = V.intSettleStorageId
			,[strTransactionId]         = V.strTransactionNumber
			,[intTransactionType]       = 6 -- GRAIN
			,[strReferenceNumber]       = ''
			,[dtmDate]                  = V.dtmDate
			,[intEntityVendorId]        = V.intEntityVendorId
			,[intLocationId]            = V.intLocationId
			-- DETAIL
			,[intTransactionDetailId]   = V.intCustomerStorageId
			,[intAccountId]             = V.intAccountId
			,[intItemId]                = V.intItemId
			,[intItemUOMId]             = V.intItemUOMId
			,[dblQuantity]              = V.dblSettleStorageQty
			,[dblAmount]                = V.dblSettleStorageAmount
			,[strCode]                  = 'STR'
		FROM vyuAPGrainClearing V
		WHERE V.strTransactionNumber = @strSettleTicket
		AND V.intSettleStorageId = @intSettleStorageId
		AND V.dblSettleStorageAmount <> 0

		EXEC uspAPClearing @APClearing = @APClearing, @post = 1;
	END

	SELECT @intSettleStorageId = MIN(intSettleStorageId)
	FROM tblGRSettleStorage	
	WHERE intParentSettleStorageId = @intParentSettleStorageId 
		AND intSettleStorageId > @intSettleStorageId
	END

	-- Begin Single Batch Posting for Customer Owned Storages
	IF(@ysnFromPriceBasisContract = 0) AND EXISTS(SELECT 1 FROM @ItemsToStorageStaging)
	BEGIN
		--Reduce the On-Storage Quantity
		EXEC uspICPostStorage 
			 @ItemsToStorageStaging
			,@strBatchId
			,@intCreatedUserId

		IF @@ERROR <> 0
			GOTO SettleStorage_Exit;
		
		-- IF @strOwnedPhysicalStock ='Customer'
		BEGIN			
			DELETE FROM @DummyGLEntries

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
			EXEC @intReturnValue = dbo.uspICPostCosting  
				@ItemsToPostStaging
				,@strBatchId  
				,'AP Clearing'
				,@intCreatedUserId
			
			IF @intReturnValue < 0
				GOTO SettleStorage_Exit;
			
			DELETE FROM @GLEntries
			DECLARE C1 CURSOR FAST_FORWARD
    		FOR SELECT * FROM @tblCustomerOwnedSettleStorage
			OPEN C1
			FETCH NEXT FROM C1 INTO @intSettleStorageId, @dblSelectedUnits, @dblFutureMarketPrice
			WHILE @@FETCH_STATUS = 0
			BEGIN
				IF EXISTS(SELECT 1 FROM tblGRSettleContract WHERE intSettleStorageId = @intSettleStorageId)
				BEGIN
					UPDATE SC1
					SET dblCost = (select top 1 IT.dblCost from tblICInventoryTransaction IT
										where IT.intTransactionId = @intSettleStorageId
											and IT.intTransactionTypeId = 44
											and IT.intItemId = a.intItemId
									)
					FROM tblGRSettleContract SC1
					INNER JOIN @SettleContract SC2
						ON SC2.intSettleContractId = SC1.intSettleContractId
					JOIN tblCTContractDetail a
						on SC2.intContractDetailId = a.intContractDetailId
				END

				DELETE FROM @SettleVoucherCreate2
				INSERT INTO @SettleVoucherCreate2
				(
					strOrderType
					,intCustomerStorageId
					,intCompanyLocationId
					,intContractHeaderId
					,intContractDetailId
					,dblUnits
					,dblCashPrice
					,intItemId
					,intItemType
					,IsProcessed
					,intTicketDiscountId
					,intPricingTypeId
					,dblBasis
					,intContractUOMId
					,dblCostUnitQty
					,dblSettleContractUnits
					,ysnDiscountFromGrossWeight
					,ysnPercentChargeType
					,dblCashPriceUsed
					,intSettleContractId
					,ysnInventoryCost
				)
				SELECT 
					strOrderType
					,intCustomerStorageId
					,intCompanyLocationId
					,intContractHeaderId
					,intContractDetailId
					,dblUnits
					,dblCashPrice
					,intItemId
					,intItemType
					,IsProcessed
					,intTicketDiscountId
					,intPricingTypeId                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                  
					,dblBasis
					,intContractUOMId
					,dblCostUnitQty
					,dblSettleContractUnits
					,ysnDiscountFromGrossWeight
					,ysnPercentChargeType
					,dblCashPriceUsed
					,intSettleContractId
					,ysnInventoryCost
				FROM @tblGRCustomerOwnedSettleStorageVoucher
				WHERE intSettleStorageId = @intSettleStorageId

				--INVENTORY items		
				-- DELETE FROM @GLEntries 		
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
					--,[intSourceEntityId] --MOD
					--,[intCommodityId] --MOD
				)
				EXEC dbo.uspGRCreateItemGLEntries
					@strBatchId
					,@SettleVoucherCreate2
					,'AP Clearing'
					,@intCreatedUserId
					,@dblSelectedUnits = @dblSelectedUnits
					,@intSettleStorageId = @intSettleStorageId
				IF @intReturnValue < 0
					GOTO SettleStorage_Exit;

				--DISCOUNTS AND CHARGES
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
					,@dtmClientPostDate
					,@ysnPosted
					,@dblFutureMarketPrice
				
						

				FETCH NEXT FROM C1 INTO @intSettleStorageId, @dblSelectedUnits, @dblFutureMarketPrice
			END
			CLOSE C1;
			DEALLOCATE C1;		
			IF EXISTS (SELECT TOP 1 1 FROM @GLEntries) 
			BEGIN 
				EXEC dbo.uspGLBookEntries @GLEntries, @ysnPosted 
			END
		END
	END

	UPDATE tblGRSettleStorage
	SET ysnPosted = 1
	WHERE intSettleStorageId = @intParentSettleStorageId or  intParentSettleStorageId = @intParentSettleStorageId
		
	UPDATE tblGRStorageHistory
		SET intBillId = @createdVouchersId
		WHERE intSettleStorageId = @intParentSettleStorageId and @createdVouchersId is not null

	--NEED TO UPDATE THE PARENT SETTLEMENT BASED ON THE COMPUTED ACTUAL SETTLEMENTS
	UPDATE SS
	SET dblNetSettlement = A.dblNetSettlementTotal
		,dblDiscountsDue = A.dblDiscountsDueTotal
	FROM tblGRSettleStorage SS
	INNER JOIN (
		SELECT intParentSettleStorageId
			,dblDiscountsDueTotal = SUM(dblDiscountsDue)
			,dblNetSettlementTotal = SUM(dblNetSettlement)
		FROM tblGRSettleStorage
		GROUP BY intParentSettleStorageId
	) A ON A.intParentSettleStorageId = SS.intSettleStorageId
	WHERE SS.intSettleStorageId = @intParentSettleStorageId

	DECLARE @intVoucherId2 AS INT
	DECLARE @VoucherId2 AS Id
	DECLARE @VoucherIdError AS Id
	IF (SELECT ysnPostVoucher FROM tblAPVendor WHERE intEntityId = @EntityId) = 1
	BEGIN
		DELETE FROM @VoucherId2
		DELETE FROM @VoucherIdError
		WHILE EXISTS(SELECT TOP 1 1 FROM @VoucherIds)
		BEGIN
			SET @intVoucherId2 = NULL
			SELECT TOP 1 @intVoucherId2 = intId FROM @VoucherIds
			EXEC [dbo].[uspAPPostBill] 
				@post = 1
				,@recap = 0
				,@isBatch = 0
				,@param = @intVoucherId2
				,@userId = @intCreatedUserId
				,@transactionType = 'Settle Storage'
				,@success = @success OUTPUT

			IF EXISTS(SELECT 1 FROM tblAPPostResult WHERE intTransactionId = @intVoucherId2 AND strMessage = 'Posting of negative voucher is not allowed.')
			BEGIN
				INSERT INTO @VoucherId2
				SELECT @intVoucherId2
			END
			ELSE
			BEGIN
				INSERT INTO @VoucherIdError
				SELECT intTransactionId FROM tblAPPostResult WHERE intTransactionId = @intVoucherId2 AND strMessage <> 'Posting of negative voucher is not allowed.'
			END

			DELETE FROM @VoucherIds WHERE intId = @intVoucherId2
		END
	END

	SELECT * FROM @VoucherId2
	SELECT * FROM @VoucherIdError

	DECLARE @VoucherNos NVARCHAR(100)
	IF EXISTS(SELECT 1 FROM @VoucherId2)
	BEGIN
		SELECT @VoucherNos = STUFF((
		SELECT ',' + (AP.strBillId)
		FROM tblAPBill AP
		INNER JOIN @VoucherId2 V
			ON V.intId = AP.intBillId
			-- AND CASE WHEN (CD.intPricingTypeId = 2 AND (CD.dblTotalCost = 0)) THEN 0 ELSE 1 END = 1
		FOR XML PATH('')) COLLATE Latin1_General_CI_AS,1,1,'')

		IF @VoucherNos LIKE '%,%'
		BEGIN 
			SET @ErrMsg = 'Unable to post vouchers. Vouchers will have negative amount. <br/> See Voucher No. <b>' + @VoucherNos + '</b> for details.'
			RAISERROR (@ErrMsg, 16, 1);
		END
		ELSE
		BEGIN
			SET @ErrMsg = 'Unable to post voucher. Voucher will have a negative amount. <br/> See Voucher No. <b>' + @VoucherNos + '</b> for details.'
			RAISERROR (@ErrMsg, 16, 1);
		END		
	END

	IF EXISTS(SELECT 1 FROM @VoucherIdError)
	BEGIN
		SELECT TOP 1 @ErrMsg = strMessage FROM tblAPPostResult WHERE intTransactionId IN (SELECT intId FROM @VoucherIdError) AND strMessage <> 'Transaction successfully posted.';
		IF @ErrMsg <> ''
		RAISERROR (@ErrMsg, 16, 1);
	END

	if isnull(@intVoucherId, 0) > 0 
	begin
		-- We need to set the Paid Amount back to the raw again the purpose of rounding the Paid Amount to 2 decimal is for the
		-- Posting of voucher
		update a
			set dblPaidAmount = dblPaidAmountRaw
				from tblGRStorageHistory a
					join @voucherPayable b 
						on a.intContractHeaderId = b.intContractHeaderId
						and a.intCustomerStorageId = b.intCustomerStorageId
			where strType = 'Settlement'
				and (dblPaidAmountRaw is not null 
						and round(dblPaidAmountRaw, 2) = dblPaidAmount)
		--
	end

	--SUMMARY LOG
	EXEC [dbo].[uspGRRiskSummaryLog2]
		@StorageHistoryIds = @intStorageHistoryIds

	--IF(@success = 0)
	--BEGIN
	--	SELECT TOP 1 @ErrMsg = strMessage FROM tblAPPostResult WHERE intTransactionId = @intVoucherId;
	--	RAISERROR (@ErrMsg, 16, 1);
	--	GOTO SettleStorage_Exit;
	--END	
	
	SettleStorage_Exit:
END TRY

BEGIN CATCH
	SET @ErrMsg = ERROR_MESSAGE()
	RAISERROR (@ErrMsg,16,1,'WITH NOWAIT')
END CATCH