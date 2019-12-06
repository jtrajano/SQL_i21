﻿CREATE PROCEDURE [dbo].[uspLGPurchaseWisePnLReport]
	@xmlParam NVARCHAR(MAX) = NULL
AS
SET QUOTED_IDENTIFIER OFF  
SET ANSI_NULLS ON  
SET NOCOUNT ON  
SET XACT_ABORT ON  
SET ANSI_WARNINGS ON
  
-- Sanitize the @xmlParam   
IF LTRIM(RTRIM(@xmlParam)) = ''   
 SET @xmlParam = NULL   
  
-- Declare the variables.
DECLARE @intAllocationDetailId AS INT = NULL
		,@intPContractDetailId AS INT = NULL
		,@intSContractDetailId AS INT = NULL
		,@intUnitMeasureId AS INT = NULL
		,@strFinancialStatus NVARCHAR(200) = NULL
		,@intDefaultCurrencyId AS INT = dbo.fnSMGetDefaultCurrency('FUNCTIONAL')
		,@strUnitMeasure AS NVARCHAR(200)
		,@strCurrency AS NVARCHAR(200)
  
-- Declare the variables for the XML parameter  
DECLARE @xmlDocumentId AS INT  
    
-- Create a table variable to hold the XML data.     
DECLARE @temp_xml_table TABLE (  
 [fieldname] NVARCHAR(50)  
 ,condition NVARCHAR(20)        
 ,[from] NVARCHAR(max)  
 ,[to] NVARCHAR(max)  
 ,[join] NVARCHAR(10)  
 ,[begingroup] NVARCHAR(50)  
 ,[endgroup] NVARCHAR(50)  
 ,[datatype] NVARCHAR(50)  
)  
  
-- Prepare the XML   
EXEC sp_xml_preparedocument @xmlDocumentId output, @xmlParam  
  
-- Insert the XML to the xml table.     
INSERT INTO @temp_xml_table  
SELECT *  
FROM OPENXML(@xmlDocumentId, 'xmlparam/filters/filter', 2)  
WITH (  
 [fieldname] nvarchar(50)  
 , condition nvarchar(20)  
 , [from] nvarchar(max)  
 , [to] nvarchar(max)  
 , [join] nvarchar(10)  
 , [begingroup] nvarchar(50)  
 , [endgroup] nvarchar(50)  
 , [datatype] nvarchar(50)  
)  
  
-- Gather the variables values from the xml table.   
SELECT @intAllocationDetailId = [from]  
FROM @temp_xml_table   
WHERE [fieldname] = 'intAllocationDetailId'  

SELECT @intPContractDetailId = [from]  
FROM @temp_xml_table   
WHERE [fieldname] = 'intPContractDetailId'  

SELECT @intSContractDetailId = [from]  
FROM @temp_xml_table   
WHERE [fieldname] = 'intSContractDetailId'  

SELECT @intUnitMeasureId = [from]  
FROM @temp_xml_table   
WHERE [fieldname] = 'intUnitMeasureId'

SELECT @strFinancialStatus = [from]  
FROM @temp_xml_table   
WHERE [fieldname] = 'strFinancialStatus'

-- Sanitize Parameters
IF (@intAllocationDetailId IS NULL)
BEGIN
	SELECT @intAllocationDetailId = intAllocationDetailId 
	FROM tblLGAllocationDetail 
	WHERE (@intPContractDetailId IS NOT NULL AND intPContractDetailId = @intPContractDetailId)
		OR (@intSContractDetailId IS NOT NULL AND intSContractDetailId = @intSContractDetailId)
END
ELSE
BEGIN
	IF (@intPContractDetailId IS NULL OR @intSContractDetailId IS NULL)
		SELECT @intPContractDetailId = intPContractDetailId
				,@intSContractDetailId = intSContractDetailId
		FROM tblLGAllocationDetail 
		WHERE intAllocationDetailId = @intAllocationDetailId
END

IF (@intUnitMeasureId IS NULL)
	SELECT @intUnitMeasureId = intSUnitMeasureId 
	FROM tblLGAllocationDetail WHERE intAllocationDetailId = @intAllocationDetailId

SELECT @strUnitMeasure = strUnitMeasure FROM tblICUnitMeasure WHERE intUnitMeasureId = @intUnitMeasureId
SELECT @strCurrency = ISNULL(strSymbol, strCurrency) FROM tblSMCurrency WHERE intCurrencyID = @intDefaultCurrencyId

