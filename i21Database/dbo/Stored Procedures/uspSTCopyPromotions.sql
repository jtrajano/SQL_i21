CREATE PROCEDURE [dbo].[uspSTCopyPromotions]
   @XML VARCHAR(max)
AS
BEGIN TRY

	 BEGIN TRANSACTION

     DECLARE @ErrMsg				 	  NVARCHAR(MAX),
	         @idoc				          INT,
	     	 @intFromStoreId                   INT,
	         @ToStore                     NVARCHAR(MAX),
			 @intBeginningComboID               INT,
			 @intEndingComboID                 INT,
             @intBeginingMixMatchID          INT,
			 @intEndingMixMatchID            INT,
			 @intBeginningItemsListNo           INT,
			 @intEndingItemsListNo             INT,
	  		 @ReplaceDuplicateRecordsysn  NVARCHAR(1),
			 @intItemListAddedCount                    INT,
			 @Itlreplaced                 INT,
			 @intComboListAddedCount                    INT,
			 @intComboReplacedCount                 INT, 
			 @intMixMatchAddedCount                    INT,
			 @intMixMatchReplacedCount                 INT,
		     @intPromotionItemListAdded      INT,
			 @intPromoItemListReplaced       INT,
			 @intComboAdded                  INT,
			 @intComboReplaced               INT,
			 @intMixMatchAdded               INT,
			 @intMixMatchReplaced            INT,

			 @intPromotionItemListId		INT,
			 @intPromotionComboListId       INT,
			 @intPromotionMixMatchListId	INT,
			 @intNewPromotionItemListId		INT,
			 @intNewPromotionComboListId    INT,
			 @intNewPromotionMixMatchListId    INT,

			 @strStatusMsg				 NVARCHAR(1000) = ''

    EXEC sp_xml_preparedocument @idoc OUTPUT, @XML 

    SELECT	
			@intFromStoreId		             =	 FromStore,
            @ToStore                     =   ToStore,
			@intBeginningComboID               =   BeginingCombo,
			@intEndingComboID                 =   EndingCombo,
            @intBeginingMixMatchID          =   BeginingMixMatchID,
            @intEndingMixMatchID            =   EndingMixMatchID,
			@intBeginningItemsListNo           =   BeginingItemsList,
			@intEndingItemsListNo             =   EndingItemsList,
			@ReplaceDuplicateRecordsysn  =   ReplaceDuplicateRecordsysn
			
		
	FROM	OPENXML(@idoc, 'root',2)
	WITH
	(
			FromStore		              INT,
			ToStore	     	              NVARCHAR(MAX),
			BeginingCombo		          INT,
			EndingCombo	     	          INT,
			BeginingMixMatchID	     	  INT,
			EndingMixMatchID	     	  INT,
			BeginingItemsList	          INT,
			EndingItemsList               INT,
			ReplaceDuplicateRecordsysn    NVARCHAR(1)
			
	)  
     
	  SET @intItemListAddedCount = 0
	  SET @Itlreplaced = 0
	  SET @intComboListAddedCount = 0
	  SET @intComboReplacedCount = 0
	  SET @intMixMatchAddedCount = 0
	  SET @intMixMatchReplacedCount = 0
	  SET @intPromotionItemListAdded  = 0  
	  SET @intPromoItemListReplaced   = 0
	  SET @intComboAdded = 0
	  SET @intComboReplaced = 0 
	  SET @intMixMatchAdded = 0
	  SET @intMixMatchReplaced = 0  


	 -- =========================================================================
	 -- [START] - Create Temporary Tables
	 -- =========================================================================

	 -- STORE LIST
     DECLARE @temptblStore TABLE (
									intPrimaryID INT IDENTITY(1, 1),
									intStoreId INT
								 );
     -- ITEM LIST
	 DECLARE @temptblPromoItemList TABLE (
											intPrimaryID INT IDENTITY(1, 1),
											intPromoItemListId INT,
											intPromoItemListNo INT
										 );

	 -- COMBO LIST
	 DECLARE @temptblPromoComboList TABLE (
											intPrimaryID INT IDENTITY(1, 1),
											intPromoComboSalesId INT 
										 );

	 -- MIX-MATCH LIST
	 DECLARE @temptblPromoMixMatchList TABLE (
											intPrimaryID INT IDENTITY(1, 1),
											intPromoMixMatchSalesId INT 
										 );
	 -- =========================================================================
	 -- [END] - Create Temporary Tables
	 -- =========================================================================




	 -- =========================================================================
	 -- [START] - POPULATE TEMP TABLES
	 -- =========================================================================
     DECLARE @intStoreId INT

	 IF(@ToStore != '')
		BEGIN
			-- Insert all intStoreId's to a temp table
			 INSERT INTO @temptblStore 
			 (
				intStoreId
			 )
			 SELECT [intID] AS intStoreId
			 FROM [dbo].[fnGetRowsFromDelimitedValues](@ToStore)
		END
	 

	 IF(@intBeginningItemsListNo != 0 AND @intEndingItemsListNo != 2147483647)
		BEGIN
			-- Insert All Promotion ITEM to temp table
			INSERT INTO @temptblPromoItemList 
			(
				intPromoItemListId
				, intPromoItemListNo
			)
			SELECT intPromoItemListId
				  , intPromoItemListNo
			FROM tblSTPromotionItemList 
			WHERE  intPromoItemListNo BETWEEN @intBeginningItemsListNo AND @intEndingItemsListNo
				AND intStoreId = @intFromStoreId 
		END
	
	
	 IF(@intBeginningComboID != 0 AND @intEndingComboID != 2147483647)
		BEGIN
			-- Insert All Promotion COMBO to temp table
			INSERT INTO @temptblPromoComboList 
			(
				intPromoComboSalesId
			)
			SELECT intPromoSalesId 
			FROM tblSTPromotionSalesList 
			WHERE  intPromoSalesId BETWEEN @intBeginningComboID AND @intEndingComboID
				AND intStoreId = @intFromStoreId 
				AND strPromoType = 'C'
		END
	

	 IF(@intBeginingMixMatchID != 0 AND @intEndingMixMatchID != 2147483647)
		BEGIN
			-- Insert All Promotion MIX-MATCH to temp table
			INSERT INTO @temptblPromoMixMatchList 
			(
				intPromoMixMatchSalesId
			)
			SELECT intPromoSalesId 
			FROM tblSTPromotionSalesList 
			WHERE intPromoSalesId BETWEEN @intBeginingMixMatchID AND @intEndingMixMatchID
				AND intStoreId = @intFromStoreId 
				AND strPromoType = 'M'
		END
	
	-- =========================================================================
	-- [END] - POPULATE TEMP TABLES
	-- =========================================================================


