CREATE VIEW [dbo].[vyuCTCleanCost]

AS
	
	SELECT	RI.intCleanCostId,
			IR.strReceiptNumber,
			CH.strContractNumber + ' - ' + LTRIM(CD.intContractSeq) AS strSequenceNumber,
			SH.strLoadNumber,
			EY.strName	AS strEntityName
	FROM	tblCTCleanCost				RI
	JOIN	tblICInventoryReceipt		IR	ON	RI.intInventoryReceiptId	=	IR.intInventoryReceiptId
	JOIN	tblLGLoad					SH	ON	SH.intLoadId				=	RI.intShipmentId
	JOIN	tblCTContractDetail			CD	ON	CD.intContractDetailId		=	RI.intContractDetailId
	JOIN	tblCTContractHeader			CH	ON	CH.intContractHeaderId		=	CD.intContractHeaderId
	JOIN	tblEMEntity					EY	ON	EY.intEntityId				=	RI.intEntityId
