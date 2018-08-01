CREATE VIEW [dbo].[vyuLGContractCostView]
AS
	SELECT		CC.*,

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
				MY.strCurrency	AS	strMainCurrency,
				CASE	WHEN	CC.strCostMethod = 'Per Unit'	THEN 
							dbo.fnCTConvertQuantityToTargetItemUOM(CD.intItemId,QU.intUnitMeasureId,CM.intUnitMeasureId,CD.dblQuantity)*CC.dblRate
						WHEN	CC.strCostMethod = 'Amount'		THEN
							CC.dblRate
						WHEN	CC.strCostMethod = 'Percentage' THEN 
							dbo.fnCTConvertQuantityToTargetItemUOM(CD.intItemId,QU.intUnitMeasureId,PU.intUnitMeasureId,CD.dblQuantity)*CD.dblCashPrice*CC.dblRate/100
				END   dblAmount,
				RT.strCurrencyExchangeRateType,
				ET.strType AS strEntityType

	FROM		tblCTContractCost	CC
	JOIN		tblCTContractDetail CD ON CD.intContractDetailId	=	CC.intContractDetailId
	JOIN		tblCTContractHeader CH ON CH.intContractHeaderId	=	CD.intContractHeaderId
	JOIN		tblICItem			IM ON IM.intItemId				=	CC.intItemId
	LEFT JOIN	tblICItemUOM		IU ON IU.intItemUOMId			=	CC.intItemUOMId
	LEFT JOIN	tblICUnitMeasure	UM ON UM.intUnitMeasureId		=	IU.intUnitMeasureId
	LEFT JOIN	tblSMCurrency		CY ON CY.intCurrencyID			=	CC.intCurrencyId
	LEFT JOIN	tblSMCurrency		MY ON MY.intCurrencyID			=	CY.intMainCurrencyId
	LEFT JOIN	tblEMEntity			EY ON EY.intEntityId			=	CC.intVendorId
	LEFT JOIN	tblEMEntityType		ET ON ET.intEntityId			=	EY.intEntityId
									  AND ET.strType = 'Vendor'
	LEFT JOIN	tblICItemUOM		PU ON PU.intItemUOMId			=	CD.intPriceItemUOMId	
	LEFT JOIN	tblICItemUOM		QU ON QU.intItemUOMId			=	CD.intItemUOMId	
	LEFT JOIN	tblICItemUOM		CM ON CM.intUnitMeasureId		=	IU.intUnitMeasureId
									  AND CM.intItemId				=	CD.intItemId		
	LEFT JOIN	tblSMCurrencyExchangeRateType	RT	ON	RT.intCurrencyExchangeRateTypeId	=		CD.intRateTypeId

UNION 


SELECT CCV.intContractCostId
	,CCV.intConcurrencyId
	,CCV.intContractDetailId
	,CCV.intItemId
	,CH.intEntityId
	,CCV.strCostMethod
	,CCV.intCurrencyId
	,CCV.dblRate
	,CCV.intItemUOMId
	,CCV.intRateTypeId
	,CCV.dblFX
	,CCV.ysnAccrue
	,CCV.ysnMTM
	,CCV.ysnPrice
	,CCV.ysnAdditionalCost
	,CCV.ysnBasis
	,CCV.ysnReceivable
	,CCV.strPaidBy
	,CCV.dtmDueDate
	,CCV.strReference
	,CCV.strRemarks
	,CCV.strStatus
	,CCV.dblReqstdAmount
	,CCV.dblRcvdPaidAmount
	,CCV.strAPAR
	,CCV.strPayToReceiveFrom
	,CCV.strReferenceNo
	,CCV.strItemNo
	,CCV.strItemDescription
	,CCV.strUOM
	,E.strName
	,CCV.intContractHeaderId
	,CCV.intUnitMeasureId
	,CCV.intContractSeq
	,CCV.strCurrency
	,CCV.strContractSeq
	,CCV.ysnBilled
	,CCV.intTermId
	,CCV.strCostType
	,CCV.ysnInventoryCost
	,CCV.strContractNumber
	,CCV.strMainCurrency
	,CCV.dblAmount
	,CCV.strCurrencyExchangeRateType
	,ET.strType AS strEntityType
FROM vyuCTContractCostView CCV
JOIN tblCTContractHeader CH ON CH.intContractHeaderId = CCV.intContractHeaderId
JOIN tblEMEntity E ON E.intEntityId = CH.intEntityId
JOIN tblEMEntityType ET ON ET.intEntityId = E.intEntityId 
WHERE ysnPrice = 1