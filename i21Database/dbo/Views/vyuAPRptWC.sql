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
		,strBillOfLading		=	Loads.strBLNumber
		,strCountryOrigin		=	ISNULL(ItemOriginCountry.strCountry, CommAttr.strDescription)
		,strAccountId			=	DetailAccount.strAccountId
		,strCurrency			=	MainCurrency.strCurrency
		,strConcern				=	'Weight Claim'
		,strUOM					=	QtyUOMDetails.strUnitMeasure
		,strClaimUOM			=	QtyUOMDetails.strUnitMeasure
		,strCostUOM				=	CASE 
										WHEN WC2Details.intCostUOMId > 0 THEN ItemCostUOMMeasure.strUnitMeasure 
										WHEN WC2Details.intWeightUOMId > 0 THEN QtyUOMWeightDetails.strUnitMeasure  --use weight uom if intCostUOMId is blank
										ELSE QtyUOMDetails.strUnitMeasure --use received uom if intCostUOMId is blank
									END
		,strLPlant				=	LPlant.strSubLocationName
		,intContractSeqId		=	ContractDetail.intContractSeq
		,dblQtyReceived			=	WC2Details.dblWeightLoss - WC2Details.dblFranchiseWeight--CASE WHEN WC2Details.intWeightUOMId > 0 THEN WC2Details.dblNetWeight ELSE WC2Details.dblQtyReceived END
		,dblCost				=	WC2Details.dblCost
		,dblTotal				=	WC2Details.dblTotal + WC2Details.dblTax
		,dblNetShippedWeight	=	WCSummary.dblNetShippedWeight
		,dblClaimWeight			=	WCSummary.dblWeightLoss - WCSummary.dblFranchiseWeight
		,dblWeightLoss			=	WCSummary.dblWeightLoss--WC2Details.dblNetShippedWeight - WC2Details.dblQtyReceived
		,dblLandedWeight		=	CASE WHEN WC2Details.intWeightUOMId > 0 THEN WCSummary.dblNetShippedWeight - WCSummary.dblWeightLoss ELSE WCSummary.dblQtyReceived END
		,dblFranchiseWeight		=	WCSummary.dblFranchiseWeight
		,dblClaimAmount			=	WCSummary.dblClaimAmount
		,strERPPONumber			=	ContractDetail.strERPPONumber
		,strContainerNumber		=	LCointainer.strContainerNumber
		,intShipToId			=	WC2.intShipToId
	FROM tblAPBill WC2
	INNER JOIN (
			SELECT
				B.intBillId
				,SUM(dblFranchiseWeight) [dblFranchiseWeight]
				,SUM([dblClaimAmount]) [dblClaimAmount] 
				,SUM([dblNetShippedWeight]) [dblNetShippedWeight]
				,SUM(dblWeightLoss) dblWeightLoss
				,SUM(dblQtyReceived) dblQtyReceived
				FROM tblAPBillDetail A
				INNER JOIN tblAPBill B ON A.intBillId = B.intBillId
				GROUP BY B.intBillId
	 ) WCSummary ON WCSummary.intBillId = WC2.intBillId
	INNER JOIN tblAPBillDetail WC2Details ON WC2.intBillId = WC2Details.intBillId
	INNER JOIN tblICItem Item ON Item.intItemId = WC2Details.intItemId
	LEFT JOIN (tblICItemUOM QtyUOM INNER JOIN tblICUnitMeasure QtyUOMDetails ON QtyUOM.intUnitMeasureId = QtyUOMDetails.intUnitMeasureId) 
			ON WC2Details.intUnitOfMeasureId = QtyUOM.intItemUOMId
	LEFT JOIN (tblICItemUOM QtyUOMWeight INNER JOIN tblICUnitMeasure QtyUOMWeightDetails ON QtyUOMWeight.intUnitMeasureId = QtyUOMWeightDetails.intUnitMeasureId) 
			ON QtyUOMWeight.intItemUOMId = WC2Details.intWeightUOMId
	LEFT JOIN (tblICItemUOM ItemCostUOM INNER JOIN tblICUnitMeasure ItemCostUOMMeasure ON ItemCostUOM.intUnitMeasureId = ItemCostUOMMeasure.intUnitMeasureId) 
			ON WC2Details.intCostUOMId = ItemCostUOM.intItemUOMId
	INNER JOIN (tblCTContractDetail ContractDetail INNER JOIN tblCTContractHeader ContractHeader ON ContractHeader.intContractHeaderId = ContractDetail.intContractHeaderId)
			ON WC2Details.intContractDetailId = ContractDetail.intContractDetailId
	INNER JOIN vyuAPRptVoucherCommonData commonData ON WC2.intBillId = commonData.intBillId
	LEFT JOIN tblGLAccount DetailAccount ON DetailAccount.intAccountId = WC2Details.intAccountId
	INNER JOIN tblSMCurrency MainCurrency ON MainCurrency.intCurrencyID = WC2Details.intCurrencyId
	LEFT JOIN tblICItemContract ItemContract INNER JOIN tblSMCountry ItemOriginCountry ON ItemContract.intCountryId = ItemOriginCountry.intCountryID
			ON ContractDetail.intItemContractId = ItemContract.intItemContractId
	LEFT JOIN tblICCommodityAttribute CommAttr ON CommAttr.intCommodityAttributeId = Item.intOriginId
	LEFT JOIN tblSMCompanyLocationSubLocation LPlant ON ContractDetail.intSubLocationId = LPlant.intCompanyLocationSubLocationId
	LEFT JOIN dbo.tblICInventoryReceiptItem ReceiptDetail ON ReceiptDetail.intInventoryReceiptItemId = WC2Details.intInventoryReceiptItemId
	LEFT JOIN tblLGLoadContainer LCointainer ON LCointainer.intLoadContainerId = ReceiptDetail.intContainerId
		LEFT JOIN tblLGLoad Loads ON Loads.intLoadId = ISNULL(LCointainer.intLoadId, WC2Details.intLoadId)
	LEFT JOIN tblCMBankAccount BankAccount ON BankAccount.intBankAccountId = WC2.intBankInfoId
	LEFT JOIN tblCMBank Bank ON BankAccount.intBankId = Bank.intBankId
	WHERE WC2.intTransactionType = 11