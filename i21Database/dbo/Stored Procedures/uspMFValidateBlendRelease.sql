CREATE PROCEDURE [dbo].[uspMFValidateBlendRelease]
@strXml nVarchar(Max)
AS
Begin Try

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

DECLARE @idoc int 
Declare @intWorkOrderId int
Declare @strNextWONo nVarchar(50)
Declare @strDemandNo nVarchar(50)
Declare @intBlendRequirementId int
Declare @ErrMsg nVarchar(Max)
Declare @intLocationId int
Declare @intUserId int
Declare @dblQtyToProduce numeric(18,6)
Declare @strMessage nVarchar(Max)
Declare @strMessageFinal nVarchar(Max)
Declare @intMessageTypeId int
Declare @intMinRowNo int
Declare @strItemNo nVarchar(50)
Declare @strLotNo nVarchar(50)

EXEC sp_xml_preparedocument @idoc OUTPUT, @strXml

Declare @tblBlendSheet table
(
	intWorkOrderId int,
	intItemId int,
	intCellId int,
	intMachineId int,
	dtmDueDate DateTime,
	dblQtyToProduce numeric(18,6),
	dblPlannedQuantity  numeric(18,6),
	dblBinSize numeric(18,6),
	strComment nVarchar(Max),
	ysnUseTemplate bit,
	ysnKittingEnabled bit,
	intLocationId int,
	intBlendRequirementId int,
	intItemUOMId int,
	intUserId int
)

Declare @tblItem table
(
	intRowNo int Identity(1,1),
	intItemId int,
	dblReqQty numeric(18,6)
)

Declare @tblLot table
(
	intRowNo int Identity(1,1),
	intLotId int,
	intItemId int,
	dblQty numeric(18,6),
	dblIssuedQuantity numeric(18,6),
	dblWeightPerUnit numeric(18,6),
	intItemUOMId int,
	intItemIssuedUOMId int,
	intUserId int,
	intRecipeItemId int
)

Declare @tblValidationMessages table
(
	intRowNo int Identity(1,1),
	intMessageTypeId int,
	strMessage nVarchar(Max),
	ysnStatus bit default 1
)

INSERT INTO @tblBlendSheet(
 intWorkOrderId,intItemId,intCellId,intMachineId,dtmDueDate,dblQtyToProduce,dblPlannedQuantity,dblBinSize,strComment,  
 ysnUseTemplate,ysnKittingEnabled,intLocationId,intBlendRequirementId,intItemUOMId,intUserId)
 Select intWorkOrderId,intItemId,intCellId,intMachineId,dtmDueDate,dblQtyToProduce,dblPlannedQuantity,dblBinSize,strComment,  
 ysnUseTemplate,ysnKittingEnabled,intLocationId,intBlendRequirementId,intItemUOMId,intUserId
 FROM OPENXML(@idoc, 'root', 2)  
 WITH ( 
	intWorkOrderId int, 
	intItemId int,
	intCellId int,
	intMachineId int,
	dtmDueDate DateTime,
	dblQtyToProduce numeric(18,6),
	dblPlannedQuantity  numeric(18,6),
	dblBinSize numeric(18,6),
	strComment nVarchar(Max),
	ysnUseTemplate bit,
	ysnKittingEnabled bit,
	intLocationId int,
	intBlendRequirementId int,
	intItemUOMId int,
	intUserId int
	)
	
INSERT INTO @tblLot(
 intLotId,intItemId,dblQty,dblIssuedQuantity,dblWeightPerUnit,intItemUOMId,intItemIssuedUOMId,intUserId,intRecipeItemId)
 Select intLotId,intItemId,dblQty,dblIssuedQuantity,dblWeightPerUnit,intItemUOMId,intItemIssuedUOMId,intUserId,intRecipeItemId
 FROM OPENXML(@idoc, 'root/lot', 2)  
 WITH (  
	intLotId int,
	intItemId int,
	dblQty numeric(18,6),
	dblIssuedQuantity numeric(18,6),
	dblPickedQuantity numeric(18,6),
	dblWeightPerUnit numeric(18,6),
	intItemUOMId int,
	intItemIssuedUOMId int,
	intUserId int,
	intRecipeItemId int
	)

Update @tblBlendSheet Set dblQtyToProduce=(Select sum(dblQty) from @tblLot)

Select @dblQtyToProduce=dblQtyToProduce,@intUserId=intUserId,@intLocationId=intLocationId from @tblBlendSheet

Update a Set a.dblWeightPerUnit=b.dblWeightPerQty 
from @tblLot a join tblICLot b on a.intLotId=b.intLotId

Declare @intRecipeId int

Select @intRecipeId = intRecipeId from tblMFRecipe a Join @tblBlendSheet b on a.intItemId=b.intItemId
 and a.intLocationId=b.intLocationId and ysnActive=1

Insert into @tblItem(intItemId,dblReqQty)
Select ri.intItemId,(ri.dblCalculatedQuantity * (@dblQtyToProduce/r.dblQuantity)) AS RequiredQty
From tblMFRecipeItem ri 
Join tblMFRecipe r on r.intRecipeId=ri.intRecipeId 
where ri.intRecipeId=@intRecipeId and ri.intRecipeItemTypeId=1
UNION
Select rs.intSubstituteItemId,(rs.dblQuantity * (@dblQtyToProduce/r.dblQuantity)) AS RequiredQty
From tblMFRecipeSubstituteItem rs 
Join tblMFRecipe r on r.intRecipeId=rs.intRecipeId 
where rs.intRecipeId=@intRecipeId and rs.intRecipeItemTypeId=1

