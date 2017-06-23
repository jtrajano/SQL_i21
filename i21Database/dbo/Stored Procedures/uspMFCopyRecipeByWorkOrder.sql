CREATE PROCEDURE dbo.uspMFCopyRecipeByWorkOrder(@strWorkOrderNo nvarchar(50))
AS
DECLARE @intItemId INT
	,@intLocationId INT
	,@intUserId INT
	,@intWorkOrderId INT

SELECT @intWorkOrderId = NULL
	,@intItemId = NULL
	,@intLocationId = NULL
	,@intUserId = NULL

SELECT @intWorkOrderId = intWorkOrderId
	,@intItemId = intItemId
	,@intLocationId = intLocationId
	,@intUserId = intCreatedUserId
FROM tblMFWorkOrder
WHERE strWorkOrderNo = @strWorkOrderNo

EXEC [dbo].[uspMFCopyRecipe] @intItemId = @intItemId
	,@intLocationId = @intLocationId
	,@intUserId = @intUserId
	,@intWorkOrderId = @intWorkOrderId
