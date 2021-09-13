CREATE PROCEDURE uspMFGetBlendItem (
	@intLocationId INT
	,@strUPCCode NVARCHAR(50)
	)
AS
BEGIN
IF EXISTS (
		SELECT 1
		FROM tblICItemUomUpc IUA
		WHERE IUA.strLongUpcCode = @strUPCCode
		)
BEGIN
	SELECT DISTINCT i.intItemId
		,i.strItemNo
		,i.strDescription
		,iu.intItemUOMId
		,iu.strLongUPCCode
		,iu.strUpcCode AS strShortUpcCode
	FROM tblICItem i
	JOIN tblICItemUOM iu ON i.intItemId = iu.intItemId
	JOIN tblICItemUomUpc IUA ON IUA.intItemUOMId = iu.intItemUOMId
	AND IUA.strLongUpcCode = @strUPCCode
	JOIN tblMFRecipe r ON i.intItemId = r.intItemId
	JOIN tblMFManufacturingProcess mp ON r.intManufacturingProcessId = mp.intManufacturingProcessId
		AND mp.intAttributeTypeId = 2
	WHERE r.ysnActive = 1
		AND r.intLocationId = @intLocationId
		AND strStatus = N'Active'
END
ELSE
BEGIN
	SELECT DISTINCT i.intItemId
		,i.strItemNo
		,i.strDescription
		,iu.intItemUOMId
		,iu.strLongUPCCode
		,iu.strUpcCode AS strShortUpcCode
	FROM tblICItem i
	JOIN tblICItemUOM iu ON i.intItemId = iu.intItemId
		AND iu.strLongUPCCode = @strUPCCode
	JOIN tblMFRecipe r ON i.intItemId = r.intItemId
	JOIN tblMFManufacturingProcess mp ON r.intManufacturingProcessId = mp.intManufacturingProcessId
		AND mp.intAttributeTypeId = 2
	WHERE r.ysnActive = 1
		AND r.intLocationId = @intLocationId
		AND strStatus = N'Active'
END
END