--Validation #1
If Exists(Select 1 From tblMFBlendValidation Where intBlendValidationDefaultId=1)
Begin

Set @strMessage=''

Select @strMessage=a.strMessage,@intMessageTypeId=a.intMessageTypeId 
From tblMFBlendValidation a
Where intBlendValidationDefaultId=1

Declare @tblMissingItem table
(
	intRowNo int Identity(1,1),
	intItemId int,
	strItemNo nVarchar(50)
)

Insert Into @tblMissingItem(intItemId,strItemNo)
Select c.intItemId,c.strItemNo 
From @tblItem a Left Join @tblLot b  On a.intItemId=b.intItemId 
Join tblICItem c on a.intItemId=c.intItemId
Where b.intItemId is null

If (Select Count(1) From @tblMissingItem)>0
Begin

Select @intMinRowNo=Min(intRowNo) from @tblMissingItem
	
While(@intMinRowNo is not null)
Begin
Set @strItemNo=''
Select @strItemNo=strItemNo From @tblMissingItem Where intRowNo=@intMinRowNo

set @strMessageFinal=@strMessage
Set @strMessageFinal =REPLACE(@strMessageFinal,'@1',@strItemNo)

Insert Into @tblValidationMessages(intMessageTypeId,strMessage)
Values(@intMessageTypeId,@strMessageFinal)

Select @intMinRowNo=Min(intRowNo) from @tblMissingItem where intRowNo>@intMinRowNo
End --End While

End --End If Missing Item Count > 0

End --End Validation #1


--Validation #2
If Exists(Select 1 From tblMFBlendValidation Where intBlendValidationDefaultId=2)
Begin

Set @strMessage=''

Select @strMessage=a.strMessage,@intMessageTypeId=a.intMessageTypeId 
From tblMFBlendValidation a
Where intBlendValidationDefaultId=2

Declare @tblExpiredLots table
(
	intRowNo int Identity(1,1),
	strLotNo nVarchar(50)
)

Insert Into @tblExpiredLots(strLotNo)
Select b.strLotNumber from @tblLot a Join tblICLot b on a.intLotId=b.intLotId 
Where b.dtmExpiryDate < GetDate()

If (Select Count(1) From @tblExpiredLots)>0
Begin

Select @intMinRowNo=Min(intRowNo) from @tblExpiredLots
	
While(@intMinRowNo is not null)
Begin
Set @strLotNo=''
Select @strLotNo=strLotNo From @tblExpiredLots Where intRowNo=@intMinRowNo

set @strMessageFinal=@strMessage
Set @strMessageFinal =REPLACE(@strMessageFinal,'@1',@strLotNo)

Insert Into @tblValidationMessages(intMessageTypeId,strMessage)
Values(@intMessageTypeId,@strMessageFinal)

Select @intMinRowNo=Min(intRowNo) from @tblExpiredLots where intRowNo>@intMinRowNo
End --End While

End --End If Missing Item Count > 0

End --End Validation #2


--Validation #3
If Exists(Select 1 From tblMFBlendValidation Where intBlendValidationDefaultId=3)
Begin

Set @strMessage=''

Select @strMessage=a.strMessage,@intMessageTypeId=a.intMessageTypeId 
From tblMFBlendValidation a
Where intBlendValidationDefaultId=3

Declare @tblQuarantineLots table
(
	intRowNo int Identity(1,1),
	strLotNo nVarchar(50)
)

Insert Into @tblQuarantineLots(strLotNo)
Select b.strLotNumber from @tblLot a Join tblICLot b on a.intLotId=b.intLotId 
Where b.intLotStatusId=3

If (Select Count(1) From @tblQuarantineLots)>0
Begin

Select @intMinRowNo=Min(intRowNo) from @tblQuarantineLots
	
While(@intMinRowNo is not null)
Begin
Set @strLotNo=''
Select @strLotNo=strLotNo From @tblQuarantineLots Where intRowNo=@intMinRowNo

set @strMessageFinal=@strMessage
Set @strMessageFinal =REPLACE(@strMessageFinal,'@1',@strLotNo)

Insert Into @tblValidationMessages(intMessageTypeId,strMessage)
Values(@intMessageTypeId,@strMessageFinal)

Select @intMinRowNo=Min(intRowNo) from @tblQuarantineLots where intRowNo>@intMinRowNo
End --End While

End --End If Missing Item Count > 0

End --End Validation #3


Select a.intRowNo,a.intMessageTypeId,a.strMessage,
Case When a.intMessageTypeId=1 then CAST(1 AS BIT) Else CAST(0 AS BIT) End AS [ysnStatus],b.strName AS strMessageTypeName 
from @tblValidationMessages a Join tblMFBlendValidationMessageType b on a.intMessageTypeId=b.intMessageTypeId

EXEC sp_xml_removedocument @idoc 

END TRY  
  
BEGIN CATCH  
 IF XACT_STATE() != 0 AND @@TRANCOUNT > 0 ROLLBACK TRANSACTION      
 SET @ErrMsg = ERROR_MESSAGE()  
 IF @idoc <> 0 EXEC sp_xml_removedocument @idoc  
 RAISERROR(@ErrMsg, 16, 1, 'WITH NOWAIT')  
  
END CATCH  