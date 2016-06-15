CREATE VIEW vyuLGLoadCostView
AS
SELECT LC.intLoadCostId
	  ,LC.intLoadId
	  ,LC.intItemId
	  ,LC.intVendorId AS intEntityId
	  ,LC.strCostMethod
	  ,LC.dblRate
	  ,LC.intItemUOMId
	  ,LC.ysnAccrue
	  ,LC.ysnMTM
	  ,LC.ysnPrice
	  ,E.strName AS strEntityName
	  ,L.strLoadNumber
	  ,UM.strUnitMeasure
	  ,I.strItemNo
FROM tblLGLoadCost LC
JOIN tblEMEntity E ON E.intEntityId = LC.intVendorId
JOIN tblLGLoad L ON L.intLoadId = LC.intLoadId
LEFT JOIN tblICItemUOM IU ON IU.intItemUOMId = LC.intItemUOMId
LEFT JOIN tblICUnitMeasure UM ON UM.intUnitMeasureId = IU.intUnitMeasureId
LEFT JOIN tblICItem I ON I.intItemId = LC.intItemId
