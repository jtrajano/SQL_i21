﻿CREATE VIEW [dbo].[vyuAPRptWeightClaimDM]
AS
SELECT
(SELECT TOP 1	strCompanyName FROM dbo.tblSMCompanySetup) AS strCompanyName
,(SELECT TOP 1 dbo.[fnAPFormatAddress](strCompanyName, NULL, NULL, strAddress, strCity, strState, strZip, strCountry, NULL) FROM tblSMCompanySetup) as strCompanyAddress
,strShipFrom = (SELECT strFullAddress = [dbo].[fnAPFormatAddress](B2.strName,NULL, A.strShipFromAttention, A.strShipFromAddress, A.strShipFromCity, A.strShipFromState, A.strShipFromZipCode, A.strShipFromCountry, A.strShipFromPhone))
,strShipTo = (SELECT strFullAddress = [dbo].[fnAPFormatAddress](NULL,(SELECT TOP 1 strCompanyName FROM dbo.tblSMCompanySetup), A.strShipToAttention, A.strShipToAddress, A.strShipToCity, A.strShipToState, A.strShipToZipCode, A.strShipToCountry, A.strShipToPhone))
,A.strBillId
,ContactEntity.strName AS strContactName
,ContactEntity.strEmail AS strContactEmail
,strDateLocation = TranLoc.strLocationName + ', ' + CONVERT(VARCHAR(12), GETDATE(), 107)
,Bank.strBankName
,BankAccount.strBankAccountHolder
,BankAccount.strIBAN
,BankAccount.strSWIFT
,Term.strTerm
,A.strRemarks
,Bank.strCountry + ', ' + Bank.strCity + ' ' + Bank.strState AS strBankAddress
,(SELECT blbFile FROM tblSMUpload WHERE intAttachmentId = 
(	
	SELECT TOP 1
	intAttachmentId
	FROM tblSMAttachment
	WHERE strScreen = 'SystemManager.CompanyPreference'
	AND strComment = 'Footer'
	ORDER BY intAttachmentId DESC
)) AS strFooter
,transactions.*
FROM 
(
	SELECT --Weight Claim original
		strConractNumber		=	ContractHeader.strContractNumber
		,strMiscDescription		=	Item.strDescription
		,strItemNo				=	Item.strItemNo
		,strBillOfLading		=	Receipt.strBillOfLading
		,strCountryOrigin		=	ISNULL(ItemOriginCountry.strCountry, CommAttr.strDescription)
		,strAccountId			=	DetailAccount.strAccountId
		,strCurrency			=	MainCurrency.strCurrency
		,strUOM					=	QtyUOMDetails.strUnitMeasure
		,strCostUOM				=	CASE WHEN WCOrigDetails.intCostUOMId > 0 THEN ItemCostUOMMeasure.strUnitMeasure ELSE QtyUOMDetails.strUnitMeasure END
		,strLPlant				=	LPlant.strSubLocationName
		,intContractSeqId		=	ContractDetail.intContractSeq
		,intBillId				=	WCOrig.intBillId
		,dblQtyReceived			=	WCOrigDetails.dblQtyReceived
		,dblCost				=	WCOrigDetails.dblCost
		,dblTotal				=	WCOrigDetails.dblTotal
	FROM tblAPBill WCOrig
	INNER JOIN tblAPBillDetail WCOrigDetails ON WCOrig.intBillId = WCOrigDetails.intBillId
	INNER JOIN tblICItem Item ON Item.intItemId = WCOrigDetails.intItemId
	INNER JOIN (tblICItemUOM QtyUOM INNER JOIN tblICUnitMeasure QtyUOMDetails ON QtyUOM.intUnitMeasureId = QtyUOMDetails.intUnitMeasureId) 
			ON (CASE WHEN WCOrigDetails.intWeightUOMId > 0 THEN WCOrigDetails.intWeightUOMId WHEN WCOrigDetails.intCostUOMId > 0 THEN WCOrigDetails.intCostUOMId ELSE WCOrigDetails.intUnitOfMeasureId END) = QtyUOM.intItemUOMId
	INNER JOIN (tblCTContractDetail ContractDetail INNER JOIN tblCTContractHeader ContractHeader ON ContractHeader.intContractHeaderId = ContractDetail.intContractHeaderId)
			ON WCOrigDetails.intContractDetailId = ContractDetail.intContractDetailId
	INNER JOIN tblICInventoryReceiptItem ReceiptDetail INNER JOIN tblICInventoryReceipt Receipt ON ReceiptDetail.intInventoryReceiptId = Receipt.intInventoryReceiptId
			ON ReceiptDetail.intInventoryReceiptItemId = WCOrigDetails.intInventoryReceiptItemId
	INNER JOIN tblGLAccount DetailAccount ON DetailAccount.intAccountId = WCOrigDetails.intAccountId
	INNER JOIN tblSMCurrency MainCurrency ON MainCurrency.intCurrencyID = WCOrig.intCurrencyId
	LEFT JOIN (tblICItemUOM ItemCostUOM INNER JOIN tblICUnitMeasure ItemCostUOMMeasure ON ItemCostUOM.intUnitMeasureId = ItemCostUOMMeasure.intUnitMeasureId) 
			ON WCOrigDetails.intCostUOMId = ItemCostUOM.intItemUOMId
	LEFT JOIN tblICItemContract ItemContract INNER JOIN tblSMCountry ItemOriginCountry ON ItemContract.intCountryId = ItemOriginCountry.intCountryID
			ON ContractDetail.intItemContractId = ItemContract.intItemContractId
	LEFT JOIN tblICCommodityAttribute CommAttr ON CommAttr.intCommodityAttributeId = Item.intOriginId
	LEFT JOIN tblSMCompanyLocationSubLocation LPlant ON ContractDetail.intSubLocationId = LPlant.intCompanyLocationSubLocationId
	WHERE WCOrig.intTransactionType = 11
	UNION ALL --Weight Claim 2nd Version from weight claim screen
	SELECT
		strConractNumber		=	ContractHeader.strContractNumber
		,strMiscDescription		=	Item.strDescription
		,strItemNo				=	Item.strItemNo
		,strBillOfLading		=	'' --GET FROM LOAD
		,strCountryOrigin		=	ISNULL(ItemOriginCountry.strCountry, CommAttr.strDescription)
		,strAccountId			=	DetailAccount.strAccountId
		,strCurrency			=	MainCurrency.strCurrency
		,strUOM					=	QtyUOMDetails.strUnitMeasure
		,strCostUOM				=	CASE WHEN WC2Details.intCostUOMId > 0 THEN ItemCostUOMMeasure.strUnitMeasure ELSE QtyUOMDetails.strUnitMeasure END
		,strLPlant				=	LPlant.strSubLocationName
		,intContractSeqId		=	ContractDetail.intContractSeq
		,intBillId				=	WC2.intBillId
		,dblQtyReceived			=	WC2Details.dblQtyReceived
		,dblCost				=	WC2Details.dblCost
		,dblTotal				=	WC2Details.dblTotal
	FROM tblAPBill WC2
	INNER JOIN tblAPBillDetail WC2Details ON WC2.intBillId = WC2Details.intBillId
	INNER JOIN tblICItem Item ON Item.intItemId = WC2Details.intItemId
	INNER JOIN (tblICItemUOM QtyUOM INNER JOIN tblICUnitMeasure QtyUOMDetails ON QtyUOM.intUnitMeasureId = QtyUOMDetails.intUnitMeasureId) 
			ON (CASE WHEN WC2Details.intWeightUOMId > 0 THEN WC2Details.intWeightUOMId WHEN WC2Details.intCostUOMId > 0 THEN WC2Details.intCostUOMId ELSE WC2Details.intUnitOfMeasureId END) = QtyUOM.intItemUOMId
	INNER JOIN (tblCTContractDetail ContractDetail INNER JOIN tblCTContractHeader ContractHeader ON ContractHeader.intContractHeaderId = ContractDetail.intContractHeaderId)
			ON WC2Details.intContractDetailId = ContractDetail.intContractDetailId
	INNER JOIN tblGLAccount DetailAccount ON DetailAccount.intAccountId = WC2Details.intAccountId
	INNER JOIN tblSMCurrency MainCurrency ON MainCurrency.intCurrencyID = WC2.intCurrencyId
	LEFT JOIN (tblICItemUOM ItemCostUOM INNER JOIN tblICUnitMeasure ItemCostUOMMeasure ON ItemCostUOM.intUnitMeasureId = ItemCostUOMMeasure.intUnitMeasureId) 
			ON WC2Details.intCostUOMId = ItemCostUOM.intItemUOMId
	LEFT JOIN tblICItemContract ItemContract INNER JOIN tblSMCountry ItemOriginCountry ON ItemContract.intCountryId = ItemOriginCountry.intCountryID
			ON ContractDetail.intItemContractId = ItemContract.intItemContractId
	LEFT JOIN tblICCommodityAttribute CommAttr ON CommAttr.intCommodityAttributeId = Item.intOriginId
	LEFT JOIN tblSMCompanyLocationSubLocation LPlant ON ContractDetail.intSubLocationId = LPlant.intCompanyLocationSubLocationId
	WHERE WC2.intTransactionType = 11
	UNION ALL -- DEBIT MEMO
	SELECT
		strConractNumber		=	ContractHeader.strContractNumber
		,strMiscDescription		=	Item.strDescription
		,strItemNo				=	Item.strItemNo
		,strBillOfLading		=	Receipt.strBillOfLading
		,strCountryOrigin		=	ISNULL(ItemOriginCountry.strCountry, CommAttr.strDescription)
		,strAccountId			=	DetailAccount.strAccountId
		,strCurrency			=	MainCurrency.strCurrency
		,strUOM					=	QtyUOMDetails.strUnitMeasure
		,strCostUOM				=	CASE WHEN DMDetails.intCostUOMId > 0 THEN ItemCostUOMMeasure.strUnitMeasure ELSE QtyUOMDetails.strUnitMeasure END
		,strLPlant				=	LPlant.strSubLocationName
		,intContractSeqId		=	ContractDetail.intContractSeq
		,intBillId				=	DM.intBillId
		,dblQtyReceived			=	CASE WHEN DMDetails.intWeightUOMId > 0 THEN DMDetails.dblNetWeight ELSE DMDetails.dblQtyReceived END
		,dblCost				=	DMDetails.dblCost
		,dblTotal				=	DMDetails.dblTotal
	FROM tblAPBill DM
	INNER JOIN tblAPBillDetail DMDetails ON DM.intBillId = DMDetails.intBillId
	INNER JOIN tblGLAccount DetailAccount ON DetailAccount.intAccountId = DMDetails.intAccountId
	INNER JOIN tblSMCurrency MainCurrency ON MainCurrency.intCurrencyID = DM.intCurrencyId
	LEFT JOIN tblICItem Item ON Item.intItemId = DMDetails.intItemId
	LEFT JOIN (tblICItemUOM QtyUOM INNER JOIN tblICUnitMeasure QtyUOMDetails ON QtyUOM.intUnitMeasureId = QtyUOMDetails.intUnitMeasureId) 
			ON (CASE WHEN DMDetails.intWeightUOMId > 0 THEN DMDetails.intWeightUOMId WHEN DMDetails.intCostUOMId > 0 THEN DMDetails.intCostUOMId ELSE DMDetails.intUnitOfMeasureId END) = QtyUOM.intItemUOMId
	LEFT JOIN (tblCTContractDetail ContractDetail INNER JOIN tblCTContractHeader ContractHeader ON ContractHeader.intContractHeaderId = ContractDetail.intContractHeaderId)
			ON DMDetails.intContractDetailId = ContractDetail.intContractDetailId
	LEFT JOIN tblICInventoryReceiptItem ReceiptDetail INNER JOIN tblICInventoryReceipt Receipt ON ReceiptDetail.intInventoryReceiptId = Receipt.intInventoryReceiptId
			ON ReceiptDetail.intInventoryReceiptItemId = DMDetails.intInventoryReceiptItemId
	LEFT JOIN (tblICItemUOM ItemCostUOM INNER JOIN tblICUnitMeasure ItemCostUOMMeasure ON ItemCostUOM.intUnitMeasureId = ItemCostUOMMeasure.intUnitMeasureId) 
			ON DMDetails.intCostUOMId = ItemCostUOM.intItemUOMId
	LEFT JOIN tblICItemContract ItemContract INNER JOIN tblSMCountry ItemOriginCountry ON ItemContract.intCountryId = ItemOriginCountry.intCountryID
			ON ContractDetail.intItemContractId = ItemContract.intItemContractId
	LEFT JOIN tblICCommodityAttribute CommAttr ON CommAttr.intCommodityAttributeId = Item.intOriginId
	LEFT JOIN tblSMCompanyLocationSubLocation LPlant ON ContractDetail.intSubLocationId = LPlant.intCompanyLocationSubLocationId
	WHERE DM.intTransactionType = 3
) transactions
INNER JOIN tblAPBill A ON transactions.intBillId = A.intBillId
INNER JOIN (tblAPVendor B INNER JOIN tblEMEntity B2 ON B.intEntityVendorId = B2.intEntityId)
	ON A.intEntityVendorId = B.intEntityVendorId
LEFT JOIN tblEMEntity ContactEntity ON A.intEntityId = ContactEntity.intEntityId
LEFT JOIN tblSMCompanyLocation TranLoc ON A.intStoreLocationId = TranLoc.intCompanyLocationId
LEFT JOIN tblCMBankAccount BankAccount ON BankAccount.intBankAccountId = A.intBankInfoId
LEFT JOIN tblCMBank Bank ON BankAccount.intBankId = Bank.intBankId
LEFT JOIN tblSMTerm Term ON A.intTermsId = Term.intTermID

