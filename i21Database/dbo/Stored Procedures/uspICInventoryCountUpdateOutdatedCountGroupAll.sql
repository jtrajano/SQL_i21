CREATE PROCEDURE dbo.uspICInventoryCountUpdateOutdatedCountGroupAll 
(
	@intInventoryCountId INT
)
AS

UPDATE cd
SET cd.dblSystemCount = os.dblNewOnHand,
	-- cd.dblLastCost = os.dblNewCost,
	cd.dblWeightQty = os.dblNewWeightQty,
	cd.dblNetQty = os.dblNewWeightQty
FROM 
	tblICInventoryCountDetail cd INNER JOIN vyuICGetInventoryCountOutdatedCountGroupAll os 
		ON os.intInventoryCountDetailId = cd.intInventoryCountDetailId
WHERE 
	cd.intInventoryCountId = @intInventoryCountId