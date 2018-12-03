﻿CREATE PROCEDURE [dbo].[uspSTUpdateRegisterItemPreview]
	@intStoreId INT
	, @intRegisterId INT
	, @dtmBeginningChangeDate DATETIME
	, @dtmEndingChangeDate DATETIME
	, @ysnExportEntirePricebookFile BIT
	, @ysnPricebookFile BIT
	, @ysnPromotionItemList BIT
	, @ysnPromotionSalesList BIT
	, @strCategoryCode VARCHAR(MAX)
	, @intCountRows INT OUT
	, @strStatusMsg AS VARCHAR(1000) OUTPUT
AS
BEGIN
	BEGIN TRY
		
		-- =============================================================================================
		-- CONVERT DATE's to UTC
		-- =============================================================================================
		DECLARE @dtmBeginningChangeDateUTC AS DATETIME = dbo.fnSTConvertDateToUTC(@dtmBeginningChangeDate)
		DECLARE @dtmEndingChangeDateUTC AS DATETIME = dbo.fnSTConvertDateToUTC(@dtmEndingChangeDate)
		-- =============================================================================================
		-- END CONVERT DATE's to UTC
		-- =============================================================================================

		--DECLARE @tableGetItems TABLE(
		--			strActionType NVARCHAR(3)
		--			, strUpcCode NVARCHAR(20)
		--			, strDescription NVARCHAR(150)
		--			, dblSalePrice DECIMAL(18, 6)
		--			, ysnSalesTaxed BIT
		--			, ysnIdRequiredLiquor BIT
		--			, ysnIdRequiredCigarette BIT
		--			, strRegProdCode NVARCHAR(200)
		--			, intItemId INT
		--)


		--DECLARE @tablePricebookFileOne TABLE(intItemId int, strActionType nvarchar(20), dtmDate DATETIME)

		----Insert to table1
		--INSERT INTO @tablePricebookFileOne
		--SELECT DISTINCT intItemId
		--			, CASE
		--					WHEN dtmDateCreated BETWEEN @dtmBeginningChangeDateUTC AND @dtmEndingChangeDateUTC 
		--						THEN 'Created' 
		--					ELSE 'Updated'
		--			  END AS strActionType
		--			, CASE
		--					WHEN dtmDateCreated BETWEEN @dtmBeginningChangeDateUTC AND @dtmEndingChangeDateUTC 
		--						THEN dtmDateCreated 
		--					ELSE dtmDateModified
		--			  END AS dtmDate
		--FROM vyuSTItemsToRegister
		--WHERE 
		--(
		--	dtmDateModified BETWEEN @dtmBeginningChangeDateUTC AND @dtmEndingChangeDateUTC
		--	OR 
		--	dtmDateCreated BETWEEN @dtmBeginningChangeDateUTC AND @dtmEndingChangeDateUTC
		--)
		--AND intCompanyLocationId = 
		--(
		--	SELECT TOP (1) intCompanyLocationId 
		--	FROM tblSTStore
		--	WHERE intStoreId = @intStoreId
		--)




		--INSERT INTO @tableGetItems
		--SELECT strActionType
		--			, strUpcCode
		--			, strDescription
		--			, dblSalePrice
		--			, ysnSalesTaxed
		--			, ysnIdRequiredLiquor
		--			, ysnIdRequiredCigarette
		--			, strRegProdCode 
		--			, intItemId 
		--FROM  
		--(
		--	SELECT *,
		--			rn = ROW_NUMBER() OVER(PARTITION BY t.intItemId ORDER BY (SELECT NULL))
		--		FROM 
		--			(
		--				SELECT 
		--					CASE WHEN tmpItem.strActionType = 'Created' THEN 'ADD' ELSE 'CHG' END AS strActionType
		--					--, IUOM.strUpcCode AS strUpcCode
		--					, IUOM.strLongUPCCode AS strUpcCode
		--					, I.strDescription AS strDescription
		--					, Prc.dblSalePrice AS dblSalePrice
		--					, IL.ysnTaxFlag1 AS ysnSalesTaxed
		--					, IL.ysnIdRequiredLiquor AS ysnIdRequiredLiquor
		--					, IL.ysnIdRequiredCigarette AS ysnIdRequiredCigarette
		--					, SubCat.strRegProdCode AS strRegProdCode
		--					, I.intItemId AS intItemId
		--				FROM tblICItem I
		--				JOIN tblICCategory Cat 
		--					ON Cat.intCategoryId = I.intCategoryId
		--				JOIN @tablePricebookFileOne tmpItem 
		--					ON tmpItem.intItemId = I.intItemId
		--				JOIN tblICItemLocation IL 
		--					ON IL.intItemId = I.intItemId
		--				LEFT JOIN tblSTSubcategoryRegProd SubCat 
		--					ON SubCat.intRegProdId = IL.intProductCodeId
		--				JOIN tblSTStore ST 
		--					ON ST.intStoreId = SubCat.intStoreId
		--					   AND IL.intLocationId = ST.intCompanyLocationId
		--				JOIN tblSMCompanyLocation L 
		--					ON L.intCompanyLocationId = IL.intLocationId
		--				JOIN tblICItemUOM IUOM 
		--					ON IUOM.intItemId = I.intItemId
		--				JOIN tblICUnitMeasure IUM 
		--					ON IUM.intUnitMeasureId = IUOM.intUnitMeasureId
		--				JOIN tblSTRegister R 
		--					ON R.intStoreId = ST.intStoreId
		--				JOIN tblICItemPricing Prc 
		--					ON Prc.intItemLocationId = IL.intItemLocationId
		--				LEFT JOIN tblICItemSpecialPricing SplPrc 
		--					ON SplPrc.intItemId = I.intItemId
		--				WHERE I.ysnFuelItem = CAST(0 AS BIT) 
		--				AND R.intRegisterId = @intRegisterId
		--				AND ST.intStoreId = @intStoreId
		--				AND I.intItemId NOT IN (SELECT intItemId FROM @tableGetItems) 
		--			) as t
		--) t1
		--WHERE rn = 1




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


		--Insert to table1
		INSERT INTO @tablePricebookFileOne
		SELECT DISTINCT intItemId
						, CASE
								WHEN dtmDateCreated BETWEEN @dtmBeginningChangeDateUTC AND @dtmEndingChangeDateUTC 
									THEN 'Created' 
								ELSE 'Updated'
						  END AS strActionType
						, CASE
								WHEN dtmDateCreated BETWEEN @dtmBeginningChangeDateUTC AND @dtmEndingChangeDateUTC 
									THEN dtmDateCreated 
								ELSE dtmDateModified
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
							JOIN tblICCategory Cat 
								ON Cat.intCategoryId = I.intCategoryId
							JOIN @tablePricebookFileOne tmpItem 
								ON tmpItem.intItemId = I.intItemId
							JOIN tblICItemLocation IL 
								ON IL.intItemId = I.intItemId
							LEFT JOIN tblSTSubcategoryRegProd SubCat 
								ON SubCat.intRegProdId = IL.intProductCodeId
							JOIN tblSTStore ST 
								ON ST.intStoreId = SubCat.intStoreId
								   AND IL.intLocationId = ST.intCompanyLocationId
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
							WHERE I.ysnFuelItem = CAST(0 AS BIT) 
							AND R.intRegisterId = @intRegisterId 
							AND ST.intStoreId = @intStoreId
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
							JOIN tblICCategory Cat 
								ON Cat.intCategoryId = I.intCategoryId
							JOIN @tablePricebookFileOne tmpItem 
								ON tmpItem.intItemId = I.intItemId
							JOIN tblICItemLocation IL 
								ON IL.intItemId = I.intItemId
							LEFT JOIN tblSTSubcategoryRegProd SubCat 
								ON SubCat.intRegProdId = IL.intProductCodeId
							JOIN tblSTStore ST 
								ON ST.intStoreId = SubCat.intStoreId
								   AND IL.intLocationId = ST.intCompanyLocationId
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
							WHERE I.ysnFuelItem = CAST(0 AS BIT) 
							AND R.intRegisterId = @intRegisterId 
							AND ST.intStoreId = @intStoreId
							AND ((@strCategoryCode <>'whitespaces' 
							AND Cat.intCategoryId IN(select * from dbo.fnSplitString(@strCategoryCode,',')))
							OR (@strCategoryCode ='whitespaces'  
							AND Cat.intCategoryId = Cat.intCategoryId))
							AND I.intItemId NOT IN (SELECT intItemId FROM @tableGetItems)
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
							JOIN tblSTPromotionItemList PIL 
								ON PIL.intPromoItemListId = PILD.intPromoItemListId
							JOIN tblICItemUOM IUOM 
								ON IUOM.intItemUOMId = PILD.intItemUOMId
							JOIN tblICItem I 
								ON I.intItemId = IUOM.intItemId 
							JOIN @tablePricebookFileOne tmpItem 
								ON tmpItem.intItemId = I.intItemId
							JOIN tblSTStore ST 
								ON ST.intStoreId = PIL.intStoreId
							JOIN tblICItemLocation IL 
								ON IL.intLocationId = ST.intCompanyLocationId 
								   AND IL.intItemId = I.intItemId
							JOIN tblICItemPricing Prc 
								ON Prc.intItemLocationId = IL.intItemLocationId
							JOIN tblSTSubcategoryRegProd SubCat 
								ON SubCat.intStoreId = ST.intStoreId
							JOIN tblSTRegister R 
								ON R.intStoreId = ST.intStoreId
							WHERE I.ysnFuelItem = CAST(0 AS BIT) 
							AND R.intRegisterId = @intRegisterId 
							AND ST.intStoreId = @intStoreId
							--AND PIL.intPromoItemListId BETWEEN @intBeginningPromoItemListId AND @intEndingPromoItemListId

							AND I.intItemId NOT IN (SELECT intItemId FROM @tableGetItems)
					) as t
				) t1
				WHERE rn = 1
			END


		--PromotionSalesList
		IF(@ysnPromotionSalesList = 1)
			BEGIN
				-- COMBO
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
							JOIN @tablePricebookFileOne tmpItem 
								ON tmpItem.intItemId = I.intItemId
							JOIN tblICItemLocation IL 
								ON IL.intItemId = I.intItemId
							JOIN tblICItemPricing Prc 
								ON Prc.intItemLocationId = IL.intItemLocationId
							JOIN tblSMCompanyLocation L 
								ON L.intCompanyLocationId = IL.intLocationId 
							JOIN tblSTStore ST 
								ON ST.intCompanyLocationId = L.intCompanyLocationId 
							JOIN tblSTRegister R 
								ON R.intStoreId = ST.intStoreId
							JOIN tblSTPromotionSalesList PSL 
								ON PSL.intStoreId = ST.intStoreId --AND Cat.intCategoryId = PSL.intCategoryId
							JOIN tblSTPromotionSalesListDetail PSLD 
								ON PSLD.intPromoSalesListId = PSL.intPromoSalesListId
							JOIN tblSTPromotionItemList PIL 
								ON PIL.intPromoItemListId = PSLD.intPromoItemListId
							JOIN tblSTPromotionItemListDetail PILD 
								ON PILD.intPromoItemListId = PIL.intPromoItemListId
							JOIN tblICItemUOM IUOM 
								ON IUOM.intItemUOMId = PILD.intItemUOMId 
							JOIN tblICUnitMeasure IUM 
								ON IUM.intUnitMeasureId = IUOM.intUnitMeasureId
							JOIN tblSTSubcategoryRegProd SubCat 
								ON SubCat.intStoreId = ST.intStoreId
							WHERE R.intRegisterId = @intRegisterId  
							AND ST.intStoreId = @intStoreId 
							AND PSL.strPromoType = 'C'
							--AND PSL.intPromoSalesId BETWEEN @intBeginningPromoSalesId AND @intEndingPromoSalesId
							AND I.intItemId NOT IN (SELECT intItemId FROM @tableGetItems)

						) as t
				) t1
				WHERE rn = 1
			
				-- MIX AND MATCH
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
						JOIN @tablePricebookFileOne tmpItem 
							ON tmpItem.intItemId = I.intItemId
						JOIN tblICItemLocation IL 
							ON IL.intItemId = I.intItemId
						JOIN tblICItemPricing Prc 
							ON Prc.intItemLocationId = IL.intItemLocationId
						JOIN tblSMCompanyLocation L 
							ON L.intCompanyLocationId = IL.intLocationId 
						JOIN tblSTStore ST 
							ON ST.intCompanyLocationId = L.intCompanyLocationId 
						JOIN tblSTRegister R 
							ON R.intStoreId = ST.intStoreId
						JOIN tblSTPromotionSalesList PSL 
							ON PSL.intStoreId = ST.intStoreId --AND Cat.intCategoryId = PSL.intCategoryId
						JOIN tblSTPromotionSalesListDetail PSLD 
							ON PSLD.intPromoSalesListId = PSL.intPromoSalesListId
						JOIN tblSTPromotionItemList PIL 
							ON PIL.intPromoItemListId = PSLD.intPromoItemListId
						JOIN tblSTPromotionItemListDetail PILD 
							ON PILD.intPromoItemListId = PIL.intPromoItemListId
						JOIN tblICItemUOM IUOM 
							ON IUOM.intItemUOMId = PILD.intItemUOMId 
						JOIN tblICUnitMeasure IUM 
							ON IUM.intUnitMeasureId = IUOM.intUnitMeasureId
						JOIN tblSTSubcategoryRegProd SubCat 
							ON SubCat.intStoreId = ST.intStoreId
						WHERE R.intRegisterId = @intRegisterId  
						AND ST.intStoreId = @intStoreId 
						AND PSL.strPromoType = 'M'
						--AND PSL.intPromoSalesId BETWEEN @intBeginningPromoSalesId AND @intEndingPromoSalesId
						AND I.intItemId NOT IN (SELECT intItemId FROM @tableGetItems)
					) as t
				) t1
				WHERE rn = 1
			END
		 --=============================================================================================






		SELECT DISTINCT strActionType
			, strUpcCode
			, strDescription
			, dblSalePrice
			, ysnSalesTaxed
			, ysnIdRequiredLiquor
			, ysnIdRequiredCigarette
			, strRegProdCode 
		FROM @tableGetItems




		SELECT @intCountRows = COUNT(*) FROM @tableGetItems
		SET @strStatusMsg = 'Success'

	END TRY

	BEGIN CATCH
		SET @intCountRows = 0
		SET @strStatusMsg = ERROR_MESSAGE()
	END CATCH
END