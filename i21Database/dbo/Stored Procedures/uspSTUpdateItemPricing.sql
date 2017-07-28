CREATE PROCEDURE [dbo].[uspSTUpdateItemPricing]
	@XML varchar(max)
	
AS
BEGIN TRY
	DECLARE @ErrMsg				NVARCHAR(MAX),
	        @idoc				INT,
			@Location 			NVARCHAR(MAX),
			@Vendor             NVARCHAR(MAX),
			@Category           NVARCHAR(MAX),
			@Family             NVARCHAR(MAX),
			@Class              NVARCHAR(MAX),
			@Description        NVARCHAR(250),
			@Region             NVARCHAR(6),
			@District           NVARCHAR(6),
			@State              NVARCHAR(2),
			@UpcCode            NVARCHAR(MAX),
			@StandardCost       DECIMAL (18,6),
			@RetailPrice        DECIMAL (18,6),
			@SalesPrice         DECIMAL (18,6),
		    @SalesStartDate		NVARCHAR(50),
			@SalesEndDate   	NVARCHAR(50),
			@ysnPreview			NVARCHAR(1),
			@currentUserId		INT
		
	                  
	EXEC sp_xml_preparedocument @idoc OUTPUT, @XML 
	
	SELECT	
			@Location		 =	 Location,
            @Vendor          =   Vendor,
			@Category        =   Category,
			@Family          =   Family,
            @Class           =   Class,
            @Description     =   ItmDescription,
			@Region          =   Region,
			@District        =   District,
			@State           =   States,
			@UpcCode         =   UPCCode,
			@StandardCost 	 = 	 Cost,
			@RetailPrice   	 =	 Retail,
			@SalesPrice		 =	 SalesPrice,
			@SalesStartDate	 =	 SalesStartingDate,
			@SalesEndDate	 =	 SalesEndingDate,
			@ysnPreview		 =   ysnPreview,
			@currentUserId   =   currentUserId
		
	FROM	OPENXML(@idoc, 'root',2)
	WITH
	(
			Location		        NVARCHAR(MAX),
			Vendor	     	        NVARCHAR(MAX),
			Category		        NVARCHAR(MAX),
			Family	     	        NVARCHAR(MAX),
			Class	     	        NVARCHAR(MAX),
			ItmDescription		    NVARCHAR(250),
			Region                  NVARCHAR(6),
			District                NVARCHAR(6),
			States                  NVARCHAR(2),
			UPCCode		            NVARCHAR(MAX),
			Cost		            DECIMAL (18,6),
			Retail		            DECIMAL (18,6),
			SalesPrice       		DECIMAL (18,6),
			SalesStartingDate		NVARCHAR(50),
			SalesEndingDate			NVARCHAR(50),
			ysnPreview				NVARCHAR(1),
			currentUserId			INT
	)  
    -- Insert statements for procedure here

      DECLARE @SQL1 NVARCHAR(MAX)

	  DECLARE @UpdateCount INT
	  DECLARE @RecCount INT

	  SET @UpdateCount = 0
	  SET @RecCount = 0

	--============================================================
	-- AUDIT LOGS
	DECLARE @ItemPricingAuditLog NVARCHAR(MAX)
	SET @ItemPricingAuditLog = ''

	DECLARE @ItemSpecialPricingAuditLog NVARCHAR(MAX)
	SET @ItemSpecialPricingAuditLog = ''

	DECLARE @JsonStringAuditLog NVARCHAR(MAX)
	SET @JsonStringAuditLog = ''

	DECLARE @checkComma bit
	--============================================================

	--Declare temp01 table holder
    DECLARE @tblTempOne TABLE 
    (
		strLocation NVARCHAR(250)
		, strUpc NVARCHAR(50)
		, strItemDescription NVARCHAR(250)
		, strChangeDescription NVARCHAR(100)
		, strOldData NVARCHAR(MAX)
		, strNewData NVARCHAR(MAX)
		, intParentId INT
		, intChildId INT
    )

	--Declare temp02 table holder (w/ distinct)
    DECLARE @tblTempTwo TABLE 
    (
	    strUpc NVARCHAR(50)
		, strItemDescription NVARCHAR(250)
		, strChangeDescription NVARCHAR(100)
		, strOldData NVARCHAR(MAX)
		, strNewData NVARCHAR(MAX)
		, intParentId INT
		, intChildId INT
    )

	--Declare ParentId holder
    DECLARE @tblId TABLE 
    (
		intId INT
    )

	--=======================================================
	--Use in while loop
	DECLARE @RowCountMax INT
	SET @RowCountMax = 0

	DECLARE @RowCountMin INT
	SET @RowCountMin = 0

	DECLARE @strChangeDescription NVARCHAR(100)
	SET @strChangeDescription = ''

	DECLARE @strOldData NVARCHAR(100)
	SET @strOldData = ''

	DECLARE @strNewData NVARCHAR(100)
	SET @strNewData = ''

	DECLARE @intParentId INT
	SET @intParentId = 0

	DECLARE @intChildId INT
	SET @intChildId = 0
	--=======================================================

	--Get currency decimal
	DECLARE @CompanyCurrencyDecimal NVARCHAR(1)
	SET @CompanyCurrencyDecimal = 0
	SELECT @CompanyCurrencyDecimal = intCurrencyDecimal from tblSMCompanyPreference

 


 --tblICItemPricing
 IF (@StandardCost IS NOT NULL)
 BEGIN
   
   --SET @SQL1 = 'INSERT INTO tblSTMassUpdateReportMaster(strLocationName,UpcCode,ItemDescription,ChangeDescription,OldData,NewData,intPrentId,intChildId) 
   SET @SQL1 = 'SELECT e.strLocationName 
						, b.strUpcCode 
						, c.strDescription 
						, ''Standard Cost'' 
						, CAST(a.dblStandardCost AS DECIMAL(18, ' + @CompanyCurrencyDecimal + '))  
						, CAST(' + CAST(@StandardCost AS NVARCHAR(250)) + ' AS DECIMAL(18, ' + @CompanyCurrencyDecimal + ')) 
						, c.intItemId 
						, a.intItemPricingId 
				FROM tblICItemPricing a 
				JOIN tblICItemUOM b ON a.intItemId = b.intItemId 
				JOIN tblICItem c ON a.intItemId = c.intItemId 
				JOIN tblICItemLocation d ON a.intItemId = d.intItemId 
				JOIN tblSMCompanyLocation e ON d.intLocationId = e.intCompanyLocationId '

