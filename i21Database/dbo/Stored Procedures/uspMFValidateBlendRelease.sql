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
Declare @strLotAlias nVarchar(50)
DECLARE @strBlendItemNo nVarchar(50)
DECLARE @dblPlannedQuantity NUMERIC(18,6)
DECLARE @strUOM nVarchar(50)
DECLARE @dblAvailableQty NUMERIC(18,6)
DECLARE @dblSelectedQty NUMERIC(18,6)
DECLARE @dblOverCommitQty NUMERIC(18,6)
Declare @ysnRecipeItemValidityByDueDate bit=0
Declare @intManufacturingProcessId int
Declare @intDayOfYear INT
Declare @dtmRecipeValidDate DATETIME
Declare @ysnEnableParentLot bit=0
Declare @dtmDueDate DATETIME
Declare @ysnLotExpiryByDueDate bit=0
Declare @dtmLotExpiryDate DATETIME
Declare @ysnShowAvailableLotsByStorageLocation bit

Select TOP 1 @ysnEnableParentLot=ISNULL(ysnEnableParentLot,0) From tblMFCompanyPreference
  
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
	ysnSubstituteItem bit,
	intParentRecipeItemId int
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
	intRecipeItemId int,
	intLocationId int,
	intStorageLocationId int
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
	strLotAlias nvarchar(50),
	strItemNo nvarchar(50),
	dblAvailableQty numeric(18,6),
	dblSelectedQty numeric(18,6),
	dblWeightPerUnit numeric(18,6),
	strUOM nvarchar(50),
	dblOverCommitQty numeric(18,6)
)

Declare @tblAvailableLot table
(
	intRowNo int Identity(1,1),
	intLotId int,
	intItemId int,
	strLotNumber nvarchar(50),
	strLotAlias nvarchar(50),
	strItemNo nvarchar(50),
	dblPhysicalQty numeric(18,6),
	dblSelectedQty numeric(18,6),
	dblWeightPerUnit numeric(18,6),
	strUOM nvarchar(50),
	dblOverCommitQty numeric(18,6),
	intParentLotId int,
	strParentLotNumber nvarchar(50),
	intLocationId int,
	intStorageLocationId int
)

Declare @tblParentLot table
(
	intRowNo int Identity(1,1),
	intParentLotId int,
	intItemId int,
	strParentLotNumber nvarchar(50),
	strLotAlias nvarchar(50),
	strItemNo nvarchar(50),
	dblPhysicalQty numeric(18,6),
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
 intLotId,intItemId,dblQty,dblIssuedQuantity,dblWeightPerUnit,intItemUOMId,intItemIssuedUOMId,intUserId,intRecipeItemId,intLocationId,intStorageLocationId)
 Select intLotId,intItemId,dblQty,dblIssuedQuantity,dblWeightPerUnit,intItemUOMId,intItemIssuedUOMId,intUserId,intRecipeItemId,intLocationId,intStorageLocationId
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
	intRecipeItemId int,
	intLocationId int,
	intStorageLocationId int
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

Select @intRecipeId = intRecipeId,@intManufacturingProcessId=intManufacturingProcessId 
from tblMFRecipe a Join @tblBlendSheet b on a.intItemId=b.intItemId
and a.intLocationId=b.intLocationId and ysnActive=1

Select @ysnRecipeItemValidityByDueDate=CASE When UPPER(pa.strAttributeValue) = 'TRUE' then 1 Else 0 End 
From tblMFManufacturingProcessAttribute pa Join tblMFAttribute at on pa.intAttributeId=at.intAttributeId
Where intManufacturingProcessId=@intManufacturingProcessId and intLocationId=@intLocationId 
and at.strAttributeName='Recipe Item Validity By Due Date'

Select @ysnLotExpiryByDueDate=CASE When UPPER(pa.strAttributeValue) = 'TRUE' then 1 Else 0 End 
From tblMFManufacturingProcessAttribute pa Join tblMFAttribute at on pa.intAttributeId=at.intAttributeId
Where intManufacturingProcessId=@intManufacturingProcessId and intLocationId=@intLocationId 
and at.strAttributeName='Lot Expiry By Due Date'

