CREATE VIEW [dbo].[vyuCTUnpricedBasisDelivery]
AS
SELECT CAST(ROW_NUMBER() OVER (ORDER BY intContractDetailId ASC) AS INT) intUniqueId
	  , intPricingTypeId
	  , intEntityId
	  , strCustomerVendor
	  , strCommodityCode
	  , strLocationName
	  , intTicketId
	  , strTicketNumber
	  , dtmScaleDate
	  , dblNetUnits
	  , intLoadId
	  , strLoadNumber
	  , intContractHeaderId
	  , intContractDetailId
	  , strContractNumber
	  , dblScheduleQty
	  , strCustomerContract
	  , dblBasisQty
	  , dblBalance
	  , dblFutures
	  , dblBasis
	  , intInvoiceVoucherId
	  , strInvoiceVoucher
	  , intContractBasisId
	  , strContractType
FROM (SELECT	   
		  intPricingTypeId = CH.intPricingTypeId
		 ,intEntityId = EME.intEntityId
		 ,strCustomerVendor = EME.strName
		 ,strCommodityCode = ICC.strCommodityCode
		 ,strLocationName=  SML.strLocationName
		 ,intTicketId = SC.intTicketId
		 ,strTicketNumber = SC.strTicketNumber
		 , dtmScaleDate = SC.dtmTransactionDateTime
		 ,dblNetUnits = SC.dblNetUnits
		 ,intLoadId = LGL.intLoadId
		 ,strLoadNumber = ISNULL(LGL.strLoadNumber,'')
		 , intContractHeaderId = CH.intContractHeaderId
		 , intContractDetailId = SCTC.intContractDetailId
		 , strContractNumber = CH.strContractNumber + '/' + CAST(ISNULL(CD.intContractSeq,'') AS VARCHAR(MAX))
		 , dblScheduleQty = SCTC.dblScheduleQty
		 , strCustomerContract = CH.strCustomerContract
		 , dblBasisQty = CASE WHEN CH.intContractBasisId IS NOT NULL THEN 0 ELSE SCTC.dblScheduleQty END
		 , dblBalance = CD.dblBalance
		 , dblFutures = CD.dblFutures
		 , dblBasis = CD.dblBasis
		 , intInvoiceVoucherId = ISNULL(ARID.intInvoiceId, APBD.intBillId)
		 , strInvoiceVoucher = ISNULL(strInvoiceNumber,strBillId)
		 , intContractBasisId
		 , strContractType
	FROM tblSCTicket SC
	INNER JOIN tblSCTicketContractUsed SCTC
		ON SCTC.intTicketId = SC.intTicketId
	INNER JOIN tblCTContractDetail CD
		ON SCTC.intContractDetailId = CD.intContractDetailId and CD.intPricingTypeId = 2
	INNER JOIN tblCTContractHeader CH
		ON CD.intContractHeaderId = CH.intContractHeaderId and CH.intPricingTypeId = 2
	INNER JOIN tblEMEntity EME
		ON EME.intEntityId = SC.intEntityId
	INNER JOIN vyuCTGetPriceContractSequence PCS
		ON PCS.intContractDetailId = SCTC.intContractDetailId --AND PCS.intContractHeaderId = CD.intContractHeaderId
	INNER JOIN tblICItem ICI
		ON ICI.intItemId = CD.intItemId
	INNER JOIN tblICCommodity ICC
		ON ICI.intCommodityId = ICC.intCommodityId
	INNER JOIN tblSMCompanyLocation SML
		ON SML.intCompanyLocationId = SC.intProcessingLocationId
	LEFT JOIN tblLGLoad LGL
		ON LGL.intLoadId = SC.intLoadId
	LEFT JOIN tblARInvoiceDetail ARID
		ON ARID.intTicketId = SC.intTicketId and ARID.intContractDetailId = SCTC.intContractDetailId --AND ARID.intContractHeaderId = CD.intContractHeaderId
	LEFT JOIN tblARInvoice ARI
		ON ARI.intInvoiceId = ARID.intInvoiceId
	LEFT JOIN tblAPBillDetail APBD
		ON APBD.intScaleTicketId = SC.intTicketId and APBD.intContractDetailId = SCTC.intContractDetailId
	LEFT JOIN tblAPBill APB
		ON APB.intBillId = APBD.intBillId) Unpriced