CREATE PROCEDURE uspMFGetPalletPlacard (@strLotNumber NVARCHAR(MAX))
AS
BEGIN
	DECLARE @tblMFLot TABLE (
		strLotNumber NVARCHAR(50) collate Latin1_General_CI_AS
		,intLocationId INT
		)

	INSERT INTO @tblMFLot
	SELECT strLotNumber
		,intLocationId
	FROM tblICLot
	WHERE intLotId IN (
			SELECT x.Item COLLATE DATABASE_DEFAULT
			FROM dbo.fnSplitString(@strLotNumber, '^') x
			)

	SELECT I.strItemNo
		,I.strDescription
		,UM.strUnitMeasure
		,SUM(L.dblQty) AS dblTotalQty
		,dbo.fnSMGetCompanyLogo('CompanyLogo') AS strLogo
		,L.strLotNumber 
		,L.intLocationId
	FROM tblICLot L
	JOIN tblICItem I ON I.intItemId = L.intItemId
	JOIN dbo.tblICItemUOM IU ON IU.intItemUOMId = L.intItemUOMId 
	JOIN dbo.tblICUnitMeasure UM ON UM.intUnitMeasureId = IU.intUnitMeasureId
	JOIN @tblMFLot L1 ON L1.strLotNumber = L.strLotNumber
		AND L1.intLocationId = L.intLocationId
	WHERE L.ysnProduced = 0
	GROUP BY I.strItemNo
		,I.strDescription
		,UM.strUnitMeasure
		,L.strLotNumber 
		,L.intLocationId
	
	UNION
	
	SELECT DT.strItemNo
		,DT.strDescription
		,DT.strUnitMeasure
		,SUM(DT.dblPhysicalCount) OVER (PARTITION BY DT.strLotNumber) dblTotalQty
		,dbo.fnSMGetCompanyLogo('WholesomeSweeteners') AS strLogo
		,DT.strLotNumber
		,DT.intLocationId
	FROM (
		SELECT I.strItemNo
			,I.strDescription
			,strParentLotNumber
			,SUM(WP.dblPhysicalCount) AS dblPhysicalCount
			,UM.strUnitMeasure
			,L.strLotNumber 
			,L.intLocationId
		FROM tblMFWorkOrderProducedLot WP
		JOIN tblICLot L ON L.intLotId = WP.intLotId
			AND WP.ysnProductionReversed = 0
		JOIN tblICItem I ON I.intItemId = L.intItemId
		JOIN dbo.tblICItemUOM IU ON IU.intItemUOMId = WP.intPhysicalItemUOMId
		JOIN dbo.tblICUnitMeasure UM ON UM.intUnitMeasureId = IU.intUnitMeasureId
		JOIN @tblMFLot L1 ON L1.strLotNumber = L.strLotNumber
			AND L1.intLocationId = L.intLocationId
		WHERE L.ysnProduced = 1
		GROUP BY I.strItemNo
			,I.strDescription
			,strParentLotNumber
			,UM.strUnitMeasure
			,L.strLotNumber
			,L.intLocationId
		) AS DT
END
