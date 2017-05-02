CREATE PROCEDURE uspMFGetPalletPlacard (@strLotNumber NVARCHAR(50))
AS
BEGIN
	SELECT DT.strItemNo
		,DT.strDescription
		,DT.strParentLotNumber
		,DT.dblPhysicalCount
		,DT.strUnitMeasure
		,SUM(DT.dblPhysicalCount) OVER () dblTotalQty
		,dbo.fnSMGetCompanyLogo('WholesomeSweeteners') as strLogo
	FROM (
		SELECT I.strItemNo
			,I.strDescription
			,strParentLotNumber
			,SUM(WP.dblPhysicalCount) AS dblPhysicalCount
			,UM.strUnitMeasure
		FROM tblMFWorkOrderProducedLot WP
		JOIN tblICLot L ON L.intLotId = WP.intLotId
		JOIN tblICItem I ON I.intItemId = L.intItemId
		JOIN dbo.tblICItemUOM IU ON IU.intItemUOMId = WP.intPhysicalItemUOMId
		JOIN dbo.tblICUnitMeasure UM ON UM.intUnitMeasureId = IU.intUnitMeasureId
		WHERE Left(L.strLotNumber, Len(@strLotNumber)) = Left(@strLotNumber, Len(@strLotNumber))
		GROUP BY I.strItemNo
			,I.strDescription
			,strParentLotNumber
			,UM.strUnitMeasure
		) AS DT
END
