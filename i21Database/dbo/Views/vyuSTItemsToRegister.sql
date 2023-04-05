﻿CREATE VIEW  [dbo].[vyuSTItemsToRegister]
AS

-- Item Should have
-- 1. UOM
-- 2. Item Location (Location same as Store Location) 
-- 3. Item Location (Product Code of Store) 
-- 3. Store (based on Location)
-- 4. Register (based on Store)
-- 5. Pricing
-- 6. Special Pricing
-- 7. Product Code - As required in C-Store defined in ST-1737

SELECT DISTINCT 
    x.dtmDateModified
	, x.dtmDateCreated
	, I.intItemId
	, EM.intEntityId
	, URN.ysnClick
	, rolePerm.intCompanyLocationId
	, ST.intStoreId
FROM tblICItem AS I
JOIN tblICCategory Cat 
	ON Cat.intCategoryId = I.intCategoryId
JOIN tblICCategoryLocation CatLoc 
	ON CatLoc.intCategoryId = Cat.intCategoryId
JOIN tblICItemLocation IL 
	ON IL.intItemId = I.intItemId
JOIN tblSTSubcategoryRegProd sr
	ON --IL.intProductCodeId = sr.intRegProdId
	(CASE
	WHEN IL.intProductCodeId IS NOT NULL THEN IL.intProductCodeId
	ELSE CatLoc.intProductCodeId
	END) = sr.intRegProdId
LEFT JOIN tblSTSubcategoryRegProd SubCat 
	ON --SubCat.intRegProdId = IL.intProductCodeId
	(CASE
	WHEN IL.intProductCodeId IS NOT NULL THEN IL.intProductCodeId
	ELSE CatLoc.intProductCodeId
	END) = sr.intRegProdId
JOIN tblSTStore ST 
	--ON ST.intStoreId = SubCat.intStoreId
	ON IL.intLocationId = ST.intCompanyLocationId
JOIN tblSMCompanyLocation L 
	ON L.intCompanyLocationId = IL.intLocationId
JOIN tblICItemUOM IUOM 
	ON IUOM.intItemId = I.intItemId 
JOIN tblICUnitMeasure IUM 
	ON IUM.intUnitMeasureId = IUOM.intUnitMeasureId 
JOIN tblSTRegister R 
	ON R.intStoreId = ST.intStoreId
JOIN tblICItemPricing Prc 
	ON Prc.intItemLocationId = IL.intItemLocationId
LEFT JOIN tblICItemSpecialPricing SplPrc 
	ON SplPrc.intItemId = I.intItemId
JOIN 
(
	 SELECT intItemId, dtmDateModified, dtmDateCreated 
	 FROM tblICItem
	 WHERE dtmDateModified IS NOT NULL 
	 OR dtmDateCreated IS NOT NULL

	 UNION

	 SELECT intItemId, dtmDateModified, dtmDateCreated 
	 FROM tblICItemLocation
	 WHERE dtmDateModified IS NOT NULL 
	 OR dtmDateCreated IS NOT NULL

	 UNION

	 SELECT intItemId, dtmDateModified, dtmDateCreated 
	 FROM tblICItemPricing
	 WHERE dtmDateModified IS NOT NULL 
	 OR dtmDateCreated IS NOT NULL

	 UNION

	 SELECT intItemId, dtmDateModified, dtmDateCreated 
	 FROM tblICItemSpecialPricing
	 WHERE dtmDateModified IS NOT NULL 
	 OR dtmDateCreated IS NOT NULL

	 UNION

	 SELECT intItemId, dtmDateModified, dtmDateCreated 
	 FROM tblICItemAccount
	 WHERE dtmDateModified IS NOT NULL 
	 OR dtmDateCreated IS NOT NULL
	 
	 UNION

	 SELECT intItemId, dtmDateModified, dtmDateCreated 
	 FROM tblICEffectiveItemCost
	 WHERE dtmDateModified IS NOT NULL 
	 OR dtmDateCreated IS NOT NULL
	 
	 UNION

	 SELECT intItemId, dtmDateModified, dtmDateCreated 
	 FROM tblICEffectiveItemPrice
	 WHERE dtmDateModified IS NOT NULL 
	 OR dtmDateCreated IS NOT NULL

	 UNION

	 SELECT intItemId, dtmDateModified, dtmDateCreated 
	 FROM tblICItemUOM
	 WHERE dtmDateModified IS NOT NULL 
	 OR dtmDateCreated IS NOT NULL
) AS x 
	ON x.intItemId = I.intItemId 
INNER JOIN dbo.tblSMUserSecurityCompanyLocationRolePermission AS rolePerm 
	ON rolePerm.intCompanyLocationId = IL.intLocationId 
INNER JOIN dbo.tblEMEntity AS EM 
	ON EM.intEntityId = rolePerm.intEntityId 
LEFT OUTER JOIN dbo.tblSTUpdateRegisterNotification AS URN 
	ON URN.intEntityId = EM.intEntityId
WHERE (ISNULL(I.ysnFuelItem,0) = 0)


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
