CREATE VIEW [dbo].[vyuSTUnpostedItemMovements]
AS

SELECT 
	strType			= 'tblSTCheckoutItemMovements' COLLATE Latin1_General_CI_AS,
	intKeyId		= tblSTCheckoutItemMovements.intItemMovementId,
	strDescription	= tblSTCheckoutItemMovements.strDescription,
	ysnPosted		= tblSTCheckoutHeader.ysnPosted,
	intCheckoutId	= tblSTCheckoutHeader.intCheckoutId,
	intStoreId		= tblSTCheckoutHeader.intStoreId,
	dtmCheckoutDate = tblSTCheckoutHeader.dtmCheckoutDate,
	dblAmount		= tblSTCheckoutItemMovements.dblTotalSales,
	dblPrice		= tblSTCheckoutItemMovements.dblCurrentPrice,
	dblQuantity		= tblSTCheckoutItemMovements.intQtySold,
	intItemId		= tblICItem.intItemId,
	strItemNo		= tblICItem.strItemNo,
	intCategoryId   = tblICCategory.intCategoryId,
	strCategoryCode = tblICCategory.strCategoryCode,
	intCompanyLocationId = tblSTStore.intCompanyLocationId,
	intItemUOMId = tblICItemUOM.intItemUOMId
FROM 
	tblSTCheckoutHeader 
	INNER JOIN tblSTCheckoutItemMovements 
		ON tblSTCheckoutHeader.intCheckoutId = tblSTCheckoutItemMovements.intCheckoutId
	INNER JOIN tblSTStore
		ON tblSTCheckoutHeader.intStoreId = tblSTStore.intStoreId
	LEFT JOIN tblICItemUOM
		ON tblSTCheckoutItemMovements.intItemUPCId = tblICItemUOM.intItemUOMId
	LEFT JOIN tblICItem
		ON tblICItemUOM.intItemId = tblICItem.intItemId
	LEFT JOIN tblICCategory
		ON tblICItem.intCategoryId = tblICCategory.intCategoryId
WHERE 
	ysnPosted = 0 OR ysnPosted = NULL