SELECT 
	*
	,dblPUnitPrice = /* P-Terminal Price + P-Differential */
					dblPTerminalPrice + dblPDifferential
	,dblSUnitPrice = /* S-Terminal Price + S-Differential */
					dblSTerminalPrice + dblSDifferential
	,dblEffectiveHedgePL = /* Effective Hedge PL = Difference x Lots Contract Size */
						dblDifference * dblLotContractSize
	,dblTheoreticalHedgePL = /* Theor Hedge PL = Difference x P-Contract Qty */
						dblDifference * dblPAllocatedQty
	,dblTotalGCCost = /* Total GC Cost = Invoiced P-Value + Effective Hedge PL + Reserves A Value */
					dblInvoicedPValue + (dblDifference * dblLotContractSize) + dblReservesAValueTotal
	,dblDifferentialCheck = /* Differential Total - S-Differential */
							dblDifferentialRateTotal - dblSDifferential
	,dblEffectiveMargin = /* Total GC Cost + Invoiced S-Value */
					(dblInvoicedPValue + (dblDifference * dblLotContractSize) + dblReservesAValueTotal) + dblInvoicedSValue
	,dblEffectiveMarginRate = /* Effective Margin / S-Qty */
						((dblInvoicedPValue + (dblDifference * dblLotContractSize) + dblReservesAValueTotal) + dblInvoicedSValue)
							/ dblSAllocatedQty
	,dblHedgePLDifference = /* Effective Hedge PL - Theor Hedge PL */
							(dblDifference * dblLotContractSize) - (dblDifference * dblPAllocatedQty)
	,dblTotalToBeRecovered = /* Hedge PL Difference + Reserves A Variance */
							(dblDifference * dblLotContractSize) - (dblDifference * dblPAllocatedQty)
							+ dblReservesATotalVariance
	,strUnitMeasure = @strUnitMeasure
	,strCurrency = @strCurrency
	,strUnitCurrency = @strCurrency + '/' + @strUnitMeasure
