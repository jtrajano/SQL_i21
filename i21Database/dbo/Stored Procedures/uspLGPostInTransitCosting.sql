CREATE PROCEDURE uspLGPostInTransitCosting 
	 @intLoadId INT
	,@ysnPost BIT
	,@intPurchaseSale INT
	,@intEntityUserSecurityId INT
AS
BEGIN TRY
	DECLARE @strErrMsg NVARCHAR(MAX)
	DECLARE @strLoadNumber NVARCHAR(100)
	DECLARE @ItemsToPost ItemInTransitCostingTableType
	DECLARE @GLEntries AS RecapTableType
	DECLARE @intReturnValue INT
	DECLARE @STARTING_NUMBER_BATCH INT = 3
	DECLARE @strBatchId NVARCHAR(20)
	DECLARE @strBatchIdUsed NVARCHAR(20)
	DECLARE @intFOBPointId INT
	DECLARE @INBOUND_SHIPMENT_TYPE AS INT = 22
	DECLARE @DefaultCurrencyId AS INT = dbo.fnSMGetDefaultCurrency('FUNCTIONAL')
	DECLARE @intDestinationFOBPointId INT
	DECLARE @ysnIsReturn BIT = 0
	DECLARE @strCMActualCostId NVARCHAR(100)

	SELECT @strBatchIdUsed = strBatchId
		,@strLoadNumber = strLoadNumber
	FROM dbo.tblLGLoad L
	LEFT JOIN tblSMFreightTerms FT ON FT.intFreightTermId = L.intFreightTermId
	LEFT JOIN tblICFobPoint FP ON FP.strFobPoint = FP.strFobPoint
	WHERE intLoadId = @intLoadId

	SELECT TOP 1 @ysnIsReturn = 1, @strCMActualCostId = I.strInvoiceNumber
	FROM tblLGLoad L 
		JOIN tblARInvoice CM ON L.intLoadId = CM.intLoadId
		JOIN tblARInvoice I ON I.intInvoiceId = CM.intOriginalInvoiceId
	WHERE L.intLoadId = @intLoadId
		AND CM.strTransactionType = 'Credit Memo'
		AND CM.ysnPosted = 1

	SELECT @intDestinationFOBPointId = intFobPointId
	FROM tblICFobPoint
	WHERE strFobPoint = 'Destination'

	EXEC dbo.uspSMGetStartingNumber 3
		,@strBatchId OUT

	SET @strBatchIdUsed = @strBatchId

	IF (ISNULL(@ysnPost, 0) = 1)
	BEGIN

		IF (@intPurchaseSale = 3) 
		BEGIN
			IF (EXISTS (SELECT 1 FROM tblLGLoadDetail LD 
					INNER JOIN tblLGLoad L ON LD.intLoadId = L.intLoadId
					INNER JOIN tblCTContractDetail CD ON CD.intContractDetailId IN (LD.intPContractDetailId, LD.intSContractDetailId)
					INNER JOIN tblCTContractHeader CH ON CH.intContractHeaderId = CD.intContractHeaderId
					WHERE L.intLoadId = @intLoadId AND CH.intPricingTypeId = 2 AND CD.intPricingStatus = 1))
				RAISERROR('One or more contracts is not yet priced. Please price the contracts to proceed.', 16, 1);
		END
		ELSE
		BEGIN 
			/* Update LS Unit Cost for Unpriced Contracts */
			UPDATE LD 
			SET dblUnitPrice = dbo.fnCTGetSequencePrice(CD.intContractDetailId,NULL)
				,dblAmount = dbo.fnCalculateCostBetweenUOM(
									LD.intPriceUOMId
									, ISNULL(LD.intWeightItemUOMId, LD.intItemUOMId) 
									,(dbo.fnCTGetSequencePrice(CD.intContractDetailId,NULL) / CASE WHEN (CUR.ysnSubCurrency = 1) THEN CUR.intCent ELSE 1 END)
								) * CASE WHEN (LD.intWeightItemUOMId IS NOT NULL) THEN LD.dblNet ELSE LD.dblQuantity END		
			FROM tblLGLoadDetail LD
				JOIN tblCTContractDetail CD ON CD.intContractDetailId = LD.intPContractDetailId
				JOIN tblCTContractHeader CH ON CH.intContractHeaderId = CD.intContractHeaderId
				JOIN vyuLGAdditionalColumnForContractDetailView AD ON CD.intContractDetailId = AD.intContractDetailId
				LEFT JOIN tblSMCurrency CUR ON CUR.intCurrencyID = LD.intPriceCurrencyId
			WHERE ISNULL(LD.dblUnitPrice, 0) = 0 AND LD.intLoadId = @intLoadId

			IF EXISTS(SELECT TOP 1 1 FROM tblLGLoadDetail LD
				INNER JOIN tblLGLoad L ON LD.intLoadId = L.intLoadId
				WHERE L.intPurchaseSale <> 3 AND LD.intLoadId = @intLoadId AND ISNULL(LD.dblUnitPrice, 0) = 0)
			BEGIN
				RAISERROR('One or more contracts is not yet priced. Please price the contracts or provide a provisional price to proceed.', 16, 1);
			END
		END

		INSERT INTO @ItemsToPost (
			intItemId
			,intItemLocationId
			,intItemUOMId
			,dtmDate
			,dblQty
			,dblUOMQty
			,dblCost
			,dblValue
			,dblSalesPrice
			,intCurrencyId
			,dblExchangeRate
			,intTransactionId
			,intTransactionDetailId
			,strTransactionId
			,intTransactionTypeId
			,intLotId
			,intSourceTransactionId
			,strSourceTransactionId
			,intSourceTransactionDetailId
			,intFobPointId
			,intInTransitSourceLocationId
			,intForexRateTypeId
			,dblForexRate
			)
		SELECT 
			intItemId = LD.intItemId
			,intItemLocationId = IL.intItemLocationId
			,intItemUOMId = ISNULL(LD.intWeightItemUOMId, LD.intItemUOMId) 
			,dtmDate = GETDATE()
			,dblQty = 
				CASE 
					WHEN LD.intWeightItemUOMId IS NOT NULL THEN 
						LD.dblNet
					ELSE 
						LD.dblQuantity
				END
			,dblUOMQty = IU.dblUnitQty
			,dblCost = dbo.fnMultiply(
								dbo.fnCalculateCostBetweenUOM(
									AD.intSeqPriceUOMId
									, ISNULL(LD.intWeightItemUOMId, LD.intItemUOMId) 
									, CASE 
										WHEN (AD.dblSeqPrice IS NULL) THEN
											CASE 
												WHEN (LD.dblUnitPrice > 0) THEN 
													LD.dblUnitPrice 
													/ CASE WHEN (LSC.ysnSubCurrency = 1) THEN LSC.intCent ELSE 1 END
												ELSE 
													dbo.fnCTGetSequencePrice(CD.intContractDetailId,NULL) 
													/ CASE WHEN (AD.ysnSeqSubCurrency = 1) THEN 100 ELSE 1 END
											END
										ELSE 
											AD.dblSeqPrice 
											/ CASE WHEN (AD.ysnSeqSubCurrency = 1) THEN 100 ELSE 1 END
										END) 
								, CASE --if contract FX tab is setup
									 WHEN AD.ysnValidFX = 1 THEN 
										CASE WHEN (ISNULL(SC.intMainCurrencyId, SC.intCurrencyID) <> @DefaultCurrencyId AND CD.intInvoiceCurrencyId <> @DefaultCurrencyId)
												THEN ISNULL(FX.dblFXRate, 1) --foreign price to foreign FX, use master FX rate
											ELSE 1 END
									 ELSE  --if contract FX tab is not setup
										CASE WHEN (@DefaultCurrencyId <> ISNULL(SC.intMainCurrencyId, SC.intCurrencyID)) 
											THEN ISNULL(FX.dblFXRate, 1)
											ELSE 1 END
									 END
								) 
							
			,dblValue = 0
			,dblSalesPrice = 0.0
			,intCurrencyId = CASE WHEN AD.ysnValidFX = 1 THEN CD.intInvoiceCurrencyId ELSE ISNULL(SC.intMainCurrencyId, SC.intCurrencyID) END
			,dblExchangeRate = ISNULL(AD.dblNetWtToPriceUOMConvFactor,0)
			,intTransactionId = L.intLoadId
			,intTransactionDetailId = LD.intLoadDetailId
			,strTransactionId = L.strLoadNumber
			,intTransactionTypeId = @INBOUND_SHIPMENT_TYPE
			,intLotId = NULL
			,intSourceTransactionId = L.intLoadId
			,strSourceTransactionId = L.strLoadNumber
			,intSourceTransactionDetailId = LD.intLoadDetailId
			,intFobPointId = CASE WHEN L.intPurchaseSale = 3 THEN @intDestinationFOBPointId ELSE FP.intFobPointId END
			,intInTransitSourceLocationId = IL.intItemLocationId
			,intForexRateTypeId = CASE --if contract FX tab is setup
									 WHEN AD.ysnValidFX = 1 THEN 
										CASE WHEN (ISNULL(SC.intMainCurrencyId, SC.intCurrencyID) = @DefaultCurrencyId AND CD.intInvoiceCurrencyId <> @DefaultCurrencyId) 
												THEN CD.intRateTypeId --functional price to foreign FX, use inverted contract FX rate
											WHEN (ISNULL(SC.intMainCurrencyId, SC.intCurrencyID) <> @DefaultCurrencyId AND CD.intInvoiceCurrencyId = @DefaultCurrencyId)
												THEN NULL --foreign price to functional FX, use NULL
											WHEN (ISNULL(SC.intMainCurrencyId, SC.intCurrencyID) <> @DefaultCurrencyId AND CD.intInvoiceCurrencyId <> @DefaultCurrencyId)
												THEN FX.intForexRateTypeId --foreign price to foreign FX, use master FX rate
											ELSE LD.intForexRateTypeId END
									 ELSE  --if contract FX tab is not setup
										CASE WHEN (@DefaultCurrencyId <> ISNULL(SC.intMainCurrencyId, SC.intCurrencyID)) 
											THEN FX.intForexRateTypeId
											ELSE LD.intForexRateTypeId END
									 END
			,dblForexRate = CASE --if contract FX tab is setup
									 WHEN AD.ysnValidFX = 1 THEN 
										CASE WHEN (ISNULL(SC.intMainCurrencyId, SC.intCurrencyID) = @DefaultCurrencyId AND CD.intInvoiceCurrencyId <> @DefaultCurrencyId) 
												THEN dbo.fnDivide(1, ISNULL(CD.dblRate, 1)) --functional price to foreign FX, use inverted contract FX rate
											WHEN (ISNULL(SC.intMainCurrencyId, SC.intCurrencyID) <> @DefaultCurrencyId AND CD.intInvoiceCurrencyId = @DefaultCurrencyId)
												THEN 1 --foreign price to functional FX, use 1
											WHEN (ISNULL(SC.intMainCurrencyId, SC.intCurrencyID) <> @DefaultCurrencyId AND CD.intInvoiceCurrencyId <> @DefaultCurrencyId)
												THEN ISNULL(FX.dblFXRate, 1) --foreign price to foreign FX, use master FX rate
											ELSE ISNULL(LD.dblForexRate,1) END
									 ELSE  --if contract FX tab is not setup
										CASE WHEN (@DefaultCurrencyId <> ISNULL(SC.intMainCurrencyId, SC.intCurrencyID)) 
											THEN ISNULL(FX.dblFXRate, 1)
											ELSE ISNULL(LD.dblForexRate,1) END
									 END
		FROM tblLGLoad L
			JOIN tblLGLoadDetail LD ON L.intLoadId = LD.intLoadId
			JOIN tblICItemLocation IL ON IL.intItemId = LD.intItemId AND LD.intPCompanyLocationId = IL.intLocationId
			JOIN tblICItemUOM IU ON IU.intItemUOMId = ISNULL(LD.intWeightItemUOMId, LD.intItemUOMId) 
			JOIN tblCTContractDetail CD ON CD.intContractDetailId = LD.intPContractDetailId
			JOIN tblCTContractHeader CH ON CH.intContractHeaderId = CD.intContractHeaderId
			JOIN vyuLGAdditionalColumnForContractDetailView AD ON AD.intContractDetailId = CD.intContractDetailId
			LEFT JOIN tblICItemUOM WU ON WU.intItemUOMId = LD.intWeightItemUOMId
			LEFT JOIN tblSMFreightTerms FT ON FT.intFreightTermId = L.intFreightTermId
			LEFT JOIN tblICFobPoint FP ON FP.strFobPoint = FT.strFobPoint
			LEFT JOIN tblSMCurrency LSC ON LSC.intCurrencyID = LD.intPriceCurrencyId
			LEFT JOIN tblSMCurrency SC ON SC.intCurrencyID = CD.intCurrencyId
			OUTER APPLY (SELECT	TOP 1  
						intForexRateTypeId = RD.intRateTypeId
						,dblFXRate = CASE WHEN ER.intFromCurrencyId = @DefaultCurrencyId  
									THEN 1/RD.[dblRate] 
									ELSE RD.[dblRate] END 
						FROM tblSMCurrencyExchangeRate ER JOIN tblSMCurrencyExchangeRateDetail RD ON RD.intCurrencyExchangeRateId = ER.intCurrencyExchangeRateId
						WHERE @DefaultCurrencyId <> ISNULL(SC.intMainCurrencyId, SC.intCurrencyID)
							AND ((ER.intFromCurrencyId = ISNULL(SC.intMainCurrencyId, SC.intCurrencyID) AND ER.intToCurrencyId = @DefaultCurrencyId) 
								OR (ER.intFromCurrencyId = @DefaultCurrencyId AND ER.intToCurrencyId = ISNULL(SC.intMainCurrencyId, SC.intCurrencyID)))
						ORDER BY RD.dtmValidFromDate DESC) FX
		WHERE L.intLoadId = @intLoadId

		BEGIN
			INSERT INTO @GLEntries (
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
				,[intSourceEntityId]
				,[intCommodityId]
				)
			EXEC @intReturnValue = dbo.uspICPostInTransitCosting @ItemsToPost = @ItemsToPost
				,@strBatchId = @strBatchIdUsed
				,@strAccountToCounterInventory = 'AP Clearing'
				,@intEntityUserSecurityId = @intEntityUserSecurityId

			UPDATE @GLEntries
			SET strCode = 'LG', strModuleName = 'Logistics'

			UPDATE tblLGLoad
			SET strBatchId = @strBatchIdUsed
			WHERE intLoadId = @intLoadId

			IF @intReturnValue < 0
			BEGIN
				RAISERROR (@strErrMsg,16,1)
			END

			EXEC dbo.uspGLBookEntries @GLEntries, @ysnPost
		END
	END
	ELSE
	BEGIN
		INSERT INTO @GLEntries (
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
				,[intSourceEntityId]
				,[intCommodityId]
		)
		EXEC	@intReturnValue = dbo.uspICUnpostCosting
				@intLoadId
				,@strLoadNumber
				,@strBatchIdUsed
				,@intEntityUserSecurityId	
				,0

		IF @intReturnValue < 0
		BEGIN
			RAISERROR (@strErrMsg,16,1)
		END

		EXEC dbo.uspGLBookEntries @GLEntries
			,@ysnPost
	END

