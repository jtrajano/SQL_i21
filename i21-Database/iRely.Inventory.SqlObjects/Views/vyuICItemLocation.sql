CREATE VIEW [dbo].[vyuICItemLocation]
AS 

SELECT	* 
FROM	tblICItemLocation
WHERE	intLocationId IS NOT NULL 