----TEST
--SELECT '@temptblStore', * FROM @temptblStore
--SELECT '@temptblPromoItemList', * FROM @temptblPromoItemList
--SELECT '@temptblPromoComboList', * FROM @temptblPromoComboList
--SELECT '@temptblPromoMixMatchList', * FROM @temptblPromoMixMatchList

	  DECLARE @intPrimaryID INT

      IF (@ReplaceDuplicateRecordsysn = 'Y')
		  BEGIN
	      
			  SELECT @intPrimaryID = MIN(intPrimaryID)
			  FROM @temptblStore

			  -- ==================================================================================
			  -- [START] - COMPUTE REPLACE COUNT AND DELETE EXISTING SALES PROMOTION
			  -- ==================================================================================

       		  WHILE (@intPrimaryID > 0)
				  BEGIN
				
					 -- GET Store ID
					 SELECT @intStoreId = intStoreId  
					 FROM @temptblStore
					 WHERE intPrimaryID = @intPrimaryID



					 -- ==================================================================================
					 -- [START] - COMBO PROMOTIONS
					 -- ==================================================================================
					 
					 --IF(@intBeginningComboID != 0 AND @intEndingComboID != 2147483647)
					 IF EXISTS(SELECT TOP 1 1 FROM @temptblPromoComboList)
						BEGIN
							-- COUNT Combo Replaced
							 SELECT @intComboReplacedCount = COUNT(*) 
							 FROM tblSTPromotionSalesList
							 WHERE intPromoSalesId IN (SELECT intPromoComboSalesId FROM @temptblPromoComboList)
								AND intStoreId = @intStoreId
								AND strPromoType = 'C'

							 SET @intComboReplaced = @intComboReplaced + @intComboReplacedCount

							 -- DELETE table PromotionSalesList if already existing
							 DELETE FROM tblSTPromotionSalesList 
							 WHERE intPromoSalesId IN (SELECT intPromoComboSalesId FROM @temptblPromoComboList)
								AND intStoreId = @intStoreId
								AND strPromoType = 'C'
						END

					 -- ==================================================================================
					 -- [END] - COMBO PROMOTIONS
					 -- ==================================================================================





					 -- ==================================================================================
					 -- [START] - MIX-MATCH PROMOTIONS
					 -- ==================================================================================

					 --IF(@intBeginingMixMatchID != 0 AND @intEndingMixMatchID != 2147483647)
					 IF EXISTS(SELECT TOP 1 1 FROM @temptblPromoMixMatchList)
						BEGIN
							-- COUNT Mix-Match Replaced
							 SELECT @intMixMatchReplacedCount = COUNT(*) 
							 FROM tblSTPromotionSalesList  
							 WHERE intPromoSalesListId IN (SELECT intPromoMixMatchSalesId FROM @temptblPromoMixMatchList)
								AND intStoreId = @intStoreId
								AND strPromoType = 'M' 
					 
							 SET @intMixMatchReplaced = @intMixMatchReplaced + @intMixMatchReplacedCount

							 DELETE FROM tblSTPromotionSalesList 
							 WHERE intPromoSalesId BETWEEN @intBeginingMixMatchID AND @intEndingMixMatchID
								AND intStoreId = @intStoreId 
								AND strPromoType = 'M'
						END
					 
					 -- ==================================================================================
					 -- [END] - MIX-MATCH PROMOTIONS
					 -- ==================================================================================





					 -- ==================================================================================
					 -- [START] - ITEM LIST PROMOTIONS
					 -- ==================================================================================

					 --IF(@intBeginningItemsListNo != 0 AND @intEndingItemsListNo != 2147483647)
					 IF EXISTS(SELECT TOP 1 1 FROM @temptblPromoItemList)
						BEGIN
							-- COUNT Item-List Replaced
							 SELECT @Itlreplaced = COUNT(*) 
							 FROM tblSTPromotionItemList 
							 WHERE intPromoItemListNo IN (SELECT intPromoItemListNo FROM @temptblPromoItemList)
								AND intStoreId = @intStoreId

							 SET @intPromoItemListReplaced  = @intPromoItemListReplaced + @Itlreplaced

							 DELETE FROM tblSTPromotionItemList 
							 WHERE intPromoItemListNo IN (SELECT intPromoItemListNo FROM @temptblPromoItemList)
								AND intStoreId = @intStoreId 
								--AND intPromoItemListId NOT IN (SELECT intPromoItemListId FROM tblSTPromotionSalesListDetail)
						END
					 
					 -- ==================================================================================
					 -- [END] - ITEM LIST PROMOTIONS
					 -- ==================================================================================




					 SELECT @intPrimaryID = MIN(intPrimaryID)
					 FROM @temptblStore
					 WHERE intPrimaryID > @intPrimaryID
   				  END	  

			  -- ==================================================================================
			  -- [END] - COMPUTE REPLACE COUNT AND DELETE EXISTING SALES PROMOTION
			  -- ==================================================================================
		 END





	 

	 SELECT @intPrimaryID = MIN(intPrimaryID)
	 FROM @temptblStore

	 -- ===========================================================================================
	 -- [START] - CLONE PROMOTIONS
	 -- ===========================================================================================

	 WHILE (@intPrimaryID > 0)
		BEGIN
		   
		   -- GET 'intStoreId'
		   SELECT @intStoreId = intStoreId  
		   FROM @temptblStore
		   WHERE intPrimaryID = @intPrimaryID


		   -- ======================================================================================
		   -- [START] - ITEM LIST PROMOTIONS
		   -- ======================================================================================

		   IF EXISTS(SELECT TOP 1 1 FROM @temptblPromoItemList)
				BEGIN
				   SELECT 
						@intItemListAddedCount = COUNT(intPromoItemListId) 
				   FROM tblSTPromotionItemList
				   WHERE intPromoItemListId IN (SELECT intPromoItemListId FROM @temptblPromoItemList)
						AND intStoreId = @intFromStoreId 


				   SET @intPromotionItemListAdded = @intPromotionItemListAdded + @intItemListAddedCount
					
				   -- ====================================================================================================================
				   -- [START] - Loop to all PROMOTION ITEM LIST
				   -- ====================================================================================================================

				   -- Loop to all the Promotion List to be inserted to all From: intStoreId's
				   WHILE EXISTS (SELECT TOP (1) 1 FROM @temptblPromoItemList)
						BEGIN
							SELECT TOP 1 @intPromotionItemListId = intPromoItemListId FROM @temptblPromoItemList

							--Inserting ItemList Header From to ToStore
						    INSERT INTO tblSTPromotionItemList 
						    (
								intStoreId
								, intPromoItemListNo
								, strPromoItemListId
								, strPromoItemListDescription
								, ysnDeleteFromRegister
								, dtmLastUpdateDate
								, intConcurrencyId
								, strClass
								, strFamily
						    )
						    SELECT 
								@intStoreId 
								, ItemList.intPromoItemListNo
								, ItemList.strPromoItemListId
								, ItemList.strPromoItemListDescription
								, CASE
									WHEN ItemList.ysnDeleteFromRegister IS NULL
										THEN 0
									ELSE ItemList.ysnDeleteFromRegister
								END AS ysnDeleteFromRegister
								, ItemList.dtmLastUpdateDate
								, ItemList.intConcurrencyId 
								, CASE
									WHEN ItemList.strClass IS NULL
										THEN ''
									ELSE ItemList.strClass
								END AS strClass
								, CASE
									WHEN ItemList.strFamily IS NULL
										THEN ''
									ELSE ItemList.strFamily
								END AS strFamily
						    FROM tblSTPromotionItemList ItemList
						    WHERE ItemList.intStoreId = @intFromStoreId 
								 AND ItemList.intPromoItemListId = @intPromotionItemListId

						    -- Get new primary ID
						    SET @intNewPromotionItemListId = SCOPE_IDENTITY();

						    --Inserting ItemList Details From to ToStore
						    INSERT INTO tblSTPromotionItemListDetail 
						    (
								intPromoItemListId
								, intItemUOMId
								, strUpcDescription
								, intUpcModifier
								, dblRetailPrice
								, intConcurrencyId
						    )
						    SELECT 
								@intNewPromotionItemListId
								, ItemListDetail.intItemUOMId
								, ItemListDetail.strUpcDescription
								, ItemListDetail.intUpcModifier
								, ItemListDetail.dblRetailPrice
								, ItemListDetail.intConcurrencyId 			
						   FROM tblSTPromotionItemListDetail AS ItemListDetail 
						   INNER JOIN tblSTPromotionItemList  AS ItemList
							  ON ItemListDetail.intPromoItemListId = ItemList.intPromoItemListId 
						   WHERE ItemList.intStoreId = @intFromStoreId
							  AND ItemList.intPromoItemListId = @intPromotionItemListId

							DELETE TOP (1) FROM @temptblPromoItemList
						END
			   
				   -- ====================================================================================================================
				   -- [END] - Loop to all PROMOTION ITEM LIST
				   -- ====================================================================================================================
				END

           -- ======================================================================================
		   -- [END] - ITEM LIST PROMOTIONS
		   -- ======================================================================================





		   -- ======================================================================================
		   -- [START] - COMBO LIST
		   -- ======================================================================================

		   IF EXISTS(SELECT TOP 1 1 FROM @temptblPromoComboList)
				BEGIN

				   SELECT 
						@intComboListAddedCount = COUNT(intPromoSalesId) 
				   FROM tblSTPromotionSalesList
				   WHERE intPromoSalesListId IN (SELECT intPromoSalesListId FROM @temptblPromoComboList)
						AND intStoreId = @intFromStoreId

				   SET @intComboAdded = @intComboAdded + @intComboListAddedCount

				   -- ====================================================================================================================
				   -- [START] - Loop to all PROMOTION COMBO LIST
				   -- ====================================================================================================================

				   WHILE EXISTS (SELECT TOP (1) 1 FROM @temptblPromoComboList)
						BEGIN
							
						   SELECT TOP 1 @intPromotionComboListId = intPromoComboSalesId FROM @temptblPromoComboList

						   ----Inserting Combo Header From to ToStore
						   INSERT INTO tblSTPromotionSalesList 
						   (
								strPromoType
								, intStoreId
								, intPromoSalesId
								, intCategoryId
								, strPromoSalesDescription
								, strPromoReason
								, intPromoUnits
								, dblPromoPrice
								, intPromoFeeType
								, intRegProdId
								, dtmPromoBegPeriod
								, dtmPromoEndPeriod
								, intPurchaseLimit
								, intSalesRestrictCode
								, ysnPurchaseAtleastMin
								, ysnPurchaseExactMultiples
								, ysnRecieptItemSize
								, ysnReturnable
								, ysnFoodStampable
								, ysnId1Required
								, ysnId2Required
								, ysnDiscountAllowed
								, ysnBlueLaw1
								, ysnBlueLaw2
								, ysnUserTaxFlag1
								, ysnUserTaxFlag2
								, ysnUserTaxFlag3
								, ysnUserTaxFlag4
								, ysnDeleteFromRegister
								, ysnSentToRuby
								, dtmLastUpdateDate
								, intConcurrencyId
						   ) 
						   SELECT 
								strPromoType
								, @intStoreId
								, intPromoSalesId
								, intCategoryId
								, strPromoSalesDescription
								, strPromoReason
								, intPromoUnits
								, dblPromoPrice
								, intPromoFeeType
								, intRegProdId
								, dtmPromoBegPeriod
								, dtmPromoEndPeriod
								, intPurchaseLimit
								, intSalesRestrictCode
								, ysnPurchaseAtleastMin
								, ysnPurchaseExactMultiples
								, ysnRecieptItemSize
								, ysnReturnable
								, ysnFoodStampable
								, ysnId1Required
								, ysnId2Required
								, ysnDiscountAllowed
								, ysnBlueLaw1
								, ysnBlueLaw2
								, ysnUserTaxFlag1
								, ysnUserTaxFlag2
								, ysnUserTaxFlag3
								, ysnUserTaxFlag4
								, ysnDeleteFromRegister
								, ysnSentToRuby
								, dtmLastUpdateDate
								, intConcurrencyId
						   FROM tblSTPromotionSalesList 
						   WHERE intPromoSalesId = @intPromotionComboListId --IN (SELECT intPromoComboSalesId FROM @temptblPromoComboList)
								AND intStoreId = @intFromStoreId 
						   
						   -- Get new primary ID
						   SET @intNewPromotionComboListId = SCOPE_IDENTITY();

						  -----Inserting Combo Details From to ToStore
						  INSERT INTO tblSTPromotionSalesListDetail 
						  (
								intPromoSalesListId
								, intPromoItemListId
								, intQuantity
								, dblPrice
								, intConcurrencyId
						  )
						  SELECT 
								 @intNewPromotionComboListId AS intPromoSalesListId
								 , ItemListTwo.intPromoItemListId
								 , SalesListDetail.intQuantity
								 , SalesListDetail.dblPrice
								 , SalesListDetail.intConcurrencyId
						   FROM tblSTPromotionItemList ItemList
						   INNER JOIN tblSTPromotionSalesListDetail SalesListDetail
								ON ItemList.intPromoItemListId = SalesListDetail.intPromoItemListId
						   INNER JOIN tblSTPromotionSalesList SalesList
								ON SalesListDetail.intPromoSalesListId = SalesList.intPromoSalesListId
						   INNER JOIN
						   (
								SELECT *
								FROM tblSTPromotionItemList
								WHERE intStoreId = @intStoreId
						   ) AS ItemListTwo
								ON ItemList.intPromoItemListNo = ItemListTwo.intPromoItemListNo
						   WHERE SalesList.intPromoSalesId = @intPromotionComboListId


							DELETE TOP (1) FROM @temptblPromoComboList
						END
				   
				  -- ====================================================================================================================
				   -- [START] - Loop to all PROMOTION COMBO LIST
				   -- ====================================================================================================================
				END         

		   -- ======================================================================================
		   -- [START] - COMBO LIST
		   -- ======================================================================================





		   -- ======================================================================================
		   -- [START] - MIX-MATCH LIST
		   -- ======================================================================================

		   IF EXISTS(SELECT TOP 1 1 FROM @temptblPromoMixMatchList)
				BEGIN

				   SELECT 
						@intMixMatchAddedCount = COUNT(intPromoSalesId) 
				   FROM tblSTPromotionSalesList
				   WHERE intPromoSalesListId IN (SELECT intPromoSalesListId FROM @temptblPromoMixMatchList)
						AND intStoreId = @intFromStoreId

				   SET @intMixMatchAdded = @intMixMatchAdded + @intMixMatchAddedCount

				   -- ====================================================================================================================
				   -- [START] - Loop to all PROMOTION MIX_MATCH LIST
				   -- ====================================================================================================================

				   WHILE EXISTS (SELECT TOP (1) 1 FROM @temptblPromoMixMatchList)
						BEGIN
							
						   SELECT TOP 1 @intPromotionMixMatchListId = intPromoMixMatchSalesId FROM @temptblPromoMixMatchList

						   ----Inserting Mix-Match Header From to ToStore
						   INSERT INTO tblSTPromotionSalesList 
						   (
								strPromoType
								, intStoreId
								, intPromoSalesId
								, intCategoryId
								, strPromoSalesDescription
								, strPromoReason
								, intPromoUnits
								, dblPromoPrice
								, intPromoFeeType
								, intRegProdId
								, dtmPromoBegPeriod
								, dtmPromoEndPeriod
								, intPurchaseLimit
								, intSalesRestrictCode
								, ysnPurchaseAtleastMin
								, ysnPurchaseExactMultiples
								, ysnRecieptItemSize
								, ysnReturnable
								, ysnFoodStampable
								, ysnId1Required
								, ysnId2Required
								, ysnDiscountAllowed
								, ysnBlueLaw1
								, ysnBlueLaw2
								, ysnUserTaxFlag1
								, ysnUserTaxFlag2
								, ysnUserTaxFlag3
								, ysnUserTaxFlag4
								, ysnDeleteFromRegister
								, ysnSentToRuby
								, dtmLastUpdateDate
								, intConcurrencyId
						   ) 
						   SELECT 
								strPromoType
								, @intStoreId
								, intPromoSalesId
								, intCategoryId
								, strPromoSalesDescription
								, strPromoReason
								, intPromoUnits
								, dblPromoPrice
								, intPromoFeeType
								, intRegProdId
								, dtmPromoBegPeriod
								, dtmPromoEndPeriod
								, intPurchaseLimit
								, intSalesRestrictCode
								, ysnPurchaseAtleastMin
								, ysnPurchaseExactMultiples
								, ysnRecieptItemSize
								, ysnReturnable
								, ysnFoodStampable
								, ysnId1Required
								, ysnId2Required
								, ysnDiscountAllowed
								, ysnBlueLaw1
								, ysnBlueLaw2
								, ysnUserTaxFlag1
								, ysnUserTaxFlag2
								, ysnUserTaxFlag3
								, ysnUserTaxFlag4
								, ysnDeleteFromRegister
								, ysnSentToRuby
								, dtmLastUpdateDate
								, intConcurrencyId
						   FROM tblSTPromotionSalesList 
						   WHERE intPromoSalesId = @intPromotionMixMatchListId 
								AND intStoreId = @intFromStoreId 
						   
						   -- Get new primary ID
						   SET @intNewPromotionMixMatchListId = SCOPE_IDENTITY();

						  -----Inserting Mix-Match Details From to ToStore
						  INSERT INTO tblSTPromotionSalesListDetail 
						  (
								intPromoSalesListId
								, intPromoItemListId
								, intQuantity
								, dblPrice
								, intConcurrencyId
						  )
						  SELECT 
								 @intNewPromotionMixMatchListId AS intPromoSalesListId
								 , ItemListTwo.intPromoItemListId
								 , SalesListDetail.intQuantity
								 , SalesListDetail.dblPrice
								 , SalesListDetail.intConcurrencyId
						   FROM tblSTPromotionItemList ItemList
						   INNER JOIN tblSTPromotionSalesListDetail SalesListDetail
								ON ItemList.intPromoItemListId = SalesListDetail.intPromoItemListId
						   INNER JOIN tblSTPromotionSalesList SalesList
								ON SalesListDetail.intPromoSalesListId = SalesList.intPromoSalesListId
						   INNER JOIN
						   (
								SELECT *
								FROM tblSTPromotionItemList
								WHERE intStoreId = @intStoreId
						   ) AS ItemListTwo
								ON ItemList.intPromoItemListNo = ItemListTwo.intPromoItemListNo
						   WHERE SalesList.intPromoSalesId = @intPromotionMixMatchListId


							DELETE TOP (1) FROM @temptblPromoMixMatchList
						END
				   
				  -- ====================================================================================================================
				   -- [START] - Loop to all PROMOTION MIX_MATCH LIST
				   -- ====================================================================================================================
				END  

		   -- ======================================================================================
		   -- [END] - MIX-MATCH LIST
		   -- ======================================================================================

			SELECT @intPrimaryID = MIN(intPrimaryID)
			FROM @temptblStore
		    WHERE intPrimaryID > @intPrimaryID

		END	  
	 
	 -- ===========================================================================================
	 -- [END] - CLONE PROMOTIONS
	 -- ===========================================================================================




	  IF (@ReplaceDuplicateRecordsysn = 'Y')
	  BEGIN

	     SET @intComboAdded = @intComboAdded- @intComboReplaced 

		 IF @intComboAdded < 0
		 BEGIN
		    SET @intComboAdded = @intComboAdded * -1
		 END

		 IF @intComboReplaced < 0
		 BEGIN
		    SET @intComboReplaced = @intComboReplaced * -1
		 END

		 set @intMixMatchAdded = @intMixMatchAdded- @intMixMatchReplaced 

		 IF @intMixMatchAdded < 0
		 BEGIN
		    SET @intMixMatchAdded = @intMixMatchAdded * -1
		 END

		 IF @intMixMatchReplaced < 0
		 BEGIN
		    SET @intMixMatchReplaced = @intMixMatchReplaced * -1
		 END

	     SET @intPromotionItemListAdded = @intPromotionItemListAdded - @intPromoItemListReplaced

		 IF @intPromotionItemListAdded < 0
		 BEGIN
		    SET @intPromotionItemListAdded = @intPromotionItemListAdded * -1
		 END

		 IF @intPromoItemListReplaced < 0
		 BEGIN
		    SET @intPromoItemListReplaced = @intPromoItemListReplaced * -1
		 END

	  END

	  SET @strStatusMsg = 'Success'

	  SELECT @intPromotionItemListAdded AS intPromotionItemListAdded
	       , @intPromoItemListReplaced AS intPromoItemListReplaced
		   , @intComboAdded AS intComboAdded
		   , @intComboReplaced As intComboReplaced
		   , @intMixMatchAdded AS intMixMatchAdded
		   , @intMixMatchReplaced AS intMixMatchReplaced
		   , @strStatusMsg AS strStatusMessage

	  
	  
	  GOTO ExitWithCommit

