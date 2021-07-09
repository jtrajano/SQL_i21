﻿CREATE PROCEDURE dbo.uspMFGetItemStockByUPCCode (
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
	,@intItemStockUOMId INT

SELECT @intItemUOMId = IU.intItemUOMId
	,@strShortUpcCode = IsNULL(IUA.strUpcCode, IU.strUpcCode)
	,@intItemId = IU.intItemId
	,@intUnitMeasureId = IU.intUnitMeasureId
FROM tblICItemUOM IU
LEFT JOIN tblICItemUomUpc IUA ON IUA.intItemUOMId = IU.intItemUOMId
WHERE IsNULL(IUA.strLongUpcCode, IU.strLongUPCCode) = @strUPCCode

SELECT @intItemStockUOMId = intItemUOMId
FROM tblICItemUOM
WHERE intItemId = @intItemId
	AND ysnStockUnit = 1

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
		,I.strDescription
		,@strUPCCode AS strUPCCode
		,@strShortUpcCode AS strShortUpcCode
		,dbo.fnMFConvertQuantityToTargetItemUOM(@intItemUOMId, @intItemUOMId, SU.dblOnHand) AS dblOnHandQty
		,dbo.fnMFConvertQuantityToTargetItemUOM(@intItemUOMId, @intItemUOMId, SU.dblUnitReserved) AS dblReservedQty
		,dbo.fnMFConvertQuantityToTargetItemUOM(@intItemUOMId, @intItemUOMId, SU.dblOnHand) - dbo.fnMFConvertQuantityToTargetItemUOM(@intItemUOMId, @intItemUOMId, SU.dblUnitReserved) AS dblAvailableQty
		,@intItemUOMId AS intItemUOMId
		,@intUnitMeasureId AS intUnitMeasureId
		,@strUnitMeasure AS strUnitMeasure
		,SU.intStorageLocationId
		,SL1.strName AS strStorageUnit
		,SU.intSubLocationId
		,SL.strSubLocationName AS strStorageLocation
	FROM tblICItemStockUOM SU
	JOIN tblICItem I ON I.intItemId = SU.intItemId
	LEFT JOIN tblSMCompanyLocationSubLocation SL ON SL.intCompanyLocationSubLocationId = SU.intSubLocationId
	LEFT JOIN tblICStorageLocation SL1 ON SL1.intStorageLocationId = SU.intStorageLocationId
	WHERE SU.intItemUOMId = @intItemUOMId
		AND SU.dblOnHand > 0
		AND SU.intItemLocationId = @intItemLocationId
		AND IsNULL(SU.intStorageLocationId, @intStorageLocationId) = @intStorageLocationId
END
ELSE
BEGIN
	SELECT I.intItemId
		,I.strItemNo
		,I.strDescription
		,@strUPCCode AS strUPCCode
		,@strShortUpcCode AS strShortUpcCode
		,dbo.fnMFConvertQuantityToTargetItemUOM(@intItemUOMId, @intItemUOMId, SU.dblOnHand) AS dblOnHandQty
		,dbo.fnMFConvertQuantityToTargetItemUOM(@intItemUOMId, @intItemUOMId, SU.dblUnitReserved) AS dblReservedQty
		,dbo.fnMFConvertQuantityToTargetItemUOM(@intItemUOMId, @intItemUOMId, SU.dblOnHand) - dbo.fnMFConvertQuantityToTargetItemUOM(@intItemUOMId, @intItemUOMId, SU.dblUnitReserved) AS dblAvailableQty
		,@intItemUOMId AS intItemUOMId
		,@intUnitMeasureId AS intUnitMeasureId
		,@strUnitMeasure AS strUnitMeasure
		,SU.intStorageLocationId
		,SL1.strName AS strStorageUnit
		,SU.intSubLocationId
		,SL.strSubLocationName AS strStorageLocation
	FROM tblICItemStockUOM SU
	JOIN tblICItem I ON I.intItemId = SU.intItemId
	LEFT JOIN tblSMCompanyLocationSubLocation SL ON SL.intCompanyLocationSubLocationId = SU.intSubLocationId
	LEFT JOIN tblICStorageLocation SL1 ON SL1.intStorageLocationId = SU.intStorageLocationId
	WHERE SU.intItemUOMId = @intItemUOMId
		AND SU.dblOnHand > 0
		AND SU.intItemLocationId = @intItemLocationId
END
