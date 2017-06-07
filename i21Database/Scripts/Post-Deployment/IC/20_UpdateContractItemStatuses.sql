---------------------------
-- Script for SQL Server 2005, 2008, and Azure
-- Purpose: Update NULL status value of item contracts. Set to Discontinued if the item status is Discontinued.
-- --------------------------------------------------

UPDATE c
SET c.strStatus = CASE i.strStatus WHEN 'Discontinued' THEN 'Discontinued' ELSE CASE WHEN c.strStatus IS NULL THEN 'Active' ELSE c.strStatus END END
FROM tblICItemContract c
	INNER JOIN tblICItem i ON i.intItemId = c.intItemId