CREATE VIEW vyuMFGetDemandEntry
AS
SELECT DD.intDemandDetailId
	 , DD.intDemandHeaderId
	 , DH.strDemandNo
	 , DH.strDemandName
	 , DH.dtmDate
	 , B.strBook
	 , SB.strSubBook
	 , I.strItemNo
	 , I.strType
	 , I1.strItemNo AS strSubstituteItemNo
	 , dtmDemandDate
	 , dblQuantity
	 , UOM.strUnitMeasure AS strItemUOM
	 , CL.strLocationName
	 , I.strDescription
FROM tblMFDemandHeader DH
JOIN tblMFDemandDetail DD ON DD.intDemandHeaderId = DH.intDemandHeaderId
LEFT JOIN tblCTBook B ON B.intBookId = DH.intBookId
LEFT JOIN tblCTSubBook SB ON SB.intSubBookId = DH.intSubBookId
LEFT JOIN tblICItem I ON I.intItemId = DD.intItemId
LEFT JOIN tblICItem I1 ON I1.intItemId = DD.intSubstituteItemId
LEFT JOIN tblICItemUOM IUOM ON IUOM.intItemUOMId = DD.intItemUOMId
LEFT JOIN tblICUnitMeasure UOM ON UOM.intUnitMeasureId = IUOM.intUnitMeasureId
LEFT JOIN tblSMCompanyLocation CL ON CL.intCompanyLocationId = DD.intCompanyLocationId
