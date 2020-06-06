CREATE PROCEDURE [dbo].[uspCTProcessToInventoryShipment]

		@intContractDetailId	INT,
		@intUserId				INT,
		@dtmLocalDate			DATETIME
AS

	SET QUOTED_IDENTIFIER OFF
	SET ANSI_NULLS ON
	SET NOCOUNT ON
	SET XACT_ABORT ON
	SET ANSI_WARNINGS OFF

	DECLARE @ErrorMessage			NVARCHAR(MAX),
			@ErrorSeverity			INT,
			@ErrorState				INT,
			@InventoryReceiptId		INT,
			@ErrMsg					NVARCHAR(MAX),
			@intInventoryShipmentId	INT,
			@dtmShipDate			DATETIME = @dtmLocalDate--GETDATE()

	DECLARE @ShipmentStagingTable	ShipmentStagingTable,
			@OtherCharges			ShipmentChargeStagingTable,
			@ShipmentItemLotStaging ShipmentItemLotStagingTable

	
	IF EXISTS (SELECT 1 FROM vyuCTContractDetailView WHERE intContractDetailId = @intContractDetailId AND dblAvailableQty <= 0) 
	BEGIN 
		RAISERROR('No quantity is available to process.',16,1)
	END

	BEGIN TRY

		IF NOT EXISTS (SELECT 1 FROM tempdb..sysobjects WHERE id = OBJECT_ID('tempdb..#tmpAddItemShipmentResult')) 
		BEGIN 
			CREATE TABLE #tmpAddItemShipmentResult 
			(
				intInventoryShipmentId INT
			)
		END 

		INSERT INTO	@ShipmentStagingTable
		(
				intOrderType,
				intSourceType,
				intEntityCustomerId,
				dtmShipDate,
				intShipFromLocationId,
				intShipToLocationId,
				intFreightTermId,
				strSourceScreenName,
				strBOLNumber,

				intItemId,
				intOwnershipType,
				dblQuantity,
				intItemUOMId,
				intOrderId,
				intLineNo,
				intWeightUOMId,
				dblUnitPrice,
				intCurrencyId,
				intForexRateTypeId,
				dblForexRate,
				strChargesLink,
				intPriceUOMId,
				dblGross,
				dblTare,
				dblNet,
				intSubLocationId,
				intStorageLocationId
		)	
		SELECT	intOrderType			=	1,
				intSourceType			=	0,
				intEntityCustomerId		=	CH.intEntityId,
				dtmShipDate				=	@dtmShipDate,
				intShipFromLocationId	=	CD.intCompanyLocationId,
				intShipToLocationId		=	EL.intEntityLocationId,
				intFreightTermId		=	CD.intFreightTermId,
				strSourceScreenName		=	'Contract',
				strBOLNumber			=	'',

				intItemId				=	CD.intItemId,
				intOwnershipType		=	1,
				dblQuantity				=	ISNULL(CD.dblBalance,0)	- ISNULL(CD.dblScheduleQty,0),
				intItemUOMId			=	CD.intItemUOMId,
				intOrderId				=	CD.intContractHeaderId,
				intLineNo				=	CD.intContractDetailId,
				intWeightUOMId			=	CD.intNetWeightUOMId,
				dblUnitPrice			=	CASE	WHEN	CD.intPricingTypeId = 2 
													THEN	dbo.fnRKGetLatestClosingPrice(CD.intFutureMarketId,CD.intFutureMonthId,GETDATE()) + 
															dbo.fnCTConvertQtyToTargetItemUOM(IU.intItemUOMId,CD.intBasisUOMId, CD.dblBasis)
													ELSE	dbo.fnCTConvertQtyToTargetItemUOM(IU.intItemUOMId,CD.intPriceItemUOMId, AD.dblSeqPrice)
											END,
				intCurrencyId			=	AD.intSeqCurrencyId,
				intForexRateTypeId		=	CD.intRateTypeId,
				dblForexRate			=	CD.dblRate,
				strChargesLink			=	'CL-' + LTRIM(CD.intContractSeq),
				intPriceUOMId			=	IU.intItemUOMId,
				dblGross				=	dbo.fnCTConvertQtyToTargetItemUOM(CD.intItemUOMId,CD.intNetWeightUOMId, ISNULL(CD.dblBalance,0)	- ISNULL(CD.dblScheduleQty,0)),
				dblTare					=	0,
				dblNet					=	dbo.fnCTConvertQtyToTargetItemUOM(CD.intItemUOMId,CD.intNetWeightUOMId, ISNULL(CD.dblBalance,0)	- ISNULL(CD.dblScheduleQty,0)),
				intSubLocationId		=	CD.intSubLocationId,		
				intStorageLocationId	=	CD.intStorageLocationId

		FROM	tblCTContractDetail			CD	
		JOIN	tblCTContractHeader			CH	ON	CH.intContractHeaderId = CD.intContractHeaderId
		CROSS	APPLY	dbo.fnCTGetAdditionalColumnForDetailView(CD.intContractDetailId) AD
		JOIN	tblEMEntityLocation			EL	ON	EL.intEntityId			=	CH.intEntityId	AND
													EL.ysnDefaultLocation	=	1			
		JOIN	tblICItemUOM				IU	ON	IU.intItemId	=	CD.intItemId	
												AND	IU.ysnStockUnit	=	1															
		WHERE	CD.intContractDetailId = @intContractDetailId

		INSERT	INTO	@OtherCharges
		(
				intOrderType,
				intSourceType,
				intEntityCustomerId,
				dtmShipDate,
				intShipFromLocationId,
				intShipToLocationId,
				intFreightTermId,
				intContractId,
				intChargeId,
				strCostMethod,
				dblRate,
				intCostUOMId,
				intCurrency,
				dblAmount,
				ysnAccrue,
				intEntityVendorId,
				ysnPrice,
				strChargesLink,
				intContractDetailId
		) 
		
		SELECT	intOrderType			=	1,
				intSourceType			=	0,
				intEntityCustomerId		=	CH.intEntityId,
				dtmShipDate				=	@dtmShipDate,
				intShipFromLocationId	=	CD.intCompanyLocationId,
				intShipToLocationId		=	EL.intEntityLocationId,
				intFreightTermId		=	CD.intFreightTermId,

				intContractId			=	CC.intContractHeaderId,
				intChargeId				=	CC.intItemId,
				strCostMethod			=	CC.strCostMethod,
				dblRate					=	CASE WHEN CC.strCostMethod = 'Amount' THEN 0 ELSE CC.dblRate END,
				intCostUOMId			=	CC.intItemUOMId,
				intCurrency				=	CC.intCurrencyId,
				dblAmount				=	CASE WHEN CC.strCostMethod = 'Amount' THEN CC.dblRate ELSE 0 END,
				ysnAccrue				=	CC.ysnAccrue,
				intEntityVendorId		=	CC.intVendorId,
				ysnPrice				=	CC.ysnPrice,
				strChargesLink			=	'CL-' + LTRIM(CD.intContractSeq),
				intContractDetailId		=	CC.intContractDetailId
								
		FROM	vyuCTContractCostView	CC
		JOIN	tblCTContractDetail		CD	ON	CD.intContractDetailId	=	CC.intContractDetailId
		JOIN	tblCTContractHeader		CH	ON	CH.intContractHeaderId	=	CC.intContractHeaderId
		JOIN	tblEMEntityLocation		EL	ON	EL.intEntityId			=	CH.intEntityId
											AND	EL.ysnDefaultLocation	=	1						
		WHERE	CC.intContractDetailId	=	@intContractDetailId

		IF NOT EXISTS(SELECT * FROM  @ShipmentStagingTable)
		BEGIN
			RAISERROR('Please verify the stock unit for the item or default location is available for the entity.',16,1)
		END

		EXEC dbo.uspICAddItemShipment 
			@Items = @ShipmentStagingTable
			,@Charges = @OtherCharges
			,@Lots = @ShipmentItemLotStaging
			,@intUserId = @intUserId;
		
		IF EXISTS(SELECT * FROM #tmpAddItemShipmentResult)
		BEGIN
			SELECT TOP 1 @intInventoryShipmentId = intInventoryShipmentId FROM  #tmpAddItemShipmentResult	

			DECLARE @intInventoryShipmentItemId	INT = NULL,
					@dblQty						NUMERIC(18,6) = 0

			SELECT	@intInventoryShipmentItemId = MIN(intInventoryShipmentItemId) 
			FROM	tblICInventoryShipmentItem
			WHERE	intInventoryShipmentId = @intInventoryShipmentId

			WHILE ISNULL(@intInventoryShipmentItemId,0) > 0
			BEGIN
				SELECT	@dblQty						=	dblQuantity
				FROM	tblICInventoryShipmentItem 
				WHERE	intInventoryShipmentItemId	=	 @intInventoryShipmentItemId
									
				EXEC	uspCTUpdateScheduleQuantity
						@intContractDetailId	=	@intContractDetailId,
						@dblQuantityToUpdate	=	@dblQty,
						@intUserId				=	@intUserId,
						@intExternalId			=	@intInventoryShipmentItemId,
						@strScreenName			=	'Inventory Shipment'

				SELECT	@intInventoryShipmentItemId = MIN(intInventoryShipmentItemId) 
				FROM	tblICInventoryShipmentItem
				WHERE	intInventoryShipmentId = @intInventoryShipmentId	AND
						intInventoryShipmentItemId > @intInventoryShipmentItemId
			END

			SELECT	@intInventoryShipmentId
		END
		ELSE
		BEGIN
			SELECT 0
		END
	END TRY
	BEGIN CATCH
		SET @ErrMsg = ERROR_MESSAGE()  
		RAISERROR (@ErrMsg,18,1,'WITH NOWAIT')
	END CATCH