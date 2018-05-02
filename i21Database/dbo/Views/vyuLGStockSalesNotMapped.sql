CREATE VIEW vyuLGStockSalesNotMapped
AS
SELECT DISTINCT SSH.intStockSalesHeaderId
	,SSH.strStockSalesNumber
	,SSH.dtmTransDate
	,CH.strContractNumber
	,AH.intAllocationHeaderId
	,AH.strAllocationNumber
	,PLH.intPickLotHeaderId
	,PLH.strPickLotNumber
	,CL.intCompanyLocationId
	,CL.strLocationName AS strCompanyLocation
	,CLSL.intCompanyLocationSubLocationId
	,CLSL.strSubLocationName AS strWarehouse
	,CH.dtmContractDate AS dtmSalesContractDate
	,CB.strContractBasis AS strINCOTerm
	,CEN.strName AS strCustomerName
	,CH.intCommodityId
	,CO.strCommodityCode
	,PT.strPricingType
	,0 AS intLoadId
	,'' AS strLoadNumber
	,CAST(0 AS BIT) AS ysnDelivered
	,dtmStartDate AS dtmDeliveryFrom
	,dtmEndDate AS dtmDeliveryTo
	,CD.intFutureMarketId AS intFutureMarketId
	,CD.intFutureMonthId AS intFutureMonthId
	,CD.strFixationBy AS strFixationBy
	,CD.dblCashPrice AS dblCashPrice
	,CH.ysnMultiplePriceFixation
	,CH.strPrintableRemarks
	,C.strCurrency AS strCurrency
	,CD.intCurrencyId AS intCurrencyId
	,(
		SELECT TOP 1 U2.strUnitMeasure
		FROM tblICItemUOM PU
		LEFT JOIN tblICUnitMeasure U2 ON U2.intUnitMeasureId = PU.intUnitMeasureId
		WHERE PU.intItemUOMId = CD.intPriceItemUOMId
		) AS strPriceUOM
	,CASE 
		WHEN CB.strINCOLocationType = 'City'
			THEN CT.strCity
		ELSE SL.strSubLocationName
		END AS strContractCity
	,CN.strCountry AS strContractCountry
	,SSH.intBookId
	,BO.strBook
	,SSH.intSubBookId
	,SB.strSubBook
FROM tblLGStockSalesHeader SSH
JOIN tblLGStockSalesLotDetail SSLD ON SSH.intStockSalesHeaderId = SSLD.intStockSalesHeaderId
JOIN tblLGAllocationHeader AH ON AH.intAllocationHeaderId = SSH.intAllocationHeaderId
JOIN tblLGPickLotHeader PLH ON PLH.intPickLotHeaderId = SSH.intPickLotHeaderId
JOIN tblCTContractHeader CH ON CH.intContractHeaderId = SSH.intContractHeaderId
JOIN tblCTContractDetail CD ON CD.intContractHeaderId = CH.intContractHeaderId
JOIN tblEMEntity CEN ON CEN.intEntityId = CH.intEntityId
JOIN tblICItem I ON I.intItemId = CD.intItemId
JOIN tblSMCompanyLocation CL ON CL.intCompanyLocationId = SSH.intCompanyLocationId
JOIN tblSMCompanyLocationSubLocation CLSL ON CLSL.intCompanyLocationSubLocationId = SSH.intSubLocationId
JOIN tblICCommodity CO ON CO.intCommodityId = CH.intCommodityId
JOIN tblCTPricingType PT ON PT.intPricingTypeId = CD.intPricingTypeId
LEFT JOIN tblSMCity CT ON CT.intCityId = CH.intINCOLocationTypeId
LEFT JOIN tblSMCompanyLocationSubLocation SL ON SL.intCompanyLocationSubLocationId = CH.intINCOLocationTypeId
LEFT JOIN tblSMCurrency C ON C.intCurrencyID = CD.intCurrencyId
LEFT JOIN tblCTContractBasis CB ON CB.intContractBasisId = CH.intContractBasisId
LEFT JOIN tblSMCountry CN ON CN.intCountryID = CH.intCountryId
LEFT JOIN tblCTBook BO ON BO.intBookId = SSH.intBookId
LEFT JOIN tblCTSubBook SB ON SB.intSubBookId = SSH.intSubBookId