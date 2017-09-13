CREATE PROCEDURE uspMFGetProductionLine (
	@intItemId INT
	,@intLocationId INT
	)
AS
BEGIN
	SELECT DISTINCT C.intManufacturingCellId
		,C.strCellName
		,C.strDescription
		,ISNULL(MC.ysnDefault, 0) AS ysnDefault
	FROM dbo.tblICItem I
	JOIN dbo.tblICItemFactory IL ON IL.intItemId = I.intItemId
	JOIN dbo.tblICItemFactoryManufacturingCell MC ON MC.intItemFactoryId = IL.intItemFactoryId
	JOIN dbo.[tblMFManufacturingCell] C ON C.intManufacturingCellId = MC.intManufacturingCellId
	WHERE C.intLocationId = @intLocationId
		AND I.intItemId = @intItemId
		ORDER BY C.strCellName
END

