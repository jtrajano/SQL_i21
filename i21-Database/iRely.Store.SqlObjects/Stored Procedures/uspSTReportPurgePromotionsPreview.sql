CREATE PROCEDURE [dbo].[uspSTReportPurgePromotionsPreview]
	@xmlParam NVARCHAR(MAX)
	
AS
BEGIN TRY
	  
	  DECLARE @ErrMsg NVARCHAR(MAX)

	  --START Handle xml Param
	  DECLARE @strPromoStore  		         NVARCHAR(MAX)
	         , @dtmPromoEndingPeriodDate     DATETIME
			 , @strPromoPurgeAllRecordsysn   NVARCHAR(5)
			 , @strPromoMixMatchysn          NVARCHAR(3)
			 , @strPromoComboysn             NVARCHAR(3)
			 , @strPromoItemListysn          NVARCHAR(3)

      IF LTRIM(RTRIM(@xmlParam)) = ''
		SET @xmlParam = NULL

	  --Declare xmlParam holder
	  DECLARE @temp_xml_table TABLE 
	  (  
			[fieldname]		NVARCHAR(50),  
			condition		NVARCHAR(20),        
			[from]			NVARCHAR(50), 
			[to]			NVARCHAR(50),  
			[join]			NVARCHAR(10),  
			[begingroup]	NVARCHAR(50),  
			[endgroup]		NVARCHAR(50),  
			[datatype]		NVARCHAR(50) 
	  )

	  DECLARE @xmlDocumentId INT

	  EXEC sp_xml_preparedocument @xmlDocumentId OUTPUT ,@xmlParam

	  INSERT INTO @temp_xml_table  
	  SELECT	*  
	  FROM	OPENXML(@xmlDocumentId, 'xmlparam/filters/filter', 2)  
	  WITH (  
				[fieldname]		NVARCHAR(50),  
				condition		NVARCHAR(20),        
				[from]			NVARCHAR(50), 
				[to]			NVARCHAR(50),  
				[join]			NVARCHAR(10),  
				[begingroup]	NVARCHAR(50),  
				[endgroup]		NVARCHAR(50),  
				[datatype]		NVARCHAR(50)  
	  )

	  --strPromoStore
	  SELECT @strPromoStore = [from]
	  FROM @temp_xml_table
	  WHERE [fieldname] = 'strPromoStore'

	  --dtmPromoEndingPeriodDate
	  SELECT @dtmPromoEndingPeriodDate = [from]
	  FROM @temp_xml_table
	  WHERE [fieldname] = 'dtmPromoEndingPeriodDate'

	  --strPromoPurgeAllRecordsysn
	  SELECT @strPromoPurgeAllRecordsysn = [from]
	  FROM @temp_xml_table
	  WHERE [fieldname] = 'strPromoPurgeAllRecordsysn'

	  --strPromoMixMatchysn
	  SELECT @strPromoMixMatchysn = [from]
	  FROM @temp_xml_table
	  WHERE [fieldname] = 'strPromoMixMatchysn'

	  --strPromoComboysn
	  SELECT @strPromoComboysn = [from]
	  FROM @temp_xml_table
	  WHERE [fieldname] = 'strPromoComboysn'

	  --strPromoItemListysn
	  SELECT @strPromoItemListysn = [from]
	  FROM @temp_xml_table
	  WHERE [fieldname] = 'strPromoItemListysn'

	  --END Handle xml Param


	  DECLARE @MiXMatchCount INT 
	  DECLARE @ComboCount INT
	  DECLARE @ItemListCount INT
	 
	  set @MiXMatchCount = 0
	  set @ComboCount = 0
	  set @ItemListCount = 0

	  --Declare Table to handle preview
	  DECLARE @tblPurgePromotionPreview TABLE 
      (
		strPromoType NVARCHAR(250)
		, strStore NVARCHAR(50)
		, strPurgePromotion NVARCHAR(250)
      )
	   
	  IF (@strPromoPurgeAllRecordsysn = 'true')
	  BEGIN

		  IF (@strPromoComboysn = 'Y' OR @strPromoComboysn = 'Yes')
		  BEGIN
   		       IF(@strPromoStore IS NOT NULL)
			   BEGIN
					INSERT INTO @tblPurgePromotionPreview
		            SELECT 
						'Promotion Sales' AS strPromoType
						, ST.intStoreNo
						, PSL.strPromoSalesDescription
					FROM tblSTPromotionSalesList PSL
					LEFT JOIN tblSTStore ST ON PSL.intStoreId = ST.intStoreId 
		            WHERE PSL.intStoreId IN (Select Item from dbo.fnSplitString(@strPromoStore,',')) 
					AND strPromoType = 'C'
			   END

			   IF(@strPromoStore IS NULL)
			   BEGIN
					INSERT INTO @tblPurgePromotionPreview
		            SELECT 
						'Promotion Sales' AS strPromoType
						, ST.intStoreNo
						, PSL.strPromoSalesDescription
					FROM tblSTPromotionSalesList PSL
					LEFT JOIN tblSTStore ST ON PSL.intStoreId = ST.intStoreId 
		            WHERE PSL.strPromoType = 'C'
			   END

		  END

	      IF (@strPromoMixMatchysn = 'Y' OR @strPromoMixMatchysn = 'Yes')
		  BEGIN
		       IF(@strPromoStore IS NOT NULL)
			   BEGIN
					INSERT INTO @tblPurgePromotionPreview
                    SELECT 
						'Promotion Sales' AS strPromoType
						, ST.intStoreNo
						, PSL.strPromoSalesDescription
					FROM tblSTPromotionSalesList PSL
					LEFT JOIN tblSTStore ST ON PSL.intStoreId = ST.intStoreId 
		            WHERE PSL.intStoreId IN (Select Item from dbo.fnSplitString(@strPromoStore,',')) and strPromoType = 'M'    
		       END

			   IF(@strPromoStore IS NULL)
			   BEGIN
					INSERT INTO @tblPurgePromotionPreview
                    SELECT 
						'Promotion Sales' AS strPromoType
						, ST.intStoreNo
						, PSL.strPromoSalesDescription
					FROM tblSTPromotionSalesList PSL
					LEFT JOIN tblSTStore ST ON PSL.intStoreId = ST.intStoreId 
		            WHERE PSL.strPromoType = 'M'    
		       END
		  END



		  --ITEM LIST
		  IF (@strPromoItemListysn = 'Y' OR @strPromoItemListysn = 'Yes')
		  BEGIN
    		   IF(@strPromoStore IS NOT NULL)
		 	   BEGIN
				   INSERT INTO @tblPurgePromotionPreview
		           SELECT 
						'Promotion Items' AS strPromoType
						, ST.intStoreNo
						, PIL.strPromoItemListDescription
				   FROM tblSTPromotionItemList PIL
				   LEFT JOIN tblSTStore ST ON PIL.intStoreId = ST.intStoreId 
		           WHERE PIL.intStoreId IN (Select Item from dbo.fnSplitString(@strPromoStore,',')) AND intPromoItemListId 
			       NOT IN (SELECT intPromoItemListId FROM tblSTPromotionSalesListDetail)    
			   END

			   IF(@strPromoStore IS NULL)
		 	   BEGIN
			       INSERT INTO @tblPurgePromotionPreview
		           SELECT 
						'Promotion Items' AS strPromoType
						, ST.intStoreNo
						, PIL.strPromoItemListDescription
				   FROM tblSTPromotionItemList PIL
				   LEFT JOIN tblSTStore ST ON PIL.intStoreId = ST.intStoreId 
		           WHERE PIL.intPromoItemListId NOT IN (SELECT intPromoItemListId FROM tblSTPromotionSalesListDetail)     
			   END
		  END
	  END


	  ELSE IF (@strPromoPurgeAllRecordsysn = 'false')
	  BEGIN
	      
		  IF (@strPromoComboysn = 'Y' OR @strPromoComboysn = 'Yes')
		  BEGIN

		       IF(@strPromoStore IS NOT NULL)
		 	   BEGIN
			         INSERT INTO @tblPurgePromotionPreview
		             SELECT 
						'Promotion Sales' AS strPromoType
						, ST.intStoreNo
						, PSL.strPromoSalesDescription
					FROM tblSTPromotionSalesList PSL
					LEFT JOIN tblSTStore ST ON PSL.intStoreId = ST.intStoreId 
		            WHERE PSL.intStoreId IN (Select Item from dbo.fnSplitString(@strPromoStore,',')) 
			        AND PSL.strPromoType = 'C' 
					AND CONVERT(DATETIME,PSL.dtmPromoEndPeriod,101) <= CONVERT(DATETIME,@dtmPromoEndingPeriodDate,101)    
			   END

			   IF(@strPromoStore IS NULL)
		 	   BEGIN
			        INSERT INTO @tblPurgePromotionPreview
   	                SELECT 
						'Promotion Sales' AS strPromoType
						, ST.intStoreNo
						, PSL.strPromoSalesDescription
					FROM tblSTPromotionSalesList PSL
					LEFT JOIN tblSTStore ST ON PSL.intStoreId = ST.intStoreId 
		            WHERE PSL.strPromoType = 'C' 
					AND CONVERT(DATETIME,PSL.dtmPromoEndPeriod,101) <= CONVERT(DATETIME,@dtmPromoEndingPeriodDate,101)    
			   END
		  END
	      
		  IF (@strPromoMixMatchysn = 'Y' OR @strPromoMixMatchysn = 'Yes')
		  BEGIN
    		   IF(@strPromoStore IS NOT NULL)
		 	   BEGIN
			        INSERT INTO @tblPurgePromotionPreview
                    SELECT 
						'Promotion Sales' AS strPromoType
						, ST.intStoreNo
						, PSL.strPromoSalesDescription
					FROM tblSTPromotionSalesList PSL
					LEFT JOIN tblSTStore ST ON PSL.intStoreId = ST.intStoreId 
		            WHERE PSL.intStoreId IN (Select Item from dbo.fnSplitString(@strPromoStore,',')) 
				    and strPromoType = 'M' AND CONVERT(DATETIME,dtmPromoEndPeriod,101) 
			        <= CONVERT(DATETIME,@dtmPromoEndingPeriodDate,101)    
			   END

			   IF(@strPromoStore IS NULL)
		 	   BEGIN
                    INSERT INTO @tblPurgePromotionPreview
                    SELECT 
						'Promotion Sales' AS strPromoType
						, ST.intStoreNo
						, PSL.strPromoSalesDescription
					FROM tblSTPromotionSalesList PSL
					LEFT JOIN tblSTStore ST ON PSL.intStoreId = ST.intStoreId 
		            WHERE strPromoType = 'M' AND CONVERT(DATETIME,dtmPromoEndPeriod,101) 
			        <= CONVERT(DATETIME,@dtmPromoEndingPeriodDate,101)    
			   END
		  END

		  IF (@strPromoItemListysn = 'Y' OR @strPromoItemListysn = 'Yes')
		  BEGIN
    		   IF(@strPromoStore IS NOT NULL)
		 	   BEGIN
			       INSERT INTO @tblPurgePromotionPreview
		           SELECT 
						'Promotion Items' AS strPromoType
						, ST.intStoreNo
						, PIL.strPromoItemListDescription
				   FROM tblSTPromotionItemList PIL
				   LEFT JOIN tblSTStore ST ON PIL.intStoreId = ST.intStoreId 
		           WHERE  PIL.intStoreId IN (Select Item from dbo.fnSplitString(@strPromoStore,',')) AND intPromoItemListId 
			       NOT IN (SELECT intPromoItemListId FROM tblSTPromotionSalesListDetail)     
			   END

			   IF(@strPromoStore IS NULL)
		 	   BEGIN
			       INSERT INTO @tblPurgePromotionPreview
		           SELECT 
						'Promotion Items' AS strPromoType
						, ST.intStoreNo
						, PIL.strPromoItemListDescription
				   FROM tblSTPromotionItemList PIL
				   LEFT JOIN tblSTStore ST ON PIL.intStoreId = ST.intStoreId 
		           WHERE  intPromoItemListId NOT IN (SELECT intPromoItemListId FROM tblSTPromotionSalesListDetail)    
			   END
		  END
		  
	  END

      --SELECT @MiXMatchCount as MixMatchCount, @ComboCount as ComboCount, @ItemListCount as ItemListCount	
	  SELECT strPromoType
	         , strStore
			 , strPurgePromotion
	  FROM @tblPurgePromotionPreview

END TRY

BEGIN CATCH       
	 SET @ErrMsg = ERROR_MESSAGE()      
	 IF @xmlDocumentId <> 0 EXEC sp_xml_removedocument @xmlDocumentId      
	 RAISERROR(@ErrMsg, 16, 1, 'WITH NOWAIT')      
END CATCH