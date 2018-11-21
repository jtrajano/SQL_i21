CREATE VIEW vyuAPRptWC
AS
SELECT
		commonData.*
		,strContractNumber		=	ContractHeader.strContractNumber
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
		,strConcern				=	'Weight Claim'
		,strUOM					=	QtyUOMDetails.strUnitMeasure
		,strClaimUOM			=	QtyUOMDetails.strUnitMeasure
		,strCostUOM				=	CASE WHEN WC2Details.intCostUOMId > 0 THEN ItemCostUOMMeasure.strUnitMeasure ELSE QtyUOMDetails.strUnitMeasure END
		,strLPlant				=	LPlant.strSubLocationName
		,intContractSeqId		=	ContractDetail.intContractSeq
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
	INNER JOIN vyuAPRptVoucherCommonData commonData ON WC2.intBillId = commonData.intBillId
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
	LEFT JOIN tblCMBankAccount BankAccount ON BankAccount.intBankAccountId = WC2.intBankInfoId
	LEFT JOIN tblCMBank Bank ON BankAccount.intBankId = Bank.intBankId
	WHERE WC2.intTransactionType = 11