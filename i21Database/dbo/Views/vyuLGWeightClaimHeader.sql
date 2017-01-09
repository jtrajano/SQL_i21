CREATE VIEW vyuLGWeightClaimHeader
AS
SELECT
	WC.intWeightClaimId,
	WC.intPurchaseSale,
	strType = CASE WHEN Load.intPurchaseSale = 1 THEN 'Inbound' ELSE CASE WHEN Load.intPurchaseSale = 2 THEN 'Outbound'  ELSE 'Drop Ship' END END,
	WC.strReferenceNumber,
	WC.dtmTransDate,
	WC.intLoadId,
	WC.dtmETAPOD,
	WC.dtmLastWeighingDate,
	WC.dtmActualWeighingDate,
	Load.strLoadNumber,
	Load.dtmScheduledDate,
	Load.strBLNumber,
	Load.dtmBLDate,
	Load.intWeightUnitMeasureId,
	strWeightUOM = WUOM.strUnitMeasure
FROM tblLGWeightClaim WC
JOIN tblLGLoad Load ON Load.intLoadId = WC.intLoadId
JOIN tblICUnitMeasure WUOM ON WUOM.intUnitMeasureId = Load.intWeightUnitMeasureId


