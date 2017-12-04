﻿CREATE VIEW [dbo].[vyuCTGridBrokerageCommissionDetail]

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
			dbo.fnRemoveTrailingZeroes(CST.dblRate) + ' ' +CST.strCurrency + '/' + CST.strUOM AS strRateUnit,	   
		  
			SEQ.strSequenceNumber,
			SEQ.dtmContractDate,
			SEQ.strItemNo,
			SEQ.strEntityName		 AS  strBuyer, 
			SEQ.dtmStartDate,
			SEQ.dtmEndDate,
			SEQ.dblQuantity,
			SEQ.strItemUOM,

			HDR.strCustomerContract AS	strBuyerRef,
			HDR.strCPContract		 AS	strSellerRef,
			SEY.strName			 AS	strSeller

    FROM	tblCTBrkgCommnDetail	BCD
    JOIN	vyuCTContractCostView	CST ON	CST.intContractCostId   =   BCD.intContractCostId	
    JOIN	vyuCTContractSequence	SEQ ON	SEQ.intContractDetailId =   CST.intContractDetailId
    JOIN	tblCTContractHeader		HDR ON	HDR.intContractHeaderId =   CST.intContractHeaderId
    JOIN	tblEMEntity				SEY ON	SEY.intEntityId			=   HDR.intCounterPartyId
