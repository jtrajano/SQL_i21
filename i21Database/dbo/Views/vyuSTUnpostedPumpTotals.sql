CREATE VIEW [dbo].[vyuSTUnpostedPumpTotals]
AS

SELECT 
	strType			= 'tblSTCheckoutPumpTotals' COLLATE Latin1_General_CI_AS,
	intKeyId		= tblSTCheckoutPumpTotals.intPumpTotalsId,
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
	strCategoryCode = tblICCategory.strCategoryCode,
	intCompanyLocationId = tblSTStore.intCompanyLocationId,
	intItemUOMId = tblICItemUOM.intItemUOMId
FROM 
	tblSTCheckoutHeader
	INNER JOIN tblSTCheckoutPumpTotals
		ON tblSTCheckoutHeader.intCheckoutId = tblSTCheckoutPumpTotals.intCheckoutId
	LEFT JOIN tblSTStore
		ON tblSTCheckoutHeader.intStoreId = tblSTStore.intStoreId
	LEFT OUTER JOIN tblICCategory 
		ON tblSTCheckoutPumpTotals.intCategoryId = tblICCategory.intCategoryId
	INNER JOIN tblICItemUOM 
		ON tblSTCheckoutPumpTotals.intPumpCardCouponId = tblICItemUOM.intItemUOMId
	LEFT OUTER JOIN tblICItem 
		ON tblICItemUOM.intItemId = tblICItem.intItemId
WHERE 
	ysnPosted = 0 OR ysnPosted = NULL