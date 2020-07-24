CREATE VIEW [dbo].[vyuAPRptWeightClaimDM]
AS
SELECT DISTINCT
(SELECT TOP 1	strCompanyName FROM dbo.tblSMCompanySetup) AS strCompanyName
--,(SELECT TOP 1 dbo.[fnAPFormatAddress](strCompanyName, NULL, NULL, strAddress, strCity, strState, strZip, strCountry, NULL) FROM tblSMCompanySetup) as strCompanyAddress
,strCompanyAddress = (SELECT TOP 1 ISNULL(RTRIM(strCompanyName) + CHAR(13) + char(10), '')
				 + ISNULL(RTRIM(strAddress) + CHAR(13) + char(10), '')
				 + ISNULL(RTRIM(strZip),'') + ' ' + ISNULL(RTRIM(strCity), '') + ' ' + ISNULL(RTRIM(strState), '') + CHAR(13) + char(10)
				 + ISNULL('' + RTRIM(strCountry) + CHAR(13) + char(10), '')
				 + ISNULL(RTRIM(strPhone)+ CHAR(13) + char(10), '') FROM tblSMCompanySetup)
,strShipFrom = (SELECT strFullAddress = [dbo].[fnAPFormatAddress](B2.strName,NULL, A.strShipFromAttention, A.strShipFromAddress, A.strShipFromCity, A.strShipFromState, A.strShipFromZipCode, A.strShipFromCountry, A.strShipFromPhone)) COLLATE Latin1_General_CI_AS
,strShipTo = (SELECT strFullAddress = [dbo].[fnAPFormatAddress](NULL,(SELECT TOP 1 strCompanyName FROM dbo.tblSMCompanySetup), A.strShipToAttention, A.strShipToAddress, A.strShipToCity, A.strShipToState, A.strShipToZipCode, A.strShipToCountry, A.strShipToPhone)) COLLATE Latin1_General_CI_AS
,A.strBillId
,ContactEntity.strName AS strContactName
,ContactEntity.strEmail AS strContactEmail
,strDateLocation = TranLoc.strLocationName + ', ' + CONVERT(VARCHAR(12), GETDATE(), 106)
,Bank.strBankName
,BankAccount.strBankAccountHolder
,BankAccount.strIBAN
,BankAccount.strSWIFT
,Term.strTerm
,A.strRemarks
,CONVERT(VARCHAR(10), A.dtmDueDate, 103) COLLATE Latin1_General_CI_AS AS dtmDueDate
,Bank.strCity + ', ' + Bank.strState +  ' ' + Bank.strCountry AS strBankAddress
--,(SELECT blbFile FROM tblSMUpload WHERE intAttachmentId = 
--(	
--	SELECT TOP 1
--	intAttachmentId
--	FROM tblSMAttachment
--	WHERE strScreen = 'SystemManager.CompanyPreference'
--	AND strComment = 'Footer'
--	ORDER BY intAttachmentId DESC
--)) AS strFooter
,transactions.*
FROM 
(
	--SELECT --Weight Claim original
	--	strContractNumber		=	ContractHeader.strContractNumber
	--	,strMiscDescription		=	Item.strDescription
	--	,strItemNo				=	Item.strItemNo
	--	,strBillOfLading		=	Receipt.strBillOfLading
	--	,strCountryOrigin		=	ISNULL(ItemOriginCountry.strCountry, CommAttr.strDescription)
	--	,strAccountId			=	DetailAccount.strAccountId
	--	,strCurrency			=	MainCurrency.strCurrency
	--	,strUOM					=	QtyUOMDetails.strUnitMeasure
	--	,strCostUOM				=	CASE WHEN WCOrigDetails.intCostUOMId > 0 THEN ItemCostUOMMeasure.strUnitMeasure ELSE QtyUOMDetails.strUnitMeasure END
	--	,strLPlant				=	LPlant.strSubLocationName
	--	,intContractSeqId		=	ContractDetail.intContractSeq
	--	,intBillId				=	WCOrig.intBillId
	--	,dblQtyReceived			=	WCOrigDetails.dblQtyReceived
	--	,dblCost				=	WCOrigDetails.dblCost
	--	,dblTotal				=	WCOrigDetails.dblTotal
	--FROM tblAPBill WCOrig
	--INNER JOIN tblAPBillDetail WCOrigDetails ON WCOrig.intBillId = WCOrigDetails.intBillId
	--INNER JOIN tblICItem Item ON Item.intItemId = WCOrigDetails.intItemId
	--INNER JOIN (tblICItemUOM QtyUOM INNER JOIN tblICUnitMeasure QtyUOMDetails ON QtyUOM.intUnitMeasureId = QtyUOMDetails.intUnitMeasureId) 
	--		ON (CASE WHEN WCOrigDetails.intWeightUOMId > 0 THEN WCOrigDetails.intWeightUOMId WHEN WCOrigDetails.intCostUOMId > 0 THEN WCOrigDetails.intCostUOMId ELSE WCOrigDetails.intUnitOfMeasureId END) = QtyUOM.intItemUOMId
	--INNER JOIN (tblCTContractDetail ContractDetail INNER JOIN tblCTContractHeader ContractHeader ON ContractHeader.intContractHeaderId = ContractDetail.intContractHeaderId)
	--		ON WCOrigDetails.intContractDetailId = ContractDetail.intContractDetailId
	--INNER JOIN tblICInventoryReceiptItem ReceiptDetail INNER JOIN tblICInventoryReceipt Receipt ON ReceiptDetail.intInventoryReceiptId = Receipt.intInventoryReceiptId
	--		ON ReceiptDetail.intInventoryReceiptItemId = WCOrigDetails.intInventoryReceiptItemId
	--INNER JOIN tblGLAccount DetailAccount ON DetailAccount.intAccountId = WCOrigDetails.intAccountId
	--INNER JOIN tblSMCurrency MainCurrency ON MainCurrency.intCurrencyID = WCOrig.intCurrencyId
	--LEFT JOIN (tblICItemUOM ItemCostUOM INNER JOIN tblICUnitMeasure ItemCostUOMMeasure ON ItemCostUOM.intUnitMeasureId = ItemCostUOMMeasure.intUnitMeasureId) 
	--		ON WCOrigDetails.intCostUOMId = ItemCostUOM.intItemUOMId
	--LEFT JOIN tblICItemContract ItemContract INNER JOIN tblSMCountry ItemOriginCountry ON ItemContract.intCountryId = ItemOriginCountry.intCountryID
	--		ON ContractDetail.intItemContractId = ItemContract.intItemContractId
	--LEFT JOIN tblICCommodityAttribute CommAttr ON CommAttr.intCommodityAttributeId = Item.intOriginId
	--LEFT JOIN tblSMCompanyLocationSubLocation LPlant ON ContractDetail.intSubLocationId = LPlant.intCompanyLocationSubLocationId
	--WHERE WCOrig.intTransactionType = 11
	--UNION ALL --Weight Claim 2nd Version from weight claim screen
	SELECT
		strContractNumber		=	ContractHeader.strContractNumber
		,strMiscDescription		=	CASE WHEN WC2Details.intContractDetailId > 0
												AND ContractDetail.intItemContractId > 0
												AND WC2Details.intContractCostId IS NULL
										THEN ItemContract.strContractItemName
										ELSE ISNULL(Item.strDescription,'')
									END
		,strItemNo				=	Item.strItemNo
		,strBillOfLading		=	(SELECT TOP 1 Loads.strBLNumber FROM tblLGLoad Loads WHERE Loads.intLoadId = WC2Details.intLoadId)--GET FROM LOAD --GET FROM LOAD
		,strCountryOrigin		=	ISNULL(ItemOriginCountry.strCountry, CommAttr.strDescription)
		,strAccountId			=	DetailAccount.strAccountId
		,strCurrency			=	MainCurrency.strCurrency
		,strConcern				=	'Weight Claim' COLLATE Latin1_General_CI_AS
		,strUOM					=	QtyUOMDetails.strUnitMeasure
		,strClaimUOM			=	QtyUOMDetails.strUnitMeasure
		,strCostUOM				=	CASE WHEN WC2Details.intCostUOMId > 0 THEN ItemCostUOMMeasure.strUnitMeasure ELSE QtyUOMDetails.strUnitMeasure END
		,strLPlant				=	LPlant.strSubLocationName
		,intContractSeqId		=	ContractDetail.intContractSeq
		,intBillId				=	WC2.intBillId
		,dblQtyReceived			=	WC2Details.dblWeightLoss - WC2Details.dblFranchiseWeight--CASE WHEN WC2Details.intWeightUOMId > 0 THEN WC2Details.dblNetWeight ELSE WC2Details.dblQtyReceived END
		,dblCost				=	WC2Details.dblCost
		,dblTotal				=	WC2Details.dblTotal + WC2Details.dblTax
		,dblNetShippedWeight	=	WC2Details.dblNetShippedWeight
		,dblWeightLoss			=	dblWeightLoss--WC2Details.dblNetShippedWeight - WC2Details.dblQtyReceived
		,dblLandedWeight		=	CASE WHEN WC2Details.intWeightUOMId > 0 THEN WC2Details.dblNetWeight ELSE WC2Details.dblQtyReceived END
		,dblFranchiseWeight		=	WC2Details.dblFranchiseWeight
		,dblClaimAmount			=	WC2Details.dblClaimAmount
		,strERPPONumber			=	ContractDetail.strERPPONumber
		,strContainerNumber		=	ISNULL(LCointainer.strContainerNumber, (SELECT TOP 1 LoadContainer.strContainerNumber FROM tblLGLoadContainer LoadContainer WHERE LoadContainer.intLoadId = WC2Details.intLoadId))
	FROM tblAPBill WC2
	INNER JOIN tblAPBillDetail WC2Details ON WC2.intBillId = WC2Details.intBillId
	INNER JOIN tblICItem Item ON Item.intItemId = WC2Details.intItemId
	INNER JOIN (tblICItemUOM QtyUOM INNER JOIN tblICUnitMeasure QtyUOMDetails ON QtyUOM.intUnitMeasureId = QtyUOMDetails.intUnitMeasureId) 
			ON (CASE WHEN WC2Details.intWeightUOMId > 0 THEN WC2Details.intWeightUOMId WHEN WC2Details.intCostUOMId > 0 THEN WC2Details.intCostUOMId ELSE WC2Details.intUnitOfMeasureId END) = QtyUOM.intItemUOMId
	INNER JOIN (tblCTContractDetail ContractDetail INNER JOIN tblCTContractHeader ContractHeader ON ContractHeader.intContractHeaderId = ContractDetail.intContractHeaderId)
			ON WC2Details.intContractDetailId = ContractDetail.intContractDetailId
	LEFT JOIN tblGLAccount DetailAccount ON DetailAccount.intAccountId = WC2Details.intAccountId
	INNER JOIN tblSMCurrency MainCurrency ON MainCurrency.intCurrencyID = WC2Details.intCurrencyId
	LEFT JOIN (tblICItemUOM ItemCostUOM INNER JOIN tblICUnitMeasure ItemCostUOMMeasure ON ItemCostUOM.intUnitMeasureId = ItemCostUOMMeasure.intUnitMeasureId) 
			ON WC2Details.intCostUOMId = ItemCostUOM.intItemUOMId
	LEFT JOIN tblICItemContract ItemContract INNER JOIN tblSMCountry ItemOriginCountry ON ItemContract.intCountryId = ItemOriginCountry.intCountryID
			ON ContractDetail.intItemContractId = ItemContract.intItemContractId
	LEFT JOIN tblICCommodityAttribute CommAttr ON CommAttr.intCommodityAttributeId = Item.intOriginId
	LEFT JOIN tblSMCompanyLocationSubLocation LPlant ON ContractDetail.intSubLocationId = LPlant.intCompanyLocationSubLocationId
	LEFT JOIN dbo.tblICInventoryReceiptItem ReceiptDetail ON ReceiptDetail.intInventoryReceiptItemId = WC2Details.intInventoryReceiptItemId
	LEFT JOIN tblLGLoadContainer LCointainer ON LCointainer.intLoadContainerId = ReceiptDetail.intContainerId
	LEFT JOIN tblLGLoad Loads ON Loads.intLoadId = LCointainer.intLoadId
	WHERE WC2.intTransactionType = 11
	UNION ALL -- DEBIT MEMO
	SELECT
		strContractNumber		=	ContractHeader.strContractNumber
		,strMiscDescription		=	CASE WHEN DMDetails.intContractDetailId > 0
												AND ContractDetail.intItemContractId > 0
												AND DMDetails.intContractCostId IS NULL
										THEN ItemContract.strContractItemName
										ELSE ISNULL(Item.strDescription,DMDetails.strMiscDescription)
									END
		,strItemNo				=	Item.strItemNo
		,strBillOfLading		=	Receipt.strBillOfLading
		,strCountryOrigin		=	ISNULL(ItemOriginCountry.strCountry, CommAttr.strDescription)
		,strAccountId			=	DetailAccount.strAccountId
		,strCurrency			=	MainCurrency.strCurrency
		,strConcern				=	CASE WHEN Receipt.intInventoryReceiptId IS NOT NULL AND Receipt.strReceiptType = 'Inventory Return'
										THEN  'Container Rejection - Commodity cost' 
										WHEN DMDetails.intLoadId > 0 THEN 'Weight Claim'
										ELSE ''
										END COLLATE Latin1_General_CI_AS 
		,strUOM					=	QtyUOMDetails.strUnitMeasure
		,strClaimUOM			=	''
		,strCostUOM				=	CASE WHEN DMDetails.intCostUOMId > 0 THEN ItemCostUOMMeasure.strUnitMeasure ELSE QtyUOMDetails.strUnitMeasure END
		,strLPlant				=	LPlant.strSubLocationName
		,intContractSeqId		=	ContractDetail.intContractSeq
		,intBillId				=	DM.intBillId
		,dblQtyReceived			=	CASE WHEN DMDetails.intWeightUOMId > 0 THEN DMDetails.dblNetWeight ELSE DMDetails.dblQtyReceived END
		,dblCost				=	DMDetails.dblCost
		,dblTotal				=	DMDetails.dblTotal  + ISNULL(DM.dblTax,0)
		,dblNetShippedWeight	=	0 --DMDetails.dblNetShippedWeight
		,dblWeightLoss			=	0 --dblWeightLoss
		,dblLandedWeight		=	0 --CASE WHEN DMDetails.intWeightUOMId > 0 THEN DMDetails.dblNetWeight ELSE DMDetails.dblQtyReceived END
		,dblFranchiseWeight		=	0 --DMDetails.dblFranchiseWeight
		,dblClaimAmount			=	0 --DMDetails.dblClaimAmount
		,strERPPONumber			=	ContractDetail.strERPPONumber
		,strContractNumber		=	LCointainer.strContainerNumber
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
	LEFT JOIN tblLGLoadContainer LCointainer ON LCointainer.intLoadContainerId = ReceiptDetail.intContainerId
	WHERE DM.intTransactionType = 3
	UNION ALL -- Voucher
	--SELECT
	--	strContractNumber		=	ContractHeader.strContractNumber
	--	,strMiscDescription		=	Item.strDescription
	--	,strItemNo				=	CASE WHEN Item.strType = 'Other Charge' THEN '' ELSE Item.strItemNo END --AP-3233
	--	,strBillOfLading		=	Receipt.strBillOfLading
	--	,strCountryOrigin		=	CASE WHEN ContractDetail.intItemId IS NOT NULL THEN ISNULL(ItemOriginCountry.strCountry, CommAttr.strDescription)
	--									ELSE ''
	--									END
	--	,strAccountId			=	DetailAccount.strAccountId
	--	,strCurrency			=	CASE WHEN DMDetails.ysnSubCurrency > 0 AND SubCurrency.intConcurrencyId > 0
	--									THEN SubCurrency.strCurrency
	--								ELSE MainCurrency.strCurrency
	--								END
	--	,strConcern				=	''
	--	,strUOM					=	QtyUOMDetails.strUnitMeasure
	--	,strClaimUOM			=	''
	--	,strCostUOM				=	CASE WHEN DMDetails.intCostUOMId > 0 THEN ItemCostUOMMeasure.strUnitMeasure 
	--									ELSE QtyUOMDetails.strUnitMeasure END
	--	,strLPlant				=	LPlant.strSubLocationName
	--	,intContractSeqId		=	ContractDetail.intContractSeq
	--	,intBillId				=	DM.intBillId
	--	,dblQtyReceived			=	CASE WHEN DMDetails.intWeightUOMId > 0 THEN DMDetails.dblNetWeight
	--								 ELSE DMDetails.dblQtyReceived 
	--								END
	--	,dblCost				=	DMDetails.dblCost
	--	,dblTotal				=	DMDetails.dblTotal
	--	,dblNetShippedWeight	=	0 --DMDetails.dblNetShippedWeight
	--	,dblWeightLoss			=	0 --dblWeightLoss
	--	,dblLandedWeight		=	0 --CASE WHEN DMDetails.intWeightUOMId > 0 THEN DMDetails.dblNetWeight ELSE DMDetails.dblQtyReceived END
	--	,dblFranchiseWeight		=	0 --DMDetails.dblFranchiseWeight
	--	,dblClaimAmount			=	0 --DMDetails.dblClaimAmount
	--	,strERPPONumber			=	ContractDetail.strERPPONumber
	--FROM tblAPBill DM
	--INNER JOIN tblAPBillDetail DMDetails ON DM.intBillId = DMDetails.intBillId
	--INNER JOIN tblGLAccount DetailAccount ON DetailAccount.intAccountId = DMDetails.intAccountId
	--INNER JOIN tblSMCurrency MainCurrency ON MainCurrency.intCurrencyID = DM.intCurrencyId
	--LEFT JOIN tblSMCurrency SubCurrency ON DM.intCurrencyId = SubCurrency.intMainCurrencyId AND SubCurrency.ysnSubCurrency = 1
	--LEFT JOIN tblICItem Item ON Item.intItemId = DMDetails.intItemId
	--LEFT JOIN (tblICItemUOM QtyUOM INNER JOIN tblICUnitMeasure QtyUOMDetails ON QtyUOM.intUnitMeasureId = QtyUOMDetails.intUnitMeasureId) 
	--		ON (CASE WHEN DMDetails.intWeightUOMId > 0 THEN DMDetails.intWeightUOMId WHEN DMDetails.intCostUOMId > 0 THEN DMDetails.intCostUOMId ELSE DMDetails.intUnitOfMeasureId END) = QtyUOM.intItemUOMId
	--LEFT JOIN (tblCTContractDetail ContractDetail 
	--				INNER JOIN tblCTContractHeader ContractHeader ON ContractHeader.intContractHeaderId = ContractDetail.intContractHeaderId
	--					--LEFT JOIN tblCTContractCost ContractCost ON ContractDetail.intContractDetailId = ContractCost.intContractDetailId
	--					)ON DMDetails.intContractDetailId = ContractDetail.intContractDetailId
	----LEFT JOIN (tblICItemUOM ContractCostItemUOM INNER JOIN tblICUnitMeasure ContractCostItemMeasure ON ContractCostItemUOM.intUnitMeasureId = ContractCostItemMeasure.intUnitMeasureId)
	----							ON ContractCostItemUOM.intItemUOMId = ContractCost.intItemUOMId
	--LEFT JOIN tblICInventoryReceiptItem ReceiptDetail INNER JOIN tblICInventoryReceipt Receipt ON ReceiptDetail.intInventoryReceiptId = Receipt.intInventoryReceiptId
	--		ON ReceiptDetail.intInventoryReceiptItemId = DMDetails.intInventoryReceiptItemId
	--LEFT JOIN (tblICItemUOM ItemCostUOM INNER JOIN tblICUnitMeasure ItemCostUOMMeasure ON ItemCostUOM.intUnitMeasureId = ItemCostUOMMeasure.intUnitMeasureId) 
	--		ON DMDetails.intCostUOMId = ItemCostUOM.intItemUOMId
	--LEFT JOIN tblICItemContract ItemContract INNER JOIN tblSMCountry ItemOriginCountry ON ItemContract.intCountryId = ItemOriginCountry.intCountryID
	--		ON ContractDetail.intItemContractId = ItemContract.intItemContractId
	--LEFT JOIN tblICCommodityAttribute CommAttr ON CommAttr.intCommodityAttributeId = Item.intOriginId
	--LEFT JOIN tblSMCompanyLocationSubLocation LPlant ON ContractDetail.intSubLocationId = LPlant.intCompanyLocationSubLocationId
	--WHERE DM.intTransactionType = 1 AND DMDetails.intContractCostId IS NULL
	--UNION ALL
	SELECT
		strContractNumber		=	ContractHeader.strContractNumber
		,strMiscDescription		=	CASE WHEN DMDetails.intContractDetailId > 0
												AND ContractDetail.intItemContractId > 0
												AND DMDetails.intContractCostId IS NULL
										THEN ItemContract.strContractItemName
										ELSE ISNULL(Item.strDescription,'')
									END
		,strItemNo				=	CASE WHEN Item.strType = 'Other Charge' THEN '' ELSE Item.strItemNo END --AP-3233
		,strBillOfLading		=	Receipt.strBillOfLading
		,strCountryOrigin		=	CASE WHEN ContractDetail.intItemId > 0 THEN 
											(CASE WHEN ItemContract.intItemContractId > 0 THEN ItemOriginCountry.strCountry ELSE CommAttr.strDescription END)
										ELSE ''
										END
		,strAccountId			=	DetailAccount.strAccountId
		,strCurrency			=	CASE WHEN ContractCost.intContractCostId > 0 AND ContractCost.strCostMethod IN ('Percentage','Amount') 
												THEN ISNULL(ContractCostCurrency.strCurrency,MainCurrency.strCurrency) --AP-3308
										WHEN DMDetails.intContractDetailId IS NULL  AND DMDetails.intInventoryReceiptItemId IS NULL THEN MainCurrency.strCurrency
										WHEN DMDetails.ysnSubCurrency > 0 AND SubCurrency.intConcurrencyId > 0
										THEN SubCurrency.strCurrency
									ELSE MainCurrency.strCurrency
									END
		,strConcern				=	'' COLLATE Latin1_General_CI_AS 
		,strUOM					=	CASE WHEN DMDetails.intContractDetailId IS NULL AND DMDetails.intInventoryReceiptItemId IS NULL THEN QtyUOMDetails.strUnitMeasure 
										WHEN ContractCost.intContractCostId > 0 AND ContractCost.strCostMethod IN ('Percentage','Amount') 
												THEN NULL 
										WHEN ContractCost.intContractCostId > 0 THEN ContractCostItemMeasure.strUnitMeasure
										ELSE QtyUOMDetails.strUnitMeasure
										END
		,strClaimUOM			=	''
		,strCostUOM				=	CASE WHEN DMDetails.intContractDetailId IS NULL AND DMDetails.intInventoryReceiptItemId IS NULL THEN NULL 
										WHEN ContractCost.intContractCostId > 0 AND ContractCost.strCostMethod IN ('Percentage','Amount') 
												THEN NULL
											WHEN DMDetails.intCostUOMId > 0 THEN ItemCostUOMMeasure.strUnitMeasure 
										ELSE QtyUOMDetails.strUnitMeasure END
		,strLPlant				=	LPlant.strSubLocationName
		,intContractSeqId		=	ContractDetail.intContractSeq
		,intBillId				=	DM.intBillId
		,dblQtyReceived			=	CASE WHEN ContractCost.intContractCostId > 0 AND ContractCost.strCostMethod IN ('Percentage','Amount') 
												THEN dblQtyReceived
										--WHEN DMDetails.intContractDetailId IS NULL AND DMDetails.intInventoryReceiptItemId IS NULL THEN NULL AP-3308
										WHEN DMDetails.intWeightUOMId > 0 THEN DMDetails.dblNetWeight
									 ELSE DMDetails.dblQtyReceived 
									END
		,dblCost				=	CASE WHEN ContractCost.intContractCostId > 0 AND ContractCost.strCostMethod IN ('Percentage','Amount') 
												THEN DMDetails.dblCost --AP-3308
											WHEN DMDetails.intContractDetailId IS NULL AND DMDetails.intInventoryReceiptItemId IS NULL THEN DMDetails.dblCost
										ELSE DMDetails.dblCost
											END
		,dblTotal				=	DMDetails.dblTotal + ISNULL(DMDetails.dblTax,0)
		,dblNetShippedWeight	=	0 --DMDetails.dblNetShippedWeight
		,dblWeightLoss			=	0 --dblWeightLoss
		,dblLandedWeight		=	0 --CASE WHEN DMDetails.intWeightUOMId > 0 THEN DMDetails.dblNetWeight ELSE DMDetails.dblQtyReceived END
		,dblFranchiseWeight		=	0 --DMDetails.dblFranchiseWeight
		,dblClaimAmount			=	0 --DMDetails.dblClaimAmount
		,strERPPONumber			=	ContractDetail.strERPPONumber
		,strContractNumber		=	LCointainer.strContainerNumber
	FROM tblAPBill DM
	INNER JOIN tblAPBillDetail DMDetails ON DM.intBillId = DMDetails.intBillId
	INNER JOIN tblGLAccount DetailAccount ON DetailAccount.intAccountId = DMDetails.intAccountId
	INNER JOIN tblSMCurrency MainCurrency ON MainCurrency.intCurrencyID = DM.intCurrencyId
	LEFT JOIN tblSMCurrency SubCurrency ON DM.intCurrencyId = SubCurrency.intMainCurrencyId AND SubCurrency.ysnSubCurrency = 1
	LEFT JOIN tblICItem Item ON Item.intItemId = DMDetails.intItemId
	LEFT JOIN (tblICItemUOM QtyUOM LEFT JOIN tblICUnitMeasure QtyUOMDetails ON QtyUOM.intUnitMeasureId = QtyUOMDetails.intUnitMeasureId) 
			ON (CASE WHEN DMDetails.intWeightUOMId > 0 THEN DMDetails.intWeightUOMId WHEN DMDetails.intCostUOMId > 0 THEN DMDetails.intCostUOMId ELSE DMDetails.intUnitOfMeasureId END) = QtyUOM.intItemUOMId
	LEFT JOIN tblCTContractDetail ContractDetail ON DMDetails.intContractDetailId = ContractDetail.intContractDetailId
	LEFT JOIN tblCTContractHeader ContractHeader ON ContractHeader.intContractHeaderId = ContractDetail.intContractHeaderId
	LEFT JOIN tblCTContractCost ContractCost ON ContractDetail.intContractDetailId = ContractCost.intContractDetailId AND DMDetails.intContractCostId = ContractCost.intContractCostId
	LEFT JOIN tblSMCurrency ContractCostCurrency ON ContractCost.intCurrencyId = ContractCostCurrency.intCurrencyID
	LEFT JOIN (tblICItemUOM ContractCostItemUOM LEFT JOIN tblICUnitMeasure ContractCostItemMeasure ON ContractCostItemUOM.intUnitMeasureId = ContractCostItemMeasure.intUnitMeasureId)
								ON ContractCostItemUOM.intItemUOMId = ContractCost.intItemUOMId
	LEFT JOIN tblICInventoryReceiptItem ReceiptDetail LEFT JOIN tblICInventoryReceipt Receipt ON ReceiptDetail.intInventoryReceiptId = Receipt.intInventoryReceiptId
			ON ReceiptDetail.intInventoryReceiptItemId = DMDetails.intInventoryReceiptItemId
	LEFT JOIN tblICItemUOM ItemCostUOM LEFT JOIN tblICUnitMeasure ItemCostUOMMeasure ON ItemCostUOM.intUnitMeasureId = ItemCostUOMMeasure.intUnitMeasureId
			ON DMDetails.intCostUOMId = ItemCostUOM.intItemUOMId
	LEFT JOIN tblICItemContract ItemContract LEFT JOIN tblSMCountry ItemOriginCountry ON ItemContract.intCountryId = ItemOriginCountry.intCountryID
			ON ContractDetail.intItemContractId = ItemContract.intItemContractId
	LEFT JOIN tblICItem ContractItem ON ContractItem.intItemId = ContractDetail.intItemId
	LEFT JOIN tblICCommodityAttribute CommAttr ON CommAttr.intCommodityAttributeId = ContractItem.intOriginId
	LEFT JOIN tblSMCompanyLocationSubLocation LPlant ON ContractDetail.intSubLocationId = LPlant.intCompanyLocationSubLocationId
	LEFT JOIN tblLGLoadContainer LCointainer ON LCointainer.intLoadContainerId = ReceiptDetail.intContainerId
	WHERE DM.intTransactionType = 1
) transactions
INNER JOIN tblAPBill A ON transactions.intBillId = A.intBillId
INNER JOIN (tblAPVendor B INNER JOIN tblEMEntity B2 ON B.[intEntityId] = B2.intEntityId)
	ON A.intEntityVendorId = B.[intEntityId]
LEFT JOIN tblEMEntityToContact EntityToContact ON A.intEntityId = EntityToContact.intEntityId AND EntityToContact.ysnDefaultContact = 1
LEFT JOIN tblEMEntity ContactEntity ON EntityToContact.intEntityContactId = ContactEntity.intEntityId
LEFT JOIN tblSMCompanyLocation TranLoc ON A.intStoreLocationId = TranLoc.intCompanyLocationId
LEFT JOIN tblCMBankAccount BankAccount ON BankAccount.intBankAccountId = A.intBankInfoId
LEFT JOIN tblCMBank Bank ON BankAccount.intBankId = Bank.intBankId
LEFT JOIN tblSMTerm Term ON A.intTermsId = Term.intTermID
GO