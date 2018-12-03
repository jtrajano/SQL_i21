CREATE VIEW [dbo].[vyuICGetReceiptAddPurchaseContract]
AS

SELECT intKey = CAST(ROW_NUMBER() OVER(ORDER BY intLocationId, intEntityVendorId, intLineNo) AS INT)
, * 
FROM (
	SELECT 	
		intLocationId				= ContractView.intCompanyLocationId			
		, intEntityVendorId			= ContractView.intEntityId
		, strVendorId				= ContractView.strVendorId
		, strVendorName				= ContractView.strEntityName
		, strReceiptType			= 'Purchase Contract' COLLATE Latin1_General_CI_AS
		, intLineNo					= ContractView.intContractDetailId
		, intOrderId				= ContractView.intContractHeaderId
		, strOrderNumber			= ContractView.strContractNumber
		, dblOrdered				= CASE WHEN ContractView.ysnLoad = 1 THEN ContractView.intNoOfLoad ELSE ContractView.dblDetailQuantity END
		, dblReceived				= CASE WHEN ContractView.ysnLoad = 1 THEN ContractView.intLoadReceived ELSE ContractView.dblDetailQuantity - ContractView.dblBalance END
		, intSourceType				= CAST(0 AS INT)
		, intSourceId				= CAST(NULL AS INT) 
		, strSourceNumber			= CAST(NULL AS NVARCHAR(50)) COLLATE Latin1_General_CI_AS 
		, intItemId					= ContractView.intItemId
		, strItemNo					= ContractView.strItemNo
		, strItemDescription		= ContractView.strItemDescription
		, dblQtyToReceive			= ContractView.dblDetailQuantity - (ContractView.dblDetailQuantity - ContractView.dblBalance)
		, intLoadToReceive			= ContractView.intNoOfLoad - ContractView.intLoadReceived
		, dblUnitCost				= ContractView.dblSeqPrice
		, dblTax					= CAST(0 AS NUMERIC(18, 6))
		, dblLineTotal				= CAST((ContractView.dblDetailQuantity - (ContractView.dblDetailQuantity - ContractView.dblBalance)) * ContractView.dblSeqPrice AS NUMERIC(18, 6))
		, strLotTracking			= ContractView.strLotTracking
		, intCommodityId			= ContractView.intCommodityId
		, intContainerId			= CAST(NULL AS INT) 
		, strContainer				= CAST(NULL AS NVARCHAR(50)) COLLATE Latin1_General_CI_AS
		, intSubLocationId			= ContractView.intCompanyLocationSubLocationId
		, strSubLocationName		= ContractView.strSubLocationName
		, intStorageLocationId		= ContractView.intStorageLocationId
		, strStorageLocationName	= ContractView.strStorageLocationName
		, intOrderUOMId				= ItemUOM.intItemUOMId
		, strOrderUOM				= ItemUnitMeasure.strUnitMeasure
		, dblOrderUOMConvFactor		= ItemUOM.dblUnitQty
		, intItemUOMId				= ItemUOM.intItemUOMId
		, strUnitMeasure			= ItemUnitMeasure.strUnitMeasure
		, strUnitType				= ItemUnitMeasure.strUnitType
		-- Gross/Net UOM -----------
		, intWeightUOMId			= GrossNetUOM.intItemUOMId
		, strWeightUOM				= GrossNetUnitMeasure.strUnitMeasure
		-- Conversion factor -------
		, dblItemUOMConvFactor		= ItemUOM.dblUnitQty
		, dblWeightUOMConvFactor	= GrossNetUOM.dblUnitQty
		-- Cost UOM ----------------
		, intCostUOMId				= ContractView.intSeqPriceUOMId
		, strCostUOM				= ContractView.strSeqPriceUOM
		--, dblCostUOMConvFactor		= ContractView.dblQtyToPriceUOMConvFactor
		, dblCostUOMConvFactor		= (SELECT dblUnitQty from tblICItemUOM WHERE intItemUOMId = ContractView.intSeqPriceUOMId)
		, intLifeTime				= ContractView.intLifeTime
		, strLifeTimeType			= ContractView.strLifeTimeType
		, ysnLoad					= CAST(0 AS BIT)
		, dblAvailableQty			= CAST(0 AS NUMERIC(38, 20))
		, strBOL					= CAST(NULL AS NVARCHAR(50)) COLLATE Latin1_General_CI_AS
		, dblFranchise				= CAST(NULL AS NUMERIC(18, 6))
		, dblContainerWeightPerQty	= CAST(NULL AS NUMERIC(18, 6))
		, ysnSubCurrency			= CAST(ContractView.ysnSubCurrency AS BIT)
		, intCurrencyId				= dbo.fnICGetCurrency(ContractView.intContractDetailId, 0) -- 0 indicates that value is not for Sub Currency
		, strSubCurrency			= (SELECT strCurrency from tblSMCurrency where intCurrencyID = dbo.fnICGetCurrency(ContractView.intContractDetailId, 1)) -- 1 indicates that value is for Sub Currency
		, dblGross					= CAST(0 AS NUMERIC(38, 20))-- There is no gross from contracts.
		, dblNet					= CAST(ContractView.dblAvailableNetWeight AS NUMERIC(38, 20))
		, intForexRateTypeId		= ContractView.intRateTypeId
		, strForexRateType			= ContractView.strCurrencyExchangeRateType
		, dblForexRate				= ContractView.dblRate
	FROM vyuCTContractAddOrdersLookup ContractView
		LEFT JOIN dbo.tblICItemUOM ItemUOM ON ContractView.intItemUOMId = ItemUOM.intItemUOMId
		LEFT JOIN dbo.tblICUnitMeasure ItemUnitMeasure ON ItemUnitMeasure.intUnitMeasureId = ItemUOM.intUnitMeasureId
		LEFT JOIN dbo.tblICItemUOM GrossNetUOM ON ContractView.intNetWeightUOMId = GrossNetUOM.intItemUOMId
		LEFT JOIN dbo.tblICUnitMeasure GrossNetUnitMeasure ON GrossNetUnitMeasure.intUnitMeasureId = GrossNetUOM.intUnitMeasureId
		LEFT JOIN dbo.tblICItemUOM CostUOM ON CostUOM.intItemUOMId = dbo.fnGetMatchingItemUOMId(ContractView.intItemId, intPriceItemUOMId)
		LEFT JOIN dbo.tblICUnitMeasure CostUnitMeasure ON CostUnitMeasure.intUnitMeasureId = CostUOM.intUnitMeasureId
	WHERE ContractView.ysnAllowedToShow = 1
		AND ContractView.strContractType = 'Purchase'
	
) tblAddOrders
