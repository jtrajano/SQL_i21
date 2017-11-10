CREATE VIEW vyuLGLoadContainerReceiptContracts
AS   
SELECT 
	intLoadDetailId
	,LD.intLoadId
	,strLoadNumber
	,intPContractDetailId
	,intPContractHeaderId
	,intPContractSeq
	,strPContractNumber
	,intPSubLocationId
	,intPCommodityId
	,LD.intItemId
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
	,dblStockUOMCF = ISNULL(dblPStockUOMCF,0.0)
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
	,intStorageLocationId = SL.intStorageLocationId
	,strStorageLocationName = SL.strName
	,LD.intForexRateTypeId		
	,LD.strForexRateType		
	,LD.dblForexRate			
	,LD.dtmScheduledDate
	,LD.intFreightTermId
	,LD.strFreightTerm
FROM vyuLGLoadDetailViewLookup LD
	LEFT JOIN tblLGLoadWarehouse LW ON LW.intLoadId = LD.intLoadId
	LEFT JOIN tblICStorageLocation SL ON SL.intStorageLocationId = LW.intStorageLocationId
WHERE intLoadDetailId NOT IN (Select intLoadDetailId FROM vyuLGLoadContainerPurchaseContractsLookup)

UNION ALL

SELECT
	  intLoadDetailId               = L.intLoadDetailId
	, intLoadId						= L.intLoadId
	, strLoadNumber					= L.strLoadNumber
	, intPContractDetailId			= L.intPContractDetailId
	, intPContractHeaderId			= L.intPContractHeaderId
	, intPContractSeq				= L.intPContractSeq
	, strPContractNumber			= L.strPContractNumber
	, intPSubLocationId				= L.intPSubLocationId
	, intPCommodityId				= L.intPCommodityId
	, intItemId						= L.intItemId				
	, intPLifeTime					= L.intPLifeTime			
	, strPLifeTimeType				= L.strPLifeTimeType		
	, intItemUOMId					= L.intItemUOMId			
	, intCompanyLocationId			= L.intCompanyLocationId	
	, dblQuantity					= L.dblQuantity			
	, dblDeliveredQuantity			= L.dblDeliveredQuantity
	, dblBalanceToReceive			= L.dblBalanceToReceive
	, dblGross						= L.dblGross
	, dblTare						= L.dblTare			
	, dblNet						= L.dblNet			
	, dblCost						= L.dblCost			
	, strPCostUOM					= L.strPCostUOM				
	, intPCostUOMId					= L.intPCostUOMId	
	, dblPCostUOMCF 				= L.dblPCostUOMCF 		
	, intWeightUOMId				= L.intWeightUOMId	
	, strWeightItemUOM				= L.strWeightUOM
	, intEntityVendorId				= L.intEntityVendorId	
	, strVendor						= L.strVendor
	, strItemNo						= L.strItemNo			
	, strItemDescription			= L.strItemDescription
	, strLotTracking				= L.strLotTracking	
	, strType						= L.strType			
	, strUnitMeasure				= L.strUnitMeasure	
	, dblItemUOMCF					= L.dblItemUOMCF		
	, intStockUOM					= L.intStockUOM		
	, strStockUOM					= L.strStockUOM		
	, strStockUOMType				= L.strStockUOMType	
	, dblStockUOMCF 				= ISNULL(L.dblStockUOMCF,0.0)
	, strBLNumber					= L.strBLNumber		
	, strContainerNumber			= L.strContainerNumber
	, strLotNumber					= strLotNumber	
	, strMarks						= strMarks		
	, strOtherMarks					= strOtherMarks
	, strSealNumber					= strSealNumber
	, strContainerType				= strContainerType				
	, intWeightItemUOMId			= intWeightItemUOMId			
	, strCurrency					= strCurrency					
	, strMainCurrency				= strMainCurrency				
	, ysnSubCurrency				= ysnSubCurrency				
	, dblMainCashPrice				= dblMainCashPrice				
	, dblFranchise					= dblFranchise					
	, dblContainerWeightPerQty		= dblContainerWeightPerQty		
	, intSubLocationId				= intSubLocationId				
	, strSubLocationName			= strSubLocationName			
	, intLoadContainerId			= intLoadContainerId			
	, intLoadDetailContainerLinkId	= intLoadDetailContainerLinkId	
	, intPurchaseSale				= intPurchaseSale				
	, intTransUsedBy				= intTransUsedBy				
	, intSourceType					= intSourceType					
	, ysnPosted						= ysnPosted						
	, intStorageLocationId			= intStorageLocationId			
	, strStorageLocationName		= strStorageLocationName	
	, intForexRateTypeId		
	, strForexRateType		
	, dblForexRate		
	, dtmScheduledDate		
	, L.intFreightTermId
	, L.strFreightTerm 
FROM vyuLGLoadContainerPurchaseContractsLookup L
