CREATE PROCEDURE [dbo].[uspMFUpdateBlendProductionDetail]
	@strXml nVarchar(Max)
AS
Begin Try

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

Declare @intWorkOrderId int
Declare @intStorageLocationId int
Declare @intUserId int
DECLARE @idoc int 
Declare @ErrMsg nVarchar(Max)

EXEC sp_xml_preparedocument @idoc OUTPUT, @strXml  

 Select @intWorkOrderId=intWorkOrderId,
		@intStorageLocationId=intStorageLocationId ,
		@intUserId=intUserId
 FROM OPENXML(@idoc, 'root', 2)  
 WITH ( 
	intWorkOrderId int, 
	intStorageLocationId int,
	intUserId int
	)

If @intStorageLocationId=0 
	Set @intStorageLocationId=null

Declare @tblLot table
(
	intRowNo int Identity(1,1),
	intWorkOrderId int,
	intWorkOrderConsumedLotId int,
	intLotId int,
	intItemId int,
	dblQty numeric(18,6),
	dblIssuedQuantity numeric(18,6),
	dblWeightPerUnit numeric(18,6),
	intItemUOMId int,
	intItemIssuedUOMId int,
	intRecipeItemId int,
	ysnStaged bit
)

INSERT INTO @tblLot(
 intWorkOrderId,intWorkOrderConsumedLotId,intLotId,intItemId,dblQty,intItemUOMId,dblIssuedQuantity,intItemIssuedUOMId,intRecipeItemId,ysnStaged)
 Select intWorkOrderId,intWorkOrderConsumedLotId,intLotId,intItemId,dblQty,intItemUOMId,dblIssuedQuantity,intItemIssuedUOMId,intRecipeItemId,ysnStaged
 FROM OPENXML(@idoc, 'root/lot', 2)  
 WITH (  
	intWorkOrderId int,
	intWorkOrderConsumedLotId int,
	intLotId int,
	intItemId int,
	dblQty numeric(18,6),
	intItemUOMId int,
	dblIssuedQuantity numeric(18,6),
	intItemIssuedUOMId int,
	dblWeightPerUnit numeric(18,6),
	intRecipeItemId int,
	ysnStaged bit
	)

Begin Tran

Delete From tblMFWorkOrderConsumedLot Where intWorkOrderId=@intWorkOrderId 
And intWorkOrderConsumedLotId not in (Select intWorkOrderConsumedLotId From @tblLot)

Insert into tblMFWorkOrderConsumedLot(intWorkOrderId,intLotId,intItemId,dblQuantity,intItemUOMId,dblIssuedQuantity,intItemIssuedUOMId,intRecipeItemId,ysnStaged,intCreatedUserId,dtmCreated,intLastModifiedUserId,dtmLastModified)
Select intWorkOrderId,intLotId,intItemId,dblQty,intItemUOMId,dblIssuedQuantity,intItemIssuedUOMId,intRecipeItemId,ysnStaged,@intUserId,GetDate(),@intUserId,GetDate() 
From @tblLot Where ISNULL(intWorkOrderConsumedLotId,0)=0

Update a Set a.intLotId=b.intLotId,
a.intItemId=b.intItemId,
a.dblQuantity=b.dblQty,
a.intItemUOMId=b.intItemUOMId,
a.dblIssuedQuantity=b.dblIssuedQuantity,
a.intItemIssuedUOMId=b.intItemIssuedUOMId,
a.intRecipeItemId=b.intRecipeItemId,
a.ysnStaged=b.ysnStaged,
a.intLastModifiedUserId=@intUserId,
a.dtmLastModified=GetDate()
From tblMFWorkOrderConsumedLot a Join @tblLot b  on a.intWorkOrderConsumedLotId=b.intWorkOrderConsumedLotId

Update tblMFWorkOrder 
Set dblQuantity=(Select sum(dblQuantity) From tblMFWorkOrderConsumedLot Where intWorkOrderId=@intWorkOrderId)
Where intWorkOrderId=@intWorkOrderId

Commit Tran

EXEC sp_xml_removedocument @idoc 

END TRY  
  
BEGIN CATCH  
 IF XACT_STATE() != 0 AND @@TRANCOUNT > 0 ROLLBACK TRANSACTION      
 SET @ErrMsg = ERROR_MESSAGE()  
 IF @idoc <> 0 EXEC sp_xml_removedocument @idoc  
 RAISERROR(@ErrMsg, 16, 1, 'WITH NOWAIT')  
  
END CATCH  