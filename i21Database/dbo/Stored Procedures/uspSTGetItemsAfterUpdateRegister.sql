CREATE PROCEDURE [dbo].[uspSTGetItemsAfterUpdateRegister]
	@intStoreId INT
	, @intRegisterId INT
	, @ysnPricebookFile BIT
	, @ysnPromotionItemList BIT
	, @ysnPromotionSalesList BIT
	, @dtmBeginningChangeDate DATETIME
	, @dtmEndingChangeDate DATETIME
	, @strCategoryCode NVARCHAR(MAX)
	, @ysnExportEntirePricebookFile BIT
	, @intBeginningPromoItemListId INT
	, @intEndingPromoItemListId INT
	, @strPromoCode NVARCHAR(25)
	, @intBeginningPromoSalesId INT
	, @intEndingPromoSalesId INT
	, @dtmBuildFileThruEndingDate DATETIME
	, @intCurrentUserId INT
AS

BEGIN TRY

	DECLARE @ErrMsg NVARCHAR(MAX);

	-- =============================================================================================
	-- CONVERT DATE's to UTC
	-- =============================================================================================
	DECLARE @dtmBeginningChangeDateUTC AS DATETIME = dbo.fnSTConvertDateToUTC(@dtmBeginningChangeDate)
	DECLARE @dtmEndingChangeDateUTC AS DATETIME = dbo.fnSTConvertDateToUTC(@dtmEndingChangeDate)
	DECLARE @dtmBuildFileThruEndingDateUTC AS DATETIME = dbo.fnSTConvertDateToUTC(@dtmBuildFileThruEndingDate)
	-- =============================================================================================
	-- END CONVERT DATE's to UTC
	-- =============================================================================================



	DECLARE @tableGetItems TABLE(
									strActionType NVARCHAR(3)
									, strUpcCode NVARCHAR(20)
									, strDescription NVARCHAR(150)
									, dblSalePrice DECIMAL(18, 6)
									, ysnSalesTaxed BIT
									, ysnIdRequiredLiquor BIT
									, ysnIdRequiredCigarette BIT
									, strRegProdCode NVARCHAR(200)
									, intItemId INT
								)
	
	DECLARE @tablePricebookFileOne TABLE(intItemId int, strActionType nvarchar(20), dtmDate DATETIME)
	--DECLARE @tablePricebookFileTwo TABLE(intItemId int, strActionType nvarchar(20), dtmDate DATETIME)

	--Insert to table1
	INSERT INTO @tablePricebookFileOne
	SELECT DISTINCT intItemId
					, CASE
							WHEN dtmDateCreated BETWEEN @dtmBeginningChangeDateUTC AND @dtmEndingChangeDateUTC THEN 'Created' ELSE 'Updated'
					  END AS strActionType
					, CASE
							WHEN dtmDateCreated BETWEEN @dtmBeginningChangeDateUTC AND @dtmEndingChangeDateUTC THEN dtmDateCreated ELSE dtmDateModified
					  END AS dtmDate
	FROM vyuSTItemsToRegister
	WHERE 
	(
		dtmDateModified BETWEEN @dtmBeginningChangeDateUTC AND @dtmEndingChangeDateUTC
		OR 
		dtmDateCreated BETWEEN @dtmBeginningChangeDateUTC AND @dtmEndingChangeDateUTC
	)
	AND intCompanyLocationId = 
	(
		SELECT TOP (1) intCompanyLocationId 
		FROM tblSTStore
		WHERE intStoreId = @intStoreId
	)




	--SELECT
	--	DISTINCT CAST(strRecordNo as int) [intItemId]
	--	, strActionType
	--	, dtmDate
	--FROM dbo.tblSMAuditLog
	--WHERE strTransactionType = 'Inventory.view.Item'
	--AND ( CHARINDEX('strItemNo', strJsonData) > 0  OR CHARINDEX('strUnitMeasure', strJsonData) > 0 
	--			  OR CHARINDEX('strStatus', strJsonData) > 0 OR CHARINDEX('dblSalePrice', strJsonData) > 0  
	--			  OR CHARINDEX('strCategoryCode', strJsonData) > 0 OR CHARINDEX('dtmBeginDate', strJsonData) > 0  
	--			  OR CHARINDEX('dtmEndDate', strJsonData) > 0 OR CHARINDEX('strDescription', strJsonData) > 0  
	--			  OR CHARINDEX('intItemTypeCode', strJsonData) > 0 OR CHARINDEX('intItemTypeSubCode', strJsonData) > 0              
	--			  OR CHARINDEX('strRegProdCode', strJsonData) > 0 OR CHARINDEX('ysnCarWash', strJsonData) > 0  
	--			  OR CHARINDEX('ysnFoodStampable', strJsonData) > 0 OR CHARINDEX('ysnIdRequiredLiquor', strJsonData) > 0  
	--			  OR CHARINDEX('ysnIdRequiredCigarette', strJsonData) > 0 OR CHARINDEX('ysnOpenPricePLU', strJsonData) > 0  
	--			  OR CHARINDEX('dblUnitQty', strJsonData) > 0 OR CHARINDEX('strUpcCode', strJsonData) > 0               
	--			  OR CHARINDEX('ysnTaxFlag1', strJsonData) > 0 OR CHARINDEX('ysnTaxFlag2', strJsonData) > 0  
	--			  OR CHARINDEX('ysnTaxFlag3', strJsonData) > 0 OR CHARINDEX('ysnTaxFlag4', strJsonData) > 0  
	--			  OR CHARINDEX('ysnApplyBlueLaw1', strJsonData) > 0 OR CHARINDEX('ysnApplyBlueLaw2', strJsonData) > 0  
	--			  OR CHARINDEX('ysnPromotionalItem', strJsonData) > 0 OR CHARINDEX('ysnQuantityRequired', strJsonData) > 0
	--			  OR CHARINDEX('strLongUPCCode', strJsonData) > 0 OR CHARINDEX('ysnSaleable', strJsonData) > 0  
	--			  OR CHARINDEX('ysnReturnable', strJsonData) > 0 OR CHARINDEX('intDepositPLUId', strJsonData) > 0 
	--			  OR CHARINDEX('Created', strJsonData) > 0

	--			  OR CHARINDEX('dblStandardCost',strJsonData) > 0
	--			  OR CHARINDEX('intCategoryId',strJsonData) > 0 )
	
	--AND dtmDate BETWEEN DATEADD(HOUR,-8,(@dtmBeginningChangeDate)) AND DATEADD(HOUR,-8,(@dtmEndingChangeDate))




	----Insert to table2
	--INSERT INTO @tablePricebookFileTwo
	--SELECT t1.intItemId, t1.strActionType, t1.dtmDate
	--	FROM(
	--		SELECT *,
	--			rn = ROW_NUMBER() OVER(PARTITION BY t.intItemId ORDER BY (SELECT NULL))
	--		FROM @tablePricebookFileOne as t
	--)t1
	--WHERE rn = 1


	--PricebookFile @StoreId @Register, @Category, @BeginingChangeDate, @EndingChangeDate, @ExportEntirePricebookFile
	IF(@ysnExportEntirePricebookFile = 1)
		BEGIN
			INSERT INTO @tableGetItems
			SELECT strActionType
					, strUpcCode
					, strDescription
					, dblSalePrice
					, ysnSalesTaxed
					, ysnIdRequiredLiquor
					, ysnIdRequiredCigarette
					, strRegProdCode 
					, intItemId 
			FROM  
			(
			SELECT *,
					rn = ROW_NUMBER() OVER(PARTITION BY t.intItemId ORDER BY (SELECT NULL))
				FROM 
					(
						SELECT 
						CASE WHEN tmpItem.strActionType = 'Created' THEN 'ADD' ELSE 'CHG' END AS strActionType
						--, IUOM.strUpcCode AS strUpcCode
						, IUOM.strLongUPCCode AS strUpcCode
						, I.strDescription AS strDescription
						, Prc.dblSalePrice AS dblSalePrice
						, IL.ysnTaxFlag1 AS ysnSalesTaxed
						, IL.ysnIdRequiredLiquor AS ysnIdRequiredLiquor
						, IL.ysnIdRequiredCigarette AS ysnIdRequiredCigarette
						, SubCat.strRegProdCode AS strRegProdCode
						, I.intItemId AS intItemId
							   FROM tblICItem I
							   JOIN tblICCategory Cat ON Cat.intCategoryId = I.intCategoryId
							   JOIN @tablePricebookFileOne tmpItem ON tmpItem.intItemId = I.intItemId
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
						WHERE I.ysnFuelItem = 0 AND R.intRegisterId = @intRegisterId AND ST.intStoreId = @intStoreId
						AND I.intItemId NOT IN (SELECT intItemId FROM @tableGetItems) 
					) as t
			) t1
			WHERE rn = 1
		END
	ELSE IF(@ysnPricebookFile = 1)
		BEGIN
			INSERT INTO @tableGetItems
			SELECT strActionType
					, strUpcCode
					, strDescription
					, dblSalePrice
					, ysnSalesTaxed
					, ysnIdRequiredLiquor
					, ysnIdRequiredCigarette
					, strRegProdCode 
					, intItemId 
			FROM  
			(
			SELECT *,
					rn = ROW_NUMBER() OVER(PARTITION BY t.intItemId ORDER BY (SELECT NULL))
				FROM 
					(
						SELECT 
						CASE WHEN tmpItem.strActionType = 'Created' THEN 'ADD' ELSE 'CHG' END AS strActionType
						--, IUOM.strUpcCode AS strUpcCode
						, IUOM.strLongUPCCode AS strUpcCode
						, I.strDescription AS strDescription
						, Prc.dblSalePrice AS dblSalePrice
						, IL.ysnTaxFlag1 AS ysnSalesTaxed
						, IL.ysnIdRequiredLiquor AS ysnIdRequiredLiquor
						, IL.ysnIdRequiredCigarette AS ysnIdRequiredCigarette
						, SubCat.strRegProdCode AS strRegProdCode
						, I.intItemId AS intItemId
							   FROM tblICItem I
							   JOIN tblICCategory Cat ON Cat.intCategoryId = I.intCategoryId
							   JOIN @tablePricebookFileOne tmpItem ON tmpItem.intItemId = I.intItemId
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

							   --LEFT JOIN tblSTPromotionItemList PIL ON PIL.intStoreId = ST.intStoreId -- Promo Item

							   --LEFT JOIN tblSTPromotionSalesList PSL ON PSL.intStoreId = ST.intStoreId -- Promo Sales

						WHERE I.ysnFuelItem = 0 AND R.intRegisterId = @intRegisterId AND ST.intStoreId = @intStoreId
						AND ((@strCategoryCode <>'whitespaces' AND Cat.intCategoryId IN(select * from dbo.fnSplitString(@strCategoryCode,',')))
						OR (@strCategoryCode ='whitespaces'  AND Cat.intCategoryId = Cat.intCategoryId))
						AND I.intItemId NOT IN (SELECT intItemId FROM @tableGetItems)

						--OR (PIL.intPromoItemListId 
						--BETWEEN @intBeginningPromoItemListId 
						--AND @intEndingPromoItemListId) -- Promo Item

						--OR (PSL.strPromoType = 'C' 
						--AND PSL.intPromoSalesId 
						--BETWEEN @intBeginningPromoSalesId 
						--AND @intEndingPromoSalesId)) -- Promo Sales 
					) as t
			) t1
			WHERE rn = 1
		END



	--PromotionItemListFile @StoreId , @Register, @BeginningItemListId, @EndingItemListId
	IF(@ysnPromotionItemList = 1)
		BEGIN
			INSERT INTO @tableGetItems
			SELECT strActionType
					, strUpcCode
					, strDescription
					, dblSalePrice
					, ysnSalesTaxed
					, ysnIdRequiredLiquor
					, ysnIdRequiredCigarette
					, strRegProdCode 
					, intItemId 
			FROM  
			(
			SELECT *,
					rn = ROW_NUMBER() OVER(PARTITION BY t.intItemId ORDER BY (SELECT NULL))
				FROM 
					(
						SELECT
						CASE WHEN tmpItem.strActionType = 'Created' THEN 'ADD' ELSE 'CHG' END AS strActionType
							--PIL.strPromoItemListDescription
							--, IUOM.strUpcCode AS strUpcCode
							, IUOM.strLongUPCCode AS strUpcCode
							, I.strDescription AS strDescription
							, Prc.dblSalePrice AS dblSalePrice
							, IL.ysnTaxFlag1 AS ysnSalesTaxed
							, IL.ysnIdRequiredLiquor AS ysnIdRequiredLiquor
							, IL.ysnIdRequiredCigarette AS ysnIdRequiredCigarette
							, SubCat.strRegProdCode AS strRegProdCode
							, I.intItemId AS intItemId
						FROM tblSTPromotionItemListDetail PILD
						JOIN tblSTPromotionItemList PIL ON PIL.intPromoItemListId = PILD.intPromoItemListId
						JOIN tblICItemUOM IUOM ON IUOM.intItemUOMId = PILD.intItemUOMId
						JOIN tblICItem I ON I.intItemId = IUOM.intItemId 
						JOIN @tablePricebookFileOne tmpItem ON tmpItem.intItemId = I.intItemId
						JOIN tblSTStore ST ON ST.intStoreId = PIL.intStoreId
						JOIN tblICItemLocation IL ON IL.intLocationId = ST.intCompanyLocationId AND IL.intItemId = I.intItemId
						JOIN tblICItemPricing Prc ON Prc.intItemLocationId = IL.intItemLocationId
						JOIN tblSTSubcategoryRegProd SubCat ON SubCat.intStoreId = ST.intStoreId
						JOIN tblSTRegister R ON R.intStoreId = ST.intStoreId

						WHERE I.ysnFuelItem = 0 AND R.intRegisterId = @intRegisterId AND ST.intStoreId = @intStoreId
						AND PIL.intPromoItemListId BETWEEN @intBeginningPromoItemListId AND @intEndingPromoItemListId

						AND I.intItemId NOT IN (SELECT intItemId FROM @tableGetItems)
				) as t
			) t1
			WHERE rn = 1
		END


	----PromotionSalesList
	IF(@ysnPromotionSalesList = 1)
		BEGIN
			IF(@strPromoCode = 'Combo')
				BEGIN
					--Print('@StoreId , @Register, @BeginningComboId, @EndingComboId')
					INSERT INTO @tableGetItems
					SELECT strActionType
							, strUpcCode
							, strDescription
							, dblSalePrice
							, ysnSalesTaxed
							, ysnIdRequiredLiquor
							, ysnIdRequiredCigarette
							, strRegProdCode 
							, intItemId 
					FROM  
					(
					SELECT *,
							rn = ROW_NUMBER() OVER(PARTITION BY t.intItemId ORDER BY (SELECT NULL))
						FROM 
							(
								SELECT 
									CASE WHEN tmpItem.strActionType = 'Created' THEN 'ADD' ELSE 'CHG' END AS strActionType
									-- , IUOM.strUpcCode AS strUpcCode
									, IUOM.strLongUPCCode AS strUpcCode
									, I.strDescription AS strDescription
									, Prc.dblSalePrice AS dblSalePrice
									, IL.ysnTaxFlag1 AS ysnSalesTaxed
									, IL.ysnIdRequiredLiquor AS ysnIdRequiredLiquor
									, IL.ysnIdRequiredCigarette AS ysnIdRequiredCigarette
									, SubCat.strRegProdCode AS strRegProdCode
									, I.intItemId AS intItemId
								FROM tblICItem I
								JOIN @tablePricebookFileOne tmpItem ON tmpItem.intItemId = I.intItemId
								JOIN tblICItemLocation IL ON IL.intItemId = I.intItemId
								JOIN tblICItemPricing Prc ON Prc.intItemLocationId = IL.intItemLocationId
								JOIN tblSMCompanyLocation L ON L.intCompanyLocationId = IL.intLocationId 
								JOIN tblSTStore ST ON ST.intCompanyLocationId = L.intCompanyLocationId 
								JOIN tblSTRegister R ON R.intStoreId = ST.intStoreId
								JOIN tblSTPromotionSalesList PSL ON PSL.intStoreId = ST.intStoreId --AND Cat.intCategoryId = PSL.intCategoryId
								JOIN tblSTPromotionSalesListDetail PSLD ON PSLD.intPromoSalesListId = PSL.intPromoSalesListId
								JOIN tblSTPromotionItemList PIL ON PIL.intPromoItemListId = PSLD.intPromoItemListId
								JOIN tblSTPromotionItemListDetail PILD ON PILD.intPromoItemListId = PIL.intPromoItemListId
								JOIN tblICItemUOM IUOM ON IUOM.intItemUOMId = PILD.intItemUOMId 
								JOIN tblICUnitMeasure IUM ON IUM.intUnitMeasureId = IUOM.intUnitMeasureId
								JOIN tblSTSubcategoryRegProd SubCat ON SubCat.intStoreId = ST.intStoreId

								WHERE R.intRegisterId = @intRegisterId  AND ST.intStoreId = @intStoreId AND PSL.strPromoType = 'C'
								AND PSL.intPromoSalesId BETWEEN @intBeginningPromoSalesId AND @intEndingPromoSalesId

								AND I.intItemId NOT IN (SELECT intItemId FROM @tableGetItems)

							) as t
					) t1
					WHERE rn = 1
				END
			ELSE
				BEGIN
					--Print('@StoreId , @Register, @BeginningMixMatchId, @EndingMixMatchId, @BuildFileThruEndingDate, @ExportEntirePricebookFile')
					INSERT INTO @tableGetItems
					SELECT strActionType
							, strUpcCode
							, strDescription
							, dblSalePrice
							, ysnSalesTaxed
							, ysnIdRequiredLiquor
							, ysnIdRequiredCigarette
							, strRegProdCode 
							, intItemId 
					FROM  
					(
					SELECT *,
							rn = ROW_NUMBER() OVER(PARTITION BY t.intItemId ORDER BY (SELECT NULL))
						FROM 
							(
								SELECT 
								CASE WHEN tmpItem.strActionType = 'Created' THEN 'ADD' ELSE 'CHG' END AS strActionType
								--, IUOM.strUpcCode AS strUpcCode
								, IUOM.strLongUPCCode AS strUpcCode
								, I.strDescription AS strDescription
								, Prc.dblSalePrice AS dblSalePrice
								, IL.ysnTaxFlag1 AS ysnSalesTaxed
								, IL.ysnIdRequiredLiquor AS ysnIdRequiredLiquor
								, IL.ysnIdRequiredCigarette AS ysnIdRequiredCigarette
								, SubCat.strRegProdCode AS strRegProdCode
								, I.intItemId AS intItemId
									   FROM tblICItem I
									   JOIN tblICCategory Cat ON Cat.intCategoryId = I.intCategoryId
									   JOIN @tablePricebookFileOne tmpItem ON tmpItem.intItemId = I.intItemId
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
								WHERE I.ysnFuelItem = 0 AND R.intRegisterId = @intRegisterId AND ST.intStoreId = @intStoreId
								AND ((@strCategoryCode <>'whitespaces' AND Cat.intCategoryId IN(select * from dbo.fnSplitString(@strCategoryCode,',')))
								OR (@strCategoryCode ='whitespaces'  AND Cat.intCategoryId = Cat.intCategoryId))

								AND I.intItemId NOT IN (SELECT intItemId FROM @tableGetItems)
							) as t
					) t1
					WHERE rn = 1
				END
		END


	-- =============================================================================================
	-- Update tblSTUpdateRegisterNotification
	-- After Update Register remove notification from all users
	-- Should only update based on location

	UPDATE URN
	SET URN.ysnClick = 1
	FROM dbo.tblSTUpdateRegisterNotification AS URN
	JOIN tblSMUserSecurity SMUS ON SMUS.intEntityId = URN.intEntityId
	WHERE SMUS.intCompanyLocationId = (SELECT intCompanyLocationId FROM tblSTStore WHERE intStoreId = @intStoreId)
	AND URN.ysnClick = 0

	--UPDATE tblSTUpdateRegisterNotification
	--SET ysnClick = 1
	--WHERE ysnClick = 0
	-- =============================================================================================


	-- Insert to tblSTUpdateRegisterHistory
	INSERT INTO tblSTUpdateRegisterHistory (intStoreId, intRegisterId, ysnPricebookFile, ysnPromotionItemList, ysnPromotionSalesList, dtmBeginningChangeDate, dtmEndingChangeDate, strCategoryCode, ysnExportEntirePricebookFile, intBeginningPromoItemListId, intEndingPromoItemListId, strPromoCode, intBeginningPromoSalesId, intEndingPromoSalesId, dtmBuildFileThruEndingDate, intUpdatedByUserId)
    VALUES (@intStoreId, @intRegisterId, @ysnPricebookFile, @ysnPromotionItemList, @ysnPromotionSalesList, @dtmBeginningChangeDateUTC, @dtmEndingChangeDateUTC, @strCategoryCode, @ysnExportEntirePricebookFile, @intBeginningPromoItemListId, @intEndingPromoItemListId, @strPromoCode, @intBeginningPromoSalesId, @intEndingPromoSalesId, @dtmBuildFileThruEndingDateUTC, @intCurrentUserId)


	-- Send query to server side 
	SELECT DISTINCT strActionType
		, strUpcCode
		, strDescription
		, dblSalePrice
		, ysnSalesTaxed
		, ysnIdRequiredLiquor
		, ysnIdRequiredCigarette
		, strRegProdCode 
	FROM @tableGetItems
	--ORDER BY intItemId ASC

END TRY

BEGIN CATCH       
	SET @ErrMsg = ERROR_MESSAGE()      
	RAISERROR(@ErrMsg, 16, 1, 'WITH NOWAIT')      
END CATCH 