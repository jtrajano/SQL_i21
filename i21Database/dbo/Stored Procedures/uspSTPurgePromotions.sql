CREATE PROCEDURE [dbo].[uspSTPurgePromotions]
	@XML varchar(max)
	
AS
BEGIN TRY
	DECLARE @ErrMsg				       NVARCHAR(MAX),
	        @idoc					   INT,
	    	@PromoStore  		       NVARCHAR(MAX),
			@PromoEndingPeriodDate     DATETIME,
			@PromoPurgeAllRecordsysn   NVARCHAR(1),
			@PromoMixMatchysn          NVARCHAR(1),
			@PromoComboysn             NVARCHAR(1),
			@PromoItemListysn          NVARCHAR(1)

	                  
	EXEC sp_xml_preparedocument @idoc OUTPUT, @XML 
	
	SELECT	
			@PromoStore		          =	Store,
			@PromoEndingPeriodDate    = EndingPeriodDate,
			@PromoPurgeAllRecordsysn  = PurgeAllRecordsysn,
			@PromoMixMatchysn         = MixMatchysn,
			@PromoComboysn            = Comboysn,
			@PromoItemListysn         = ItemListysn 

		
	FROM	OPENXML(@idoc, 'root',2)
	WITH
	(
			Store    		        NVARCHAR(MAX),
			EndingPeriodDate        DATETIME,
			PurgeAllRecordsysn      NVARCHAR(1),
            MixMatchysn             NVARCHAR(1),
			Comboysn                NVARCHAR(1), 
			ItemListysn             NVARCHAR(1)
	
	)  
	
	  DECLARE @MiXMatchCount INT 
	  DECLARE @ComboCount INT
	  DECLARE @ItemListCount INT
	 
	  set @MiXMatchCount = 0
	  set @ComboCount = 0
	  set @ItemListCount = 0

	   
	  IF (@PromoPurgeAllRecordsysn = 'Y')
	  BEGIN

		  IF (@PromoComboysn = 'Y')
		  BEGIN
		       SELECT @ComboCount = COUNT(*) from tblSTPromotionSalesList
		       WHERE intStoreId IN (Select Item from dbo.fnSplitString(@PromoStore,',')) and strPromoType = 'C'

		       DELETE FROM tblSTPromotionSalesList 
		       WHERE intStoreId IN (Select Item from dbo.fnSplitString(@PromoStore,',')) and strPromoType = 'C'
		  END

	      IF (@PromoMixMatchysn = 'Y')
		  BEGIN
                SELECT @MiXMatchCount = COUNT(*) from tblSTPromotionSalesList
		        WHERE intStoreId IN (Select Item from dbo.fnSplitString(@PromoStore,',')) and strPromoType = 'M' 
  
		        DELETE FROM tblSTPromotionSalesList 
		        WHERE intStoreId IN (Select Item from dbo.fnSplitString(@PromoStore,',')) and strPromoType = 'M'
		  END

		  IF (@PromoItemListysn = 'Y')
		  BEGIN

		       SELECT @ItemListCount = COUNT (*) FROM tblSTPromotionItemList 
		       WHERE  intStoreId IN (Select Item from dbo.fnSplitString(@PromoStore,',')) AND intPromoItemListId 
               NOT IN (SELECT intPromoItemListId FROM tblSTPromotionSalesListDetail)

		       DELETE FROM tblSTPromotionItemList 
		       WHERE  intStoreId IN (Select Item from dbo.fnSplitString(@PromoStore,',')) AND intPromoItemListId 
			   NOT IN (SELECT intPromoItemListId FROM tblSTPromotionSalesListDetail as adj1 INNER JOIN tblSTPromotionSalesList as adj2
			   ON adj1.intPromoSalesListId = adj2.intPromoSalesListId and adj2.intStoreId IN (Select Item from dbo.fnSplitString(@PromoStore,',')))
		  END
	  END

	  if (@PromoPurgeAllRecordsysn <> 'Y')
	  BEGIN
	      
		  IF (@PromoComboysn = 'Y')
		  BEGIN
		       SELECT @ComboCount = COUNT(*) from tblSTPromotionSalesList
		       WHERE intStoreId IN (Select Item from dbo.fnSplitString(@PromoStore,',')) 
			   and strPromoType = 'C' AND CONVERT(DATETIME,dtmPromoEndPeriod,101) 
			   <= CONVERT(DATETIME,@PromoEndingPeriodDate,101)
			  			  
	           DELETE FROM tblSTPromotionSalesList 
		       WHERE intStoreId IN (Select Item from dbo.fnSplitString(@PromoStore,',')) 
			   and strPromoType = 'C' AND CONVERT(DATETIME,dtmPromoEndPeriod,101) 
			   <= CONVERT(DATETIME,@PromoEndingPeriodDate,101)
		  END
	      
		  IF (@PromoMixMatchysn = 'Y')
		  BEGIN
                SELECT @MiXMatchCount = COUNT(*) from tblSTPromotionSalesList
		        WHERE intStoreId IN (Select Item from dbo.fnSplitString(@PromoStore,','))
				and strPromoType = 'M' AND CONVERT(DATETIME,dtmPromoEndPeriod,101) 
			    <= CONVERT(DATETIME,@PromoEndingPeriodDate,101)
 
		        DELETE FROM tblSTPromotionSalesList 
		        WHERE intStoreId IN (Select Item from dbo.fnSplitString(@PromoStore,',')) 
				and strPromoType = 'M' AND CONVERT(DATETIME,dtmPromoEndPeriod,101) 
			    <= CONVERT(DATETIME,@PromoEndingPeriodDate,101)
		  END

		  IF (@PromoItemListysn = 'Y')
		  BEGIN
		       SELECT @ItemListCount = COUNT (*) FROM tblSTPromotionItemList 
		       WHERE  intStoreId IN (Select Item from dbo.fnSplitString(@PromoStore,',')) AND intPromoItemListId 
               NOT IN (SELECT intPromoItemListId FROM tblSTPromotionSalesListDetail as adj1 INNER JOIN tblSTPromotionSalesList as adj2
			   ON adj1.intPromoSalesListId = adj2.intPromoSalesListId and adj2.intStoreId 
			   IN (Select Item from dbo.fnSplitString(@PromoStore,',')))

		       DELETE FROM tblSTPromotionItemList 
		       WHERE  intStoreId IN (Select Item from dbo.fnSplitString(@PromoStore,',')) AND intPromoItemListId 
               NOT IN (SELECT intPromoItemListId FROM tblSTPromotionSalesListDetail as adj1 INNER JOIN tblSTPromotionSalesList as adj2
			   ON adj1.intPromoSalesListId = adj2.intPromoSalesListId and adj2.intStoreId 
			   IN (Select Item from dbo.fnSplitString(@PromoStore,',')))
		  END
	  END

      select @MiXMatchCount as MixMatchCount, @ComboCount as ComboCount, @ItemListCount as ItemListCount	
		        

END TRY

BEGIN CATCH       
 SET @ErrMsg = ERROR_MESSAGE()      
 IF @idoc <> 0 EXEC sp_xml_removedocument @idoc      
 RAISERROR(@ErrMsg, 16, 1, 'WITH NOWAIT')      
END CATCH