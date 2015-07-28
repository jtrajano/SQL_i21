CREATE VIEW [dbo].[vyuCTSequenceUsageHistory]
AS 

	SELECT	UH.intSequenceUsageHistoryId,
			UH.intContractDetailId,
			UH.dtmTransactionDate,
			UH.strScreenName,
			IR.strReceiptNumber	AS	strNumber,
			UH.strFieldName,
			UH.dblOldValue,
			UH.dblTransactionQuantity,
			UH.dblNewValue,
			US.strUserName
	FROM	tblCTSequenceUsageHistory	UH
	JOIN	tblICInventoryReceiptItem	RI	ON	RI.intInventoryReceiptItemId	=	UH.intExternalId 
	JOIN	tblICInventoryReceipt		IR	ON	IR.intInventoryReceiptId		=	RI.intInventoryReceiptId
	JOIN	tblSMUserSecurity			US	ON	US.intUserSecurityID			=	UH.intUserId
	WHERE	UH.strScreenName	=	'Inventory Receipt'