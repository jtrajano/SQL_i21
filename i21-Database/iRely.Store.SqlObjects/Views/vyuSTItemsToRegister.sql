CREATE VIEW  [dbo].[vyuSTItemsToRegister]
AS

-- Item Should have
-- 1. UOM
-- 2. Location
-- 3. Store (based on Location)
-- 4. Register (based on Store)
-- 5. Pricing
-- 6. Special Pricing

SELECT DISTINCT 
    x.dtmDateModified
	, x.dtmDateCreated
	, I.intItemId
	, EM.intEntityId
	, URN.ysnClick
	, SMUS.intCompanyLocationId
	, ST.intStoreId
FROM tblICItem AS I
JOIN tblICCategory Cat ON Cat.intCategoryId = I.intCategoryId
JOIN tblICItemLocation IL ON IL.intItemId = I.intItemId
LEFT JOIN tblSTSubcategoryRegProd SubCat ON SubCat.intRegProdId = IL.intProductCodeId
JOIN tblSTStore ST ON ST.intStoreId = SubCat.intStoreId
				   AND IL.intLocationId = ST.intCompanyLocationId
JOIN tblSMCompanyLocation L ON L.intCompanyLocationId = IL.intLocationId
JOIN tblICItemUOM IUOM ON IUOM.intItemId = I.intItemId 
JOIN tblICUnitMeasure IUM ON IUM.intUnitMeasureId = IUOM.intUnitMeasureId 
JOIN tblSTRegister R ON R.intStoreId = ST.intStoreId
JOIN tblICItemPricing Prc ON Prc.intItemLocationId = IL.intItemLocationId
JOIN tblICItemSpecialPricing SplPrc ON SplPrc.intItemId = I.intItemId
JOIN 
(
	 SELECT intItemId, dtmDateModified, dtmDateCreated FROM tblICItem
	 WHERE dtmDateModified IS NOT NULL OR dtmDateCreated IS NOT NULL
	 UNION
	 SELECT intItemId, dtmDateModified, dtmDateCreated FROM tblICItemLocation
	 WHERE dtmDateModified IS NOT NULL OR dtmDateCreated IS NOT NULL
	 UNION
	 SELECT intItemId, dtmDateModified, dtmDateCreated FROM tblICItemPricing
	 WHERE dtmDateModified IS NOT NULL OR dtmDateCreated IS NOT NULL
	 UNION
	 SELECT intItemId, dtmDateModified, dtmDateCreated FROM tblICItemSpecialPricing
	 WHERE dtmDateModified IS NOT NULL OR dtmDateCreated IS NOT NULL
	 UNION
	 SELECT intItemId, dtmDateModified, dtmDateCreated FROM tblICItemAccount
	 WHERE dtmDateModified IS NOT NULL OR dtmDateCreated IS NOT NULL
) AS x ON x.intItemId = I.intItemId 
JOIN dbo.tblSMUserSecurity AS SMUS ON SMUS.intCompanyLocationId = IL.intLocationId 
JOIN dbo.tblEMEntity AS EM ON EM.intEntityId = SMUS.intEntityId 
LEFT OUTER JOIN dbo.tblSTUpdateRegisterNotification AS URN ON URN.intEntityId = EM.intEntityId
WHERE (I.ysnFuelItem = 0)
--AND 
--(
--	x.dtmDateModified BETWEEN ISNULL
--	(
--		(
--			SELECT TOP (1) dtmEndingChangeDate
--			FROM dbo.tblSTUpdateRegisterHistory     
--			WHERE intStoreId = ST.intStoreId
--			ORDER BY intUpdateRegisterHistoryId DESC
--		),
--		(
--			SELECT TOP (1) dtmDate
--			FROM dbo.tblSMAuditLog
--			WHERE strTransactionType = 'Inventory.view.Item'
--			OR strTransactionType = 'Inventory.view.ItemLocation'
--			ORDER BY dtmDate ASC
--		)
--	)
--	-- Between current date
--	AND GETUTCDATE()
--)
--OR 
--(
--	x.dtmDateCreated BETWEEN ISNULL
--	(
--		(
--			SELECT TOP (1) dtmEndingChangeDate
--			FROM dbo.tblSTUpdateRegisterHistory     
--			WHERE intStoreId = ST.intStoreId
--			ORDER BY intUpdateRegisterHistoryId DESC
--		),
--		(
--			SELECT TOP (1) dtmDate
--			FROM dbo.tblSMAuditLog
--			WHERE strTransactionType = 'Inventory.view.Item'
--			OR strTransactionType = 'Inventory.view.ItemLocation'
--			ORDER BY dtmDate ASC
--		)
--	)
--	-- Between current date
--	AND GETUTCDATE()
--)