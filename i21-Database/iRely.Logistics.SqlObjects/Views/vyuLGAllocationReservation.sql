CREATE VIEW vyuLGAllocationReservation
AS
SELECT LR.intReservationId AS intReservationId
	,LR.intContractDetailId AS intContractDetailId
	,LR.dblReservedQuantity AS dblReservedQuantity
	,LR.intUnitMeasureId AS intUnitMeasureId
	,LR.intPurchaseSale AS intPurchaseSale
	,LR.dtmReservedDate AS dtmReservedDate
	,LR.intUserSecurityId AS intUserSecurityId
	,LR.strComments AS strComments
	,LR.intConcurrencyId AS intConcurrencyId
	,UM.intUnitMeasureId AS intReservationUnitMeasureId
	,UM.strUnitMeasure AS strUnitMeasure
	,UM.strSymbol AS strSymbol
	,US.intEntityId AS intUserId
	,US.strUserName AS strUserName
	,CD.intContractHeaderId AS intContractHeaderId
	,CD.intContractSeq AS intContractSeq
	,CD.intCompanyLocationId AS intCompanyLocationId
	,CD.dtmStartDate AS dtmStartDate
	,CD.dtmEndDate AS dtmEndDate
	,CD.intItemId AS intItemId
	,CD.intItemUOMId AS intItemUOMId
	,CD.dblQuantity AS dblQuantity
	,CD.strBuyerSeller AS strBuyerSeller
	,CD.strFobBasis AS strFobBasis
	,CD.dblOriginalQty AS dblOriginalQty
	,CD.dblBalance AS dblBalance
	,CD.dblIntransitQty AS dblIntransitQty
	,CD.dblScheduleQty AS dblScheduleQty
	,CD.dblBasis AS dblBasis
	,CD.dblCashPrice AS dblCashPrice
	,CD.intCurrencyId AS intCurrencyId
	,CD.intPriceItemUOMId AS intPriceItemUOMId
	,CH.intEntityId AS intContractEntityId
	,CH.intCommodityId AS intCommodityId
	,CH.strContractNumber AS strContractNumber
	,CH.intContractBasisId AS intContractBasisId
	,CH.dtmContractDate AS dtmContractDate
	,CH.strCustomerContract AS strCustomerContract
	,CH.intSalespersonId AS intSalespersonId
	,CH.intPositionId AS intPositionId
	,CH.intPricingTypeId AS intPricingTypeId
	,CH.intInsuranceById AS intInsuranceById
	,CH.intTermId AS intTermId
	,CH.intGradeId AS intGradeId
	,CH.intWeightId AS intWeightId
	,CH.ysnLoad AS ysnLoad
	,CB.strContractBasis AS strContractBasis
	,E.strName AS strContractEntity
	,E.strEmail AS strEmail
	,E.intDefaultLocationId AS intDefaultLocationId
	,I.strType AS strType
	,I.strItemNo AS strItemNo
	,I.strDescription AS strDescription
	,I.intOriginId AS intOriginId
	,Country.strCountry as strItemOrigin
FROM tblLGReservation AS LR
INNER JOIN tblICUnitMeasure AS UM ON LR.intUnitMeasureId = UM.intUnitMeasureId
INNER JOIN tblSMUserSecurity AS US ON LR.intUserSecurityId = US.intEntityId
INNER JOIN tblCTContractDetail AS CD ON LR.intContractDetailId = CD.intContractDetailId
INNER JOIN tblCTContractHeader AS CH ON CD.intContractHeaderId = CH.intContractHeaderId
INNER JOIN tblEMEntity AS E ON CH.intEntityId = E.intEntityId
LEFT OUTER JOIN tblCTContractBasis AS CB ON CH.intContractBasisId = CB.intContractBasisId
LEFT OUTER JOIN tblICItem AS I ON CD.intItemId = I.intItemId
LEFT JOIN tblICCommodityAttribute CA ON CA.intCommodityAttributeId = I.intOriginId
LEFT JOIN tblSMCountry Country ON Country.intCountryID = CA.intCountryID
LEFT JOIN tblICCommodity Comm ON Comm.intCommodityId = CH.intCommodityId