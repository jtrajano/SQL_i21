CREATE VIEW [dbo].[vyuIPContractCostView]
AS
SELECT CC.intContractCostId
	,CC.intContractDetailId
	,CC.strCostMethod
	,CC.dblRate
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
	,CC.ysn15DaysFromShipment
	,CC.strReference
	,CC.strRemarks
	,CC.strStatus
	,CC.strCostStatus
	,CC.dblReqstdAmount
	,CC.dblRcvdPaidAmount
	,CC.dblActualAmount
	,CC.dblAccruedAmount
	,CC.dblRemainingPercent
	,CC.dtmAccrualDate
	,CC.strAPAR
	,CC.strPayToReceiveFrom
	,CC.strReferenceNo
	,IM.strItemNo
	,UM.strUnitMeasure strUOM
	,EY.strName strVendorName
	,CY.strCurrency
	,RT.strCurrencyExchangeRateType
FROM tblCTContractCost CC
JOIN tblICItem IM ON IM.intItemId = CC.intItemId
LEFT JOIN tblICItemUOM IU ON IU.intItemUOMId = CC.intItemUOMId
LEFT JOIN tblICUnitMeasure UM ON UM.intUnitMeasureId = IU.intUnitMeasureId
LEFT JOIN tblSMCurrency CY ON CY.intCurrencyID = CC.intCurrencyId
LEFT JOIN tblSMCurrency MY ON MY.intCurrencyID = CY.intMainCurrencyId
LEFT JOIN tblEMEntity EY ON EY.intEntityId = CC.intVendorId
LEFT JOIN tblEMEntityType ET ON ET.intEntityId = EY.intEntityId
	AND ET.strType = 'Vendor'
LEFT JOIN tblSMCurrencyExchangeRateType RT ON RT.intCurrencyExchangeRateTypeId = CC.intRateTypeId