SET @SQL1 = @SQL1 + ' WHERE 1=1 ' 

 IF (@Location IS NOT NULL)
        BEGIN 
           SET @SQL1 = @SQL1 + ' and d.intLocationId IN (' + CAST(@Location as NVARCHAR) + ')'
        END

IF (@Vendor IS NOT NULL)
    BEGIN 
         set @SQL1 = @SQL1 +  ' and  a.intItemLocationId 
         IN (select intItemLocationId from tblICItemLocation where intVendorId 
         IN (select intEntityId from tblEMEntity where intEntityId 
   	     IN (' + CAST(@Vendor as NVARCHAR) + ')' + '))' 
    END

 IF (@Category IS NOT NULL)
     BEGIN
             set @SQL1 = @SQL1 +  ' and a.intItemId  
         IN (select intItemId from tblICItem where intCategoryId IN 
         (select intCategoryId from tblICCategory where intCategoryId 
	     IN (' + CAST(@Category as NVARCHAR) + ')' + '))' 
     END

  IF (@Family IS NOT NULL)
      BEGIN
           set @SQL1 = @SQL1 +  ' and a.intItemLocationId IN 
           (select intItemLocationId from tblICItemLocation where intFamilyId IN 
           (select intFamilyId from tblICItemLocation where intFamilyId 
	        IN (' + CAST(@Family as NVARCHAR) + ')' + '))' 
       END

   IF (@Class  IS NOT NULL)
      BEGIN
          set @SQL1 = @SQL1 +  ' and a.intItemLocationId IN 
          (select intItemLocationId from tblICItemLocation where intClassId IN 
          (select intClassId from tblICItemLocation where intClassId 
		  IN (' + CAST(@Class as NVARCHAR) + ')' + '))' 
      END

      IF (@UpcCode IS NOT NULL)
           BEGIN
	           set @SQL1 = @SQL1 +  ' and b.intItemUOMId IN (' + CAST(@UpcCode as NVARCHAR) + ')' 
           END


     IF ((@Region IS NOT NULL)
	 and(@Region != ''))
	     BEGIN
			 set @SQL1 = @SQL1 +  ' and a.intItemLocationId IN 
			 (select intItemLocationId from tblICItemLocation where intLocationId IN 
			 (select intCompanyLocationId from tblSTStore where strRegion 
			 IN ( ''' + (@Region) + ''')' + '))' 
	      END

	  IF ((@District IS NOT NULL)
	  and(@District != ''))
		  BEGIN
			 set @SQL1 = @SQL1 +  ' and a.intItemLocationId IN 
			 (select intItemLocationId from tblICItemLocation where intLocationId IN 
			 (select intCompanyLocationId from tblSTStore where strDistrict 
			 IN ( ''' + (@District) + ''')' + '))'
		  END

        IF ((@State IS NOT NULL)
	  and(@State != ''))
		  BEGIN
			 set @SQL1 = @SQL1 +  ' and a.intItemLocationId IN 
			 (select intItemLocationId from tblICItemLocation where intLocationId IN 
			 (select intCompanyLocationId from tblSTStore where strState 
			 IN ( ''' + (@State) + ''')' + '))' 
		  END

         IF ((@Description IS NOT NULL)
	   and (@Description != ''))
		BEGIN
		   set @SQL1 = @SQL1 +  ' and a.intItemId IN 
		   (select intItemId from tblICItem where strDescription 
		    like ''%' + LTRIM(@Description) + '%'' )' 
		END
 
	INSERT @tblTempOne
	EXEC (@SQL1)

 END 

 IF (@RetailPrice IS NOT NULL)
 BEGIN

   --SET @SQL1 = 'INSERT INTO tblSTMassUpdateReportMaster(strLocationName,UpcCode,ItemDescription,ChangeDescription,OldData,NewData,intPrentId,intChildId) 
   SET @SQL1 = 'SELECT e.strLocationName 
					  , b.strUpcCode 
					  , c.strDescription 
					  , ''Retail Price'' 
					  , CAST(a.dblSalePrice AS DECIMAL(18, ' + @CompanyCurrencyDecimal + '))  
					  , CAST(' + CAST(@RetailPrice AS NVARCHAR(250)) + ' AS DECIMAL(18, ' + @CompanyCurrencyDecimal + ')) 
					  , c.intItemId 
					  , a.intItemPricingId 
			  FROM tblICItemPricing a JOIN tblICItemUOM b ON a.intItemId = b.intItemId 
			  JOIN tblICItem c ON a.intItemId = c.intItemId 
			  JOIN tblICItemLocation d ON a.intItemId = d.intItemId 
			  JOIN tblSMCompanyLocation e ON d.intLocationId = e.intCompanyLocationId '

 SET @SQL1 = @SQL1 + ' where 1=1 ' 

 IF (@Location IS NOT NULL)
        BEGIN 
           SET @SQL1 = @SQL1 + ' and d.intLocationId IN (' + CAST(@Location as NVARCHAR) + ')'
        END