END TRY

BEGIN CATCH
	SET @strStatusMsg = 'Script Error: ' + ERROR_MESSAGE()

	-- ROLLBACK
	GOTO ExitWithRollback
END CATCH


ExitWithCommit:
--PRINT 'Will Commit'
	-- Commit Transaction
	COMMIT TRANSACTION
	GOTO ExitPost
	

ExitWithRollback:
    -- Rollback Transaction here
	IF @@TRANCOUNT > 0
		BEGIN
			-- PRINT 'Will Rollback'
			ROLLBACK TRANSACTION 
		END
	
		
ExitPost:




---- OLD CODE
--BEGIN
--     DECLARE @ErrMsg				 	  NVARCHAR(MAX),
--	         @idoc				          INT,
--	     	 @FromStore                   INT,
--	         @ToStore                     NVARCHAR(MAX),
--			 @BeginingCombo               INT,
--			 @EndingCombo                 INT,
--             @BeginingMixMatchID          INT,
--			 @EndingMixMatchID            INT,
--			 @BeginingItemsList           INT,
--			 @EndingItemsList             INT,
--	  		 @ReplaceDuplicateRecordsysn  NVARCHAR(1),
--			 @Itladded                    INT,
--			 @Itlreplaced                 INT,
--			 @Cboadded                    INT,
--			 @Cboreplaced                 INT, 
--			 @Mxmadded                    INT,
--			 @MxmReplaced                 INT,
--		     @PromotionItemListAdded      INT,
--			 @PromoItemListReplaced       INT,
--			 @ComboAdded                  INT,
--			 @ComboReplaced               INT,
--			 @MixMatchAdded               INT,
--			 @MixMatchReplaced            INT

