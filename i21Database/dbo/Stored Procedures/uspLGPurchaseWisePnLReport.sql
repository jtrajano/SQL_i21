CREATE PROCEDURE [dbo].[uspLGPurchaseWisePnLReport]
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
DECLARE @strAllocationDetailRefNo AS NVARCHAR(100)
		,@strPContractNumberSeq AS NVARCHAR(100)
		,@strSContractNumberSeq AS NVARCHAR(100)
		,@strUnitMeasure AS NVARCHAR(200)
		,@strWeightUnitMeasure AS NVARCHAR(200)
		,@strFinancialStatus NVARCHAR(200) = NULL
		,@intAllocationDetailId AS INT = NULL
		,@intPContractDetailId AS INT = NULL
		,@intSContractDetailId AS INT = NULL
		,@intUnitMeasureId AS INT = NULL
		,@intWeightUnitMeasureId AS INT = NULL
		,@intDefaultCurrencyId AS INT = dbo.fnSMGetDefaultCurrency('FUNCTIONAL')
		,@strCurrency AS NVARCHAR(200)
		,@strCompanyName NVARCHAR(100)
		,@strCompanyAddress NVARCHAR(100)
		,@strCity NVARCHAR(25)
		,@strState NVARCHAR(50)
		,@strZip NVARCHAR(12)
		,@strCountry NVARCHAR(25)
  
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
SELECT @strAllocationDetailRefNo = [from]  
FROM @temp_xml_table   
WHERE [fieldname] = 'strAllocationDetailRefNo'  

SELECT @strPContractNumberSeq = [from]  
FROM @temp_xml_table   
WHERE [fieldname] = 'strPContractNumberSeq'  

SELECT @strSContractNumberSeq = [from]  
FROM @temp_xml_table   
WHERE [fieldname] = 'strSContractNumberSeq'  

SELECT @strUnitMeasure = [from]  
FROM @temp_xml_table   
WHERE [fieldname] = 'strUnitMeasure'

SELECT @strWeightUnitMeasure = [from]  
FROM @temp_xml_table   
WHERE [fieldname] = 'strWeightUnitMeasure'

--Extract Parameters
SELECT @intAllocationDetailId = intAllocationDetailId FROM tblLGAllocationDetail WHERE strAllocationDetailRefNo = @strAllocationDetailRefNo
SELECT @intUnitMeasureId = intUnitMeasureId FROM tblICUnitMeasure WHERE strUnitMeasure = @strUnitMeasure
SELECT @intWeightUnitMeasureId = intUnitMeasureId FROM tblICUnitMeasure WHERE strUnitMeasure = @strWeightUnitMeasure

--Extract Purchase Contract Detail Id
IF (ISNULL(@strPContractNumberSeq, '') <> '')
BEGIN
	SELECT @intPContractDetailId = CD.intContractDetailId 
	FROM tblCTContractDetail CD 
		LEFT JOIN tblCTContractHeader CH ON CD.intContractHeaderId = CH.intContractHeaderId
		WHERE CH.intContractTypeId = 1
			AND CH.strContractNumber = SUBSTRING(@strPContractNumberSeq, 1, LEN(@strPContractNumberSeq) - CHARINDEX('/', REVERSE(@strPContractNumberSeq)))
			AND CD.intContractSeq = CAST(RIGHT(@strPContractNumberSeq, CHARINDEX('/', REVERSE(@strPContractNumberSeq)) - 1) AS INT)
END

--Extract Sales Contract Detail Id
IF (ISNULL(@strSContractNumberSeq, '') <> '')
BEGIN
	SELECT @intSContractDetailId = CD.intContractDetailId 
	FROM tblCTContractDetail CD 
		LEFT JOIN tblCTContractHeader CH ON CD.intContractHeaderId = CH.intContractHeaderId
		WHERE CH.intContractTypeId = 2
			AND CH.strContractNumber = SUBSTRING(@strSContractNumberSeq, 1, LEN(@strSContractNumberSeq) - CHARINDEX('/', REVERSE(@strSContractNumberSeq)))
			AND CD.intContractSeq = CAST(RIGHT(@strSContractNumberSeq, CHARINDEX('/', REVERSE(@strSContractNumberSeq)) - 1) AS INT)
