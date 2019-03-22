CREATE PROCEDURE [dbo].[uspSTCopyPromotions]
   @XML varchar(max)
AS
BEGIN
     DECLARE @ErrMsg				 	  NVARCHAR(MAX),
	         @idoc				          INT,
	     	 @FromStore                   INT,
	         @ToStore                     NVARCHAR(MAX),
			 @BeginingCombo               INT,
			 @EndingCombo                 INT,
             @BeginingMixMatchID          INT,
			 @EndingMixMatchID            INT,
			 @BeginingItemsList           INT,
			 @EndingItemsList             INT,
	  		 @ReplaceDuplicateRecordsysn  NVARCHAR(1),
			 @Itladded                    INT,
			 @Itlreplaced                 INT,
			 @Cboadded                    INT,
			 @Cboreplaced                 INT, 
			 @Mxmadded                    INT,
			 @MxmReplaced                 INT,
		     @PromotionItemListAdded      INT,
			 @PromoItemListReplaced       INT,
			 @ComboAdded                  INT,
			 @ComboReplaced               INT,
			 @MixMatchAdded               INT,
			 @MixMatchReplaced            INT

    EXEC sp_xml_preparedocument @idoc OUTPUT, @XML 

    SELECT	
			@FromStore		             =	 FromStore,
            @ToStore                     =   ToStore,
			@BeginingCombo               =   BeginingCombo,
			@EndingCombo                 =   EndingCombo,
            @BeginingMixMatchID          =   BeginingMixMatchID,
            @EndingMixMatchID            =   EndingMixMatchID,
			@BeginingItemsList           =   BeginingItemsList,
			@EndingItemsList             =   EndingItemsList,
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
     
	  set @Itladded = 0
	  set @Itlreplaced = 0
	  set @Cboadded = 0
	  set @Cboreplaced = 0
	  set @Mxmadded = 0
	  set @MxmReplaced = 0
	  set @PromotionItemListAdded  = 0  
	  set @PromoItemListReplaced   = 0
	  set @ComboAdded = 0
	  set @ComboReplaced = 0 
	  set @MixMatchAdded = 0
	  set @MixMatchReplaced = 0  


     DECLARE @tempTble Table (
	        DataKey INT IDENTITY(1, 1),
            DestinationStore INT NULL);

     DECLARE @DestinationStore INT

     while len(@ToStore ) > 0
     begin
        insert into @tempTble (DestinationStore ) values(left(@ToStore , charindex(',', @ToStore +',')-1))
        set @ToStore = stuff(@ToStore , 1, charindex(',', @ToStore +','), '')
     end

	 Declare @DataKey int

      if (@ReplaceDuplicateRecordsysn = 'Y')
	  BEGIN
	      
          SELECT @DataKey = MIN(DataKey)
	      FROM @tempTble
       	  WHILE (@DataKey > 0)
	      BEGIN
             
             SELECT @DestinationStore = DestinationStore  FROM @tempTble
		     WHERE DataKey = @DataKey

		     SELECT @Cboreplaced = COUNT(*) FROM tblSTPromotionSalesList  
		     WHERE intPromoSalesId BETWEEN @BeginingCombo AND @EndingCombo
		     and intStoreId = @DestinationStore and strPromoType = 'C'

		     DELETE FROM tblSTPromotionSalesList 
		     WHERE intPromoSalesId BETWEEN @BeginingCombo AND @EndingCombo
		     and intStoreId = @DestinationStore and strPromoType = 'C'

			 set @ComboReplaced = @ComboReplaced + @Cboreplaced

		     SELECT @MxmReplaced = COUNT(*) FROM tblSTPromotionSalesList  
		     WHERE intPromoSalesId BETWEEN @BeginingMixMatchID AND @EndingMixMatchID
		     and intStoreId = @DestinationStore and strPromoType = 'M'

			 set @MixMatchReplaced = @MixMatchReplaced + @MxmReplaced

		     DELETE FROM tblSTPromotionSalesList 
		     WHERE intPromoSalesId BETWEEN @BeginingMixMatchID AND @EndingMixMatchID
		     and intStoreId = @DestinationStore and strPromoType = 'M'
	  
	         SELECT @Itlreplaced = COUNT(*) FROM tblSTPromotionItemList 
		     WHERE  intPromoItemListNo BETWEEN @BeginingItemsList AND @EndingItemsList
	         and intStoreId = @DestinationStore

			 set @PromoItemListReplaced  = @PromoItemListReplaced + @Itlreplaced

             DELETE FROM tblSTPromotionItemList 
		     WHERE  intPromoItemListNo BETWEEN @BeginingItemsList AND @EndingItemsList
	         and intStoreId = @DestinationStore AND intPromoItemListId   
		     NOT IN (SELECT intPromoItemListId FROM tblSTPromotionSalesListDetail)
		   
             SELECT @DataKey = MIN(DataKey)
		     FROM @tempTble
		     Where DataKey>@DataKey
   	      END	  
	 END

	 SELECT @DataKey = MIN(DataKey)
	 FROM @tempTble
	 WHILE (@DataKey > 0)
	  BEGIN
		   SELECT @DestinationStore = DestinationStore  FROM @tempTble
		   WHERE DataKey = @DataKey

           SELECT @Itladded= COUNT (*) from tblSTPromotionItemList
           WHERE intPromoItemListNo between @BeginingItemsList and @EndingItemsList
           AND intStoreId = @FromStore and intPromoItemListNo 
           NOT IN (select intPromoItemListNo from tblSTPromotionItemList where CAST(intStoreId AS NVARCHAR) IN (CAST(@DestinationStore AS NVARCHAR))) 

		   set @PromotionItemListAdded = @PromotionItemListAdded + @Itladded

           --Inserting ItemList Header From to ToStore

		   INSERT INTO tblSTPromotionItemList (intStoreId,intPromoItemListNo,
           strPromoItemListId,strPromoItemListDescription,
           ysnDeleteFromRegister,dtmLastUpdateDate,intConcurrencyId)
           SELECT @DestinationStore ,intPromoItemListNo,
           strPromoItemListId,strPromoItemListDescription,
           ysnDeleteFromRegister, dtmLastUpdateDate, intConcurrencyId from tblSTPromotionItemList 
           WHERE intStoreId = @FromStore AND intPromoItemListNo BETWEEN @BeginingItemsList AND @EndingItemsList
	       and intPromoItemListNo NOT IN(select intPromoItemListNo from tblSTPromotionItemList where intStoreId = @DestinationStore)

         --Inserting ItemList Details From to ToStore

          INSERT INTO tblSTPromotionItemListDetail (intPromoItemListId,intItemUOMId,
          strUpcDescription,intUpcModifier,
          dblRetailPrice, intConcurrencyId)
	      SELECT 
	      (SELECT Top 1 adj4.intPromoItemListId FROM tblSTPromotionItemList 
	      adj4 WHERE adj4.intStoreId = @DestinationStore and adj4.intPromoItemListNo = adj2.intPromoItemListNo) 
	      as intPromoItemListId,
	      adj1.intItemUOMId,
	      adj1.strUpcDescription,adj1.intUpcModifier,
	      adj1.dblRetailPrice, adj1.intConcurrencyId FROM tblSTPromotionItemListDetail
	      AS adj1 INNER JOIN tblSTPromotionItemList  AS adj2
	      ON adj1.intPromoItemListId = adj2.intPromoItemListId and intStoreId = @FromStore
	      WHERE adj2.intPromoItemListNo in 
	      (SELECT adj3.intPromoItemListNo FROM tblSTPromotionItemList adj3 WHERE adj3.intStoreId = @DestinationStore)	
	      AND intPromoItemListNo NOT IN (select intPromoItemListNo from tblSTPromotionItemList as adj11 
	      INNER JOIN tblSTPromotionItemListDetail
	      AS adj22 ON adj22.intPromoItemListId = adj11.intPromoItemListId AND intStoreId = @DestinationStore)
	      AND adj1.intItemUOMId IN (SELECT intItemUOMId FROM tblICItemUOM AS adj3 INNER JOIN 
	      tblICItemLocation AS adj4 ON adj3.intItemId = adj4.intItemId INNER JOIN 
	      tblSMCompanyLocation AS adj5 ON adj4.intLocationId = adj5.intCompanyLocationId INNER JOIN 
	      tblSTStore AS adj6 ON adj5.intCompanyLocationId = adj6.intCompanyLocationId where adj6.intStoreId = @DestinationStore)     


          SELECT @Cboadded = COUNT(*) from tblSTPromotionSalesList
	      WHERE intPromoSalesId BETWEEN @BeginingCombo AND @EndingCombo
	      AND intStoreId = @FromStore and strPromoType = 'C' AND intPromoSalesId NOT IN
	      (SELECT intPromoSalesId from tblSTPromotionSalesList where intStoreId = @DestinationStore 
	      and strPromoType = 'C')

          set @ComboAdded = @ComboAdded + @Cboadded

          ----Inserting Combo Header From to ToStore

          INSERT INTO tblSTPromotionSalesList (strPromoType, intStoreId, intPromoSalesId, intCategoryId,
	      strPromoSalesDescription, strPromoReason, intPromoUnits, dblPromoPrice,
	      intPromoFeeType, intRegProdId, dtmPromoBegPeriod,
	      dtmPromoEndPeriod, intPurchaseLimit,
	      intSalesRestrictCode, ysnPurchaseAtleastMin, ysnPurchaseExactMultiples,ysnRecieptItemSize,
	      ysnReturnable, ysnFoodStampable, ysnId1Required, ysnId2Required,
	      ysnDiscountAllowed, ysnBlueLaw1, ysnBlueLaw2, ysnUserTaxFlag1, ysnUserTaxFlag2,
	      ysnUserTaxFlag3, ysnUserTaxFlag4, ysnDeleteFromRegister, 
	      ysnSentToRuby, dtmLastUpdateDate, intConcurrencyId) 
	      SELECT strPromoType, @DestinationStore, intPromoSalesId, intCategoryId,
	      strPromoSalesDescription, strPromoReason, intPromoUnits, dblPromoPrice,
	      intPromoFeeType, intRegProdId, dtmPromoBegPeriod,
	      dtmPromoEndPeriod, intPurchaseLimit,
	      intSalesRestrictCode, ysnPurchaseAtleastMin, ysnPurchaseExactMultiples,ysnRecieptItemSize,
	      ysnReturnable, ysnFoodStampable, ysnId1Required, ysnId2Required,
	      ysnDiscountAllowed, ysnBlueLaw1, ysnBlueLaw2, ysnUserTaxFlag1, ysnUserTaxFlag2,
	      ysnUserTaxFlag3, ysnUserTaxFlag4, ysnDeleteFromRegister, 
	      ysnSentToRuby, dtmLastUpdateDate, intConcurrencyId
	      FROM tblSTPromotionSalesList 
	      WHERE intStoreId = @FromStore AND intPromoSalesId BETWEEN @BeginingCombo AND @EndingCombo AND strPromoType = 'C'
	      and intPromoSalesId NOT IN(select intPromoSalesId from tblSTPromotionSalesList where intStoreId = @DestinationStore AND strPromoType = 'C')

          -----Inserting Combo Details From to ToStore

		  INSERT INTO tblSTPromotionSalesListDetail (intPromoSalesListId,intPromoItemListId,
	      intQuantity,dblPrice,intConcurrencyId)
	      SELECT 
	      (SELECT TOP 1 adj4.intPromoSalesListId From tblSTPromotionSalesList AS
	      adj4 Where adj4.intStoreId = @DestinationStore and adj4.intPromoSalesId = adj2.intPromoSalesId AND  adj4.strPromoType = 'C') 
	      AS intPromoSalesListId,
	      (SELECT intPromoItemListId FROM tblSTPromotionItemList WHERE intStoreId = @DestinationStore  AND intPromoItemListNo IN 
          (SELECT intPromoItemListNo FROM tblSTPromotionItemList WHERE intPromoItemListId = adj1.intPromoItemListId )),
	      adj1.intQuantity,
	      adj1.dblPrice, adj1.intConcurrencyId FROM tblSTPromotionSalesListDetail
	      AS adj1 INNER JOIN tblSTPromotionSalesList  AS adj2
	      ON adj1.intPromoSalesListId = adj2.intPromoSalesListId and intStoreId = @FromStore and strPromoType = 'C'
	      INNER JOIN tblSTPromotionItemList as adj5 ON adj1.intPromoItemListId = adj5.intPromoItemListId
	      WHERE adj2.intPromoSalesId in 
	      (SELECT adj3.intPromoSalesId FROM tblSTPromotionSalesList adj3 WHERE adj3.intStoreId = @DestinationStore and adj3.strPromoType = 'C')	
          AND intPromoSalesId NOT IN (select intPromoSalesId from tblSTPromotionSalesList as adj11 INNER JOIN tblSTPromotionSalesListDetail
	      AS adj22 ON adj22.intPromoSalesListId = adj11.intPromoSalesListId AND intStoreId = @DestinationStore and adj11.strPromoType = 'C')
	      AND adj5.intPromoItemListNo BETWEEN @BeginingItemsList AND @EndingItemsList


          SELECT @Mxmadded = COUNT(*) from tblSTPromotionSalesList
	      WHERE intPromoSalesId BETWEEN @BeginingMixMatchID AND @EndingMixMatchID
	      AND intStoreId = @FromStore and strPromoType = 'M' AND intPromoSalesId NOT IN
	     (SELECT intPromoSalesId from tblSTPromotionSalesList where intStoreId = @DestinationStore 
	      and strPromoType = 'M')

          set @MixMatchAdded = @MixMatchAdded + @Mxmadded

         ----Inserting MixMatch Header From to ToStore

         INSERT INTO tblSTPromotionSalesList (strPromoType, intStoreId, intPromoSalesId, intCategoryId,
 	     strPromoSalesDescription, strPromoReason, intPromoUnits, dblPromoPrice,
	     intPromoFeeType, intRegProdId,  dtmPromoBegPeriod,
	     dtmPromoEndPeriod,  intPurchaseLimit,
	     intSalesRestrictCode, ysnPurchaseAtleastMin, ysnPurchaseExactMultiples,ysnRecieptItemSize,
	     ysnReturnable, ysnFoodStampable, ysnId1Required, ysnId2Required,
	     ysnDiscountAllowed, ysnBlueLaw1, ysnBlueLaw2, ysnUserTaxFlag1, ysnUserTaxFlag2,
	     ysnUserTaxFlag3, ysnUserTaxFlag4, ysnDeleteFromRegister, 
	     ysnSentToRuby, dtmLastUpdateDate, intConcurrencyId) 
	     SELECT strPromoType, @DestinationStore, intPromoSalesId, intCategoryId,
	     strPromoSalesDescription, strPromoReason, intPromoUnits, dblPromoPrice,
	     intPromoFeeType, intRegProdId,  dtmPromoBegPeriod,
	     dtmPromoEndPeriod,  intPurchaseLimit,
	     intSalesRestrictCode, ysnPurchaseAtleastMin, ysnPurchaseExactMultiples,ysnRecieptItemSize,
	     ysnReturnable, ysnFoodStampable, ysnId1Required, ysnId2Required,
	     ysnDiscountAllowed, ysnBlueLaw1, ysnBlueLaw2, ysnUserTaxFlag1, ysnUserTaxFlag2,
	     ysnUserTaxFlag3, ysnUserTaxFlag4, ysnDeleteFromRegister, 
	     ysnSentToRuby, dtmLastUpdateDate, intConcurrencyId
	     FROM tblSTPromotionSalesList 
	     WHERE intStoreId = @FromStore AND intPromoSalesId BETWEEN @BeginingMixMatchID AND @EndingMixMatchID AND strPromoType = 'M'
	     and intPromoSalesId NOT IN(select intPromoSalesId from tblSTPromotionSalesList where intStoreId = @DestinationStore AND strPromoType = 'M')

         ----Inserting MixMatch Details From to ToStore
 
         INSERT INTO tblSTPromotionSalesListDetail (intPromoSalesListId,intPromoItemListId,
	     intQuantity,dblPrice,intConcurrencyId)
	     SELECT 
	     (SELECT TOP 1 adj4.intPromoSalesListId From tblSTPromotionSalesList AS
	     adj4 Where adj4.intStoreId = @DestinationStore and adj4.intPromoSalesId = adj2.intPromoSalesId  AND adj4.strPromoType = 'M') 
	     AS intPromoSalesListId,
	     (SELECT intPromoItemListId FROM tblSTPromotionItemList WHERE intStoreId = @DestinationStore AND intPromoItemListNo IN
         (SELECT intPromoItemListNo FROM tblSTPromotionItemList WHERE intPromoItemListId = adj1.intPromoItemListId)),
	     adj1.intQuantity,
	     adj1.dblPrice, adj1.intConcurrencyId FROM tblSTPromotionSalesListDetail 
	     AS adj1 INNER JOIN tblSTPromotionSalesList  AS adj2
 	     ON adj1.intPromoSalesListId = adj2.intPromoSalesListId and intStoreId = @FromStore and strPromoType = 'M'
	     INNER JOIN tblSTPromotionItemList as adj5 ON adj1.intPromoItemListId = adj5.intPromoItemListId
	     WHERE adj2.intPromoSalesId in 
	     (SELECT adj3.intPromoSalesId FROM tblSTPromotionSalesList adj3 WHERE adj3.intStoreId = @DestinationStore and adj3.strPromoType = 'M')	
	     AND intPromoSalesId NOT IN (SELECT intPromoSalesId FROM tblSTPromotionSalesList AS adj11 INNER JOIN tblSTPromotionSalesListDetail
	     AS adj22 ON adj22.intPromoSalesListId = adj11.intPromoSalesListId AND intStoreId = @DestinationStore and adj11.strPromoType = 'M')
	     AND adj5.intPromoItemListNo BETWEEN @BeginingItemsList AND @EndingItemsList

	    SELECT @DataKey = MIN(DataKey)
		      FROM @tempTble
		       Where DataKey>@DataKey

	  END	  

	  IF (@ReplaceDuplicateRecordsysn = 'Y')
	  BEGIN

	     SET @ComboAdded = @ComboAdded- @ComboReplaced 

		 IF @ComboAdded < 0
		 BEGIN
		    SET @ComboAdded = @ComboAdded * -1
		 END

		 IF @ComboReplaced < 0
		 BEGIN
		    SET @ComboReplaced = @ComboReplaced * -1
		 END

		 set @MixMatchAdded = @MixMatchAdded- @MixMatchReplaced 

		 IF @MixMatchAdded < 0
		 BEGIN
		    SET @MixMatchAdded = @MixMatchAdded * -1
		 END

		 IF @MixMatchReplaced < 0
		 BEGIN
		    SET @MixMatchReplaced = @MixMatchReplaced * -1
		 END

	     SET @PromotionItemListAdded = @PromotionItemListAdded - @PromoItemListReplaced

		 IF @PromotionItemListAdded < 0
		 BEGIN
		    SET @PromotionItemListAdded = @PromotionItemListAdded * -1
		 END

		 IF @PromoItemListReplaced < 0
		 BEGIN
		    SET @PromoItemListReplaced = @PromoItemListReplaced * -1
		 END

	  END

	  SELECT @PromotionItemListAdded AS PromotionItemListAdded, @PromoItemListReplaced AS PromoItemListReplaced,
	  @ComboAdded AS ComboAdded, @ComboReplaced As ComboReplaced,
	  @MixMatchAdded AS MixMatchAdded, @MixMatchReplaced AS MixMatchReplaced
END