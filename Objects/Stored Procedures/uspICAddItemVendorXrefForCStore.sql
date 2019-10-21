CREATE PROCEDURE [dbo].[uspICAddItemVendorXrefForCStore]
	@intItemId AS INT
	,@intItemLocationId AS INT
	,@intVendorId AS INT
	,@strVendorProduct AS NVARCHAR(50) 
	,@intEntityUserSecurityId AS INT 
	,@intItemVendorXrefId AS INT = NULL OUTPUT 
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS ON

DECLARE @intDataSourceId_CStore AS TINYINT = 1
	   
-- Get the item vendor cross reference. 
SELECT 
	@intItemVendorXrefId = intItemVendorXrefId
FROM 
	tblICItemVendorXref
WHERE 
	intItemId = @intItemId 
	AND intItemLocationId = @intItemLocationId
	AND intVendorId = @intVendorId
	AND strVendorProduct = @strVendorProduct

-- If NULL, item location does not exists. It is safe to create a new item record. 
IF @intItemVendorXrefId IS NULL 
AND LTRIM(RTRIM(ISNULL(@strVendorProduct, ''))) <> ''
BEGIN 
	INSERT INTO tblICItemVendorXref(		
		intItemId
		,intItemLocationId 
		,intVendorId 
		,strVendorProduct 
		,strProductDescription
		,intConcurrencyId 
		,dtmDateCreated 
		,intCreatedByUserId 
		,intDataSourceId
	)
	SELECT 
		intItemId = @intItemId
		,intItemLocationId = @intItemLocationId
		,intVendorId = @intVendorId
		,strVendorProduct = @strVendorProduct		
		,strProductDescription = @strVendorProduct		
		,intConcurrencyId = 1
		,dtmDateCreated = GETDATE()
		,intCreatedByUserId = @intEntityUserSecurityId
		,intDataSourceId = @intDataSourceId_CStore

	SELECT @intItemVendorXrefId = SCOPE_IDENTITY()

	-- Create an audit log. 
	IF @intItemVendorXrefId IS NOT NULL
	AND @intItemId IS NOT NULL 
	BEGIN 
		EXEC dbo.uspSMAuditLog 
			@keyValue = @intItemId
			,@screenName = 'Inventory.view.Item'
			,@entityId = @intEntityUserSecurityId
			,@actionType = 'Updated'
			,@changeDescription = 'C-Store created a Vendor Item Cross Reference.'
			,@fromValue = NULL 
			,@toValue = @strVendorProduct  
	END
END 