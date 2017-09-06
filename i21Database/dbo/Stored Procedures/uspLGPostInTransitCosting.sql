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


	SELECT @strBatchIdUsed = strBatchId,
		   @strLoadNumber = strLoadNumber
	FROM tblLGLoad 
	WHERE intLoadId = @intLoadId

	IF(@strBatchIdUsed IS NULL)
		EXEC dbo.uspSMGetStartingNumber 3, @strBatchId OUT

	SET @strBatchIdUsed = @strBatchId

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
		,AD.dblSeqPrice
		,(CONVERT(NUMERIC(18, 6), Sum(AD.dblSeqPrice)) / (
				CONVERT(NUMERIC(18, 6), (
						SELECT SUM(dblNet)
						FROM tblLGLoadDetail D
						WHERE L.intLoadId = D.intLoadId
						))
				) * CONVERT(NUMERIC(18, 6), SUM(LD.dblNet)))
		,0.0
		,AD.intSeqCurrencyId
		,AD.dblNetWtToPriceUOMConvFactor
		,L.intLoadId
		,intLoadDetailId
		,L.strLoadNumber
		,22 intTransactionTypeId
		,NULL
		,L.intLoadId
		,strLoadNumber
		,0
		,2--FP.intFobPointId
		,IL.intItemLocationId
		,NULL
		,AD.dblQtyToPriceUOMConvFactor
	FROM tblLGLoad L
	JOIN tblLGLoadDetail LD ON L.intLoadId = LD.intLoadId
	JOIN tblICItemLocation IL ON IL.intItemId = LD.intItemId
		AND LD.intPCompanyLocationId = IL.intLocationId
	JOIN tblICItemUOM IU ON IU.intItemUOMId = LD.intItemUOMId
	JOIN tblCTContractDetail CD ON CD.intContractDetailId = LD.intPContractDetailId
	JOIN tblCTContractHeader CH ON CH.intContractHeaderId = CD.intContractHeaderId
		CROSS APPLY dbo.fnCTGetAdditionalColumnForDetailView(CD.intContractDetailId) AD
	LEFT JOIN tblSMFreightTerms FT ON FT.intFreightTermId = L.intFreightTermId
	LEFT JOIN tblICFobPoint FP ON FP.strFobPoint = FT.strFobPoint
	WHERE L.intLoadId = @intLoadId
	GROUP BY LD.intItemId
			,IL.intItemLocationId
			,LD.intItemUOMId
			,LD.dblQuantity
			,IU.dblUnitQty
			,AD.dblSeqPrice
			,L.intLoadId
			,AD.intSeqCurrencyId
			,AD.dblNetWtToPriceUOMConvFactor
			,LD.intLoadDetailId
			,L.strLoadNumber
			,FP.intFobPointId
			,AD.dblQtyToPriceUOMConvFactor
	

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
		EXEC @intReturnValue = dbo.uspICPostInTransitCosting 
									 @ItemsToPost = @ItemsToPost
									,@strBatchId = @strLoadNumber
									,@strAccountToCounterInventory = 'AP Clearing'--NULL
									,@intEntityUserSecurityId = @intEntityUserSecurityId
									,@strGLDescription = ''

		SELECT * FROM @GLEntries
		IF @intReturnValue < 0 
		BEGIN
			RAISERROR(@strErrMsg,16,1)
		END
		
		EXEC dbo.uspGLBookEntries @GLEntries, @ysnPost 
				
	END 	

END TRY

BEGIN CATCH
	SET @strErrMsg = ERROR_MESSAGE()

	RAISERROR (@strErrMsg,16,1,'WITH NOWAIT')
END CATCH