Select @ysnShowAvailableLotsByStorageLocation=CASE When UPPER(pa.strAttributeValue) = 'TRUE' then 1 Else 0 End 
From tblMFManufacturingProcessAttribute pa Join tblMFAttribute at on pa.intAttributeId=at.intAttributeId
Where intManufacturingProcessId=@intManufacturingProcessId and intLocationId=@intLocationId 
and at.strAttributeName='Show Available Lots By Storage Location'

Select @dtmDueDate=Convert(date,dtmDueDate) from @tblBlendSheet

If @ysnRecipeItemValidityByDueDate=0
	Set @dtmRecipeValidDate=Convert(date,GetDate())
Else
	Set @dtmRecipeValidDate=@dtmDueDate

SELECT @intDayOfYear = DATEPART(dy, @dtmRecipeValidDate)

If @ysnLotExpiryByDueDate=0
	Set @dtmLotExpiryDate=GetDate()
Else
	Set @dtmLotExpiryDate=@dtmDueDate

Insert into @tblItem(intItemId,dblReqQty,ysnSubstituteItem,intParentRecipeItemId)
Select ri.intItemId,(ri.dblCalculatedQuantity * (@dblQtyToProduce/r.dblQuantity)) AS RequiredQty,0,0
From tblMFRecipeItem ri 
Join tblMFRecipe r on r.intRecipeId=ri.intRecipeId 
where ri.intRecipeId=@intRecipeId and ri.intRecipeItemTypeId=1 and
((ri.ysnYearValidationRequired = 1 AND @dtmRecipeValidDate BETWEEN ri.dtmValidFrom AND ri.dtmValidTo)
OR (ri.ysnYearValidationRequired = 0 AND @intDayOfYear BETWEEN DATEPART(dy, ri.dtmValidFrom) AND DATEPART(dy, ri.dtmValidTo)))
UNION
Select rs.intSubstituteItemId,(rs.dblQuantity * (@dblQtyToProduce/r.dblQuantity)) AS RequiredQty,1,rs.intItemId
From tblMFRecipeSubstituteItem rs  
Join tblMFRecipe r on r.intRecipeId=rs.intRecipeId 
where rs.intRecipeId=@intRecipeId and rs.intRecipeItemTypeId=1

If @ysnEnableParentLot=0
	Insert into @tblReservedQty
	Select tl.intLotId,Sum(sr.dblQty) AS dblReservedQty 
	From tblICStockReservation sr 
	Join @tblLot tl on sr.intLotId=tl.intLotId
	group by tl.intLotId