IF (@Vendor IS NOT NULL)
    BEGIN 
         set @SQL1 = @SQL1 +  ' and  a.intItemLocationId
         IN (select intItemLocationId from tblICItemLocation where intVendorId
         IN (select intEntityId from tblEMEntity where intEntityId 
   	     IN (' + CAST(@Vendor as NVARCHAR) + ')' + '))'
    END

 IF (@Category IS NOT NULL)
     BEGIN
             set @SQL1 = @SQL1 +  ' and a.intItemId  
         IN (select intItemId from tblICItem where intCategoryId IN
         (select intCategoryId from tblICCategory where intCategoryId 
	     IN (' + CAST(@Category as NVARCHAR) + ')' + '))'
     END

  IF (@Family IS NOT NULL)
      BEGIN
           set @SQL1 = @SQL1 +  ' and a.intItemLocationId IN 
           (select intItemLocationId from tblICItemLocation where intFamilyId IN
           (select intFamilyId from tblICItemLocation where intFamilyId 
	        IN (' + CAST(@Family as NVARCHAR) + ')' + '))'
       END

   IF (@Class  IS NOT NULL)
      BEGIN
          set @SQL1 = @SQL1 +  ' and a.intItemLocationId IN 
          (select intItemLocationId from tblICItemLocation where intClassId IN
          (select intClassId from tblICItemLocation where intClassId 
		  IN (' + CAST(@Class as NVARCHAR) + ')' + '))'
      END

	IF (@UpcCode IS NOT NULL)
           BEGIN
	           set @SQL1 = @SQL1 +  ' and b.intItemUOMId IN (' + CAST(@UpcCode as NVARCHAR) + ')'
           END

     IF ((@Region IS NOT NULL)
	 and(@Region != ''))
	     BEGIN
			 set @SQL1 = @SQL1 +  ' and a.intItemLocationId IN 
			 (select intItemLocationId from tblICItemLocation where intLocationId IN 
			 (select intCompanyLocationId from tblSTStore where strRegion 
			 IN ( ''' + (@Region) + ''')' + '))'
	      END

	  IF ((@District IS NOT NULL)
	  and(@District != ''))
		  BEGIN
			 set @SQL1 = @SQL1 +  ' and a.intItemLocationId IN 
			 (select intItemLocationId from tblICItemLocation where intLocationId IN 
			 (select intCompanyLocationId from tblSTStore where strDistrict 
			 IN ( ''' + (@District) + ''')' + '))'
		  END

        IF ((@State IS NOT NULL)
	  and(@State != ''))
		  BEGIN
			 set @SQL1 = @SQL1 +  ' and a.intItemLocationId IN 
			 (select intItemLocationId from tblICItemLocation where intLocationId IN 
			 (select intCompanyLocationId from tblSTStore where strState 
			 IN ( ''' + (@State) + ''')' + '))'
		  END

         IF ((@Description IS NOT NULL)
	   and (@Description != ''))
		BEGIN
		   set @SQL1 = @SQL1 +  ' and a.intItemId IN 
		   (select intItemId from tblICItem where strDescription 
		    like ''%' + LTRIM(@Description) + '%'' )'
		END

	INSERT @tblTempOne
	EXEC (@SQL1)
 END 


 --tblICItemSpecialPricing
 IF (@SalesPrice IS NOT NULL)
 BEGIN

    --SET @SQL1 = 'INSERT INTO tblSTMassUpdateReportMaster(strLocationName,UpcCode,ItemDescription,ChangeDescription,OldData,NewData,intPrentId,intChildId)
    SET @SQL1 = 'SELECT e.strLocationName
				      , b.strUpcCode
					  , c.strDescription
					  , ''Sales Price''
					  , CAST(a.dblUnitAfterDiscount AS DECIMAL(18, ' + @CompanyCurrencyDecimal + ')) 
					  , CAST(' + CAST(@SalesPrice AS NVARCHAR(250)) + ' AS DECIMAL(18, ' + @CompanyCurrencyDecimal + ')) 
					  , c.intItemId 
					  , a.intItemSpecialPricingId 
				 FROM tblICItemSpecialPricing a 
				 JOIN tblICItemUOM b ON a.intItemUnitMeasureId = b.intItemUOMId 
				 JOIN tblICItem c ON a.intItemId = c.intItemId 
				 JOIN tblICItemLocation d ON a.intItemId = d.intItemId 
				 JOIN tblSMCompanyLocation e ON d.intLocationId = e.intCompanyLocationId '

    SET @SQL1 = @SQL1 + ' where 1=1 ' 

    IF (@Location IS NOT NULL)
       BEGIN 
           SET @SQL1 = @SQL1 + ' and d.intLocationId IN (' + CAST(@Location as NVARCHAR) + ')'
       END 

    IF (@Vendor IS NOT NULL)
       BEGIN 
             set @SQL1 = @SQL1 +  ' and  a.intItemLocationId
             IN (select intItemLocationId from tblICItemLocation where intVendorId
             IN (select intEntityId from tblEMEntity where intEntityId 
			 IN (' + CAST(@Vendor as NVARCHAR) + ')' + '))'
       END

	IF (@Category IS NOT NULL)
         BEGIN
                  set @SQL1 = @SQL1 +  ' and a.intItemId  
              IN (select intItemId from tblICItem where intCategoryId IN
              (select intCategoryId from tblICCategory where intCategoryId
			   IN (' + CAST(@Category as NVARCHAR) + ')' + '))'
         END

	IF (@Family IS NOT NULL)
         BEGIN
              set @SQL1 = @SQL1 +  ' and a.intItemLocationId IN 
              (select intItemLocationId from tblICItemLocation where intFamilyId IN
              (select intFamilyId from tblICItemLocation where intFamilyId 
			  IN (' + CAST(@Family as NVARCHAR) + ')' + '))'
         END

	IF (@Class IS NOT NULL)
          BEGIN
              set @SQL1 = @SQL1 +  ' and a.intItemLocationId IN 
              (select intItemLocationId from tblICItemLocation where intClassId IN
              (select intClassId from tblICItemLocation where intClassId 
			  IN (' + CAST(@Class as NVARCHAR) + ')' + '))'
           END

	IF (@UpcCode IS NOT NULL)
           BEGIN
	           set @SQL1 = @SQL1 +  ' and a.intItemUnitMeasureId IN (' + CAST(@UpcCode as NVARCHAR) + ')'
           END

	IF ((@Region IS NOT NULL)
    and(@Region != ''))
			BEGIN
			 set @SQL1 = @SQL1 +  ' and a.intItemLocationId IN 
			 (select intItemLocationId from tblICItemLocation where intLocationId IN 
			 (select intCompanyLocationId from tblSTStore where strRegion 
			 IN ( ''' + (@Region) + ''')' + '))'
			END

	IF ((@District IS NOT NULL)
    and(@District != ''))
			BEGIN
			 set @SQL1 = @SQL1 +  ' and a.intItemLocationId IN 
			 (select intItemLocationId from tblICItemLocation where intLocationId IN 
			 (select intCompanyLocationId from tblSTStore where strDistrict 
			 IN ( ''' + (@District) + ''')' + '))'
			END

      IF ((@State IS NOT NULL)
	and(@State != ''))
			BEGIN
			 set @SQL1 = @SQL1 +  ' and a.intItemLocationId IN 
			 (select intItemLocationId from tblICItemLocation where intLocationId IN 
			 (select intCompanyLocationId from tblSTStore where strState 
			 IN ( ''' + (@State) + ''')' + '))'
			END

      IF ((@Description IS NOT NULL)
    and (@Description != ''))
		BEGIN
		   set @SQL1 = @SQL1 +  ' and a.intItemId IN 
		   (select intItemId from tblICItem where strDescription 
		    like ''%' + LTRIM(@Description) + '%'' )'
		END

		set @SQL1 = @SQL1 + ' and  a.strPromotionType = ''Discount''' 

		INSERT @tblTempOne
		EXEC (@SQL1)
 END 

 IF (@SalesStartDate IS NOT NULL)
 BEGIN

      SET @SalesStartDate = CONVERT(VARCHAR(10),@SalesStartDate,111)
      --SET @SQL1 = 'INSERT INTO tblSTMassUpdateReportMaster(strLocationName,UpcCode,ItemDescription,ChangeDescription,OldData,NewData,intPrentId,intChildId) 
      SET @SQL1 = 'SELECT e.strLocationName 
					   , b.strUpcCode 
					   , c.strDescription 
					   , ''Sales start date'' 
					   , REPLACE(CONVERT(NVARCHAR(10),a.dtmBeginDate,111), ''/'', ''-'') 
					   , ''' + CAST(@SalesStartDate as NVARCHAR(250)) + ''' 
					   , c.intItemId 
					   , a.intItemSpecialPricingId 
				   FROM tblICItemSpecialPricing a 
				   JOIN tblICItemUOM b ON a.intItemUnitMeasureId = b.intItemUOMId 
				   JOIN tblICItem c ON a.intItemId = c.intItemId 
				   JOIN tblICItemLocation d ON a.intItemId = d.intItemId 
				   JOIN tblSMCompanyLocation e ON d.intLocationId = e.intCompanyLocationId '

	SET @SQL1 = @SQL1 + ' where 1=1 ' 

    IF (@Location IS NOT NULL)
        BEGIN 
           SET @SQL1 = @SQL1 + ' and d.intLocationId IN (' + CAST(@Location as NVARCHAR) + ')'
        END

    IF (@Vendor IS NOT NULL)
       BEGIN 
             set @SQL1 = @SQL1 +  ' and  a.intItemLocationId
             IN (select intItemLocationId from tblICItemLocation where intVendorId
             IN (select intEntityId from tblEMEntity where intEntityId 
			 IN (' + CAST(@Vendor as NVARCHAR) + ')' + '))'
       END

	  if (@Category IS NOT NULL)
         BEGIN
                  set @SQL1 = @SQL1 +  ' and a.intItemId  
              IN (select intItemId from tblICItem where intCategoryId IN
              (select intCategoryId from tblICCategory where intCategoryId
			   IN (' + CAST(@Category as NVARCHAR) + ')' + '))'
         END

	  if (@Family IS NOT NULL)
         BEGIN
              set @SQL1 = @SQL1 +  ' and a.intItemLocationId IN 
              (select intItemLocationId from tblICItemLocation where intFamilyId IN
              (select intFamilyId from tblICItemLocation where intFamilyId 
			  IN (' + CAST(@Family as NVARCHAR) + ')' + '))'
         END

	  if (@Class IS NOT NULL)
          BEGIN
              set @SQL1 = @SQL1 +  ' and a.intItemLocationId IN 
              (select intItemLocationId from tblICItemLocation where intClassId IN
              (select intClassId from tblICItemLocation where intClassId 
			  IN (' + CAST(@Class as NVARCHAR) + ')' + '))'
           END

	  if (@UpcCode IS NOT NULL)
          BEGIN
	          set @SQL1 = @SQL1 +  ' and a.intItemUnitMeasureId IN (' + CAST(@UpcCode as NVARCHAR) + ')'
           END

	  if ((@Region IS NOT NULL)
	  and(@Region != ''))
			BEGIN
			 set @SQL1 = @SQL1 +  ' and a.intItemLocationId IN 
			 (select intItemLocationId from tblICItemLocation where intLocationId IN 
			 (select intCompanyLocationId from tblSTStore where strRegion 
			 IN ( ''' + (@Region) + ''')' + '))'
			END

	  if ((@District IS NOT NULL)
	  and(@District != ''))
		 BEGIN
			 set @SQL1 = @SQL1 +  ' and a.intItemLocationId IN 
			 (select intItemLocationId from tblICItemLocation where intLocationId IN 
			 (select intCompanyLocationId from tblSTStore where strDistrict 
			 IN ( ''' + (@District) + ''')' + '))'
		END

        if ((@State IS NOT NULL)
	  and(@State != ''))
			BEGIN
			 set @SQL1 = @SQL1 +  ' and a.intItemLocationId IN 
			 (select intItemLocationId from tblICItemLocation where intLocationId IN 
			 (select intCompanyLocationId from tblSTStore where strState 
			 IN ( ''' + (@State) + ''')' + '))'
			END

        if ((@Description IS NOT NULL)
	  and (@Description != ''))
	     BEGIN
		   set @SQL1 = @SQL1 +  ' and a.intItemId IN 
		   (select intItemId from tblICItem where strDescription 
		    like ''%' + LTRIM(@Description) + '%'' )'
		END

		set @SQL1 = @SQL1 + ' and  a.strPromotionType = ''Discount''' 
   
   INSERT @tblTempOne
   EXEC (@SQL1)
 END 

 IF (@SalesEndDate IS NOT NULL)
 BEGIN
 
      SET @SalesEndDate = CONVERT(VARCHAR(10),@SalesEndDate,111)
      --SET @SQL1 = 'INSERT INTO tblSTMassUpdateReportMaster(strLocationName,UpcCode,ItemDescription,ChangeDescription,OldData,NewData)
      SET @SQL1 = 'SELECT e.strLocationName
					   , b.strUpcCode
					   , c.strDescription
					   , ''Sales end date''
					   , REPLACE(CONVERT(NVARCHAR(10),a.dtmEndDate,111), ''/'', ''-'')
					   , ''' + CAST(@SalesEndDate as NVARCHAR(250)) + ''' 
					   , c.intItemId 
					   , a.intItemSpecialPricingId 
				   FROM tblICItemSpecialPricing a 
				   JOIN tblICItemUOM b ON a.intItemUnitMeasureId = b.intItemUOMId 
				   JOIN tblICItem c ON a.intItemId = c.intItemId 
				   JOIN tblICItemLocation d ON a.intItemId = d.intItemId 
				   JOIN tblSMCompanyLocation e ON d.intLocationId = e.intCompanyLocationId '

	SET @SQL1 = @SQL1 + ' where 1=1 ' 

    IF (@Location IS NOT NULL)
        BEGIN 
           SET @SQL1 = @SQL1 + ' and d.intLocationId IN (' + CAST(@Location as NVARCHAR) + ')'
        END

    IF (@Vendor IS NOT NULL)
       BEGIN 
             set @SQL1 = @SQL1 +  ' and  a.intItemLocationId
             IN (select intItemLocationId from tblICItemLocation where intVendorId
             IN (select intEntityId from tblEMEntity where intEntityId 
			 IN (' + CAST(@Vendor as NVARCHAR) + ')' + '))'
       END

	  if (@Category IS NOT NULL)
         BEGIN
                  set @SQL1 = @SQL1 +  ' and a.intItemId  
              IN (select intItemId from tblICItem where intCategoryId IN
              (select intCategoryId from tblICCategory where intCategoryId
			   IN (' + CAST(@Category as NVARCHAR) + ')' + '))'
         END

	  if (@Family IS NOT NULL)
         BEGIN
              set @SQL1 = @SQL1 +  ' and a.intItemLocationId IN 
              (select intItemLocationId from tblICItemLocation where intFamilyId IN
              (select intFamilyId from tblICItemLocation where intFamilyId 
			  IN (' + CAST(@Family as NVARCHAR) + ')' + '))'
         END

	  if (@Class IS NOT NULL)
          BEGIN
              set @SQL1 = @SQL1 +  ' and a.intItemLocationId IN 
              (select intItemLocationId from tblICItemLocation where intClassId IN
              (select intClassId from tblICItemLocation where intClassId 
			  IN (' + CAST(@Class as NVARCHAR) + ')' + '))'
           END

	   if (@UpcCode IS NOT NULL)
           BEGIN
	           set @SQL1 = @SQL1 +  ' and a.intItemUnitMeasureId IN (' + CAST(@UpcCode as NVARCHAR) + ')'
           END

	    if ((@Region IS NOT NULL)
		and(@Region != ''))
			BEGIN
			 set @SQL1 = @SQL1 +  ' and a.intItemLocationId IN 
			 (select intItemLocationId from tblICItemLocation where intLocationId IN 
			 (select intCompanyLocationId from tblSTStore where strRegion 
			 IN ( ''' + (@Region) + ''')' + '))'
			END

	    if ((@District IS NOT NULL)
		and(@District != ''))
			BEGIN
			 set @SQL1 = @SQL1 +  ' and a.intItemLocationId IN 
			 (select intItemLocationId from tblICItemLocation where intLocationId IN 
			 (select intCompanyLocationId from tblSTStore where strDistrict 
			 IN ( ''' + (@District) + ''')' + '))'
			END

          if ((@State IS NOT NULL)
		and(@State != ''))
			BEGIN
			 set @SQL1 = @SQL1 +  ' and a.intItemLocationId IN 
			 (select intItemLocationId from tblICItemLocation where intLocationId IN 
			 (select intCompanyLocationId from tblSTStore where strState 
			 IN ( ''' + (@State) + ''')' + '))'
			END

          if ((@Description IS NOT NULL)
		and (@Description != ''))
		BEGIN
		   set @SQL1 = @SQL1 +  ' and a.intItemId IN 
		   (select intItemId from tblICItem where strDescription 
		    like ''%' + LTRIM(@Description) + '%'' )'
		END

		set @SQL1 = @SQL1 + ' and  a.strPromotionType = ''Discount''' 

	INSERT @tblTempOne
	EXEC (@SQL1)
