CREATE VIEW [dbo].[vyuCTGridBrokerageCommissionDetail]

AS

	SELECT  BCD.intBrkgCommnDetailId,
			BCD.intBrkgCommnId,
			BCD.intContractCostId,
			BCD.dblDueEstimated,
			BCD.dblReqstdAmount,
			BCD.dblRcvdPaidAmount,
			BCD.intCreatedById,
			BCD.dtmCreated,
			BCD.intLastModifiedById,
			BCD.dtmLastModified,
			BCD.intConcurrencyId,

			CST.strStatus,
			CST.dtmDueDate,
			CST.strCurrency,
			CST.ysnReceivable,
			CST.intContractDetailId,
			CST.intVendorId,
			CST.intVendorId AS intCostEntityId,
			CST.strUOM AS strRateUOM,
			CST.dblRate,
			dbo.fnRemoveTrailingZeroes(CST.dblRate) + ' ' +CST.strCurrency + '/' + CST.strUOM AS strRateUnit,
			CST.intUOMId AS intRateUOMId,	   
			CST.strSymbol,
		  
			SEQ.strSequenceNumber,
			SEQ.dtmContractDate,
			SEQ.strItemNo,
			SEQ.strItemDescription,
			SEQ.strEntityName		 AS  strSeller, 
			SEQ.dtmStartDate,
			SEQ.dtmEndDate,
			SEQ.dblQuantity,
			SEQ.strItemUOM,
			SEQ.intItemReportUOMId,
			SEQ.strPricingType,

			HDR.strCustomerContract	AS	strSellerRef,
			HDR.strCPContract		AS	strBuyerRef,
			SEY.strName				AS	strBuyer,
			HDR.intContractHeaderId,
			HDR.strContractNumber,
			
			BC.dtmPaymentDate,
			BC.strBatchNumber,

			VCHR.strBillId,
			INVC.strInvoiceNumber

    FROM	tblCTBrkgCommnDetail	BCD
    JOIN	vyuCTContractCostView	CST ON	CST.intContractCostId   =   BCD.intContractCostId	
    JOIN	vyuCTContractSequence	SEQ ON	SEQ.intContractDetailId =   CST.intContractDetailId
    JOIN	tblCTContractHeader		HDR ON	HDR.intContractHeaderId =   CST.intContractHeaderId
    
	JOIN tblCTBrkgCommn BC ON BC.intBrkgCommnId = BCD.intBrkgCommnId
	LEFT JOIN	tblEMEntity				SEY ON	SEY.intEntityId			=   HDR.intCounterPartyId
	LEFT JOIN tblAPBill VCHR ON BC.intVoucherId = VCHR.intBillId
	LEFT JOIN tblARInvoice INVC ON BC.intInvoiceId = INVC.intInvoiceId
