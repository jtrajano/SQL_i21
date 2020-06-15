
CREATE VIEW [dbo].[vyuSTUnpostedItemSales]
AS

SELECT 
strType			= 'tblSTCheckoutPumpTotals' COLLATE Latin1_General_CI_AS,
intKeyId			= tblSTCheckoutPumpTotals.intPumpTotalsId,
strDescription	= tblSTCheckoutPumpTotals.strDescription,
ysnPosted		= tblSTCheckoutHeader.ysnPosted,
intCheckoutId	= tblSTCheckoutHeader.intCheckoutId,
intStoreId		= tblSTCheckoutHeader.intStoreId,
dtmCheckoutDate = tblSTCheckoutHeader.dtmCheckoutDate,
dblAmount		= tblSTCheckoutPumpTotals.dblAmount,
dblPrice		= tblSTCheckoutPumpTotals.dblPrice,
dblQuantity		= tblSTCheckoutPumpTotals.dblQuantity,
intItemId		= tblICItem.intItemId,
strItemNo		= tblICItem.strItemNo,
intCategoryId   = tblICCategory.intCategoryId,
strCategoryCode = tblICCategory.strCategoryCode
FROM tblSTCheckoutHeader
INNER JOIN tblSTCheckoutPumpTotals
ON tblSTCheckoutHeader.intCheckoutId = tblSTCheckoutPumpTotals.intCheckoutId
LEFT OUTER JOIN tblICCategory ON tblSTCheckoutPumpTotals.intCategoryId = tblICCategory.intCategoryId
INNER JOIN tblICItemUOM ON tblSTCheckoutPumpTotals.intPumpCardCouponId = tblICItemUOM.intItemUOMId
LEFT OUTER JOIN tblICItem ON tblICItemUOM.intItemId = tblICItem.intItemId
WHERE ysnPosted = 0 OR ysnPosted = NULL

UNION ALL

SELECT 
strType			= 'tblSTCheckoutItemMovements',
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
strCategoryCode = tblICCategory.strCategoryCode
FROM tblSTCheckoutHeader 
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
WHERE ysnPosted = 0 OR ysnPosted = NULL