CREATE PROCEDURE [dbo].[uspCTLoadContractCost]
	@intContractDetailId	INT
AS

	SELECT		--CC.*,
				CC.intContractCostId
				,CC.intConcurrencyId
				,CC.intPrevConcurrencyId
				,CC.intContractDetailId
				,CC.intItemId
				,CC.intVendorId
				,CC.strCostMethod
				,CC.intCurrencyId
				,CC.dblRate
				,CC.intItemUOMId
				,CC.intRateTypeId
				,CC.dblFX
				,CC.ysnAccrue
				,CC.ysnMTM
				,CC.ysnPrice
				,CC.ysnAdditionalCost
				,CC.ysnBasis
				,CC.ysnReceivable
				,CC.strParty
				,CC.strPaidBy
				,CC.dtmDueDate
				,CC.strReference
				,CC.ysn15DaysFromShipment
				,CC.strRemarks
				,CC.strStatus
				,CC.strCostStatus
				,CC.dblReqstdAmount
				,CC.dblRcvdPaidAmount
				,dblActualAmount = isnull(CC.dblActualAmount,0.00)
				,CC.dblAccruedAmount
				,CC.dblRemainingPercent
				,CC.dtmAccrualDate
				,CC.strAPAR
				,CC.strPayToReceiveFrom
				,CC.strReferenceNo
				,CC.intContractCostRefId
				,CC.ysnFromBasisComponent,

				IM.strItemNo, 
				IM.strDescription strItemDescription,
				UM.strUnitMeasure strUOM, 
				EY.strName strVendorName, 
				CD.intContractHeaderId, 
				IU.intUnitMeasureId, 
				CD.intContractSeq, 
				CY.strCurrency,
				CH.strContractNumber + ' - ' + LTRIM(CD.intContractSeq) strContractSeq,
				CAST(ISNULL((SELECT TOP 1 intBillDetailId FROM tblAPBillDetail WHERE intContractCostId = CC.intContractCostId),0) AS BIT) ysnBilled,
				CH.intTermId,					
				IM.strCostType,
				IM.ysnInventoryCost,
				CH.strContractNumber,
				CH.dtmContractDate,
				MY.strCurrency	AS	strMainCurrency,
				(CASE	WHEN	CC.strCostMethod = 'Per Unit'	THEN 
							dbo.fnCTConvertQuantityToTargetItemUOM(CD.intItemId,QU.intUnitMeasureId,CM.intUnitMeasureId,CD.dblQuantity)*CC.dblRate
						WHEN	CC.strCostMethod = 'Amount' THEN
							CC.dblRate
						WHEN	CC.strCostMethod = 'Per Container'	THEN
							(CC.dblRate * (case when isnull(CD.intNumberOfContainers,1) = 0 then 1 else isnull(CD.intNumberOfContainers,1) end))
						WHEN	CC.strCostMethod = 'Percentage' THEN 
							dbo.fnCTConvertQuantityToTargetItemUOM(CD.intItemId,QU.intUnitMeasureId,PU.intUnitMeasureId,CD.dblQuantity)*CD.dblCashPrice*CC.dblRate/100
				END)  / (case when isnull(CY.ysnSubCurrency,convert(bit,0)) = convert(bit,1) then isnull(CY.intCent,1) else 1 end)  dblAmount,
				RT.strCurrencyExchangeRateType,
				CH.intBookId AS intHeaderBookId,
				CH.intSubBookId AS intHeaderSubBookId,
				CD.intBookId AS intDetailBookId,
				CD.intSubBookId AS intDetailSubBookId	

	FROM		tblCTContractCost	CC
	JOIN		tblCTContractDetail	CD	ON	CD.intContractDetailId	=	CC.intContractDetailId
										AND CC.intContractDetailId  =	@intContractDetailId	
	JOIN		tblCTContractHeader CH	ON	CH.intContractHeaderId	=	CD.intContractHeaderId
	JOIN		tblICItem			IM	ON	IM.intItemId			=	CC.intItemId
	LEFT JOIN	tblICItemUOM		IU	ON	IU.intItemUOMId			=	CC.intItemUOMId
	LEFT JOIN	tblICUnitMeasure	UM	ON	UM.intUnitMeasureId		=	IU.intUnitMeasureId
	LEFT JOIN	tblSMCurrency		CY	ON	CY.intCurrencyID		=	CC.intCurrencyId
	LEFT JOIN	tblSMCurrency		MY	ON	MY.intCurrencyID		=	CY.intMainCurrencyId
	LEFT JOIN	tblEMEntity			EY	ON	EY.intEntityId			=	CC.intVendorId
	LEFT JOIN	tblEMEntityType		ET	ON	ET.intEntityId			=	EY.intEntityId
										AND ET.strType				=	'Vendor'
	LEFT JOIN	tblICItemUOM		PU	ON	PU.intItemUOMId			=	CD.intPriceItemUOMId	
	LEFT JOIN	tblICItemUOM		QU	ON	QU.intItemUOMId			=	CD.intItemUOMId	
	LEFT JOIN	tblICItemUOM		CM	ON	CM.intUnitMeasureId		=	IU.intUnitMeasureId
										AND CM.intItemId			=	CD.intItemId	
	LEFT JOIN	tblSMCurrencyExchangeRateType	RT	ON	RT.intCurrencyExchangeRateTypeId	=		CC.intRateTypeId