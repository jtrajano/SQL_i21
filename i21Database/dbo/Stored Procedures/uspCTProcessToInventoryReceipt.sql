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
		INSERT INTO	@ReceiptStagingTable
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
				intGrossNetUOMId,
				dblGross,
				dblNet,
				dblCost,
				intCostUOMId,
				intCurrencyId,
				intSubCurrencyCents, 
				dblExchangeRate,
				intLotId,
				intSubLocationId,
				intStorageLocationId,
				ysnIsStorage,
				intSourceId,	
				intSourceType,		 	
				strSourceId,
				strSourceScreenName,
				ysnSubCurrency,
				intForexRateTypeId,
				dblForexRate
		)	
		SELECT	strReceiptType				=	'Purchase Contract',
				intEntityVendorId			=	CH.intEntityId,
				intShipFromId				=	EL.intEntityLocationId,
				intLocationId				=	CD.intCompanyLocationId,
				intItemId					=	CD.intItemId,
				intItemLocationId			=	CD.intCompanyLocationId,
				intItemUOMId				=	CD.intItemUOMId,
				intContractHeaderId			=	CD.intContractHeaderId,
				intContractDetailId			=	CD.intContractDetailId,
				dtmDate						=	CD.dtmStartDate,
				intShipViaId				=	CD.intShipViaId,
				dblQty						=	ISNULL(CD.dblBalance,0)		-	ISNULL(CD.dblScheduleQty,0),
				intGrossNetUOMId			=	ISNULL(CD.intNetWeightUOMId,0),	
				dblGross					=	dbo.fnCTConvertQtyToTargetItemUOM(CD.intItemUOMId,CD.intNetWeightUOMId,ISNULL(CD.dblBalance,0)-ISNULL(CD.dblScheduleQty,0)),
				dblNet						=	dbo.fnCTConvertQtyToTargetItemUOM(CD.intItemUOMId,CD.intNetWeightUOMId,ISNULL(CD.dblBalance,0)-ISNULL(CD.dblScheduleQty,0)),
				dblCost						=	ISNULL(AD.dblSeqPrice,0),
				intCostUOMId				=	ISNULL(AD.intSeqPriceUOMId, CD.intItemUOMId), -- If Seq-price-uom is null, then use the contract-detail-item-uom. 
				intCurrencyId				=	ISNULL(SC.intMainCurrencyId, AD.intSeqCurrencyId),
				intSubCurrencyCents			=	ISNULL(SubCurrency.intCent, 1), 
				dblExchangeRate				=	1,
				intLotId					=	NULL ,
				intSubLocationId			=	ISNULL(CD.intSubLocationId,IL.intSubLocationId),
				intStorageLocationId		=	ISNULL(CD.intStorageLocationId,IL.intStorageLocationId),
				ysnIsStorage				=	0,
				intSourceId					=	NULL,
				intSourceType		 		=	0,
				strSourceId					=	CH.strContractNumber,
				strSourceScreenName			=	'Contract',
				ysnSubCurrency				=	SubCurrency.ysnSubCurrency,
				intForexRateTypeId			=	CD.intRateTypeId,
				dblForexRate				=	CD.dblRate

		FROM	tblCTContractDetail			CD	
		JOIN	tblCTContractHeader			CH	ON	CH.intContractHeaderId = CD.intContractHeaderId
		JOIN	tblICItemLocation			IL	ON	IL.intItemId	=	CD.intItemId AND IL.intLocationId = CD.intCompanyLocationId
		CROSS	APPLY	dbo.fnCTGetAdditionalColumnForDetailView(CD.intContractDetailId) AD
		JOIN	tblEMEntityLocation			EL	ON	EL.intEntityId			=	CH.intEntityId	AND
													EL.ysnDefaultLocation	=	1				LEFT
		JOIN	vyuICGetItemStock			SK	ON	SK.intItemId			=	CD.intItemId	AND		
													SK.intLocationId		=	CD.intCompanyLocationId
		LEFT JOIN tblSMCurrency				SC	ON	SC.intCurrencyID		=	AD.intSeqCurrencyId
		LEFT JOIN tblSMCurrency				SubCurrency  ON SubCurrency.intCurrencyID = CASE WHEN SC.intMainCurrencyId IS NOT NULL THEN  CD.intCurrencyId ELSE NULL END 
		WHERE	CD.intContractDetailId = @intContractDetailId

		INSERT	INTO	@OtherCharges
		(
				[intOtherChargeEntityVendorId],
				[intChargeId],
				[strCostMethod],
				[dblRate],
				[dblAmount],
				[intCostUOMId],
				[intContractHeaderId],
				[intContractDetailId],
				[ysnAccrue],
				[strReceiptType],
				[intShipViaId],
				[intCurrencyId],
				[intEntityVendorId],
				[intShipFromId],
				[intLocationId],
				[ysnPrice],
				[ysnSubCurrency],
				[intCostCurrencyId]
		) 
		
		SELECT	CC.intVendorId,
				CC.intItemId,
				CC.strCostMethod,
				CASE WHEN CC.strCostMethod = 'Amount' THEN 0 ELSE CC.dblRate END,
				CASE WHEN CC.strCostMethod = 'Amount' THEN CC.dblRate ELSE 0 END,
				CC.intItemUOMId,
				CC.intContractHeaderId,
				CC.intContractDetailId,
				CC.ysnAccrue,
				'Purchase Contract',
				CD.intShipViaId,
				ISNULL(CD.intMainCurrencyId, CD.intCurrencyId),
				CD.intEntityId,
				EL.intEntityLocationId,
				CD.intCompanyLocationId,
				CC.ysnPrice,
				CY.ysnSubCurrency,
				CY.intCurrencyID
								
		FROM	vyuCTContractCostView	CC
		JOIN	vyuCTContractDetailView	CD	ON	CD.intContractDetailId	=	CC.intContractDetailId
		JOIN	tblEMEntityLocation		EL	ON	EL.intEntityId			=	CD.intEntityId			AND
												EL.ysnDefaultLocation	=	1						LEFT
		JOIN	tblSMCurrency			CY  ON	CY.intCurrencyID		=	CC.intCurrencyId

		WHERE	CC.intContractDetailId	=	@intContractDetailId
		AND		ISNULL(CC.ysnBasis,0) <> 1

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