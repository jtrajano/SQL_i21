CREATE VIEW [dbo].[vyuICItemLite]
AS
SELECT
	  i.intItemId
	, i.strItemNo
	, i.strType
	, i.strDescription
	, il.intItemLocationId
	, ipr.dblSalePrice
	, bi.intItemId AS [intBundleItemId]
	, bi.strItemNo AS [strBundleItemNo]
	, i.ysnAvailableTM
	, i.dblDefaultFull
	, il.intLocationId
FROM tblICItem i
	LEFT OUTER JOIN tblICItemLocation il ON il.intItemId = i.intItemId
	LEFT OUTER JOIN tblICItemPricing ipr ON ipr.intItemId = i.intItemId AND ipr.intItemLocationId = il.intItemLocationId
	LEFT OUTER JOIN tblICItemBundle ib ON ib.intItemId = i.intItemId
	LEFT OUTER JOIN tblICItem bi ON bi.intItemId = ib.intBundleItemId