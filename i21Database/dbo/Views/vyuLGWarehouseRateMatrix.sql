CREATE VIEW vyuLGWarehouseRateMatrix
AS
SELECT 
		WMD.intWarehouseRateMatrixDetailId
		,WMD.strCategory
		,WMD.strActivity
		,WMD.intType
		,WMD.intSort
		,WMD.dblUnitRate
		,WMD.intCommodityUnitMeasureId
		,WMD.ysnPrint
		,WMD.strComments
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
LEFT JOIN tblICCommodityUnitMeasure CUOM ON CUOM.intCommodityUnitMeasureId = WMD.intCommodityUnitMeasureId
LEFT JOIN tblICUnitMeasure UOM	ON UOM.intUnitMeasureId = CUOM.intUnitMeasureId
LEFT JOIN tblSMCurrency Currency ON Currency.intCurrencyID = WMH.intCurrencyId