END 

--NEW
SELECT @RecCount  = count(*) from @tblTempOne 
DELETE FROM @tblTempOne WHERE strOldData = strNewData
SELECT @UpdateCount = count(*) from @tblTempOne WHERE strOldData !=  strNewData

--OLD
--SELECT @RecCount  = count(*) from tblSTMassUpdateReportMaster 
--DELETE FROM tblSTMassUpdateReportMaster WHERE OldData =  NewData
--SELECT @UpdateCount = count(*) from tblSTMassUpdateReportMaster WHERE OldData !=  NewData
	  







 IF ((@ysnPreview != 'Y')
 AND (@UpdateCount > 0))
 BEGIN
       
     SET @UpdateCount = 0 
     
     IF ((@StandardCost IS NOT NULL)
     OR (@RetailPrice IS NOT NULL))
     BEGIN

	         set @SQL1 = ' update tblICItemPricing set '

		     if (@StandardCost IS NOT NULL)
             BEGIN
                set @SQL1 = @SQL1 + 'dblStandardCost = ''' + LTRIM(@StandardCost) + ''''
	         END

		     if (@RetailPrice IS NOT NULL)  
             BEGIN
               if (@StandardCost IS NOT NULL)
                  set @SQL1 = @SQL1 + ' , dblSalePrice = ''' + LTRIM(@RetailPrice) + ''''
               else
                  set @SQL1 = @SQL1 + ' dblSalePrice = ''' + LTRIM(@RetailPrice) + '''' 
	         END

             set @SQL1 = @SQL1 + ' where 1=1 ' 
	    
		   if (@Location IS NOT NULL)
	          BEGIN 
	                set @SQL1 = @SQL1 +  ' and  tblICItemPricing.intItemLocationId
	                IN (select intItemLocationId from tblICItemLocation where intLocationId
	                IN (select intLocationId from tblICItemLocation where intLocationId 
					IN (' + CAST(@Location as NVARCHAR) + ')' + '))'
	          END

		   if (@Vendor IS NOT NULL)
	           BEGIN 
	                 set @SQL1 = @SQL1 +  ' and  tblICItemPricing.intItemLocationId
	                 IN (select intItemLocationId from tblICItemLocation where intVendorId
	                 IN (select intEntityId from tblEMEntity where intEntityId 
				     IN (' + CAST(@Vendor as NVARCHAR) + ')' + '))'
	           END

		   if (@Category IS NOT NULL)
	           BEGIN
	                 set @SQL1 = @SQL1 +  ' and tblICItemPricing.intItemId  
	                 IN (select intItemId from tblICItem where intCategoryId IN
		             (select intCategoryId from tblICCategory where intCategoryId 
					 IN (' + CAST(@Category as NVARCHAR) + ')' + '))'
	           END

		   if (@Family IS NOT NULL)
	           BEGIN
		              set @SQL1 = @SQL1 +  ' and tblICItemPricing.intItemLocationId IN 
		              (select intItemLocationId from tblICItemLocation where intFamilyId IN
		              (select intFamilyId from tblICItemLocation where intFamilyId 
					  IN (' + CAST(@Family as NVARCHAR) + ')' + '))'
	           END

			if (@Class  IS NOT NULL)
	            BEGIN
	                  set @SQL1 = @SQL1 +  ' and tblICItemPricing.intItemLocationId IN 
		              (select intItemLocationId from tblICItemLocation where intClassId IN
		              (select intClassId from tblICItemLocation where intClassId 
					  IN (' + CAST(@Class as NVARCHAR) + ')' + '))'
	             END

		    if (@UpcCode IS NOT NULL)
		        BEGIN
			          set @SQL1 = @SQL1 +  ' and tblICItemPricing.intItemId  
                     IN (select intItemId from tblICItemUOM where  intItemUOMId IN
	                  (select intItemUOMId from tblICItemUOM  where intItemUOMId 
					  IN (' + CAST(@UpcCode as NVARCHAR) + ')' + '))'
		        END

		    if ((@Region IS NOT NULL)
			and(@Region != ''))
			 	   BEGIN
					 set @SQL1 = @SQL1 +  ' and tblICItemPricing.intItemLocationId IN 
					 (select intItemLocationId from tblICItemLocation where intLocationId IN 
					 (select intCompanyLocationId from tblSTStore where strRegion 
					 IN ( ''' + (@Region) + ''')' + '))'
			       END

			if ((@District IS NOT NULL)
			and(@District != ''))
			    BEGIN
			 		 set @SQL1 = @SQL1 +  ' and tblICItemPricing.intItemLocationId IN 
					 (select intItemLocationId from tblICItemLocation where intLocationId IN 
					 (select intCompanyLocationId from tblSTStore where strDistrict 
					 IN ( ''' + (@District) + ''')' + '))'
				END

           if ((@State IS NOT NULL)
			and(@State != ''))
			    BEGIN
				   set @SQL1 = @SQL1 +  ' and tblICItemPricing.intItemLocationId IN 
				   (select intItemLocationId from tblICItemLocation where intLocationId IN 
				   (select intCompanyLocationId from tblSTStore where strState 
					IN ( ''' + (@State) + ''')' + '))'
				END

           if ((@Description IS NOT NULL)
			and (@Description != ''))
				BEGIN
				   set @SQL1 = @SQL1 +  ' and tblICItemPricing.intItemId IN 
				   (select intItemId from tblICItem where strDescription 
				    like ''%' + LTRIM(@Description) + '%'' )'
				END
      EXEC (@SQL1)
      SELECT  @UpdateCount =   @UpdateCount + (@@ROWCOUNT) 
	  END

	  IF ((@SalesPrice IS NOT NULL)
	  OR (@SalesStartDate IS NOT NULL)
	  OR (@SalesEndDate IS NOT NULL))
	  BEGIN
	       set @SQL1 = ' update tblICItemSpecialPricing set '

		   if (@SalesPrice IS NOT NULL)
           BEGIN
             set @SQL1 = @SQL1 + 'dblUnitAfterDiscount = ''' + LTRIM(@SalesPrice) + ''''
	       END

		   if (@SalesStartDate IS NOT NULL)  
          BEGIN
              if (@SalesPrice IS NOT NULL)
                  set @SQL1 = @SQL1 + ' , dtmBeginDate = ''' + LTRIM(@SalesStartDate) + ''''
             else
                set @SQL1 = @SQL1 + ' dtmBeginDate = ''' + LTRIM(@SalesStartDate) + '''' 
	       END

		   if (@SalesEndDate IS NOT NULL)  
          BEGIN
              if ((@SalesPrice IS NOT NULL)
			   OR (@SalesStartDate IS NOT NULL))
                  set @SQL1 = @SQL1 + ' , dtmEndDate = ''' + LTRIM(@SalesEndDate) + ''''
             else
                  set @SQL1 = @SQL1 + ' dtmEndDate = ''' + LTRIM(@SalesEndDate) + '''' 
	       END

		   set @SQL1 = @SQL1 + ' where 1=1 ' 

		   if (@Location IS NOT NULL)
	          BEGIN 
	                set @SQL1 = @SQL1 +  ' and  tblICItemSpecialPricing.intItemLocationId
	                IN (select intItemLocationId from tblICItemLocation where intLocationId
	                IN (select intLocationId from tblICItemLocation where intLocationId
					IN (' + CAST(@Location as NVARCHAR) + ')' + '))'
	          END

		   if (@Vendor IS NOT NULL)
	           BEGIN 
	                 set @SQL1 = @SQL1 +  ' and  tblICItemSpecialPricing.intItemLocationId
	                 IN (select intItemLocationId from tblICItemLocation where intVendorId
	                 IN (select intEntityId from tblEMEntity where intEntityId 
					 IN (' + CAST(@Vendor as NVARCHAR) + ')' + '))'
	           END

			  if (@Category IS NOT NULL)
	             BEGIN
	                  set @SQL1 = @SQL1 +  ' and tblICItemSpecialPricing.intItemId  
	                  IN (select intItemId from tblICItem where intCategoryId IN
		              (select intCategoryId from tblICCategory where intCategoryId
					   IN (' + CAST(@Category as NVARCHAR) + ')' + '))'
	             END

			  if (@Family IS NOT NULL)
	             BEGIN
		              set @SQL1 = @SQL1 +  ' and tblICItemSpecialPricing.intItemLocationId IN 
		              (select intItemLocationId from tblICItemLocation where intFamilyId IN
		              (select intFamilyId from tblICItemLocation where intFamilyId 
					  IN (' + CAST(@Family as NVARCHAR) + ')' + '))'
	             END

			  if (@Class IS NOT NULL)
	              BEGIN
	                  set @SQL1 = @SQL1 +  ' and tblICItemSpecialPricing.intItemLocationId IN 
		              (select intItemLocationId from tblICItemLocation where intClassId IN
		              (select intClassId from tblICItemLocation where intClassId 
					  IN (' + CAST(@Class as NVARCHAR) + ')' + '))'
	               END

			   if (@UpcCode IS NOT NULL)
		           BEGIN
			           set @SQL1 = @SQL1 +  ' and tblICItemSpecialPricing.intItemId  
                      IN (select intItemId from tblICItemUOM where  intItemUOMId IN
	                   (select intItemUOMId from tblICItemUOM  where intItemUOMId 
					   IN (' + CAST(@UpcCode as NVARCHAR) + ')' + '))'
		           END

			    if ((@Region IS NOT NULL)
				and(@Region != ''))
					BEGIN
					 set @SQL1 = @SQL1 +  ' and tblICItemSpecialPricing.intItemLocationId IN 
					 (select intItemLocationId from tblICItemLocation where intLocationId IN 
					 (select intCompanyLocationId from tblSTStore where strRegion 
					 IN ( ''' + (@Region) + ''')' + '))'
					END

			    if ((@District IS NOT NULL)
				and(@District != ''))
					BEGIN
					 set @SQL1 = @SQL1 +  ' and tblICItemSpecialPricing.intItemLocationId IN 
					 (select intItemLocationId from tblICItemLocation where intLocationId IN 
					 (select intCompanyLocationId from tblSTStore where strDistrict 
					 IN ( ''' + (@District) + ''')' + '))'
					END

               if ((@State IS NOT NULL)
				and(@State != ''))
					BEGIN
					 set @SQL1 = @SQL1 +  ' and tblICItemSpecialPricing.intItemLocationId IN 
					 (select intItemLocationId from tblICItemLocation where intLocationId IN 
					 (select intCompanyLocationId from tblSTStore where strState 
					 IN ( ''' + (@State) + ''')' + '))'
					END

               if ((@Description IS NOT NULL)
				and (@Description != ''))
				BEGIN
				   set @SQL1 = @SQL1 +  ' and tblICItemSpecialPricing.intItemId IN 
				   (select intItemId from tblICItem where strDescription 
				    like ''%' + LTRIM(@Description) + '%'' )'
				END

				SET @SQL1 = @SQL1 + ' and  strPromotionType = ''Discount''' 
				EXEC (@SQL1)
                SELECT  @UpdateCount =   @UpdateCount + (@@ROWCOUNT)   
	  END
 END
     

	--AUDIT LOG

	--use distinct to table Id's
	INSERT INTO @tblId(intId)
	SELECT DISTINCT intChildId 
	--FROM tblSTMassUpdateReportMaster
	FROM @tblTempOne
	ORDER BY intChildId ASC

	--==========================================================================================================================================
	WHILE EXISTS (SELECT TOP (1) 1 FROM @tblId)
	BEGIN
		SELECT TOP 1 @intChildId = intId FROM @tblId

		--use distinct to table tempOne
		DELETE FROM @tblTempTwo
		INSERT INTO @tblTempTwo(strUpc, strItemDescription, strChangeDescription, strOldData, strNewData, intParentId, intChildId)
		SELECT DISTINCT strUpc
						, strItemDescription
						, strChangeDescription
						, strOldData
						, strNewData
						, intParentId
						, intChildId 
		--FROM tblSTMassUpdateReportMaster
		FROM @tblTempOne
		WHERE intChildId = @intChildId
		ORDER BY intChildId ASC

		SET @RowCountMin = 1
		SELECT @RowCountMax = Count(*) FROM @tblTempTwo

			WHILE(@RowCountMin <= @RowCountMax)
			BEGIN
				SELECT TOP(1) @strChangeDescription = strChangeDescription, @strOldData = strOldData, @strNewData = strNewData, @intParentId = intParentId from @tblTempTwo
			    
				IF(@strChangeDescription = 'Standard Cost' OR @strChangeDescription = 'Retail Price')
				BEGIN
					SET @ItemPricingAuditLog = @ItemPricingAuditLog + '{"change":"dblStandardCost","from":"' + @strOldData + '","to":"' + @strNewData + '","leaf":true,"iconCls":"small-gear","isField":true,"keyValue":' + CAST(@intChildId AS NVARCHAR(50)) + ',"associationKey":"tblICItemPricings","changeDescription":"' + @strChangeDescription + '","hidden":false},'
				END

				ELSE IF(@strChangeDescription = 'Sales Price' OR @strChangeDescription = 'Sales start date' OR @strChangeDescription = 'Sales end date')
				BEGIN
					SET @ItemSpecialPricingAuditLog = @ItemSpecialPricingAuditLog + '{"change":"dblStandardCost","from":"' + @strOldData + '","to":"' + @strNewData + '","leaf":true,"iconCls":"small-gear","isField":true,"keyValue":' + CAST(@intChildId AS NVARCHAR(50)) + ',"associationKey":"tblICItemSpecialPricings","changeDescription":"' + @strChangeDescription + '","hidden":false},'
				END

				SET @RowCountMin = @RowCountMin + 1
				DELETE TOP (1) FROM @tblTempTwo
			END


		--INSERT to AUDITLOG
		--=================================================================================================
		--tblICItemPricing
		IF (@ItemPricingAuditLog != '')
		BEGIN
			--Remove last character comma(,)
			SET @ItemPricingAuditLog = left(@ItemPricingAuditLog, len(@ItemPricingAuditLog)-1)

			SET @ItemPricingAuditLog = '{"change":"tblICItemPricings","children":[{"action":"Updated","change":"Updated - Record: ' + CAST(@intChildId AS NVARCHAR(50)) + '","keyValue":' + CAST(@intChildId AS NVARCHAR(50)) + ',"iconCls":"small-tree-modified","children":[' + @ItemPricingAuditLog + ']}],"iconCls":"small-tree-grid","changeDescription":"Pricing"},'
		END

		--tblICItemSpecialPricing
		IF (@ItemSpecialPricingAuditLog != '')
		BEGIN
			--Remove last character comma(,)
			SET @ItemSpecialPricingAuditLog = left(@ItemSpecialPricingAuditLog, len(@ItemSpecialPricingAuditLog)-1)

			SET @ItemSpecialPricingAuditLog = '{"change":"tblICItemSpecialPricings","children":[{"action":"Updated","change":"Updated - Record: ' + CAST(@intChildId AS NVARCHAR(50)) + '","keyValue":' + CAST(@intChildId AS NVARCHAR(50)) + ',"iconCls":"small-tree-modified","children":[' + @ItemSpecialPricingAuditLog + ']}],"iconCls":"small-tree-grid","changeDescription":"Promotional Pricing"},'
		END

		SET @JsonStringAuditLog = @ItemPricingAuditLog + @ItemSpecialPricingAuditLog


		SELECT @checkComma = CASE WHEN RIGHT(@JsonStringAuditLog, 1) IN (',') THEN 1 ELSE 0 END
		IF(@checkComma = 1)
		BEGIN
			--Remove last character comma(,)
			SET @JsonStringAuditLog = left(@JsonStringAuditLog, len(@JsonStringAuditLog)-1)
		END

		SET @JsonStringAuditLog = '{"action":"Updated","change":"Updated - Record: ' + CAST(@intParentId AS NVARCHAR(50)) + '","keyValue":' + CAST(@intParentId AS NVARCHAR(50)) + ',"iconCls":"small-tree-modified","children":[' + @JsonStringAuditLog + ']}'
		INSERT INTO tblSMAuditLog(strActionType, strTransactionType, strRecordNo, strDescription, strRoute, strJsonData, dtmDate, intEntityId, intConcurrencyId)
		VALUES(
				'Updated'
				, 'Inventory.view.Item'
				, @intParentId
				, ''
				, null
				, @JsonStringAuditLog
				, GETUTCDATE()
				, @currentUserId
				, 1
		)
		--=================================================================================================

		--Clear
		SET @ItemPricingAuditLog = ''
		SET @ItemSpecialPricingAuditLog = ''

		DELETE TOP (1) FROM @tblId
	END
	--==========================================================================================================================================

--NEW
SELECT @UpdateCount = COUNT(*)
FROM 
(
  SELECT DISTINCT intChildId FROM @tblTempOne --tblSTMassUpdateReportMaster
) T1
SELECT @UpdateCount as UpdateItemPrcicingCount, @RecCount as RecCount

DELETE FROM tblSTMassUpdateReportMaster

INSERT INTO tblSTMassUpdateReportMaster(strLocationName, UpcCode, ItemDescription, ChangeDescription, OldData, NewData)
SELECT strLocation
	  , strUpc
	  , strItemDescription
	  , strChangeDescription
	  , strOldData
	  , strNewData 
FROM @tblTempOne


--OLD
--SELECT @UpdateCount as UpdateItemPrcicingCount, @RecCount as RecCount		    

END TRY

BEGIN CATCH       
 SET @ErrMsg = ERROR_MESSAGE()      
 IF @idoc <> 0 EXEC sp_xml_removedocument @idoc      
 RAISERROR(@ErrMsg, 16, 1, 'WITH NOWAIT')      
END CATCH