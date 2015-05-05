CREATE PROCEDURE [dbo].[uspSTPurgePromotions]
	@XML varchar(max)
	
AS
BEGIN TRY

    SET QUOTED_IDENTIFIER OFF
    SET ANSI_NULLS ON
    SET NOCOUNT ON
    SET XACT_ABORT ON
    SET ANSI_WARNINGS OFF

	DECLARE @ErrMsg				       NVARCHAR(MAX),
	        @idoc					   INT,
	    	@PromoLocation 		       NVARCHAR(MAX),
			@PromoEndingPeriodDate     DATETIME,
			@PromoPurgeAllRecordsysn   NVARCHAR(1),
			@PromoMixMatchysn          NVARCHAR(1),
			@PromoComboysn             NVARCHAR(1),
			@PromoItemListysn          NVARCHAR(1)


	                  
	EXEC sp_xml_preparedocument @idoc OUTPUT, @XML 
	
	SELECT	
			@PromoLocation		      =	Location,
			@PromoEndingPeriodDate    = EndingPeriodDate,
			@PromoPurgeAllRecordsysn  = PurgeAllRecordsysn,
			@PromoMixMatchysn         = MixMatchysn,
			@PromoComboysn            = Comboysn,
			@PromoItemListysn         = ItemListysn 

		
	FROM	OPENXML(@idoc, 'root',2)
	WITH
	(
			Location		        NVARCHAR(MAX),
			EndingPeriodDate        DATETIME,
			PurgeAllRecordsysn      NVARCHAR(1),
            MixMatchysn             NVARCHAR(1),
			Comboysn                NVARCHAR(1), 
			ItemListysn             NVARCHAR(1)
	
	)  

      DECLARE @SQL1 NVARCHAR(MAX)
	  DECLARE @MiXMatchCount INT 
	  DECLARE @ComboCount INT
	  DECLARE @ItemListCount INT

	  select @MiXMatchCount = 0,  @ComboCount = 0, @ItemListCount = 0

	  PRINT @PromoItemListysn


	    if (@PromoItemListysn = 'Y')
	      BEGIN
			  
			  PRINT @PromoEndingPeriodDate

              set @SQL1 = 'delete from stmixmst '
		  
		      set @SQL1 = @SQL1 + ' where 1=1 ' 

 	          if (@PromoLocation IS NOT NULL)
		      BEGIN 
		        set @SQL1 = @SQL1 +  ' and  stmix_store_name IN 
		 	     (''' + replace((SELECT (CAST(@PromoLocation AS NVARCHAR(MAX)))),',',''',''') +''')'
		      END

  	          if ((@PromoEndingPeriodDate IS NOT NULL)
		      and (@PromoPurgeAllRecordsysn = 'N'))
			      BEGIN
				    set @SQL1 = @SQL1 +  ' and  stmix_end_date  <= ''' 
			        + (SELECT CONVERT(NVARCHAR(12), CONVERT(DATETIME,@PromoEndingPeriodDate),112)) + ''''
                  END  

              exec (@SQL1)

	          set @MiXMatchCount = (select (@@ROWCOUNT))

			  set @SQL1 = 'delete from stcbomst '
		  
		      set @SQL1 = @SQL1 + ' where 1=1 ' 

 	          if (@PromoLocation IS NOT NULL)
		      BEGIN 
		        set @SQL1 = @SQL1 +  ' and  stcbo_store_name IN 
		 	     (''' + replace((SELECT (CAST(@PromoLocation AS NVARCHAR(MAX)))),',',''',''') +''')'
		      END

  	          if ((@PromoEndingPeriodDate IS NOT NULL)
		      and (@PromoPurgeAllRecordsysn = 'N'))
			      BEGIN
				    set @SQL1 = @SQL1 +  ' and  stcbo_end_date  <= ''' 
			        + (SELECT CONVERT(NVARCHAR(12), CONVERT(DATETIME,@PromoEndingPeriodDate),112)) + ''''
                  END  

              exec (@SQL1)

		      set @ComboCount = (select (@@ROWCOUNT))

			  set @SQL1 = 'delete from stitlmst '

		      set @SQL1 = @SQL1 + ' where 1=1 ' 

			  if (@PromoLocation IS NOT NULL)
		      BEGIN 
		          set @SQL1 = @SQL1 +  ' and  stitl_store_name IN 
		 	       (''' + replace((SELECT (CAST(@PromoLocation AS NVARCHAR(MAX)))),',',''',''') +''')'
              END
		      set @SQL1 = @SQL1 + ' and stitl_xml_list_id NOT IN (' + ' 
                  select stitl_xml_list_id from stitlmst a 
                  join stmixmst b on a.stitl_xml_list_id=b.stmix_itemlist_id_1 
                  or a.stitl_xml_list_id=b.stmix_itemlist_id_2 
                  or a.stitl_xml_list_id=b.stmix_itemlist_id_3
                  or a.stitl_xml_list_id=b.stmix_itemlist_id_4
                  or a.stitl_xml_list_id=b.stmix_itemlist_id_5
                  union
                  select stitl_xml_list_id from stitlmst a 
                  join stcbomst c on a.stitl_xml_list_id=c.stcbo_itemlist_id_1
                  or a.stitl_xml_list_id=c.stcbo_itemlist_id_1
                  or a.stitl_xml_list_id=c.stcbo_itemlist_id_2
                  or a.stitl_xml_list_id=c.stcbo_itemlist_id_3
                  or a.stitl_xml_list_id=c.stcbo_itemlist_id_4
                  or a.stitl_xml_list_id=c.stcbo_itemlist_id_5 '
				  + ')' 

              exec (@SQL1)
	          set @ItemListCount = (select (@@ROWCOUNT))
	       END      


	  if ((@PromoMixMatchysn = 'Y') and  (@PromoItemListysn = 'N'))
	      BEGIN
	          set @SQL1 = 'delete from stmixmst '
		  
		      set @SQL1 = @SQL1 + ' where 1=1 ' 

 	          if (@PromoLocation IS NOT NULL)
		      BEGIN 
		        set @SQL1 = @SQL1 +  ' and  stmix_store_name IN 
		 	     (''' + replace((SELECT (CAST(@PromoLocation AS NVARCHAR(MAX)))),',',''',''') +''')'
		      END

  	          if ((@PromoEndingPeriodDate IS NOT NULL)
		      and (@PromoPurgeAllRecordsysn = 'N'))
			      BEGIN
				    set @SQL1 = @SQL1 +  ' and  stmix_end_date  <= ''' 
			        + (SELECT CONVERT(NVARCHAR(12), CONVERT(DATETIME,@PromoEndingPeriodDate),112)) + ''''
                  END  
              exec (@SQL1)
	          set @MiXMatchCount = (select (@@ROWCOUNT))
	      END      

       if ((@PromoComboysn = 'Y') and (@PromoItemListysn = 'N'))
	      BEGIN
	          set @SQL1 = 'delete from stcbomst '
		  
		      set @SQL1 = @SQL1 + ' where 1=1 ' 

 	          if (@PromoLocation IS NOT NULL)
		      BEGIN 
		        set @SQL1 = @SQL1 +  ' and  stcbo_store_name IN 
		 	     (''' + replace((SELECT (CAST(@PromoLocation AS NVARCHAR(MAX)))),',',''',''') +''')'
		      END

  	          if ((@PromoEndingPeriodDate IS NOT NULL)
		      and (@PromoPurgeAllRecordsysn = 'N'))
			      BEGIN
				    set @SQL1 = @SQL1 +  ' and  stcbo_end_date  <= ''' 
			        + (SELECT CONVERT(NVARCHAR(12), CONVERT(DATETIME,@PromoEndingPeriodDate),112)) + ''''
                  END  
              exec (@SQL1)
		      set @ComboCount = (select (@@ROWCOUNT))
	      END    
		   
     select @MiXMatchCount as MixMatchCount, @ComboCount as ComboCount, @ItemListCount as ItemListCount	
		        

END TRY

BEGIN CATCH       
 SET @ErrMsg = ERROR_MESSAGE()      
 IF @idoc <> 0 EXEC sp_xml_removedocument @idoc      
 RAISERROR(@ErrMsg, 16, 1, 'WITH NOWAIT')      
END CATCH