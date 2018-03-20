CREATE VIEW [dbo].[vyuSTItemsToRegister]
AS
SELECT DISTINCT I.intItemId, EM.intEntityId, URN.ysnClick
FROM tblICItem I
JOIN tblICCategory Cat ON Cat.intCategoryId = I.intCategoryId
JOIN(
	SELECT DISTINCT CAST(strRecordNo AS INT) [intItemId] 
	FROM dbo.tblSMAuditLog 
	WHERE strTransactionType = 'Inventory.view.Item'
		AND ( CHARINDEX('strItemNo', strJsonData) > 0  OR CHARINDEX('strUnitMeasure', strJsonData) > 0  
		OR CHARINDEX('strStatus', strJsonData) > 0 OR CHARINDEX('dblSalePrice', strJsonData) > 0   
		OR CHARINDEX('strCategoryCode', strJsonData) > 0 OR CHARINDEX('dtmBeginDate', strJsonData) > 0
		OR CHARINDEX('dtmEndDate', strJsonData) > 0 OR CHARINDEX('strDescription', strJsonData) > 0   
		OR CHARINDEX('intItemTypeCode', strJsonData) > 0 OR CHARINDEX('intItemTypeSubCode', strJsonData) > 0 		 
		OR CHARINDEX('strRegProdCode', strJsonData) > 0 OR CHARINDEX('ysnCarWash', strJsonData) > 0   
		OR CHARINDEX('ysnFoodStampable', strJsonData) > 0 OR CHARINDEX('ysnIdRequiredLiquor', strJsonData) > 0   
		OR CHARINDEX('ysnIdRequiredCigarette', strJsonData) > 0 OR CHARINDEX('ysnOpenPricePLU', strJsonData) > 0   
		OR CHARINDEX('dblUnitQty', strJsonData) > 0 OR CHARINDEX('strUpcCode', strJsonData) > 0 		
		OR CHARINDEX('ysnTaxFlag1', strJsonData) > 0 OR CHARINDEX('ysnTaxFlag2', strJsonData) > 0   
		OR CHARINDEX('ysnTaxFlag3', strJsonData) > 0 OR CHARINDEX('ysnTaxFlag4', strJsonData) > 0   
		OR CHARINDEX('ysnApplyBlueLaw1', strJsonData) > 0 OR CHARINDEX('ysnApplyBlueLaw2', strJsonData) > 0   
		OR CHARINDEX('ysnPromotionalItem', strJsonData) > 0 OR CHARINDEX('ysnQuantityRequired', strJsonData) > 0 
		OR CHARINDEX('strLongUPCCode', strJsonData) > 0 OR CHARINDEX('ysnSaleable', strJsonData) > 0   
		OR CHARINDEX('ysnReturnable', strJsonData) > 0 OR CHARINDEX('intDepositPLUId', strJsonData) > 0  
		
		OR CHARINDEX('dblStandardCost',strJsonData) > 0
		OR CHARINDEX('intCategoryId',strJsonData) > 0 )

	    AND dtmDate BETWEEN 
				ISNULL(
						(DATEADD(HOUR,-8,(SELECT TOP 1 dtmEndingChangeDate FROM tblSTUpdateRegisterHistory ORDER BY intUpdateRegisterHistoryId DESC)))
						, (
							SELECT TOP 1 dtmDate
							FROM tblSMAuditLog
							WHERE strTransactionType = 'Inventory.view.Item'
							ORDER BY dtmDate ASC
						)) 
				AND GETUTCDATE()

) AS x ON x.intItemId = I.intItemId 
JOIN tblICItemLocation IL ON IL.intItemId = I.intItemId
LEFT JOIN tblSTSubcategoryRegProd SubCat ON SubCat.intRegProdId = IL.intProductCodeId
JOIN tblSTStore ST ON ST.intStoreId = SubCat.intStoreId
JOIN tblSMCompanyLocation L ON L.intCompanyLocationId = IL.intLocationId
JOIN tblICItemUOM IUOM ON IUOM.intItemId = I.intItemId 
JOIN tblICUnitMeasure IUM ON IUM.intUnitMeasureId = IUOM.intUnitMeasureId 
JOIN tblSTRegister R ON R.intStoreId = ST.intStoreId
JOIN tblICItemPricing Prc ON Prc.intItemLocationId = IL.intItemLocationId
JOIN tblICItemSpecialPricing SplPrc ON SplPrc.intItemId = I.intItemId
JOIN tblSMUserSecurity SMUS ON SMUS.intCompanyLocationId = IL.intLocationId
JOIN tblEMEntity EM ON EM.intEntityId = SMUS.intEntityId
JOIN tblSTUpdateRegisterNotification URN ON URN.intEntityId = EM.intEntityId
WHERE I.ysnFuelItem = 0