--    EXEC sp_xml_preparedocument @idoc OUTPUT, @XML 

--    SELECT	
--			@FromStore		             =	 FromStore,
--            @ToStore                     =   ToStore,
--			@BeginingCombo               =   BeginingCombo,
--			@EndingCombo                 =   EndingCombo,
--            @BeginingMixMatchID          =   BeginingMixMatchID,
--            @EndingMixMatchID            =   EndingMixMatchID,
--			@BeginingItemsList           =   BeginingItemsList,
--			@EndingItemsList             =   EndingItemsList,
--			@ReplaceDuplicateRecordsysn  =   ReplaceDuplicateRecordsysn
			
		
--	FROM	OPENXML(@idoc, 'root',2)
--	WITH
--	(
--			FromStore		              INT,
--			ToStore	     	              NVARCHAR(MAX),
--			BeginingCombo		          INT,
--			EndingCombo	     	          INT,
--			BeginingMixMatchID	     	  INT,
--			EndingMixMatchID	     	  INT,
--			BeginingItemsList	          INT,
--			EndingItemsList               INT,
--			ReplaceDuplicateRecordsysn    NVARCHAR(1)
			
--	)  
     
--	  set @Itladded = 0
--	  set @Itlreplaced = 0
--	  set @Cboadded = 0
--	  set @Cboreplaced = 0
--	  set @Mxmadded = 0
--	  set @MxmReplaced = 0
--	  set @PromotionItemListAdded  = 0  
--	  set @PromoItemListReplaced   = 0
--	  set @ComboAdded = 0
--	  set @ComboReplaced = 0 
--	  set @MixMatchAdded = 0
--	  set @MixMatchReplaced = 0  


