CREATE VIEW vyuAPRptVoucher
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
	,strUOM					=	CASE WHEN DMDetails.intContractDetailId IS NULL AND DMDetails.intInventoryReceiptItemId IS NULL THEN NULL 
									WHEN ContractCost.intContractCostId > 0 AND ContractCost.strCostMethod IN ('Percentage','Amount') 
											THEN NULL 
									WHEN ContractCost.intContractCostId > 0 THEN ContractCostItemMeasure.strUnitMeasure
									ELSE QtyUOMDetails.strUnitMeasure
									END
	,strClaimUOM			=	'' COLLATE Latin1_General_CI_AS
	,strCostUOM				=	CASE WHEN DMDetails.intContractDetailId IS NULL AND DMDetails.intInventoryReceiptItemId IS NULL THEN NULL 
									WHEN ContractCost.intContractCostId > 0 AND ContractCost.strCostMethod IN ('Percentage','Amount') 
											THEN NULL
										WHEN DMDetails.intCostUOMId > 0 THEN ItemCostUOMMeasure.strUnitMeasure 
									ELSE QtyUOMDetails.strUnitMeasure END
	,strLPlant				=	LPlant.strSubLocationName
	,intContractSeqId		=	ContractDetail.intContractSeq
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
	,strContainerNumber		=	LCointainer.strContainerNumber
FROM tblAPBill DM
INNER JOIN tblAPBillDetail DMDetails ON DM.intBillId = DMDetails.intBillId
INNER JOIN tblGLAccount DetailAccount ON DetailAccount.intAccountId = DMDetails.intAccountId
INNER JOIN tblSMCurrency MainCurrency ON MainCurrency.intCurrencyID = DM.intCurrencyId
INNER JOIN vyuAPRptVoucherCommonData commonData ON DM.intBillId = commonData.intBillId
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