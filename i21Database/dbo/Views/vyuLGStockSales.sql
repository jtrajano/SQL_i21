CREATE VIEW vyuLGStockSales
AS
SELECT SH.intStockSalesHeaderId
	  ,SH.strStockSalesNumber
	  ,SLD.intStockSalesLotDetailId
	  ,SL.strLocationName 
	  ,strCustomerName = E.strName
	  ,SH.intCommodityId
	  ,strCommodity = C.strDescription
	  ,SH.intSubLocationId
	  ,strSubLocationName = SLCL.strSubLocationName
	  ,SH.intWeightUnitMeasureId
	  ,strWeightUOM = UM.strUnitMeasure
	  ,SH.intContractHeaderId
	  ,CH.strContractNumber
	  ,SH.intAllocationHeaderId
	  ,AH.strAllocationNumber
	  ,SH.intPickLotHeaderId
	  ,PLH.strPickLotNumber
	  ,intSalesPersonId = SP.intEntityId
	  ,strSalesPerson = SP.strName
	  ,PO.intPositionId 
	  ,PO.strPosition
	  ,PO.strPositionType
	  ,CH.intFreightTermId
	  ,strIncoTerms = CB.strFreightTerm
	  ,intPricingType = CH.intPricingTypeId 
	  ,PT.strPricingType
	  ,CH.intInsuranceById
	  ,IB.strInsuranceBy
	  ,CD.strFixationBy
	  ,CD.intFutureMarketId
	  ,FM.strFutMarketName
	  ,CD.intFutureMonthId
	  ,MO.strFutureMonth
	  ,CH.intTermId
	  ,TE.strTerm
	  ,TE.strTermCode
	  ,CH.intGradeId 
	  ,strApprovalGrade = AG.strWeightGradeDesc
	  ,CH.intWeightId
	  ,strWeightGrade = WG.strWeightGradeDesc
	  ,ysnShipped = CAST(CASE WHEN EXISTS (SELECT TOP 1 1 FROM tblLGLoadDetail WHERE intSContractDetailId = CD.intContractDetailId) THEN 1 ELSE 0 END AS BIT)
FROM tblLGStockSalesHeader SH
JOIN tblLGStockSalesLotDetail SLD ON SLD.intStockSalesHeaderId = SH.intStockSalesHeaderId
JOIN tblEMEntity E ON E.intEntityId = SH.intCustomerEntityId
JOIN tblSMCompanyLocation SL ON SL.intCompanyLocationId = SH.intCompanyLocationId
JOIN tblICCommodity C ON C.intCommodityId = SH.intCommodityId
JOIN tblSMCompanyLocationSubLocation SLCL ON SLCL.intCompanyLocationSubLocationId = SH.intSubLocationId
JOIN tblICUnitMeasure UM ON UM.intUnitMeasureId = SH.intWeightUnitMeasureId
JOIN tblCTContractHeader CH ON CH.intContractHeaderId = SH.intContractHeaderId
JOIN tblCTContractDetail CD ON CD.intContractHeaderId = CH.intContractHeaderId 
LEFT JOIN tblLGAllocationHeader AH ON AH.intAllocationHeaderId = SH.intAllocationHeaderId
LEFT JOIN tblLGPickLotHeader PLH ON PLH.intPickLotHeaderId = SH.intPickLotHeaderId
LEFT JOIN tblEMEntity SP ON SP.intEntityId = CH.intSalespersonId
LEFT JOIN tblCTPricingType PT ON PT.intPricingTypeId = CH.intPricingTypeId
LEFT JOIN tblCTPosition PO ON PO.intPositionId = CH.intPositionId
LEFT JOIN tblSMFreightTerms CB ON CB.intFreightTermId = CH.intFreightTermId
LEFT JOIN tblCTInsuranceBy IB ON IB.intInsuranceById = CH.intInsuranceById
LEFT JOIN tblRKFutureMarket FM ON FM.intFutureMarketId = CD.intFutureMarketId 
LEFT JOIN tblRKFuturesMonth MO ON MO.intFutureMonthId = CD.intFutureMonthId		
LEFT JOIN tblSMTerm TE ON TE.intTermID = CH.intTermId
LEFT JOIN tblCTWeightGrade AG ON AG.intWeightGradeId = CH.intGradeId
LEFT JOIN tblCTWeightGrade WG ON WG.intWeightGradeId = CH.intWeightId