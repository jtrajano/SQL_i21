CREATE PROCEDURE dbo.uspICInventoryCountUpdateOutdatedItemStock (
	@intInventoryCountId INT
)
AS

UPDATE cd
SET 
	cd.dblSystemCount = os.dblNewOnHand,
	cd.dblWeightQty = os.dblNewWeightQty,
	cd.dblNetQty = os.dblNewWeightQty
FROM 
	tblICInventoryCountDetail cd
	INNER JOIN vyuICGetInventoryCountOutdatedItemStock os 
		ON os.intInventoryCountDetailId = cd.intInventoryCountDetailId
WHERE cd.intInventoryCountId = @intInventoryCountId