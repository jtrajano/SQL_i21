﻿CREATE PROCEDURE [dbo].[uspCTLoadContractCost]
	@intContractDetailId	INT
AS

	SELECT		CC.intContractCostId, 
				CC.intContractDetailId, 
				CC.intConcurrencyId, 
				CC.intItemId, 
				CC.intVendorId, 
				CC.strCostMethod, 
				CC.intCurrencyId,
				CC.dblRate,
				CC.intItemUOMId, 
				CC.dblFX, 
				CC.ysnAccrue, 
				CC.ysnMTM, 
				CC.ysnPrice, 
				CC.ysnAdditionalCost,
				CC.ysnBasis,
				CC.strReference,
				CC.ysnReceivable,
				CC.strPaidBy,
                CC.strStatus,
				CC.dblReqstdAmount,
				CC.dblRcvdPaidAmount,

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
                CC.strAPAR,
				CC.strPayToReceiveFrom,
				CC.dtmDueDate,
				CC.strReferenceNo,
				CC.strRemarks,			
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
				END   dblAmount

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
