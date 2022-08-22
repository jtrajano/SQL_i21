CREATE PROCEDURE [dbo].[uspICUpdateRecostFormulationItems]
	@intRecostFormulationId INT 
AS

IF NOT EXISTS (SELECT TOP 1 1 FROM tblICRecostFormulation r WHERE r.intRecostFormulationId = @intRecostFormulationId AND ISNULL(ysnPosted, 0) = 0) 
BEGIN 
	RETURN; -- Exits Immediately 
END 

UPDATE tblICRecostFormulation
SET 
	intConcurrencyId = ISNULL(intConcurrencyId, 0) + 1
WHERE 
	intRecostFormulationId = @intRecostFormulationId 

-- Update the Standard Cost
UPDATE p
SET
	p.dblStandardCost = ri.dblNewStandardCost 	
FROM 
	tblICRecostFormulation r INNER JOIN tblICRecostFormulationDetail ri
		ON r.intRecostFormulationId = ri.intRecostFormulationId
	INNER JOIN tblICItem i 
		ON i.intItemId = ri.intItemId
	INNER JOIN tblICItemLocation il 
		ON il.intItemId = i.intItemId
		AND il.intLocationId = ri.intLocationId 
	INNER JOIN tblICItemPricing p
		ON p.intItemId = ri.intItemId
		AND p.intItemLocationId = il.intItemLocationId 		
WHERE 
	r.intRecostFormulationId = @intRecostFormulationId
	AND ISNULL(ri.dblNewStandardCost, 0) <> 0 
	AND p.dblStandardCost <> ri.dblNewStandardCost 

-- Update the Retail Price 
UPDATE p
SET
	dblSalePrice = ISNULL(NULLIF(ri.dblNewRetailPrice, 0), p.dblSalePrice) 
FROM 
	tblICRecostFormulation r INNER JOIN tblICRecostFormulationDetail ri
		ON r.intRecostFormulationId = ri.intRecostFormulationId
	INNER JOIN tblICItem i 
		ON i.intItemId = ri.intItemId
	INNER JOIN tblICItemLocation il 
		ON il.intItemId = i.intItemId
		AND il.intLocationId = ri.intLocationId 
	INNER JOIN tblICItemPricing p
		ON p.intItemId = ri.intItemId
		AND p.intItemLocationId = il.intItemLocationId 		
WHERE 
	r.intRecostFormulationId = @intRecostFormulationId
	AND ISNULL(ri.dblNewRetailPrice, 0) <> 0 
	AND ri.dblNewRetailPrice <> p.dblSalePrice

UPDATE tblICRecostFormulation
SET 
	ysnPosted = 1 
WHERE 
	intRecostFormulationId = @intRecostFormulationId 

RETURN 0
