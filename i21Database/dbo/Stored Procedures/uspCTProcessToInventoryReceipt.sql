﻿CREATE PROCEDURE [dbo].[uspCTProcessToInventoryReceipt]

		@intContractDetailId	INT,
		@intUserId				INT		
AS

	SET QUOTED_IDENTIFIER OFF
	SET ANSI_NULLS ON
	SET NOCOUNT ON
	SET XACT_ABORT ON
	SET ANSI_WARNINGS OFF

	DECLARE @ErrorMessage			NVARCHAR(4000),
			@ErrorSeverity			INT,
			@ErrorState				INT,
			@InventoryReceiptId		INT,
			@ErrMsg					NVARCHAR(MAX),
			@intInventoryReceiptId	INT,
			@ysnRequireProducerQty	BIT,
			@ysnLoad				BIT,

			@ReceiptStagingTable		ReceiptStagingTable,
			@OtherCharges				ReceiptOtherChargesTableType,
			@ReceiptItemLotStagingTable	ReceiptItemLotStagingTable,
			@ReceiptTradeFinance		ReceiptTradeFinance
	
	SELECT TOP 1 @ysnRequireProducerQty = ysnRequireProducerQty FROM tblCTCompanyPreference 

	SELECT	@ysnLoad	=	ISNULL(CH.ysnLoad, 0) 
	FROM	tblCTContractDetail CD 
	JOIN	tblCTContractHeader CH ON CH.intContractHeaderId = CD.intContractHeaderId
	WHERE	CD.intContractDetailId	= @intContractDetailId

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
				dblForexRate,
				intFreightTermId,
				intBookId,
				intSubBookId,
				intLoadReceive,
				dblUnitRetail,
				strTaxPoint,
				intTaxLocationId,
				intTaxGroupId
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
				dtmDate						=	GETDATE(),
				intShipViaId				=	CD.intShipViaId,
				dblQty						=	ISNULL(CD.dblBalance,0)		-	ISNULL(CD.dblScheduleQty,0),
				intGrossNetUOMId			=	ISNULL(CD.intNetWeightUOMId,0),	
				dblGross					=	dbo.fnCTConvertQtyToTargetItemUOM(CD.intItemUOMId,CD.intNetWeightUOMId,ISNULL(CD.dblBalance,0)-ISNULL(CD.dblScheduleQty,0)),
				dblNet						=	dbo.fnCTConvertQtyToTargetItemUOM(CD.intItemUOMId,CD.intNetWeightUOMId,ISNULL(CD.dblBalance,0)-ISNULL(CD.dblScheduleQty,0)),
				--CT-7100 (ECOM commented this line for ECOM) --dblCost						=	CASE	WHEN	CD.intPricingTypeId = 2 
				--CT-7100 (ECOM commented this line for ECOM) --										THEN	ISNULL(dbo.fnRKGetLatestClosingPrice(CD.intFutureMarketId,CD.intFutureMonthId,GETDATE()), 0) + 
				--CT-7100 (ECOM commented this line for ECOM) --												ISNULL(dbo.fnCTConvertQtyToTargetItemUOM(IU.intItemUOMId,CD.intBasisUOMId, CD.dblBasis),0)
				--CT-7100 (ECOM commented this line for ECOM) --										ELSE	ISNULL(dbo.fnCTConvertQtyToTargetItemUOM(IU.intItemUOMId,CD.intPriceItemUOMId, AD.dblSeqPrice),0)
				--CT-7100 (ECOM commented this line for ECOM) --								END,
				--CT-7100 (ECOM commented this line for ECOM) --intCostUOMId				=	IU.intItemUOMId, -- If Seq-price-uom is null, then use the contract-detail-item-uom. 
				dblCost						=	CASE	WHEN	CD.intPricingTypeId = 2 
														THEN	
															CASE WHEN ISNULL(AD.dblSeqPrice,0)   = 0 THEN 0 ELSE
															   ((ISNULL(dbo.fnRKGetLatestClosingPrice(CD.intFutureMarketId,CD.intFutureMonthId,GETDATE()), 0) +   
																ISNULL(CD.dblBasis,0))  / CASE WHEN ISNULL(CU.ysnSubCurrency, 0) = CAST(1 AS BIT)   THEN 100 ELSE 1 END) * ISNULL(CD.dblRate, 1 ) 
															END
														ELSE	ISNULL(AD.dblSeqPrice,0)
												END,
				intCostUOMId				=	CASE WHEN CD.intPricingTypeId = 2 OR ISNULL(CD.intCurrencyExchangeRateId, 0) = 0 THEN 
													CD.intBasisUOMId 
												ELSE
													CD.intFXPriceUOMId 
												END,
				intCurrencyId				=	ISNULL(SC.intMainCurrencyId, AD.intSeqCurrencyId),
				intSubCurrencyCents			=	ISNULL(SY.intCent, 1), 
				dblExchangeRate				=	1,
				intLotId					=	NULL ,
				intSubLocationId			=	CD.intSubLocationId,
				intStorageLocationId		=	CD.intStorageLocationId,
				ysnIsStorage				=	0,
				intSourceId					=	NULL,
				intSourceType		 		=	0,
				strSourceId					=	CH.strContractNumber,
				strSourceScreenName			=	'Contract',
				ysnSubCurrency				=	SY.ysnSubCurrency,
				intForexRateTypeId			=	CD.intRateTypeId,
				dblForexRate				=	NULL,
				intFreightTermId			=	CD.intFreightTermId,
				intBookId					=	CD.intBookId,
				intSubBookId				=	CD.intSubBookId,
				intLoadReceive				=	ISNULL(CD.dblBalanceLoad,0)		-	ISNULL(CD.dblScheduleLoad,0),
				dblUnitRetail				=	CD.dblCashPrice,
				strTaxPoint					=	CD.strTaxPoint,
				intTaxLocationId			=	CD.intTaxLocationId,
				intTaxGroupId				=	CD.intTaxGroupId

		FROM	tblCTContractDetail			CD	
		JOIN	tblCTContractHeader			CH	ON	CH.intContractHeaderId	=	CD.intContractHeaderId
		--CT-7100 (ECOM commented this line for ECOM) --JOIN tblICItemUOM IU ON IU.intItemId = CD.intItemId AND IU.ysnStockUnit = 1		

		CROSS	APPLY	dbo.fnCTGetAdditionalColumnForDetailView(CD.intContractDetailId) AD

		JOIN	tblEMEntityLocation			EL	ON	EL.intEntityId			=	CH.intEntityId	
												AND	EL.ysnDefaultLocation	=	1				
  LEFT	JOIN	vyuICGetItemStock			SK	ON	SK.intItemId			=	CD.intItemId			
												AND	SK.intLocationId		=	CD.intCompanyLocationId
  LEFT  JOIN	tblSMCurrency				SC	ON	SC.intCurrencyID		=	AD.intSeqCurrencyId
  LEFT  JOIN	tblSMCurrency				SY  ON	SY.intCurrencyID		=	CASE WHEN SC.intMainCurrencyId IS NOT NULL THEN  CD.intCurrencyId ELSE NULL END 
	LEFT JOIN tblSMCurrency CU ON CU.intCurrencyID = CD.intCurrencyId
	LEFT JOIN tblSMCurrency CY ON CY.intCurrencyID = CU.intMainCurrencyId
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
				[intCostCurrencyId],
				[ysnInventoryCost],
				[dblForexRate],
				[intForexRateTypeId]
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
				CY.intCurrencyID,
				CC.ysnInventoryCost,
				CC.dblFX,
				CC.intRateTypeId
								
		FROM	vyuCTContractCostView	CC
		JOIN	vyuCTContractDetailView	CD	ON	CD.intContractDetailId	=	CC.intContractDetailId
		JOIN	tblEMEntityLocation		EL	ON	EL.intEntityId			=	CD.intEntityId			AND
												EL.ysnDefaultLocation	=	1						LEFT
		JOIN	tblSMCurrency			CY  ON	CY.intCurrencyID		=	CC.intCurrencyId

		WHERE	CC.intContractDetailId	=	@intContractDetailId
		AND		ISNULL(CC.ysnBasis,0) <> 1

		

		IF ISNULL(@ysnRequireProducerQty, 0) = 1
		BEGIN
			INSERT INTO @ReceiptItemLotStagingTable
			(
				[strReceiptType]
				,[intItemId]
				,[intLotId]
				,[strLotNumber]
				,[intLocationId]
				,[intShipFromId]
				,[intShipViaId]	
				,[intSubLocationId]
				,[intStorageLocationId] 
				,[intCurrencyId]
				,[intItemUnitMeasureId]
				,[dblQuantity]
				,[dblGrossWeight]
				,[dblTareWeight]
				,[dblCost]
				,[intEntityVendorId]
				,[dtmManufacturedDate]
				,[dtmExpiryDate]
				,[strBillOfLadding]
				,[strCertificate]
				,[intProducerId]
				,[strCertificateId]
				,[strTrackingNumber]
				,[intSourceType]
				,[intContractHeaderId]
				,[intContractDetailId]
			)

			SELECT	 [strReceiptType]		=   'Purchase Contract'
					,[intItemId]			=   CD.intItemId
					,[intLotId]				=   NULL
					,[strLotNumber]			=   NULL
					,[intLocationId]		=   CD.intCompanyLocationId
					,[intShipFromId]		=   CASE	WHEN ISNULL((SELECT TOP 1 intShipFromId from tblAPVendor where intEntityId = CH.intEntityId), 0) > 0
														THEN (SELECT TOP 1 intShipFromId from tblAPVendor where intEntityId = CH.intEntityId)
														ELSE (SELECT TOP 1 intEntityLocationId from tblEMEntityLocation where intEntityId = CH.intEntityId AND ysnDefaultLocation = 1)
												END
					,[intShipViaId]			=   CD.intShipViaId
					,[intSubLocationId]		=   CD.intSubLocationId
					,[intStorageLocationId]	=   CD.intStorageLocationId
					,[intCurrencyId]		=   ISNULL(SC.intMainCurrencyId, AD.intSeqCurrencyId)
					,[intItemUnitMeasureId]	=   CD.intItemUOMId
					,[dblQuantity]			=   CC.dblQuantity
					,[dblGrossWeight]		=   dbo.fnCTConvertQtyToTargetItemUOM(CD.intItemUOMId,CD.intNetWeightUOMId,CC.dblQuantity)
					,[dblTareWeight]		=   0
					,[dblCost]				=   CASE	WHEN	CD.intPricingTypeId = 2 
														THEN	(
																	SELECT ISNULL(dbo.fnCTConvertQtyToTargetItemUOM(CD.intItemUOMId,futureUOM.intItemUOMId,dblSettlementPrice + ISNULL(dbo.fnCTConvertQtyToTargetItemUOM(futureUOM.intItemUOMId,CD.intBasisUOMId,CD.dblBasis),0)),0) 
																	FROM dbo.fnRKGetFutureAndBasisPrice (1,CH.intCommodityId,right(convert(varchar, CD.dtmEndDate, 106),8),2,CD.intFutureMarketId,CD.intFutureMonthId,NULL,NULL,0 ,CD.intItemId,AD.intSeqCurrencyId)
																	LEFT JOIN tblICItemUOM futureUOM ON futureUOM.intUnitMeasureId = intSettlementUOMId AND futureUOM.intItemId = CD.intItemId
																)
														ELSE	AD.dblSeqPrice
												END
					,[intEntityVendorId]	=   CH.intEntityId
					,[dtmManufacturedDate]	=   GETDATE()
					,[dtmExpiryDate]		=   dbo.fnICCalculateExpiryDate(CD.intItemId, NULL , GETDATE())
					,[strBillOfLadding]		=   ''
					,[strCertificate]		=   CF.strCertificationName
					,[intProducerId]		=   CC.intProducerId
					,[strCertificateId]		=   CC.strCertificationId
					,[strTrackingNumber]	=   CC.strTrackingNumber
					,[intSourceType]		=   0
					,[intContractHeaderId]	=   CD.intContractHeaderId
					,[intContractDetailId]	=   CD.intContractDetailId

			FROM	tblCTContractDetail			CD 
			JOIN	tblCTContractHeader			CH  ON  CH.intContractHeaderId	=	CD.intContractHeaderId
													AND	CD.intContractDetailId	=	@intContractDetailId
	 CROSS APPLY	dbo.fnCTGetAdditionalColumnForDetailView(CD.intContractDetailId)AD
		   
		   JOIN		tblICItem					IC  ON  IC.intItemId			=	CD.intItemId
		   JOIN		tblCTContractCertification  CC  ON  CC.intContractDetailId	=	CD.intContractDetailId
		   JOIN		tblICCertification		    CF  ON  CF.intCertificationId	=	CC.intCertificationId
	 LEFT  JOIN		tblSMCurrency				SC	ON	SC.intCurrencyID		=	AD.intSeqCurrencyId

		END

		IF NOT EXISTS(SELECT * FROM  @ReceiptStagingTable)
		BEGIN
			RAISERROR('Please verify the stock unit for the item or default location is available for the entity.',16,1)
		END

		IF EXISTS(SELECT TOP 1 1 FROM tblCTContractDetail WHERE intContractDetailId = @intContractDetailId AND strFinanceTradeNo IS NOT NULL )
		BEGIN
			INSERT INTO @ReceiptTradeFinance
			(
				[strReceiptType]
				,[intEntityVendorId]
				,[intCurrencyId]
				,[intLocationId]
				,[intShipFromId]
				,[intShipViaId]
				,[intShipFromEntityId]
				,[strTradeFinanceNumber]
				,[intBankId]
				,[intBankAccountId]
				,[intBorrowingFacilityId]
				,[strBankReferenceNo]
				,[intLimitTypeId]
				,[intSublimitTypeId]
				,[ysnSubmittedToBank]
				,[dtmDateSubmitted]
				,[strApprovalStatus]
				,[dtmDateApproved]
				,[strWarrantNo]
				,[intWarrantStatus]
				,[strReferenceNo]
				,[intOverrideFacilityValuation]
				,[strComments]
			)
			SELECT	 [strReceiptType]				=   'Purchase Contract'
					,[intEntityVendorId]			=   CH.intEntityId
					,[intCurrencyId]				=   ISNULL(SC.intMainCurrencyId, AD.intSeqCurrencyId)
					,[intLocationId]				= CD.intCompanyLocationId
					,[intShipFromId]				=   CASE	WHEN ISNULL((SELECT TOP 1 intShipFromId from tblAPVendor where intEntityId = CH.intEntityId), 0) > 0
														THEN (SELECT TOP 1 intShipFromId from tblAPVendor where intEntityId = CH.intEntityId)
														ELSE (SELECT TOP 1 intEntityLocationId from tblEMEntityLocation where intEntityId = CH.intEntityId AND ysnDefaultLocation = 1)
														END
					,[intShipViaId]					=   CD.intShipViaId
					,[intShipFromEntityId]			=   CH.intEntityId
					,[strTradeFinanceNumber]		=	CD.strFinanceTradeNo
					,[intBankId]					=	CD.intBankId
					,[intBankAccountId]				=	CD.intBankAccountId
					,[intBorrowingFacilityId]		=	CD.intBorrowingFacilityId
					,[strBankReferenceNo]			=	CD.strBankReferenceNo
					,[intLimitTypeId]				=	CD.intBorrowingFacilityLimitId
					,[intSublimitTypeId]			=	CD.intBorrowingFacilityLimitDetailId
					,[ysnSubmittedToBank]			=	CD.ysnSubmittedToBank
					,[dtmDateSubmitted]				=	CD.dtmDateSubmitted
					,[strApprovalStatus]			=	ASTF.strApprovalStatus
					,[dtmDateApproved]				=	CD.dtmDateApproved
					,[strWarrantNo]					=	null
					,[intWarrantStatus]				=	null
					,[strReferenceNo]				=	CD.strReferenceNo
					,[intOverrideFacilityValuation]	=	CD.intBankValuationRuleId
					,[strComments]					=	CD.strComments
			FROM tblCTContractDetail CD
			JOIN	tblCTContractHeader			CH  ON  CH.intContractHeaderId	=	CD.intContractHeaderId
			LEFT JOIN tblCTApprovalStatusTF ASTF on ASTF.intApprovalStatusId = CD.intApprovalStatusId
			CROSS APPLY	dbo.fnCTGetAdditionalColumnForDetailView(CD.intContractDetailId)AD
			LEFT  JOIN		tblSMCurrency				SC	ON	SC.intCurrencyID		=	AD.intSeqCurrencyId
			where CD.intContractDetailId = @intContractDetailId
			
			
		END
	
		EXEC dbo.uspICAddItemReceipt @ReceiptStagingTable,@OtherCharges,@intUserId, @ReceiptItemLotStagingTable, @ReceiptTradeFinance;
		
		IF EXISTS(SELECT * FROM #tmpAddItemReceiptResult)
		BEGIN
			SELECT TOP 1 @intInventoryReceiptId = intInventoryReceiptId FROM  #tmpAddItemReceiptResult	

			DECLARE @intInventoryReceiptItemId	INT = NULL,
					@dblQty						NUMERIC(38,20) = 0

			SELECT	@intInventoryReceiptItemId = MIN(intInventoryReceiptItemId) 
			FROM	tblICInventoryReceiptItem
			WHERE	intInventoryReceiptId = @intInventoryReceiptId

			WHILE ISNULL(@intInventoryReceiptItemId,0) > 0
			BEGIN
				SELECT	@dblQty						=	CASE WHEN @ysnLoad = 1 THEN intLoadReceive ELSE dblOpenReceive END
				FROM	tblICInventoryReceiptItem 
				WHERE	intInventoryReceiptItemId	=	 @intInventoryReceiptItemId
									
				EXEC	uspCTUpdateScheduleQuantity
						@intContractDetailId	=	@intContractDetailId,
						@dblQuantityToUpdate	=	@dblQty,
						@intUserId				=	@intUserId,
						@intExternalId			=	@intInventoryReceiptItemId,
						@strScreenName			=	'Inventory Receipt'

				update
					tblCTContractDetail
					set
						dblScheduleLoad = (CASE WHEN @ysnLoad = 1 THEN @dblQty ELSE 0.00 END)
						,dblScheduleQty = (CASE WHEN @ysnLoad = 0 THEN @dblQty ELSE 0.00 END)
				where
					intContractDetailId = @intContractDetailId;

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