If @ysnEnableParentLot=0
	Insert Into @tblAvailableQty(intLotId,intItemId,strLotNo,strLotAlias,strItemNo,dblAvailableQty,dblSelectedQty,dblOverCommitQty,dblWeightPerUnit,strUOM)
	Select l.intLotId,l.intItemId,icl.strLotNumber,icl.strLotAlias,i.strItemNo,
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
Else
	Begin
		Insert into @tblAvailableLot(intLotId,intItemId,strLotNumber,strLotAlias,strItemNo,dblPhysicalQty,dblSelectedQty,dblOverCommitQty,dblWeightPerUnit,strUOM,
			intParentLotId,strParentLotNumber,intLocationId,intStorageLocationId)
		Select icl.intLotId,icl.intItemId,icl.strLotNumber,icl.strLotAlias,i.strItemNo,
		ISNULL(icl.dblWeight,0) AS dblPhysicalQty,
		l.dblQty AS dblSelectedQty,
		(l.dblQty % l.dblWeightPerUnit) AS dblOverCommitQty,
		l.dblWeightPerUnit,
		um.strUnitMeasure AS strUOM,
		icl.intParentLotId,
		pl.strParentLotNumber,
		icl.intLocationId,
		icl.intStorageLocationId
		from @tblLot l
		Join tblICLot icl on l.intLotId=icl.intParentLotId 
		Join tblICParentLot pl on l.intLotId=pl.intParentLotId
		Join tblICItem i on l.intItemId=i.intItemId
		Join tblICItemUOM iu on l.intItemUOMId=iu.intItemUOMId
		Join tblICUnitMeasure um on iu.intUnitMeasureId=um.intUnitMeasureId
		Where icl.dblWeight>0

		If @ysnShowAvailableLotsByStorageLocation=1
			Begin
				Insert into @tblParentLot(intParentLotId,intItemId,strParentLotNumber,strLotAlias,strItemNo,dblPhysicalQty,dblSelectedQty,
				dblOverCommitQty,dblWeightPerUnit,strUOM)
				Select intParentLotId,intItemId,strParentLotNumber,strLotAlias,strItemNo,
				sum(dblPhysicalQty) AS dblPhysicalQty,dblSelectedQty,
				(sum(dblPhysicalQty) % AVG(dblWeightPerUnit)) AS dblOverCommitQty,
				AVG(dblWeightPerUnit) AS dblWeightPerUnit,strUOM 
				From @tblAvailableLot Group By intParentLotId,intItemId,strParentLotNumber,strLotAlias,strItemNo,dblSelectedQty,strUOM,intLocationId,intStorageLocationId

				Insert Into @tblAvailableQty(intLotId,intItemId,strLotNo,strLotAlias,strItemNo,dblAvailableQty,dblSelectedQty,dblOverCommitQty,dblWeightPerUnit,strUOM)
				Select tpl.intParentLotId,tpl.intItemId,tpl.strParentLotNumber,tpl.strLotAlias,tpl.strItemNo, 
						(tpl.dblPhysicalQty - r.dblReservedQty) AS dblAvailableQty,tpl.dblSelectedQty,dblOverCommitQty,
						dblWeightPerUnit,strUOM 
				from @tblParentLot tpl join @tblReservedQty r on tpl.intParentLotId=r.intLotId
			End 
		Else
			Begin
				Insert into @tblParentLot(intParentLotId,intItemId,strParentLotNumber,strLotAlias,strItemNo,dblPhysicalQty,dblSelectedQty,
				dblOverCommitQty,dblWeightPerUnit,strUOM)
				Select intParentLotId,intItemId,strParentLotNumber,strLotAlias,strItemNo,
				sum(dblPhysicalQty) AS dblPhysicalQty,dblSelectedQty,
				(sum(dblPhysicalQty) % AVG(dblWeightPerUnit)) AS dblOverCommitQty,
				AVG(dblWeightPerUnit) AS dblWeightPerUnit,strUOM 
				From @tblAvailableLot Group By intParentLotId,intItemId,strParentLotNumber,strLotAlias,strItemNo,dblSelectedQty,strUOM,intLocationId

				Insert Into @tblAvailableQty(intLotId,intItemId,strLotNo,strLotAlias,strItemNo,dblAvailableQty,dblSelectedQty,dblOverCommitQty,dblWeightPerUnit,strUOM)
				Select tpl.intParentLotId,tpl.intItemId,tpl.strParentLotNumber,tpl.strLotAlias,tpl.strItemNo, 
						(tpl.dblPhysicalQty - r.dblReservedQty) AS dblAvailableQty,tpl.dblSelectedQty,dblOverCommitQty,
						dblWeightPerUnit,strUOM 
				from @tblParentLot tpl join @tblReservedQty r on tpl.intParentLotId=r.intLotId
			End 
	End

--Validation #1
If Exists(Select 1 From tblMFBlendValidation Where intBlendValidationDefaultId=1 AND intTypeId=1)
Begin

Set @strMessage=''

Select @strMessage=a.strMessage,@intMessageTypeId=a.intMessageTypeId 
From tblMFBlendValidation a
Where intBlendValidationDefaultId=1 AND intTypeId=1

