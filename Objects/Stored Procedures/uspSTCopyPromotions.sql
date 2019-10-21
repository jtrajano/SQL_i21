CREATE PROCEDURE [dbo].[uspSTCopyPromotions]
   @XML VARCHAR(max)
AS
BEGIN TRY

	 BEGIN TRANSACTION

     DECLARE @ErrMsg				 	  NVARCHAR(MAX),
	         @idoc				          INT,
	     	 @intFromStoreId              INT,
	         @ToStore                     NVARCHAR(MAX),
			 @intBeginningComboID         INT,
			 @intEndingComboID            INT,
             @intBeginingMixMatchID       INT,
			 @intEndingMixMatchID         INT,
			 @intBeginningItemsListNo     INT,
			 @intEndingItemsListNo        INT,
	  		 @ReplaceDuplicateRecordsysn  NVARCHAR(1),
			 @intUserEntityId			  INT,

			 @intItemListAddedCount       INT,
			 @Itlreplaced                 INT,
			 @intComboListAddedCount      INT,
			 @intComboReplacedCount       INT, 
			 @intMixMatchAddedCount       INT,
			 @intMixMatchReplacedCount    INT,
		     @intPromotionItemListAdded   INT,
			 @intPromoItemListReplaced    INT,
			 @intComboAdded               INT,
			 @intComboReplaced            INT,
			 @intMixMatchAdded            INT,
			 @intMixMatchReplaced         INT,

			 @intPromotionItemListId		INT,
			 @intPromotionComboListId       INT,
			 @intPromotionMixMatchListId	INT,
			 @intNewPromotionITEMListId		INT,
			 @intNewPromotionCOMBOListId    INT,
			 @intNewPromotionMIXMATCHListId    INT,

			 @strStatusMsg				 NVARCHAR(1000) = ''

    EXEC sp_xml_preparedocument @idoc OUTPUT, @XML 

    SELECT	
			@intFromStoreId		            =	FromStore,
            @ToStore						=   ToStore,
			@intBeginningComboID            =   BeginingCombo,
			@intEndingComboID               =   EndingCombo,
            @intBeginingMixMatchID          =   BeginingMixMatchID,
            @intEndingMixMatchID            =   EndingMixMatchID,
			@intBeginningItemsListNo        =   BeginingItemsList,
			@intEndingItemsListNo           =   EndingItemsList,
			@ReplaceDuplicateRecordsysn     =   ReplaceDuplicateRecordsysn,
			@intUserEntityId			    =   intUserEntityId
			
		
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
			ReplaceDuplicateRecordsysn    NVARCHAR(1),
			intUserEntityId				  INT
			
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
	 DECLARE @temptblPromoITEMList TABLE (
											intPrimaryID INT IDENTITY(1, 1),
											intPromoItemListId INT,
											intPromoItemListNo INT
										 );

	 -- COMBO LIST
	 DECLARE @temptblPromoCOMBOList TABLE (
											intPrimaryID INT IDENTITY(1, 1),
											intPromoComboSalesId INT 
										 );

	 -- MIX-MATCH LIST
	 DECLARE @temptblPromoMIXMATCHList TABLE (
											intPrimaryID INT IDENTITY(1, 1),
											intPromoMixMatchSalesId INT 
										 );
	 -- =========================================================================
	 -- [END] - Create Temporary Tables
	 -- =========================================================================




	 -- =========================================================================
	 -- [START] - POPULATE TEMP TABLES
	 -- =========================================================================
	 -- NOTE: if No Combo, Mix-Match or Item-List then include ALL

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
	 

	 -- Insert All Promotion ITEM to temp table
	 INSERT INTO @temptblPromoITEMList 
	 (
		intPromoItemListId
		, intPromoItemListNo
	 )
	 SELECT intPromoItemListId
			, intPromoItemListNo
	 FROM tblSTPromotionItemList 
	 WHERE intPromoItemListNo BETWEEN @intBeginningItemsListNo AND @intEndingItemsListNo
		AND intStoreId = @intFromStoreId
	
	
	 -- Insert All Promotion COMBO to temp table
	 INSERT INTO @temptblPromoCOMBOList 
	 (
		intPromoComboSalesId
	 )
	 SELECT intPromoSalesId 
	 FROM tblSTPromotionSalesList 
	 WHERE  intPromoSalesId BETWEEN @intBeginningComboID AND @intEndingComboID
			AND intStoreId = @intFromStoreId 
			AND strPromoType = 'C'
	

	 -- Insert All Promotion MIX-MATCH to temp table
	 INSERT INTO @temptblPromoMIXMATCHList 
	 (
				intPromoMixMatchSalesId
	 )
	 SELECT intPromoSalesId 
	 FROM tblSTPromotionSalesList 
	 WHERE intPromoSalesId BETWEEN @intBeginingMixMatchID AND @intEndingMixMatchID
		AND intStoreId = @intFromStoreId 
		AND strPromoType = 'M'
	
	-- =========================================================================
	-- [END] - POPULATE TEMP TABLES
	-- =========================================================================