FROM
	(SELECT 
		ALD.strAllocationDetailRefNo 
		,ALD.intPContractDetailId
		,ALD.intSContractDetailId
		,strFinancialStatus = SCS.strContractStatus + CASE WHEN ISNULL(SCD.strFinancialStatus, '') <> '' THEN '/' + ISNULL(SCD.strFinancialStatus, '') ELSE '' END
		,strPContractNumberSeq = PCH.strContractNumber + '/' + CAST(PCD.intContractSeq AS NVARCHAR(10))
		,strSContractNumberSeq = SCH.strContractNumber + '/' + CAST(SCD.intContractSeq AS NVARCHAR(10))
		,strProductType = CA.strDescription 
		,strPClient = V.strName
		,strSClient = C.strName
		,dblPAllocatedQty = dbo.fnCalculateQtyBetweenUOM (AUOM.intItemUOMId, ToUOM.intItemUOMId, ALD.dblPAllocatedQty)
		,dblSAllocatedQty = dbo.fnCalculateQtyBetweenUOM (AUOM.intItemUOMId, ToUOM.intItemUOMId, ALD.dblSAllocatedQty)
		,dblPTerminalPrice = /* P-Terminal Price */
							ISNULL(dbo.fnCalculateCostBetweenUOM(PCD.intPriceItemUOMId, ToUOM.intItemUOMId, PCD.dblFutures) / ISNULL(PCUR.intCent, 1), 0)
		,dblSTerminalPrice = /* S-Terminal Price */
							ISNULL(dbo.fnCalculateCostBetweenUOM(SCD.intPriceItemUOMId, ToUOM.intItemUOMId, SCD.dblFutures) / ISNULL(SCUR.intCent, 1), 0)
		,dblPDifferential = /* P-Differential */
							ISNULL(dbo.fnCalculateCostBetweenUOM(SCD.intPriceItemUOMId, ToUOM.intItemUOMId, PCD.dblBasis) / ISNULL(PCUR.intCent, 1), 0)
		,dblSDifferential = /* S-Differential */
							ISNULL(dbo.fnCalculateCostBetweenUOM(SCD.intPriceItemUOMId, ToUOM.intItemUOMId, SCD.dblBasis) / ISNULL(SCUR.intCent, 1), 0)
		,dblInvoicedPValue = /* Invoiced P-Value */
							ISNULL(VCHR.dblTotalCost, 0) * -1
		,dblInvoicedSValue = /* Invoiced S-Value */
							ISNULL(INVC.dblTotalCost, 0)
		,dblDifference = /* Difference = P-Terminal Price - S-Terminal Price */
							(dbo.fnCalculateCostBetweenUOM(PCD.intPriceItemUOMId, ToUOM.intItemUOMId, PCD.dblFutures) / ISNULL(PCUR.intCent, 1))
							- (dbo.fnCalculateCostBetweenUOM(SCD.intPriceItemUOMId, ToUOM.intItemUOMId, SCD.dblFutures) / ISNULL(SCUR.intCent, 1))
		,dblLots = /* Lots */
					PCD.dblNoOfLots
		,dblLotContractSize = /* Lots Contract Size = Lots x Contract Size*/
							PCD.dblNoOfLots * dbo.fnCTConvertQuantityToTargetItemUOM(I.intItemId, FM.intUnitMeasureId, @intUnitMeasureId, FM.dblContractSize)
		,dblReservesARateTotal = RA.dblReservesARateTotal
		,dblReservesAValueTotal = RA.dblReservesAValueTotal
		,dblReservesBRateTotal = RB.dblReservesBRateTotal
		,dblReservesBValueTotal = RB.dblReservesBValueTotal
		,dblDifferentialRateTotal = /* P-Differential + Reserves A Total + Reserves B Total */
								(dbo.fnCalculateCostBetweenUOM(SCD.intPriceItemUOMId, ToUOM.intItemUOMId, PCD.dblBasis) / ISNULL(PCUR.intCent, 1))
								+ ISNULL(RA.dblReservesARateTotal, 0) 
								+ ISNULL(RB.dblReservesBRateTotal, 0) 
		,dblTonnageCheck = /* P-Qty - S-Qty */
						dbo.fnCalculateQtyBetweenUOM (AUOM.intItemUOMId, ToUOM.intItemUOMId, ALD.dblPAllocatedQty) 
						- dbo.fnCalculateQtyBetweenUOM (AUOM.intItemUOMId, ToUOM.intItemUOMId, ALD.dblSAllocatedQty)
		,dblTotalMargin = RB.dblReservesBValueTotal * -1
		,dblReservesATotalVariance = RA.dblReservesAVarianceTotal
	FROM tblLGAllocationDetail ALD
		LEFT JOIN tblCTContractDetail PCD ON ALD.intPContractDetailId = PCD.intContractDetailId
		LEFT JOIN tblCTContractHeader PCH ON PCH.intContractHeaderId = PCD.intContractHeaderId
		LEFT JOIN tblICItem I ON I.intItemId = PCD.intItemId
		LEFT JOIN tblICCommodity COM ON COM.intCommodityId = PCH.intCommodityId
		LEFT JOIN tblICCommodityAttribute CA ON CA.intCommodityAttributeId = I.intProductTypeId
		LEFT JOIN tblICCommodityAttribute OG ON OG.intCommodityAttributeId = I.intOriginId
		LEFT JOIN tblEMEntity V ON V.intEntityId = PCH.intEntityId
		LEFT JOIN tblRKFutureMarket FM ON FM.intFutureMarketId = PCD.intFutureMarketId
		LEFT JOIN tblCTContractDetail SCD ON ALD.intSContractDetailId = SCD.intContractDetailId
		LEFT JOIN tblCTContractHeader SCH ON SCH.intContractHeaderId = SCD.intContractHeaderId
		LEFT JOIN tblCTContractStatus SCS ON SCS.intContractStatusId = SCD.intContractStatusId
		LEFT JOIN tblEMEntity C ON C.intEntityId = SCH.intEntityId
		LEFT JOIN tblICItemUOM AUOM ON AUOM.intItemId = I.intItemId AND AUOM.intUnitMeasureId = ALD.intSUnitMeasureId
		LEFT JOIN tblSMCurrency PCUR ON PCUR.intCurrencyID = PCD.intBasisCurrencyId
		LEFT JOIN tblSMCurrency SCUR ON SCUR.intCurrencyID = SCD.intBasisCurrencyId
		OUTER APPLY (SELECT	TOP 1 intItemUOMId, dblUnitQty FROM	dbo.tblICItemUOM 
						WHERE intItemId = I.intItemId AND intUnitMeasureId = @intUnitMeasureId) ToUOM
		/* Purchase Value */
		OUTER APPLY 
			(SELECT 
				dblTotalCost = SUM(CASE WHEN BL.intTransactionType IN (3, 11) 
										THEN (BLD.dblTotal * -1) 
										ELSE BLD.dblTotal END)
			FROM tblAPBillDetail BLD 
				INNER JOIN tblAPBill BL ON BL.intBillId = BLD.intBillId
				INNER JOIN tblICItem BLDI ON BLDI.intItemId = BLD.intItemId
			WHERE BL.ysnPosted = 1 
				AND BLD.intContractDetailId = PCD.intContractDetailId
				AND BLDI.strType <> 'Other Charge') VCHR
		/* Sales Value */
		OUTER APPLY 
			(SELECT 
				dblTotalCost = SUM(CASE WHEN IV.strTransactionType IN ('Credit Memo') 
										THEN (IVD.dblTotal * -1) 
										ELSE IVD.dblTotal END)
			FROM tblARInvoiceDetail IVD 
				INNER JOIN tblARInvoice IV ON IV.intInvoiceId = IVD.intInvoiceId
				INNER JOIN tblICItem IVDI ON IVDI.intItemId = IVD.intItemId
			WHERE IV.ysnPosted = 1 
				AND IVD.intContractDetailId = SCD.intContractDetailId
				AND IVDI.strType <> 'Other Charge') INVC
		/* Reserves A */
		OUTER APPLY 
			(SELECT dblReservesARateTotal = SUM(ISNULL(CC.dblRate, 0))
					,dblReservesAValueTotal = SUM(ISNULL(CC.dblAmount, 0))
					,dblReservesAVarianceTotal = SUM(CASE WHEN (ISNULL(VCHR.dblTotal, 0) + ISNULL(INVC.dblTotal, 0)) < 0 
										THEN (ISNULL(VCHR.dblTotal, 0) + ISNULL(INVC.dblTotal, 0)) - ISNULL(CC.dblAmount, 0) 
										ELSE 0 END)
			FROM tblICItem I 
				OUTER APPLY (SELECT CC.intContractDetailId
						,dblRate = CASE WHEN CC.strCostMethod = 'Per Unit' THEN 
											dbo.fnCalculateCostBetweenUOM(CC.intItemUOMId,ToUOM.intItemUOMId,CC.dblRate)
										ELSE CC.dblRate END / ISNULL(CCUR.intCent, 1)
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
					 WHERE CC.intItemId = I.intItemId AND ALD.intAllocationDetailId = @intAllocationDetailId) CC
				OUTER APPLY (SELECT dblTotal = SUM(BLD.dblTotal) 
					FROM tblAPBillDetail BLD 
						INNER JOIN tblAPBill BL ON BL.intBillId = BLD.intBillId
						INNER JOIN tblICItem BLDI ON BLDI.intItemId = BLD.intItemId
					WHERE BL.ysnPosted = 1
						AND BLD.intContractDetailId = CC.intContractDetailId 
						AND BLD.intItemId = I.intItemId 
						AND BLDI.strType = 'Other Charge'
					) VCHR
				OUTER APPLY (SELECT dblTotal = SUM(IVD.dblTotal) 
					FROM tblARInvoiceDetail IVD 
						INNER JOIN tblARInvoice IV ON IV.intInvoiceId = IVD.intInvoiceId
						INNER JOIN tblICItem IVDI ON IVDI.intItemId = IVD.intItemId
					WHERE IV.ysnPosted = 1
						AND IVD.intContractDetailId = CC.intContractDetailId 
						AND IVD.intItemId = I.intItemId 
						AND IVDI.strType = 'Other Charge'
					) INVC
			WHERE I.intCategoryId = (SELECT TOP 1 intPnLReportReserveACategoryId FROM tblLGCompanyPreference)
		) RA 
		/* Reserves B */
		OUTER APPLY 
			(SELECT dblReservesBRateTotal = SUM(ISNULL(CC.dblRate, 0))
					,dblReservesBValueTotal = SUM(ISNULL(CC.dblAmount, 0)) * -1
			FROM tblICItem I 
			OUTER APPLY (SELECT CC.intContractDetailId
							,dblRate = CASE WHEN CC.strCostMethod = 'Per Unit' THEN 
											dbo.fnCalculateCostBetweenUOM(CC.intItemUOMId,ToUOM.intItemUOMId,CC.dblRate)
										ELSE CC.dblRate END / ISNULL(CCUR.intCent, 1)
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
					 WHERE CC.intItemId = I.intItemId AND ALD.intAllocationDetailId = @intAllocationDetailId) CC
			WHERE I.intCategoryId = (SELECT TOP 1 intPnLReportReserveBCategoryId FROM tblLGCompanyPreference)
		) RB 
	WHERE ALD.strAllocationDetailRefNo IS NOT NULL AND ALD.intAllocationDetailId = @intAllocationDetailId
) PNL
