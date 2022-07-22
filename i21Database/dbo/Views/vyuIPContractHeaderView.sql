CREATE VIEW [dbo].[vyuIPContractHeaderView]
AS
SELECT CH.intContractHeaderId
	,CH.strCustomerContract
	,CH.strContractNumber
	,CH.dtmContractDate
	,CH.dblQuantity AS dblHeaderQuantity
	,CH.strInternalComment
	,CH.ysnSigned
	,CH.ysnPrinted
	,CH.strPrintableRemarks
	,CH.dblTolerancePct
	,CH.dblProvisionalInvoicePct
	,CH.ysnSubstituteItem
	,CH.ysnUnlimitedQuantity
	,CH.ysnMaxPrice
	,CH.ysnProvisional
	,CH.ysnLoad
	,CH.intNoOfLoad
	,CH.dblQuantityPerLoad
	,CH.ysnCategory
	,CH.ysnMultiplePriceFixation
	,CH.dblFutures
	,CH.dblNoOfLots
	,CH.ysnClaimsToProducer
	,CH.ysnRiskToProducer
	,CH.strAmendmentLog
	,CH.ysnExported
	,CH.dtmExported
	,CH.ysnMailSent
	,CH.dtmSigned
	,CH.dtmCreated
	,CH.dtmLastModified
	,CH.ysnBrokerage
	,U2.strUnitMeasure AS strHeaderUnitMeasure
	,W1.strWeightGradeDesc AS strGrade
	,W2.strWeightGradeDesc AS strWeight
	,TX.strTextCode
	,AN.strName AS strAssociationName
	,TM.strTerm
	,PO.strPosition
	,IB.strInsuranceBy
	,IT.strInvoiceType
	,CO.strCountry
	,CY.strCommodityCode
	,PT.strPricingType
	,CE.strName AS strCreatedBy
	,YR.strCropYear
	,UE.strName AS strLastModifiedBy
	,SY.strName AS strSalesperson
	,FT.strFreightTerm
	,AB.strCity strArbitration
	,SB.strSubBook
	,CT.strCity					AS	strINCOLocation
	,CH.intProductTypeId
	,CH.ysnPrimeCustomer
FROM tblCTContractHeader CH
LEFT JOIN tblCTWeightGrade W1 ON W1.intWeightGradeId = CH.intGradeId
LEFT JOIN tblCTWeightGrade W2 ON W2.intWeightGradeId = CH.intWeightId
LEFT JOIN tblCTContractText TX ON TX.intContractTextId = CH.intContractTextId
LEFT JOIN tblCTAssociation AN ON AN.intAssociationId = CH.intAssociationId
LEFT JOIN tblSMTerm TM ON TM.intTermID = CH.intTermId
LEFT JOIN tblCTPosition PO ON PO.intPositionId = CH.intPositionId
LEFT JOIN tblCTInsuranceBy IB ON IB.intInsuranceById = CH.intInsuranceById
LEFT JOIN tblCTInvoiceType IT ON IT.intInvoiceTypeId = CH.intInvoiceTypeId
LEFT JOIN tblSMCountry CO ON CO.intCountryID = CH.intCountryId
LEFT JOIN tblICCommodity CY ON CY.intCommodityId = CH.intCommodityId
LEFT JOIN tblCTPricingType PT ON PT.intPricingTypeId = CH.intPricingTypeId
LEFT JOIN tblCTCropYear YR ON YR.intCropYearId = CH.intCropYearId
LEFT JOIN tblSMFreightTerms FT ON FT.intFreightTermId = CH.intFreightTermId
LEFT JOIN tblSMCity CT ON CT.intCityId = CH.intINCOLocationTypeId
LEFT JOIN tblSMCity AB ON AB.intCityId = CH.intArbitrationId
LEFT JOIN tblEMEntity SY ON SY.intEntityId = CH.intSalespersonId
LEFT JOIN tblEMEntity CE ON CE.intEntityId = CH.intCreatedById
LEFT JOIN tblEMEntity UE ON UE.intEntityId = CH.intLastModifiedById
LEFT JOIN tblICCommodityUnitMeasure CM ON CM.intCommodityUnitMeasureId = CH.intCommodityUOMId
LEFT JOIN tblICUnitMeasure U2 ON U2.intUnitMeasureId = CM.intUnitMeasureId
LEFT JOIN tblCTSubBook SB ON SB.intSubBookId = CH.intSubBookId
