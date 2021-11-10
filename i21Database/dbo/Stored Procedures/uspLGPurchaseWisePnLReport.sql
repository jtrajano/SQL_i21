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

SELECT @intUnitMeasureId = FM.intUnitMeasureId
FROM tblLGAllocationDetail ALD
	INNER JOIN tblCTContractDetail PCD ON PCD.intContractDetailId = ALD.intPContractDetailId
	INNER JOIN tblRKFutureMarket FM ON FM.intFutureMarketId = PCD.intFutureMarketId
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
							/ dblSAllocatedQty
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
	,strCityStateZip = CASE WHEN (@strCity = '') THEN '' ELSE @strCity + ', ' END 
						+ CASE WHEN (@strState = '') THEN '' ELSE @strState + ', ' END 
						+ @strZip + CASE WHEN (@strCity = '' AND @strState = '' AND @strZip = '') THEN '' ELSE ',' END
FROM
	(SELECT 
		ALD.strAllocationDetailRefNo 
		,ALD.intPContractDetailId
		,ALD.intSContractDetailId
		,strFinancialStatus = CASE WHEN PCD.ysnFinalPNL = 1 THEN 'Final P&L Created'
						WHEN PCD.ysnProvisionalPNL = 1 THEN 'Provisional P&L Created'
						WHEN BD.intContractDetailId IS NOT NULL THEN 'Purchase Invoice Received' 
						WHEN PCD.strFinancialStatus IS NOT NULL THEN PCD.strFinancialStatus 
						ELSE '' END
		,strPContractNumberSeq = PCH.strContractNumber + '/' + CAST(PCD.intContractSeq AS NVARCHAR(10))
		,strSContractNumberSeq = SCH.strContractNumber + '/' + CAST(SCD.intContractSeq AS NVARCHAR(10))
		,strItemNo = I.strItemNo
		,strItemDescription = I.strDescription
		,strOrigin = OG.strDescription
		,strProductType = CA.strDescription 
		,strCommodity = COM.strCommodityCode
		,strPClient = V.strName
		,strSClient = C.strName
		,dblPAllocatedQty = CASE WHEN ISNULL(VCHR.dblNetShippedWt, 0) <> 0 THEN VCHR.dblNetShippedWt + ISNULL(VCADJ.dblWtAdjustment, 0)
								 WHEN ISNULL(LS.dblNetShippedWt, 0) <> 0 THEN LS.dblNetShippedWt
								 ELSE dbo.fnCalculateQtyBetweenUOM (PUOM.intItemUOMId, ToWUOM.intItemUOMId, ALD.dblPAllocatedQty) END
		,dblSAllocatedQty = CASE WHEN COALESCE(INVC.dblNetShippedWt, PINVC.dblNetShippedWt, 0) <> 0 THEN ISNULL(INVC.dblNetShippedWt, PINVC.dblNetShippedWt)
								 ELSE dbo.fnCalculateQtyBetweenUOM (SUOM.intItemUOMId, ToWUOM.intItemUOMId, ALD.dblSAllocatedQty) END
		,dblPAllocatedQtyInPriceUOM = CASE WHEN ISNULL(VCHR.dblNetShippedWt, 0) <> 0 THEN dbo.fnCalculateQtyBetweenUOM (ToWUOM.intItemUOMId, PCD.intPriceItemUOMId, VCHR.dblNetShippedWt + ISNULL(VCADJ.dblWtAdjustment, 0))
										   WHEN ISNULL(LS.dblNetShippedWt, 0) <> 0 THEN dbo.fnCalculateQtyBetweenUOM (LS.intItemUOMId, PCD.intPriceItemUOMId, LS.dblNetShippedWt)
										   ELSE dbo.fnCalculateQtyBetweenUOM (PUOM.intItemUOMId, PCD.intPriceItemUOMId, ALD.dblPAllocatedQty) END
		,dblSAllocatedQtyInPriceUOM = CASE WHEN COALESCE(INVC.dblNetShippedWt, PINVC.dblNetShippedWt, 0) <> 0 THEN dbo.fnCalculateQtyBetweenUOM (ToWUOM.intItemUOMId, SCD.intPriceItemUOMId, ISNULL(INVC.dblNetShippedWt, PINVC.dblNetShippedWt))
										   ELSE dbo.fnCalculateQtyBetweenUOM (SUOM.intItemUOMId, SCD.intPriceItemUOMId, ALD.dblSAllocatedQty) END
		,dblSAllocatedQtyInResUOM = CASE WHEN COALESCE(INVC.dblNetShippedWt, PINVC.dblNetShippedWt, 0) <> 0 THEN dbo.fnCalculateQtyBetweenUOM (ToWUOM.intItemUOMId, ToUOM.intItemUOMId, ISNULL(INVC.dblNetShippedWt, PINVC.dblNetShippedWt))
										 ELSE dbo.fnCalculateQtyBetweenUOM (SUOM.intItemUOMId, ToUOM.intItemUOMId, ALD.dblSAllocatedQty) END
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
							COALESCE(INVC.dblTotalCost, PINVC.dblTotalCost, 0) + ISNULL(INADJ.dblTotalCost, 0)
		,dblDifference = /* Difference = P-Terminal Price - S-Terminal Price */
							ISNULL(PCD.dblFutures, 0) - ISNULL(SCD.dblFutures, 0)
		,dblDifferenceInFC = (ISNULL(PCD.dblFutures, 0) / ISNULL(PCUR.intCent, 1)) - (ISNULL(SCD.dblFutures, 0) / ISNULL(SCUR.intCent, 1))
		,dblLots = /* Lots = Invoice or Allocated Weight / Contract Weight */
					ROUND(dbo.fnDivide(CASE WHEN COALESCE(INVC.dblNetShippedWt, PINVC.dblNetShippedWt, 0) <> 0 THEN ISNULL(INVC.dblNetShippedWt, PINVC.dblNetShippedWt)
									ELSE dbo.fnCalculateQtyBetweenUOM (SUOM.intItemUOMId, ToWUOM.intItemUOMId, ALD.dblSAllocatedQty) END,
									dbo.fnCTConvertQuantityToTargetItemUOM(I.intItemId, FM.intUnitMeasureId, @intWeightUnitMeasureId, FM.dblContractSize)), 0)
		,dblLotContractSize = /* Lots Contract Size = Lots x Contract Size*/
							ROUND(dbo.fnDivide(CASE WHEN COALESCE(INVC.dblNetShippedWt, PINVC.dblNetShippedWt, 0) <> 0 THEN ISNULL(INVC.dblNetShippedWt, PINVC.dblNetShippedWt)
									ELSE dbo.fnCalculateQtyBetweenUOM (SUOM.intItemUOMId, ToWUOM.intItemUOMId, ALD.dblSAllocatedQty) END,
									dbo.fnCTConvertQuantityToTargetItemUOM(I.intItemId, FM.intUnitMeasureId, @intWeightUnitMeasureId, FM.dblContractSize)), 0)
								* dbo.fnCTConvertQuantityToTargetItemUOM(I.intItemId, FM.intUnitMeasureId, @intWeightUnitMeasureId, FM.dblContractSize)
		,dblLotContractSizeInPriceUOM =  /* Lots Contract Size converted to Price UOM for Eff Hedge PL calculation */
							ROUND(dbo.fnDivide(CASE WHEN COALESCE(INVC.dblNetShippedWt, PINVC.dblNetShippedWt, 0) <> 0 THEN ISNULL(INVC.dblNetShippedWt, PINVC.dblNetShippedWt)
									ELSE dbo.fnCalculateQtyBetweenUOM (SUOM.intItemUOMId, ToWUOM.intItemUOMId, ALD.dblSAllocatedQty) END,
									dbo.fnCTConvertQuantityToTargetItemUOM(I.intItemId, FM.intUnitMeasureId, @intWeightUnitMeasureId, FM.dblContractSize)), 0)
								* dbo.fnCTConvertQuantityToTargetItemUOM(I.intItemId, FM.intUnitMeasureId, IUOM.intUnitMeasureId, FM.dblContractSize)
		,dblReservesARateTotal = ISNULL(RA.dblReservesARateTotal, 0)
		,dblReservesAValueTotal = ISNULL(RA.dblReservesAValueTotal * -1, 0)
		,dblReservesBRateTotal = ISNULL(RB.dblReservesBRateTotal, 0)
		,dblReservesBValueTotal = ISNULL(RB.dblReservesBValueTotal * -1, 0)
		,dblDifferentialRateTotal = /* P-Differential + Reserves A Total + Reserves B Total */
								ISNULL(PCD.dblBasis, 0)
								+ ISNULL(RA.dblReservesARateTotal, 0) 
								+ ISNULL(RB.dblReservesBRateTotal, 0) 
		,dblTonnageCheck = /* P-Qty - S-Qty */
						CASE WHEN ISNULL(VCHR.dblNetShippedWt, 0) <> 0 THEN VCHR.dblNetShippedWt + ISNULL(VCADJ.dblWtAdjustment, 0)
							 WHEN ISNULL(LS.dblNetShippedWt, 0) <> 0 THEN LS.dblNetShippedWt
							 ELSE dbo.fnCalculateQtyBetweenUOM (PUOM.intItemUOMId, ToWUOM.intItemUOMId, ALD.dblPAllocatedQty) END
						- COALESCE(INVC.dblNetShippedWt, PINVC.dblNetShippedWt, dbo.fnCalculateQtyBetweenUOM (SUOM.intItemUOMId, ToWUOM.intItemUOMId, ALD.dblSAllocatedQty))
		,dblTotalMargin = /* Reserves B Total in Absolute Value */ 
							ABS(RB.dblReservesBValueTotal)
		,dblReservesATotalVariance = ISNULL(RA.dblReservesAVarianceTotal, 0) * -1
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
		LEFT JOIN tblCTContractStatus PCS ON PCS.intContractStatusId = PCD.intContractStatusId
		LEFT JOIN tblEMEntity C ON C.intEntityId = SCH.intEntityId
		LEFT JOIN tblICItemUOM SUOM ON SUOM.intItemId = I.intItemId AND SUOM.intUnitMeasureId = ALD.intSUnitMeasureId
		LEFT JOIN tblICItemUOM PUOM ON PUOM.intItemId = I.intItemId AND PUOM.intUnitMeasureId = ALD.intPUnitMeasureId
		LEFT JOIN tblSMCurrency PCUR ON PCUR.intCurrencyID = PCD.intBasisCurrencyId
		LEFT JOIN tblSMCurrency SCUR ON SCUR.intCurrencyID = SCD.intBasisCurrencyId
		LEFT JOIN tblICItemUOM IUOM ON PCD.intPriceItemUOMId = IUOM.intItemUOMId
		LEFT JOIN tblICUnitMeasure PUM ON PUM.intUnitMeasureId = IUOM.intUnitMeasureId
		OUTER APPLY (SELECT TOP 1 intContractDetailId FROM tblAPBillDetail bd WHERE bd.intContractDetailId = PCD.intContractDetailId) BD
		OUTER APPLY (SELECT	TOP 1 intItemUOMId, dblUnitQty FROM	dbo.tblICItemUOM 
						WHERE intItemId = I.intItemId AND intUnitMeasureId = @intUnitMeasureId) ToUOM
		OUTER APPLY (SELECT	TOP 1 intItemUOMId, dblUnitQty FROM	dbo.tblICItemUOM 
						WHERE intItemId = I.intItemId AND intUnitMeasureId = @intWeightUnitMeasureId) ToWUOM
		OUTER APPLY (SELECT TOP 1 ysnFullHeaderLogo, intReportLogoHeight, intReportLogoWidth
							,intPnLReportReserveACategoryId, intPnLReportReserveBCategoryId 
						FROM tblLGCompanyPreference) CP
		/* Load Shipment */
		OUTER APPLY 
			(SELECT 
				dblNetShippedWt = SUM(LD.dblShipmentNetWt) --LS Net Weight in Tonnage Unit
				,dblShippedNetQty = SUM(LD.dblShipmentQty) --LS Net Weight in Contract Unit
				,intItemUOMId = MAX(LD.intWeightItemUOMId)
			FROM 
				(SELECT l.intLoadId, ld.intItemId, ld.intPContractDetailId, l.ysnPosted, ld.intWeightItemUOMId
					,dblShipmentNetWt = dbo.fnCalculateQtyBetweenUOM (ld.intWeightItemUOMId, ToWUOM.intItemUOMId, ld.dblNet) 
					,dblShipmentQty = dbo.fnCalculateQtyBetweenUOM (ld.intWeightItemUOMId, ld.intItemUOMId, ld.dblNet) 
					FROM tblLGLoadDetail ld
					INNER JOIN tblLGLoad l on l.intLoadId = ld.intLoadId and l.intShipmentType = 1
					WHERE l.ysnPosted = 1 AND ld.intPContractDetailId = PCD.intContractDetailId) LD
			) LS
		/* Purchase Value */
		OUTER APPLY 
			(SELECT 
				dblTotalCost = SUM(BLD.dblTotal)
				,dblNetShippedWt = SUM(BLD.dblQtyReceived)
			FROM 
				(SELECT bl.intBillId, bld.intItemId, bld.intContractDetailId, bl.ysnPosted, bl.intTransactionType
					,dblTotal = bld.dblTotal * CASE WHEN bl.intTransactionType IN (3, 11) THEN -1 ELSE 1 END
					,dblQtyReceived = dbo.fnCalculateQtyBetweenUOM (bld.intWeightUOMId, ToWUOM.intItemUOMId, 
										CASE WHEN (bld.intItemId <> PCD.intItemId) THEN 0 
											ELSE 
												CASE WHEN bl.intTransactionType IN (11) THEN bld.dblQtyOrdered ELSE bld.dblNetWeight  END
											END) 
									* CASE WHEN bl.intTransactionType IN (3, 11) THEN -1 ELSE 1 END
					FROM tblAPBillDetail bld
					INNER JOIN tblAPBill bl on bl.intBillId = bld.intBillId) BLD
				INNER JOIN tblICItem BLDI ON BLDI.intItemId = BLD.intItemId
			WHERE (BLD.ysnPosted = 1 OR BLD.intTransactionType = 11) 
				AND BLD.intContractDetailId = PCD.intContractDetailId
				AND BLDI.intCategoryId NOT IN (CP.intPnLReportReserveACategoryId, CP.intPnLReportReserveBCategoryId)) VCHR
		/* Purchase Weight Adjustment */
		OUTER APPLY 
			(SELECT 
				dblWtAdjustment = SUM(BLD.dblWeightAdj)
			FROM 
				(SELECT bl.intBillId, bld.intItemId, bld.intContractDetailId, bl.ysnPosted, bl.intTransactionType
					,dblWeightAdj = dbo.fnCalculateQtyBetweenUOM (PCD.intNetWeightUOMId, ToWUOM.intItemUOMId, bld.dblWeight) 
									* CASE WHEN bl.intTransactionType IN (3, 11) THEN -1 ELSE 1 END
					FROM tblAPBillDetail bld
					INNER JOIN tblAPBill bl on bl.intBillId = bld.intBillId) BLD
				INNER JOIN tblICItem BLDI ON BLDI.intItemId = BLD.intItemId
			WHERE (BLD.ysnPosted = 1 OR BLD.intTransactionType = 11) 
				AND BLD.intContractDetailId = PCD.intContractDetailId
				AND BLD.intItemId <> PCD.intItemId
				AND BLDI.intCategoryId NOT IN (CP.intPnLReportReserveACategoryId, CP.intPnLReportReserveBCategoryId)) VCADJ
		/* Sales Value */
		OUTER APPLY 
			(SELECT 
				dblTotalCost = SUM(dblTotal)
				,dblNetShippedWt = SUM(dblQtyShipped)
			FROM 
				(SELECT ivd.intInvoiceId, ivd.intItemId, ivd.intContractDetailId, iv.ysnPosted
					,dblTotal = dblTotal * CASE WHEN (iv.strTransactionType IN ('Credit Memo') AND ISNULL(iv.ysnFromProvisional, 0) = 0) THEN -1 ELSE 1 END
					,dblQtyShipped = dbo.fnCalculateQtyBetweenUOM (intItemWeightUOMId, ToWUOM.intItemUOMId, dblShipmentNetWt) 
									* CASE WHEN (iv.strTransactionType IN ('Credit Memo') AND ISNULL(iv.ysnFromProvisional, 0) = 0) THEN -1 ELSE 1 END
					FROM tblARInvoiceDetail ivd
					INNER JOIN tblARInvoice iv on iv.intInvoiceId = ivd.intInvoiceId AND iv.strType = 'Standard') IVD 
				INNER JOIN tblICItem IVDI ON IVDI.intItemId = IVD.intItemId
			WHERE IVD.ysnPosted = 1 
				AND IVD.intContractDetailId = SCD.intContractDetailId
				AND IVD.intItemId = SCD.intItemId) INVC
		OUTER APPLY
			(SELECT 
				dblTotalCost = SUM(dblTotal)
				,dblNetShippedWt = SUM(dblQtyShipped)
			FROM 
				(SELECT ivd.intInvoiceId, ivd.intItemId, ivd.intContractDetailId, iv.ysnPosted
					,dblTotal = dblTotal
					,dblQtyShipped = dbo.fnCalculateQtyBetweenUOM (intItemWeightUOMId, ToWUOM.intItemUOMId, dblShipmentNetWt)
					FROM tblARInvoiceDetail ivd
					INNER JOIN tblARInvoice iv on iv.intInvoiceId = ivd.intInvoiceId AND iv.strType = 'Provisional') IVD 
				INNER JOIN tblICItem IVDI ON IVDI.intItemId = IVD.intItemId
			WHERE IVD.ysnPosted = 1 
				AND IVD.intContractDetailId = SCD.intContractDetailId
				AND IVD.intItemId = SCD.intItemId) PINVC
		/* Sales Value Adjustment */
		OUTER APPLY 
			(SELECT 
				dblTotalCost = SUM(dblTotal)
			FROM 
				(SELECT ivd.intInvoiceId, ivd.intItemId, ivd.intContractDetailId, iv.ysnPosted
					,dblTotal = dblTotal * CASE WHEN (iv.strTransactionType IN ('Credit Memo') AND ISNULL(iv.ysnFromProvisional, 0) = 0) THEN -1 ELSE 1 END
					FROM tblARInvoiceDetail ivd INNER JOIN tblARInvoice iv on iv.intInvoiceId = ivd.intInvoiceId AND iv.strType = 'Standard') IVD 
				INNER JOIN tblICItem IVDI ON IVDI.intItemId = IVD.intItemId
			WHERE IVD.ysnPosted = 1 
				AND IVD.intContractDetailId = SCD.intContractDetailId
				AND IVD.intItemId <> SCD.intItemId
				AND IVDI.intCategoryId NOT IN (CP.intPnLReportReserveACategoryId, CP.intPnLReportReserveBCategoryId)) INADJ
		/* Reserves A */
		OUTER APPLY 
			(SELECT dblReservesARateTotal = SUM(ISNULL(CC.dblRate, 0))
					,dblReservesAValueTotal = SUM(CASE WHEN (ISNULL(RAVCHR.dblTotal, 0) + ISNULL(RAINVC.dblTotal, 0)) <> 0 
												THEN (ISNULL(RAVCHR.dblTotal, 0) + ISNULL(RAINVC.dblTotal, 0))
												ELSE ISNULL(CC.dblAmount, 0) END)
					,dblReservesAVarianceTotal = SUM(CASE WHEN (ISNULL(RAVCHR.dblTotal, 0) + ISNULL(RAINVC.dblTotal, 0)) <> 0 
										THEN (ISNULL(RAVCHR.dblTotal, 0) + ISNULL(RAINVC.dblTotal, 0)) - ISNULL(CC.dblAmount, 0) 
										ELSE 0 END)
			FROM tblICItem I 
				/* Reserves Rate and Amount */
				CROSS APPLY (SELECT dblRate = CASE WHEN CC.strCostMethod = 'Per Unit' THEN 
													CC.dblRate
												WHEN CC.strCostMethod = 'Amount' THEN
													CC.dblRate 
													/ CASE WHEN ISNULL(VCHR.dblNetShippedWt, 0) <> 0 THEN VCHR.dblNetShippedWt + ISNULL(VCADJ.dblWtAdjustment, 0)
															 WHEN ISNULL(LS.dblShippedNetQty, 0) <> 0 THEN dbo.fnCalculateQtyBetweenUOM(CD.intItemUOMId,ToUOM.intItemUOMId,LS.dblShippedNetQty)
															 ELSE dbo.fnCalculateQtyBetweenUOM(CD.intItemUOMId,ToUOM.intItemUOMId,ALD.dblSAllocatedQty) END
												ELSE CC.dblRate END * COALESCE(CC.dblFX, FX.dblFXRate, 1)
								,dblAmount = CASE WHEN CC.strCostMethod = 'Per Unit' THEN 
													CASE WHEN ISNULL(VCHR.dblNetShippedWt, 0) <> 0 THEN VCHR.dblNetShippedWt + ISNULL(VCADJ.dblWtAdjustment, 0)
															 WHEN ISNULL(LS.dblShippedNetQty, 0) <> 0 THEN dbo.fnCalculateQtyBetweenUOM(CD.intItemUOMId,ToUOM.intItemUOMId,LS.dblShippedNetQty)
															 ELSE dbo.fnCalculateQtyBetweenUOM(CD.intItemUOMId,ToUOM.intItemUOMId,ALD.dblSAllocatedQty) END
													* dbo.fnCalculateCostBetweenUOM(CC.intItemUOMId,CCTonUOM.intItemUOMId,CC.dblRate) / ISNULL(CCUR.intCent, 1)
												WHEN CC.strCostMethod = 'Amount' THEN
													CC.dblRate
												WHEN CC.strCostMethod = 'Per Container'	THEN
													CC.dblRate * (CASE WHEN ISNULL(CD.intNumberOfContainers,1) = 0 THEN 1 ELSE ISNULL(CD.intNumberOfContainers,1) END)
												WHEN CC.strCostMethod = 'Percentage' THEN 
													CASE WHEN ISNULL(VCHR.dblNetShippedWt, 0) <> 0 THEN VCHR.dblNetShippedWt + ISNULL(VCADJ.dblWtAdjustment, 0)
															 WHEN ISNULL(LS.dblShippedNetQty, 0) <> 0 THEN dbo.fnCalculateQtyBetweenUOM(CD.intItemUOMId,ToUOM.intItemUOMId,LS.dblShippedNetQty)
															 ELSE dbo.fnCalculateQtyBetweenUOM(CD.intItemUOMId,ToUOM.intItemUOMId,ALD.dblSAllocatedQty) END
													* CD.dblCashPrice * CC.dblRate/100
												END * COALESCE(CC.dblFX, FX.dblFXRate, 1)
						FROM tblCTContractCost CC
							LEFT JOIN tblCTContractDetail CD ON CD.intContractDetailId = CC.intContractDetailId
							LEFT JOIN tblSMCurrency CCUR ON CCUR.intCurrencyID = CC.intCurrencyId
							LEFT JOIN tblICItemUOM CDUOM ON CDUOM.intItemUOMId = CD.intPriceItemUOMId
							OUTER APPLY (SELECT	TOP 1 intItemUOMId, dblUnitQty FROM	dbo.tblICItemUOM 
										WHERE intItemId = CC.intItemId AND intUnitMeasureId = CDUOM.intUnitMeasureId) CToUOM
							OUTER APPLY (SELECT	TOP 1 intItemUOMId, dblUnitQty FROM	dbo.tblICItemUOM 
									WHERE intItemId = CC.intItemId AND intUnitMeasureId = @intWeightUnitMeasureId) CCTonUOM
							OUTER APPLY (SELECT	TOP 1 dblFXRate = CASE WHEN ER.intFromCurrencyId = @intDefaultCurrencyId THEN 1/RD.[dblRate] ELSE RD.[dblRate] END 
									FROM tblSMCurrencyExchangeRate ER
									JOIN tblSMCurrencyExchangeRateDetail RD ON RD.intCurrencyExchangeRateId = ER.intCurrencyExchangeRateId
									WHERE @intDefaultCurrencyId <> ISNULL(CCUR.intMainCurrencyId, CCUR.intCurrencyID)
										AND ((ER.intFromCurrencyId = ISNULL(CCUR.intMainCurrencyId, CCUR.intCurrencyID) AND ER.intToCurrencyId = @intDefaultCurrencyId) 
											OR (ER.intFromCurrencyId = @intDefaultCurrencyId AND ER.intToCurrencyId = ISNULL(CCUR.intMainCurrencyId, CCUR.intCurrencyID)))
									ORDER BY RD.dtmValidFromDate DESC) FX
					WHERE CC.intItemId = I.intItemId AND CD.intContractDetailId = ALD.intSContractDetailId AND CC.dblRate <> 0) CC
				/* Reserves Voucher Amount */
				OUTER APPLY 
					(SELECT dblTotal = SUM(CASE WHEN BL.intTransactionType IN (3, 11) 
									THEN (BLD.dblTotal * -1) * COALESCE(BLD.dblRate, FX.dblFXRate, 1) 
									ELSE BLD.dblTotal * COALESCE(BLD.dblRate, FX.dblFXRate, 1) END) 
						FROM tblAPBillDetail BLD 
							INNER JOIN tblAPBill BL ON BL.intBillId = BLD.intBillId
							INNER JOIN tblICItem BLDI ON BLDI.intItemId = BLD.intItemId
							LEFT JOIN tblSMCurrency CCUR ON CCUR.intCurrencyID = BLD.intCurrencyId
							OUTER APPLY (SELECT	TOP 1 dblFXRate = CASE WHEN ER.intFromCurrencyId = @intDefaultCurrencyId THEN 1/RD.[dblRate] ELSE RD.[dblRate] END 
										FROM tblSMCurrencyExchangeRate ER
										JOIN tblSMCurrencyExchangeRateDetail RD ON RD.intCurrencyExchangeRateId = ER.intCurrencyExchangeRateId
										WHERE @intDefaultCurrencyId <> ISNULL(CCUR.intMainCurrencyId, CCUR.intCurrencyID)
											AND ((ER.intFromCurrencyId = ISNULL(CCUR.intMainCurrencyId, CCUR.intCurrencyID) AND ER.intToCurrencyId = @intDefaultCurrencyId) 
												OR (ER.intFromCurrencyId = @intDefaultCurrencyId AND ER.intToCurrencyId = ISNULL(CCUR.intMainCurrencyId, CCUR.intCurrencyID)))
										ORDER BY RD.dtmValidFromDate DESC) FX
						WHERE BL.ysnPosted = 1
							AND BLD.intContractDetailId IN (ALD.intPContractDetailId, ALD.intSContractDetailId)
							AND BLD.intItemId = I.intItemId 
							) RAVCHR
				/* Reserves Invoice Amount */
				OUTER APPLY 
					(SELECT dblTotal = SUM(CASE WHEN IV.strTransactionType IN ('Credit Memo') 
										THEN (IVD.dblTotal * -1) * COALESCE(IVD.dblCurrencyExchangeRate, FX.dblFXRate, 1) 
										ELSE IVD.dblTotal * COALESCE(IVD.dblCurrencyExchangeRate, FX.dblFXRate, 1) END)
					FROM tblARInvoiceDetail IVD 
						INNER JOIN tblARInvoice IV ON IV.intInvoiceId = IVD.intInvoiceId
						INNER JOIN tblICItem IVDI ON IVDI.intItemId = IVD.intItemId
						LEFT JOIN tblSMCurrency CCUR ON CCUR.intCurrencyID = IV.intCurrencyId
						OUTER APPLY (SELECT	TOP 1 dblFXRate = CASE WHEN ER.intFromCurrencyId = @intDefaultCurrencyId THEN 1/RD.[dblRate] ELSE RD.[dblRate] END 
									FROM tblSMCurrencyExchangeRate ER
									JOIN tblSMCurrencyExchangeRateDetail RD ON RD.intCurrencyExchangeRateId = ER.intCurrencyExchangeRateId
									WHERE @intDefaultCurrencyId <> ISNULL(CCUR.intMainCurrencyId, CCUR.intCurrencyID)
										AND ((ER.intFromCurrencyId = ISNULL(CCUR.intMainCurrencyId, CCUR.intCurrencyID) AND ER.intToCurrencyId = @intDefaultCurrencyId) 
											OR (ER.intFromCurrencyId = @intDefaultCurrencyId AND ER.intToCurrencyId = ISNULL(CCUR.intMainCurrencyId, CCUR.intCurrencyID)))
									ORDER BY RD.dtmValidFromDate DESC) FX
					WHERE IV.ysnPosted = 1
						AND IVD.intContractDetailId IN (ALD.intPContractDetailId, ALD.intSContractDetailId)
						AND IVD.intItemId = I.intItemId 
					) RAINVC
			WHERE I.intCategoryId = CP.intPnLReportReserveACategoryId
		) RA 
		/* Reserves B */
		OUTER APPLY 
			(SELECT dblReservesBRateTotal = SUM(ISNULL(CC.dblRate, 0))
					,dblReservesBValueTotal = SUM(CASE WHEN (ISNULL(RBVCHR.dblTotal, 0) + ISNULL(RBINVC.dblTotal, 0)) <> 0 
												THEN (ISNULL(RBVCHR.dblTotal, 0) + ISNULL(RBINVC.dblTotal, 0))
												ELSE ISNULL(CC.dblAmount, 0) END)
			FROM tblICItem I 
				/* Reserves Rate and Amount */
				CROSS APPLY (SELECT dblRate = CASE WHEN CC.strCostMethod = 'Per Unit' THEN 
													CC.dblRate
												WHEN CC.strCostMethod = 'Amount' THEN
													CC.dblRate 
													/ CASE WHEN ISNULL(VCHR.dblNetShippedWt, 0) <> 0 THEN VCHR.dblNetShippedWt + ISNULL(VCADJ.dblWtAdjustment, 0)
															 WHEN ISNULL(LS.dblShippedNetQty, 0) <> 0 THEN dbo.fnCalculateQtyBetweenUOM(CD.intItemUOMId,ToUOM.intItemUOMId,LS.dblShippedNetQty)
															 ELSE dbo.fnCalculateQtyBetweenUOM(CD.intItemUOMId,CCTonUOM.intItemUOMId,ALD.dblSAllocatedQty) END
												ELSE CC.dblRate END * COALESCE(CC.dblFX, FX.dblFXRate, 1)
								,dblAmount = CASE WHEN CC.strCostMethod = 'Per Unit' THEN 
													CASE WHEN ISNULL(VCHR.dblNetShippedWt, 0) <> 0 THEN VCHR.dblNetShippedWt + ISNULL(VCADJ.dblWtAdjustment, 0)
															 WHEN ISNULL(LS.dblShippedNetQty, 0) <> 0 THEN dbo.fnCalculateQtyBetweenUOM(CD.intItemUOMId,ToUOM.intItemUOMId,LS.dblShippedNetQty)
															 ELSE dbo.fnCalculateQtyBetweenUOM(CD.intItemUOMId,ToUOM.intItemUOMId,ALD.dblSAllocatedQty) END
													* dbo.fnCalculateCostBetweenUOM(CC.intItemUOMId,CCTonUOM.intItemUOMId,ISNULL(CC.dblRate, 0)) / ISNULL(CCUR.intCent, 1)
												WHEN CC.strCostMethod = 'Amount' THEN
													CC.dblRate
												WHEN CC.strCostMethod = 'Per Container'	THEN
													CC.dblRate * (CASE WHEN ISNULL(CD.intNumberOfContainers,1) = 0 THEN 1 ELSE ISNULL(CD.intNumberOfContainers,1) END)
												WHEN CC.strCostMethod = 'Percentage' THEN 
													CASE WHEN ISNULL(VCHR.dblNetShippedWt, 0) <> 0 THEN VCHR.dblNetShippedWt + ISNULL(VCADJ.dblWtAdjustment, 0)
															 WHEN ISNULL(LS.dblShippedNetQty, 0) <> 0 THEN dbo.fnCalculateQtyBetweenUOM(CD.intItemUOMId,ToUOM.intItemUOMId,LS.dblShippedNetQty)
															 ELSE dbo.fnCalculateQtyBetweenUOM(CD.intItemUOMId,ToUOM.intItemUOMId,ALD.dblSAllocatedQty) END
													* CD.dblCashPrice * CC.dblRate/100
												END * COALESCE(CC.dblFX, FX.dblFXRate, 1)
						FROM tblCTContractCost CC
							LEFT JOIN tblCTContractDetail CD ON CD.intContractDetailId = CC.intContractDetailId
							LEFT JOIN tblSMCurrency CCUR ON CCUR.intCurrencyID = CC.intCurrencyId
							LEFT JOIN tblICItemUOM CDUOM ON CDUOM.intItemUOMId = CD.intPriceItemUOMId
							OUTER APPLY (SELECT	TOP 1 intItemUOMId, dblUnitQty FROM	dbo.tblICItemUOM 
										WHERE intItemId = CC.intItemId AND intUnitMeasureId = CDUOM.intUnitMeasureId) CToUOM
							OUTER APPLY (SELECT	TOP 1 intItemUOMId, dblUnitQty FROM	dbo.tblICItemUOM 
									WHERE intItemId = CC.intItemId AND intUnitMeasureId = @intWeightUnitMeasureId) CCTonUOM
							OUTER APPLY (SELECT	TOP 1 dblFXRate = CASE WHEN ER.intFromCurrencyId = @intDefaultCurrencyId THEN 1/RD.[dblRate] ELSE RD.[dblRate] END 
									FROM tblSMCurrencyExchangeRate ER
									JOIN tblSMCurrencyExchangeRateDetail RD ON RD.intCurrencyExchangeRateId = ER.intCurrencyExchangeRateId
									WHERE @intDefaultCurrencyId <> ISNULL(CCUR.intMainCurrencyId, CCUR.intCurrencyID)
										AND ((ER.intFromCurrencyId = ISNULL(CCUR.intMainCurrencyId, CCUR.intCurrencyID) AND ER.intToCurrencyId = @intDefaultCurrencyId) 
											OR (ER.intFromCurrencyId = @intDefaultCurrencyId AND ER.intToCurrencyId = ISNULL(CCUR.intMainCurrencyId, CCUR.intCurrencyID)))
									ORDER BY RD.dtmValidFromDate DESC) FX
					WHERE CC.intItemId = I.intItemId AND CD.intContractDetailId = ALD.intSContractDetailId AND CC.dblRate <> 0) CC
				/* Reserves Voucher Amount */
				OUTER APPLY 
					(SELECT dblTotal = SUM(CASE WHEN BL.intTransactionType IN (3, 11) 
									THEN (BLD.dblTotal * -1) * COALESCE(BLD.dblRate, FX.dblFXRate, 1) 
									ELSE BLD.dblTotal * COALESCE(BLD.dblRate, FX.dblFXRate, 1) END) 
						FROM tblAPBillDetail BLD 
							INNER JOIN tblAPBill BL ON BL.intBillId = BLD.intBillId
							INNER JOIN tblICItem BLDI ON BLDI.intItemId = BLD.intItemId
							LEFT JOIN tblSMCurrency CCUR ON CCUR.intCurrencyID = BLD.intCurrencyId
							OUTER APPLY (SELECT	TOP 1 dblFXRate = CASE WHEN ER.intFromCurrencyId = @intDefaultCurrencyId THEN 1/RD.[dblRate] ELSE RD.[dblRate] END 
										FROM tblSMCurrencyExchangeRate ER
										JOIN tblSMCurrencyExchangeRateDetail RD ON RD.intCurrencyExchangeRateId = ER.intCurrencyExchangeRateId
										WHERE @intDefaultCurrencyId <> ISNULL(CCUR.intMainCurrencyId, CCUR.intCurrencyID)
											AND ((ER.intFromCurrencyId = ISNULL(CCUR.intMainCurrencyId, CCUR.intCurrencyID) AND ER.intToCurrencyId = @intDefaultCurrencyId) 
												OR (ER.intFromCurrencyId = @intDefaultCurrencyId AND ER.intToCurrencyId = ISNULL(CCUR.intMainCurrencyId, CCUR.intCurrencyID)))
										ORDER BY RD.dtmValidFromDate DESC) FX
						WHERE BL.ysnPosted = 1
							AND BLD.intContractDetailId IN (ALD.intPContractDetailId, ALD.intSContractDetailId)
							AND BLD.intItemId = I.intItemId 
							) RBVCHR
				/* Reserves Invoice Amount */
				OUTER APPLY 
					(SELECT dblTotal = SUM(CASE WHEN IV.strTransactionType IN ('Credit Memo') 
										THEN (IVD.dblTotal * -1) * COALESCE(IVD.dblCurrencyExchangeRate, FX.dblFXRate, 1) 
										ELSE IVD.dblTotal * COALESCE(IVD.dblCurrencyExchangeRate, FX.dblFXRate, 1) END)
					FROM tblARInvoiceDetail IVD 
						INNER JOIN tblARInvoice IV ON IV.intInvoiceId = IVD.intInvoiceId
						INNER JOIN tblICItem IVDI ON IVDI.intItemId = IVD.intItemId
						LEFT JOIN tblSMCurrency CCUR ON CCUR.intCurrencyID = IV.intCurrencyId
						OUTER APPLY (SELECT	TOP 1 dblFXRate = CASE WHEN ER.intFromCurrencyId = @intDefaultCurrencyId THEN 1/RD.[dblRate] ELSE RD.[dblRate] END 
									FROM tblSMCurrencyExchangeRate ER
									JOIN tblSMCurrencyExchangeRateDetail RD ON RD.intCurrencyExchangeRateId = ER.intCurrencyExchangeRateId
									WHERE @intDefaultCurrencyId <> ISNULL(CCUR.intMainCurrencyId, CCUR.intCurrencyID)
										AND ((ER.intFromCurrencyId = ISNULL(CCUR.intMainCurrencyId, CCUR.intCurrencyID) AND ER.intToCurrencyId = @intDefaultCurrencyId) 
											OR (ER.intFromCurrencyId = @intDefaultCurrencyId AND ER.intToCurrencyId = ISNULL(CCUR.intMainCurrencyId, CCUR.intCurrencyID)))
									ORDER BY RD.dtmValidFromDate DESC) FX
					WHERE IV.ysnPosted = 1
						AND IVD.intContractDetailId IN (ALD.intPContractDetailId, ALD.intSContractDetailId)
						AND IVD.intItemId = I.intItemId 
					) RBINVC
			WHERE I.intCategoryId = CP.intPnLReportReserveBCategoryId
		) RB
	WHERE ALD.strAllocationDetailRefNo IS NOT NULL AND ALD.intAllocationDetailId = @intAllocationDetailId
) PNL

GO