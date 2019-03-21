CREATE VIEW [dbo].[vyuICGetInventoryInTransit]
AS

SELECT	* 
FROM	vyuICGetInventoryValuation
WHERE	ysnInTransit = 1