--     DECLARE @tempTble Table (
--	        DataKey INT IDENTITY(1, 1),
--            DestinationStore INT NULL);

--     DECLARE @DestinationStore INT

--     while len(@ToStore ) > 0
--     begin
--        insert into @tempTble (DestinationStore ) values(left(@ToStore , charindex(',', @ToStore +',')-1))
--        set @ToStore = stuff(@ToStore , 1, charindex(',', @ToStore +','), '')
--     end

--	 Declare @DataKey int

--      if (@ReplaceDuplicateRecordsysn = 'Y')
--	  BEGIN
	      
--          SELECT @DataKey = MIN(DataKey)
--	      FROM @tempTble
--       	  WHILE (@DataKey > 0)
--	      BEGIN
             
--             SELECT @DestinationStore = DestinationStore  FROM @tempTble
--		     WHERE DataKey = @DataKey

--		     SELECT @Cboreplaced = COUNT(*) FROM tblSTPromotionSalesList  
--		     WHERE intPromoSalesId BETWEEN @BeginingCombo AND @EndingCombo
--		     and intStoreId = @DestinationStore and strPromoType = 'C'

--		     DELETE FROM tblSTPromotionSalesList 
--		     WHERE intPromoSalesId BETWEEN @BeginingCombo AND @EndingCombo
--		     and intStoreId = @DestinationStore and strPromoType = 'C'

