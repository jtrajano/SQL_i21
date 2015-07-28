CREATE VIEW [dbo].[vyuCTSequenceHistory]
AS 

	SELECT	UH.intContractDetailId,
			UH.dtmTransactionDate		AS	dtmAdjustmentDate,
			UH.strScreenName			AS	strAdjustmentType,
			IR.strReceiptNumber			AS	strNumber,
			UH.strFieldName,
			UH.dblOldValue,
			UH.dblTransactionQuantity	AS	dblAdjAmount,
			UH.dblNewValue,
			US.strUserName
	FROM	tblCTSequenceUsageHistory	UH
	JOIN	tblICInventoryReceiptItem	RI	ON	RI.intInventoryReceiptItemId	=	UH.intExternalId 
	JOIN	tblICInventoryReceipt		IR	ON	IR.intInventoryReceiptId		=	RI.intInventoryReceiptId
	JOIN	tblSMUserSecurity			US	ON	US.intUserSecurityID			=	UH.intUserId
	WHERE	UH.strScreenName	=	'Inventory Receipt'