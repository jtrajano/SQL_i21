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
AS

BEGIN TRY

	DECLARE @ErrMsg NVARCHAR(MAX);

	DECLARE @tableGetItems TABLE(
									strActionType NVARCHAR(3)
									, strUpcCode NVARCHAR(20)
									, strDescription NVARCHAR(150)
									, dblSalePrice DECIMAL(18, 6)
									, ysnSalesTaxed BIT
									, ysnIdRequiredLiquor BIT
									, ysnIdRequiredCigarette BIT
									, strRegProdCode NVARCHAR(200)
								)


	--PricebookFile @StoreId @Register, @Category, @BeginingChangeDate, @EndingChangeDate, @ExportEntirePricebookFile
	IF(@ysnPricebookFile = 1)
		BEGIN

			DECLARE @tablePricebookFileOne TABLE(intItemId int, strActionType nvarchar(20), dtmDate DATETIME)
			DECLARE @tablePricebookFileTwo TABLE(intItemId int, strActionType nvarchar(20), dtmDate DATETIME)

			--Insert to table1
			INSERT INTO @tablePricebookFileOne
			SELECT
				DISTINCT CAST(strRecordNo as int) [intItemId]
				, strActionType
				, dtmDate
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
				  OR CHARINDEX('Created', strJsonData) > 0)
		   AND dtmDate BETWEEN @dtmBeginningChangeDate AND @dtmEndingChangeDate

		   --Insert to table2
		   INSERT INTO @tablePricebookFileTwo
		   SELECT t1.intItemId, t1.strActionType, t1.dtmDate
				FROM(
					SELECT *,
						rn = ROW_NUMBER() OVER(PARTITION BY t.intItemId ORDER BY (SELECT NULL))
					FROM @tablePricebookFileOne as t
		   )t1
		   WHERE rn = 1


		   INSERT INTO @tableGetItems
		   SELECT 
		    CASE WHEN tmpItem.strActionType = 'Created' THEN 'ADD' ELSE 'CHG' END AS strActionType
			, IUOM.strUpcCode AS strUpcCode
			, I.strDescription AS strDescription
			, Prc.dblSalePrice AS dblSalePrice
			, 1 AS ysnSalesTaxed
			, IL.ysnIdRequiredLiquor AS ysnIdRequiredLiquor
			, IL.ysnIdRequiredCigarette AS ysnIdRequiredCigarette
			, SubCat.strRegProdCode AS strRegProdCode
				   from tblICItem I
				   JOIN tblICCategory Cat ON Cat.intCategoryId = I.intCategoryId
				   JOIN @tablePricebookFileTwo tmpItem ON tmpItem.intItemId = I.intItemId
				   JOIN tblICItemLocation IL ON IL.intItemId = I.intItemId
				   LEFT JOIN tblSTSubcategoryRegProd SubCat ON SubCat.intRegProdId = IL.intProductCodeId
				   JOIN tblSTStore ST ON ST.intStoreId = SubCat.intStoreId
				   JOIN tblSMCompanyLocation L ON L.intCompanyLocationId = IL.intLocationId
				   JOIN tblICItemUOM IUOM ON IUOM.intItemId = I.intItemId
				   JOIN tblICUnitMeasure IUM ON IUM.intUnitMeasureId = IUOM.intUnitMeasureId
				   JOIN tblSTRegister R ON R.intStoreId = ST.intStoreId
				   JOIN tblICItemPricing Prc ON Prc.intItemLocationId = IL.intItemLocationId
				   JOIN tblICItemSpecialPricing SplPrc ON SplPrc.intItemId = I.intItemId
			WHERE I.ysnFuelItem = 0 
			AND R.intRegisterId = @intRegisterId 
			AND ST.intStoreId = @intStoreId
			AND ((@strCategoryCode <>'whitespaces' 
			AND Cat.intCategoryId IN(select * from dbo.fnSplitString(@strCategoryCode,',')))
			OR (@strCategoryCode ='whitespaces'  AND Cat.intCategoryId = Cat.intCategoryId))
			AND I.intItemId IN (SELECT intItemId FROM @tablePricebookFileTwo)
		END


	----PromotionItemListFile @StoreId , @Register, @BeginningItemListId, @EndingItemListId
	--IF(@ysnPromotionItemList = 1)
	--	BEGIN
	--		Print('')
	--	END


	----PromotionSalesList
	--IF(@ysnPromotionSalesList = 1)
	--	BEGIN
	--		IF(@strPromoCode = 'Combo')
	--			BEGIN
	--				Print('@StoreId , @Register, @BeginningComboId, @EndingComboId')
	--			END
	--		ELSE
	--			BEGIN
	--				Print('@StoreId , @Register, @BeginningMixMatchId, @EndingMixMatchId, @BuildFileThruEndingDate, @ExportEntirePricebookFile')
	--			END
	--	END

	-- Insert to tblSTUpdateRegisterHistory
	INSERT INTO tblSTUpdateRegisterHistory (intStoreId, intRegisterId, ysnPricebookFile, ysnPromotionItemList, ysnPromotionSalesList, dtmBeginningChangeDate, dtmEndingChangeDate, strCategoryCode, ysnExportEntirePricebookFile, intBeginningPromoItemListId, intEndingPromoItemListId, strPromoCode, intBeginningPromoSalesId, intEndingPromoSalesId, dtmBuildFileThruEndingDate)
    VALUES (@intStoreId, @intRegisterId, @ysnPricebookFile, @ysnPromotionItemList, @ysnPromotionSalesList, @dtmBeginningChangeDate, @dtmEndingChangeDate, @strCategoryCode, @ysnExportEntirePricebookFile, @intBeginningPromoItemListId, @intEndingPromoItemListId, @strPromoCode, @intBeginningPromoSalesId, @intEndingPromoSalesId, @dtmBuildFileThruEndingDate)


	-- Send query to server side 
	SELECT strActionType
		, strUpcCode
		, strDescription
		, dblSalePrice
		, ysnSalesTaxed
		, ysnIdRequiredLiquor
		, ysnIdRequiredCigarette
		, strRegProdCode 
	FROM @tableGetItems
END TRY

BEGIN CATCH       
	SET @ErrMsg = ERROR_MESSAGE()      
	RAISERROR(@ErrMsg, 16, 1, 'WITH NOWAIT')      
END CATCH