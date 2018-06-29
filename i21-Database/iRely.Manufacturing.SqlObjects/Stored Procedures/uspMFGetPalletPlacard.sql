CREATE PROCEDURE uspMFGetPalletPlacard (@strLotNumber NVARCHAR(50))
AS
BEGIN
	IF EXISTS (
			SELECT *
			FROM tblICLot
			WHERE strLotNumber = @strLotNumber
				AND ysnProduced = 0
			)
	BEGIN
		SELECT I.strItemNo
			,I.strDescription
			,PL.strParentLotNumber
			,SUM(L.dblQty) AS dblPhysicalCount
			,UM.strUnitMeasure
			,SUM(L.dblQty) AS dblTotalQty
			,dbo.fnSMGetCompanyLogo('CompanyLogo') AS strLogo
		FROM tblICLot L
		JOIN tblICItem I ON I.intItemId = L.intItemId
		JOIN dbo.tblICItemUOM IU ON IU.intItemUOMId = L.intItemUOMId
		JOIN dbo.tblICUnitMeasure UM ON UM.intUnitMeasureId = IU.intUnitMeasureId
		JOIN tblICParentLot PL ON PL.intParentLotId = L.intParentLotId
		WHERE L.strLotNumber = @strLotNumber
		GROUP BY I.strItemNo
			,I.strDescription
			,PL.strParentLotNumber
			,UM.strUnitMeasure
	END
	ELSE
	BEGIN
		SELECT DT.strItemNo
			,DT.strDescription
			,DT.strParentLotNumber
			,DT.dblPhysicalCount
			,DT.strUnitMeasure
			,SUM(DT.dblPhysicalCount) OVER () dblTotalQty
			,dbo.fnSMGetCompanyLogo('WholesomeSweeteners') AS strLogo
		FROM (
			SELECT I.strItemNo
				,I.strDescription
				,strParentLotNumber
				,SUM(WP.dblPhysicalCount) AS dblPhysicalCount
				,UM.strUnitMeasure
			FROM tblMFWorkOrderProducedLot WP
			JOIN tblICLot L ON L.intLotId = WP.intLotId
				AND WP.ysnProductionReversed = 0
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
END
