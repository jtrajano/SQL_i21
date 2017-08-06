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

	SELECT @strLoadNumber = strLoadNumber
	FROM tblLGLoad
	WHERE intLoadId = @intLoadId

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
		,11 intTransactionTypeId
		,0
		,L.intLoadId
		,strLoadNumber
		,0
		,FP.intFobPointId
		,IL.intItemLocationId
		,0
		,AD.dblQtyToPriceUOMConvFactor
	FROM tblLGLoad L
	JOIN tblLGLoadDetail LD ON L.intLoadId = LD.intLoadId
	JOIN tblICItemLocation IL ON IL.intItemId = LD.intItemId
		AND LD.intPCompanyLocationId = IL.intLocationId
	JOIN tblICItemUOM IU ON IU.intItemUOMId = LD.intItemUOMId
	JOIN tblCTContractDetail CD ON CD.intContractDetailId = LD.intPContractDetailId
	JOIN tblCTContractHeader CH ON CH.intContractHeaderId = CD.intContractHeaderId
	--JOIN tblICItemLocation IL ON IL.intItemId = LD.intItemId AND IL.intLocationId = LD.intPCompanyLocationId
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
	

	EXEC uspICPostInTransitCosting @ItemsToPost = @ItemsToPost
		,@strBatchId = @strLoadNumber
		,@strAccountToCounterInventory = 0
		,@intEntityUserSecurityId = @intEntityUserSecurityId
		,@strGLDescription = ''
END TRY

BEGIN CATCH
	SET @strErrMsg = ERROR_MESSAGE()

	RAISERROR (@strErrMsg,16,1,'WITH NOWAIT')
END CATCH