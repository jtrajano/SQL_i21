CREATE PROCEDURE uspMFGetProductCountBySubLocation (@intSubLocationId INT,@strItemNo nvarchar(50)='%',@intItemId int=0,@intManufacturingProcessId int=0)
AS
BEGIN
	SELECT Count(*) AS ProductCount
	FROM dbo.tblMFRecipe R
	JOIN dbo.tblICItem I ON I.intItemId = R.intItemId
	JOIN dbo.tblICItemUOM IU ON IU.intItemId = I.intItemId
	JOIN dbo.tblICUnitMeasure U ON U.intUnitMeasureId = IU.intUnitMeasureId
	JOIN dbo.tblSMCompanyLocationSubLocationCategory C ON C.intCategoryId = I.intCategoryId
		AND C.intCompanyLocationSubLocationId = @intSubLocationId
		AND R.ysnActive = 1
		AND IU.ysnStockUnit = 1
		AND I.strStatus='Active'
		AND I.strItemNo LIKE @strItemNo+'%'
		AND I.intItemId =(Case When @intItemId >0 then @intItemId else I.intItemId end)
		AND R.intManufacturingProcessId =(Case When @intManufacturingProcessId >0 then @intManufacturingProcessId else R.intManufacturingProcessId end)
END