CREATE PROCEDURE [dbo].[uspMFValidateBlendProduction]
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
Declare @dblExpectedCost NUMERIC(38,20)
Declare @dblAffordabilityCost NUMERIC(38,20)
Declare @dblAffordabilityCostFinal NUMERIC(38,20)
Declare @dblAffordabilityRangeMinValue NUMERIC(38,20)
Declare @intBlendItemId INT
Declare @intTestIdForAffordabilityRange INT
Declare @intUserRoleIdToOverrideAffordabilityCheck INT
Declare @intManufacturingProcessId int
Declare @strPackagingCategoryId NVARCHAR(Max)
  
EXEC sp_xml_preparedocument @idoc OUTPUT, @strXml

Declare @tblBlendSheet table
(
	intWorkOrderId int,
	intItemId int,
	intItemUOMId int,
	dblQtyToProduce numeric(18,6),
	intLocationId int,
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
 intWorkOrderId,intItemId,intItemUOMId,dblQtyToProduce,intLocationId,intUserId)
 Select intWorkOrderId,intItemId,intItemUOMId,dblQtyToProduce,intLocationId,intUserId
 FROM OPENXML(@idoc, 'root', 2)  
 WITH ( 
	intWorkOrderId int, 
	intItemId int,
	intItemUOMId int,
	dblQtyToProduce numeric(18,6),
	dblPlannedQuantity  numeric(18,6),
	intLocationId int,
	intUserId int
	)
	