END

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
	SELECT @intUnitMeasureId = UOM.intUnitMeasureId
	FROM tblLGAllocationDetail ALD 
		INNER JOIN tblCTContractDetail SCD ON ALD.intSContractDetailId = SCD.intContractDetailId
		INNER JOIN tblICItemUOM UOM ON UOM.intItemUOMId = SCD.intPriceItemUOMId
	WHERE intAllocationDetailId = @intAllocationDetailId

IF (@intWeightUnitMeasureId IS NULL)
	SELECT @intUnitMeasureId = AL.intWeightUnitMeasureId 
	FROM tblLGAllocationDetail ALD INNER JOIN tblLGAllocationHeader AL
		ON ALD.intAllocationHeaderId = AL.intAllocationHeaderId
	 WHERE ALD.intAllocationDetailId = @intAllocationDetailId


SELECT @strUnitMeasure = CASE WHEN ISNULL(strSymbol, '') <> '' THEN strSymbol ELSE strUnitMeasure END
FROM tblICUnitMeasure WHERE intUnitMeasureId = @intUnitMeasureId

SELECT @strWeightUnitMeasure = CASE WHEN ISNULL(strSymbol, '') <> '' THEN strSymbol ELSE strUnitMeasure END
FROM tblICUnitMeasure WHERE intUnitMeasureId = @intWeightUnitMeasureId

SELECT @strCurrency = CASE WHEN ISNULL(strSymbol, '') <> '' THEN strSymbol ELSE strCurrency END
FROM tblSMCurrency WHERE intCurrencyID = @intDefaultCurrencyId

SELECT TOP 1 
	@strCompanyName = strCompanyName
	,@strCompanyAddress = strAddress
	,@strCity = strCity
	,@strState = strState
	,@strZip = strZip
	,@strCountry = strCountry
FROM tblSMCompanySetup

SELECT 
	*
	,dblPUnitPrice = /* P-Terminal Price + P-Differential */
					dblPTerminalPrice + dblPDifferential
	,dblSUnitPrice = /* S-Terminal Price + S-Differential */
					dblSTerminalPrice + dblSDifferential
	,dblEffectiveHedgePL = /* Effective Hedge PL = Difference x Lots Contract Size */
						dblDifferenceInFC * dblLotContractSizeInPriceUOM
	,dblTheoreticalHedgePL = /* Theor Hedge PL = Difference x P-Contract Qty */
						dblDifferenceInFC * dblPAllocatedQtyInPriceUOM
	,dblTotalGCCost = /* Total GC Cost = Invoiced P-Value + Effective Hedge PL + Reserves A Value */
					dblInvoicedPValue + (dblDifferenceInFC * dblLotContractSizeInPriceUOM) + dblReservesAValueTotal
	,dblDifferentialCheck = /* Differential Total - S-Differential */
							dblDifferentialRateTotal - dblSDifferential
	,dblEffectiveMargin = /* Total GC Cost + Invoiced S-Value */
					(dblInvoicedPValue + (dblDifferenceInFC * dblLotContractSizeInPriceUOM) + dblReservesAValueTotal) + dblInvoicedSValue
	,dblEffectiveMarginRate = /* Effective Margin / S-Qty */
						((dblInvoicedPValue + (dblDifferenceInFC * dblLotContractSizeInPriceUOM) + dblReservesAValueTotal) + dblInvoicedSValue)
							/ dblSAllocatedQtyInResUOM
	,dblHedgePLDifference = /* Effective Hedge PL - Theor Hedge PL */
							(dblDifferenceInFC * dblLotContractSizeInPriceUOM) - (dblDifferenceInFC * dblPAllocatedQtyInPriceUOM)
	,dblTotalToBeRecovered = /* Hedge PL Difference + Reserves A Variance */
							(dblDifferenceInFC * dblLotContractSizeInPriceUOM) - (dblDifferenceInFC * dblPAllocatedQtyInPriceUOM)
							+ dblReservesATotalVariance
	,strUnitMeasure = @strUnitMeasure
	,strWeightUnitMeasure = @strWeightUnitMeasure
	,strCurrency = @strCurrency
	,strUnitCurrency = @strCurrency + '/' + @strUnitMeasure
	,intAllocationDetailId = @intAllocationDetailId
	,intUnitMeasureId = @intUnitMeasureId
	,intWeightUnitMeasureId = @intWeightUnitMeasureId
	,strCompanyName = @strCompanyName
	,strCompanyAddress = @strCompanyAddress
	,strCompanyCountry = @strCountry 
	,strCityStateZip = @strCity + ', ' + @strState + ', ' + @strZip + ','
