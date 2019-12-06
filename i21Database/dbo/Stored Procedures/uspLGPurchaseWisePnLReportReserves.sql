CREATE PROCEDURE [dbo].[uspLGPurchaseWisePnLReportReserves]
	@intAllocationDetailId INT
	,@intUnitMeasureId INT = NULL
	,@intReserves INT = 1 /* 1= Reserves A, 2 = Reserves B */
AS

DECLARE @intDefaultCurrencyId AS INT = dbo.fnSMGetDefaultCurrency('FUNCTIONAL')
		,@strUnitMeasure AS NVARCHAR(200)
		,@strCurrency AS NVARCHAR(200)

IF (@intUnitMeasureId IS NULL)
	SELECT @intUnitMeasureId = intSUnitMeasureId 
	FROM tblLGAllocationDetail WHERE intAllocationDetailId = @intAllocationDetailId

SELECT @strUnitMeasure = strUnitMeasure FROM tblICUnitMeasure WHERE intUnitMeasureId = @intUnitMeasureId
SELECT @strCurrency = ISNULL(strSymbol, strCurrency) FROM tblSMCurrency WHERE intCurrencyID = @intDefaultCurrencyId

SELECT
	I.strItemNo
	,dblRate = ISNULL(CC.dblRate, 0)
	,dblEstimatedAmount = ISNULL(CC.dblAmount, 0)
	,dblInvoicedAmount = CASE WHEN @intReserves = 1 THEN ISNULL(VCHR.dblTotal, 0) + ISNULL(INVC.dblTotal, 0) ELSE 0 END
	,dblVariance = CASE WHEN @intReserves = 1 THEN 
						CASE WHEN (ISNULL(VCHR.dblTotal, 0) + ISNULL(INVC.dblTotal, 0)) < 0 
							THEN (ISNULL(VCHR.dblTotal, 0) + ISNULL(INVC.dblTotal, 0)) - ISNULL(CC.dblAmount, 0)
							ELSE 0 END
					ELSE 0 END
	,dblRecalcValue = CASE WHEN @intReserves = 1 THEN 
						CASE WHEN (ISNULL(VCHR.dblTotal, 0) + ISNULL(INVC.dblTotal, 0)) < 0 
							THEN (ISNULL(VCHR.dblTotal, 0) + ISNULL(INVC.dblTotal, 0)) 
							ELSE ISNULL(CC.dblAmount, 0) END
					ELSE ISNULL(CC.dblAmount, 0) * -1 END
	,strUnitCurrency = @strCurrency + '/' + @strUnitMeasure
FROM tblICItem I
	OUTER APPLY (SELECT CC.intContractDetailId
						,dblRate = ISNULL(dbo.fnCalculateCostBetweenUOM(CC.intItemUOMId,ToUOM.intItemUOMId,CC.dblRate), 0) / ISNULL(CCUR.intCent, 1)
						,dblAmount = CASE WHEN CC.strCostMethod = 'Per Unit' THEN 
											dbo.fnCalculateQtyBetweenUOM(CD.intItemUOMId,CC.intItemUOMId,CD.dblQuantity) * CC.dblRate
										WHEN CC.strCostMethod = 'Amount' OR CC.strCostMethod = 'Per Container' THEN
											CC.dblRate
										WHEN CC.strCostMethod = 'Percentage' THEN 
											dbo.fnCalculateQtyBetweenUOM(CD.intItemUOMId,CC.intItemUOMId,CD.dblQuantity) * CD.dblCashPrice * CC.dblRate/100
										END
					FROM tblCTContractCost CC
						LEFT JOIN tblCTContractDetail CD ON CD.intContractDetailId = CC.intContractDetailId
						LEFT JOIN tblLGAllocationDetail ALD ON CC.intContractDetailId = ALD.intSContractDetailId
						LEFT JOIN tblSMCurrency CCUR ON CCUR.intCurrencyID = CC.intCurrencyId
						OUTER APPLY (SELECT	TOP 1 intItemUOMId, dblUnitQty FROM	dbo.tblICItemUOM 
									WHERE intItemId = I.intItemId AND intUnitMeasureId = @intUnitMeasureId) ToUOM
					 WHERE CC.intItemId = I.intItemId AND ALD.intAllocationDetailId = @intAllocationDetailId) CC
	OUTER APPLY (SELECT dblTotal = SUM(CASE WHEN BL.intTransactionType IN (3, 11) 
										THEN (BLD.dblTotal * -1) 
										ELSE BLD.dblTotal END) 
				FROM tblAPBillDetail BLD 
					INNER JOIN tblAPBill BL ON BL.intBillId = BLD.intBillId
					INNER JOIN tblICItem BLDI ON BLDI.intItemId = BLD.intItemId
				WHERE BL.ysnPosted = 1
					AND BLD.intContractDetailId = CC.intContractDetailId 
					AND BLD.intItemId = I.intItemId 
					AND BLDI.strType = 'Other Charge'
				) VCHR
	OUTER APPLY (SELECT dblTotal = SUM(CASE WHEN IV.strTransactionType IN ('Credit Memo') 
										THEN (IVD.dblTotal * -1) 
										ELSE IVD.dblTotal END)
				FROM tblARInvoiceDetail IVD 
					INNER JOIN tblARInvoice IV ON IV.intInvoiceId = IVD.intInvoiceId
					INNER JOIN tblICItem IVDI ON IVDI.intItemId = IVD.intItemId
				WHERE IV.ysnPosted = 1
					AND IVD.intContractDetailId = CC.intContractDetailId 
					AND IVD.intItemId = I.intItemId 
					AND IVDI.strType = 'Other Charge'
				) INVC
WHERE I.intCategoryId = (SELECT TOP 1 CASE WHEN @intReserves <> 1 
							THEN intPnLReportReserveBCategoryId 
							ELSE intPnLReportReserveACategoryId END 
						FROM tblLGCompanyPreference)
GO