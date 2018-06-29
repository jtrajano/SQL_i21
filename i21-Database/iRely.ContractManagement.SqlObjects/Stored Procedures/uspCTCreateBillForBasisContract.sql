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
	DECLARE @intBasisContractHeaderId INT
	DECLARE @EntityId INT
	DECLARE @intCommodityStockUomId INT
	DECLARE @intCreatedUserId INT
	DECLARE @intCreatedBillId AS INT
	DECLARE @voucherDetailStorage AS [VoucherDetailStorage]
	DECLARE @dtmDate AS DATETIME
	
	DECLARE @TicketNo NVARCHAR(20)
	DECLARE @LocationId INT
	DECLARE @detailCreated AS Id
	DECLARE @strVoucher NVARCHAR(20)
	DECLARE @success AS BIT

	DECLARE @SettleStorage AS TABLE 
	(
		 intSettleStorageKey INT IDENTITY(1, 1)
		,intSettleStorageId INT
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


	INSERT INTO @SettleStorage(intSettleStorageId,TicketNo)
	SELECT SC.intSettleStorageId,SS.strStorageTicket 
	FROM tblGRSettleContract SC
	JOIN tblGRSettleStorage SS ON SS.intSettleStorageId = SC.intSettleStorageId
	WHERE ISNULL(SS.intBillId,0) > 0 AND SC.intContractDetailId = @intBasisContractDetailId

	SELECT @SettleStorageKey = MIN(intSettleStorageKey)
	FROM @SettleStorage

	WHILE @SettleStorageKey > 0
	BEGIN
	
			SET    @intSettleStorageId     = NULL
			SET    @TicketNo		       = NULL
			SET    @LocationId		       = NULL
			SET    @intCommodityStockUomId = NULL

			SELECT @intSettleStorageId =intSettleStorageId ,@TicketNo = TicketNo  
			FROM @SettleStorage  
			WHERE intSettleStorageKey = @SettleStorageKey
			
			SELECT @LocationId = SS.intCompanyLocationId ,@intCommodityStockUomId =SS.intCommodityStockUomId 
			FROM tblGRSettleStorage SS
			WHERE SS.intSettleStorageId = @intSettleStorageId

				DELETE FROM @voucherDetailStorage
				------------------------------Insert Inventory Item-------------------------------------
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
			 intCustomerStorageId	= SST.intCustomerStorageId
			,intItemId				= SS.intItemId
			,[intAccountId]			= NULL
			,[dblQtyReceived]		= CASE WHEN SST.dblUnits <= SC.dblUnits THEN ROUND(SST.dblUnits,2) ELSE ROUND(SC.dblUnits,2) END
			,[strMiscDescription]	= Item.[strItemNo]
			,[dblCost]				= @dblCashPrice
			,intContractHeaderId	= @intBasisContractHeaderId
			,intContractDetailId	= @intBasisContractDetailId
			,[intUnitOfMeasureId]	= SS.intCommodityStockUomId
			,[intCostUOMId]			= SS.intCommodityStockUomId
			,[dblWeightUnitQty]		= 1 
			,[dblCostUnitQty]		= 1 
			,[dblUnitQty]			= 1
			,[dblNetWeight]			= 0 
			FROM tblGRSettleContract SC
			JOIN tblGRSettleStorage SS ON SS.intSettleStorageId = SC.intSettleStorageId
			JOIN tblGRSettleStorageTicket SST ON SST.intSettleStorageId = SC.intSettleStorageId AND SST.intSettleStorageId = SS.intSettleStorageId
			JOIN tblGRCustomerStorage     CS  ON CS.intCustomerStorageId = SST.intCustomerStorageId
			JOIN tblICItem Item ON Item.intItemId = SS.intItemId
			WHERE ISNULL(SS.intBillId,0) > 0 
			AND SC.intContractDetailId	= @intBasisContractDetailId
			AND SS.intSettleStorageId   = @intSettleStorageId

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
			 [intCustomerStorageId]   = SS.[intCustomerStorageId]
			,[intItemId]			  = SS.[intItemId]
			,[intAccountId]			  = NULL
			,[dblQtyReceived]		  = SS.dblStorageUnits
			,[strMiscDescription]	  = Item.[strItemNo]
			,[dblCost]				  = SS.dblDiscountUnPaid
			,[intContractHeaderId]	  = @intBasisContractHeaderId
			,[intContractDetailId]	  = @intBasisContractDetailId
			,[intUnitOfMeasureId]	  = @intCommodityStockUomId
			,[intCostUOMId]			  = @intCommodityStockUomId
			,[dblWeightUnitQty]		  = 1 
			,[dblCostUnitQty]		  = 1 
			,[dblUnitQty]			  = 1
			,[dblNetWeight] 		  = 0 
			FROM
			@SettleDiscountForContract SS
			JOIN tblICItem Item ON Item.intItemId = SS.intItemId
			JOIN tblGRSettleStorageTicket SST ON SST.intSettleStorageTicketId = SS.intSettleStorageTicketId
			WHERE intContractDetailId = @intBasisContractDetailId AND SST.intSettleStorageId = @intSettleStorageId
			
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

