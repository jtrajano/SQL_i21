CREATE PROCEDURE [dbo].[uspCTProcessToInventoryReceipt]

		@intContractDetailId	INT,
		@intUserId				INT		
AS

	SET QUOTED_IDENTIFIER OFF
	SET ANSI_NULLS ON
	SET NOCOUNT ON
	SET XACT_ABORT ON
	SET ANSI_WARNINGS OFF

	DECLARE @ErrorMessage			NVARCHAR(4000)
	DECLARE @ErrorSeverity			INT
	DECLARE @ErrorState				INT
	DECLARE @InventoryReceiptId		INT
	DECLARE @ErrMsg					NVARCHAR(MAX)
	DECLARE	@intInventoryReceiptId	INT

	DECLARE @ReceiptStagingTable	ReceiptStagingTable,
			@OtherCharges			ReceiptOtherChargesTableType

	
	IF EXISTS (SELECT 1 FROM vyuCTContractDetailView WHERE intContractDetailId = @intContractDetailId AND dblAvailableQty <= 0) 
	BEGIN 
		RAISERROR('No quantity is available to process.',16,1)
	END

	IF NOT EXISTS (SELECT 1 FROM tempdb..sysobjects WHERE id = OBJECT_ID('tempdb..#tmpAddItemReceiptResult')) 
	BEGIN 
		CREATE TABLE #tmpAddItemReceiptResult 
		(
			intSourceId INT,
			intInventoryReceiptId INT
		)
	END 

	BEGIN TRY

		INSERT	INTO	@ReceiptStagingTable
		(
				strReceiptType,
				intEntityVendorId,
				intShipFromId,
				intLocationId,
				intItemId,
				intItemLocationId,
				intItemUOMId,
				intContractHeaderId,
				intContractDetailId,
				dtmDate,
				intShipViaId,
				dblQty,
				dblCost,
				intCostUOMId,
				intCurrencyId,
				dblExchangeRate,
				intLotId,
				intSubLocationId,
				intStorageLocationId,
				ysnIsStorage,
				intSourceId,	
				intSourceType,		 	
				strSourceId,
				strSourceScreenName
		)	
		SELECT	strReceiptType				=	'Purchase Contract',
				intEntityVendorId			=	CD.intEntityId,
				intShipFromId				=	EL.intEntityLocationId,
				intLocationId				=	CD.intCompanyLocationId,
				intItemId					=	CD.intItemId,
				intItemLocationId			=	CD.intCompanyLocationId,
				intItemUOMId				=	CD.intItemUOMId,
				intContractHeaderId			=	CD.intContractHeaderId,
				intContractDetailId			=	CD.intContractDetailId,
				dtmDate						=	CD.dtmStartDate,
				intShipViaId				=	CD.intShipViaId,
				dblQty						=	CD.dblAvailableQty,
				dblCost						=	CD.dblCashPrice,
				intCostUOMId				=	CD.intPriceItemUOMId,
				intCurrencyId				=	CD.intCurrencyId,
				dblExchangeRate				=	1,
				intLotId					=	NULL ,
				intSubLocationId			=	NULL,
				intStorageLocationId		=	NULL,
				ysnIsStorage				=	0,
				intSourceId					=	NULL,
				intSourceType		 		=	0,
				strSourceId					=	CD.strContractNumber,
				strSourceScreenName			=	'Contract'
				
		FROM	vyuCTContractDetailView		CD	
		JOIN	tblEntityLocation			EL	ON	EL.intEntityId			=	CD.intEntityId	AND
													EL.ysnDefaultLocation	=	1				LEFT
		JOIN	vyuICGetItemStock			SK	ON	SK.intItemId			=	CD.intItemId	AND		
													SK.intLocationId		=	CD.intCompanyLocationId
				
		WHERE	CD.intContractDetailId = @intContractDetailId

		INSERT	INTO	@OtherCharges
		(
				[intOtherChargeEntityVendorId],
				[intChargeId],
				[strCostMethod],
				[dblRate],
				[intCostUOMId],
				[intContractHeaderId],
				[intContractDetailId],
				[ysnAccrue],
				[strReceiptType],
				[intShipViaId],
				[intCurrencyId],
				[intEntityVendorId],
				[intShipFromId],
				[intLocationId]
		) 
		
	   SELECT	CC.intVendorId,
				CC.intItemId,
				CC.strCostMethod,
				CC.dblRate,
				CC.intItemUOMId,
				CC.intContractHeaderId,
				CC.intContractDetailId,
				CC.ysnAccrue,
				'Purchase Contract',
				CD.intShipViaId,
				CD.intCurrencyId,
				CD.intEntityId,
				EL.intEntityLocationId,
				CD.intCompanyLocationId
				
	   FROM		vyuCTContractCostView	CC
	   JOIN		vyuCTContractDetailView	CD	ON	CD.intContractDetailId	=	CC.intContractDetailId
	   JOIN		tblEntityLocation		EL	ON	EL.intEntityId			=	CD.intEntityId			AND
												EL.ysnDefaultLocation	=	1
	   WHERE	CC.intContractDetailId	=	@intContractDetailId

	

		IF NOT EXISTS(SELECT * FROM  @ReceiptStagingTable)
		BEGIN
    		RETURN
		END

		EXEC dbo.uspICAddItemReceipt @ReceiptStagingTable,@OtherCharges,@intUserId;
		
		IF EXISTS(SELECT * FROM #tmpAddItemReceiptResult)
		BEGIN
			SELECT TOP 1 @intInventoryReceiptId = intInventoryReceiptId FROM  #tmpAddItemReceiptResult	

			DECLARE @intInventoryReceiptItemId	INT = NULL,
					@dblQty						NUMERIC(18,6) = 0

			SELECT	@intInventoryReceiptItemId = MIN(intInventoryReceiptItemId) 
			FROM	tblICInventoryReceiptItem
			WHERE	intInventoryReceiptId = @intInventoryReceiptId

			WHILE ISNULL(@intInventoryReceiptItemId,0) > 0
			BEGIN
				SELECT	@dblQty						=	dblOpenReceive
				FROM	tblICInventoryReceiptItem 
				WHERE	intInventoryReceiptItemId	=	 @intInventoryReceiptItemId
									
				EXEC	uspCTUpdateScheduleQuantity
						@intContractDetailId	=	@intContractDetailId,
						@dblQuantityToUpdate	=	@dblQty,
						@intUserId				=	@intUserId,
						@intExternalId			=	@intInventoryReceiptItemId,
						@strScreenName			=	'Inventory Receipt'

				SELECT	@intInventoryReceiptItemId = MIN(intInventoryReceiptItemId) 
				FROM	tblICInventoryReceiptItem
				WHERE	intInventoryReceiptId = @intInventoryReceiptId	AND
						intInventoryReceiptItemId > @intInventoryReceiptItemId
			END

			SELECT	@intInventoryReceiptId
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