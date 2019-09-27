CREATE VIEW vyuICGetReceiptAddLGInboundShipmentEx
AS
SELECT
	  intKey						= CAST(ROW_NUMBER() OVER(ORDER BY LoadDetail.intLoadDetailId) AS INT)   
	, intLocationId					= Load.intCompanyLocationId
	, intEntityVendorId				= LoadDetail.intVendorEntityId
	, strVendorId					= Entity.strName
	, strVendorName					= Entity.strName
	, strReceiptType				= 'Purchase Contract' COLLATE Latin1_General_CI_AS
	, intLineNo						= ContractDetail.intContractDetailId
	, intOrderId					= Contract.intContractHeaderId
	, intSourceType					= 2
	, strOrderNumber				= Contract.strContractNumber
	, dblOrdered					= LoadContainerLink.dblQuantity
	, dblReceived					= ISNULL(LoadContainerLink.dblReceivedQty, 0)
	, intSourceId					= LoadDetail.intLoadDetailId
	, strSourceNumber				= Load.strLoadNumber
	, intItemId						= LoadDetail.intItemId
	, strItemNo						= Item.strItemNo
	, strItemDescription			= Item.strDescription
	, dblQtyToReceive				= LoadContainerLink.dblQuantity - ISNULL(LoadContainerLink.dblReceivedQty, 0)
	, intLoadToReceive				= 0
	, dblUnitCost					= ContractDetail.dblCashPrice
	, dblTax						= CAST(0 AS NUMERIC(18, 6)) 
	, dblLineTotal					= CAST(0 AS NUMERIC(18, 6))
	, strLotTracking				= Item.strLotTracking
	, intCommodityId				= Item.intCommodityId
	, intContainerId				= LoadContainer.intLoadContainerId
	, strContainer					= LoadContainer.strContainerNumber
	, intSubLocationId				= ISNULL(LoadWarehouse.intSubLocationId, LoadDetail.intPSubLocationId) 
	, strSubLocationName			= CASE WHEN LoadWarehouse.intSubLocationId IS NOT NULL THEN LoadWarehouseSubLocation.strSubLocationName ELSE LoadDetailSubLocation.strSubLocationName END
	, intStorageLocationId			= LoadWarehouse.intStorageLocationId
	, strStorageLocationName		= LoadWarehouseStorageLocation.strName
	, intOrderUOMId					= ItemUOM.intItemUOMId
	, strOrderUOM					= ItemUnitMeasure.strUnitMeasure
	, dblOrderUOMConvFactor			= ItemUOM.dblUnitQty
	, intItemUOMId					= ItemUOM.intItemUOMId
	, strUnitMeasure				= ItemUnitMeasure.strUnitMeasure
	, strUnitType					= ItemUnitMeasure.strUnitType
	-- Gross/Net UOM -----------	
	, intWeightUOMId				= GrossNetUOM.intItemUOMId
	, strWeightUOM					= GrossNetUnitMeasure.strUnitMeasure
	-- Conversion factor -------	
	, dblItemUOMConvFactor			= ItemUOM.dblUnitQty
	, dblWeightUOMConvFactor		= GrossNetUOM.dblUnitQty
	-- Cost UOM ----------------	
	, intCostUOMId					= CostUOM.intItemUOMId
	, strCostUOM					= CostUnitMeasure.strUnitMeasure
	, dblCostUOMConvFactor			= CostUOM.dblUnitQty
	, intLifeTime					= Item.intLifeTime
	, strLifeTimeType				= Item.strLifeTimeType
	, ysnLoad						= CAST(0 AS BIT) 
	, dblAvailableQty				= CAST(0 AS NUMERIC(38, 20))
	, strBOL						= Load.strBLNumber
	, dblFranchise					= CASE WHEN WeightGrade.dblFranchise > 0 THEN WeightGrade.dblFranchise / 100 ELSE 0 END
	, dblContainerWeightPerQty		= (LoadContainer.dblNetWt / CASE WHEN ISNULL(LoadContainer.dblQuantity,0) = 0 THEN 1 ELSE LoadContainer.dblQuantity END)
	, ysnSubCurrency				= CAST(ContractDetailCurrency.ysnSubCurrency AS BIT)
	, intCurrencyId					= CASE WHEN ContractDetail.ysnUseFXPrice = 1 THEN ContractDetailExtras.intSeqCurrencyId ELSE ISNULL(ISNULL(ContractDetailCurrency.intMainCurrencyId, ContractDetail.intCurrencyId), dbo.fnSMGetDefaultCurrency('FUNCTIONAL')) END
	, strSubCurrency				= SubCurrency.strCurrency
	, dblGross						= (LoadContainer.dblGrossWt / CASE WHEN ISNULL(LoadContainer.dblQuantity,0) = 0 THEN 1 ELSE LoadContainer.dblQuantity END) * LoadContainerLink.dblQuantity
	, dblNet						= (LoadContainer.dblNetWt / CASE WHEN ISNULL(LoadContainer.dblQuantity,0) = 0 THEN 1 ELSE LoadContainer.dblQuantity END) * LoadContainerLink.dblQuantity
	, ysnRejected					= LoadContainer.ysnRejected
	, intForexRateTypeId			= CASE WHEN dbo.fnSMGetDefaultCurrency('FUNCTIONAL') = CASE WHEN ContractDetail.ysnUseFXPrice = 1 THEN ContractDetailExtras.intSeqCurrencyId ELSE ISNULL(ISNULL(ContractDetailCurrency.intMainCurrencyId, ContractDetail.intCurrencyId), dbo.fnSMGetDefaultCurrency('FUNCTIONAL')) END THEN NULL ELSE ISNULL(LoadDetail.intForexRateTypeId, CompanyPreferenceForexRateType.intForexRateTypeId) END
	, strForexRateType				= CASE WHEN dbo.fnSMGetDefaultCurrency('FUNCTIONAL') = CASE WHEN ContractDetail.ysnUseFXPrice = 1 THEN ContractDetailExtras.intSeqCurrencyId ELSE ISNULL(ISNULL(ContractDetailCurrency.intMainCurrencyId, ContractDetail.intCurrencyId), dbo.fnSMGetDefaultCurrency('FUNCTIONAL')) END THEN NULL ELSE ISNULL(currencyType.strCurrencyExchangeRateType, CompanyPreferenceForexRateType.strCurrencyExchangeRateType) END
	, dblForexRate					= CASE WHEN dbo.fnSMGetDefaultCurrency('FUNCTIONAL') = CASE WHEN ContractDetail.ysnUseFXPrice = 1 THEN ContractDetailExtras.intSeqCurrencyId ELSE ISNULL(ISNULL(ContractDetailCurrency.intMainCurrencyId, ContractDetail.intCurrencyId), dbo.fnSMGetDefaultCurrency('FUNCTIONAL')) END THEN NULL ELSE ISNULL(LoadDetail.dblForexRate, defaultForexRate.dblRate) END
	, ysnBundleItem					= CAST(0 AS BIT)
	, intBundledItemId				= CAST(NULL AS INT)
	, strBundledItemNo				= CAST(NULL AS NVARCHAR(50)) COLLATE Latin1_General_CI_AS
	, strBundledItemDescription		= CAST(NULL AS NVARCHAR(50)) COLLATE Latin1_General_CI_AS
	, ysnIsBasket					= CAST(0 AS BIT)
	, intFreightTermId				= Load.intFreightTermId
	, strFreightTerm				= LoadFreightTerm.strFreightTerm
	, strMarkings					= LoadContainer.strMarks
	, strBundleType					= Item.strBundleType
	, intContractSeq 				= ContractDetail.intContractSeq
	, strLotCondition				= ICPreference.strLotCondition
	, intLoadDetailContainerLinkId	= LoadContainerLink.intLoadDetailContainerLinkId 