--Update Contract Balance and Scheduled Qty for Drop Ship
IF (@intPurchaseSale = 3)
BEGIN 
	DECLARE @ItemsFromInventoryReceipt AS dbo.ReceiptItemTableType
	INSERT INTO @ItemsFromInventoryReceipt (
		-- Header
		[intInventoryReceiptId] 
		,[strInventoryReceiptId] 
		,[strReceiptType] 
		,[intSourceType] 
		,[dtmDate] 
		,[intCurrencyId] 
		,[dblExchangeRate] 
		-- Detail 
		,[intInventoryReceiptDetailId] 
		,[intItemId] 
		,[intLocationId] 
		,[intItemLocationId] 
		,[intSubLocationId] 
		,[intStorageLocationId] 
		,[intItemUOMId] 
		,[intWeightUOMId] 
		,[dblQty] 
		,[dblUOMQty] 
		,[dblCost] 
		,[intLineNo] 
		,[ysnLoad]
		,[intLoadReceive]
	)
	SELECT 
		-- Header
		[intInventoryReceiptId] = L.intLoadId
		,[strInventoryReceiptId]  = L.strLoadNumber
		,[strReceiptType] = 'Purchase Contract'
		,[intSourceType] = -1
		,[dtmDate] = GETDATE()
		,[intCurrencyId] = NULL
		,[dblExchangeRate] = 1
		-- Detail 
		,[intInventoryReceiptDetailId] = LD.intLoadDetailId
		,[intItemId] = LD.intItemId
		,[intLocationId] = LD.intPCompanyLocationId
		,[intItemLocationId] = (SELECT TOP 1 ITL.intItemLocationId
									FROM tblICItemLocation ITL
									WHERE ITL.intItemId = LD.intItemId
										AND ITL.intLocationId = CD.intCompanyLocationId)
		,[intSubLocationId] = LD.intSSubLocationId
		,[intStorageLocationId] = NULL
		,[intItemUOMId] = LD.intItemUOMId
		,[intWeightUOMId] = LD.intWeightItemUOMId
		,[dblQty] = CASE 
					WHEN @ysnPost = 1
						THEN LD.dblQuantity
					ELSE -1 * LD.dblQuantity
					END
		,[dblUOMQty] = IU.dblUnitQty
		,[dblCost] = CD.dblCashPrice
		,[intLineNo] = ISNULL(LD.intPContractDetailId, 0)
		,[ysnLoad] = CH.ysnLoad
		,[intLoadReceive] = CASE WHEN CH.ysnLoad = 1 THEN 
								CASE WHEN @ysnPost = 1 THEN -1 ELSE 1 END
							ELSE NULL END
	FROM tblLGLoad L
		JOIN tblLGLoadDetail LD ON L.intLoadId = LD.intLoadId
		JOIN tblCTContractDetail CD ON CD.intContractDetailId = LD.intPContractDetailId
		JOIN tblCTContractHeader CH ON CD.intContractHeaderId = CH.intContractHeaderId
		JOIN tblICItemUOM IU ON IU.intItemUOMId = LD.intItemUOMId
		LEFT JOIN tblICItemUOM WU ON WU.intItemUOMId = LD.intWeightItemUOMId
	WHERE L.intLoadId = @intLoadId

	EXEC dbo.uspCTReceived @ItemsFromInventoryReceipt
		,@intEntityUserSecurityId
		,@ysnPost
END


END TRY

BEGIN CATCH
	SET @strErrMsg = ERROR_MESSAGE()

	RAISERROR (@strErrMsg,16,1,'WITH NOWAIT')
END CATCH