FROM
	(SELECT 
		ALD.strAllocationDetailRefNo 
		,ALD.intPContractDetailId
		,ALD.intSContractDetailId
		,strFinancialStatus = SCS.strContractStatus + CASE WHEN ISNULL(SCD.strFinancialStatus, '') <> '' THEN '/' + ISNULL(SCD.strFinancialStatus, '') ELSE '' END
		,strPContractNumberSeq = PCH.strContractNumber + '/' + CAST(PCD.intContractSeq AS NVARCHAR(10))
		,strSContractNumberSeq = SCH.strContractNumber + '/' + CAST(SCD.intContractSeq AS NVARCHAR(10))
		,strItemNo = I.strItemNo
		,strItemDescription = I.strDescription
		,strOrigin = OG.strDescription
		,strProductType = CA.strDescription 
		,strCommodity = COM.strCommodityCode
		,strPClient = V.strName
		,strSClient = C.strName
		,dblPAllocatedQty = ISNULL(VCHR.dblNetShippedWt, dbo.fnCalculateQtyBetweenUOM (PUOM.intItemUOMId, ToWUOM.intItemUOMId, ALD.dblPAllocatedQty))
		,dblSAllocatedQty = ISNULL(INVC.dblNetShippedWt, dbo.fnCalculateQtyBetweenUOM (SUOM.intItemUOMId, ToWUOM.intItemUOMId, ALD.dblSAllocatedQty))
		,dblPAllocatedQtyInPriceUOM = ISNULL(dbo.fnCalculateQtyBetweenUOM (ToWUOM.intItemUOMId, PCD.intPriceItemUOMId, VCHR.dblNetShippedWt), 
											dbo.fnCalculateQtyBetweenUOM (PUOM.intItemUOMId, PCD.intPriceItemUOMId, ALD.dblPAllocatedQty))
		,dblSAllocatedQtyInPriceUOM = ISNULL(dbo.fnCalculateQtyBetweenUOM (ToWUOM.intItemUOMId, SCD.intPriceItemUOMId, INVC.dblNetShippedWt), 
										dbo.fnCalculateQtyBetweenUOM (SUOM.intItemUOMId, SCD.intPriceItemUOMId, ALD.dblSAllocatedQty))
		,dblSAllocatedQtyInResUOM = ISNULL(dbo.fnCalculateQtyBetweenUOM (ToWUOM.intItemUOMId, ToUOM.intItemUOMId, INVC.dblNetShippedWt), 
										dbo.fnCalculateQtyBetweenUOM (SUOM.intItemUOMId, ToUOM.intItemUOMId, ALD.dblSAllocatedQty))
		,dblPTerminalPrice = /* P-Terminal Price */
							ISNULL(PCD.dblFutures, 0)
		,dblSTerminalPrice = /* S-Terminal Price */
							ISNULL(SCD.dblFutures, 0)
		,dblPDifferential = /* P-Differential */
							ISNULL(PCD.dblBasis, 0)
		,dblSDifferential = /* S-Differential */
							ISNULL(SCD.dblBasis, 0)
		,dblInvoicedPValue = /* Invoiced P-Value */
							ISNULL(VCHR.dblTotalCost, 0) * -1
		,dblInvoicedSValue = /* Invoiced S-Value */
							ISNULL(INVC.dblTotalCost, 0)
		,dblDifference = /* Difference = P-Terminal Price - S-Terminal Price */
							ISNULL(PCD.dblFutures, 0) - ISNULL(SCD.dblFutures, 0)
		,dblDifferenceInFC = (ISNULL(PCD.dblFutures, 0) / ISNULL(PCUR.intCent, 1)) - (ISNULL(SCD.dblFutures, 0) / ISNULL(SCUR.intCent, 1))
		,dblLots = /* Lots */
					PCD.dblNoOfLots
		,dblLotContractSize = /* Lots Contract Size = Lots x Contract Size*/
							PCD.dblNoOfLots * dbo.fnCTConvertQuantityToTargetItemUOM(I.intItemId, FM.intUnitMeasureId, @intWeightUnitMeasureId, FM.dblContractSize)
		,dblLotContractSizeInPriceUOM = PCD.dblNoOfLots * dbo.fnCTConvertQuantityToTargetItemUOM(I.intItemId, FM.intUnitMeasureId, IUOM.intUnitMeasureId, FM.dblContractSize)
		,dblReservesARateTotal = RA.dblReservesARateTotal
		,dblReservesAValueTotal = RA.dblReservesAValueTotal * -1
		,dblReservesBRateTotal = RB.dblReservesBRateTotal
		,dblReservesBValueTotal = RB.dblReservesBValueTotal * -1
		,dblDifferentialRateTotal = /* P-Differential + Reserves A Total + Reserves B Total */
								ISNULL(PCD.dblBasis, 0)
								+ ISNULL(RA.dblReservesARateTotal, 0) 
								+ ISNULL(RB.dblReservesBRateTotal, 0) 
		,dblTonnageCheck = /* P-Qty - S-Qty */
						ISNULL(VCHR.dblNetShippedWt, dbo.fnCalculateQtyBetweenUOM (PUOM.intItemUOMId, ToWUOM.intItemUOMId, ALD.dblPAllocatedQty))
						- ISNULL(INVC.dblNetShippedWt, dbo.fnCalculateQtyBetweenUOM (SUOM.intItemUOMId, ToWUOM.intItemUOMId, ALD.dblSAllocatedQty))
		,dblTotalMargin = /* Reserves B Total in Absolute Value */ 
							ABS(RB.dblReservesBValueTotal)
		,dblReservesATotalVariance = RA.dblReservesAVarianceTotal * -1
		,blbHeaderLogo = dbo.fnSMGetCompanyLogo('Header')
		,blbFooterLogo = dbo.fnSMGetCompanyLogo('Footer')
		,blbFullHeaderLogo = dbo.fnSMGetCompanyLogo('FullHeaderLogo')
		,blbFullFooterLogo = dbo.fnSMGetCompanyLogo('FullFooterLogo')
		,ysnFullHeaderLogo = CASE WHEN CP.ysnFullHeaderLogo = 1 THEN 'true' else 'false' end
		,intReportLogoHeight = ISNULL(CP.intReportLogoHeight,0)
		,intReportLogoWidth = ISNULL(CP.intReportLogoWidth,0)
		,strPriceUnit = PUM.strUnitMeasure
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
		LEFT JOIN tblICItemUOM SUOM ON SUOM.intItemId = I.intItemId AND SUOM.intUnitMeasureId = ALD.intSUnitMeasureId
		LEFT JOIN tblICItemUOM PUOM ON PUOM.intItemId = I.intItemId AND PUOM.intUnitMeasureId = ALD.intPUnitMeasureId
		LEFT JOIN tblSMCurrency PCUR ON PCUR.intCurrencyID = PCD.intBasisCurrencyId
		LEFT JOIN tblSMCurrency SCUR ON SCUR.intCurrencyID = SCD.intBasisCurrencyId
		LEFT JOIN tblICItemUOM IUOM ON PCD.intPriceItemUOMId = IUOM.intItemUOMId
		LEFT JOIN tblICUnitMeasure PUM ON PUM.intUnitMeasureId = IUOM.intUnitMeasureId
		OUTER APPLY (SELECT	TOP 1 intItemUOMId, dblUnitQty FROM	dbo.tblICItemUOM 
						WHERE intItemId = I.intItemId AND intUnitMeasureId = @intUnitMeasureId) ToUOM
		OUTER APPLY (SELECT	TOP 1 intItemUOMId, dblUnitQty FROM	dbo.tblICItemUOM 
						WHERE intItemId = I.intItemId AND intUnitMeasureId = @intWeightUnitMeasureId) ToWUOM
		OUTER APPLY (SELECT TOP 1 ysnFullHeaderLogo, intReportLogoHeight, intReportLogoWidth
							,intPnLReportReserveACategoryId, intPnLReportReserveBCategoryId 
						FROM tblLGCompanyPreference) CP
		/* Purchase Value */
		OUTER APPLY 
			(SELECT 
				dblTotalCost = SUM(BLD.dblTotal)
				,dblNetShippedWt = SUM(BLD.dblQtyReceived)
			FROM 
				(SELECT bl.intBillId, bld.intItemId, bld.intContractDetailId, bl.ysnPosted, bl.intTransactionType
					,dblTotal = bld.dblTotal * CASE WHEN bl.intTransactionType IN (3, 11) THEN -1 ELSE 1 END
					,dblQtyReceived = dbo.fnCalculateQtyBetweenUOM (intUnitOfMeasureId, ToWUOM.intItemUOMId, dblQtyReceived) 
									* CASE WHEN bl.intTransactionType IN (3, 11) THEN -1 ELSE 1 END
					FROM tblAPBillDetail bld
					INNER JOIN tblAPBill bl on bl.intBillId = bld.intBillId) BLD
				INNER JOIN tblICItem BLDI ON BLDI.intItemId = BLD.intItemId
			WHERE (BLD.ysnPosted = 1 OR BLD.intTransactionType = 11) 
				AND BLD.intContractDetailId = PCD.intContractDetailId
				AND BLDI.intCategoryId NOT IN (CP.intPnLReportReserveACategoryId, CP.intPnLReportReserveBCategoryId)) VCHR
		/* Sales Value */
		OUTER APPLY 
			(SELECT 
				dblTotalCost = SUM(dblTotal)
				,dblNetShippedWt = SUM(dblQtyShipped)
			FROM 
				(SELECT ivd.intInvoiceId, ivd.intItemId, ivd.intContractDetailId, iv.ysnPosted
					,dblTotal = dblTotal * CASE WHEN iv.strTransactionType IN ('Credit Memo') THEN -1 ELSE 1 END
					,dblQtyShipped = dbo.fnCalculateQtyBetweenUOM (intItemUOMId, ToWUOM.intItemUOMId, dblQtyShipped) 
									* CASE WHEN iv.strTransactionType IN ('Credit Memo') THEN -1 ELSE 1 END
					FROM tblARInvoiceDetail ivd
					INNER JOIN tblARInvoice iv on iv.intInvoiceId = ivd.intInvoiceId) IVD 
				INNER JOIN tblICItem IVDI ON IVDI.intItemId = IVD.intItemId
			WHERE IVD.ysnPosted = 1 
				AND IVD.intContractDetailId = SCD.intContractDetailId
				AND IVDI.intCategoryId NOT IN (CP.intPnLReportReserveACategoryId, CP.intPnLReportReserveBCategoryId)) INVC
		/* Reserves A */
		OUTER APPLY 
			(SELECT dblReservesARateTotal = SUM(ISNULL(CC.dblRate, 0))
					,dblReservesAValueTotal = SUM(CASE WHEN (ISNULL(VCHR.dblTotal, 0) + ISNULL(INVC.dblTotal, 0)) <> 0 
												THEN (ISNULL(VCHR.dblTotal, 0) + ISNULL(INVC.dblTotal, 0))
												ELSE ISNULL(CC.dblAmount, 0) END)
					,dblReservesAVarianceTotal = SUM(CASE WHEN (ISNULL(VCHR.dblTotal, 0) + ISNULL(INVC.dblTotal, 0)) <> 0 
										THEN (ISNULL(VCHR.dblTotal, 0) + ISNULL(INVC.dblTotal, 0)) - ISNULL(CC.dblAmount, 0) 
										ELSE 0 END)
			FROM tblICItem I 
				OUTER APPLY (SELECT intPContractDetailId
								,intSContractDetailId
								,dblRate = CASE WHEN CC.strCostMethod = 'Per Unit' THEN 
													dbo.fnCalculateCostBetweenUOM(CC.intItemUOMId,CToUOM.intItemUOMId,CC.dblRate)
												ELSE CC.dblRate END
								,dblAmount = CASE WHEN CC.strCostMethod = 'Per Unit' THEN 
													dbo.fnCalculateQtyBetweenUOM(CD.intItemUOMId,ToUOM.intItemUOMId,CD.dblQuantity) 
													* dbo.fnCalculateCostBetweenUOM(CC.intItemUOMId,TonUOM.intItemUOMId,CC.dblRate) / ISNULL(CCUR.intCent, 1)
												WHEN CC.strCostMethod = 'Amount' THEN
													CC.dblRate
												WHEN CC.strCostMethod = 'Per Container'	THEN
													CC.dblRate * (CASE WHEN ISNULL(CD.intNumberOfContainers,1) = 0 THEN 1 ELSE ISNULL(CD.intNumberOfContainers,1) END)
												WHEN CC.strCostMethod = 'Percentage' THEN 
													dbo.fnCalculateQtyBetweenUOM(CD.intItemUOMId,ToUOM.intItemUOMId,CD.dblQuantity) * CD.dblCashPrice * CC.dblRate/100
												END
						FROM tblCTContractCost CC
							LEFT JOIN tblCTContractDetail CD ON CD.intContractDetailId = CC.intContractDetailId
							LEFT JOIN tblLGAllocationDetail ALD ON CC.intContractDetailId = ALD.intSContractDetailId
							LEFT JOIN tblSMCurrency CCUR ON CCUR.intCurrencyID = CC.intCurrencyId
							LEFT JOIN tblICItemUOM CDUOM ON CDUOM.intItemUOMId = CD.intPriceItemUOMId
							OUTER APPLY (SELECT	TOP 1 intItemUOMId, dblUnitQty FROM	dbo.tblICItemUOM 
										WHERE intItemId = CC.intItemId AND intUnitMeasureId = CDUOM.intUnitMeasureId) CToUOM
							OUTER APPLY (SELECT	TOP 1 intItemUOMId, dblUnitQty FROM	dbo.tblICItemUOM 
									WHERE intItemId = CC.intItemId AND intUnitMeasureId = @intUnitMeasureId) TonUOM
					WHERE CC.intItemId = I.intItemId AND ALD.intAllocationDetailId = @intAllocationDetailId) CC
				OUTER APPLY (SELECT dblTotal = SUM(BLD.dblTotal) 
					FROM tblAPBillDetail BLD 
						INNER JOIN tblAPBill BL ON BL.intBillId = BLD.intBillId
						INNER JOIN tblICItem BLDI ON BLDI.intItemId = BLD.intItemId
					WHERE BL.ysnPosted = 1
						AND BLD.intContractDetailId IN (CC.intPContractDetailId, CC.intSContractDetailId) 
						AND BLD.intItemId = I.intItemId 
						AND BLDI.intCategoryId IN (CP.intPnLReportReserveACategoryId)
					) VCHR
				OUTER APPLY (SELECT dblTotal = SUM(IVD.dblTotal) 
					FROM tblARInvoiceDetail IVD 
						INNER JOIN tblARInvoice IV ON IV.intInvoiceId = IVD.intInvoiceId
						INNER JOIN tblICItem IVDI ON IVDI.intItemId = IVD.intItemId
					WHERE IV.ysnPosted = 1
						AND IVD.intContractDetailId IN (CC.intPContractDetailId, CC.intSContractDetailId)
						AND IVD.intItemId = I.intItemId 
						AND IVDI.intCategoryId IN (CP.intPnLReportReserveACategoryId)
					) INVC
			WHERE I.intCategoryId = CP.intPnLReportReserveACategoryId
		) RA 
		/* Reserves B */
		OUTER APPLY 
			(SELECT dblReservesBRateTotal = SUM(ISNULL(CC.dblRate, 0))
					,dblReservesBValueTotal = SUM(ISNULL(CC.dblAmount, 0)) * -1
			FROM tblICItem I 
			OUTER APPLY (SELECT intPContractDetailId
							,intSContractDetailId
							,dblRate = CASE WHEN CC.strCostMethod = 'Per Unit' THEN 
											dbo.fnCalculateCostBetweenUOM(CC.intItemUOMId,CToUOM.intItemUOMId,CC.dblRate)
										ELSE CC.dblRate END
							,dblAmount = CASE WHEN CC.strCostMethod = 'Per Unit' THEN 
												dbo.fnCalculateQtyBetweenUOM(CD.intItemUOMId,ToUOM.intItemUOMId,CD.dblQuantity) 
												* dbo.fnCalculateCostBetweenUOM(CC.intItemUOMId,TonUOM.intItemUOMId,CC.dblRate) / ISNULL(CCUR.intCent, 1)
											WHEN CC.strCostMethod = 'Amount' THEN
												CC.dblRate
											WHEN CC.strCostMethod = 'Per Container'	THEN
												CC.dblRate * (CASE WHEN ISNULL(CD.intNumberOfContainers,1) = 0 THEN 1 ELSE ISNULL(CD.intNumberOfContainers,1) END)
											WHEN CC.strCostMethod = 'Percentage' THEN 
												dbo.fnCalculateQtyBetweenUOM(CD.intItemUOMId,ToUOM.intItemUOMId,CD.dblQuantity) * CD.dblCashPrice * CC.dblRate/100
											END
						FROM tblCTContractCost CC
							LEFT JOIN tblCTContractDetail CD ON CD.intContractDetailId = CC.intContractDetailId
							LEFT JOIN tblLGAllocationDetail ALD ON CC.intContractDetailId = ALD.intSContractDetailId
							LEFT JOIN tblSMCurrency CCUR ON CCUR.intCurrencyID = CC.intCurrencyId
							LEFT JOIN tblICItemUOM CDUOM ON CDUOM.intItemUOMId = CD.intPriceItemUOMId
							OUTER APPLY (SELECT	TOP 1 intItemUOMId, dblUnitQty FROM	dbo.tblICItemUOM 
									WHERE intItemId = CC.intItemId AND intUnitMeasureId = CDUOM.intUnitMeasureId) CToUOM
							OUTER APPLY (SELECT	TOP 1 intItemUOMId, dblUnitQty FROM	dbo.tblICItemUOM 
									WHERE intItemId = CC.intItemId AND intUnitMeasureId = @intUnitMeasureId) TonUOM
					 WHERE CC.intItemId = I.intItemId AND ALD.intAllocationDetailId = @intAllocationDetailId) CC
			WHERE I.intCategoryId = CP.intPnLReportReserveBCategoryId
		) RB 
	WHERE ALD.strAllocationDetailRefNo IS NOT NULL AND ALD.intAllocationDetailId = @intAllocationDetailId
) PNL

GO