FROM tblLGLoad Load
	INNER JOIN tblLGLoadDetail LoadDetail ON LoadDetail.intLoadId = Load.intLoadId
	INNER JOIN tblLGLoadDetailContainerLink LoadContainerLink ON LoadDetail.intLoadDetailId = LoadContainerLink.intLoadDetailId
	LEFT OUTER JOIN tblLGLoadContainer LoadContainer ON LoadContainerLink.intLoadContainerId = LoadContainer.intLoadContainerId
	LEFT OUTER JOIN tblLGLoadWarehouseContainer LoadWarehouseContainer ON LoadWarehouseContainer.intLoadContainerId = LoadContainer.intLoadContainerId
	LEFT OUTER JOIN tblLGLoadWarehouse LoadWarehouse ON LoadWarehouse.intLoadWarehouseId = LoadWarehouseContainer.intLoadWarehouseId
	LEFT OUTER JOIN tblSMCompanyLocationSubLocation LoadWarehouseSubLocation ON LoadWarehouseSubLocation.intCompanyLocationSubLocationId = LoadWarehouse.intSubLocationId
	LEFT OUTER JOIN tblSMCompanyLocationSubLocation LoadDetailSubLocation ON LoadDetailSubLocation.intCompanyLocationSubLocationId = LoadDetail.intPSubLocationId
	LEFT OUTER JOIN tblICStorageLocation LoadWarehouseStorageLocation ON LoadWarehouseStorageLocation.intStorageLocationId = LoadWarehouse.intStorageLocationId
	LEFT OUTER JOIN tblICItemUOM ItemUOM ON LoadDetail.intItemUOMId= ItemUOM.intItemUOMId
	LEFT OUTER JOIN tblICUnitMeasure ItemUnitMeasure ON ItemUnitMeasure.intUnitMeasureId = ItemUOM.intUnitMeasureId
	LEFT OUTER JOIN tblICItemUOM GrossNetUOM ON LoadDetail.intWeightItemUOMId = GrossNetUOM.intItemUOMId
	LEFT OUTER JOIN tblICUnitMeasure GrossNetUnitMeasure ON GrossNetUnitMeasure.intUnitMeasureId = GrossNetUOM.intUnitMeasureId
	INNER JOIN tblCTContractDetail ContractDetail ON ContractDetail.intContractDetailId = LoadDetail.intPContractDetailId
	INNER JOIN tblCTContractHeader Contract ON Contract.intContractHeaderId = ContractDetail.intContractHeaderId
	CROSS APPLY dbo.fnCTGetAdditionalColumnForDetailView(ContractDetail.intContractDetailId) ContractDetailExtras
	LEFT JOIN dbo.tblICItemUOM CostUOM ON CostUOM.intItemUOMId = dbo.fnGetMatchingItemUOMId(LoadDetail.intItemId, ISNULL(ContractDetail.intPriceItemUOMId, ContractDetail.intAdjItemUOMId))
	LEFT JOIN dbo.tblICUnitMeasure CostUnitMeasure ON CostUnitMeasure.intUnitMeasureId = CostUOM.intUnitMeasureId
	INNER JOIN tblICItem Item ON Item.intItemId = LoadDetail.intItemId
	INNER JOIN tblEMEntity Entity ON Entity.intEntityId = Contract.intEntityId 
	LEFT OUTER JOIN tblCTWeightGrade WeightGrade ON WeightGrade.intWeightGradeId = Contract.intWeightId
	LEFT OUTER JOIN tblSMCurrency ContractDetailCurrency ON ContractDetailCurrency.intCurrencyID = ContractDetail.intCurrencyId
	LEFT OUTER JOIN tblSMFreightTerms LoadFreightTerm ON LoadFreightTerm.intFreightTermId = Load.intFreightTermId
	OUTER APPLY (
		SELECT currency.intCurrencyID, currency.strCurrency
		FROM tblSMCurrency currency
		WHERE currency.intCurrencyID = CASE WHEN ContractDetail.ysnUseFXPrice = 1 THEN ContractDetailExtras.intSeqCurrencyId ELSE ISNULL(ISNULL(ContractDetail.intCurrencyId, ContractDetailCurrency.intMainCurrencyId), dbo.fnSMGetDefaultCurrency('FUNCTIONAL')) END
	) SubCurrency
	OUTER APPLY (
		SELECT TOP 1 *
		FROM tblICCompanyPreference			
	) ICPreference
	OUTER APPLY (
		SELECT intForexRateTypeId = MultiCurrencyDefault.intContractRateTypeId, ForexRateType.strCurrencyExchangeRateType
		FROM tblSMCompanyPreference Company
			INNER JOIN tblSMMultiCurrency MultiCurrencyDefault ON MultiCurrencyDefault.intMultiCurrencyId = Company.intMultiCurrencyId
			INNER JOIN tblSMCurrencyExchangeRateType ForexRateType ON ForexRateType.intCurrencyExchangeRateTypeId = MultiCurrencyDefault.intContractRateTypeId
		-- Get the contract default forex rate type
		WHERE LoadDetail.intForexRateTypeId IS NULL
			AND Company.intDefaultCurrencyId <> CASE WHEN ContractDetail.ysnUseFXPrice = 1 THEN ContractDetailExtras.intSeqCurrencyId ELSE ISNULL(ISNULL(ContractDetailCurrency.intMainCurrencyId, ContractDetail.intCurrencyId), dbo.fnSMGetDefaultCurrency('FUNCTIONAL')) END -- Logistic currency is not the functional currnecy. 
		) CompanyPreferenceForexRateType
		OUTER APPLY dbo.fnSMGetForexRate(
			CASE WHEN ContractDetail.ysnUseFXPrice = 1 THEN ContractDetailExtras.intSeqCurrencyId ELSE ISNULL(ISNULL(ContractDetailCurrency.intMainCurrencyId, ContractDetail.intCurrencyId), dbo.fnSMGetDefaultCurrency('FUNCTIONAL')) END
			,ISNULL(LoadDetail.intForexRateTypeId, CompanyPreferenceForexRateType.intForexRateTypeId)
			,Load.dtmScheduledDate
		) defaultForexRate
	LEFT OUTER JOIN tblSMCurrencyExchangeRateType currencyType ON currencyType.intCurrencyExchangeRateTypeId = LoadDetail.intForexRateTypeId
WHERE Load.ysnPosted = 1
	AND Load.intTransUsedBy = 1
	AND Load.intPurchaseSale = 1
	AND (LoadContainerLink.dblQuantity - ISNULL(LoadContainerLink.dblReceivedQty, 0)) > 0
	AND ISNULL(LoadContainer.ysnRejected, 0) <> 1
	AND Item.strType NOT IN('Software', 'Other Charge', 'Comment', 'Service')
	--AND LoadDetail.intVendorEntityId = 879
	--AND intCurrencyId = 3