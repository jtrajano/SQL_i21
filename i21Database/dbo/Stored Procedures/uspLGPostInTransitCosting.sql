CREATE PROCEDURE uspLGPostInTransitCosting 
	 @intLoadId INT
	,@ysnPost BIT
	,@intPurchaseSale INT
	,@intEntityUserSecurityId INT
AS
BEGIN TRY
	DECLARE @strErrMsg NVARCHAR(MAX)
	DECLARE @intShipmentType INT
	DECLARE @strLoadNumber NVARCHAR(100)
	DECLARE @ItemsToPost ItemInTransitCostingTableType
	DECLARE @GLEntries AS RecapTableType
	DECLARE @intReturnValue INT
	DECLARE @STARTING_NUMBER_BATCH INT = 3
	DECLARE @strBatchId NVARCHAR(20)
	DECLARE @strBatchIdUsed NVARCHAR(20)
	DECLARE @intLocationId INT
	DECLARE @strFOBPoint NVARCHAR(50)
	DECLARE @intFOBPointId INT
	DECLARE @INVENTORY_SHIPMENT_TYPE AS INT = 5
	DECLARE @DefaultCurrencyId AS INT = dbo.fnSMGetDefaultCurrency('FUNCTIONAL')
	DECLARE @ysnAllowBlankGLEntries AS BIT = 1
	DECLARE @dummyGLEntries AS RecapTableType
	DECLARE @intSalesContractId INT
	DECLARE @intItemLocationId INT
	DECLARE @intDestinationFOBPointId INT

	SELECT @strBatchIdUsed = strBatchId
		,@strLoadNumber = strLoadNumber
		,@strFOBPoint = FT.strFobPoint
		,@intFOBPointId = FP.intFobPointId
	FROM dbo.tblLGLoad L
	LEFT JOIN tblSMFreightTerms FT ON FT.intFreightTermId = L.intFreightTermId
	LEFT JOIN tblICFobPoint FP ON FP.strFobPoint = FP.strFobPoint
	WHERE intLoadId = @intLoadId

	SELECT @intDestinationFOBPointId = intFobPointId
	FROM tblICFobPoint
	WHERE strFobPoint = 'Destination'

	EXEC dbo.uspSMGetStartingNumber 3
		,@strBatchId OUT

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
			)
		SELECT 
			intItemId = LD.intItemId
			,intItemLocationId = IL.intItemLocationId
			,intItemUOMId = LD.intItemUOMId
			,dtmDate = GETDATE()
			,dblQty = LD.dblQuantity
			,dblUOMQty = IU.dblUnitQty
			,dblCost = 
						ISNULL(
							--LD.dblAmount/LD.dblQuantity 
							dbo.fnCalculateCostBetweenUOM(
								LD.intPriceUOMId
								, LD.intItemUOMId
								, (LD.dblUnitPrice / CASE WHEN (CUR.ysnSubCurrency = 1) THEN CUR.intCent ELSE 1 END)
							) 
							, (
								
								CASE 
									WHEN (AD.dblSeqPrice IS NULL) THEN
										CASE 
											WHEN (LD.dblUnitPrice > 0) THEN 
												LD.dblUnitPrice 
												/ CASE WHEN (CUR.ysnSubCurrency = 1) THEN CUR.intCent ELSE 1 END
											ELSE 
												dbo.fnCTGetSequencePrice(CD.intContractDetailId,NULL) 
										END
									ELSE 
										AD.dblSeqPrice 
										/ CASE WHEN (AD.ysnSeqSubCurrency = 1) THEN 100 ELSE 1 END
								END
								* AD.dblQtyToPriceUOMConvFactor
								* CASE 
									WHEN (@DefaultCurrencyId <> LD.intForexCurrencyId AND LD.intForexRateTypeId IS NOT NULL AND LD.dblForexRate IS NOT NULL) THEN ISNULL(LD.dblForexRate, 1) --FX on LS detail level
									WHEN (@DefaultCurrencyId <> ISNULL(SeqCUR.intMainCurrencyId, SeqCUR.intCurrencyID)) THEN ISNULL(CTFX.dblFXRate, 1) --FX on CT level
									WHEN (@DefaultCurrencyId <> L.intCurrencyId) THEN ISNULL(FX.dblFXRate, 1) --FX on LS header level
									ELSE 1 
								END
							) 
						)
			,dblValue = CASE WHEN (AD.dblSeqPrice IS NULL) THEN
							CASE WHEN (LD.dblUnitPrice > 0) 
								THEN LD.dblUnitPrice / CASE WHEN (CUR.ysnSubCurrency = 1) THEN CUR.intCent ELSE 1 END
								ELSE dbo.fnCTGetSequencePrice(CD.intContractDetailId,NULL) END
							ELSE AD.dblSeqPrice / CASE WHEN (AD.ysnSeqSubCurrency = 1) THEN 100 ELSE 1 END
						END
						* AD.dblQtyToPriceUOMConvFactor 
						* CASE WHEN (@DefaultCurrencyId <> LD.intForexCurrencyId AND LD.intForexRateTypeId IS NOT NULL AND LD.dblForexRate IS NOT NULL) THEN ISNULL(LD.dblForexRate, 1) --FX on LS detail level
							   WHEN (@DefaultCurrencyId <> ISNULL(SeqCUR.intMainCurrencyId, SeqCUR.intCurrencyID)) THEN ISNULL(CTFX.dblFXRate, 1) --FX on CT level
							   WHEN (@DefaultCurrencyId <> L.intCurrencyId) THEN ISNULL(FX.dblFXRate, 1) --FX on LS header level
							   ELSE 1 END
						* LD.dblQuantity 
			,dblSalesPrice = 0.0
			,intCurrencyId = @DefaultCurrencyId 
			,dblExchangeRate = ISNULL(AD.dblNetWtToPriceUOMConvFactor,0)
			,intTransactionId = L.intLoadId
			,intTransactionDetailId = LD.intLoadDetailId
			,strTransactionId = L.strLoadNumber
			,intTransactionTypeId = 22
			,intLotId = NULL
			,intSourceTransactionId = L.intLoadId
			,strSourceTransactionId = L.strLoadNumber
			,intSourceTransactionDetailId = LD.intLoadDetailId
			,intFobPointId = CASE WHEN L.intPurchaseSale = 3 THEN @intDestinationFOBPointId ELSE FP.intFobPointId END
			,intInTransitSourceLocationId = IL.intItemLocationId
			,intForexRateTypeId = CASE WHEN CD.ysnUseFXPrice = 1 THEN ISNULL(CD.intRateTypeId,LD.intForexRateTypeId)
									   WHEN (@DefaultCurrencyId <> ISNULL(SeqCUR.intMainCurrencyId, SeqCUR.intCurrencyID)) THEN CTFX.intForexRateTypeId 
									   WHEN (@DefaultCurrencyId <> L.intCurrencyId) THEN FX.intForexRateTypeId
									   ELSE LD.intForexRateTypeId END
			,dblForexRate = CASE WHEN CD.ysnUseFXPrice = 1 THEN ISNULL(CD.dblRate,LD.dblForexRate) 
								 WHEN (@DefaultCurrencyId <> ISNULL(SeqCUR.intMainCurrencyId, SeqCUR.intCurrencyID)) THEN ISNULL(CTFX.dblFXRate, 1)
								 WHEN (@DefaultCurrencyId <> L.intCurrencyId) THEN ISNULL(FX.dblFXRate, 1)
								 ELSE ISNULL(LD.dblForexRate,1) END
		FROM tblLGLoad L
		JOIN tblLGLoadDetail LD ON L.intLoadId = LD.intLoadId
		JOIN tblICItemLocation IL ON IL.intItemId = LD.intItemId
			AND LD.intPCompanyLocationId = IL.intLocationId
		JOIN tblICItemUOM IU ON IU.intItemUOMId = LD.intItemUOMId
		JOIN tblCTContractDetail CD ON CD.intContractDetailId = LD.intPContractDetailId
		JOIN tblCTContractHeader CH ON CH.intContractHeaderId = CD.intContractHeaderId
		CROSS APPLY dbo.fnCTGetAdditionalColumnForDetailView(CD.intContractDetailId) AD
		LEFT JOIN tblICItemUOM WU ON WU.intItemUOMId = LD.intWeightItemUOMId
		LEFT JOIN tblSMFreightTerms FT ON FT.intFreightTermId = L.intFreightTermId
		LEFT JOIN tblICFobPoint FP ON FP.strFobPoint = FT.strFobPoint
		LEFT JOIN tblSMCurrency CUR ON CUR.intCurrencyID = LD.intPriceCurrencyId
		LEFT JOIN tblSMCurrency SeqCUR ON SeqCUR.intCurrencyID = AD.intSeqCurrencyId
		OUTER APPLY (SELECT	TOP 1  
						intForexRateTypeId = RD.intRateTypeId
						,dblFXRate = CASE WHEN ER.intFromCurrencyId = @DefaultCurrencyId  
									THEN 1/RD.[dblRate] 
									ELSE RD.[dblRate] END 
						FROM tblSMCurrencyExchangeRate ER
						JOIN tblSMCurrencyExchangeRateDetail RD ON RD.intCurrencyExchangeRateId = ER.intCurrencyExchangeRateId
						WHERE @DefaultCurrencyId <> L.intCurrencyId
							AND ((ER.intFromCurrencyId = L.intCurrencyId AND ER.intToCurrencyId = @DefaultCurrencyId) 
								OR (ER.intFromCurrencyId = @DefaultCurrencyId AND ER.intToCurrencyId = L.intCurrencyId))
						ORDER BY RD.dtmValidFromDate DESC) FX
		OUTER APPLY (SELECT	TOP 1  
				intForexRateTypeId = RD.intRateTypeId
				,dblFXRate = CASE WHEN ER.intFromCurrencyId = @DefaultCurrencyId  
							THEN 1/RD.[dblRate] 
							ELSE RD.[dblRate] END 
				FROM tblSMCurrencyExchangeRate ER
				JOIN tblSMCurrencyExchangeRateDetail RD ON RD.intCurrencyExchangeRateId = ER.intCurrencyExchangeRateId
				WHERE @DefaultCurrencyId <> ISNULL(SeqCUR.intMainCurrencyId, SeqCUR.intCurrencyID)
					AND ((ER.intFromCurrencyId = ISNULL(SeqCUR.intMainCurrencyId, SeqCUR.intCurrencyID) AND ER.intToCurrencyId = @DefaultCurrencyId) 
						OR (ER.intFromCurrencyId = @DefaultCurrencyId AND ER.intToCurrencyId = ISNULL(SeqCUR.intMainCurrencyId, SeqCUR.intCurrencyID)))
				ORDER BY RD.dtmValidFromDate DESC) CTFX
		WHERE L.intLoadId = @intLoadId
		GROUP BY LD.intItemId
			,IL.intItemLocationId
			,LD.intItemUOMId
			,LD.dblQuantity
			,LD.dblNet
			,IU.dblUnitQty
			,WU.dblUnitQty
			,AD.dblSeqPrice
			,L.intLoadId
			,L.intCurrencyId
			,AD.dblNetWtToPriceUOMConvFactor
			,LD.intLoadDetailId
			,L.strLoadNumber
			,FP.intFobPointId
			,AD.dblQtyToPriceUOMConvFactor
			,AD.ysnSeqSubCurrency
			,CD.intContractDetailId
			,CD.intRateTypeId
			,CD.dblRate
			,CD.ysnUseFXPrice
			,LD.strPriceStatus
			,LD.intWeightItemUOMId
			,LD.intPriceUOMId
			,LD.dblUnitPrice
			,CUR.ysnSubCurrency
			,CUR.intCent
			,LD.intForexRateTypeId
			,LD.dblForexRate
			,LD.intForexCurrencyId
			,LD.dblAmount
			,L.intPurchaseSale
			,CD.dblTotalCost
			,CD.dblCashPrice
			,AD.intSeqCurrencyId
			,SeqCUR.intMainCurrencyId
			,SeqCUR.intCurrencyID
			,FX.intForexRateTypeId
			,FX.dblFXRate
			,CTFX.intForexRateTypeId
			,CTFX.dblFXRate

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

			EXEC dbo.uspGLBookEntries @GLEntries
				,@ysnPost

			--SELECT TOP 1 @intItemLocationId = intItemLocationId
			--FROM @ItemsToPost
			--WHERE strTransactionId = @strLoadNumber
			--	AND intTransactionId = @intLoadId

			--UPDATE tblICInventoryTransaction
			--SET intItemLocationId = @intItemLocationId
			--WHERE intTransactionId = @intLoadId
			--	AND strTransactionId = @strLoadNumber
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
END TRY

BEGIN CATCH
	SET @strErrMsg = ERROR_MESSAGE()

	RAISERROR (@strErrMsg,16,1,'WITH NOWAIT')
END CATCH