Declare @tblMissingItem table
(
	intRowNo int Identity(1,1),
	intItemId int,
	strItemNo nVarchar(50)
)

Declare @tblSelectedSubstituteItem table
(
	intRowNo int Identity(1,1),
	intParentRecipeItemId int
)

Insert into @tblSelectedSubstituteItem(intParentRecipeItemId)
Select  ti.intParentRecipeItemId From @tblLot tl 
Join @tblItem ti on tl.intItemId=ti.intItemId 
where ysnSubstituteItem=1

Insert Into @tblMissingItem(intItemId,strItemNo)
Select c.intItemId,c.strItemNo 
From @tblItem a Left Join @tblLot b  On a.intItemId=b.intItemId 
Join tblICItem c on a.intItemId=c.intItemId
Where b.intItemId is null and a.ysnSubstituteItem=0

Delete From @tblMissingItem Where intItemId in (Select intParentRecipeItemId From @tblSelectedSubstituteItem)

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
If Exists(Select 1 From tblMFBlendValidation Where intBlendValidationDefaultId=2 AND intTypeId=1)
Begin

Set @strMessage=''

Select @strMessage=a.strMessage,@intMessageTypeId=a.intMessageTypeId 
From tblMFBlendValidation a
Where intBlendValidationDefaultId=2 AND intTypeId=1

Declare @tblExpiredLots table
(
	intRowNo int Identity(1,1),
	strLotNo nVarchar(50),
	strLotAlias nVarchar(50)
)

If @ysnEnableParentLot=0
	Insert Into @tblExpiredLots(strLotNo,strLotAlias)
	Select b.strLotNumber,b.strLotAlias from @tblLot a Join tblICLot b on a.intLotId=b.intLotId 
	Where b.dtmExpiryDate < @dtmLotExpiryDate
Else
	Insert Into @tblExpiredLots(strLotNo,strLotAlias)
	Select pl.strParentLotNumber,pl.strParentLotAlias from @tblLot tl Join tblICParentLot pl on tl.intLotId=pl.intParentLotId 
	Where pl.dtmExpiryDate < @dtmLotExpiryDate

If (Select Count(1) From @tblExpiredLots)>0
Begin

Select @intMinRowNo=Min(intRowNo) from @tblExpiredLots
	
While(@intMinRowNo is not null)
Begin
Set @strLotNo=''
Set @strLotAlias=''
Select @strLotNo=strLotNo,@strLotAlias=Case When ISNULL(strLotAlias,'')='' then '' Else ' (' + strLotAlias + ')' End 
From @tblExpiredLots Where intRowNo=@intMinRowNo

set @strMessageFinal=@strMessage
Set @strMessageFinal =REPLACE(@strMessageFinal,'@1',@strLotNo + @strLotAlias)

Insert Into @tblValidationMessages(intMessageTypeId,strMessage)
Values(@intMessageTypeId,@strMessageFinal)

Select @intMinRowNo=Min(intRowNo) from @tblExpiredLots where intRowNo>@intMinRowNo
End --End While

End --End If Missing Item Count > 0

End --End Validation #2


--Validation #3
If Exists(Select 1 From tblMFBlendValidation Where intBlendValidationDefaultId=3 AND intTypeId=1)
Begin

Set @strMessage=''

Select @strMessage=a.strMessage,@intMessageTypeId=a.intMessageTypeId 
From tblMFBlendValidation a
Where intBlendValidationDefaultId=3 AND intTypeId=1

Declare @tblQuarantineLots table
(
	intRowNo int Identity(1,1),
	strLotNo nVarchar(50),
	strLotAlias nVarchar(50)
)

If @ysnEnableParentLot=0
	Insert Into @tblQuarantineLots(strLotNo,strLotAlias)
	Select l.strLotNumber,l.strLotAlias from @tblLot tl Join tblICLot l on tl.intLotId=l.intLotId
	Join tblICLotStatus ls on l.intLotStatusId=ls.intLotStatusId 
	Where ls.strPrimaryStatus='Quarantine' 
