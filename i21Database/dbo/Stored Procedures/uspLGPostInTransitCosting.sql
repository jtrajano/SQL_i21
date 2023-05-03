CREATE PROCEDURE uspLGPostInTransitCosting 
	 @intLoadId INT
	,@ysnPost BIT
	,@intPurchaseSale INT
	,@intEntityUserSecurityId INT
	,@ysnRecap BIT = 0
	,@strBatchId NVARCHAR(40) = NULL OUTPUT
AS
SET ANSI_WARNINGS ON

--BEGIN TRY
	DECLARE @strErrMsg NVARCHAR(MAX)
	DECLARE @strLoadNumber NVARCHAR(100)
	DECLARE @ItemsToPost ItemInTransitCostingTableType
	DECLARE @GLEntries AS RecapTableType
	DECLARE @APClearing AS APClearing
	DECLARE @intReturnValue INT
	DECLARE @STARTING_NUMBER_BATCH INT = 3
	DECLARE @strBatchIdUsed NVARCHAR(40)
	DECLARE @intFOBPointId INT
	DECLARE @INBOUND_SHIPMENT_TYPE AS INT = 22
	DECLARE @DefaultCurrencyId AS INT = dbo.fnSMGetDefaultCurrency('FUNCTIONAL')
	DECLARE @intDestinationFOBPointId INT
	DECLARE @ysnIsReturn BIT = 0
	DECLARE @strCMActualCostId NVARCHAR(100)
	DECLARE @ValueToPost AS ItemInTransitValueOnlyTableType
	DECLARE @ItemsForInTransitCosting AS ItemInTransitCostingTableType
	DECLARE @strTransactionId AS NVARCHAR(50)
	DECLARE @strGLDescription AS NVARCHAR(500) = NULL
	DECLARE @intInvoiceCurrency AS INT

	SELECT @strBatchIdUsed = strBatchId
		,@strLoadNumber = strLoadNumber
		,@strTransactionId = strLoadNumber
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

	SELECT @intInvoiceCurrency =
		CASE WHEN AD.ysnValidFX = 1
			THEN CD.intInvoiceCurrencyId
			ELSE ISNULL(SC.intMainCurrencyId, SC.intCurrencyID)
		END
	FROM tblLGLoad L
	JOIN tblLGLoadDetail LD ON L.intLoadId = LD.intLoadId
	JOIN tblCTContractDetail CD ON CD.intContractDetailId = LD.intPContractDetailId
	JOIN vyuLGAdditionalColumnForContractDetailView AD ON AD.intContractDetailId = CD.intContractDetailId
	LEFT JOIN tblSMCurrency SC ON SC.intCurrencyID = CD.intCurrencyId
	WHERE L.intLoadId = @intLoadId


	IF (ISNULL(@ysnPost, 0) = 1)
	BEGIN

		IF (@intPurchaseSale = 3) 
		BEGIN
			IF (EXISTS (SELECT 1 FROM (
					SELECT dblUnitPrice = dbo.fnCTGetSequencePrice(CD.intContractDetailId,NULL)
					FROM tblLGLoadDetail LD
					JOIN tblCTContractDetail CD ON CD.intContractDetailId IN (LD.intPContractDetailId, LD.intSContractDetailId)
					WHERE LD.intLoadId = @intLoadId) p WHERE p.dblUnitPrice IS NULL))
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
	END

	/* Auto-correct Weight UOMs */
	UPDATE LD
	SET intWeightItemUOMId = WUOM.intItemUOMId
	FROM tblLGLoadDetail LD
		INNER JOIN tblLGLoad L ON L.intLoadId = LD.intLoadId
		LEFT JOIN tblICItemUOM IUOM ON IUOM.intItemUOMId = LD.intItemUOMId
		LEFT JOIN tblICItemUOM WUOM ON WUOM.intItemId = LD.intItemId AND WUOM.intUnitMeasureId = ISNULL(L.intWeightUnitMeasureId, IUOM.intUnitMeasureId)
	WHERE L.intLoadId = @intLoadId AND ISNULL(intWeightItemUOMId, 0) <> WUOM.intItemUOMId

	/* Auto-correct Cost UOMs */
	UPDATE LD
	SET intPriceUOMId = CPUOM.intItemUOMId
	FROM tblLGLoadDetail LD
		INNER JOIN tblLGLoad L ON L.intLoadId = LD.intLoadId
		LEFT JOIN tblICItemUOM PUOM ON PUOM.intItemUOMId = LD.intPriceUOMId
		LEFT JOIN tblICItemUOM CPUOM ON CPUOM.intItemId = LD.intItemId AND CPUOM.intUnitMeasureId = PUOM.intUnitMeasureId
	WHERE L.intLoadId = @intLoadId AND ISNULL(LD.intPriceUOMId, 0) <> CPUOM.intItemUOMId

	/* Build In-Transit Costing parameter */
		
	-- Create a unique transaction name. 
	DECLARE @TransactionName AS VARCHAR(500) = 'Inbound Shipment Transaction' + CAST(NEWID() AS NVARCHAR(100));

	--------------------------------------------------------------------------------------------  
	-- Begin a transaction and immediately create a save point 
	--------------------------------------------------------------------------------------------  
	BEGIN TRAN @TransactionName

	SAVE TRAN @TransactionName

	EXEC dbo.uspSMGetStartingNumber 3, @strBatchId OUT
	SET @strBatchIdUsed = @strBatchId

	IF (ISNULL(@ysnPost, 0) = 1)
	BEGIN
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
			,intSourceEntityId
			,strBOLNumber
			)
		SELECT 
			intItemId = LD.intItemId
			,intItemLocationId = IL.intItemLocationId
			,intItemUOMId = ISNULL(LD.intWeightItemUOMId, LD.intItemUOMId) 
			,dtmDate = L.dtmScheduledDate
			,dblQty = LD.dblQuantity
			,dblUOMQty = IU.dblUnitQty
			--,dblCost = 
			--	dbo.fnDivide (
			--		dbo.fnMultiply (
			--			LD.dblNet,
			--			dbo.fnMultiply (
			--				dbo.fnCalculateCostBetweenUOM (
			--					AD.intSeqPriceUOMId
			--					,ISNULL(LD.intWeightItemUOMId, LD.intItemUOMId) 
			--					,CASE 
			--						WHEN (AD.dblSeqPrice IS NULL) THEN
			--							CASE 
			--								WHEN (LD.dblUnitPrice > 0) THEN 
			--									LD.dblUnitPrice 
			--									/ CASE WHEN (LSC.ysnSubCurrency = 1) THEN LSC.intCent ELSE 1 END
			--								ELSE 
			--									dbo.fnCTGetSequencePrice(CD.intContractDetailId,NULL) 
			--									/ CASE WHEN (AD.ysnSeqSubCurrency = 1) THEN 100 ELSE 1 END
			--							END
			--						ELSE 
			--							AD.dblSeqPrice 
			--							/ CASE WHEN (AD.ysnSeqSubCurrency = 1) THEN 100 ELSE 1 END
			--					END
			--				) 
			--				,CASE --if contract FX tab is setup
			--					WHEN AD.ysnValidFX = 1 THEN 
			--						CASE 
			--							WHEN (ISNULL(SC.intMainCurrencyId, SC.intCurrencyID) = @DefaultCurrencyId AND CD.intInvoiceCurrencyId <> @DefaultCurrencyId) THEN 
			--								dbo.fnDivide(1, ISNULL(CD.dblRate, 1)) --functional price to foreign FX, use inverted contract FX rate
			--							WHEN (ISNULL(SC.intMainCurrencyId, SC.intCurrencyID) <> @DefaultCurrencyId AND CD.intInvoiceCurrencyId = @DefaultCurrencyId) THEN 
			--								1 --foreign price to functional FX, use 1
			--							WHEN (ISNULL(SC.intMainCurrencyId, SC.intCurrencyID) <> @DefaultCurrencyId AND CD.intInvoiceCurrencyId <> @DefaultCurrencyId) THEN 
			--								ISNULL(FX.dblFXRate, 1) --foreign price to foreign FX, use master FX rate
			--							ELSE 
			--								ISNULL(LD.dblForexRate,1) 
			--						END
			--					ELSE  --if contract FX tab is not setup
			--						CASE 
			--							WHEN (@DefaultCurrencyId <> ISNULL(SC.intMainCurrencyId, SC.intCurrencyID)) THEN 
			--								ISNULL(FX.dblFXRate, 1)
			--							ELSE 1 
			--						END
			--				END
			--			)
			--		)
			--		, LD.dblQuantity
			--	)

			-- Cost is in foreign currency. 
			,dblCost = 
				dbo.fnDivide (
					dbo.fnMultiply (
						LD.dblNet
						,dbo.fnCalculateCostBetweenUOM (
							AD.intSeqPriceUOMId
							,ISNULL(LD.intWeightItemUOMId, LD.intItemUOMId) 
							,CASE 
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
							END
						) 
					)
					, LD.dblQuantity
				)
			,dblValue = 0
			,dblSalesPrice = 0.0
			,intCurrencyId = @intInvoiceCurrency
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
			,dblForexRate = ISNULL(LD.dblPFunctionalFxRate, dbo.fnLGGetForexRateFromContract(CD.intContractDetailId))
			,ISNULL(LD.intVendorEntityId, LD.intCustomerEntityId) 
			,L.strLoadNumber
		FROM tblLGLoad L
			JOIN tblLGLoadDetail LD ON L.intLoadId = LD.intLoadId
			JOIN tblICItemLocation IL ON IL.intItemId = LD.intItemId AND LD.intPCompanyLocationId = IL.intLocationId
			JOIN tblICItemUOM IU ON IU.intItemUOMId = LD.intItemUOMId
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
						WHERE @DefaultCurrencyId <> CD.intInvoiceCurrencyId
							AND (ER.intFromCurrencyId = CD.intInvoiceCurrencyId AND ER.intToCurrencyId = @DefaultCurrencyId)
							AND RD.dtmValidFromDate <= L.dtmScheduledDate
						ORDER BY RD.dtmValidFromDate DESC) FX
		WHERE L.intLoadId = @intLoadId

		
		-- Update currency fields to functional currency. 
		BEGIN 
			UPDATE	itemCost
			SET		dblExchangeRate = 1
					,dblForexRate = 1
					,intCurrencyId = @DefaultCurrencyId
			FROM	@ItemsToPost itemCost
			WHERE	ISNULL(itemCost.intCurrencyId, @DefaultCurrencyId) = @DefaultCurrencyId 

			UPDATE	itemCost
			SET		dblCost = dbo.fnMultiply(dblCost, ISNULL(dblForexRate, 1)) 
					,dblSalesPrice = dbo.fnMultiply(dblSalesPrice, ISNULL(dblForexRate, 1)) 
					,dblValue = dbo.fnMultiply(dblValue, ISNULL(dblForexRate, 1)) 
					,dblForexCost = dblCost
			FROM	@ItemsToPost itemCost
			WHERE	itemCost.intCurrencyId <> @DefaultCurrencyId 
		END

		-- Item
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
		EXEC @intReturnValue = dbo.uspICPostInTransitCosting @ItemsToPost = @ItemsToPost
			,@strBatchId = @strBatchIdUsed
			,@strAccountToCounterInventory = 'AP Clearing'
			,@intEntityUserSecurityId = @intEntityUserSecurityId

		-- Inventoried Other Charges
		INSERT INTO @ValueToPost (
			[intItemId] 
			,[intOtherChargeItemId]
			,[intItemLocationId] 
			,[dtmDate] 
			,[dblValue] 
			,[intTransactionId] 
			,[intTransactionDetailId] 
			,[strTransactionId] 
			,[intTransactionTypeId] 
			,[intLotId] 
			,[intSourceTransactionId] 
			,[strSourceTransactionId] 
			,[intSourceTransactionDetailId] 
			,[intFobPointId] 
			,[intInTransitSourceLocationId] 
			,[intCurrencyId] 
			,[intForexRateTypeId] 
			,[dblForexRate] 
			,[intSourceEntityId] 
			,[strSourceType] 
			,[strSourceNumber] 
			,[strBOLNumber] 
			,[intTicketId]
		)
		SELECT 
			[intItemId] = LD.intItemId
			,[intOtherChargeItemId] = ShipmentCharges.intItemId
			,[intItemLocationId] = IL.intItemLocationId
			,[dtmDate] = L.dtmScheduledDate
			,[dblValue] = ShipmentCharges.dblAmount 
			,[intTransactionId] = L.intLoadId
			,[intTransactionDetailId] = LD.intLoadDetailId
			,[strTransactionId] = L.strLoadNumber
			,[intTransactionTypeId] = @INBOUND_SHIPMENT_TYPE
			,[intLotId] = NULL
			,[intSourceTransactionId] = L.intLoadId
			,[strSourceTransactionId] = L.strLoadNumber
			,[intSourceTransactionDetailId] = LD.intLoadDetailId
			,[intFobPointId] = FP.intFobPointId
			,[intInTransitSourceLocationId] = IL.intItemLocationId
			,[intCurrencyId] = ShipmentCharges.intCurrencyId
			,[intForexRateTypeId] = NULL --CASE WHEN (ISNULL(CSC.intMainCurrencyId, CSC.intCurrencyID) = @DefaultCurrencyId) THEN 1 ELSE ISNULL(FX.intCurrencyExchangeRateTypeId,1) END
			,[dblForexRate] = ShipmentCharges.dblFX --CASE WHEN (ISNULL(CSC.intMainCurrencyId, CSC.intCurrencyID) = @DefaultCurrencyId) THEN 1 ELSE ISNULL(FX.dblForexRate,1) END
			,[intSourceEntityId] = NULL
			,[strSourceType] = NULL
			,[strSourceNumber] = NULL 
			,[strBOLNumber] = NULL 
			,[intTicketId] = NULL 
		FROM dbo.tblLGLoad L
		INNER JOIN tblLGLoadDetail LD ON L.intLoadId = LD.intLoadId
		INNER JOIN tblLGLoadCost ShipmentCharges ON ShipmentCharges.intLoadId = L.intLoadId AND ShipmentCharges.strEntityType = 'Vendor'
		INNER JOIN tblICItemLocation IL ON IL.intItemId = LD.intItemId AND LD.intPCompanyLocationId = IL.intLocationId
		LEFT JOIN tblSMFreightTerms FT ON FT.intFreightTermId = L.intFreightTermId
		LEFT JOIN tblICFobPoint FP ON FP.strFobPoint = FT.strFobPoint
		LEFT JOIN tblSMCurrency CSC ON CSC.intCurrencyID = ShipmentCharges.intCurrencyId
		WHERE L.intLoadId = @intLoadId AND ISNULL(ShipmentCharges.ysnInventoryCost,0) = 1
		AND ISNULL(ShipmentCharges.ysnAccrue, 0) = 1

		EXEC @intReturnValue = dbo.uspICPostInTransitCosting  
			@ItemsForInTransitCosting  
			,@strBatchId  
			,NULL 
			,@intEntityUserSecurityId
			,NULL
			,@ValueToPost

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
				,[strRateType]
		)			
		EXEC @intReturnValue = dbo.uspICCreateGLEntriesOnInTransitValueAdjustment								
			@strBatchId = @strBatchId
			,@strTransactionId = @strTransactionId
			,@intEntityUserSecurityId = @intEntityUserSecurityId
			,@strGLDescription = @strGLDescription
			,@AccountCategory_Cost_Adjustment = DEFAULT 

		-- Other Charges
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
		)	
		EXEC @intReturnValue = dbo.uspLGPostOtherCharges 
			@intLoadId
			,@strBatchId
			,@intEntityUserSecurityId
			,@INBOUND_SHIPMENT_TYPE
			,@ysnPost

		UPDATE @GLEntries
		SET strCode = 'LG', strModuleName = 'Logistics'

		IF @intReturnValue < 0
		BEGIN
			RAISERROR (@strErrMsg,16,1)
		END
	END
	ELSE
	BEGIN
		-- Item
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
				,@strBatchId
				,@intEntityUserSecurityId	
				,0

		-- Inventoried Other Charges
		INSERT INTO @ValueToPost (
			[intItemId] 
			,[intOtherChargeItemId]
			,[intItemLocationId] 
			,[dtmDate] 
			,[dblValue] 
			,[intTransactionId] 
			,[intTransactionDetailId] 
			,[strTransactionId] 
			,[intTransactionTypeId] 
			,[intLotId] 
			,[intSourceTransactionId] 
			,[strSourceTransactionId] 
			,[intSourceTransactionDetailId] 
			,[intFobPointId] 
			,[intInTransitSourceLocationId] 
			,[intCurrencyId] 
			,[intForexRateTypeId] 
			,[dblForexRate] 
			,[intSourceEntityId] 
			,[strSourceType] 
			,[strSourceNumber] 
			,[strBOLNumber] 
			,[intTicketId]
		)
		SELECT 
			[intItemId] = LD.intItemId
			,[intOtherChargeItemId] = ShipmentCharges.intItemId
			,[intItemLocationId] = IL.intItemLocationId
			,[dtmDate] = L.dtmScheduledDate
			,[dblValue] = ShipmentCharges.dblAmount * -1
			,[intTransactionId] = L.intLoadId
			,[intTransactionDetailId] = LD.intLoadDetailId
			,[strTransactionId] = L.strLoadNumber
			,[intTransactionTypeId] = @INBOUND_SHIPMENT_TYPE
			,[intLotId] = NULL
			,[intSourceTransactionId] = L.intLoadId
			,[strSourceTransactionId] = L.strLoadNumber
			,[intSourceTransactionDetailId] = LD.intLoadDetailId
			,[intFobPointId] = FP.intFobPointId
			,[intInTransitSourceLocationId] = IL.intItemLocationId
			,[intCurrencyId] = ShipmentCharges.intCurrencyId
			,[intForexRateTypeId] = NULL --CASE WHEN (ISNULL(CSC.intMainCurrencyId, CSC.intCurrencyID) = @DefaultCurrencyId) THEN 1 ELSE ISNULL(FX.intCurrencyExchangeRateTypeId,1) END
			,[dblForexRate] = ShipmentCharges.dblFX --CASE WHEN (ISNULL(CSC.intMainCurrencyId, CSC.intCurrencyID) = @DefaultCurrencyId) THEN 1 ELSE ISNULL(FX.dblForexRate,1) END
			,[intSourceEntityId] = NULL
			,[strSourceType] = NULL
			,[strSourceNumber] = NULL 
			,[strBOLNumber] = NULL 
			,[intTicketId] = NULL 
		FROM dbo.tblLGLoad L
		INNER JOIN tblLGLoadDetail LD ON L.intLoadId = LD.intLoadId
		INNER JOIN tblLGLoadCost ShipmentCharges ON ShipmentCharges.intLoadId = L.intLoadId AND ShipmentCharges.strEntityType = 'Vendor'
		INNER JOIN tblICItemLocation IL ON IL.intItemId = LD.intItemId AND LD.intPCompanyLocationId = IL.intLocationId
		LEFT JOIN tblSMFreightTerms FT ON FT.intFreightTermId = L.intFreightTermId
		LEFT JOIN tblICFobPoint FP ON FP.strFobPoint = FT.strFobPoint
		LEFT JOIN tblSMCurrency CSC ON CSC.intCurrencyID = ShipmentCharges.intCurrencyId
		WHERE L.intLoadId = @intLoadId AND ISNULL(ShipmentCharges.ysnInventoryCost,0) = 1

		EXEC @intReturnValue = dbo.uspICPostInTransitCosting  
			@ItemsForInTransitCosting  
			,@strBatchId  
			,NULL 
			,@intEntityUserSecurityId
			,NULL
			,@ValueToPost

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
				,[strRateType]
		)			
		EXEC @intReturnValue = dbo.uspICCreateGLEntriesOnInTransitValueAdjustment								
			@strBatchId = @strBatchId
			,@strTransactionId = @strTransactionId
			,@intEntityUserSecurityId = @intEntityUserSecurityId
			,@strGLDescription = @strGLDescription
			,@AccountCategory_Cost_Adjustment = DEFAULT 

		-- Other Charges
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
		)	
		EXEC @intReturnValue = dbo.uspLGPostOtherCharges 
			@intLoadId
			,@strBatchId
			,@intEntityUserSecurityId
			,@INBOUND_SHIPMENT_TYPE
			,@ysnPost
		
		UPDATE @GLEntries
		SET [ysnIsUnposted] = 1

		IF @intReturnValue < 0
		BEGIN
			RAISERROR (@strErrMsg,16,1)
		END
	END

