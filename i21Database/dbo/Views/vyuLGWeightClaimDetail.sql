CREATE VIEW vyuLGWeightClaimDetail
AS
SELECT
	WCD.intWeightClaimDetailId
	,WCD.intWeightClaimId
	,WCD.strCondition
	,WCD.intItemId
	,WCD.dblQuantity
	,WCD.dblFromNet
	,WCD.dblToGross
	,WCD.dblToTare
	,WCD.dblToNet
	,WCD.dblFranchiseWt
	,WCD.dblWeightLoss
	,WCD.dblClaimableWt
	,WCD.intPartyEntityId
	,WCD.dblUnitPrice
	,WCD.intCurrencyId
	,WCD.dblClaimAmount
	,WCD.intPriceItemUOMId
	,WCD.dblAdditionalCost
	,WCD.ysnNoClaim
	,WCD.intContractDetailId
	,WCD.intBillId
	,WCD.intInvoiceId
	,WCD.dblFranchise
	,WCD.dblSeqPriceConversionFactoryWeightUOM
	,WCD.intWeightClaimDetailRefId
	,WCD.intLoadContainerId
	,strContainerNumber = LC.strContainerNumber
	,strMarks = LC.strMarks
	,strContractNumber = CH.strContractNumber
	,intContractTypeId = CH.intContractTypeId
	,intContractSeq = CD.intContractSeq
	,strEntityName = EM.strName
	,strCurrency = C.strCurrency
	,strPriceUOM = PUM.strUnitMeasure
	,strPaidTo = PTEM.strName
	,ysnSeqSubCurrency = C.ysnSubCurrency
	,dblSeqPriceInWeightUOM = dblSeqPriceConversionFactoryWeightUOM * WCD.dblUnitPrice
	,dblSeqPrice = WCD.dblUnitPrice
	,WCD.intConcurrencyId
FROM
	tblLGWeightClaimDetail WCD
	LEFT JOIN tblCTContractDetail CD ON CD.intContractDetailId = WCD.intContractDetailId
	LEFT JOIN tblCTContractHeader CH ON CH.intContractHeaderId = CD.intContractHeaderId
	LEFT JOIN tblEMEntity EM ON EM.intEntityId = CH.intEntityId
	LEFT JOIN tblEMEntity PTEM ON PTEM.intEntityId = WCD.intPartyEntityId
	LEFT JOIN tblICItemUOM PUOM ON PUOM.intItemUOMId = WCD.intPriceItemUOMId
	LEFT JOIN tblICUnitMeasure PUM ON PUM.intUnitMeasureId = PUOM.intUnitMeasureId
	LEFT JOIN tblSMCurrency C ON C.intCurrencyID = WCD.intCurrencyId
	LEFT JOIN tblLGLoadContainer LC ON LC.intLoadContainerId = WCD.intLoadContainerId
GO