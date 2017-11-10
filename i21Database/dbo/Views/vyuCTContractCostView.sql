﻿CREATE VIEW [dbo].[vyuCTContractCostView]
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
				CC.intPaidById,
				CC.ysnBasis,
				CC.dtmDueDate,
				CC.strReference,
				CC.strRemarks,
				CC.ysnReceivable,

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
				PY.strName AS strPaidBy,
				IM.strCostType,
				IM.ysnInventoryCost

	FROM		tblCTContractCost	CC
	JOIN		tblCTContractDetail CD ON CD.intContractDetailId	=	CC.intContractDetailId
	JOIN		tblCTContractHeader CH ON CH.intContractHeaderId	=	CD.intContractHeaderId
	JOIN		tblICItem			IM ON IM.intItemId				=	CC.intItemId
	LEFT JOIN	tblICItemUOM		IU ON IU.intItemUOMId			=	CC.intItemUOMId
	LEFT JOIN	tblICUnitMeasure	UM ON UM.intUnitMeasureId		=	IU.intUnitMeasureId
	LEFT JOIN	tblSMCurrency		CY ON CY.intCurrencyID			=	CC.intCurrencyId
	LEFT JOIN	tblEMEntity			EY ON EY.intEntityId			=	CC.intVendorId
	LEFT JOIN	tblEMEntityType		ET ON ET.intEntityId			=	EY.intEntityId
									  AND ET.strType = 'Vendor'
	LEFT JOIN	tblEMEntity			PY ON PY.intEntityId			=	CC.intPaidById
