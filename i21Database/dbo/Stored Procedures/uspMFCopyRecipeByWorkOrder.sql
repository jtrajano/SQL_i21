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

DECLARE @tblMFInputQty TABLE (
        intItemId INT
        ,dblInputQty DECIMAL(24, 10)
        )
 
INSERT INTO @tblMFInputQty (
        intItemId
        ,dblInputQty
        )
SELECT WI.intItemId
        ,SUM(IsNULL(dbo.fnMFConvertQuantityToTargetItemUOM(WI.intItemUOMId, RI.intItemUOMId , WI.dblQuantity), 0))
FROM tblMFWorkOrderInputLot WI
JOIN tblMFWorkOrderRecipeItem RI on RI.intItemId=WI.intItemId and RI.intWorkOrderId =WI.intWorkOrderId
WHERE WI.intWorkOrderId = @intWorkOrderId
        AND WI.ysnConsumptionReversed = 0
GROUP BY WI.intItemId
 
UPDATE PS
SET dblYieldQuantity = 0
        ,dblInputQuantity = I.dblInputQty
FROM tblMFProductionSummary PS
JOIN @tblMFInputQty I ON I.intItemId = PS.intItemId
WHERE PS.intWorkOrderId = @intWorkOrderId