----TEST
--SELECT '@temptblStore', * FROM @temptblStore
--SELECT '@temptblPromoITEMList', * FROM @temptblPromoITEMList
--SELECT '@temptblPromoCOMBOList', * FROM @temptblPromoCOMBOList
--SELECT '@temptblPromoMIXMATCHList', * FROM @temptblPromoMIXMATCHList

	  DECLARE @intPrimaryID INT
	         , @intCOMBOPrimaryID INT
			 , @intMIXMATCHPrimaryID INT
			 , @intITEMListPrimaryID INT

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

-- TEST
--SELECT 'intStoreId', @intStoreId

					 -- ==================================================================================
					 -- [START] - COMBO PROMOTIONS
					 -- ==================================================================================
					 
					 --IF(@intBeginningComboID != 0 AND @intEndingComboID != 2147483647)
					 IF EXISTS(SELECT TOP 1 1 FROM @temptblPromoCOMBOList)
						BEGIN
							
							 IF EXISTS(
										 SELECT TOP 1 1 
										 FROM tblSTPromotionSalesList
										 WHERE intPromoSalesId IN (SELECT temp.intPromoComboSalesId FROM @temptblPromoCOMBOList temp)
											AND intStoreId = @intStoreId
											AND strPromoType = 'C'
									  )
								BEGIN

									 -- COUNT Combo Replaced
									 SELECT @intComboReplacedCount = COUNT(*) 
									 FROM tblSTPromotionSalesList
									 WHERE intPromoSalesId IN (SELECT temp.intPromoComboSalesId FROM @temptblPromoCOMBOList temp)
										AND intStoreId = @intStoreId
										AND strPromoType = 'C'

									 SET @intComboReplaced = @intComboReplaced + @intComboReplacedCount



									 -- ==========================================================================
									 -- [START] - AUDIT LOG - Mark as Deleted
									 -- ==========================================================================
									 --DECLARE @strPromoCOMBOListIds AS NVARCHAR(1000) = STUFF((
										--														SELECT ',' + CAST(CL.intPromoSalesListId AS NVARCHAR(50)) 
										--														FROM tblSTPromotionSalesList CL
										--														WHERE intPromoSalesId IN (SELECT temp.intPromoComboSalesId FROM @temptblPromoCOMBOList temp)
										--															AND CL.intStoreId = @intStoreId 
										--															AND CL.strPromoType = 'C'
										--														FOR XML PATH('')
										--													 ) ,1,1,'')
									 
									 -- Get the lowest primary id
									 DECLARE @intLoopCOMBOPrimaryId AS INT = 0

									 SELECT @intLoopCOMBOPrimaryId = MIN(intPrimaryID)
									 FROM @temptblPromoCOMBOList

									 -- Loop through all records
									 WHILE (@intLoopCOMBOPrimaryId > 0)
										BEGIN

										   EXEC dbo.uspSMAuditLog 
												@screenName				=		'Store.view.PromotionSales'		    -- Screen Namespace
												,@keyValue				=		@intLoopCOMBOPrimaryId				-- Primary Key Value of the Voucher. 
												,@entityId				=		@intUserEntityId					-- Entity Id.
												,@actionType			=		'Deleted'							-- Action Type
							    				,@actionIcon			=		'small-new-minus'					-- 'small-menu-maintenance', 'small-new-plus', 'small-new-minus',
												,@changeDescription		=		''									-- Description
												,@fromValue				=		''									-- Previous Value
												,@toValue				=		''									-- New Value

										   -- Use the next primary ID
										   SET @intLoopCOMBOPrimaryId = @intLoopCOMBOPrimaryId + 1
										   IF NOT EXISTS(SELECT TOP 1 1 FROM @temptblPromoCOMBOList WHERE intPrimaryID = @intLoopCOMBOPrimaryId)
												BEGIN
													SET @intLoopCOMBOPrimaryId = 0 -- This will exit the loop
												END

										END
									 -- ==========================================================================
									 -- [START] - AUDIT LOG - Mark as Deleted
									 -- ==========================================================================



									 -- DELETE table PromotionSalesList if already existing
									 DELETE FROM tblSTPromotionSalesList 
									 WHERE intPromoSalesId IN (SELECT temp.intPromoComboSalesId FROM @temptblPromoCOMBOList temp)
										AND intStoreId = @intStoreId
										AND strPromoType = 'C'

								END

						END

					 -- ==================================================================================
					 -- [END] - COMBO PROMOTIONS
					 -- ==================================================================================





					 -- ==================================================================================
					 -- [START] - MIX-MATCH PROMOTIONS
					 -- ==================================================================================

					 --IF(@intBeginingMixMatchID != 0 AND @intEndingMixMatchID != 2147483647)
					 IF EXISTS(SELECT TOP 1 1 FROM @temptblPromoMIXMATCHList)
						BEGIN

							 IF EXISTS(
											SELECT TOP 1 1 
											FROM tblSTPromotionSalesList  
											WHERE intPromoSalesId IN (SELECT temp.intPromoMixMatchSalesId FROM @temptblPromoMIXMATCHList temp)
												AND intStoreId = @intStoreId
												AND strPromoType = 'M' 
							          )
								BEGIN

									 -- COUNT Mix-Match Replaced
									 SELECT @intMixMatchReplacedCount = COUNT(*) 
									 FROM tblSTPromotionSalesList  
									 WHERE intPromoSalesId IN (SELECT temp.intPromoMixMatchSalesId FROM @temptblPromoMIXMATCHList temp)
										AND intStoreId = @intStoreId
										AND strPromoType = 'M'	 
									 
									 SET @intMixMatchReplaced = @intMixMatchReplaced + @intMixMatchReplacedCount



									 -- ==========================================================================
									 -- [START] - AUDIT LOG - Mark as Deleted
									 -- ==========================================================================
									 --DECLARE @strPromoMIXMATCHListIds AS NVARCHAR(1000) = STUFF((
										--														SELECT ',' + CAST(SL.intPromoSalesListId AS NVARCHAR(50)) 
										--														FROM tblSTPromotionSalesList SL
										--														WHERE intPromoSalesId IN (SELECT temp.intPromoMixMatchSalesId FROM @temptblPromoMIXMATCHList temp)
										--															AND SL.intStoreId = @intStoreId 
										--															AND SL.strPromoType = 'M'
										--														FOR XML PATH('')
										--													 ) ,1,1,'')

									 -- Get the lowest primary id
									 DECLARE @intLoopMIXMATCHPrimaryId AS INT = 0

									 SELECT @intLoopMIXMATCHPrimaryId = MIN(intPrimaryID)
									 FROM  @temptblPromoMIXMATCHList

									 -- Loop through all records
									 WHILE (@intLoopMIXMATCHPrimaryId > 0)
										BEGIN

										   EXEC dbo.uspSMAuditLog 
												@screenName				=		'Store.view.PromotionSales'		    -- Screen Namespace
												,@keyValue				=		@intLoopMIXMATCHPrimaryId			-- Primary Key Value of the Voucher. 
												,@entityId				=		@intUserEntityId					-- Entity Id.
												,@actionType			=		'Deleted'							-- Action Type
							    				,@actionIcon			=		'small-new-minus'					-- 'small-menu-maintenance', 'small-new-plus', 'small-new-minus',
												,@changeDescription		=		''									-- Description
												,@fromValue				=		''									-- Previous Value
												,@toValue				=		''									-- New Value

										   -- Use the next primary ID
										   SET @intLoopMIXMATCHPrimaryId = @intLoopMIXMATCHPrimaryId + 1
										   IF NOT EXISTS(SELECT TOP 1 1 FROM @temptblPromoMIXMATCHList WHERE intPrimaryID = @intLoopMIXMATCHPrimaryId)
												BEGIN
													SET @intLoopMIXMATCHPrimaryId = 0 -- This will exit the loop
												END

										END
									 -- ==========================================================================
									 -- [START] - AUDIT LOG - Mark as Deleted
									 -- ==========================================================================



									 DELETE FROM tblSTPromotionSalesList 
									 WHERE intPromoSalesId IN (SELECT temp.intPromoMixMatchSalesId FROM @temptblPromoMIXMATCHList temp)
										AND intStoreId = @intStoreId 
										AND strPromoType = 'M'

								END
							 
						END
					 
					 -- ==================================================================================
					 -- [END] - MIX-MATCH PROMOTIONS
					 -- ==================================================================================





					 -- ==================================================================================
					 -- [START] - ITEM LIST PROMOTIONS
					 -- ==================================================================================

					 --IF(@intBeginningItemsListNo != 0 AND @intEndingItemsListNo != 2147483647)
					 IF EXISTS(SELECT TOP 1 1 FROM @temptblPromoITEMList)
						BEGIN
							 
							 IF EXISTS(
									     SELECT TOP 1 1
									     FROM tblSTPromotionItemList 
									     WHERE intPromoItemListNo IN (SELECT temp.intPromoItemListNo FROM @temptblPromoITEMList temp)
											AND intStoreId = @intStoreId
							          )
								BEGIN

									 -- COUNT Item-List Replaced
									 SELECT @Itlreplaced = COUNT(*) 
									 FROM tblSTPromotionItemList 
									 WHERE intPromoItemListNo IN (SELECT temp.intPromoItemListNo FROM @temptblPromoITEMList temp)
										AND intStoreId = @intStoreId

									 SET @intPromoItemListReplaced  = @intPromoItemListReplaced + @Itlreplaced
								
									 -- ==========================================================================
									 -- [START] - AUDIT LOG - Mark as Deleted
									 -- ==========================================================================
									 --DECLARE @strPromoITEMListIds AS NVARCHAR(1000) = STUFF((
										--														SELECT ',' + CAST(IL.intPromoItemListId AS NVARCHAR(50)) 
										--														FROM tblSTPromotionItemList IL
										--														WHERE intPromoItemListNo IN (SELECT temp.intPromoItemListNo FROM @temptblPromoITEMList temp)
										--															AND IL.intStoreId = @intStoreId 
										--														FOR XML PATH('')
										--												   ) ,1,1,'')

									 -- Get the lowest primary id
									 DECLARE @intLoopITEMPrimaryId AS INT = 0

									 SELECT @intLoopITEMPrimaryId = MIN(intPrimaryID)
									 FROM  @temptblPromoITEMList

									 -- Loop through all records
									 WHILE (@intLoopITEMPrimaryId > 0)
										BEGIN

										   EXEC dbo.uspSMAuditLog 
											   @screenName			=		'Store.view.PromotionItemList'		-- Screen Namespace
											  ,@keyValue			=		@intLoopITEMPrimaryId				-- Primary Key Value of the Voucher. 
											  ,@entityId			=		@intUserEntityId					-- Entity Id.
											  ,@actionType			=		'Deleted'							-- Action Type
											  ,@actionIcon			=		'small-new-minus'					-- 'small-menu-maintenance', 'small-new-plus', 'small-new-minus',
											  ,@changeDescription	=		''									-- Description
											  ,@fromValue			=		''									-- Previous Value
											  ,@toValue				=		''									-- New Value

										   -- Use the next primary ID
										   SET @intLoopITEMPrimaryId = @intLoopITEMPrimaryId + 1
										   IF NOT EXISTS(SELECT TOP 1 1 FROM @temptblPromoITEMList WHERE intPrimaryID = @intLoopITEMPrimaryId)
												BEGIN
													SET @intLoopITEMPrimaryId = 0 -- This will exit the loop
												END

										END

									
									 -- ==========================================================================
									 -- [START] - AUDIT LOG - Mark as Deleted
									 -- ==========================================================================

									 DELETE FROM tblSTPromotionItemList 
									 WHERE intPromoItemListNo IN (SELECT temp.intPromoItemListNo FROM @temptblPromoITEMList temp)
										AND intStoreId = @intStoreId 
								END

							 
						END
					 
					 -- ==================================================================================
					 -- [END] - ITEM LIST PROMOTIONS
					 -- ==================================================================================



					 SET @intPrimaryID = @intPrimaryID + 1
					 IF NOT EXISTS(SELECT TOP 1 1 FROM @temptblStore WHERE intPrimaryID = @intPrimaryID)
						BEGIN
							SET @intPrimaryID = 0 -- This will exit the loop
						END
					 --SELECT @intPrimaryID = MIN(intPrimaryID)
					 --FROM @temptblStore
					 --WHERE intPrimaryID > @intPrimaryID
   				  END	  

			  -- ==================================================================================
			  -- [END] - COMPUTE REPLACE COUNT AND DELETE EXISTING SALES PROMOTION
			  -- ==================================================================================
		 END





	 

	 SELECT @intPrimaryID = MIN(intPrimaryID)
	 FROM @temptblStore