Else
	Insert Into @tblQuarantineLots(strLotNo,strLotAlias)
	Select pl.strParentLotNumber,pl.strParentLotAlias from @tblLot tl Join tblICParentLot pl on tl.intLotId=pl.intParentLotId
	Join tblICLotStatus ls on pl.intLotStatusId=ls.intLotStatusId 
	Where ls.strPrimaryStatus='Quarantine'

If (Select Count(1) From @tblQuarantineLots)>0
Begin

Select @intMinRowNo=Min(intRowNo) from @tblQuarantineLots
	
While(@intMinRowNo is not null)
Begin
Set @strLotNo=''
Set @strLotAlias=''
Select @strLotNo=strLotNo,@strLotAlias=Case When ISNULL(strLotAlias,'')='' then '' Else ' (' + strLotAlias + ')' End 
From @tblQuarantineLots Where intRowNo=@intMinRowNo

set @strMessageFinal=@strMessage
Set @strMessageFinal =REPLACE(@strMessageFinal,'@1',@strLotNo + @strLotAlias)

Insert Into @tblValidationMessages(intMessageTypeId,strMessage)
Values(@intMessageTypeId,@strMessageFinal)

Select @intMinRowNo=Min(intRowNo) from @tblQuarantineLots where intRowNo>@intMinRowNo
End --End While

End --End If Missing Item Count > 0

End --End Validation #3


--Validation #4
If Exists(Select 1 From tblMFBlendValidation Where intBlendValidationDefaultId=4 AND intTypeId=1)
Begin

Set @strMessage=''

Select @strMessage=a.strMessage,@intMessageTypeId=a.intMessageTypeId 
From tblMFBlendValidation a
Where intBlendValidationDefaultId=4 AND intTypeId=1

Declare @tblSubstituteLots table
(
	intRowNo int Identity(1,1),
	strLotNo nVarchar(50),
	strItemNo nVarchar(50)
)

If @ysnEnableParentLot=0
	Insert Into @tblSubstituteLots(strLotNo,strItemNo)
	Select b.strLotNumber,d.strItemNo from @tblLot a Join tblICLot b on a.intLotId=b.intLotId 
	Join @tblItem c on a.intItemId=c.intItemId 
	Join tblICItem d on c.intItemId=d.intItemId
	Where c.ysnSubstituteItem=1
Else
	Insert Into @tblSubstituteLots(strLotNo,strItemNo)
	Select pl.strParentLotNumber,i.strItemNo from @tblLot tl Join tblICParentLot pl on tl.intLotId=pl.intParentLotId 
	Join @tblItem ti on tl.intItemId=ti.intItemId 
	Join tblICItem i on ti.intItemId=i.intItemId
	Where ti.ysnSubstituteItem=1

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
If Exists(Select 1 From tblMFBlendValidation Where intBlendValidationDefaultId=5 AND intTypeId=1)
Begin

Set @strMessage=''

Select @strMessage=a.strMessage,@intMessageTypeId=a.intMessageTypeId 
From tblMFBlendValidation a
Where intBlendValidationDefaultId=5 AND intTypeId=1

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
If Exists(Select 1 From tblMFBlendValidation Where intBlendValidationDefaultId=6 AND intTypeId=1)
Begin

Set @strMessage=''

Select @strMessage=a.strMessage,@intMessageTypeId=a.intMessageTypeId 
From tblMFBlendValidation a
Where intBlendValidationDefaultId=6 AND intTypeId=1

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
If Exists(Select 1 From tblMFBlendValidation Where intBlendValidationDefaultId=7 AND intTypeId=1)
Begin

Set @strMessage=''

Select @strMessage=a.strMessage,@intMessageTypeId=a.intMessageTypeId 
From tblMFBlendValidation a
Where intBlendValidationDefaultId=7 AND intTypeId=1

