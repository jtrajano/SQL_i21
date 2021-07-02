CREATE PROCEDURE dbo.uspMFGetItemStockByUPCCode (
	@strUPCCode NVARCHAR(50)
	,@intLocationId INT
	)
AS
DECLARE @intItemUOMId INT
	,@strShortUpcCode NVARCHAR(50)
	,@intUnitMeasureId INT
	,@strUnitMeasure NVARCHAR(50)
	,@intItemId INT
	,@intItemLocationId INT

SELECT @intItemUOMId = IU.intItemUOMId
	,@strShortUpcCode = IsNULL(IUA.strUpcCode, IU.strUpcCode)
	,@intUnitMeasureId = intUnitMeasureId
	,@intItemId = intItemId
FROM tblICItemUOM IU
LEFT JOIN tblICItemUomUpc IUA ON IUA.intItemUOMId = IU.intItemUOMId
WHERE IsNULL(IUA.strLongUpcCode, IU.strLongUPCCode) = @strUPCCode

SELECT @strUnitMeasure = strUnitMeasure
FROM tblICUnitMeasure
WHERE intUnitMeasureId = @intUnitMeasureId

SELECT @intItemLocationId = intItemLocationId
FROM tblICItemLocation
WHERE intItemId = @intItemId
	AND intLocationId = @intLocationId

SELECT I.intItemId
	,I.strItemNo
	,@strUPCCode AS strUPCCode
	,@strShortUpcCode AS strShortUpcCode
	,SU.dblOnHand
	,SU.dblUnitReserved
	,SU.dblOnHand - SU.dblUnitReserved AS dblAvailableQty
	,@intUnitMeasureId AS intUnitMeasureId
	,@strUnitMeasure AS strUnitMeasure
	,SL1.strName AS strStorageUnit
	,SL.strSubLocationName AS strStorageLocation
FROM tblICItemStockUOM SU
JOIN tblICItem I ON I.intItemId = SU.intItemId
LEFT JOIN tblSMCompanyLocationSubLocation SL ON SL.intCompanyLocationSubLocationId = SU.intSubLocationId
LEFT JOIN tblICStorageLocation SL1 ON SL1.intStorageLocationId = SU.intStorageLocationId
WHERE intItemUOMId = @intItemUOMId
	AND SU.dblOnHand > 0
	AND SU.intItemLocationId = @intItemLocationId