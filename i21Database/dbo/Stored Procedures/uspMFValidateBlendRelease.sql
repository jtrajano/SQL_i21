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
DECLARE @strBlendItemNo nVarchar(50)
DECLARE @dblPlannedQuantity NUMERIC(18,6)
DECLARE @strUOM nVarchar(50)
DECLARE @dblAvailableQty NUMERIC(18,6)
DECLARE @dblSelectedQty NUMERIC(18,6)
DECLARE @dblOverCommitQty NUMERIC(18,6)
  
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
	dblReqQty numeric(18,6),
	ysnSubstituteItem bit
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

Declare @tblReservedQty table
(
	intLotId int,
	dblReservedQty numeric(18,6)
)

Declare @tblAvailableQty table
(
	intRowNo int Identity(1,1),
	intLotId int,
	intItemId int,
	strLotNo nvarchar(50),
	strItemNo nvarchar(50),
	dblAvailableQty numeric(18,6),
	dblSelectedQty numeric(18,6),
	dblWeightPerUnit numeric(18,6),
	strUOM nvarchar(50),
	dblOverCommitQty numeric(18,6)
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

--Update @tblBlendSheet Set dblQtyToProduce=(Select sum(dblQty) from @tblLot)

Select @dblQtyToProduce=dblQtyToProduce,@dblPlannedQuantity=dblPlannedQuantity,@intUserId=intUserId,@intLocationId=intLocationId,@strBlendItemNo=b.strItemNo,
@strUOM=d.strUnitMeasure 
from @tblBlendSheet a 
Join tblICItem b On a.intItemId=b.intItemId
Join tblICItemUOM c on c.intItemUOMId=a.intItemUOMId
Join tblICUnitMeasure d on c.intUnitMeasureId=d.intUnitMeasureId

Update a Set a.dblWeightPerUnit=b.dblWeightPerQty 
from @tblLot a join tblICLot b on a.intLotId=b.intLotId

Declare @intRecipeId int

Select @intRecipeId = intRecipeId from tblMFRecipe a Join @tblBlendSheet b on a.intItemId=b.intItemId
 and a.intLocationId=b.intLocationId and ysnActive=1

Insert into @tblItem(intItemId,dblReqQty,ysnSubstituteItem)
Select ri.intItemId,(ri.dblCalculatedQuantity * (@dblQtyToProduce/r.dblQuantity)) AS RequiredQty,0
From tblMFRecipeItem ri 
Join tblMFRecipe r on r.intRecipeId=ri.intRecipeId 
where ri.intRecipeId=@intRecipeId and ri.intRecipeItemTypeId=1
UNION
Select rs.intSubstituteItemId,(rs.dblQuantity * (@dblQtyToProduce/r.dblQuantity)) AS RequiredQty,1
From tblMFRecipeSubstituteItem rs 
Join tblMFRecipe r on r.intRecipeId=rs.intRecipeId 
where rs.intRecipeId=@intRecipeId and rs.intRecipeItemTypeId=1

Insert into @tblReservedQty
Select cl.intLotId,Sum(cl.dblQuantity) AS dblReservedQty 
From tblMFWorkOrderConsumedLot cl 
Join tblMFWorkOrder w on cl.intWorkOrderId=w.intWorkOrderId
join tblICLot l on l.intLotId=cl.intLotId
where w.intStatusId<>13
group by cl.intLotId

Insert Into @tblAvailableQty(intLotId,intItemId,strLotNo,strItemNo,dblAvailableQty,dblSelectedQty,dblOverCommitQty,dblWeightPerUnit,strUOM)
Select l.intLotId,l.intItemId,icl.strLotNumber,i.strItemNo,
ISNULL((ISNULL(icl.dblWeight,0) - ISNULL(r.dblReservedQty,0)),0) AS dblAvailableQty,
l.dblQty,
(l.dblQty % l.dblWeightPerUnit) AS dblOverCommitQty,
l.dblWeightPerUnit,
um.strUnitMeasure
from @tblLot l
Left Join @tblReservedQty r on l.intLotId=r.intLotId
Join tblICLot icl on l.intLotId=icl.intLotId 
Join tblICItem i on l.intItemId=i.intItemId
Join tblICItemUOM iu on l.intItemUOMId=iu.intItemUOMId
Join tblICUnitMeasure um on iu.intUnitMeasureId=um.intUnitMeasureId

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


--Validation #4
If Exists(Select 1 From tblMFBlendValidation Where intBlendValidationDefaultId=4)
Begin

Set @strMessage=''

Select @strMessage=a.strMessage,@intMessageTypeId=a.intMessageTypeId 
From tblMFBlendValidation a
Where intBlendValidationDefaultId=4

Declare @tblSubstituteLots table
(
	intRowNo int Identity(1,1),
	strLotNo nVarchar(50),
	strItemNo nVarchar(50)
)

Insert Into @tblSubstituteLots(strLotNo,strItemNo)
Select b.strLotNumber,d.strItemNo from @tblLot a Join tblICLot b on a.intLotId=b.intLotId 
Join @tblItem c on a.intItemId=c.intItemId 
Join tblICItem d on c.intItemId=d.intItemId
Where c.ysnSubstituteItem=1

If (Select Count(1) From @tblSubstituteLots)>0
Begin

Select @intMinRowNo=Min(intRowNo) from @tblSubstituteLots
	
While(@intMinRowNo is not null)
Begin
Set @strLotNo=''
Set @strItemNo=''

Select @strLotNo=strLotNo,@strItemNo=strItemNo From @tblSubstituteLots Where intRowNo=@intMinRowNo

set @strMessageFinal=@strMessage
Set @strMessageFinal =REPLACE(@strMessageFinal,'@1',@strLotNo)
Set @strMessageFinal =REPLACE(@strMessageFinal,'@2',@strItemNo)

Insert Into @tblValidationMessages(intMessageTypeId,strMessage)
Values(@intMessageTypeId,@strMessageFinal)

Select @intMinRowNo=Min(intRowNo) from @tblSubstituteLots where intRowNo>@intMinRowNo
End --End While

End --End If Missing Item Count > 0

End --End Validation #4


--Validation #5
If Exists(Select 1 From tblMFBlendValidation Where intBlendValidationDefaultId=5)
Begin

Set @strMessage=''

Select @strMessage=a.strMessage,@intMessageTypeId=a.intMessageTypeId 
From tblMFBlendValidation a
Where intBlendValidationDefaultId=5

If (@dblQtyToProduce > @dblPlannedQuantity)
Begin

set @strMessageFinal=@strMessage
Set @strMessageFinal =REPLACE(@strMessageFinal,'@1',@strBlendItemNo)
Set @strMessageFinal =REPLACE(@strMessageFinal,'@2',convert(varchar, @dblQtyToProduce) + ' ' + @strUOM)
Set @strMessageFinal =REPLACE(@strMessageFinal,'@3',convert(varchar, @dblPlannedQuantity) + ' ' + @strUOM)

Insert Into @tblValidationMessages(intMessageTypeId,strMessage)
Values(@intMessageTypeId,@strMessageFinal)

End --End If

End --End Validation #5


--Validation #6
If Exists(Select 1 From tblMFBlendValidation Where intBlendValidationDefaultId=6)
Begin

Set @strMessage=''

Select @strMessage=a.strMessage,@intMessageTypeId=a.intMessageTypeId 
From tblMFBlendValidation a
Where intBlendValidationDefaultId=6

If (@dblQtyToProduce < @dblPlannedQuantity)
Begin

set @strMessageFinal=@strMessage
Set @strMessageFinal =REPLACE(@strMessageFinal,'@1',@strBlendItemNo)
Set @strMessageFinal =REPLACE(@strMessageFinal,'@2', convert(varchar, @dblQtyToProduce) + ' ' + @strUOM)
Set @strMessageFinal =REPLACE(@strMessageFinal,'@3',convert(varchar, @dblPlannedQuantity) + ' ' + @strUOM)

Insert Into @tblValidationMessages(intMessageTypeId,strMessage)
Values(@intMessageTypeId,@strMessageFinal)

End --End If

End --End Validation #6


--Validation #7
If Exists(Select 1 From tblMFBlendValidation Where intBlendValidationDefaultId=7)
Begin

Set @strMessage=''

Select @strMessage=a.strMessage,@intMessageTypeId=a.intMessageTypeId 
From tblMFBlendValidation a
Where intBlendValidationDefaultId=7

Declare @tblMoreOverCommitQty table
(
	intRowNo int Identity(1,1),
	intLotId int,
	intItemId int,
	strLotNo nvarchar(50),
	strItemNo nvarchar(50),
	dblAvailableQty numeric(18,6),
	dblSelectedQty numeric(18,6),
	dblWeightPerUnit numeric(18,6),
	strUOM nvarchar(50),
	dblOverCommitQty numeric(18,6)
)

Insert Into @tblMoreOverCommitQty(intLotId,intItemId,strLotNo,strItemNo,dblAvailableQty,dblSelectedQty,dblOverCommitQty,dblWeightPerUnit,strUOM)
Select intLotId,intItemId,strLotNo,strItemNo,dblAvailableQty,dblSelectedQty,dblOverCommitQty,dblWeightPerUnit,strUOM 
From  @tblAvailableQty where dblOverCommitQty > dblWeightPerUnit AND dblOverCommitQty > 0

If (Select Count(1) From @tblMoreOverCommitQty)>0
Begin

Select @intMinRowNo=Min(intRowNo) from @tblMoreOverCommitQty
	
While(@intMinRowNo is not null)
Begin
Set @strLotNo=''
Set @strItemNo=''

Select @strLotNo=strLotNo,@strItemNo=strItemNo, 
@dblAvailableQty=dblAvailableQty,
@dblSelectedQty=dblSelectedQty,
@dblOverCommitQty=dblOverCommitQty
From @tblMoreOverCommitQty Where intRowNo=@intMinRowNo

set @strMessageFinal=@strMessage
Set @strMessageFinal =REPLACE(@strMessageFinal,'@1',@strLotNo)
Set @strMessageFinal =REPLACE(@strMessageFinal,'@2',convert(varchar, @dblAvailableQty) + ' ' + @strUOM)
Set @strMessageFinal =REPLACE(@strMessageFinal,'@3',@strItemNo)
Set @strMessageFinal =REPLACE(@strMessageFinal,'@4',convert(varchar, @dblSelectedQty) + ' ' + @strUOM)
Set @strMessageFinal =REPLACE(@strMessageFinal,'@5',convert(varchar, @dblOverCommitQty) + ' ' + @strUOM)
Set @strMessageFinal =REPLACE(@strMessageFinal,'@6',@strItemNo)

Insert Into @tblValidationMessages(intMessageTypeId,strMessage)
Values(@intMessageTypeId,@strMessageFinal)

Select @intMinRowNo=Min(intRowNo) from @tblMoreOverCommitQty where intRowNo>@intMinRowNo
End --End While

End --End If Missing Item Count > 0

End --End Validation #7


--Validation #8
If Exists(Select 1 From tblMFBlendValidation Where intBlendValidationDefaultId=8)
Begin

Set @strMessage=''

Select @strMessage=a.strMessage,@intMessageTypeId=a.intMessageTypeId 
From tblMFBlendValidation a
Where intBlendValidationDefaultId=8

Declare @tblLessOverCommitQty table
(
	intRowNo int Identity(1,1),
	intLotId int,
	intItemId int,
	strLotNo nvarchar(50),
	strItemNo nvarchar(50),
	dblAvailableQty numeric(18,6),
	dblSelectedQty numeric(18,6),
	dblWeightPerUnit numeric(18,6),
	strUOM nvarchar(50),
	dblOverCommitQty numeric(18,6)
)

Insert Into @tblLessOverCommitQty(intLotId,intItemId,strLotNo,strItemNo,dblAvailableQty,dblSelectedQty,dblOverCommitQty,dblWeightPerUnit,strUOM)
Select intLotId,intItemId,strLotNo,strItemNo,dblAvailableQty,dblSelectedQty,dblOverCommitQty,dblWeightPerUnit,strUOM 
From  @tblAvailableQty where dblOverCommitQty < dblWeightPerUnit AND dblOverCommitQty > 0

If (Select Count(1) From @tblLessOverCommitQty)>0
Begin

Select @intMinRowNo=Min(intRowNo) from @tblLessOverCommitQty
	
While(@intMinRowNo is not null)
Begin
Set @strLotNo=''
Set @strItemNo=''

Select @strLotNo=strLotNo,@strItemNo=strItemNo, 
@dblAvailableQty=dblAvailableQty,
@dblSelectedQty=dblSelectedQty,
@dblOverCommitQty=dblOverCommitQty
From @tblLessOverCommitQty Where intRowNo=@intMinRowNo

set @strMessageFinal=@strMessage
Set @strMessageFinal =REPLACE(@strMessageFinal,'@1',@strLotNo)
Set @strMessageFinal =REPLACE(@strMessageFinal,'@2',convert(varchar, @dblAvailableQty) + ' ' + @strUOM)
Set @strMessageFinal =REPLACE(@strMessageFinal,'@3',@strItemNo)
Set @strMessageFinal =REPLACE(@strMessageFinal,'@4',convert(varchar, @dblSelectedQty) + ' ' + @strUOM)
Set @strMessageFinal =REPLACE(@strMessageFinal,'@5',convert(varchar, @dblOverCommitQty) + ' ' + @strUOM)
Set @strMessageFinal =REPLACE(@strMessageFinal,'@6',@strItemNo)

Insert Into @tblValidationMessages(intMessageTypeId,strMessage)
Values(@intMessageTypeId,@strMessageFinal)

Select @intMinRowNo=Min(intRowNo) from @tblLessOverCommitQty where intRowNo>@intMinRowNo
End --End While

End --End If Missing Item Count > 0

End --End Validation #8



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