Declare @tblMoreOverCommitQty table
(
	intRowNo int Identity(1,1),
	intLotId int,
	intItemId int,
	strLotNo nvarchar(50),
	strLotAlias nvarchar(50),
	strItemNo nvarchar(50),
	dblAvailableQty numeric(18,6),
	dblSelectedQty numeric(18,6),
	dblWeightPerUnit numeric(18,6),
	strUOM nvarchar(50),
	dblOverCommitQty numeric(18,6)
)

Insert Into @tblMoreOverCommitQty(intLotId,intItemId,strLotNo,strLotAlias,strItemNo,dblAvailableQty,dblSelectedQty,dblOverCommitQty,dblWeightPerUnit,strUOM)
Select intLotId,intItemId,strLotNo,strLotAlias,strItemNo,dblAvailableQty,dblSelectedQty,dblOverCommitQty,dblWeightPerUnit,strUOM 
From  @tblAvailableQty where dblOverCommitQty > dblWeightPerUnit AND dblOverCommitQty > 0

If (Select Count(1) From @tblMoreOverCommitQty)>0
Begin

Select @intMinRowNo=Min(intRowNo) from @tblMoreOverCommitQty
	
While(@intMinRowNo is not null)
Begin
Set @strLotNo=''
Set @strLotAlias=''
Set @strItemNo=''

Select @strLotNo=strLotNo,
@strLotAlias=Case When ISNULL(strLotAlias,'')='' then '' Else ' (' + strLotAlias + ')' End,
@strItemNo=strItemNo, 
@dblAvailableQty=dblAvailableQty,
@dblSelectedQty=dblSelectedQty,
@dblOverCommitQty=dblOverCommitQty
From @tblMoreOverCommitQty Where intRowNo=@intMinRowNo

set @strMessageFinal=@strMessage
Set @strMessageFinal =REPLACE(@strMessageFinal,'@1',@strLotNo + @strLotAlias)
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
If Exists(Select 1 From tblMFBlendValidation Where intBlendValidationDefaultId=8 AND intTypeId=1)
Begin

Set @strMessage=''

Select @strMessage=a.strMessage,@intMessageTypeId=a.intMessageTypeId 
From tblMFBlendValidation a
Where intBlendValidationDefaultId=8 AND intTypeId=1

Declare @tblLessOverCommitQty table
(
	intRowNo int Identity(1,1),
	intLotId int,
	intItemId int,
	strLotNo nvarchar(50),
	strLotAlias nvarchar(50),
	strItemNo nvarchar(50),
	dblAvailableQty numeric(18,6),
	dblSelectedQty numeric(18,6),
	dblWeightPerUnit numeric(18,6),
	strUOM nvarchar(50),
	dblOverCommitQty numeric(18,6)
)

Insert Into @tblLessOverCommitQty(intLotId,intItemId,strLotNo,strLotAlias,strItemNo,dblAvailableQty,dblSelectedQty,dblOverCommitQty,dblWeightPerUnit,strUOM)
Select intLotId,intItemId,strLotNo,strLotAlias,strItemNo,dblAvailableQty,dblSelectedQty,dblOverCommitQty,dblWeightPerUnit,strUOM 
From  @tblAvailableQty where dblOverCommitQty < dblWeightPerUnit AND dblOverCommitQty > 0

If (Select Count(1) From @tblLessOverCommitQty)>0
Begin

Select @intMinRowNo=Min(intRowNo) from @tblLessOverCommitQty
	
While(@intMinRowNo is not null)
Begin
Set @strLotNo=''
Set @strLotAlias=''
Set @strItemNo=''

Select @strLotNo=strLotNo,
@strLotAlias=Case When ISNULL(strLotAlias,'')='' then '' Else ' (' + strLotAlias + ')' End,
@strItemNo=strItemNo, 
@dblAvailableQty=dblAvailableQty,
@dblSelectedQty=dblSelectedQty,
@dblOverCommitQty=dblOverCommitQty
From @tblLessOverCommitQty Where intRowNo=@intMinRowNo

set @strMessageFinal=@strMessage
Set @strMessageFinal =REPLACE(@strMessageFinal,'@1',@strLotNo + @strLotAlias)
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