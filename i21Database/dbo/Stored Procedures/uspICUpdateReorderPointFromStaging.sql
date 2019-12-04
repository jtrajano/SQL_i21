CREATE PROCEDURE [dbo].[uspICUpdateReorderPointFromStaging]
AS
UPDATE il
SET	  il.dblLeadTime = rp.dblLeadTime
	, il.dblMinOrder = rp.dblMinOrder
	, il.dblReorderPoint = rp.dblReorderPoint
	, il.dblSuggestedQty = rp.dblSuggestedQty
	, il.strStorageUnitNo = NULLIF(rp.strStorageUnitNo '')
FROM tblICItemLocation il
	INNER JOIN tblICStagingReorderPoint rp ON rp.intItemLocationId = il.intItemLocationId

DELETE FROM tblICStagingReorderPoint