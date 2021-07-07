CREATE PROCEDURE dbo.uspMFGetItemStockByUPCCode (
	@strUPCCode NVARCHAR(50)
	,@intLocationId INT
	,@intStorageLocationId INT = NULL
	)
AS
DECLARE @intItemUOMId INT
	,@strShortUpcCode NVARCHAR(50)
	,@intUnitMeasureId INT
	,@strUnitMeasure NVARCHAR(50)
	,@intItemId INT
	,@intItemLocationId INT
	,@intItemStockUOMId int 

SELECT @intItemUOMId = IU.intItemUOMId
	,@strShortUpcCode = IsNULL(IUA.strUpcCode, IU.strUpcCode)

	,@intItemId = intItemId
FROM tblICItemUOM IU
LEFT JOIN tblICItemUomUpc IUA ON IUA.intItemUOMId = IU.intItemUOMId
WHERE IsNULL(IUA.strLongUpcCode, IU.strLongUPCCode) = @strUPCCode

Select @intItemStockUOMId = intItemUOMId
			,@intUnitMeasureId = intUnitMeasureId
from tblICItemUOM
Where intItemId = @intItemId and ysnStockUnit=1

SELECT @strUnitMeasure = strUnitMeasure
FROM tblICUnitMeasure
WHERE intUnitMeasureId = @intUnitMeasureId

SELECT @intItemLocationId = intItemLocationId
FROM tblICItemLocation
WHERE intItemId = @intItemId
	AND intLocationId = @intLocationId

IF @intStorageLocationId IS NOT NULL
BEGIN
	SELECT I.intItemId
		,I.strItemNo
		,@strUPCCode AS strUPCCode
		,@strShortUpcCode AS strShortUpcCode
		,dbo.fnMFConvertQuantityToTargetItemUOM(@intItemStockUOMId,@intItemUOMId,SU.dblOnHand)
		,dbo.fnMFConvertQuantityToTargetItemUOM(@intItemStockUOMId,@intItemUOMId,SU.dblUnitReserved)
		,dbo.fnMFConvertQuantityToTargetItemUOM(@intItemStockUOMId,@intItemUOMId,SU.dblOnHand) - dbo.fnMFConvertQuantityToTargetItemUOM(@intItemStockUOMId,@intItemUOMId,SU.dblUnitReserved) AS dblAvailableQty
		,@intUnitMeasureId AS intUnitMeasureId
		,@strUnitMeasure AS strUnitMeasure
		,SL1.strName AS strStorageUnit
		,SL.strSubLocationName AS strStorageLocation
		,Count(I.intItemId) OVER (
			) intItemCount
	FROM tblICItemStockUOM SU
	JOIN tblICItem I ON I.intItemId = SU.intItemId
	LEFT JOIN tblSMCompanyLocationSubLocation SL ON SL.intCompanyLocationSubLocationId = SU.intSubLocationId
	LEFT JOIN tblICStorageLocation SL1 ON SL1.intStorageLocationId = SU.intStorageLocationId
	WHERE intItemUOMId = @intItemStockUOMId
		AND SU.dblOnHand > 0
		AND SU.intItemLocationId = @intItemLocationId
		AND IsNULL(SU.intStorageLocationId, @intStorageLocationId) = @intStorageLocationId
END
ELSE
BEGIN
	SELECT I.intItemId
		,I.strItemNo
		,@strUPCCode AS strUPCCode
		,@strShortUpcCode AS strShortUpcCode
		,dbo.fnMFConvertQuantityToTargetItemUOM(@intItemStockUOMId,@intItemUOMId,SU.dblOnHand)
		,dbo.fnMFConvertQuantityToTargetItemUOM(@intItemStockUOMId,@intItemUOMId,SU.dblUnitReserved)
		,dbo.fnMFConvertQuantityToTargetItemUOM(@intItemStockUOMId,@intItemUOMId,SU.dblOnHand) - dbo.fnMFConvertQuantityToTargetItemUOM(@intItemStockUOMId,@intItemUOMId,SU.dblUnitReserved) AS dblAvailableQty
		,@intUnitMeasureId AS intUnitMeasureId
		,@strUnitMeasure AS strUnitMeasure
		,SL1.strName AS strStorageUnit
		,SL.strSubLocationName AS strStorageLocation
		,Count(I.intItemId) OVER (
			) intItemCount
	FROM tblICItemStockUOM SU
	JOIN tblICItem I ON I.intItemId = SU.intItemId
	LEFT JOIN tblSMCompanyLocationSubLocation SL ON SL.intCompanyLocationSubLocationId = SU.intSubLocationId
	LEFT JOIN tblICStorageLocation SL1 ON SL1.intStorageLocationId = SU.intStorageLocationId
	WHERE intItemUOMId = @intItemStockUOMId
		AND SU.dblOnHand > 0
		AND SU.intItemLocationId = @intItemLocationId
END
