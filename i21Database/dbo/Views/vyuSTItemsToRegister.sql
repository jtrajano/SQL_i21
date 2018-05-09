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
FROM dbo.tblICItem AS I 
INNER JOIN dbo.tblICCategory AS Cat ON Cat.intCategoryId = I.intCategoryId 
INNER JOIN 
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
INNER JOIN dbo.tblICItemLocation AS IL ON IL.intItemId = I.intItemId 
LEFT OUTER JOIN dbo.tblSTSubcategoryRegProd AS SubCat ON SubCat.intRegProdId = IL.intProductCodeId 
INNER JOIN dbo.tblSTStore AS ST ON ST.intCompanyLocationId = IL.intLocationId --ST.intStoreId = SubCat.intStoreId 
INNER JOIN dbo.tblSMCompanyLocation AS L ON L.intCompanyLocationId = IL.intLocationId 
INNER JOIN dbo.tblICItemUOM AS IUOM ON IUOM.intItemId = I.intItemId 
INNER JOIN dbo.tblICUnitMeasure AS IUM ON IUM.intUnitMeasureId = IUOM.intUnitMeasureId 
INNER JOIN dbo.tblSTRegister AS R ON R.intStoreId = ST.intStoreId 
INNER JOIN dbo.tblICItemPricing AS Prc ON Prc.intItemLocationId = IL.intItemLocationId 
INNER JOIN dbo.tblICItemSpecialPricing AS SplPrc ON SplPrc.intItemId = I.intItemId 
INNER JOIN dbo.tblSMUserSecurity AS SMUS ON SMUS.intCompanyLocationId = IL.intLocationId 
INNER JOIN dbo.tblEMEntity AS EM ON EM.intEntityId = SMUS.intEntityId 
LEFT OUTER JOIN dbo.tblSTUpdateRegisterNotification AS URN ON URN.intEntityId = EM.intEntityId
WHERE (I.ysnFuelItem = 0) 
AND 
(
	x.dtmDateModified BETWEEN ISNULL
	(
		(
			SELECT TOP (1) dtmEndingChangeDate
			FROM dbo.tblSTUpdateRegisterHistory     
			WHERE intStoreId = ST.intStoreId
			ORDER BY intUpdateRegisterHistoryId DESC
		),
		(
			SELECT TOP (1) dtmDate
			FROM dbo.tblSMAuditLog
			WHERE strTransactionType = 'Inventory.view.Item'
			OR strTransactionType = 'Inventory.view.ItemLocation'
			ORDER BY dtmDate ASC
		)
	)
	-- Between current date
	AND GETUTCDATE()
)
OR 
(
	x.dtmDateCreated BETWEEN ISNULL
	(
		(
			SELECT TOP (1) dtmEndingChangeDate
			FROM dbo.tblSTUpdateRegisterHistory     
			WHERE intStoreId = ST.intStoreId
			ORDER BY intUpdateRegisterHistoryId DESC
		),
		(
			SELECT TOP (1) dtmDate
			FROM dbo.tblSMAuditLog
			WHERE strTransactionType = 'Inventory.view.Item'
			OR strTransactionType = 'Inventory.view.ItemLocation'
			ORDER BY dtmDate ASC
		)
	)
	-- Between current date
	AND GETUTCDATE()
)