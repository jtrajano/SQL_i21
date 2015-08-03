CREATE VIEW [dbo].[vyuCTSequenceUsageHistory]
AS 

	SELECT	UH.intSequenceUsageHistoryId,
			UH.intContractDetailId,
			CD.intContractHeaderId,
			CD.intContractSeq,
			UH.dtmTransactionDate,
			UH.strScreenName,
			IR.strReceiptNumber	AS	strNumber,
			UH.strFieldName,
			UH.dblOldValue,
			UH.dblTransactionQuantity,
			UH.dblNewValue,
			US.strUserName
	FROM	tblCTSequenceUsageHistory	UH
	JOIN	tblCTContractDetail			CD	ON	CD.intContractDetailId			=	UH.intContractDetailId
	JOIN	tblICInventoryReceiptItem	RI	ON	RI.intInventoryReceiptItemId	=	UH.intExternalId 
	JOIN	tblICInventoryReceipt		IR	ON	IR.intInventoryReceiptId		=	RI.intInventoryReceiptId
	JOIN	tblSMUserSecurity			US	ON	US.intUserSecurityID			=	UH.intUserId
	WHERE	UH.strScreenName	=	'Inventory Receipt'

	UNION ALL

	SELECT	UH.intSequenceUsageHistoryId,
			UH.intContractDetailId,
			CD.intContractHeaderId,
			CD.intContractSeq,
			UH.dtmTransactionDate,
			UH.strScreenName,
			HR.strInvoiceNumber	AS	strNumber,
			UH.strFieldName,
			UH.dblOldValue,
			UH.dblTransactionQuantity,
			UH.dblNewValue,
			US.strUserName
	FROM	tblCTSequenceUsageHistory	UH
	JOIN	tblCTContractDetail			CD	ON	CD.intContractDetailId			=	UH.intContractDetailId
	JOIN	tblARInvoiceDetail			DL	ON	DL.intInvoiceDetailId			=	UH.intExternalId 
	JOIN	tblARInvoice				HR	ON	HR.intInvoiceId					=	DL.intInvoiceId
	JOIN	tblSMUserSecurity			US	ON	US.intUserSecurityID			=	UH.intUserId
	WHERE	UH.strScreenName	=	'Invoice'