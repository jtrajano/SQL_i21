﻿CREATE PROCEDURE [dbo].[uspLGUpdateAllocatedBasisComponent]
	@intAllocationDetailId INT
AS

DECLARE @intPContractBasisItemId INT
DECLARE @intReserveBCategoryId INT
DECLARE @intSContractDetailId INT
DECLARE @intPContractDetailId INT
DECLARE @intBasisUnitMeasureId INT
DECLARE @intBasisCurrencyId INT
DECLARE @intBasisDecimals INT
DECLARE @intSubCurrencyCents INT = 1

SELECT TOP 1 
	@intPContractBasisItemId = intPurchaseContractBasisItemId
	,@intReserveBCategoryId = intPnLReportReserveBCategoryId
FROM tblLGCompanyPreference 

/* Check if Purchase Contract Basis Item and Reserve B Category is configured */
IF @intAllocationDetailId IS NULL OR @intPContractBasisItemId IS NULL OR @intReserveBCategoryId IS NULL
RETURN

/* Get Allocated Contracts */
SELECT @intSContractDetailId = ALD.intSContractDetailId 
		,@intPContractDetailId = ALD.intPContractDetailId
		,@intBasisUnitMeasureId = UOM.intUnitMeasureId
		,@intBasisCurrencyId = SCD.intBasisCurrencyId
		,@intSubCurrencyCents = ISNULL(BCUR.intCent, 1)
		,@intBasisDecimals = ISNULL(FM.intNoOfDecimal, CP.intCurrencyDecimal)
FROM tblLGAllocationDetail ALD
	INNER JOIN tblCTContractDetail PCD ON PCD.intContractDetailId = ALD.intPContractDetailId
	INNER JOIN tblCTContractDetail SCD ON SCD.intContractDetailId = ALD.intSContractDetailId
	INNER JOIN tblCTContractHeader SCH ON SCH.intContractHeaderId = SCD.intContractHeaderId
	LEFT JOIN tblICItemUOM UOM ON UOM.intItemUOMId = SCD.intBasisUOMId
	LEFT JOIN tblSMCurrency BCUR ON BCUR.intCurrencyID = SCD.intBasisCurrencyId
	LEFT JOIN tblRKFutureMarket FM ON FM.intFutureMarketId = SCD.intFutureMarketId
	OUTER APPLY (SELECT TOP 1 intCurrencyDecimal FROM tblSMCompanyPreference) CP
WHERE intAllocationDetailId = @intAllocationDetailId

/* Place Reserve B Components with zero rate to temp table */
SELECT 
	CC.*
INTO #tmpReserveB
FROM tblCTContractCost CC 
	INNER JOIN tblICItem I ON I.intItemId = CC.intItemId
WHERE intContractDetailId = @intSContractDetailId
	AND I.intCategoryId = @intReserveBCategoryId 

IF EXISTS(SELECT TOP 1 1 FROM #tmpReserveB)
BEGIN
	/* Apply Reserves B Standard Costs */
	UPDATE RB
	SET RB.dblRate = CASE WHEN ISNULL(RB.dblRate, 0) = 0 THEN
							CASE WHEN (I.intCostUOMId IS NULL) 
								THEN I.dblAmount * @intSubCurrencyCents
							WHEN (I.intCostUOMId <> BUOM.intItemUOMId) 
								THEN dbo.fnCalculateCostBetweenUOM(I.intCostUOMId, BUOM.intItemUOMId, I.dblAmount) * @intSubCurrencyCents
							ELSE I.dblAmount * @intSubCurrencyCents END 
						ELSE RB.dblRate END
		,RB.intItemUOMId = BUOM.intItemUOMId
	FROM #tmpReserveB RB
	INNER JOIN tblICItem I ON RB.intItemId = I.intItemId
	LEFT JOIN tblICItemUOM UOM ON UOM.intItemUOMId = RB.intItemUOMId
	OUTER APPLY (SELECT intItemUOMId FROM tblICItemUOM WHERE intItemId = RB.intItemId AND intUnitMeasureId = @intBasisUnitMeasureId) BUOM

	/* Update Sales Contract Basis Components with the recalculated amounts */
	UPDATE CC
	SET CC.dblRate = ROUND(RB.dblRate, @intBasisDecimals)
		,CC.intItemUOMId = RB.intItemUOMId
	FROM tblCTContractCost CC
	INNER JOIN #tmpReserveB RB ON CC.intContractCostId = RB.intContractCostId

	/* Recalculate Sales Basis Total and Contract Cash Price*/
	UPDATE SCD
		SET dblBasis = BS.dblBasisTotal
			,dblCashPrice = SCD.dblFutures + BS.dblBasisTotal
	FROM tblCTContractDetail SCD
	OUTER APPLY (SELECT dblBasisTotal = SUM(dblRate) FROM tblCTContractCost 
				WHERE ysnBasis = 1 AND intContractDetailId = @intSContractDetailId) BS
	WHERE SCD.intContractDetailId = @intSContractDetailId
END
GO