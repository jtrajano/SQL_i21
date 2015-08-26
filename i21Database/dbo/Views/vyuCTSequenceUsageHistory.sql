CREATE VIEW [dbo].[vyuCTSequenceUsageHistory]
AS 

	SELECT	UH.intSequenceUsageHistoryId,
			UH.intContractDetailId,
			CD.intContractHeaderId,
			CD.intContractSeq,
			UH.dtmTransactionDate,
			UH.strScreenName,
			LTRIM(IR.strReceiptNumber)	AS	strNumber,
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
			LTRIM(HR.strInvoiceNumber)	AS	strNumber,
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

	UNION ALL

	SELECT	UH.intSequenceUsageHistoryId,
			UH.intContractDetailId,
			CD.intContractHeaderId,
			CD.intContractSeq,
			UH.dtmTransactionDate,
			UH.strScreenName,
			LTRIM(DL.intLoadNumber)	AS	strNumber,
			UH.strFieldName,
			UH.dblOldValue,
			UH.dblTransactionQuantity,
			UH.dblNewValue,
			US.strUserName
	FROM	tblCTSequenceUsageHistory	UH
	JOIN	tblCTContractDetail			CD	ON	CD.intContractDetailId			=	UH.intContractDetailId
	JOIN	tblLGLoad					DL	ON	DL.intLoadId					=	UH.intExternalId 
	JOIN	tblSMUserSecurity			US	ON	US.intUserSecurityID			=	UH.intUserId
	WHERE	UH.strScreenName	=	'Load Schedule'

	UNION ALL

	SELECT	UH.intSequenceUsageHistoryId,
			UH.intContractDetailId,
			CD.intContractHeaderId,
			CD.intContractSeq,
			UH.dtmTransactionDate,
			'Transport'	AS strScreenName,
			LTRIM(HR.strTransaction)	AS	strNumber,
			UH.strFieldName,
			UH.dblOldValue,
			UH.dblTransactionQuantity,
			UH.dblNewValue,
			US.strUserName
	FROM	tblCTSequenceUsageHistory	UH
	JOIN	tblCTContractDetail			CD	ON	CD.intContractDetailId			=	UH.intContractDetailId
	JOIN	tblTRTransportReceipt		DL	ON	DL.intTransportReceiptId		=	UH.intExternalId 
	JOIN	tblTRTransportLoad			HR	ON	HR.intTransportLoadId			=	DL.intTransportLoadId
	JOIN	tblSMUserSecurity			US	ON	US.intUserSecurityID			=	UH.intUserId
	WHERE	UH.strScreenName	=	'Transport Purchase'
	
	UNION ALL

	SELECT	UH.intSequenceUsageHistoryId,
			UH.intContractDetailId,
			CD.intContractHeaderId,
			CD.intContractSeq,
			UH.dtmTransactionDate,
			'Transport'	AS strScreenName,
			LTRIM(HR.strTransaction)	AS	strNumber,
			UH.strFieldName,
			UH.dblOldValue,
			UH.dblTransactionQuantity,
			UH.dblNewValue,
			US.strUserName
	FROM	tblCTSequenceUsageHistory	UH
	JOIN	tblCTContractDetail			CD	ON	CD.intContractDetailId			=	UH.intContractDetailId
	JOIN	tblTRDistributionHeader		DL	ON	DL.intDistributionHeaderId		=	UH.intExternalId 
	JOIN	tblTRTransportReceipt		TR	ON	TR.intTransportReceiptId		=	DL.intTransportReceiptId 	
	JOIN	tblTRTransportLoad			HR	ON	HR.intTransportLoadId			=	TR.intTransportLoadId
	JOIN	tblSMUserSecurity			US	ON	US.intUserSecurityID			=	UH.intUserId
	WHERE	UH.strScreenName	=	'Transport Sale'

	UNION ALL

	SELECT	UH.intSequenceUsageHistoryId,
			UH.intContractDetailId,
			CD.intContractHeaderId,
			CD.intContractSeq,
			UH.dtmTransactionDate,
			UH.strScreenName,
			LTRIM(DL.intTicketNumber)	AS	strNumber,
			UH.strFieldName,
			UH.dblOldValue,
			UH.dblTransactionQuantity,
			UH.dblNewValue,
			US.strUserName
	FROM	tblCTSequenceUsageHistory	UH
	JOIN	tblCTContractDetail			CD	ON	CD.intContractDetailId		=	UH.intContractDetailId
	JOIN	tblSCTicket					DL	ON	DL.intTicketId				=	UH.intExternalId 
	JOIN	tblSMUserSecurity			US	ON	US.intUserSecurityID		=	UH.intUserId
	WHERE	UH.strScreenName	=	'Scale'