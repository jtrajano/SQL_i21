CREATE PROCEDURE [dbo].[uspCTCreateBillForBasisContract]
	  @intBasisContractDetailId INT
	 ,@dblCashPrice DECIMAL(24, 10)
	 ,@dblUnits DECIMAL(24, 10) = NULL
AS
BEGIN TRY
	SET NOCOUNT ON

	DECLARE @ErrMsg NVARCHAR(MAX)
	DECLARE @SettleStorageKey INT
	DECLARE @intSettleStorageId INT
	DECLARE @intParentSettleStorageId INT
	DECLARE @intBasisContractHeaderId INT
	DECLARE @EntityId INT
	DECLARE @intCommodityStockUomId INT
	DECLARE @intCreatedUserId INT
	DECLARE @intCreatedBillId AS INT
	DECLARE @voucherDetailStorage AS VoucherPayable
	DECLARE @dtmDate AS DATETIME
	
	DECLARE @TicketNo NVARCHAR(20)
	DECLARE @LocationId INT
	DECLARE @detailCreated AS Id
	DECLARE @strVoucher NVARCHAR(20)
	DECLARE @success AS BIT

	DECLARE @dblOldCost DECIMAL(24, 10)

	DECLARE @SettleStorage AS TABLE 
	(
		 intSettleStorageKey INT IDENTITY(1, 1)
		,intSettleStorageId INT
		,intParentSettleStorageId INT NULL
		,TicketNo  NVARCHAR(20)
	)
	
	DECLARE @SettleDiscountForContract AS TABLE 
	(
		 intSettleDiscountKey INT
		,[strType] NVARCHAR(40) COLLATE Latin1_General_CI_AS
		,intSettleStorageTicketId INT
		,intCustomerStorageId INT
		,[strStorageTicketNumber] NVARCHAR(40) COLLATE Latin1_General_CI_AS
		,[intItemId] INT
		,[strItem] NVARCHAR(40) COLLATE Latin1_General_CI_AS
		,[dblGradeReading] DECIMAL(24, 10) NULL
		,intContractDetailId INT
		,dblStorageUnits DECIMAL(24, 10)
		,dblDiscountUnPaid DECIMAL(24, 10)
		,intPricingTypeId INT
	)
	
	DECLARE @SettleStorageFeeForContract AS TABLE 
	(
		 intSettleDiscountKey INT
		,[strType] NVARCHAR(40) COLLATE Latin1_General_CI_AS
		,intSettleStorageTicketId INT
		,intCustomerStorageId INT
		,[strStorageTicketNumber] NVARCHAR(40) COLLATE Latin1_General_CI_AS
		,[intItemId] INT
		,[strItem] NVARCHAR(40) COLLATE Latin1_General_CI_AS
		,[dblGradeReading] DECIMAL(24, 10) NULL
		,intContractDetailId INT
		,dblStorageUnits DECIMAL(24, 10)
		,dblDiscountUnPaid DECIMAL(24, 10)
		,intPricingTypeId INT
	)

	SET @dtmDate = GETDATE()

	SELECT
	  @EntityId					= CH.intEntityId
	 ,@intCreatedUserId			= ISNULL(CH.intLastModifiedById,CH.intCreatedById)  
	 ,@intBasisContractHeaderId = CH.intContractHeaderId
	 ,@dblCashPrice				= dbo.fnCTConvertQuantityToTargetItemUOM(CD.intItemId,C1.intUnitMeasureId,PU.intUnitMeasureId,CD.dblCashPrice)
	FROM		tblCTContractDetail			CD
	JOIN		tblCTContractHeader         CH  ON  CH.intContractHeaderId = CD.intContractHeaderId
	LEFT JOIN	tblICItemUOM				PU	ON	PU.intItemUOMId		   = CD.intPriceItemUOMId		
	LEFT JOIN   tblICCommodityUnitMeasure	C1	ON	C1.intCommodityId	   = CH.intCommodityId
	WHERE       C1.ysnStockUnit=1 AND CD.intContractDetailId = @intBasisContractDetailId


	INSERT INTO @SettleStorage(intSettleStorageId, intParentSettleStorageId, TicketNo)
	SELECT SC.intSettleStorageId, SS.intParentSettleStorageId, SS.strStorageTicket 
	FROM tblGRSettleContract SC
	JOIN tblGRSettleStorage SS ON SS.intSettleStorageId = SC.intSettleStorageId
	WHERE SC.intContractDetailId = @intBasisContractDetailId
	AND SS.intParentSettleStorageId IS NOT NULL
	--AND NOT EXISTS(SELECT TOP 1 1 FROM tblAPBillDetail WHERE intContractDetailId = @intBasisContractDetailId)

	SELECT @SettleStorageKey = MIN(intSettleStorageKey)
	FROM @SettleStorage

	WHILE @SettleStorageKey > 0
	BEGIN
	
			SET		@intSettleStorageId			= NULL
			SET		@intParentSettleStorageId	= NULL
			SET		@TicketNo					= NULL
			SET		@LocationId					= NULL
			SET		@intCommodityStockUomId		= NULL

			SELECT @intSettleStorageId =intSettleStorageId, @intParentSettleStorageId = intParentSettleStorageId, @TicketNo = TicketNo  
			FROM @SettleStorage  
			WHERE intSettleStorageKey = @SettleStorageKey
			
			SELECT @LocationId = SS.intCompanyLocationId ,@intCommodityStockUomId =SS.intCommodityStockUomId 
			FROM tblGRSettleStorage SS
			WHERE SS.intSettleStorageId = @intSettleStorageId
			
			SELECT TOP 1 @dblOldCost = ISNULL(a.dblLastSettle,0) + ISNULL(e.dblBasis,0)
			FROM tblRKFutSettlementPriceMarketMap a
			JOIN tblRKFuturesSettlementPrice b
				ON b.intFutureSettlementPriceId = a.intFutureSettlementPriceId
			JOIN tblRKFuturesMonth c
				ON c.intFutureMonthId = a.intFutureMonthId
			JOIN tblRKFutureMarket d
				ON d.intFutureMarketId = b.intFutureMarketId
			JOIN tblCTContractDetail e
				ON e.intFutureMarketId = b.intFutureMarketId
			WHERE e.intContractDetailId = @intBasisContractDetailId
			ORDER BY b.dtmPriceDate DESC
			
			DELETE FROM @voucherDetailStorage
			------------------------------Insert Inventory Item-------------------------------------
			INSERT INTO @voucherDetailStorage 
			(
				[intCustomerStorageId]
				,[intItemId]
				,[intAccountId]
				,[dblQuantityToBill]
				,[strMiscDescription]
				,[dblOldCost]
				,[dblCost]
				,[intContractHeaderId]
				,[intContractDetailId]
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
			)
			 SELECT 
			 intCustomerStorageId	= SST.intCustomerStorageId
			,intItemId				= SS.intItemId
			,[intAccountId]			= [dbo].[fnGetItemGLAccount](Item.intItemId, ItemLoc.intItemLocationId, 'AP Clearing')
			,[dblQuantityToBill]	= CASE WHEN SST.dblUnits <= SC.dblUnits THEN ROUND(SST.dblUnits,2) ELSE ROUND(SC.dblUnits,2) END
			,[strMiscDescription]	= Item.[strItemNo]
			,[dblOldCost]			= @dblOldCost
			,[dblCost]				= @dblCashPrice
			,intContractHeaderId	= @intBasisContractHeaderId
			,intContractDetailId	= @intBasisContractDetailId
			,[dblOrderQty]	    	= CS.dblOriginalBalance
			,[intQtyToBillUOMId]	= SS.intCommodityStockUomId
			,[intCostUOMId]			= SS.intCommodityStockUomId
			,[dblWeightUnitQty]		= 1 
			,[dblCostUnitQty]		= 1 
			,[dblQtyToBillUnitQty]	= 1
			,[dblNetWeight]			= 0
			,[intShipToId]			= @LocationId
			,[intEntityVendorId]	= @EntityId
			,[intTransactionType]	= 1
			,[dtmVoucherDate]		= @dtmDate
			FROM tblGRSettleContract SC
			JOIN tblGRSettleStorage SS ON SS.intSettleStorageId = SC.intSettleStorageId
			JOIN tblGRSettleStorageTicket SST ON SST.intSettleStorageId = SC.intSettleStorageId AND SST.intSettleStorageId = SS.intSettleStorageId
			JOIN tblGRCustomerStorage     CS  ON CS.intCustomerStorageId = SST.intCustomerStorageId
			JOIN tblICItem Item ON Item.intItemId = SS.intItemId
			JOIN tblICItemLocation as ItemLoc on ItemLoc.intItemId = Item.intItemId and ItemLoc.intLocationId = CS.intCompanyLocationId
			WHERE SC.intContractDetailId	= @intBasisContractDetailId
			AND SS.intSettleStorageId   = @intSettleStorageId
			AND SS.intParentSettleStorageId IS NOT NULL
			--AND NOT EXISTS(SELECT TOP 1 1 FROM tblAPBillDetail WHERE intContractDetailId = @intBasisContractDetailId)
			------------------------------Insert Discount Item-------------------------------------
			DELETE @SettleDiscountForContract
			
			INSERT INTO @SettleDiscountForContract
			(
			   intSettleDiscountKey		
			  ,[strType]					
			  ,intSettleStorageTicketId	
			  ,intCustomerStorageId		
			  ,[strStorageTicketNumber]	
			  ,[intItemId]				
			  ,[strItem]					
			  ,[dblGradeReading]			
			  ,intContractDetailId		
			  ,dblStorageUnits			
			  ,dblDiscountUnPaid			
			  ,intPricingTypeId
			)
			EXEC uspGRCalculateSettleDiscountForContract @intSettleStorageId

			INSERT INTO @voucherDetailStorage 
			(
				 [intCustomerStorageId]
				,[intItemId]
				,[intAccountId]
				,[dblQuantityToBill]
				,[strMiscDescription]
				,[dblCost]
				,[intContractHeaderId]
				,[intContractDetailId]
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
				)
			SELECT 
			 [intCustomerStorageId]   = SS.[intCustomerStorageId]
			,[intItemId]			  = SS.[intItemId]
			,[intAccountId]			  = [dbo].[fnGetItemGLAccount](Item.intItemId, ItemLoc.intItemLocationId, 'AP Clearing')
			,[dblQuantityToBill]	  = SS.dblStorageUnits
			,[strMiscDescription]	  = Item.[strItemNo]
			,[dblCost]				  = SS.dblDiscountUnPaid
			,[intContractHeaderId]	  = @intBasisContractHeaderId
			,[intContractDetailId]	  = @intBasisContractDetailId
			,[dblOrderQty]			  = CS.dblOriginalBalance
			,[intQtyToBillUOMId]	  = @intCommodityStockUomId
			,[intCostUOMId]			  = @intCommodityStockUomId
			,[dblWeightUnitQty]		  = 1 
			,[dblCostUnitQty]		  = 1 
			,[dblQtyToBillUnitQty]	  = 1
			,[dblNetWeight] 		  = 0 
			,[intShipToId]			  = @LocationId
			,[intEntityVendorId]	  = @EntityId
			,[intTransactionType]	  = 1
			,[dtmVoucherDate]		  = @dtmDate
			FROM
			@SettleDiscountForContract SS
			JOIN tblICItem Item ON Item.intItemId = SS.intItemId
			JOIN tblGRSettleStorageTicket SST ON SST.intSettleStorageTicketId = SS.intSettleStorageTicketId		
			JOIN tblGRCustomerStorage     CS  ON CS.intCustomerStorageId = SST.intCustomerStorageId	
			JOIN tblICItemLocation as ItemLoc on ItemLoc.intItemId = Item.intItemId and ItemLoc.intLocationId = CS.intCompanyLocationId
			WHERE intContractDetailId = @intBasisContractDetailId AND SST.intSettleStorageId = @intSettleStorageId

			INSERT INTO @voucherDetailStorage 
			(
				[intCustomerStorageId]
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
			)
			EXEC [uspGRCalculateSettleStorageFeeForContract]  @intParentSettleStorageId

			UPDATE @voucherDetailStorage SET dblQuantityToBill = dblQuantityToBill* -1 WHERE ISNULL(dblCost,0) < 0
			UPDATE @voucherDetailStorage SET dblCost = dblCost* -1 WHERE ISNULL(dblCost,0) < 0
			UPDATE @voucherDetailStorage SET intContractHeaderId = @intBasisContractHeaderId, intContractDetailId = @intBasisContractDetailId
			
			EXEC [dbo].[uspAPCreateVoucher]
			@voucherPayables = @voucherDetailStorage
			,@userId = @intCreatedUserId
			,@createdVouchersId = @intCreatedBillId OUTPUT

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

			
			SELECT @SettleStorageKey = MIN(intSettleStorageKey)
			FROM @SettleStorage WHERE intSettleStorageKey > @SettleStorageKey

	END

	SettleStorage_Exit:

END TRY

BEGIN CATCH
	SET @ErrMsg = ERROR_MESSAGE()
	RAISERROR (@ErrMsg,16,1,'WITH NOWAIT')
END CATCH

