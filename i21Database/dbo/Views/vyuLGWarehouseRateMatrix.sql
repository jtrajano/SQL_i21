CREATE VIEW vyuLGWarehouseRateMatrix
AS
SELECT 
		WMD.intWarehouseRateMatrixDetailId
		,WMD.strCategory
		,WMD.strActivity
		,WMD.intType
		,WMD.intSort
		,WMD.dblUnitRate
		,WMD.[intItemUOMId]
		,WMD.ysnPrint
		,WMD.strComments
		,WMD.intItemId
		,WMD.intCalculateQty
		,strCalculateQty = CASE WMD.intCalculateQty 
							WHEN 1 THEN 'By Shipped Net Wt'
							WHEN 2 THEN 'By Shipped Gross Wt'
							WHEN 3 THEN 'By Received Net Wt'
							WHEN 4 THEN 'By Received Gross Wt'
							WHEN 5 THEN 'By Delivered Net Wt'
							WHEN 6 THEN 'By Delivered Gross Wt'
							WHEN 7 THEN 'By Quantity'
							WHEN 8 THEN 'Manual Entry' 
						   END
		,Item.strItemNo
		,WMH.intWarehouseRateMatrixHeaderId
		,WMH.strServiceContractNo
		,WMH.dtmContractDate
		,WMH.intCompanyLocationId
		,WMH.intCommodityId
		,WMH.intCompanyLocationSubLocationId
		,WMH.intVendorEntityId
		,WMH.dtmValidityFrom
		,WMH.dtmValidityTo
		,WMH.ysnActive
		,WMH.intCurrencyId
		,UOM.intUnitMeasureId
		,UOM.strUnitMeasure
		,UOM.strUnitType
		,Currency.strCurrency
FROM tblLGWarehouseRateMatrixDetail WMD
JOIN tblLGWarehouseRateMatrixHeader WMH ON WMH.intWarehouseRateMatrixHeaderId = WMD.intWarehouseRateMatrixHeaderId
LEFT JOIN tblICItemUOM IU ON IU.intItemUOMId = WMD.intItemUOMId
LEFT JOIN tblICUnitMeasure UOM	ON UOM.intUnitMeasureId = IU.intUnitMeasureId
LEFT JOIN tblSMCurrency Currency ON Currency.intCurrencyID = WMH.intCurrencyId
LEFT JOIN tblICItem Item ON Item.intItemId = WMD.intItemId