--			 set @ComboReplaced = @ComboReplaced + @Cboreplaced

--		     SELECT @MxmReplaced = COUNT(*) FROM tblSTPromotionSalesList  
--		     WHERE intPromoSalesId BETWEEN @BeginingMixMatchID AND @EndingMixMatchID
--		     and intStoreId = @DestinationStore and strPromoType = 'M'

--			 set @MixMatchReplaced = @MixMatchReplaced + @MxmReplaced

--		     DELETE FROM tblSTPromotionSalesList 
--		     WHERE intPromoSalesId BETWEEN @BeginingMixMatchID AND @EndingMixMatchID
--		     and intStoreId = @DestinationStore and strPromoType = 'M'
	  
--	         SELECT @Itlreplaced = COUNT(*) FROM tblSTPromotionItemList 
--		     WHERE  intPromoItemListNo BETWEEN @BeginingItemsList AND @EndingItemsList
--	         and intStoreId = @DestinationStore

--			 set @PromoItemListReplaced  = @PromoItemListReplaced + @Itlreplaced

--             DELETE FROM tblSTPromotionItemList 
--		     WHERE  intPromoItemListNo BETWEEN @BeginingItemsList AND @EndingItemsList
--	         and intStoreId = @DestinationStore AND intPromoItemListId   
--		     NOT IN (SELECT intPromoItemListId FROM tblSTPromotionSalesListDetail)
		   
--             SELECT @DataKey = MIN(DataKey)
--		     FROM @tempTble
--		     Where DataKey>@DataKey
--   	      END	  
--	 END

--	 SELECT @DataKey = MIN(DataKey)
--	 FROM @tempTble
--	 WHILE (@DataKey > 0)
--	  BEGIN
--		   SELECT @DestinationStore = DestinationStore  FROM @tempTble
--		   WHERE DataKey = @DataKey

--           SELECT @Itladded= COUNT (*) from tblSTPromotionItemList
--           WHERE intPromoItemListNo between @BeginingItemsList and @EndingItemsList
--           AND intStoreId = @FromStore and intPromoItemListNo 
--           NOT IN (select intPromoItemListNo from tblSTPromotionItemList where CAST(intStoreId AS NVARCHAR) IN (CAST(@DestinationStore AS NVARCHAR))) 

--		   set @PromotionItemListAdded = @PromotionItemListAdded + @Itladded

--           --Inserting ItemList Header From to ToStore

--		   INSERT INTO tblSTPromotionItemList (intStoreId,intPromoItemListNo,
--           strPromoItemListId,strPromoItemListDescription,
--           ysnDeleteFromRegister,dtmLastUpdateDate,intConcurrencyId)
--           SELECT @DestinationStore ,intPromoItemListNo,
--           strPromoItemListId,strPromoItemListDescription,
--           ysnDeleteFromRegister, dtmLastUpdateDate, intConcurrencyId from tblSTPromotionItemList 
--           WHERE intStoreId = @FromStore AND intPromoItemListNo BETWEEN @BeginingItemsList AND @EndingItemsList
--	       and intPromoItemListNo NOT IN(select intPromoItemListNo from tblSTPromotionItemList where intStoreId = @DestinationStore)

--         --Inserting ItemList Details From to ToStore

--          INSERT INTO tblSTPromotionItemListDetail (intPromoItemListId,intItemUOMId,
--          strUpcDescription,intUpcModifier,
--          dblRetailPrice, intConcurrencyId)
--	      SELECT 
--	      (SELECT Top 1 adj4.intPromoItemListId FROM tblSTPromotionItemList 
--	      adj4 WHERE adj4.intStoreId = @DestinationStore and adj4.intPromoItemListNo = adj2.intPromoItemListNo) 
--	      as intPromoItemListId,
--	      adj1.intItemUOMId,
--	      adj1.strUpcDescription,adj1.intUpcModifier,
--	      adj1.dblRetailPrice, adj1.intConcurrencyId FROM tblSTPromotionItemListDetail
--	      AS adj1 INNER JOIN tblSTPromotionItemList  AS adj2
--	      ON adj1.intPromoItemListId = adj2.intPromoItemListId and intStoreId = @FromStore
--	      WHERE adj2.intPromoItemListNo in 
--	      (SELECT adj3.intPromoItemListNo FROM tblSTPromotionItemList adj3 WHERE adj3.intStoreId = @DestinationStore)	
--	      AND intPromoItemListNo NOT IN (select intPromoItemListNo from tblSTPromotionItemList as adj11 
--	      INNER JOIN tblSTPromotionItemListDetail
--	      AS adj22 ON adj22.intPromoItemListId = adj11.intPromoItemListId AND intStoreId = @DestinationStore)
--	      AND adj1.intItemUOMId IN (SELECT intItemUOMId FROM tblICItemUOM AS adj3 INNER JOIN 
--	      tblICItemLocation AS adj4 ON adj3.intItemId = adj4.intItemId INNER JOIN 
--	      tblSMCompanyLocation AS adj5 ON adj4.intLocationId = adj5.intCompanyLocationId INNER JOIN 
--	      tblSTStore AS adj6 ON adj5.intCompanyLocationId = adj6.intCompanyLocationId where adj6.intStoreId = @DestinationStore)     


