CREATE PROCEDURE [dbo].[uspLGGetLoadItemQuantity]
	@intLoadId INT
	,@intItemId INT
	,@dblQuantity NUMERIC (18, 6) OUTPUT
AS

DECLARE @intStockItemUOMId INT
DECLARE @strLoadNumber NVARCHAR(200)
DECLARE @strItemNo NVARCHAR(200)
DECLARE @errMsg NVARCHAR(MAX)

--Get Item Info
SELECT @strItemNo = strItemNo FROM tblICItem WHERE intItemId = @intItemId
IF (@strItemNo IS NULL)
BEGIN
	SET @errMsg = 'Item does not exist';
	RAISERROR(@errMsg, 16, 1);
	RETURN 0;
END

--Get Item Stock UOM
SELECT @intStockItemUOMId = intItemUOMId FROM tblICItemUOM 
WHERE intItemId = @intItemId AND ysnStockUnit = 1
IF (@intStockItemUOMId IS NULL)
BEGIN
	SET @errMsg = 'Stock UOM not found for ' + @strItemNo;
	RAISERROR(@errMsg, 16, 1);
	RETURN 0;
END

--Get Load Info
SELECT @strLoadNumber = strLoadNumber from tblLGLoad
WHERE intLoadId = @intLoadId
IF (@strLoadNumber IS NULL)
BEGIN
	SET @errMsg = 'Load does not exist';
	RAISERROR(@errMsg, 16, 1);
	RETURN 0;
END

--Validate Load Detail
IF NOT EXISTS(SELECT TOP 1 1 FROM tblLGLoadDetail WHERE intLoadId = @intLoadId AND intItemId = @intItemId)
BEGIN
	SET @errMsg = 'Item ''' + @strItemNo + ''' does not exist in ' + @strLoadNumber;
	RAISERROR(@errMsg, 16, 1);
	RETURN 0;
END

--Retrieve Output
SELECT @dblQuantity = SUM(dbo.fnCalculateQtyBetweenUOM(LD.intItemUOMId, @intStockItemUOMId, LD.dblQuantity))
FROM tblLGLoadDetail LD
WHERE intLoadId = @intLoadId AND intItemId = @intItemId
GROUP BY LD.intItemUOMId

--Return Output
RETURN @dblQuantity;

GO