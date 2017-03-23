CREATE PROCEDURE [dbo].[uspCTProcessToInventoryShipment]

		@intContractDetailId	INT,
		@intUserId				INT		
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
			@dtmShipDate			DATETIME = GETDATE()

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
				dblForexRate
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
				dblUnitPrice			=	ISNULL(AD.dblSeqPrice,0),
				intCurrencyId			=	CD.intCurrencyId,
				intForexRateTypeId		=	CD.intRateTypeId,
				dblForexRate			=	CD.dblRate

		FROM	tblCTContractDetail			CD	
		JOIN	tblCTContractHeader			CH	ON	CH.intContractHeaderId = CD.intContractHeaderId
		CROSS	APPLY	dbo.fnCTGetAdditionalColumnForDetailView(CD.intContractDetailId) AD
		JOIN	tblEMEntityLocation			EL	ON	EL.intEntityId			=	CH.intEntityId	AND
													EL.ysnDefaultLocation	=	1				
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
				ysnPrice
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
				dblRate					=	CC.dblRate,
				intCostUOMId			=	CC.intItemUOMId,
				intCurrency				=	CC.intCurrencyId,
				dblAmount				=	0,
				ysnAccrue				=	CC.ysnAccrue,
				intEntityVendorId		=	CC.intVendorId,
				ysnPrice				=	CC.ysnPrice
								
		FROM	vyuCTContractCostView	CC
		JOIN	tblCTContractDetail		CD	ON	CD.intContractDetailId	=	CC.intContractDetailId
		JOIN	tblCTContractHeader		CH	ON	CH.intContractHeaderId	=	CC.intContractHeaderId
		JOIN	tblEMEntityLocation		EL	ON	EL.intEntityId			=	CH.intEntityId
											AND	EL.ysnDefaultLocation	=	1						
		WHERE	CC.intContractDetailId	=	@intContractDetailId

		IF NOT EXISTS(SELECT * FROM  @ShipmentStagingTable)
		BEGIN
			RETURN
		END

		EXEC dbo.uspICAddItemShipment @ShipmentStagingTable,@OtherCharges,@ShipmentItemLotStaging,@intUserId;
		
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