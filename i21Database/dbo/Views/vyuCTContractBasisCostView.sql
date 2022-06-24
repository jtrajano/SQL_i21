CREATE VIEW [dbo].[vyuCTContractBasisCostView]
AS 

	SELECT		CC.intContractCostId,
				CC.intContractDetailId,
				CH.intContractHeaderId,
				CH.strContractNumber,
				CD.intContractSeq,					
				CH.strContractNumber + ' - ' + LTRIM(CD.intContractSeq) strContractSeq,
				IM.strItemNo, 
				IM.strDescription strItemDescription,
				UM.strUnitMeasure strUOM, 
				UM.intUnitMeasureId AS intUOMId,
				UM.strSymbol,
				LTRIM(BC.intSort) as strOrder,
				(CASE	WHEN	CC.strCostMethod = 'Per Unit'	THEN 
							dbo.fnCTConvertQuantityToTargetItemUOM(CD.intItemId,QU.intUnitMeasureId,CM.intUnitMeasureId,CD.dblQuantity)*CC.dblRate
						WHEN	CC.strCostMethod = 'Amount' THEN
							CC.dblRate * isnull(CC.dblFX,1)
						WHEN	CC.strCostMethod = 'Per Container'	THEN
							(CC.dblRate * (case when isnull(CD.intNumberOfContainers,1) = 0 then 1 else isnull(CD.intNumberOfContainers,1) end))
						WHEN	CC.strCostMethod = 'Percentage' THEN 
							dbo.fnCTConvertQuantityToTargetItemUOM(CD.intItemId,QU.intUnitMeasureId,PU.intUnitMeasureId,CD.dblQuantity)*CD.dblCashPrice*CC.dblRate/100
				END)  / (case when isnull(CY.ysnSubCurrency,convert(bit,0)) = convert(bit,1) then isnull(CY.intCent,1) else 1 end)  dblAmount,
				CC.dblActualAmount,
				CC.intVendorId,
				EY.strName strVendorName, 
				CY.strCurrency as strCostCurrency ,
				IC.strCurrency as strInvoiceCurrency,
				CC.dblFX,
				CC.dblRate,
				(CASE	WHEN	CC.strCostMethod = 'Per Unit'	THEN 
							dbo.fnCTConvertQuantityToTargetItemUOM(CD.intItemId,QU.intUnitMeasureId,CM.intUnitMeasureId,CD.dblQuantity)*CC.dblRate
						WHEN	CC.strCostMethod = 'Amount' THEN
							CC.dblRate * isnull(CC.dblFX,1)
						WHEN	CC.strCostMethod = 'Per Container'	THEN
							(CC.dblRate * (case when isnull(CD.intNumberOfContainers,1) = 0 then 1 else isnull(CD.intNumberOfContainers,1) end))
						WHEN	CC.strCostMethod = 'Percentage' THEN 
							dbo.fnCTConvertQuantityToTargetItemUOM(CD.intItemId,QU.intUnitMeasureId,PU.intUnitMeasureId,CD.dblQuantity)*CD.dblCashPrice*CC.dblRate/100
				END)  / (case when isnull(CY.ysnSubCurrency,convert(bit,0)) = convert(bit,1) then isnull(CY.intCent,1) else 1 end)  * dblFX as dblInvoiceAmount
				
				--CC.strCostMethod,
				--CC.intCurrencyId,
				--CC.dblRate,
				--CC.intItemUOMId,
				--CC.intRateTypeId,
				--CC.ysnAccrue,
				--CC.ysnMTM,
				--CC.ysnPrice,
				--CC.ysnAdditionalCost,
				--ISNULL(CC.ysnBasis,0) AS ysnBasis,
				--CC.ysnReceivable,
				--CC.strParty,
				--CC.strPaidBy,
				--CC.dtmDueDate,
				--CC.ysn15DaysFromShipment,
				--CC.strReference,
				--CC.strRemarks,
				--CC.strStatus,
				--CC.strCostStatus,
				--CC.dblReqstdAmount,
				--CC.dblRcvdPaidAmount,
				--CC.dblActualAmount,
				--CC.dblAccruedAmount,
				--CC.dblRemainingPercent,
				--CC.dtmAccrualDate,
				--CC.strAPAR,
				--CC.strPayToReceiveFrom,
				--CC.strReferenceNo,
				--CC.intContractCostRefId,
				--CC.ysnFromBasisComponent,
				--CC.intConcurrencyId,
				--CC.intPrevConcurrencyId,	
				--CD.intContractHeaderId, 
				--IU.intUnitMeasureId, 
				--CAST(ISNULL((SELECT TOP 1 intBillDetailId FROM tblAPBillDetail WHERE intContractCostId = CC.intContractCostId),0) AS BIT) ysnBilled,
				--CH.intTermId,							
				--IM.strCostType,
				--IM.ysnInventoryCost,
				--CH.strContractNumber,
				--CH.dtmContractDate,
				--MY.strCurrency	AS	strMainCurrency,
				--RT.strCurrencyExchangeRateType,
				--CH.intBookId AS intHeaderBookId,
				--CH.intSubBookId AS intHeaderSubBookId,
				--CD.intBookId AS intDetailBookId,
				--CD.intSubBookId AS intDetailSubBookId				
	FROM		tblCTContractCost	CC
	JOIN		tblCTContractDetail CD ON CD.intContractDetailId	=	CC.intContractDetailId
	JOIN		tblCTContractHeader CH ON CH.intContractHeaderId	=	CD.intContractHeaderId
	JOIN		tblICItem			IM ON IM.intItemId				=	CC.intItemId
	LEFT JOIN	tblICItemUOM		IU ON IU.intItemUOMId			=	CC.intItemUOMId
	LEFT JOIN	tblICUnitMeasure	UM ON UM.intUnitMeasureId		=	IU.intUnitMeasureId
	LEFT JOIN	tblSMCurrency		CY ON CY.intCurrencyID			=	CC.intCurrencyId
	LEFT JOIN	tblSMCurrency		MY ON MY.intCurrencyID			=	CY.intMainCurrencyId
	LEFT JOIN	tblSMCurrency		IC ON IC.intCurrencyID			=	CD.intInvoiceCurrencyId
	LEFT JOIN	tblEMEntity			EY ON EY.intEntityId			=	CC.intVendorId
	LEFT JOIN	tblEMEntityType		ET ON ET.intEntityId			=	EY.intEntityId
									  AND ET.strType = 'Vendor'
	LEFT JOIN	tblICItemUOM		PU ON PU.intItemUOMId			=	CD.intPriceItemUOMId	
	LEFT JOIN	tblICItemUOM		QU ON QU.intItemUOMId			=	CD.intItemUOMId	
	LEFT JOIN	tblICItemUOM		CM ON CM.intUnitMeasureId		=	IU.intUnitMeasureId
									  AND CM.intItemId				=	CD.intItemId		
	LEFT JOIN	tblSMCurrencyExchangeRateType	RT	ON	RT.intCurrencyExchangeRateTypeId	=		CC.intRateTypeId
	LEFT JOIN	tblCTBasisCost	    BC	ON	BC.intItemId			=	CC.intItemId	