INSERT INTO @tblLot(
 intWorkOrderConsumedLotId,intLotId,intItemId,dblQty,intItemUOMId,dblIssuedQuantity,intItemIssuedUOMId,dblWeightPerUnit,intRecipeItemId,ysnStaged)
 Select intWorkOrderConsumedLotId,intLotId,intItemId,dblQty,intItemUOMId,dblIssuedQuantity,intItemIssuedUOMId,dblWeightPerUnit,intRecipeItemId,ysnStaged
 FROM OPENXML(@idoc, 'root/lot', 2)  
 WITH (  
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

Update @tblBlendSheet Set dblQtyToProduce=(Select sum(dblQty) from @tblLot)

Select @intWorkOrderId=intWorkOrderId,@dblQtyToProduce=dblQtyToProduce,@intUserId=intUserId,@intLocationId=intLocationId,@strBlendItemNo=b.strItemNo,
@strUOM=d.strUnitMeasure,@intBlendItemId=a.intItemId 
from @tblBlendSheet a 
Join tblICItem b On a.intItemId=b.intItemId
Join tblICItemUOM c on c.intItemUOMId=a.intItemUOMId
Join tblICUnitMeasure d on c.intUnitMeasureId=d.intUnitMeasureId

Update a Set a.dblWeightPerUnit=b.dblWeightPerQty 
from @tblLot a join tblICLot b on a.intLotId=b.intLotId

Declare @dblRecipeQuantity numeric(18,6)

Select @dblRecipeQuantity = dblQuantity from tblMFWorkOrderRecipe Where intWorkOrderId=@intWorkOrderId

Select @intManufacturingProcessId=intManufacturingProcessId 
from tblMFWorkOrderRecipe Where intWorkOrderId=@intWorkOrderId

SELECT @strPackagingCategoryId = ISNULL(pa.strAttributeValue, '')
FROM tblMFManufacturingProcessAttribute pa
JOIN tblMFAttribute at ON pa.intAttributeId = at.intAttributeId
WHERE intManufacturingProcessId = @intManufacturingProcessId
	AND intLocationId = @intLocationId
	AND at.strAttributeName = 'Packaging Category'

Select @intTestIdForAffordabilityRange=pa.strAttributeValue 
From tblMFManufacturingProcessAttribute pa Join tblMFAttribute at on pa.intAttributeId=at.intAttributeId
Where intManufacturingProcessId=@intManufacturingProcessId and intLocationId=@intLocationId 
and at.strAttributeName='Quality Test Name To Get Blend Affordability Range'

Select @intUserRoleIdToOverrideAffordabilityCheck=pa.strAttributeValue 
From tblMFManufacturingProcessAttribute pa Join tblMFAttribute at on pa.intAttributeId=at.intAttributeId
Where intManufacturingProcessId=@intManufacturingProcessId and intLocationId=@intLocationId 
and at.strAttributeName='User Role To Override Blend Affordability Check'

--Insert into @tblItem(intItemId,dblReqQty,ysnSubstituteItem)
--Select ri.intItemId,(ri.dblCalculatedQuantity * (@dblQtyToProduce/@dblRecipeQuantity)) AS RequiredQty,0
--From tblMFWorkOrderRecipeItem ri 
--where ri.intWorkOrderId=@intWorkOrderId and ri.intRecipeItemTypeId=1
--UNION
--Select rs.intSubstituteItemId,(rs.dblQuantity * (@dblQtyToProduce/@dblRecipeQuantity)) AS RequiredQty,1
--From tblMFWorkOrderRecipeSubstituteItem rs 
--where rs.intWorkOrderId=@intWorkOrderId and rs.intRecipeItemTypeId=1

--Insert into @tblReservedQty
--Select cl.intLotId,Sum(cl.dblQuantity) AS dblReservedQty 
--From tblMFWorkOrderConsumedLot cl 
--Join tblMFWorkOrder w on cl.intWorkOrderId=w.intWorkOrderId
--join tblICLot l on l.intLotId=cl.intLotId
--where w.intStatusId<>13
--group by cl.intLotId

--Insert Into @tblAvailableQty(intLotId,intItemId,strLotNo,strItemNo,dblAvailableQty,dblSelectedQty,dblOverCommitQty,dblWeightPerUnit,strUOM)
--Select l.intLotId,l.intItemId,icl.strLotNumber,i.strItemNo,
--ISNULL((ISNULL(icl.dblWeight,0) - ISNULL(r.dblReservedQty,0)),0) AS dblAvailableQty,
--l.dblQty,
--(l.dblQty % l.dblWeightPerUnit) AS dblOverCommitQty,
--l.dblWeightPerUnit,
--um.strUnitMeasure
--from @tblLot l
--Left Join @tblReservedQty r on l.intLotId=r.intLotId
--Join tblICLot icl on l.intLotId=icl.intLotId 
--Join tblICItem i on l.intItemId=i.intItemId
--Join tblICItemUOM iu on l.intItemUOMId=iu.intItemUOMId
--Join tblICUnitMeasure um on iu.intUnitMeasureId=um.intUnitMeasureId

--Validation #1
If Exists(Select 1 From tblMFBlendValidation Where intBlendValidationDefaultId=1 AND intTypeId=2)
Begin

Set @strMessage=''

Select @strMessage=a.strMessage,@intMessageTypeId=a.intMessageTypeId 
From tblMFBlendValidation a
Where intBlendValidationDefaultId=1 AND intTypeId=2

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
If Exists(Select 1 From tblMFBlendValidation Where intBlendValidationDefaultId=2 AND intTypeId=2)
Begin

Set @strMessage=''

Select @strMessage=a.strMessage,@intMessageTypeId=a.intMessageTypeId 
From tblMFBlendValidation a
Where intBlendValidationDefaultId=2 AND intTypeId=2

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
If Exists(Select 1 From tblMFBlendValidation Where intBlendValidationDefaultId=3 AND intTypeId=2)
Begin

Set @strMessage=''

Select @strMessage=a.strMessage,@intMessageTypeId=a.intMessageTypeId 
From tblMFBlendValidation a
Where intBlendValidationDefaultId=3 AND intTypeId=2

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
If Exists(Select 1 From tblMFBlendValidation Where intBlendValidationDefaultId=4 AND intTypeId=2)
Begin

Set @strMessage=''

Select @strMessage=a.strMessage,@intMessageTypeId=a.intMessageTypeId 
From tblMFBlendValidation a
Where intBlendValidationDefaultId=4 AND intTypeId=2

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
If Exists(Select 1 From tblMFBlendValidation Where intBlendValidationDefaultId=5 AND intTypeId=2)
Begin

Set @strMessage=''

Select @strMessage=a.strMessage,@intMessageTypeId=a.intMessageTypeId 
From tblMFBlendValidation a
Where intBlendValidationDefaultId=5 AND intTypeId=2

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
If Exists(Select 1 From tblMFBlendValidation Where intBlendValidationDefaultId=6 AND intTypeId=2)
Begin

Set @strMessage=''

Select @strMessage=a.strMessage,@intMessageTypeId=a.intMessageTypeId 
From tblMFBlendValidation a
Where intBlendValidationDefaultId=6 AND intTypeId=2

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
If Exists(Select 1 From tblMFBlendValidation Where intBlendValidationDefaultId=7 AND intTypeId=2)
Begin

Set @strMessage=''

Select @strMessage=a.strMessage,@intMessageTypeId=a.intMessageTypeId 
From tblMFBlendValidation a
Where intBlendValidationDefaultId=7 AND intTypeId=2

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
If Exists(Select 1 From tblMFBlendValidation Where intBlendValidationDefaultId=8 AND intTypeId=2)
Begin

Set @strMessage=''

Select @strMessage=a.strMessage,@intMessageTypeId=a.intMessageTypeId 
From tblMFBlendValidation a
Where intBlendValidationDefaultId=8 AND intTypeId=2

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


--Validation #9
If Exists(Select 1 From tblMFBlendValidation Where intBlendValidationDefaultId=9 AND intTypeId=1)
Begin

Set @strMessage=''

--Get Affordability Cost
Select @dblAffordabilityCost=(CASE Month(GETDATE()) 
			WHEN 1 THEN bg.dblJan WHEN 2 THEN bg.dblFeb WHEN 3 THEN bg.dblMar WHEN 4 THEN bg.dblApr WHEN 5 THEN bg.dblMay WHEN 6 THEN bg.dblJun 
			WHEN 7 THEN bg.dblJul WHEN 8 THEN bg.dblAug WHEN 9 THEN bg.dblSep WHEN 10 THEN bg.dblOct WHEN 11 THEN bg.dblNov WHEN 12 THEN bg.dblDec 
			END)
From tblMFBudget bg
Where bg.intItemId=@intBlendItemId AND bg.intLocationId=@intLocationId AND bg.intYear=YEAR(GETDATE()) AND bg.intBudgetTypeId=2

--Get Expected Cost
Select @dblExpectedCost=SUM(tl.dblQty * ISNULL(l.dblLastCost,0)) / (SELECT sum(dblQty)
			FROM @tblLot l join tblICItem i on l.intItemId=i.intItemId Where i.intCategoryId not in (Select * from dbo.[fnCommaSeparatedValueToTable](@strPackagingCategoryId)))
From @tblLot tl Join tblICLot l on tl.intLotId=l.intLotId

If ISNULL(@dblExpectedCost,0)>0 AND ISNULL(@dblAffordabilityCost,0)>0
Begin
	--Get Affordability Range Min Value from Item
	Select TOP 1 @dblAffordabilityRangeMinValue = ppv.dblMinValue
	from tblQMProduct p
	Join tblQMProductProperty pp on p.intProductId=pp.intProductId
	Join tblQMProductPropertyValidityPeriod ppv on pp.intProductPropertyId=ppv.intProductPropertyId
	Where DATEPART(dy, GETDATE()) BETWEEN DATEPART(dy, ppv.dtmValidFrom) AND DATEPART(dy, ppv.dtmValidTo)
	AND p.intProductTypeId=2 AND p.intProductValueId=@intBlendItemId AND pp.intTestId=@intTestIdForAffordabilityRange

	--Get Affordability Range Min Value from Category if not available for Item
	If ISNULL(@dblAffordabilityRangeMinValue,0.0)=0 OR @dblAffordabilityRangeMinValue IS NULL
	Select TOP 1 @dblAffordabilityRangeMinValue = ppv.dblMinValue
	from tblQMProduct p
	Join tblQMProductProperty pp on p.intProductId=pp.intProductId
	Join tblQMProductPropertyValidityPeriod ppv on pp.intProductPropertyId=ppv.intProductPropertyId
	Where DATEPART(dy, GETDATE()) BETWEEN DATEPART(dy, ppv.dtmValidFrom) AND DATEPART(dy, ppv.dtmValidTo)
	AND p.intProductTypeId=1 AND p.intProductValueId=(Select intCategoryId From tblICItem Where intItemId=@intBlendItemId) AND pp.intTestId=@intTestIdForAffordabilityRange

	Set @dblAffordabilityCostFinal=ISNULL(@dblAffordabilityCost,0.0) + (ISNULL(@dblAffordabilityCost,0.0) * ISNULL(@dblAffordabilityRangeMinValue,0.0) / 100.0) 

	Select @strMessage=a.strMessage,@intMessageTypeId=a.intMessageTypeId 
	From tblMFBlendValidation a
	Where intBlendValidationDefaultId=9 AND intTypeId=1

	--If user has override role, then show error as warning
	If Exists(Select 1 from tblSMUserSecurityCompanyLocationRolePermission 
	Where intEntityId=@intUserId AND intUserRoleId=@intUserRoleIdToOverrideAffordabilityCheck AND intCompanyLocationId=@intLocationId)
		Set @intMessageTypeId=1

	If ISNULL(@dblExpectedCost,0.0)>ISNULL(@dblAffordabilityCostFinal,0.0)
	Begin

		set @strMessageFinal=@strMessage
		Set @strMessageFinal =REPLACE(@strMessageFinal,'@1',dbo.fnRemoveTrailingZeroes(@dblAffordabilityCostFinal))
		Set @strMessageFinal =REPLACE(@strMessageFinal,'@2', dbo.fnRemoveTrailingZeroes(@dblExpectedCost))

		Insert Into @tblValidationMessages(intMessageTypeId,strMessage)
		Values(@intMessageTypeId,@strMessageFinal)

	End

End --End If

End --End Validation #9



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