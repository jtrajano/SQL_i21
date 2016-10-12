CREATE VIEW vyuLGStockSaleSearch
AS
SELECT SSH.intStockSalesHeaderId
	  ,SSH.strStockSalesNumber
	  ,SSH.dtmTransDate
	  ,CH.strContractNumber
	  ,CD.intContractSeq
	  ,AH.intAllocationHeaderId
	  ,AH.strAllocationNumber
	  ,PLH.intPickLotHeaderId
	  ,PLH.strPickLotNumber
	  ,CL.intCompanyLocationId
	  ,CL.strLocationName AS strCompanyLocation
	  ,CLSL.intCompanyLocationSubLocationId 
	  ,CLSL.strSubLocationName AS strWarehouse
	  ,CH.dtmContractDate AS dtmSalesContractDate
	  ,CB.strContractBasis	AS strINCOTerm
	  ,CEN.strName AS strCustomerName
	  ,CH.intCommodityId
	  ,CO.strCommodityCode
	  ,PT.strPricingType
	  ,0 AS intLoadId
	  ,'' AS strLoadNumber
	  ,CAST(0 AS BIT) AS ysnDelivered
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
LEFT JOIN tblCTContractBasis CB ON CB.intContractBasisId = CH.intContractBasisId