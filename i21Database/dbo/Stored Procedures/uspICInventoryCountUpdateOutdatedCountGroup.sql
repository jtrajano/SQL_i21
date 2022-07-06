CREATE PROCEDURE dbo.uspICInventoryCountUpdateOutdatedCountGroup 
(
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
	INNER JOIN vyuICGetInventoryCountOutdatedCountGroup os 
		ON os.intInventoryCountDetailId = cd.intInventoryCountDetailId
WHERE 
	cd.intInventoryCountId = @intInventoryCountId

