CREATE PROCEDURE [dbo].[uspSTCopyPromotions]
   @XML varchar(max)
AS
BEGIN
     DECLARE @ErrMsg				 	  NVARCHAR(MAX),
	         @idoc				          INT,
	     	 @FromStore                   INT,
	         @ToStore                     INT,
			 @BeginingCombo               INT,
			 @EndingCombo                 INT,
             @BeginingMixMatchID          INT,
			 @EndingMixMatchID            INT,
			 @BeginingItemsList           INT,
			 @EndingItemsList             INT,
	  		 @ReplaceDuplicateRecordsysn  NVARCHAR(1),
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
			ToStore	     	              INT,
			BeginingCombo		          INT,
			EndingCombo	     	          INT,
			BeginingMixMatchID	     	  INT,
			EndingMixMatchID	     	  INT,
			BeginingItemsList	          INT,
			EndingItemsList               INT,
			ReplaceDuplicateRecordsysn    NVARCHAR(1)
			
	)  
    
	  set @PromotionItemListAdded  = 0  
	  set @PromoItemListReplaced   = 0
	  set @ComboAdded = 0
	  set @ComboReplaced = 0 
	  set @MixMatchAdded = 0
	  set @MixMatchReplaced = 0  
  

      if (@ReplaceDuplicateRecordsysn = 'Y')
	  BEGIN
	      
		  SELECT @ComboReplaced = COUNT(*) FROM tblSTPromotionSalesList  
		  WHERE intPromoSalesId BETWEEN @BeginingCombo AND @EndingCombo
		  and intStoreId = @ToStore and strPromoType = 'C'

		  DELETE FROM tblSTPromotionSalesList 
		  WHERE intPromoSalesId BETWEEN @BeginingCombo AND @EndingCombo
		  and intStoreId = @ToStore and strPromoType = 'C'

		  SELECT @MixMatchReplaced = COUNT(*) FROM tblSTPromotionSalesList  
		  WHERE intPromoSalesId BETWEEN @BeginingMixMatchID AND @EndingMixMatchID
		  and intStoreId = @ToStore and strPromoType = 'M'

		  DELETE FROM tblSTPromotionSalesList 
		  WHERE intPromoSalesId BETWEEN @BeginingMixMatchID AND @EndingMixMatchID
		  and intStoreId = @ToStore and strPromoType = 'M'
	  
	      SELECT @PromoItemListReplaced = COUNT(*) FROM tblSTPromotionItemList 
		  WHERE  intPromoItemListNo BETWEEN @BeginingItemsList AND @EndingItemsList
	      AND intStoreId = @ToStore

          DELETE FROM tblSTPromotionItemList 
		  WHERE  intPromoItemListNo BETWEEN @BeginingItemsList AND @EndingItemsList
	      AND intStoreId = @ToStore AND intPromoItemListId   
		  NOT IN (SELECT intPromoItemListId FROM tblSTPromotionSalesListDetail)
	 
	  END


	  SELECT @PromotionItemListAdded = COUNT (*) from tblSTPromotionItemList
	  WHERE intPromoItemListNo between @BeginingItemsList and @EndingItemsList
	  AND intStoreId = @FromStore and intPromoItemListNo 
	  NOT IN (select intPromoItemListNo from tblSTPromotionItemList where intStoreId = @ToStore) 

	   --Inserting ItemList Header From to ToStore

      INSERT INTO tblSTPromotionItemList (intStoreId,intPromoItemListNo,
      strPromoItemListId,strPromoItemListDescription,
      ysnDeleteFromRegister,dtmLastUpdateDate,intConcurrencyId)
      SELECT @ToStore,intPromoItemListNo,
      strPromoItemListId,strPromoItemListDescription,
      ysnDeleteFromRegister, dtmLastUpdateDate, intConcurrencyId from tblSTPromotionItemList 
      WHERE intStoreId = @FromStore AND intPromoItemListNo BETWEEN @BeginingItemsList AND @EndingItemsList
	  and intPromoItemListNo NOT IN(select intPromoItemListNo from tblSTPromotionItemList where intStoreId = @ToStore)
	  

	  --Inserting ItemList Details From to ToStore

      INSERT INTO tblSTPromotionItemListDetail (intPromoItemListId,intItemUOMId,
      strUpcDescription,intUpcModifier,
      dblRetailPrice, intConcurrencyId)
	  SELECT 
	  (SELECT Top 1 adj4.intPromoItemListId FROM tblSTPromotionItemList 
	  adj4 WHERE adj4.intStoreId = @ToStore and adj4.intPromoItemListNo = adj2.intPromoItemListNo) 
	  as intPromoItemListId,
	  adj1.intItemUOMId,
	  adj1.strUpcDescription,adj1.intUpcModifier,
	  adj1.dblRetailPrice, adj1.intConcurrencyId FROM tblSTPromotionItemListDetail
	  AS adj1 INNER JOIN tblSTPromotionItemList  AS adj2
	  ON adj1.intPromoItemListId = adj2.intPromoItemListId and intStoreId = @FromStore
	  WHERE adj2.intPromoItemListNo in 
	  (SELECT adj3.intPromoItemListNo FROM tblSTPromotionItemList adj3 WHERE adj3.intStoreId = @ToStore)	
	  AND intPromoItemListNo NOT IN (select intPromoItemListNo from tblSTPromotionItemList as adj11 
	  INNER JOIN tblSTPromotionItemListDetail
	  AS adj22 ON adj22.intPromoItemListId = adj11.intPromoItemListId AND intStoreId = @ToStore)
	  AND adj1.intItemUOMId IN (SELECT intItemUOMId FROM tblICItemUOM AS adj3 INNER JOIN 
	  tblICItemLocation AS adj4 ON adj3.intItemId = adj4.intItemId INNER JOIN 
	  tblSMCompanyLocation AS adj5 ON adj4.intLocationId = adj5.intCompanyLocationId INNER JOIN 
	  tblSTStore AS adj6 ON adj5.intCompanyLocationId = adj6.intCompanyLocationId where adj6.intStoreId = @ToStore)

	   SELECT @ComboAdded = COUNT(*) from tblSTPromotionSalesList
	   WHERE intPromoSalesId BETWEEN @BeginingCombo AND @EndingCombo
	   AND intStoreId = @FromStore and strPromoType = 'C' AND intPromoSalesId NOT IN
	   (SELECT intPromoSalesId from tblSTPromotionSalesList where intStoreId = @ToStore 
	    and strPromoType = 'C')
	 
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
	   SELECT strPromoType, @ToStore, intPromoSalesId, intCategoryId,
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
	   and intPromoSalesId NOT IN(select intPromoSalesId from tblSTPromotionSalesList where intStoreId = @ToStore AND strPromoType = 'C')

	  -----Inserting Combo Details From to ToStore

       INSERT INTO tblSTPromotionSalesListDetail (intPromoSalesListId,intPromoItemListId,
	   intQuantity,dblPrice,intConcurrencyId)
	   SELECT 
	   (SELECT TOP 1 adj4.intPromoSalesListId From tblSTPromotionSalesList AS
	   adj4 Where adj4.intStoreId = @ToStore and adj4.intPromoSalesId = adj2.intPromoSalesId AND  adj4.strPromoType = 'C') 
	   AS intPromoSalesListId,
	   (SELECT intPromoItemListId FROM tblSTPromotionItemList WHERE intStoreId = @ToStore  AND intPromoItemListNo IN 
       (SELECT intPromoItemListNo FROM tblSTPromotionItemList WHERE intPromoItemListId = adj1.intPromoItemListId )),
	   adj1.intQuantity,
	   adj1.dblPrice, adj1.intConcurrencyId FROM tblSTPromotionSalesListDetail
	   AS adj1 INNER JOIN tblSTPromotionSalesList  AS adj2
	   ON adj1.intPromoSalesListId = adj2.intPromoSalesListId and intStoreId = @FromStore and strPromoType = 'C'
	   INNER JOIN tblSTPromotionItemList as adj5 ON adj1.intPromoItemListId = adj5.intPromoItemListId
	   WHERE adj2.intPromoSalesId in 
	   (SELECT adj3.intPromoSalesId FROM tblSTPromotionSalesList adj3 WHERE adj3.intStoreId = @ToStore and adj3.strPromoType = 'C')	
       AND intPromoSalesId NOT IN (select intPromoSalesId from tblSTPromotionSalesList as adj11 INNER JOIN tblSTPromotionSalesListDetail
	   AS adj22 ON adj22.intPromoSalesListId = adj11.intPromoSalesListId AND intStoreId = @ToStore and adj11.strPromoType = 'C')
	   AND adj5.intPromoItemListNo BETWEEN @BeginingItemsList AND @EndingItemsList

      
	   SELECT @MixMatchAdded = COUNT(*) from tblSTPromotionSalesList
	   WHERE intPromoSalesId BETWEEN @BeginingMixMatchID AND @EndingMixMatchID
	   AND intStoreId = @FromStore and strPromoType = 'M' AND intPromoSalesId NOT IN
	   (SELECT intPromoSalesId from tblSTPromotionSalesList where intStoreId = @ToStore 
	    and strPromoType = 'M')

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
	   SELECT strPromoType, @ToStore, intPromoSalesId, intCategoryId,
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
	   and intPromoSalesId NOT IN(select intPromoSalesId from tblSTPromotionSalesList where intStoreId = @ToStore AND strPromoType = 'M')

	  ----Inserting MixMatch Details From to ToStore
	 
	  INSERT INTO tblSTPromotionSalesListDetail (intPromoSalesListId,intPromoItemListId,
	  intQuantity,dblPrice,intConcurrencyId)
	  SELECT 
	  (SELECT TOP 1 adj4.intPromoSalesListId From tblSTPromotionSalesList AS
	  adj4 Where adj4.intStoreId = @ToStore and adj4.intPromoSalesId = adj2.intPromoSalesId  AND adj4.strPromoType = 'M') 
	  AS intPromoSalesListId,
	  (SELECT intPromoItemListId FROM tblSTPromotionItemList WHERE intStoreId = @ToStore AND intPromoItemListNo IN
      (SELECT intPromoItemListNo FROM tblSTPromotionItemList WHERE intPromoItemListId = adj1.intPromoItemListId)),
	  adj1.intQuantity,
	  adj1.dblPrice, adj1.intConcurrencyId FROM tblSTPromotionSalesListDetail 
	  AS adj1 INNER JOIN tblSTPromotionSalesList  AS adj2
 	  ON adj1.intPromoSalesListId = adj2.intPromoSalesListId and intStoreId = @FromStore and strPromoType = 'M'
	  INNER JOIN tblSTPromotionItemList as adj5 ON adj1.intPromoItemListId = adj5.intPromoItemListId
	  WHERE adj2.intPromoSalesId in 
	  (SELECT adj3.intPromoSalesId FROM tblSTPromotionSalesList adj3 WHERE adj3.intStoreId = @ToStore and adj3.strPromoType = 'M')	
	  AND intPromoSalesId NOT IN (SELECT intPromoSalesId FROM tblSTPromotionSalesList AS adj11 INNER JOIN tblSTPromotionSalesListDetail
	  AS adj22 ON adj22.intPromoSalesListId = adj11.intPromoSalesListId AND intStoreId = @ToStore and adj11.strPromoType = 'M')
	  AND adj5.intPromoItemListNo BETWEEN @BeginingItemsList AND @EndingItemsList


	  if (@ReplaceDuplicateRecordsysn = 'Y')
	  BEGIN

	     set @ComboAdded = @ComboAdded- @ComboReplaced 

		 if @ComboAdded < 0
		 BEGIN
		    set @ComboAdded = @ComboAdded * -1
		 END

		 if @ComboReplaced < 0
		 BEGIN
		    set @ComboReplaced = @ComboReplaced * -1
		 END

		 set @MixMatchAdded = @MixMatchAdded- @MixMatchReplaced 

		 if @MixMatchAdded < 0
		 BEGIN
		    set @MixMatchAdded = @MixMatchAdded * -1
		 END

		 if @MixMatchReplaced < 0
		 BEGIN
		    set @MixMatchReplaced = @MixMatchReplaced * -1
		 END

	     set @PromotionItemListAdded = @PromotionItemListAdded - @PromoItemListReplaced

		  if @PromotionItemListAdded < 0
		 BEGIN
		    set @PromotionItemListAdded = @PromotionItemListAdded * -1
		 END

		 if @PromoItemListReplaced < 0
		 BEGIN
		    set @PromoItemListReplaced = @PromoItemListReplaced * -1
		 END

	  END

	  select @PromotionItemListAdded AS PromotionItemListAdded, @PromoItemListReplaced AS PromoItemListReplaced,
	  @ComboAdded AS ComboAdded, @ComboReplaced As ComboReplaced,
	  @MixMatchAdded AS MixMatchAdded, @MixMatchReplaced AS MixMatchReplaced
END