﻿CREATE PROCEDURE uspMFGetProductionLine (
	@intItemId INT
	,@intLocationId INT
	)
AS
BEGIN
	SELECT C.intManufacturingCellId
		,C.strCellName
		,C.strDescription
	FROM dbo.tblICItem I
	JOIN dbo.tblICItemFactory IL ON IL.intItemId = I.intItemId
	JOIN dbo.tblICItemFactoryManufacturingCell MC ON MC.intItemFactoryId = IL.intItemFactoryId
	JOIN dbo.tblICManufacturingCell C ON C.intManufacturingCellId = MC.intManufacturingCellId
	WHERE C.intLocationId = @intLocationId
		AND I.intItemId = @intItemId
END

