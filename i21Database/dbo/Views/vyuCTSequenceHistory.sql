CREATE VIEW [dbo].[vyuCTSequenceHistory]
AS 

	SELECT	CA.dtmAdjustmentDate,
			'Inventory Receipt' AS	strAdjustmentType,
			IR.strReceiptNumber	AS	strNumber,
			'Balance'			AS	strFieldName,
			CA.dblOldBalance	AS	dblOldValue,
			CA.dblAdjAmount	AS	dblAdjAmount,
			CA.dblNewBalance	AS	dblNewValue,
			US.strUserName
	FROM	tblCTContractAdjustment		CA
	JOIN	tblICInventoryReceiptItem	RI	ON	RI.intInventoryReceiptItemId	=	CA.intInventoryReceiptItemId AND CA.intInventoryReceiptItemId IS NOT NULL
	JOIN	tblICInventoryReceipt		IR	ON	IR.intInventoryReceiptId		=	RI.intInventoryReceiptId
	JOIN	tblSMUserSecurity			US	ON	US.intUserSecurityID			=	CA.intUserId