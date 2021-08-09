CREATE VIEW vyuIPLoadStorageCostView
AS
SELECT 
		LD.intLoadId,
	   I.strItemNo,
	   LSC.intLoadStorageCostId,
	   C.strCurrency,
	   LSC.dblPrice,
	   PC.strCurrency AS strPriceCurrency, 
	   LSC.dblAmount,
	   UM.strUnitMeasure AS strUOM,
	   CT.strItemNo AS strCostType
From tblLGLoadDetail LD
JOIN tblLGLoadDetailLot LDL ON LDL.intLoadDetailId = LD.intLoadDetailId
JOIN tblICLot LOT ON LOT.intLotId = LDL.intLotId
JOIN tblICItem I ON I.intItemId = LOT.intItemId
JOIN tblLGLoadStorageCost LSC ON LSC.intLoadDetailLotId = LDL.intLoadDetailLotId 
LEFT JOIN tblICItemUOM PIU ON PIU.intItemUOMId = LSC.intPriceUOMId
LEFT JOIN tblICUnitMeasure UM ON UM.intUnitMeasureId = PIU.intUnitMeasureId
LEFT JOIN tblSMCurrency C ON C.intCurrencyID = LSC.intCurrency
LEFT JOIN tblSMCurrency PC ON PC.intCurrencyID = LSC.intPriceCurrencyId
LEFT JOIN vyuCTCostType CT ON CT.intItemId = LSC.intCostType
