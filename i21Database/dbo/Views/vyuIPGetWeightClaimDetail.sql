CREATE VIEW vyuIPGetWeightClaimDetail
AS
SELECT WCD.[intWeightClaimDetailId]
	,WCD.[intConcurrencyId]
	,WCD.[intWeightClaimId]
	,WCD.[strCondition]
	,WCD.[intItemId]
	,WCD.[dblQuantity]
	,WCD.[dblFromNet]
	,WCD.[dblToNet]
	,WCD.[dblFranchiseWt]
	,WCD.[dblWeightLoss]
	,WCD.[dblClaimableWt]
	,WCD.[intPartyEntityId]
	,WCD.[dblUnitPrice]
	,WCD.[intCurrencyId]
	,WCD.[dblClaimAmount]
	,WCD.[intPriceItemUOMId]
	,UM.strUnitMeasure 
	,WCD.[dblAdditionalCost]
	,WCD.[ysnNoClaim] 
	,WCD.[intContractDetailId]
	,WCD.[intBillId]
	,WCD.[intInvoiceId]
	,WCD.[dblFranchise]
	,WCD.[dblSeqPriceConversionFactoryWeightUOM]
	,WCD.[intWeightClaimDetailRefId]
	,I.intItemRefId
	,I.strItemNo
	,C.strCurrency
	,E.strName As strPartyName
	,UM.strUnitMeasure as strPriceUOM
FROM tblLGWeightClaimDetail WCD
Left JOIN [tblSMCurrency] C on C.intCurrencyID=WCD.intCurrencyId
Left JOIN tblEMEntity E on E.intEntityId=WCD.intPartyEntityId
Left JOIN  [tblICItem] I on I.intItemId =WCD.intItemId
Left JOIN tblICItemUOM IU on IU.intItemUOMId=WCD.intPriceItemUOMId
Left JOIN tblICUnitMeasure UM On UM.intUnitMeasureId =IU.intUnitMeasureId 


 


