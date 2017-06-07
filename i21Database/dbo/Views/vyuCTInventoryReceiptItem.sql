CREATE VIEW [dbo].[vyuCTInventoryReceiptItem]

AS 
	SELECT	CAST(ROW_NUMBER() OVER(ORDER BY strReceiptNumber ASC) AS INT) intInventoryReceiptItemId,
			*
	FROM	(
				SELECT	DISTINCT
						RI.intInventoryReceiptId,
						IR.strReceiptNumber,
						IR.strReceiptType,
						IR.intSourceType,
						CQ.intLoadId AS intShipmentId,
						CD.intContractDetailId,
						IR.intEntityVendorId,
						CH.strContractNumber + ' - ' + LTRIM(CD.intContractSeq) AS strSequenceNumber,
						SH.strLoadNumber,
						EY.strName	AS strEntityName
				FROM	tblICInventoryReceiptItem	RI
				JOIN	tblICInventoryReceipt		IR	ON	RI.intInventoryReceiptId	=	IR.intInventoryReceiptId
				JOIN	tblLGLoadDetail				CQ	ON	CQ.intLoadDetailId			=	RI.intSourceId
				JOIN	tblLGLoad					SH	ON	SH.intLoadId				=	CQ.intLoadId
				JOIN	tblCTContractDetail			CD	ON	CD.intContractDetailId		=	CQ.intPContractDetailId
				JOIN	tblCTContractHeader			CH	ON	CH.intContractHeaderId		=	CD.intContractHeaderId
				JOIN	tblEMEntity					EY	ON	EY.intEntityId				=	IR.intEntityVendorId
				WHERE	IR.strReceiptType = 'Purchase Contract' AND IR.intSourceType = 2
			)t