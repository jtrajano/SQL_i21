CREATE VIEW vyuIPLoadCostView
AS
SELECT LC.intLoadCostId
	  ,LC.intLoadId
	  ,LC.strEntityType
	  ,LC.strCostMethod
	  ,C.strCurrency
	  ,LC.dblRate
	  ,LC.dblAmount
	  ,LC.ysnAccrue
	  ,LC.ysnMTM
	  ,LC.ysnPrice
	  ,E.strName AS strEntityName
	  ,UM.strUnitMeasure
	  ,I.strItemNo
FROM tblLGLoadCost LC
JOIN tblEMEntity E ON E.intEntityId = LC.intVendorId
JOIN tblLGLoad L ON L.intLoadId = LC.intLoadId
LEFT JOIN tblICItemUOM IU ON IU.intItemUOMId = LC.intItemUOMId
LEFT JOIN tblICUnitMeasure UM ON UM.intUnitMeasureId = IU.intUnitMeasureId
LEFT JOIN tblICItem I ON I.intItemId = LC.intItemId
LEFT JOIN tblSMCurrency C ON C.intCurrencyID = LC.intCurrencyId
LEFT JOIN tblAPBill B ON B.intBillId = LC.intBillId
LEFT JOIN tblCTBook BO ON BO.intBookId = L.intBookId
LEFT JOIN tblCTSubBook SB ON SB.intSubBookId = L.intSubBookId