--PRINT '[START] - CLONE PROMOTIONS'

	 -- ===========================================================================================
	 -- [START] - CLONE PROMOTIONS
	 -- ===========================================================================================

	 WHILE (@intPrimaryID > 0)
		BEGIN
		   
		   -- GET 'intStoreId'
		   SELECT @intStoreId = intStoreId  
		   FROM @temptblStore
		   WHERE intPrimaryID = @intPrimaryID

---- TEST
--SELECT 'intStoreId', @intStoreId, 'Primary ID', @intPrimaryID

--PRINT '[START] - ITEM LIST PROMOTIONS'
		   -- ======================================================================================
		   -- [START] - ITEM LIST PROMOTIONS
		   -- ======================================================================================
		   
		   IF EXISTS(SELECT TOP 1 1 FROM @temptblPromoITEMList)
				BEGIN

				   SELECT 
						@intItemListAddedCount = COUNT(intPromoItemListId) 
				   FROM tblSTPromotionItemList
				   WHERE intPromoItemListId IN (SELECT temp.intPromoItemListId FROM @temptblPromoITEMList temp)
						AND intStoreId = @intFromStoreId 


				   SET @intPromotionItemListAdded = @intPromotionItemListAdded + @intItemListAddedCount
					
				   -- ====================================================================================================================
				   -- [START] - Loop to all PROMOTION ITEM LIST
				   -- ====================================================================================================================

				   -- Loop to all the Promotion List to be inserted to all From: intStoreId's
				   SELECT @intITEMListPrimaryID = MIN(intPrimaryID)
				   FROM @temptblPromoITEMList

				   WHILE (@intITEMListPrimaryID > 0) --EXISTS (SELECT TOP (1) 1 FROM @temptblPromoITEMList)
						BEGIN
							SELECT TOP 1 @intPromotionItemListId = intPromoItemListId FROM @temptblPromoITEMList WHERE intPrimaryID = @intITEMListPrimaryID


							IF EXISTS(
										SELECT TOP 1 1 
										FROM tblSTPromotionItemList ItemList
										WHERE ItemList.intStoreId = @intFromStoreId 
											AND ItemList.intPromoItemListId = @intPromotionItemListId
									 )
								BEGIN

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
									SET @intNewPromotionITEMListId = SCOPE_IDENTITY();



									-- ==========================================================================
									-- [START] - AUDIT LOG - Mark as Created
									-- ==========================================================================
									-- SET @strPromoITEMListIds = CAST(@intNewPromotionITEMListId AS NVARCHAR(50))

									EXEC dbo.uspSMAuditLog 
										   @screenName			=		'Store.view.PromotionItemList'		-- Screen Namespace
										  ,@keyValue			=		@intNewPromotionITEMListId			-- Primary Key Value of the Voucher. 
										  ,@entityId			=		@intUserEntityId					-- Entity Id.
										  ,@actionType			=		'Created'							-- Action Type
										  ,@actionIcon			=		'small-new-plus'					-- 'small-menu-maintenance', 'small-new-plus', 'small-new-minus',
										  ,@changeDescription	=		'Created by Copy Promotion screen'	-- Description
										  ,@fromValue			=		''									-- Previous Value
										  ,@toValue				=		''									-- New Value
									-- ==========================================================================
									-- [START] - AUDIT LOG - Mark as Created
									-- ==========================================================================




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
										@intNewPromotionITEMListId
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

								END
							



							SET @intITEMListPrimaryID = @intITEMListPrimaryID + 1
						    IF NOT EXISTS(SELECT TOP 1 1 FROM @temptblPromoITEMList WHERE intPrimaryID = @intITEMListPrimaryID)
								BEGIN
									SET @intITEMListPrimaryID = 0 -- This will exit the loop
								END
							-- DELETE TOP (1) FROM @temptblPromoITEMList
						END
			   
				   -- ====================================================================================================================
				   -- [END] - Loop to all PROMOTION ITEM LIST
				   -- ====================================================================================================================

				END

           -- ======================================================================================
		   -- [END] - ITEM LIST PROMOTIONS
		   -- ======================================================================================