--          SELECT @Cboadded = COUNT(*) from tblSTPromotionSalesList
--	      WHERE intPromoSalesId BETWEEN @BeginingCombo AND @EndingCombo
--	      AND intStoreId = @FromStore and strPromoType = 'C' AND intPromoSalesId NOT IN
--	      (SELECT intPromoSalesId from tblSTPromotionSalesList where intStoreId = @DestinationStore 
--	      and strPromoType = 'C')

--          set @ComboAdded = @ComboAdded + @Cboadded

--          ----Inserting Combo Header From to ToStore

--          INSERT INTO tblSTPromotionSalesList (strPromoType, intStoreId, intPromoSalesId, intCategoryId,
--	      strPromoSalesDescription, strPromoReason, intPromoUnits, dblPromoPrice,
--	      intPromoFeeType, intRegProdId, dtmPromoBegPeriod,
--	      dtmPromoEndPeriod, intPurchaseLimit,
--	      intSalesRestrictCode, ysnPurchaseAtleastMin, ysnPurchaseExactMultiples,ysnRecieptItemSize,
--	      ysnReturnable, ysnFoodStampable, ysnId1Required, ysnId2Required,
--	      ysnDiscountAllowed, ysnBlueLaw1, ysnBlueLaw2, ysnUserTaxFlag1, ysnUserTaxFlag2,
--	      ysnUserTaxFlag3, ysnUserTaxFlag4, ysnDeleteFromRegister, 
--	      ysnSentToRuby, dtmLastUpdateDate, intConcurrencyId) 
--	      SELECT strPromoType, @DestinationStore, intPromoSalesId, intCategoryId,
--	      strPromoSalesDescription, strPromoReason, intPromoUnits, dblPromoPrice,
--	      intPromoFeeType, intRegProdId, dtmPromoBegPeriod,
--	      dtmPromoEndPeriod, intPurchaseLimit,
--	      intSalesRestrictCode, ysnPurchaseAtleastMin, ysnPurchaseExactMultiples,ysnRecieptItemSize,
--	      ysnReturnable, ysnFoodStampable, ysnId1Required, ysnId2Required,
--	      ysnDiscountAllowed, ysnBlueLaw1, ysnBlueLaw2, ysnUserTaxFlag1, ysnUserTaxFlag2,
--	      ysnUserTaxFlag3, ysnUserTaxFlag4, ysnDeleteFromRegister, 
--	      ysnSentToRuby, dtmLastUpdateDate, intConcurrencyId
--	      FROM tblSTPromotionSalesList 
--	      WHERE intStoreId = @FromStore AND intPromoSalesId BETWEEN @BeginingCombo AND @EndingCombo AND strPromoType = 'C'
--	      and intPromoSalesId NOT IN(select intPromoSalesId from tblSTPromotionSalesList where intStoreId = @DestinationStore AND strPromoType = 'C')

--          -----Inserting Combo Details From to ToStore

--		  INSERT INTO tblSTPromotionSalesListDetail (intPromoSalesListId,intPromoItemListId,
--	      intQuantity,dblPrice,intConcurrencyId)
--	      SELECT 
--	      (SELECT TOP 1 adj4.intPromoSalesListId From tblSTPromotionSalesList AS
--	      adj4 Where adj4.intStoreId = @DestinationStore and adj4.intPromoSalesId = adj2.intPromoSalesId AND  adj4.strPromoType = 'C') 
--	      AS intPromoSalesListId,
--	      (SELECT intPromoItemListId FROM tblSTPromotionItemList WHERE intStoreId = @DestinationStore  AND intPromoItemListNo IN 
--          (SELECT intPromoItemListNo FROM tblSTPromotionItemList WHERE intPromoItemListId = adj1.intPromoItemListId )),
--	      adj1.intQuantity,
--	      adj1.dblPrice, adj1.intConcurrencyId FROM tblSTPromotionSalesListDetail
--	      AS adj1 INNER JOIN tblSTPromotionSalesList  AS adj2
--	      ON adj1.intPromoSalesListId = adj2.intPromoSalesListId and intStoreId = @FromStore and strPromoType = 'C'
--	      INNER JOIN tblSTPromotionItemList as adj5 ON adj1.intPromoItemListId = adj5.intPromoItemListId
--	      WHERE adj2.intPromoSalesId in 
--	      (SELECT adj3.intPromoSalesId FROM tblSTPromotionSalesList adj3 WHERE adj3.intStoreId = @DestinationStore and adj3.strPromoType = 'C')	
--          AND intPromoSalesId NOT IN (select intPromoSalesId from tblSTPromotionSalesList as adj11 INNER JOIN tblSTPromotionSalesListDetail
--	      AS adj22 ON adj22.intPromoSalesListId = adj11.intPromoSalesListId AND intStoreId = @DestinationStore and adj11.strPromoType = 'C')
--	      AND adj5.intPromoItemListNo BETWEEN @BeginingItemsList AND @EndingItemsList


--          SELECT @Mxmadded = COUNT(*) from tblSTPromotionSalesList
--	      WHERE intPromoSalesId BETWEEN @BeginingMixMatchID AND @EndingMixMatchID
--	      AND intStoreId = @FromStore and strPromoType = 'M' AND intPromoSalesId NOT IN
--	     (SELECT intPromoSalesId from tblSTPromotionSalesList where intStoreId = @DestinationStore 
--	      and strPromoType = 'M')

--          set @MixMatchAdded = @MixMatchAdded + @Mxmadded

--         ----Inserting MixMatch Header From to ToStore

