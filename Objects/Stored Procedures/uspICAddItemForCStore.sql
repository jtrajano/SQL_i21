CREATE PROCEDURE [dbo].[uspICAddItemForCStore]
	@intCategoryId AS INT 
	,@strItemNo NVARCHAR(50)
	,@strShortName AS NVARCHAR(50) = NULL 
	,@strDescription NVARCHAR(250) = NULL 	
	,@intEntityUserSecurityId AS INT 
	,@intItemId AS INT = NULL OUTPUT 
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS ON

DECLARE @intDataSourceId_CStore AS TINYINT = 1

-- Get the item id. 
SELECT @intItemId = intItemId FROM tblICItem WHERE strItemNo = @strItemNo

-- If NULL, item does not exists. It is safe to create a new item record. 
IF @intItemId IS NULL 
BEGIN 
	INSERT INTO tblICItem (
		strItemNo
		,strType
		,strShortName
		,strDescription
		,strLotTracking
		,strInventoryTracking
		,intCreatedByUserId
		,intConcurrencyId
		,dtmDateCreated
		,intDataSourceId
		,intLifeTime
		,strStatus
		,intCategoryId
	)
	SELECT
		strItemNo = @strItemNo
		,strType = 'Inventory'
		,strShortName = @strShortName
		,strDescription = @strDescription
		,strLotTracking = 'No'
		,strInventoryTracking = 'Item Level'
		,intCreatedByUserId = @intEntityUserSecurityId
		,intConcurrencyId = 1
		,dtmDateCreated = GETDATE() 
		,intDataSourceId = @intDataSourceId_CStore
		,intLifeTime = 0 
		,strStatus = 'Active'
		,intCategoryId = @intCategoryId

	SELECT @intItemId = SCOPE_IDENTITY()

	-- Create an audit log. 
	IF @intItemId IS NOT NULL
	BEGIN 
		EXEC dbo.uspSMAuditLog 
			@keyValue = @intItemId
			,@screenName = 'Inventory.view.Item'
			,@entityId = @intEntityUserSecurityId
			,@actionType = 'Created'
			,@changeDescription = 'C-Store created an item.'
			,@fromValue = NULL 
			,@toValue = NULL 
	END
END 