CREATE VIEW [dbo].[vyuARGetItemAccount]
AS
SELECT     
Item.intItemId, 
Item.strItemNo,
Item.strType,
dbo.fnGetItemGLAccount(Item.intItemId, ItemLocation.intLocationId, N'Service Charges') AS intAccountId, 
dbo.fnGetItemGLAccount(Item.intItemId, ItemLocation.intLocationId, N'COGS') AS intCOGSAccountId, 
dbo.fnGetItemGLAccount(Item.intItemId, ItemLocation.intLocationId, N'Sales') AS intSalesAccountId, 
dbo.fnGetItemGLAccount(Item.intItemId, ItemLocation.intLocationId, N'Inventory') AS intInventoryAccountId
FROM         
dbo.tblICItem AS Item LEFT OUTER JOIN
dbo.tblICItemLocation AS ItemLocation ON ItemLocation.intItemId = Item.intItemId
