CREATE PROCEDURE [dbo].[uspSTInventoryMassUpdate]
	@XML varchar(max)
	
AS
BEGIN TRY
	DECLARE @ErrMsg			    	NVARCHAR(MAX),
	        @idoc			     	INT,
			@intItemUOMId 	        INT,
			@intItemId              INT,
			@strDescription         NVARCHAR(250),
			@intItemLocationId      INT,
			@PosDescription         NVARCHAR(250),
			@intItemPricingId       INT,
			@dblSalePrice           DECIMAL(18,6),
			@intVendorId            INT,
			@intItemVendorXrefId    INT,
			@strVendorProduct       NVARCHAR(50),
			@intCategoryId          INT,
			@FamilyId               INT,
			@ClassId                INT
	                  
	EXEC sp_xml_preparedocument @idoc OUTPUT, @XML 
	
	SELECT	
			@intItemUOMId		 =	 intItemUOMId,
			@intItemId           =   intItemId,
			@strDescription      =   strDescription,
			@intItemLocationId   =   intItemLocationId,
			@PosDescription      =   PosDescription,
			@intItemPricingId    =   intItemPricingId,
			@dblSalePrice        =   dblSalePrice,
			@intVendorId         =   intVendorId,
			@intItemVendorXrefId =   intItemVendorXrefId,
			@strVendorProduct    =   strVendorProduct,
			@intCategoryId       =   intCategoryId,
			@FamilyId            =   FamilyId,
			@ClassId             =   ClassId
			      
		
	FROM	OPENXML(@idoc, 'root',2)
	WITH
	(
			intItemUOMId		        INT,
			intItemId                   INT,
			strDescription              NVARCHAR(250),
			intItemLocationId           INT,
			PosDescription              NVARCHAR(250),
			intItemPricingId            INT,
			dblSalePrice                DECIMAL(18,6),
			intVendorId                 INT,
			intItemVendorXrefId         INT,
			strVendorProduct            NVARCHAR(50),
			intCategoryId               INT,
			FamilyId                    INT,
			ClassId                     INT 
			 
	)  
    -- Insert statements for procedure here

	DECLARE @VendorXrefCount INT

	--Update Item Description

	 UPDATE tblICItem SET strDescription = @strDescription where intItemId = @intItemId

	 --Update Pos Description

	 UPDATE tblICItemLocation SET strDescription = @PosDescription where intItemLocationId = @intItemLocationId

	 --Update Retail Prie

	 UPDATE tblICItemPricing SET dblSalePrice = @dblSalePrice where intItemPricingId = @intItemPricingId

	 ----Update Vendor Id

	 UPDATE tblICItemLocation SET intVendorId = @intVendorId where @intItemLocationId = @intItemLocationId

     
	 SELECT @VendorXrefCount = COUNT(*) FROM tblICItemVendorXref 
	 WHERE intItemVendorXrefId = @intItemVendorXrefId 
	  
     
	 --Insert Vendor X-ref 
	 IF (@VendorXrefCount > 0)
	 BEGIN
	       UPDATE tblICItemVendorXref SET strVendorProduct = @strVendorProduct 
		   WHERE intItemVendorXrefId = @intItemVendorXrefId
	 END

	 --Update Vendor X-ref 

	 IF ((@strVendorProduct IS NOT NULL)
	 AND (@VendorXrefCount = 0 ))
	 BEGIN
	       IF ((@intItemId IS NOT NULL)
		   AND (@intItemLocationId IS NOT NULL)
		   AND (@intVendorId IS NOT NULL)
		   AND  (@strVendorProduct IS NOT NULL))
		   BEGIN
		       INSERT INTO tblICItemVendorXref (intItemId,intItemLocationId,intVendorId,strVendorProduct)
		       VALUES(@intItemId,@intItemLocationId,@intVendorId,@strVendorProduct)
	       END
	 END

	 ----Update Category

	 UPDATE tblICItem set intCategoryId = @intCategoryId WHERE intItemId = @intItemId

	 ----Update Family

	 UPDATE tblICItemLocation SET intFamilyId = @FamilyId WHERE intItemLocationId = @intItemLocationId

	 ----Update Class
	 
	 UPDATE tblICItemLocation SET intClassId = @ClassId WHERE intItemLocationId = @intItemLocationId
 

END TRY

BEGIN CATCH       
 SET @ErrMsg = ERROR_MESSAGE()      
 IF @idoc <> 0 EXEC sp_xml_removedocument @idoc      
 RAISERROR(@ErrMsg, 16, 1, 'WITH NOWAIT')      
END CATCH


