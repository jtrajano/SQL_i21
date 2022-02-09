CREATE PROCEDURE [dbo].[uspSTCopyPromotions]
   @XML VARCHAR(max)
AS
BEGIN TRY

	 BEGIN TRANSACTION
	 BEGIN TRY

     DECLARE @ErrMsg				 	  NVARCHAR(MAX),
	         @idoc				          INT,
	     	 @intFromStoreId              INT,
	         @ToStore                     NVARCHAR(MAX),
	         @ToStoreGroup                NVARCHAR(MAX),
			@intBeginningComboID         NVARCHAR(MAX),
			 --@intEndingComboID            INT,
             @intBeginingMixMatchID       NVARCHAR(MAX),
			 --@intEndingMixMatchID         INT,
			 @intBeginningItemsListNo     NVARCHAR(MAX),
			-- @intEndingItemsListNo        INT,
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
            @ToStoreGroup					=   ToStoreGroup,
			@intBeginningComboID            =   BeginingCombo,
			--@intEndingComboID               =   EndingCombo,
            @intBeginingMixMatchID          =   BeginingMixMatchID,
            --@intEndingMixMatchID            =   EndingMixMatchID,
			@intBeginningItemsListNo        =   BeginingItemsList,
			--@intEndingItemsListNo           =   EndingItemsList,
			@ReplaceDuplicateRecordsysn     =   ReplaceDuplicateRecordsysn,
			@intUserEntityId			    =   intUserEntityId
			
		
	FROM	OPENXML(@idoc, 'root',2)
	WITH
	(
			FromStore		              INT,
			ToStore	     	              NVARCHAR(MAX),
			ToStoreGroup	     	      NVARCHAR(MAX),
			BeginingCombo		           NVARCHAR(MAX),
			--EndingCombo	     	          INT,
			BeginingMixMatchID	     	   NVARCHAR(MAX),
			--EndingMixMatchID	     	  INT,
			BeginingItemsList	           NVARCHAR(MAX),
			--EndingItemsList               INT,
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

										  -- MIX-MATCH LIST ID 
	 DECLARE @temptblPromoMIXMATCHListID TABLE (
											intPrimaryID INT IDENTITY(1, 1),
											intPromoMixMatchSalesId INT 
										 );

	 -- MIX-MATCH LIST ID
	 DECLARE @temptblPromoCOMBOListID TABLE (
											intPrimaryID INT IDENTITY(1, 1),
											intPromoComboSalesId INT 
											 );
	-- ITEM LIST ID
	 DECLARE @temptblPromoITEMListID TABLE (
											intPrimaryID INT IDENTITY(1, 1),
											intPromoItemListId INT,
											intPromoItemListNo INT
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
		
	 IF(@ToStoreGroup != '')
		BEGIN
			-- Insert all intStoreId's to a temp table
			 INSERT INTO @temptblStore 
			 (
				intStoreId
			 )
			SELECT DISTINCT st.intStoreId AS intLocationId
			FROM [dbo].[fnGetRowsFromDelimitedValues](@ToStoreGroup)
			INNER JOIN tblSTStoreGroup sg
				ON sg.intStoreGroupId = intID
			INNER JOIN tblSTStoreGroupDetail sgt
				ON sgt.intStoreGroupId = sg.intStoreGroupId
			INNER JOIN tblSTStore st
				ON st.intStoreId = sgt.intStoreId
			WHERE st.intStoreId != @intFromStoreId
		END

		 --INSERT TO THE TEMP table all the promo combo ID
		IF (@intBeginningComboID != '')
			BEGIN
				INSERT INTO @temptblPromoCOMBOListID
				(
					intPromoComboSalesId
				)SELECT [intID] AS intPromoComboSalesId
				FROM [dbo].[fnGetRowsFromDelimitedValues](@intBeginningComboID)

		END

		 --INSERT TO THE TEMP table all the promo MIX ID
	 IF (@intBeginingMixMatchID != '')
		BEGIN
			INSERT INTO @temptblPromoMIXMATCHListID
			 (
				intPromoMixMatchSalesId
			 )SELECT [intID] AS intPromoMixMatchSalesId
			 FROM [dbo].[fnGetRowsFromDelimitedValues](@intBeginingMixMatchID)
		END

	 --INSERT TO THE TEMP Promotion ID ITEM to temp table.
	  IF (@intBeginningItemsListNo != '')
		BEGIN
			INSERT INTO @temptblPromoITEMListID
			 (
				intPromoItemListNo
			 )SELECT [intID] AS intPromoItemListNo
			 FROM [dbo].[fnGetRowsFromDelimitedValues](@intBeginningItemsListNo)
		END
	 
	  -- Insert All Promotion COMBO to temp table
	 INSERT INTO @temptblPromoCOMBOList 
	 (
		intPromoComboSalesId
	 )
	 SELECT intPromoSalesId 
	 FROM tblSTPromotionSalesList 
	 --WHERE  intPromoSalesId BETWEEN @intBeginningComboID AND @intEndingComboID
	 WHERE  intPromoSalesListId IN (SELECT intPromoComboSalesId FROM @temptblPromoCOMBOListID) 
			AND intStoreId = @intFromStoreId 
			AND strPromoType = 'C'

	 -- Insert All Promotion MIX-MATCH to temp table
	 INSERT INTO @temptblPromoMIXMATCHList 
	 (
				intPromoMixMatchSalesId
	 )
	 SELECT intPromoSalesId 
	 FROM tblSTPromotionSalesList 
	 --WHERE intPromoSalesId BETWEEN @intBeginingMixMatchID AND @intEndingMixMatchID
	 WHERE intPromoSalesId IN (SELECT intPromoMixMatchSalesId FROM @temptblPromoMIXMATCHListID)
		AND intStoreId = @intFromStoreId 
		AND strPromoType = 'M'

		
	 -- Insert All Promotion ITEM to temp table
	 INSERT INTO @temptblPromoITEMList 
	 (
		intPromoItemListId
		, intPromoItemListNo
	 )
	 SELECT intPromoItemListId
			, intPromoItemListNo
	 FROM tblSTPromotionItemList 
	 --WHERE intPromoItemListNo BETWEEN @intBeginningItemsListNo AND @intEndingItemsListNo
	 WHERE intPromoItemListNo IN (SELECT intPromoItemListNo FROM  @temptblPromoITEMListID) 
		--AND intPromoItemListId IN (SELECT intPromoItemListId FROM tblSTPromotionSalesList WHERE intPromoSalesId IN (SELECT intPromoComboSalesId FROM @temptblPromoCOMBOList))
		--AND intPromoItemListId IN (SELECT intPromoItemListId FROM tblSTPromotionSalesList WHERE intPromoSalesId IN (SELECT intPromoMixMatchSalesId FROM @temptblPromoMIXMATCHList))
		AND intStoreId = @intFromStoreId
	
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
										AND intPromoItemListId NOT IN (SELECT intPromoItemListId 
																		FROM tblSTPromotionSalesListDetail s 
																		INNER JOIN tblSTPromotionSalesList t
																		ON s.intPromoSalesListId = t.intPromoSalesListId
																		WHERE t.intStoreId = @intStoreId)

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
		   
--PRINT '[START] - ITEM LIST PROMOTIONS'
		   -- ======================================================================================
		   -- [START] - ITEM LIST PROMOTIONS
		   -- ======================================================================================
		   IF EXISTS(SELECT TOP 1 1 FROM @temptblPromoITEMList)
				BEGIN

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
										 AND intPromoItemListId NOT IN (SELECT intPromoItemListId 
																		FROM tblSTPromotionSalesListDetail s 
																		INNER JOIN tblSTPromotionSalesList t
																		ON s.intPromoSalesListId = t.intPromoSalesListId
																		WHERE t.intStoreId = @intStoreId)
										 AND (intStoreId != @intStoreId AND intPromoItemListNo NOT IN (SELECT intPromoItemListNo FROM tblSTPromotionItemList WHERE intStoreId = @intStoreId))

									IF @@ROWCOUNT = 1
										BEGIN
											SET @intPromotionItemListAdded = @intPromotionItemListAdded + 1
										END

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
									  AND ItemList.intPromoItemListId NOT IN (SELECT intPromoItemListId 
																FROM tblSTPromotionSalesListDetail s 
																INNER JOIN tblSTPromotionSalesList t
																ON s.intPromoSalesListId = t.intPromoSalesListId
																WHERE t.intStoreId = @intStoreId)
									  AND (intStoreId != @intStoreId)


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
				
				   -- ====================================================================================================================
				   -- [START] - Loop to all PROMOTION COMBO LIST
				   -- ====================================================================================================================
				   SELECT @intCOMBOPrimaryID = MIN(intPrimaryID)
				   FROM @temptblPromoCOMBOList

				   WHILE (@intCOMBOPrimaryID > 0) --EXISTS (SELECT TOP (1) 1 FROM @temptblPromoCOMBOList)
						BEGIN
							
						   SELECT TOP 1 @intPromotionComboListId = intPromoComboSalesId FROM @temptblPromoCOMBOList WHERE intPrimaryID = @intCOMBOPrimaryID

						   IF NOT EXISTS (SELECT TOP 1 1 FROM tblSTPromotionSalesList WHERE intStoreId = @intStoreId
																							AND intPromoSalesId = @intPromotionComboListId
																							AND strPromoType = 'C')
						   BEGIN
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
									, ysnWeekDayPromotionSunday
									, ysnWeekDayPromotionMonday
									, ysnWeekDayPromotionTuesday
									, ysnWeekDayPromotionWednesday
									, ysnWeekDayPromotionThursday
									, ysnWeekDayPromotionFriday
									, ysnWeekDayPromotionSaturday
									, dtmStartTimePromotionSunday
									, dtmStartTimePromotionMonday
									, dtmStartTimePromotionTuesday
									, dtmStartTimePromotionWednesday
									, dtmStartTimePromotionThursday
									, dtmStartTimePromotionFriday
									, dtmStartTimePromotionSaturday
									, dtmEndTimePromotionSunday
									, dtmEndTimePromotionMonday
									, dtmEndTimePromotionTuesday
									, dtmEndTimePromotionWednesday
									, dtmEndTimePromotionThursday
									, dtmEndTimePromotionFriday
									, dtmEndTimePromotionSaturday
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
									, ysnWeekDayPromotionSunday
									, ysnWeekDayPromotionMonday
									, ysnWeekDayPromotionTuesday
									, ysnWeekDayPromotionWednesday
									, ysnWeekDayPromotionThursday
									, ysnWeekDayPromotionFriday
									, ysnWeekDayPromotionSaturday
									, dtmStartTimePromotionSunday
									, dtmStartTimePromotionMonday
									, dtmStartTimePromotionTuesday
									, dtmStartTimePromotionWednesday
									, dtmStartTimePromotionThursday
									, dtmStartTimePromotionFriday
									, dtmStartTimePromotionSaturday
									, dtmEndTimePromotionSunday
									, dtmEndTimePromotionMonday
									, dtmEndTimePromotionTuesday
									, dtmEndTimePromotionWednesday
									, dtmEndTimePromotionThursday
									, dtmEndTimePromotionFriday
									, dtmEndTimePromotionSaturday
									, intConcurrencyId
							   FROM tblSTPromotionSalesList 
							   WHERE intPromoSalesId = @intPromotionComboListId --IN (SELECT intPromoComboSalesId FROM @temptblPromoCOMBOList)
									AND intStoreId = @intFromStoreId 
									AND strPromoType = 'C'
									
								IF @@ROWCOUNT = 1
									BEGIN
										SET @intComboAdded = @intComboAdded + 1
									END
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
									, dblCost
									, intQuantity
									, dblPrice
									, intConcurrencyId
							   )
							   SELECT DISTINCT
									 @intNewPromotionCOMBOListId AS intPromoSalesListId
									 , ItemListTwo.intPromoItemListId
									 , SalesListDetail.dblCost
									 , SalesListDetail.intQuantity
									 , SalesListDetail.dblPrice
									 , SalesListDetail.intConcurrencyId
							   FROM tblSTPromotionItemList ItemList
							   INNER JOIN tblSTPromotionSalesListDetail SalesListDetail
									ON ItemList.intPromoItemListId = SalesListDetail.intPromoItemListId
							   INNER JOIN tblSTPromotionSalesList SalesList
									ON SalesListDetail.intPromoSalesListId = SalesList.intPromoSalesListId
									AND SalesList.strPromoType = 'C'
							   INNER JOIN
							   (
									SELECT *
									FROM tblSTPromotionItemList
									WHERE intStoreId = @intStoreId
							   ) AS ItemListTwo
									ON ItemList.intPromoItemListNo = ItemListTwo.intPromoItemListNo
							   WHERE SalesList.intPromoSalesId = @intPromotionComboListId 
							   
						   END


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
				
				   -- ====================================================================================================================
				   -- [START] - Loop to all PROMOTION MIX_MATCH LIST
				   -- ====================================================================================================================
				   SELECT @intMIXMATCHPrimaryID = MIN(intPrimaryID)
				   FROM @temptblPromoMIXMATCHList

				   WHILE (@intMIXMATCHPrimaryID > 0) --EXISTS (SELECT TOP (1) 1 FROM @temptblPromoMIXMATCHList)
						BEGIN
							
						   SELECT TOP 1 @intPromotionMixMatchListId = intPromoMixMatchSalesId FROM @temptblPromoMIXMATCHList WHERE intPrimaryID = @intMIXMATCHPrimaryID
						   
						   IF NOT EXISTS (SELECT TOP 1 1 FROM tblSTPromotionSalesList WHERE intStoreId = @intStoreId
																							AND intPromoSalesId = @intPromotionMixMatchListId
																							AND strPromoType = 'M')
						   BEGIN

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
									, ysnWeekDayPromotionSunday
                                    , ysnWeekDayPromotionMonday
                                    , ysnWeekDayPromotionTuesday
                                    , ysnWeekDayPromotionWednesday
                                    , ysnWeekDayPromotionThursday
                                    , ysnWeekDayPromotionFriday
                                    , ysnWeekDayPromotionSaturday
                                    , dtmStartTimePromotionSunday
                                    , dtmStartTimePromotionMonday
                                    , dtmStartTimePromotionTuesday
                                    , dtmStartTimePromotionWednesday
                                    , dtmStartTimePromotionThursday
                                    , dtmStartTimePromotionFriday
                                    , dtmStartTimePromotionSaturday
                                    , dtmEndTimePromotionSunday
                                    , dtmEndTimePromotionMonday
                                    , dtmEndTimePromotionTuesday
                                    , dtmEndTimePromotionWednesday
                                    , dtmEndTimePromotionThursday
                                    , dtmEndTimePromotionFriday
                                    , dtmEndTimePromotionSaturday
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
									, ysnWeekDayPromotionSunday
                                    , ysnWeekDayPromotionMonday
                                    , ysnWeekDayPromotionTuesday
                                    , ysnWeekDayPromotionWednesday
                                    , ysnWeekDayPromotionThursday
                                    , ysnWeekDayPromotionFriday
                                    , ysnWeekDayPromotionSaturday
                                    , dtmStartTimePromotionSunday
                                    , dtmStartTimePromotionMonday
                                    , dtmStartTimePromotionTuesday
                                    , dtmStartTimePromotionWednesday
                                    , dtmStartTimePromotionThursday
                                    , dtmStartTimePromotionFriday
                                    , dtmStartTimePromotionSaturday
                                    , dtmEndTimePromotionSunday
                                    , dtmEndTimePromotionMonday
                                    , dtmEndTimePromotionTuesday
                                    , dtmEndTimePromotionWednesday
                                    , dtmEndTimePromotionThursday
                                    , dtmEndTimePromotionFriday
                                    , dtmEndTimePromotionSaturday
									, intConcurrencyId
								FROM tblSTPromotionSalesList 
								WHERE intPromoSalesId = @intPromotionMixMatchListId 
									AND intStoreId = @intFromStoreId 
									AND strPromoType = 'M'
						   
								IF @@ROWCOUNT = 1
									BEGIN
										SET @intMixMatchAdded = @intMixMatchAdded + 1
									END

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
									, dblCost
									, intQuantity
									, dblPrice
									, intConcurrencyId
								)
								SELECT DISTINCT
										@intNewPromotionMIXMATCHListId AS intPromoSalesListId
										, ItemListTwo.intPromoItemListId
										, SalesListDetail.dblCost
										, SalesListDetail.intQuantity
										, SalesListDetail.dblPrice
										, SalesListDetail.intConcurrencyId
								FROM tblSTPromotionItemList ItemList
								INNER JOIN tblSTPromotionSalesListDetail SalesListDetail
									ON ItemList.intPromoItemListId = SalesListDetail.intPromoItemListId
								INNER JOIN tblSTPromotionSalesList SalesList
									ON SalesListDetail.intPromoSalesListId = SalesList.intPromoSalesListId
									AND SalesList.strPromoType = 'M'
								INNER JOIN
								(
									SELECT *
									FROM tblSTPromotionItemList
									WHERE intStoreId = @intStoreId
								) AS ItemListTwo
									ON ItemList.intPromoItemListNo = ItemListTwo.intPromoItemListNo
								WHERE SalesList.intPromoSalesId = @intPromotionMixMatchListId
							END

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
	 END TRY
	 BEGIN CATCH
		SELECT ERROR_MESSAGE() 
		SELECT ERROR_LINE() 
	 END CATCH



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