IF @ysnRecap = 1
BEGIN 
	ROLLBACK TRAN @TransactionName
	EXEC dbo.uspGLPostRecap @GLEntries, @intEntityUserSecurityId
	COMMIT TRAN @TransactionName
END  
ELSE
BEGIN
	EXEC dbo.uspGLBookEntries @GLEntries, @ysnPost

	--Insert AP Clearing
	INSERT INTO @APClearing (
		intTransactionId
		,strTransactionId
		,intTransactionType
		,strReferenceNumber
		,dtmDate
		,intEntityVendorId
		,intLocationId
		,intTransactionDetailId
		,intAccountId
		,intItemId
		,intItemUOMId
		,dblQuantity
		,dblAmount
		,intOffsetId
		,strOffsetId
		,intOffsetDetailId
		,intOffsetDetailTaxId
		,strCode)
	SELECT DISTINCT
		intTransactionId = GL.intTransactionId
		,strTransactionId = GL.strTransactionId
		,intTransactionType = 4
		,strReferenceNumber = L.strBLNumber
		,dtmDate = GL.dtmDate
		,intEntityVendorId = LD.intVendorEntityId
		,intLocationId = IL.intLocationId
		,intTransactionDetailId = LD.intLoadDetailId
		,intAccountId = GL.intAccountId
		,intItemId = LD.intItemId
		,intItemUOMId = ISNULL(LD.intWeightItemUOMId, LD.intItemUOMId)
		,dblQuantity = ISNULL(LD.dblNet, LD.dblQuantity)
		,dblAmount = ABS(GL.dblDebit - GL.dblCredit)
		,intOffsetId = NULL
		,strOffsetId = NULL
		,intOffsetDetailId = NULL
		,intOffsetDetailTaxId = NULL
		,strCode = GL.strCode
	FROM tblLGLoad L
		INNER JOIN tblLGLoadDetail LD ON LD.intLoadId = L.intLoadId
		INNER JOIN tblICInventoryTransaction ICT ON ICT.intTransactionId = L.intLoadId AND ICT.intTransactionDetailId = LD.intLoadDetailId AND ICT.intTransactionTypeId = 22
		INNER JOIN @GLEntries GL ON GL.intTransactionId = L.intLoadId AND GL.intJournalLineNo = ICT.intInventoryTransactionId
		LEFT JOIN tblICItemLocation IL ON IL.intItemId = LD.intItemId AND LD.intPCompanyLocationId = IL.intLocationId
	WHERE intAccountId = dbo.fnGetItemGLAccount(LD.intItemId, IL.intItemLocationId, 'AP Clearing')

	EXEC uspAPClearing @APClearing, @ysnPost

	COMMIT TRAN @TransactionName
END

--Update Contract Balance and Scheduled Qty for Drop Ship
IF (@intPurchaseSale = 3 AND @ysnRecap = 0)
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
		,[dtmDate] = L.dtmScheduledDate
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
		,[dblCost] = 0 --field is required but not used for updating contract balance
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
--END TRY
--BEGIN CATCH
--	IF @@TRANCOUNT > 1
--	BEGIN
--		ROLLBACK TRAN @TransactionName

--		COMMIT TRAN @TransactionName
--	END

--	SET @strErrMsg = ERROR_MESSAGE()
--	RAISERROR (@strErrMsg,16,1,'WITH NOWAIT')
--END CATCH
