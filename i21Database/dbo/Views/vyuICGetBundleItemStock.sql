CREATE VIEW [dbo].[vyuICGetBundleItemStock]
	AS
SELECT	ItemComponent.*,
		intKitItemId = ItemBundle.intItemId,
		strKitItemNo = ItemBundleDetail.strItemNo,
		strKitItemDesc = ItemBundleDetail.strDescription,
		dblComponentQuantity = ItemBundle.dblQuantity,
		ItemBundle.dblMarkUpOrDown,
		ItemBundle.dtmBeginDate,
		ItemBundle.dtmEndDate
FROM tblICItemBundle ItemBundle
INNER JOIN tblICItem ItemBundleDetail ON ItemBundle.intItemId = ItemBundleDetail.intItemId
LEFT OUTER JOIN vyuICGetItemStock ItemComponent ON ItemComponent.intItemId = ItemBundle.intBundleItemId