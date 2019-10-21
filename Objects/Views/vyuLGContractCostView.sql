﻿CREATE VIEW [dbo].[vyuLGContractCostView]
AS
SELECT CONVERT(INT, ROW_NUMBER() OVER (
			PARTITION BY intContractDetailId ORDER BY intContractCostId
			)) AS intId
	,*
FROM (
	SELECT CC.intContractCostId
		,CC.intConcurrencyId
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
		,CC.strPaidBy
		,CC.strParty
		,CC.dtmDueDate
		,CC.strReference
		,CC.strRemarks
		,CC.strStatus
		,CC.dblReqstdAmount
		,CC.dblRcvdPaidAmount
		,CC.strAPAR
		,CC.strPayToReceiveFrom
		,CC.strReferenceNo
		,IM.strItemNo
		,IM.strDescription strItemDescription
		,UM.strUnitMeasure strUOM
		,strVendorName = ET.strName
		,CD.intContractHeaderId
		,IU.intUnitMeasureId
		,CD.intContractSeq
		,CY.strCurrency
		,CH.strContractNumber + ' - ' + LTRIM(CD.intContractSeq) strContractSeq
		,CAST(ISNULL((
					SELECT TOP 1 intBillDetailId
					FROM tblAPBillDetail
					WHERE intContractCostId = CC.intContractCostId
					), 0) AS BIT) ysnBilled
		,CH.intTermId
		,IM.strCostType
		,IM.ysnInventoryCost
		,CH.strContractNumber
		,MY.strCurrency AS strMainCurrency
		,CASE 
			WHEN CC.strCostMethod = 'Per Unit'
				THEN dbo.fnCTConvertQuantityToTargetItemUOM(CD.intItemId, QU.intUnitMeasureId, CM.intUnitMeasureId, CD.dblQuantity) * CC.dblRate
			WHEN CC.strCostMethod = 'Amount'
				THEN CC.dblRate
			WHEN CC.strCostMethod = 'Percentage'
				THEN dbo.fnCTConvertQuantityToTargetItemUOM(CD.intItemId, QU.intUnitMeasureId, PU.intUnitMeasureId, CD.dblQuantity) * CD.dblCashPrice * CC.dblRate / 100
			END dblAmount
		,RT.strCurrencyExchangeRateType
		,strEntityType = 'Vendor' COLLATE Latin1_General_CI_AS
		,IM.intOnCostTypeId
	FROM tblCTContractCost CC
	JOIN tblCTContractDetail CD ON CD.intContractDetailId = CC.intContractDetailId
	JOIN tblCTContractHeader CH ON CH.intContractHeaderId = CD.intContractHeaderId
	JOIN tblICItem IM ON IM.intItemId = CC.intItemId
	LEFT JOIN tblICItemUOM IU ON IU.intItemUOMId = CC.intItemUOMId
	LEFT JOIN tblICUnitMeasure UM ON UM.intUnitMeasureId = IU.intUnitMeasureId
	LEFT JOIN tblSMCurrency CY ON CY.intCurrencyID = CC.intCurrencyId
	LEFT JOIN tblSMCurrency MY ON MY.intCurrencyID = CY.intMainCurrencyId
	LEFT JOIN tblEMEntity ET ON ET.intEntityId = CC.intVendorId
	LEFT JOIN tblICItemUOM PU ON PU.intItemUOMId = CD.intPriceItemUOMId
	LEFT JOIN tblICItemUOM QU ON QU.intItemUOMId = CD.intItemUOMId
	LEFT JOIN tblICItemUOM CM ON CM.intUnitMeasureId = IU.intUnitMeasureId
		AND CM.intItemId = CD.intItemId
	LEFT JOIN tblSMCurrencyExchangeRateType RT ON RT.intCurrencyExchangeRateTypeId = CD.intRateTypeId
	WHERE CC.ysnPrice = 0
	
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
		,CCV.strParty
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
		,strEntityType = CASE WHEN CH.intContractTypeId = 1 THEN 'Vendor' ELSE 'Customer' END COLLATE Latin1_General_CI_AS
		,IM.intOnCostTypeId
	FROM vyuCTContractCostView CCV
	JOIN tblICItem IM ON IM.intItemId = CCV.intItemId
	JOIN tblCTContractHeader CH ON CH.intContractHeaderId = CCV.intContractHeaderId
	JOIN tblEMEntity E ON E.intEntityId = CH.intEntityId
	WHERE CCV.ysnPrice = 1
	) tbl