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

	SELECT @strBatchIdUsed = strBatchId
		,@strLoadNumber = strLoadNumber
		,@strFOBPoint = FT.strFobPoint
		,@intFOBPointId = FP.intFobPointId
	FROM dbo.tblLGLoad L
	LEFT JOIN tblSMFreightTerms FT ON FT.intFreightTermId = L.intFreightTermId
	LEFT JOIN tblICFobPoint FP ON FP.strFobPoint = FP.strFobPoint
	WHERE intLoadId = @intLoadId

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
		SELECT LD.intItemId
			,IL.intItemLocationId
			,LD.intItemUOMId
			,GETDATE()
			,LD.dblQuantity
			,IU.dblUnitQty
			,CASE 
				WHEN LD.strPriceStatus = 'Basis'
					THEN CASE 
							WHEN CUR.ysnSubCurrency = 1
								THEN dbo.fnCTConvertQtyToTargetItemUOM(LD.intItemUOMId, LD.intPriceUOMId, 1) * LD.dblUnitPrice / 100
							ELSE dbo.fnCTConvertQtyToTargetItemUOM(LD.intItemUOMId, LD.intPriceUOMId, 1) * LD.dblUnitPrice
							END
				ELSE CASE 
						WHEN AD.ysnSeqSubCurrency = 1
							THEN AD.dblQtyToPriceUOMConvFactor * ISNULL(AD.dblSeqPrice, 0) / 100
						ELSE AD.dblQtyToPriceUOMConvFactor * ISNULL(AD.dblSeqPrice, 0)
						END
				END dblCost
			,CASE 
				WHEN LD.strPriceStatus = 'Basis'
					THEN CASE 
							WHEN CUR.ysnSubCurrency = 1
								THEN dbo.fnCTConvertQtyToTargetItemUOM(LD.intItemUOMId, LD.intPriceUOMId, 1) * LD.dblUnitPrice / 100
							ELSE dbo.fnCTConvertQtyToTargetItemUOM(LD.intItemUOMId, LD.intPriceUOMId, 1) * LD.dblUnitPrice
							END
				ELSE CASE 
						WHEN AD.ysnSeqSubCurrency = 1
							THEN AD.dblQtyToPriceUOMConvFactor * ISNULL(AD.dblSeqPrice, 0) / 100
						ELSE AD.dblQtyToPriceUOMConvFactor * ISNULL(AD.dblSeqPrice, 0)
						END
				END * LD.dblQuantity dblValue
			,0.0
			,L.intCurrencyId
			,ISNULL(AD.dblNetWtToPriceUOMConvFactor,0)
			,L.intLoadId
			,intLoadDetailId
			,L.strLoadNumber
			,22 intTransactionTypeId
			,NULL
			,L.intLoadId
			,strLoadNumber
			,0
			,FP.intFobPointId
			,IL.intItemLocationId
			,CASE WHEN CD.ysnUseFXPrice = 1 THEN CD.intRateTypeId ELSE NULL END
			,CASE WHEN CD.ysnUseFXPrice = 1 THEN CD.dblRate ELSE 1 END
		FROM tblLGLoad L
		JOIN tblLGLoadDetail LD ON L.intLoadId = LD.intLoadId
		JOIN tblICItemLocation IL ON IL.intItemId = LD.intItemId
			AND LD.intPCompanyLocationId = IL.intLocationId
		JOIN tblICItemUOM IU ON IU.intItemUOMId = LD.intItemUOMId
		JOIN tblCTContractDetail CD ON CD.intContractDetailId = LD.intPContractDetailId
		JOIN tblCTContractHeader CH ON CH.intContractHeaderId = CD.intContractHeaderId
		CROSS APPLY dbo.fnCTGetAdditionalColumnForDetailView(CD.intContractDetailId) AD
		LEFT JOIN tblSMFreightTerms FT ON FT.intFreightTermId = CASE WHEN L.intPurchaseSale = 3 THEN 1 ELSE L.intFreightTermId END
		LEFT JOIN tblICFobPoint FP ON FP.strFobPoint = FT.strFobPoint
		LEFT JOIN tblSMCurrency CUR ON CUR.intCurrencyID = LD.intPriceCurrencyId
		WHERE L.intLoadId = @intLoadId
		GROUP BY LD.intItemId
			,IL.intItemLocationId
			,LD.intItemUOMId
			,LD.dblQuantity
			,IU.dblUnitQty
			,AD.dblSeqPrice
			,L.intLoadId
			,L.intCurrencyId
			,AD.dblNetWtToPriceUOMConvFactor
			,LD.intLoadDetailId
			,L.strLoadNumber
			,FP.intFobPointId
			,AD.dblQtyToPriceUOMConvFactor
			,AD.ysnSeqSubCurrency
			,CD.intRateTypeId
			,CD.dblRate
			,CD.ysnUseFXPrice
			,LD.strPriceStatus
			,LD.intWeightItemUOMId
			,LD.intPriceUOMId
			,LD.dblUnitPrice
			,CUR.ysnSubCurrency

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

	IF @intPurchaseSale > 3
	BEGIN
		DECLARE @ItemsForPost AS ItemCostingTableType
		DECLARE @StorageItemsForPost AS ItemCostingTableType

		-- Get company owned items to post. 
		INSERT INTO @ItemsForPost (
			intItemId
			,intItemLocationId
			,intItemUOMId
			,dtmDate
			,dblQty
			,dblUOMQty
			,dblCost
			,dblSalesPrice
			,intCurrencyId
			,dblExchangeRate
			,intTransactionId
			,intTransactionDetailId
			,strTransactionId
			,intTransactionTypeId
			,intLotId
			,intSubLocationId
			,intStorageLocationId
			)
		SELECT intItemId = LoadDetail.intItemId
			,intItemLocationId = dbo.fnICGetItemLocation(LoadDetail.intItemId, LoadDetail.intSCompanyLocationId)
			,intItemUOMId = CASE 
				WHEN Lot.intLotId IS NULL
					THEN ItemUOM.intItemUOMId
				ELSE LotItemUOM.intItemUOMId
				END
			,dtmDate = dbo.fnRemoveTimeOnDate(LOAD.dtmScheduledDate)
			,dblQty = - 1 * CASE 
				WHEN Lot.intLotId IS NULL
					THEN ISNULL(LoadDetail.dblQuantity, 0)
				ELSE ISNULL(DetailLot.dblLotQuantity, 0)
				END
			,dblUOMQty = CASE 
				WHEN Lot.intLotId IS NULL
					THEN ItemUOM.dblUnitQty
				ELSE LotItemUOM.dblUnitQty
				END
			,dblCost = ISNULL(CASE 
					WHEN Lot.dblLastCost IS NULL
						THEN (
								SELECT TOP 1 dblLastCost
								FROM tblICItemPricing
								WHERE intItemId = LoadDetail.intItemId
									AND intItemLocationId = dbo.fnICGetItemLocation(LoadDetail.intItemId, LoadDetail.intSCompanyLocationId)
								)
					ELSE Lot.dblLastCost
					END, 0) * CASE 
				WHEN Lot.intLotId IS NULL
					THEN ItemUOM.dblUnitQty
				ELSE LotItemUOM.dblUnitQty
				END
			,dblSalesPrice = 0.00
			,intCurrencyId = @DefaultCurrencyId
			,dblExchangeRate = 1
			,intTransactionId = LOAD.intLoadId
			,intTransactionDetailId = LoadDetail.intLoadDetailId
			,strTransactionId = LOAD.strLoadNumber
			,intTransactionTypeId = @INVENTORY_SHIPMENT_TYPE
			,intLotId = ISNULL(Lot.intLotId,0)
			,intSubLocationId = Lot.intSubLocationId --, DetailLot.intSubLocationId)
			,intStorageLocationId = Lot.intStorageLocationId --, DetailLot.intStorageLocationId) 
		FROM tblLGLoad LOAD --Header 
		INNER JOIN tblLGLoadDetail LoadDetail ON LOAD.intLoadId = LoadDetail.intLoadId -- DetailItem
		INNER JOIN tblICItemUOM ItemUOM ON ItemUOM.intItemUOMId = LoadDetail.intItemUOMId
		LEFT JOIN tblLGLoadDetailLot DetailLot ON DetailLot.intLoadDetailId = LoadDetail.intLoadDetailId
		LEFT JOIN tblICLot Lot ON Lot.intLotId = DetailLot.intLotId
		LEFT JOIN tblICItemUOM LotItemUOM ON LotItemUOM.intItemUOMId = Lot.intItemUOMId
		WHERE LOAD.intLoadId = @intLoadId

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
		SELECT [intItemId]
			,[intItemLocationId]
			,[intItemUOMId]
			,[dtmDate]
			,- [dblQty]
			,[dblUOMQty]
			,[dblCost]
			,[dblValue]
			,[dblSalesPrice]
			,[intCurrencyId]
			,ISNULL([dblExchangeRate],0)
			,[intTransactionId]
			,[intTransactionDetailId]
			,[strTransactionId]
			,[intTransactionTypeId]
			,[intLotId]
			,[intTransactionId]
			,[strTransactionId]
			,[intTransactionDetailId]
			,[intFobPointId] = 2
			,[intInTransitSourceLocationId] = t.intItemLocationId
			,[intForexRateTypeId] = t.intForexRateTypeId
			,[dblForexRate] = t.dblForexRate
		FROM tblICInventoryTransaction t
		WHERE t.strTransactionId = @intLoadId
			AND t.ysnIsUnposted = 0
			AND t.strBatchId = @strBatchId
			AND @intFOBPointId = 2
			AND t.dblQty < 0 -- Ensure the Qty is negative. Credit Memo are positive Qtys.  Credit Memo does not ship out but receives stock. 

		IF EXISTS (
				SELECT TOP 1 1
				FROM @ItemsToPost
				)
		BEGIN
			SET @ysnAllowBlankGLEntries = 0

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
				,@strBatchId = @strBatchId
				,@strAccountToCounterInventory = NULL
				,@intEntityUserSecurityId = @intEntityUserSecurityId
				,@strGLDescription = ''

			--IF @intReturnValue < 0
			--	GOTO With_Rollback_Exit
			END
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