--         INSERT INTO tblSTPromotionSalesList (strPromoType, intStoreId, intPromoSalesId, intCategoryId,
-- 	     strPromoSalesDescription, strPromoReason, intPromoUnits, dblPromoPrice,
--	     intPromoFeeType, intRegProdId,  dtmPromoBegPeriod,
--	     dtmPromoEndPeriod,  intPurchaseLimit,
--	     intSalesRestrictCode, ysnPurchaseAtleastMin, ysnPurchaseExactMultiples,ysnRecieptItemSize,
--	     ysnReturnable, ysnFoodStampable, ysnId1Required, ysnId2Required,
--	     ysnDiscountAllowed, ysnBlueLaw1, ysnBlueLaw2, ysnUserTaxFlag1, ysnUserTaxFlag2,
--	     ysnUserTaxFlag3, ysnUserTaxFlag4, ysnDeleteFromRegister, 
--	     ysnSentToRuby, dtmLastUpdateDate, intConcurrencyId) 
--	     SELECT strPromoType, @DestinationStore, intPromoSalesId, intCategoryId,
--	     strPromoSalesDescription, strPromoReason, intPromoUnits, dblPromoPrice,
--	     intPromoFeeType, intRegProdId,  dtmPromoBegPeriod,
--	     dtmPromoEndPeriod,  intPurchaseLimit,
--	     intSalesRestrictCode, ysnPurchaseAtleastMin, ysnPurchaseExactMultiples,ysnRecieptItemSize,
--	     ysnReturnable, ysnFoodStampable, ysnId1Required, ysnId2Required,
--	     ysnDiscountAllowed, ysnBlueLaw1, ysnBlueLaw2, ysnUserTaxFlag1, ysnUserTaxFlag2,
--	     ysnUserTaxFlag3, ysnUserTaxFlag4, ysnDeleteFromRegister, 
--	     ysnSentToRuby, dtmLastUpdateDate, intConcurrencyId
--	     FROM tblSTPromotionSalesList 
--	     WHERE intStoreId = @FromStore AND intPromoSalesId BETWEEN @BeginingMixMatchID AND @EndingMixMatchID AND strPromoType = 'M'
--	     and intPromoSalesId NOT IN(select intPromoSalesId from tblSTPromotionSalesList where intStoreId = @DestinationStore AND strPromoType = 'M')

--         ----Inserting MixMatch Details From to ToStore
 
--         INSERT INTO tblSTPromotionSalesListDetail (intPromoSalesListId,intPromoItemListId,
--	     intQuantity,dblPrice,intConcurrencyId)
--	     SELECT 
--	     (SELECT TOP 1 adj4.intPromoSalesListId From tblSTPromotionSalesList AS
--	     adj4 Where adj4.intStoreId = @DestinationStore and adj4.intPromoSalesId = adj2.intPromoSalesId  AND adj4.strPromoType = 'M') 
--	     AS intPromoSalesListId,
--	     (SELECT intPromoItemListId FROM tblSTPromotionItemList WHERE intStoreId = @DestinationStore AND intPromoItemListNo IN
--         (SELECT intPromoItemListNo FROM tblSTPromotionItemList WHERE intPromoItemListId = adj1.intPromoItemListId)),
--	     adj1.intQuantity,
--	     adj1.dblPrice, adj1.intConcurrencyId FROM tblSTPromotionSalesListDetail 
--	     AS adj1 INNER JOIN tblSTPromotionSalesList  AS adj2
-- 	     ON adj1.intPromoSalesListId = adj2.intPromoSalesListId and intStoreId = @FromStore and strPromoType = 'M'
--	     INNER JOIN tblSTPromotionItemList as adj5 ON adj1.intPromoItemListId = adj5.intPromoItemListId
--	     WHERE adj2.intPromoSalesId in 
--	     (SELECT adj3.intPromoSalesId FROM tblSTPromotionSalesList adj3 WHERE adj3.intStoreId = @DestinationStore and adj3.strPromoType = 'M')	
--	     AND intPromoSalesId NOT IN (SELECT intPromoSalesId FROM tblSTPromotionSalesList AS adj11 INNER JOIN tblSTPromotionSalesListDetail
--	     AS adj22 ON adj22.intPromoSalesListId = adj11.intPromoSalesListId AND intStoreId = @DestinationStore and adj11.strPromoType = 'M')
--	     AND adj5.intPromoItemListNo BETWEEN @BeginingItemsList AND @EndingItemsList

--	    SELECT @DataKey = MIN(DataKey)
--		      FROM @tempTble
--		       Where DataKey>@DataKey

--	  END	  

--	  IF (@ReplaceDuplicateRecordsysn = 'Y')
--	  BEGIN

--	     SET @ComboAdded = @ComboAdded- @ComboReplaced 

--		 IF @ComboAdded < 0
--		 BEGIN
--		    SET @ComboAdded = @ComboAdded * -1
--		 END

--		 IF @ComboReplaced < 0
--		 BEGIN
--		    SET @ComboReplaced = @ComboReplaced * -1
--		 END

--		 set @MixMatchAdded = @MixMatchAdded- @MixMatchReplaced 

--		 IF @MixMatchAdded < 0
--		 BEGIN
--		    SET @MixMatchAdded = @MixMatchAdded * -1
--		 END

--		 IF @MixMatchReplaced < 0
--		 BEGIN
--		    SET @MixMatchReplaced = @MixMatchReplaced * -1
--		 END

--	     SET @PromotionItemListAdded = @PromotionItemListAdded - @PromoItemListReplaced

--		 IF @PromotionItemListAdded < 0
--		 BEGIN
--		    SET @PromotionItemListAdded = @PromotionItemListAdded * -1
--		 END

--		 IF @PromoItemListReplaced < 0
--		 BEGIN
--		    SET @PromoItemListReplaced = @PromoItemListReplaced * -1
--		 END

--	  END

--	  SELECT @PromotionItemListAdded AS PromotionItemListAdded, @PromoItemListReplaced AS PromoItemListReplaced,
--	  @ComboAdded AS ComboAdded, @ComboReplaced As ComboReplaced,
--	  @MixMatchAdded AS MixMatchAdded, @MixMatchReplaced AS MixMatchReplaced
--END