--PRINT '[START] - COMBO LIST'
		   -- ======================================================================================
		   -- [START] - COMBO LIST
		   -- ======================================================================================

		   IF EXISTS(SELECT TOP 1 1 FROM @temptblPromoCOMBOList)
				BEGIN

				   SELECT 
						@intComboListAddedCount = COUNT(intPromoSalesId) 
				   FROM tblSTPromotionSalesList
				   WHERE intPromoSalesId IN (SELECT temp.intPromoComboSalesId FROM @temptblPromoCOMBOList temp)
						AND intStoreId = @intFromStoreId
						AND strPromoType = 'C'

				   SET @intComboAdded = @intComboAdded + @intComboListAddedCount

				   -- ====================================================================================================================
				   -- [START] - Loop to all PROMOTION COMBO LIST
				   -- ====================================================================================================================
				   SELECT @intCOMBOPrimaryID = MIN(intPrimaryID)
				   FROM @temptblPromoCOMBOList

				   WHILE (@intCOMBOPrimaryID > 0) --EXISTS (SELECT TOP (1) 1 FROM @temptblPromoCOMBOList)
						BEGIN
							
						   SELECT TOP 1 @intPromotionComboListId = intPromoComboSalesId FROM @temptblPromoCOMBOList WHERE intPrimaryID = @intCOMBOPrimaryID

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
						   WHERE intPromoSalesId = @intPromotionComboListId --IN (SELECT intPromoComboSalesId FROM @temptblPromoCOMBOList)
								AND intStoreId = @intFromStoreId 
								AND strPromoType = 'C'

						   -- Get new primary ID
						   SET @intNewPromotionCOMBOListId = SCOPE_IDENTITY();

						   -- ==========================================================================
						   -- [START] - AUDIT LOG - Mark as Created
						   -- ==========================================================================
						   -- SET @strPromoCOMBOListIds = CAST(@intNewPromotionCOMBOListId AS NVARCHAR(50))
						   EXEC dbo.uspSMAuditLog 
									@screenName				=		'Store.view.PromotionSales'		    -- Screen Namespace
									,@keyValue				=		@intNewPromotionCOMBOListId			-- Primary Key Value of the Voucher. 
									,@entityId				=		@intUserEntityId					-- Entity Id.
									,@actionType			=		'Created'							-- Action Type
									,@actionIcon			=		'small-new-plus'					-- 'small-menu-maintenance', 'small-new-plus', 'small-new-minus',
									,@changeDescription		=		''									-- Description
									,@fromValue				=		''									-- Previous Value
									,@toValue				=		''									-- New Value
						   -- ==========================================================================
						   -- [END] - AUDIT LOG - Mark as Created
						   -- ==========================================================================

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
								 @intNewPromotionCOMBOListId AS intPromoSalesListId
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



						    SET @intCOMBOPrimaryID = @intCOMBOPrimaryID + 1
						    IF NOT EXISTS(SELECT TOP 1 1 FROM @temptblPromoCOMBOList WHERE intPrimaryID = @intCOMBOPrimaryID)
								BEGIN
									SET @intCOMBOPrimaryID = 0 -- This will exit the loop
								END
						   -- DELETE TOP (1) FROM @temptblPromoCOMBOList
						END
				   
				  -- ====================================================================================================================
				   -- [START] - Loop to all PROMOTION COMBO LIST
				   -- ====================================================================================================================
				END         

		   -- ======================================================================================
		   -- [START] - COMBO LIST
		   -- ======================================================================================
