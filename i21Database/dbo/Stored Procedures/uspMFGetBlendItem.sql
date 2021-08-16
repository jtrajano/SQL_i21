CREATE PROCEDURE uspMFGetBlendItem (
	@intLocationId INT
	,@strItemNo NVARCHAR(50)
	)
AS
BEGIN
	SELECT DISTINCT i.intItemId
		,i.strItemNo
		,i.strDescription
	FROM tblICItem i
	JOIN tblMFRecipe r ON i.intItemId = r.intItemId
	JOIN tblMFManufacturingProcess mp ON r.intManufacturingProcessId = mp.intManufacturingProcessId
		AND mp.intAttributeTypeId = 2
	WHERE r.ysnActive = 1
		AND r.intLocationId = @intLocationId
		AND strStatus = N'Active'
		AND strItemNo = @strItemNo
END