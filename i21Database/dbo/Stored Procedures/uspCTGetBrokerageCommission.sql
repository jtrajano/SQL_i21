CREATE PROCEDURE [dbo].[uspCTGetBrokerageCommission]
	@intEntityId			INT			= NULL,
    @strStatus				NVARCHAR(50)= NULL,
    @intContractHeaderId	INT			= NULL,
    @ysnSummary				BIT			= 0
AS 

		SELECT  CST.intContractCostId,
				CST.dblReqstdAmount,
				CST.dblRcvdPaidAmount,
				CST.strStatus,
				dbo.fnRemoveTrailingZeroes(CST.dblRate) + ' ' +CST.strCurrency + '/' + CST.strUOM AS strRateUnit,
	   
				SEQ.strSequenceNumber,
				SEQ.dtmContractDate,
				SEQ.strItemNo,
				SEQ.strEntityName		AS  strBuyer, 
				SEQ.dtmStartDate,
				SEQ.dtmEndDate,
				SEQ.dblQuantity,
				SEQ.strItemUOM,

				HDR.strCustomerContract AS	 strBuyerRef,
				HDR.strCPContract		AS	 strSellerRef,
	   
				SEY.strName				AS	 strSeller

		FROM	vyuCTContractCostView	CST
		JOIN	vyuCTContractSequence	SEQ	ON	SEQ.intContractDetailId =   CST.intContractDetailId
		JOIN	tblCTContractHeader		HDR ON	HDR.intContractHeaderId =   CST.intContractHeaderId
		JOIN	tblEMEntity				SEY ON	SEY.intEntityId			=   HDR.intCounterPartyId
		JOIN	tblICItem				CIM	ON	CIM.intItemId		    =   CST.intItemId 
											AND	CIM.strCostType			=   'Commission'

		WHERE	CST.intVendorId				=   ISNULL(@intEntityId,CST.intVendorId)
		AND		ISNULL(CST.strStatus,'')	=   ISNULL(@strStatus,ISNULL(CST.strStatus,''))
		AND		HDR.intContractHeaderId		=	ISNULL(@intContractHeaderId,HDR.intContractHeaderId)
