CREATE VIEW vyuAPRptDM
AS
SELECT
		commonData.*
		,strContractNumber		=	ContractHeader.strContractNumber
		,strMiscDescription		=	CASE WHEN DMDetails.intContractDetailId > 0
												AND ContractDetail.intItemContractId > 0
												AND DMDetails.intContractCostId IS NULL
										THEN ItemContract.strContractItemName
										ELSE ISNULL(Item.strDescription,'')
									END
		,strItemNo				=	ISNULL(Item.strItemNo, DMDetails.strMiscDescription)
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
		,strClaimUOM			=	'' COLLATE Latin1_General_CI_AS
		,strCostUOM				=	CASE WHEN DMDetails.intCostUOMId > 0 THEN ItemCostUOMMeasure.strUnitMeasure ELSE QtyUOMDetails.strUnitMeasure END
		,strLPlant				=	LPlant.strSubLocationName
		,intContractSeqId		=	ContractDetail.intContractSeq
		,dblQtyOrdered			=	DMDetails.dblQtyOrdered
		,dblQtyReceived			=	CASE WHEN DMDetails.intWeightUOMId > 0 THEN DMDetails.dblNetWeight ELSE DMDetails.dblQtyReceived END
		,dblCost				=	DMDetails.dblCost
		,dblDetailTotal			=	DMDetails.dblTotal
		,dblDiscount			=	DMDetails.dblDiscount
		,dblDetailTax			=	DMDetails.dblTax
		,dblTax					=	DM.dblTax
		,dblTotal				=	DMDetails.dblTotal
		,dblPayment				=	DM.dblPayment
		,dblNetShippedWeight	=	0 --DMDetails.dblNetShippedWeight
		,dblWeightLoss			=	0 --dblWeightLoss
		,dblLandedWeight		=	0 --CASE WHEN DMDetails.intWeightUOMId > 0 THEN DMDetails.dblNetWeight ELSE DMDetails.dblQtyReceived END
		,dblFranchiseWeight		=	0 --DMDetails.dblFranchiseWeight
		,dblClaimAmount			=	0 --DMDetails.dblClaimAmount
		,strERPPONumber			=	ContractDetail.strERPPONumber
		,strPONumber			=	CASE 
									WHEN DMDetails.intPurchaseDetailId > 0
									THEN po.strPurchaseOrderNumber
									ELSE NULL END
		,strContainerNumber		=	LCointainer.strContainerNumber
		,strShipVia				=	shipVia.strShipVia
		,ysnPaid				=	DM.ysnPaid
	FROM tblAPBill DM
	INNER JOIN tblAPBillDetail DMDetails ON DM.intBillId = DMDetails.intBillId
	INNER JOIN tblGLAccount DetailAccount ON DetailAccount.intAccountId = DMDetails.intAccountId
	INNER JOIN tblSMCurrency MainCurrency ON MainCurrency.intCurrencyID = DM.intCurrencyId
	INNER JOIN vyuAPRptVoucherCommonData commonData ON DM.intBillId = commonData.intBillId
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
	LEFT JOIN (tblPOPurchaseDetail poDetail INNER JOIN tblPOPurchase po ON po.intPurchaseId = poDetail.intPurchaseId)
			ON poDetail.intPurchaseDetailId = DMDetails.intPurchaseDetailId
	LEFT JOIN tblICCommodityAttribute CommAttr ON CommAttr.intCommodityAttributeId = Item.intOriginId
	LEFT JOIN tblSMCompanyLocationSubLocation LPlant ON ContractDetail.intSubLocationId = LPlant.intCompanyLocationSubLocationId
	LEFT JOIN tblLGLoadContainer LCointainer ON LCointainer.intLoadContainerId = ReceiptDetail.intContainerId
	LEFT JOIN tblSMShipVia shipVia
			ON shipVia.intEntityId = DM.intShipViaId
	WHERE DM.intTransactionType = 3