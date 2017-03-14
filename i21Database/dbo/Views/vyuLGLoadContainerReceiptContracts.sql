CREATE VIEW vyuLGLoadContainerReceiptContracts
AS   
SELECT 
	intLoadDetailId
	,intLoadId
	,strLoadNumber
	,intPContractDetailId
	,intPContractHeaderId
	,intPContractSeq
	,strPContractNumber
	,intPSubLocationId
	,intPCommodityId
	,intItemId
	,intPLifeTime
	,strPLifeTimeType
	,intItemUOMId
	,intCompanyLocationId
	,dblQuantity
	,dblDeliveredQuantity
	,dblBalanceToReceive = dblQuantity - dblDeliveredQuantity
	,dblGross
	,dblTare
	,dblNet
	,dblCost = dblPCashPrice
	,strPCostUOM
	,intPCostUOMId
	,dblPCostUOMCF 
	,intWeightUOMId = intWeightItemUOMId
	,strWeightItemUOM
	,intEntityVendorId = intVendorEntityId
	,strVendor
	,strItemNo
	,strItemDescription
	,strLotTracking
	,strType
	,strUnitMeasure = strItemUOM COLLATE Latin1_General_CI_AS
	,dblItemUOMCF
	,intStockUOM = intPStockUOM
	,strStockUOM = strPStockUOM COLLATE Latin1_General_CI_AS
	,strStockUOMType = strPStockUOMType COLLATE Latin1_General_CI_AS
	,dblStockUOMCF = dblPStockUOMCF 
	,strBLNumber = NULL
	,strContainerNumber = NULL
	,strLotNumber = NULL
	,strMarks = NULL
	,strOtherMarks = NULL
	,strSealNumber = NULL
	,strContainerType = NULL
	,intWeightItemUOMId
	,strCurrency = strPCurrency COLLATE Latin1_General_CI_AS
	,strMainCurrency = strPMainCurrency COLLATE Latin1_General_CI_AS
	,ysnSubCurrency = ysnPSubCurrency
	,dblMainCashPrice = dblPMainCashPrice
	,dblFranchise = dblPFranchise
	,dblContainerWeightPerQty = NULL
	,intSubLocationId = NULL
	,strSubLocationName = NULL
	,intLoadContainerId = -1
	,intLoadDetailContainerLinkId = -1
	,intPurchaseSale
	,intTransUsedBy
	,intSourceType
	,ysnPosted
	,intStorageLocationId = CAST(NULL AS INT)
	,strStorageLocationName = CAST(NULL AS INT)
FROM vyuLGLoadDetailView WHERE intLoadDetailId NOT IN (Select intLoadDetailId FROM vyuLGLoadContainerPurchaseContracts)

UNION ALL

SELECT 

	intLoadDetailId
	,intLoadId
	,strLoadNumber
	,intPContractDetailId
	,intContractHeaderId
	,intContractSeq
	,strContractNumber COLLATE Latin1_General_CI_AS
	,intPSubLocationId
	,intCommodityId
	,intItemId
	,intLifeTime
	,strLifeTimeType COLLATE Latin1_General_CI_AS
	,intItemUOMId
	,intLocationId
	,dblQuantity
	,dblReceivedQty
	,dblBalanceToReceive = dblQuantity - dblReceivedQty
	,dblGrossWt
	,dblTareWt
	,dblNetWt
	,dblCost
	,strCostUOM COLLATE Latin1_General_CI_AS
	,intCostUOMId
	,dblCostUOMCF
	,intWeightUOMId
	,strWeightUOM COLLATE Latin1_General_CI_AS
	,intEntityVendorId
	,strVendor COLLATE Latin1_General_CI_AS
	,strItemNo COLLATE Latin1_General_CI_AS
	,strItemDescription COLLATE Latin1_General_CI_AS
	,strLotTracking COLLATE Latin1_General_CI_AS
	,strType COLLATE Latin1_General_CI_AS
	,strUnitMeasure COLLATE Latin1_General_CI_AS
	,dblItemUOMCF
	,intStockUOM
	,strStockUOM COLLATE Latin1_General_CI_AS
	,strStockUOMType COLLATE Latin1_General_CI_AS
	,dblStockUOMCF
	,strBLNumber COLLATE Latin1_General_CI_AS
	,strContainerNumber COLLATE Latin1_General_CI_AS
	,strLotNumber COLLATE Latin1_General_CI_AS
	,strMarks COLLATE Latin1_General_CI_AS
	,strOtherMarks COLLATE Latin1_General_CI_AS
	,strSealNumber COLLATE Latin1_General_CI_AS
	,strContainerType COLLATE Latin1_General_CI_AS
	,intWeightItemUOMId
	,strCurrency COLLATE Latin1_General_CI_AS
	,strMainCurrency COLLATE Latin1_General_CI_AS
	,ysnSubCurrency
	,dblMainCashPrice
	,dblFranchise
	,dblContainerWeightPerQty
	,intSubLocationId
	,strSubLocationName
	,intLoadContainerId
	,intLoadDetailContainerLinkId
	,intPurchaseSale
	,intTransUsedBy
	,intSourceType
	,ysnPosted
	,intStorageLocationId = CAST(NULL AS INT)
	,strStorageLocationName = CAST(NULL AS INT)
FROM vyuLGLoadContainerPurchaseContracts