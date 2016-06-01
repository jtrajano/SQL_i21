CREATE PROCEDURE [dbo].[uspMFRecallReport]
	@strLotNumber nvarchar(50) = NULL,
	@intLocationId INT = NULL,
	@strUserName nvarchar(50) = NULL,
	@strTraceName nvarchar(50) = NULL
AS
Declare @intAttributeTypeId int
Declare @intItemId INT
Declare @strItemType nvarchar(50)

Select TOP 1 @intItemId=intItemId From tblICLot Where strLotNumber=@strLotNumber And intLocationId=@intLocationId

If (Select strType From tblICItem Where intItemId=@intItemId)='Inventory'
	Set @strItemType='Raw'
Else
Begin
	Select @intAttributeTypeId=ISNULL(mp.intAttributeTypeId,0)
	From tblMFRecipe r Join tblMFManufacturingProcess mp on r.intManufacturingProcessId=mp.intManufacturingProcessId
	where r.intItemId = @intItemId

	If @intAttributeTypeId=2
		Set @strItemType='Blend'

	If @intAttributeTypeId=3
		Set @strItemType='FG'
End

SELECT NULL AS intTranId,@strTraceName AS strTraceName,@strItemType AS strItemType
