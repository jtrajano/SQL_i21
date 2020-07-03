CREATE PROCEDURE [dbo].[uspGRPostSettleStorage]
	@intSettleStorageId INT
	,@ysnPosted BIT
	,@ysnFromPriceBasisContract BIT = 0
	,@dblCashPriceFromCt DECIMAL(24, 10) = 0
	,@dblQtyFromCt DECIMAL(24,10) = 0
	
AS
BEGIN TRY
	SET NOCOUNT ON

	DECLARE @ErrMsg NVARCHAR(MAX)
	DECLARE @adjustCostOfDelayedPricingStock AS [ItemCostAdjustmentTableType]
	DECLARE @voucherDetailStorage AS [VoucherDetailStorage]
	DECLARE @VoucherDetailReceiptCharge as [VoucherDetailReceiptCharge]
	DECLARE @EntityId INT
	DECLARE @LocationId INT
	DECLARE @ItemId INT
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

	--Get vouchered quantity
	DECLARE @dblTotalVoucheredQuantity AS DECIMAL(24,10)
	-- THIS IS THE STORAGE UNIT
	DECLARE @dblSelectedUnits AS DECIMAL(24,10)
	declare @doPartialHistory bit = 0

	DECLARE @strSettleTicket NVARCHAR(40)

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

	/*	intItemType
		------------
		1-Inventory
		2-Storage Charge
		3-Discount
		4-Fee
   */
	
	SELECT @intDecimalPrecision = intCurrencyDecimal FROM tblSMCompanyPreference

	SET @dtmDate = GETDATE()
	SET @intParentSettleStorageId = @intSettleStorageId	

	/*avoid the oversettling of storages*/
	IF(@ysnFromPriceBasisContract = 0)
	BEGIN
		DECLARE @CustomerStorageIds AS Id
		DECLARE @intId AS INT
		DELETE FROM @CustomerStorageIds
		INSERT INTO @CustomerStorageIds
		SELECT intCustomerStorageId FROM tblGRSettleStorageTicket WHERE intSettleStorageId = @intSettleStorageId

		WHILE EXISTS(SELECT 1 FROM @CustomerStorageIds)
		BEGIN
			SELECT TOP 1 @intId = intId FROM @CustomerStorageIds

			IF (
			SELECT SUM(dblUnits) 
			FROM tblGRSettleStorageTicket A
			INNER JOIN tblGRSettleStorage B
				ON B.intSettleStorageId = A.intSettleStorageId
				AND B.intParentSettleStorageId IS NULL
			WHERE intCustomerStorageId = @intId ) > 
			(SELECT dblOriginalBalance FROM tblGRCustomerStorage WHERE intCustomerStorageId = @intId)
			BEGIN
				DELETE FROM @CustomerStorageIds WHERE intId = @intId
				RAISERROR('The record has changed. Please refresh screen.',16,1,1)
				RETURN;
			END
			ELSE
			BEGIN
				DELETE FROM @CustomerStorageIds WHERE intId = @intId
			END			
		END	
	END

	if @ysnFromPriceBasisContract = 0 
	begin
		declare @invalid_tickets_with_special_discount nvarchar(500)
		set @invalid_tickets_with_special_discount = ''
			select @invalid_tickets_with_special_discount = @invalid_tickets_with_special_discount + d.strTicketNumber + ','
				from tblGRSettleStorageTicket  a
					join tblGRSettleStorage b
						on a.intSettleStorageId= b.intSettleStorageId 
							and b.intParentSettleStorageId is null	
					join tblGRCustomerStorage c
						on a.intCustomerStorageId = c.intCustomerStorageId
					join tblSCTicket d
						on c.intTicketId = d.intTicketId
							and d.ysnHasSpecialDiscount = 1
							and d.ysnSpecialGradePosted = 0		 
					where a.intSettleStorageId = @intSettleStorageId

		if replace(ltrim(rtrim(@invalid_tickets_with_special_discount)),',', '') <> ''
		begin
			set @ErrMsg = 'The following Tickets have special discount that is not yet posted ( ' + substring(@invalid_tickets_with_special_discount, 1, len(@invalid_tickets_with_special_discount) - 1) +  ' )'
			RAISERROR(@ErrMsg, 16,1,1)
			RETURN;
		end
	end

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
			,@dblSelectedUnits				= dblSelectedUnits
			,@strSettleTicket					= strStorageTicket
		FROM tblGRSettleStorage
		WHERE intSettleStorageId = @intSettleStorageId
	
		SET @dblTotalVoucheredQuantity = isnull([dbo].[fnGRGetVoucheredUnits](@intSettleStorageId), 0)

		if @dblTotalVoucheredQuantity > = @dblSelectedUnits
			return

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
		
		select @intPayToEntityId =  intEntityLocationId from tblEMEntityLocation where intEntityId = @EntityId and ysnDefaultLocation = 1
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
				,intCustomerStorageId	  	= SST.intCustomerStorageId
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
				,intFuturesMonthId
			)
			SELECT 
				 intSettleContractId 	= SSC.intSettleContractId 
				,intContractDetailId 	= SSC.intContractDetailId 
				,dblContractUnits    	= SSC.dblUnits -- ( isnull( b.dblVoucherQtyReceived, 0 ) )
				,ContractEntityId    	= CD.intEntityId
				,dblCashPrice		 	= case when ISNULL(@dblCashPriceFromCt,0) != 0 then @dblCashPriceFromCt else CD.dblCashPrice end
				,intPricingTypeId    	= CD.intPricingTypeId
				,dblBasis			 	= CD.dblBasisInItemStockUOM
				,intContractUOMId	 	= CD.intContractUOMId
				,dblCostUnitQty		 	= CD.dblCostUnitQty
				,strPricingType			= CD.strPricingType
				,intFuturesMonthId		= CD.intGetContractDetailFutureMonthId
			FROM tblGRSettleContract SSC
			JOIN vyuGRGetContracts CD 
				ON CD.intContractDetailId = SSC.intContractDetailId				
			--left join vyuCTAvailableQuantityForVoucher b
			--	on b.intContractDetailId = SSC.intContractDetailId
			WHERE intSettleStorageId = @intSettleStorageId 
				AND SSC.dblUnits > 0 
					--and (@ysnFromPriceBasisContract = 0 or SSC.dblUnits > b.dblVoucherQtyReceived)
			ORDER BY SSC.intSettleContractId

			IF EXISTS(SELECT TOP 1 1 FROM @SettleContract WHERE strPricingType = 'Basis')
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
					select top 1 @dblFutureMarkePrice = a.dblLastSettle  FROM tblRKFutSettlementPriceMarketMap a 
					JOIN tblRKFuturesSettlementPrice b 
						ON b.intFutureSettlementPriceId = a.intFutureSettlementPriceId			
					WHERE b.intFutureMarketId = @intFutureMarketId 
						and a.intFutureMonthId = @intFuturesMonthId
					ORDER by b.dtmPriceDate DESC
				end



				IF isnull(@dblFutureMarkePrice, 0) <= 0
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
					intPricingTypeId int null

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
						intPricingTypeId
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
						c.intPricingTypeId
				from (
						select distinct intContractDetailId, ContractEntityId, dblContractUnits from @SettleContract
					) a
				join vyuCTAvailableQuantityForVoucher b
					on b.intContractDetailId = a.intContractDetailId 
				left join vyuGRGetContracts c
					on c.intContractDetailId = a.intContractDetailId 
						
				outer apply (
					select sum(dblQtyReceived) as dblTotal
						from tblAPBillDetail 
							where intBillId in 
								(select intBillId from tblAPBill where strVendorOrderNumber = (select strStorageTicket from tblGRSettleStorage where intSettleStorageId = @intSettleStorageId)) 
							and intContractDetailId = a.intContractDetailId
				) total_bill
					where a.dblContractUnits > isnull(total_bill.dblTotal, 0)


				declare @acd DECIMAL(24,10)
				set @acd = @dblSelectedUnits - isnull(@dblTotalVoucheredQuantity, 0)

				declare @cur_contract_id int				
				declare @cur_contract_max_units DECIMAL(24,10)
				declare @cur_billed_per_contract_id DECIMAL(24,10)
				begin
					select top 1  @cur_contract_id =  intContractDetailId, @cur_contract_max_units = dblContractUnits from @SettleContract order by intContractDetailId asc
					

					while @cur_contract_id is not null
					begin
						
						 select @cur_contract_max_units = dblContractUnits from @SettleContract where intContractDetailId = @cur_contract_id


						 select @cur_billed_per_contract_id = sum(dblQtyReceived)
							from tblAPBillDetail 
								where intBillId in 
									(select intBillId from tblAPBill where strVendorOrderNumber = (select strStorageTicket from tblGRSettleStorage where intSettleStorageId = @intSettleStorageId)) 
								and intContractDetailId = @cur_contract_id

						set @cur_contract_max_units = @cur_contract_max_units - isnull(@cur_billed_per_contract_id, 0)

						update @avqty 
							set dblContractUnitGuard = @cur_contract_max_units, @cur_contract_max_units = @cur_contract_max_units - dblAvailableQuantity
						where intContractDetailId = @cur_contract_id
						
						select @cur_contract_id =  Min(intContractDetailId) from @SettleContract where intContractDetailId > @cur_contract_id
						 
					end					

				end

				delete from @avqty where not ( dblAvailableQuantity > abs(dblContractUnitGuard) or dblContractUnitGuard >= 0 )
				update @avqty set dblAvailableQuantity = case when dblContractUnitGuard >= 0 then dblAvailableQuantity else dblAvailableQuantity + dblContractUnitGuard end

				--update @avqty set bb = @acd - dblAvailableQuantity, cc = @acd, @acd = (@acd - dblAvailableQuantity)

				--delete from @avqty where cc > dblAvailableQuantity
				update @avqty set dd = dblAvailableQuantity + cc where cc < 0		

				--update @avqty set dd = 				
				--	case 
				--	when cc >= 0 
				--		then dblAvailableQuantity 
				--	when dblAvailableQuantity + cc >= 0 
				--		then dblAvailableQuantity + cc 
				--	else null end
				
				--update @avqty set dblAvailableQuantity = dd
				--update @avqty set dblAvailableQuantity = dblAvailableQuantity - case when (abs(dblContractUnitGuard))
				--delete from @avqty where dblAvailableQuantity is null
			end

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
				)
				SELECT 
					 intCustomerStorageId		= CS.intCustomerStorageId
					,intCompanyLocationId		= CS.intCompanyLocationId 
					,intContractHeaderId		= NULL
					,intContractDetailId		= SC.intContractDetailId
					,dblUnits					= CASE													
													WHEN DCO.strDiscountCalculationOption = 'Gross Weight' THEN 
														CASE WHEN CS.dblGrossQuantity IS NULL THEN SST.dblUnits
														ELSE
															ROUND((SST.dblUnits / CS.dblOriginalBalance) * CS.dblGrossQuantity,10)
														END
													ELSE SST.dblUnits
												END
					,dblCashPrice				= 
												CASE 
													WHEN QM.strDiscountChargeType = 'Percent'
																THEN (dbo.fnCTConvertQuantityToTargetItemUOM(CS.intItemId, IU.intUnitMeasureId, CS.intUnitMeasureId, ISNULL(QM.dblDiscountPaid, 0)) - dbo.fnCTConvertQuantityToTargetItemUOM(CS.intItemId, IU.intUnitMeasureId, CS.intUnitMeasureId, ISNULL(QM.dblDiscountDue, 0)))
																	*
																	CASE WHEN SC.strPricingType = 'Basis' THEN
																		@dblFutureMarkePrice + SC.dblBasis
																	ELSE
																		(CASE WHEN SS.dblCashPrice <> 0 THEN SS.dblCashPrice ELSE SC.dblCashPrice END)
																	END
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
					,intPricingTypeId			= CD.intPricingTypeId
					,intContractUOMId			= SC.intContractUOMId
				FROM tblGRCustomerStorage CS
				JOIN tblGRSettleStorageTicket SST 
					ON SST.intCustomerStorageId = CS.intCustomerStorageId 
						AND SST.intSettleStorageId = @intSettleStorageId 
						AND SST.dblUnits > 0
				JOIN tblGRSettleStorage SS
					ON SS.intSettleStorageId = SST.intSettleStorageId
				-- JOIN tblICCommodityUnitMeasure CU
				-- 	ON CU.intCommodityId = CS.intCommodityId
				-- 		AND CU.ysnStockUnit = 1
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


				select @dblGrossUnits  = dblGrossQuantity 
					from tblGRCustomerStorage 
						where intCustomerStorageId = @intCustomerStorageId


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
					BREAK;
			END

			BEGIN
				EXEC dbo.uspSMGetStartingNumber 
					 @STARTING_NUMBER_BATCH
					,@strBatchId OUTPUT
				
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

				DELETE
				FROM @ItemsToStorage

				DELETE
				FROM @ItemsToPost

				DELETE 
				FROM @GLEntries

				SELECT 
					@strOwnedPhysicalStock = ST.strOwnedPhysicalStock
					,@intShipFrom = intShipFromLocationId
					,@shipFromEntityId = intShipFromEntityId
				FROM tblGRCustomerStorage CS 
				JOIN tblGRStorageType ST 
					ON ST.intStorageScheduleTypeId = CS.intStorageTypeId
				WHERE CS.intCustomerStorageId = @intCustomerStorageId
				
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
													ELSE @dblFutureMarkePrice + ISNULL(SV.dblBasis,0)
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
						INNER JOIN tblICItem I
							ON I.intItemId = SV.intItemId
								AND I.ysnInventoryCost = 1
								and SV.intItemType = 3
					) DiscountCost
					WHERE SV.intItemType = 1



		
					select  @ab = 
						sum(
							isnull(dblSettleContractUnits, dblUnits) * ( (CASE 
															when intItemType = 3 then SV.dblCashPrice
															WHEN SV.intPricingTypeId = 1 OR SV.intPricingTypeId = 6 OR SV.intPricingTypeId IS NULL THEN SV.[dblCashPrice]
															ELSE @dblFutureMarkePrice + ISNULL(SV.dblBasis,0)
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
														ELSE @dblFutureMarkePrice + ISNULL(SV.dblBasis,0)
												   END)
												   + (dbo.fnDivide(DiscountCost.dblTotalCashPrice, @dblSelectedUnits))-- + DiscountCost.dblTotalCashPrice
												   --+ (@additionalDiscrepancy /  case when @useUnits = 1 then SV.dblUnits else 1  end )
												   --+ @additionalDiscrepancy 
					,dblSalesPrice				= 0.00
					,intCurrencyId				= @intCurrencyId
					,dblExchangeRate			= 1
					,intTransactionId			= @intSettleStorageId
					,intTransactionDetailId		=  case when SC.intContractDetailId is not null then SC.intSettleContractId else @intSettleStorageTicketId end
					,strTransactionId			= @TicketNo
					,intTransactionTypeId		= 44
					,intLotId					= @intLotId
					,intSubLocationId			= CS.intCompanyLocationSubLocationId
					,intStorageLocationId		= CS.intStorageLocationId
					,ysnIsStorage				= 1
				FROM @SettleVoucherCreate SV
				JOIN tblGRCustomerStorage CS 
					ON CS.intCustomerStorageId = SV.intCustomerStorageId
				left join @SettleContract SC
					on SV.intContractDetailId = SC.intContractDetailId
				-- JOIN tblICCommodityUnitMeasure CU 
				-- 	ON CU.intCommodityId = CS.intCommodityId 
				-- 		AND CU.ysnStockUnit = 1
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
						ISNULL(
							SUM(
								ROUND(
									(SV.dblCashPrice * 
										CASE WHEN ISNULL(SV.dblSettleContractUnits,0) > 0 
											THEN 
												CASE WHEN SV.ysnDiscountFromGrossWeight = 1 then  
														((SV.dblSettleContractUnits / @dblGrossUnits) * @dblSelectedUnits) 
												else SV.dblSettleContractUnits end
												
											ELSE 
												CASE WHEN SV.ysnDiscountFromGrossWeight = 1 then  
														((SV.dblUnits  / @dblGrossUnits) * @dblSelectedUnits) 
												else SV.dblUnits  end
										END)									 
								, 2) 
							) 
						,0)  AS dblTotalCashPrice
						--ISNULL(SUM((ROUND(SV.dblCashPrice * CASE WHEN ISNULL(SV.dblSettleContractUnits,0) > 0 THEN SV.dblSettleContractUnits ELSE SV.dblUnits END, 2)) / SV.dblUnits),0)  AS dblTotalCashPrice
						--ISNULL(Round((Sum(SV.dblCashPrice * CASE WHEN ISNULL(SV.dblSettleContractUnits,0) > 0 THEN SV.dblSettleContractUnits ELSE SV.dblUnits END)), 2  ),0)  AS dblTotalCashPrice
					FROM @SettleVoucherCreate SV
					INNER JOIN tblICItem I
						ON I.intItemId = SV.intItemId
							AND I.ysnInventoryCost = 1
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
														ELSE @dblFutureMarkePrice + ISNULL(SV.dblBasis,0)
												   END)
												   + (dbo.fnDivide(DiscountCost.dblTotalCashPrice, CASE WHEN SV.ysnDiscountFromGrossWeight = 1 then @dblGrossUnits else @dblSelectedUnits end ))												   
												   --+ (@additionalDiscrepancy /  case when @useUnits = 1 then SV.dblUnits else 1  end )
					,dblSalesPrice				= 0.00
					,intCurrencyId				= @intCurrencyId
					,dblExchangeRate			= 1
					,intTransactionId			= @intSettleStorageId
					,intTransactionDetailId		= case when SC.intContractDetailId is not null then SC.intSettleContractId else @intSettleStorageTicketId end
					,strTransactionId			= @TicketNo
					,intTransactionTypeId		= 44
					,intLotId					= @intLotId
					,intSubLocationId			= CS.intCompanyLocationSubLocationId
					,intStorageLocationId		= CS.intStorageLocationId
					,ysnIsStorage				= 0
				FROM @SettleVoucherCreate SV
				JOIN tblGRCustomerStorage CS 
					ON CS.intCustomerStorageId = SV.intCustomerStorageId
				left join @SettleContract SC
					on SV.intContractDetailId = SC.intContractDetailId
				--JOIN tblICCommodityUnitMeasure CU 
				--	ON CU.intCommodityId = CS.intCommodityId 
				--	AND CU.ysnStockUnit = 1
				JOIN tblICItemUOM IU
					ON IU.intItemId = CS.intItemId
						AND IU.ysnStockUnit = 1
				OUTER APPLY (
					SELECT 
						ISNULL(
							SUM(
								ROUND(
									(SV.dblCashPrice * 
										CASE WHEN ISNULL(SV.dblSettleContractUnits,0) > 0 
											THEN 
												CASE WHEN SV.ysnDiscountFromGrossWeight = 1 then  
														((SV.dblSettleContractUnits / @dblSelectedUnits) * @dblGrossUnits) 
												else SV.dblSettleContractUnits end
												
											ELSE 
												CASE WHEN SV.ysnDiscountFromGrossWeight = 1 then  
														((SV.dblUnits  / @dblSelectedUnits ) * @dblGrossUnits ) 
												else SV.dblUnits  end
										END)									 
								, 2) 
							) 
						,0)  AS dblTotalCashPrice
						--ISNULL(Round((Sum(SV.dblCashPrice * CASE WHEN ISNULL(SV.dblSettleContractUnits,0) > 0 THEN SV.dblSettleContractUnits ELSE SV.dblUnits END)), 2  ),0)  AS dblTotalCashPrice
					FROM @SettleVoucherCreate SV
					INNER JOIN tblICItem I
						ON I.intItemId = SV.intItemId
							AND I.ysnInventoryCost = 1
							and SV.intItemType = 3
							--and not(SV.intPricingTypeId = 1 OR SV.intPricingTypeId = 6 OR SV.intPricingTypeId IS NULL)
				) DiscountCost
				WHERE SV.intItemType = 1

				IF @ysnFromPriceBasisContract = 0
				BEGIN
					--insert in table which will be used when unposting
					INSERT INTO [dbo].[tblGRSettledItemsToStorage]
					(
						intItemId
						,intItemLocationId
						,intItemUOMId
						,dtmDate
						,dblQty
						,dblUOMQty
						,dblCost
						,intCurrencyId
						,intTransactionId
						,intTransactionDetailId
						,strTransactionId
						,intLotId
						,intSubLocationId
						,intStorageLocationId
						,ysnIsStorage
					)
					SELECT intItemId
						,intItemLocationId
						,intItemUOMId
						,dtmDate
						,dblQty
						,dblUOMQty
						,dblCost
						,intCurrencyId
						,intTransactionId
						,intTransactionDetailId
						,strTransactionId
						,intLotId
						,intSubLocationId
						,intStorageLocationId
						,ysnIsStorage 
					FROM (
						SELECT * FROM @ItemsToStorage
						UNION ALL
						SELECT * FROM @ItemsToPost
					) I
				END				

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
											ELSE @dblFutureMarkePrice + SC2.dblBasis
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
				IF(@ysnFromPriceBasisContract = 0)	
				BEGIN
									
						IF @strOwnedPhysicalStock ='Customer' 
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
								@ItemsToPost  
								,@strBatchId  
								,'AP Clearing'
								,@intCreatedUserId
	
							IF @intReturnValue < 0
								GOTO SettleStorage_Exit;
								
							begin								
								IF EXISTS(SELECT 1 FROM tblGRSettleContract WHERE intSettleStorageId = @intSettleStorageId)
								BEGIN
									UPDATE SC1
									SET dblCost = (select top 1 dblCost from tblICInventoryTransaction IT
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
							end

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
								--,[intSourceEntityId] --MOD
								--,[intCommodityId] --MOD
							)
							EXEC dbo.uspGRCreateItemGLEntries
								@strBatchId
								,@SettleVoucherCreate
								,'AP Clearing'
								,@intCreatedUserId
								,@dblSelectedUnits = @dblSelectedUnits
							IF @intReturnValue < 0
								GOTO SettleStorage_Exit;

							--IF EXISTS (SELECT TOP 1 1 FROM @GLEntries)
							--BEGIN 
							--	EXEC dbo.uspGLBookEntries @GLEntries, @ysnPosted 
							--END 
						    
							--DELETE FROM @GLEntries
							
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


				end

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
					@doPartialHistory  = 1
				FROM @SettleVoucherCreate a
				cross apply(
					select top 1 
						intContractDetailId,	intPriceFixationDetailId, dblCashPrice, dblAvailableQuantity, intPricingTypeId
						from @avqty  
					where intContractDetailId = a.intContractDetailId order by intPriceFixationDetailId desc
				) availableQtyForVoucher
				WHERE a.strOrderType = 'Contract' and availableQtyForVoucher.intContractDetailId is not null and ( availableQtyForVoucher.intPriceFixationDetailId is not null or availableQtyForVoucher.intPricingTypeId = 1 )
				and isnull(@dblQtyFromCt, 0) <= 0
				
				---
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
												
				begin
					-- must update the qty for the discounts
					declare @dblTotalUnits DECIMAL(24, 10)
				
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

					UPDATE SVC
					SET SVC.dblUnits = CASE WHEN SVC.ysnDiscountFromGrossWeight = 1 THEN (@dblTotalUnits / CS.dblOriginalBalance) * CS.dblGrossQuantity ELSE @dblTotalUnits END
					FROM @SettleVoucherCreate SVC
					INNER JOIN tblGRCustomerStorage CS
						ON CS.intCustomerStorageId = SVC.intCustomerStorageId
					WHERE SVC.intItemType in (2, 3) and SVC.dblUnits > @dblTotalUnits

				end
				
				--GRN-2138 - COST ADJUSTMENT LOGIC FOR DELIVERY SHEETS
				IF @ysnFromPriceBasisContract = 0 AND @ysnDPOwnedType = 1
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
																				WHEN ((a.intItemType = 3 AND DSC.strDiscountChargeType = 'Dollar') OR a.intItemType = 2) AND @ysnDPOwnedType = 0 THEN 
																					case when @ysnFromPriceBasisContract = 1 and a.intItemType = 2 then 'Other Charge Expense' else  'AP Clearing' end 
																				WHEN a.intItemType = 1 THEN 'AP Clearing'
																				WHEN @ysnDPOwnedType = 1 and a.intItemType = 3  AND CS.intTicketId IS NOT NULL then 'AP Clearing'
																				ELSE 'Other Charge Expense' 
																			END
																				)
					,[intContractHeaderId]			= case when a.intItemType = 1 then  a.[intContractHeaderId] else null end -- need to set the contract details to null for non item
					,[intContractDetailId]			= a.[intContractDetailId] -- need to set the contract details to null for non item
					,[intInventoryReceiptItemId] = 
													CASE 
														WHEN ST.ysnDPOwnedType = 0 THEN NULL
														ELSE 
																CASE 
																		WHEN a.intItemType = 1 AND CS.intTicketId IS NOT NULL THEN RI.intInventoryReceiptItemId
																		ELSE NULL
																END
													END
					,[intCustomerStorageId]			= a.[intCustomerStorageId]
					,[intSettleStorageId]			= @intSettleStorageId
					,[dblOrderQty]					= CASE	
														WHEN CD.intContractDetailId is not null and intItemType = 1 then ROUND(dbo.fnCalculateQtyBetweenUOM(b.intItemUOMId,@intUnitMeasureId, CD.dblQuantity),6) 
														WHEN ISNULL(availableQtyForVoucher.dblContractUnits,0) > 0 THEN availableQtyForVoucher.dblContractUnits
														WHEN @origdblSpotUnits > 0 THEN ROUND(dbo.fnCalculateQtyBetweenUOM(b.intItemUOMId,@intCashPriceUOMId,a.dblUnits),6) 
														ELSE a.dblUnits 
													END
														
					,[dblOrderUnitQty]				= 1
					,[intOrderUOMId]				= CASE
														WHEN @origdblSpotUnits > 0 THEN @intCashPriceUOMId
														ELSE b.intItemUOMId
													END
					,[dblQuantityToBill]			= case when @doPartialHistory = 1 then
															case WHEN @ysnFromPriceBasisContract = 1 and (intItemType = 2 or intItemType = 3)
																	then a.dblUnits
																WHEN (intItemType = 2 or intItemType = 3)
																	then a.dblUnits
																when availableQtyForVoucher.dblAvailableQuantity >  a.dblUnits then a.dblUnits																	
																WHEN @origdblSpotUnits > 0 THEN ROUND(dbo.fnCalculateQtyBetweenUOM(b.intItemUOMId,@intCashPriceUOMId,a.dblUnits),6) 
																else isnull(availableQtyForVoucher.dblAvailableQuantity, @dblQtyFromCt) end
														else
															CASE 
																WHEN (a.intPricingTypeId = 2 or a.intPricingTypeId in (1, 6) ) and availableQtyForVoucher.intContractDetailId is not null and availableQtyForVoucher.dblAvailableQuantity > 0
																	and intItemType = 1
																	THEN availableQtyForVoucher.dblAvailableQuantity -- @dblQtyFromCt 																		
																WHEN @origdblSpotUnits > 0 
																	THEN ROUND(dbo.fnCalculateQtyBetweenUOM(b.intItemUOMId,@intCashPriceUOMId,a.dblUnits),6) 
																WHEN a.intPricingTypeId in (1, 6) and @ysnFromPriceBasisContract = 1 
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
														end
					,[intQtyToBillUOMId]			= CASE
														WHEN @origdblSpotUnits > 0 THEN @intCashPriceUOMId
														ELSE b.intItemUOMId
													END
					,[dblCost]						= 
														case when @doPartialHistory = 1 then
															case WHEN (intItemType = 2 or intItemType = 3) then a.dblCashPrice
															else isnull(availableQtyForVoucher.dblCashPrice, a.dblCashPrice) end
														else
															CASE																
																WHEN (intItemType = 2 or intItemType = 3) then a.dblCashPrice
																when availableQtyForVoucher.intContractDetailId is not null and @ysnFromPriceBasisContract = 1 then
																	ISNULL(dbo.fnCTConvertQtyToTargetItemUOM(a.intContractUOMId,b.intItemUOMId, availableQtyForVoucher.dblCashPrice),0)
																WHEN a.[intContractHeaderId] IS NOT NULL THEN dbo.fnCTConvertQtyToTargetItemUOM(a.intContractUOMId,b.intItemUOMId,a.dblCashPrice)
																ELSE a.dblCashPrice
															END
														end					
															
					,[dblOldCost]					=  case when @ysnFromPriceBasisContract = 0 then null 
														else 
															case 
															when (a.intContractHeaderId is not null and a.intPricingTypeId = 1 and CH.intPricingTypeId <> 2) or
																(@origdblSpotUnits > 0) then null
															WHEN a.[intContractHeaderId] IS NOT NULL AND @ysnFromPriceBasisContract = 1 
															--and (@dblQtyFromCt = @dblSelectedUnits) 
															THEN 															
																(
																	select dblCost from tblICInventoryTransaction IT
																		where IT.intTransactionId = @intSettleStorageId
																			and IT.intTransactionTypeId = 44
																			and IT.intItemId = a.intItemId
																			and IT.intTransactionDetailId = CC.intSettleContractId
																)
																--IT.dblCost--RI.dblUnitCost --dbo.fnCTConvertQtyToTargetItemUOM(a.intContractUOMId,RI.intCostUOMId, RI.dblUnitCost)
																WHEN CS.intStorageTypeId = 2 THEN 
																(select dblCost from tblICInventoryTransaction IT
																inner join tblGRStorageHistory STH
																	on STH.intTransferStorageId = IT.intTransactionId
																	where IT.intTransactionTypeId = 56
																		and IT.intItemId = a.intItemId)
															else null end
														end
					,[dblCostUnitQty]				= ISNULL(a.dblCostUnitQty,1)
					,[intCostUOMId]					= CASE
														WHEN @origdblSpotUnits > 0 THEN @intCashPriceUOMId 
														WHEN a.[intContractHeaderId] IS NOT NULL THEN a.intContractUOMId
														ELSE b.intItemUOMId
													END
					,[dblNetWeight]					= case when @doPartialHistory = 1 then
															case WHEN @ysnFromPriceBasisContract = 1 and (intItemType = 2 or intItemType = 3)
																	then a.dblUnits
																WHEN (intItemType = 2 or intItemType = 3)
																	then a.dblUnits
																when availableQtyForVoucher.dblAvailableQuantity >  a.dblUnits then a.dblUnits 															
																WHEN @origdblSpotUnits > 0 THEN ROUND(dbo.fnCalculateQtyBetweenUOM(b.intItemUOMId,@intCashPriceUOMId,a.dblUnits),6) 
																else isnull(availableQtyForVoucher.dblAvailableQuantity, @dblQtyFromCt) end
														else
															CASE 
																WHEN (a.intPricingTypeId = 2 or a.intPricingTypeId in (1, 6) ) and availableQtyForVoucher.intContractDetailId is not null and availableQtyForVoucher.dblAvailableQuantity > 0
																and intItemType = 1
																	THEN availableQtyForVoucher.dblAvailableQuantity -- @dblQtyFromCt 																
																WHEN @origdblSpotUnits > 0 
																	THEN ROUND(dbo.fnCalculateQtyBetweenUOM(b.intItemUOMId,@intCashPriceUOMId,a.dblUnits),6) 
																WHEN a.intPricingTypeId in (1, 6) and @ysnFromPriceBasisContract = 1 
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
														end												
					,[dblWeightUnitQty]				= 1 
					,[intWeightUOMId]				= CASE
														WHEN a.[intContractHeaderId] IS NOT NULL THEN b.intItemUOMId
														ELSE NULL
													END	
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
				JOIN tblGRStorageType ST
					ON ST.intStorageScheduleTypeId = CS.intStorageTypeId
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
				LEFT JOIN tblCTContractDetail CD
					ON CD.intContractDetailId = a.intContractDetailId				
				LEFT JOIN tblCTContractHeader CH
					ON CD.intContractHeaderId = CH.intContractHeaderId
				left join (
					select						
						intContractDetailId,	intPriceFixationDetailId, dblCashPrice, dblAvailableQuantity, dblContractUnits, intPricingTypeId						
						from @avqty  			
						--from vyuCTAvailableQuantityForVoucher 					
				) availableQtyForVoucher
					on availableQtyForVoucher.intContractDetailId = a.intContractDetailId

				left join tblGRSettleContract CC
					on CC.intSettleStorageId = SST.intSettleStorageId
						and CC.intContractDetailId = availableQtyForVoucher.intContractDetailId
							
				WHERE a.dblCashPrice <> 0 
					AND a.dblUnits <> 0 
					AND SST.intSettleStorageId = @intSettleStorageId
				AND CASE WHEN (a.intPricingTypeId = 2 AND ISNULL(@dblCashPriceFromCt,0) = 0) THEN 0 ELSE 1 END = 1
				and (	a.intContractDetailId is null or  
						CH.intPricingTypeId in (1, 6) or
							(CH.intPricingTypeId = 3 and availableQtyForVoucher.intPricingTypeId = 1) or
							(CH.intPricingTypeId = 2 and 
								a.intContractDetailId is not null 
								and availableQtyForVoucher.dblAvailableQuantity > 0)
						or (availableQtyForVoucher.intContractDetailId is not null 
							and isnull(availableQtyForVoucher.intPricingTypeId, 0) = 1)
					)
				and a.intSettleVoucherKey not in ( select id from @DiscountSCRelation )
				--and (@ysnDPOwnedType = 0 or (@ysnDPOwnedType = 1 and a.intItemType = 1))
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
								join tblAPBill d
									on c.intBillId = d.intBillId
										and d.strVendorOrderNumber = @TicketNo
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
								dblQuantityToBill = isnull(@total_units_for_voucher, dblQuantityToBill), 
								dblNetWeight = isnull(@total_units_for_voucher, dblNetWeight),
								dblOrderQty =  isnull(@total_units_for_voucher, dblOrderQty)
							from @voucherPayable a
							join @SettleVoucherCreate b
								on a.intItemId = b.intItemId
							where b.intItemType = 2
					end

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
						--AND ScaleSetup.intFreightItemId = ReceiptCharge.[intChargeId]
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

				---Adding Freight Charges.
				
								
				---Adding Contract Other Charges.
				--INSERT INTO @voucherDetailStorage
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
				
				IF @dblVoucherTotal > 0 AND EXISTS(SELECT NULL FROM @voucherPayable DS INNER JOIN tblICItem I on I.intItemId = DS.intItemId WHERE I.strType = 'Inventory'  and dblOrderQty <> 0)
				BEGIN
					update @voucherPayable set ysnStage = 0
					EXEC uspAPCreateVoucher @voucherPayable, @voucherPayableTax, @intCreatedUserId, 1, @ErrMsg, @createdVouchersId OUTPUT
				END
				ELSE 
					IF(EXISTS(SELECT NULL FROM @voucherPayable DS INNER JOIN tblICItem I on I.intItemId = DS.intItemId WHERE I.strType = 'Inventory' and dblOrderQty <> 0))
					BEGIN
						BEGIN
						RAISERROR('Total Voucher will be negative',16,1)
						END
					END

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

						EXEC [uspAPUpdateVoucherDetailTax] @detailCreated

					end





					--DELETE FROM @detailCreated

					--INSERT INTO @detailCreated
					--SELECT intBillDetailId
					--FROM tblAPBillDetail
					--WHERE intBillId = CAST(@createdVouchersId AS INT)
					--	AND (CASE 
					--			WHEN @ysnDPOwnedType = 1 THEN 
					--				CASE WHEN intInventoryReceiptChargeId IS NULL THEN 1 ELSE 0 END 
					--			ELSE 1 
					--		END = 1)

					--EXEC [uspAPUpdateVoucherDetailTax] @detailCreated

					--IF @@ERROR <> 0
					--	GOTO SettleStorage_Exit;

					--UPDATE bd
					--SET bd.dblRate = CASE 
					--						WHEN ISNULL(bd.dblRate, 0) = 0 THEN 1
					--						ELSE bd.dblRate
					--				 END
					--FROM tblAPBillDetail bd
					--WHERE bd.intBillId = CAST(@createdVouchersId AS INT)

					--UPDATE tblAPBill
					--SET dblTotal = (
					--					SELECT ROUND(SUM(bd.dblTotal) + SUM(bd.dblTax), 6)
					--					FROM tblAPBillDetail bd
					--					WHERE bd.intBillId = CAST(@createdVouchersId AS INT)
					--				)
					--WHERE intBillId = CAST(@createdVouchersId AS INT)

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
									where b.ysnInventoryCost = 1 and strType = 'Other Charge'

					IF ISNULL(@dblTotal,0) > 0 AND ISNULL(@requireApproval , 0) = 0
					BEGIN							
							
								UPDATE tblGRSettleStorage
									SET intBillId = @createdVouchersId
										WHERE intSettleStorageId = @intSettleStorageId  and @createdVouchersId is not null
										
								update a
									set dblPaidAmount = round((b.dblOldCost + isnull(@sum_e, 0)) * a.dblUnits , 2),
										dblPaidAmountRaw = (b.dblOldCost + isnull(@sum_e, 0)) * a.dblUnits,
										dblOldCost = b.dblOldCost
										from tblGRStorageHistory a
											join @voucherPayable b 
												on a.intContractHeaderId = b.intContractHeaderId
												and a.intCustomerStorageId = b.intCustomerStorageId
											-- join tblGRSettleStorageTicket d 
											-- 	on d.intCustomerStorageId = b.intCustomerStorageId
											-- join tblICInventoryTransaction c
											-- 	on c.strTransactionId = b.strVendorOrderNumber
											-- 		and c.intItemId = b.intItemId 
											-- 		and c.intTransactionId = d.intSettleStorageId
											-- 		and c.intTransactionDetailId = d.intSettleStorageTicketId													
										where strType = 'Settlement'										

								
							--IF @ysnFromTransferStorage = 0
							
							EXEC [dbo].[uspAPPostBill] 
								 @post = 1
								,@recap = 0
								,@isBatch = 0
								,@param = @intVoucherId
								,@userId = @intCreatedUserId
								,@transactionType = 'Settle Storage'
								,@success = @success OUTPUT

							-- We need to set the Paid Amount back to the raw again the purpose of rounding the Paid Amount to 2 decimal is for the
							-- Posting of voucher
							--Note that 19.2 Dev Ithaca is different from this one
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

					END

					IF(@success = 0)
					BEGIN
						SELECT TOP 1 @ErrMsg = strMessage FROM tblAPPostResult WHERE intTransactionId = @intVoucherId;
						RAISERROR (@ErrMsg, 16, 1);
						GOTO SettleStorage_Exit;
					END
					
					
					
					--Inserting data to price fixation detail 
					begin
						/*
							insert into tblCTPriceFixationDetailAPAR(intPriceFixationDetailId, intBillId, intBillDetailId, intConcurrencyId)
							select b.intPriceFixationDetailId, a.intBillId, a.intBillDetailId, 1 from tblAPBillDetail a 
								cross apply ( select intPriceFixationDetailId from @avqty ) b											
								where intBillId = @intVoucherId and a.intContractDetailId is not null and a.intContractHeaderId is not null
								and b.intPriceFixationDetailId is not null
						*/
						
						insert into tblCTPriceFixationDetailAPAR(intPriceFixationDetailId, intBillId, intBillDetailId, intConcurrencyId)
						select intPriceFixationDetailId, @intVoucherId, intBillDetailId, 1  from @avqty a 
							join tblCTContractDetail b
								on b.intContractDetailId = a.intContractDetailId
							join tblCTContractHeader c
								on c.intContractHeaderId = b.intContractHeaderId
									and c.intPricingTypeId = 2		
						where intBillDetailId is not null and intPriceFixationDetailId is not null
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
				-- JOIN tblICCommodityUnitMeasure CU 
				-- 	ON CU.intCommodityId = CS.intCommodityId 
				-- 		AND CU.ysnStockUnit = 1
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
				DECLARE @StorageHistoryStagingTable AS [StorageHistoryStagingTable]
				DECLARE @intStorageHistoryId INT
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
					, SV.dblCashPrice
					, CASE WHEN @intVoucherId = 0 THEN NULL ELSE @intVoucherId END
				FROM @SettleVoucherCreate SV
					INNER JOIN tblGRCustomerStorage CS ON CS.intCustomerStorageId = SV.intCustomerStorageId
					INNER JOIN tblICItemUOM IU ON IU.intItemId = CS.intItemId
						AND IU.ysnStockUnit = 1
				WHERE SV.intItemType = 1

				EXEC uspGRInsertStorageHistoryRecord @StorageHistoryStagingTable, @intStorageHistoryId OUTPUT
			END

			UPDATE tblGRSettleStorage
			SET ysnPosted = 1
				,intBillId = @createdVouchersId
			WHERE (intSettleStorageId = @intSettleStorageId  ) and @createdVouchersId is not null
		END

	SELECT @intSettleStorageId = MIN(intSettleStorageId)
	FROM tblGRSettleStorage	
	WHERE intParentSettleStorageId = @intParentSettleStorageId 
		AND intSettleStorageId > @intSettleStorageId

	END

	UPDATE tblGRSettleStorage
	SET ysnPosted = 1
	WHERE intSettleStorageId = @intParentSettleStorageId or  intParentSettleStorageId = @intParentSettleStorageId

	
	UPDATE tblGRStorageHistory
		SET intBillId = @createdVouchersId
		WHERE intSettleStorageId = @intParentSettleStorageId and @createdVouchersId is not null

	SettleStorage_Exit:
END TRY

BEGIN CATCH
	SET @ErrMsg = ERROR_MESSAGE()
	RAISERROR (@ErrMsg,16,1,'WITH NOWAIT')
END CATCH
