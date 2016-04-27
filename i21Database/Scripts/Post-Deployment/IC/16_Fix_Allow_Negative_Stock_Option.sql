-- --------------------------------------------------
-- Script for SQL Server 2005, 2008, and Azure
-- Purpose: Insert fresh data for the inventory Cost Adjustment Types. 
-- --------------------------------------------------

print('/*******************  BEGIN Fixing the Allow Negative Option *******************/')
GO

-- Switch all Allow Negative Stock Option from "Yes with Auto Write-Off" to "Yes"
-- "Yes with Auto Write-Off" is obsolete starting 16.1. 
UPDATE dbo.tblICItemLocation
SET	intAllowNegativeInventory = 1
WHERE intAllowNegativeInventory = 2

GO
print('/*******************  END Fixing the Allow Negative Option *******************/')