--PRINT '[END] - COMBO LIST'



--PRINT '[START] - MIX-MATCH LIST'
		   -- ======================================================================================
		   -- [START] - MIX-MATCH LIST
		   -- ======================================================================================

		   IF EXISTS(SELECT TOP 1 1 FROM @temptblPromoMIXMATCHList)
				BEGIN

				   SELECT 
						@intMixMatchAddedCount = COUNT(intPromoSalesId) 
				   FROM tblSTPromotionSalesList
				   WHERE intPromoSalesId IN (SELECT temp.intPromoMixMatchSalesId FROM @temptblPromoMIXMATCHList temp)
						AND intStoreId = @intFromStoreId
						AND strPromoType = 'M'

--PRINT '@intMixMatchAddedCount: ' + CAST(@intMixMatchAddedCount AS NVARCHAR(50))

				   SET @intMixMatchAdded = @intMixMatchAdded + @intMixMatchAddedCount

				   -- ====================================================================================================================
				   -- [START] - Loop to all PROMOTION MIX_MATCH LIST
				   -- ====================================================================================================================
				   SELECT @intMIXMATCHPrimaryID = MIN(intPrimaryID)
				   FROM @temptblPromoMIXMATCHList

				   WHILE (@intMIXMATCHPrimaryID > 0) --EXISTS (SELECT TOP (1) 1 FROM @temptblPromoMIXMATCHList)
						BEGIN
							
						   SELECT TOP 1 @intPromotionMixMatchListId = intPromoMixMatchSalesId FROM @temptblPromoMIXMATCHList WHERE intPrimaryID = @intMIXMATCHPrimaryID

--PRINT '@intPromotionMixMatchListId: ' + CAST(@intPromotionMixMatchListId AS NVARCHAR(50))

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
								, ISNULL(intPromoUnits, 0)
								, ISNULL(dblPromoPrice, 0)
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
								AND strPromoType = 'M'
						   
						   -- Get new primary ID
						   SET @intNewPromotionMIXMATCHListId = SCOPE_IDENTITY();

--PRINT '@intNewPromotionMIXMATCHListId: ' + CAST(@intNewPromotionMIXMATCHListId AS NVARCHAR(50))

						   -- ==========================================================================
						   -- [START] - AUDIT LOG - Mark as Created
						   -- ==========================================================================
						   -- SET @strPromoMIXMATCHListIds = @intNewPromotionMIXMATCHListId
						   BEGIN TRY
						   EXEC dbo.uspSMAuditLog 
									@screenName				=		'Store.view.PromotionSales'		    -- Screen Namespace
									,@keyValue				=		@intNewPromotionMIXMATCHListId		-- Primary Key Value of the Voucher. 
									,@entityId				=		@intUserEntityId					-- Entity Id.
									,@actionType			=		'Created'							-- Action Type
							    	,@actionIcon			=		'small-new-minus'					-- 'small-menu-maintenance', 'small-new-plus', 'small-new-minus',
									,@changeDescription		=		''									-- Description
									,@fromValue				=		''									-- Previous Value
									,@toValue				=		''									-- New Value
							END TRY
							BEGIN CATCH
								SET @strStatusMsg = 'Script Error: ' + ERROR_MESSAGE()

								-- ROLLBACK
								GOTO ExitWithRollback
							END CATCH
							-- ==========================================================================
							-- [START] - AUDIT LOG - Mark as Created
							-- ==========================================================================



						   -----Inserting Mix-Match Details From to ToStore
						   INSERT INTO tblSTPromotionSalesListDetail 
						   (
								intPromoSalesListId
								, intPromoItemListId
								, intQuantity
								, dblPrice
								, intConcurrencyId
						   )
						   SELECT DISTINCT
								 @intNewPromotionMIXMATCHListId AS intPromoSalesListId
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


						   SET @intMIXMATCHPrimaryID = @intMIXMATCHPrimaryID + 1
						   IF NOT EXISTS(SELECT TOP 1 1 FROM @temptblPromoMIXMATCHList WHERE intPrimaryID = @intMIXMATCHPrimaryID)
								BEGIN
									SET @intMIXMATCHPrimaryID = 0 -- This will exit the loop
								END
						   -- DELETE TOP (1) FROM @temptblPromoMIXMATCHList
						END
				   
				  -- ====================================================================================================================
				   -- [START] - Loop to all PROMOTION MIX_MATCH LIST
				   -- ====================================================================================================================
				END  

		   -- ======================================================================================
		   -- [END] - MIX-MATCH LIST
		   -- ======================================================================================
--PRINT '[END] - MIX-MATCH LIST'


		   SET @intPrimaryID = @intPrimaryID + 1
		   IF NOT EXISTS(SELECT TOP 1 1 FROM @temptblStore WHERE intPrimaryID = @intPrimaryID)
				BEGIN
					SET @intPrimaryID = 0 -- This will exit the loop
				END

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