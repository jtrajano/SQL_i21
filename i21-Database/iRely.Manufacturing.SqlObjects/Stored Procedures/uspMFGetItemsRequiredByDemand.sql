CREATE PROCEDURE [dbo].[uspMFGetItemsRequiredByDemand]
	@strBlendRequirementIds nvarchar(max),
	@intLocationId int
AS

Declare @index int
Declare @id int
Declare @intMinDemand Int
Declare @intItemId int
Declare @dblQtyToProduce decimal(38,20)
Declare @dtmDueDate DateTime=GETDATE()

Declare @tblBlendRequirement table
(
	intRowNo int Identity(1,1),
	intBlendRequirementId int,
	intItemId int,
	dblQuantity numeric(38,20)
)

Declare @tblItem table
(

	intItemId int,
	strItemNo nvarchar(50),
	strDescription nvarchar(250),
	dblRequiredQty numeric(38,20),
	dblPhysicalQty numeric(38,20),
	dblReservedQty numeric(38,20),
	dblAvailableQty numeric(38,20),
	dblSelectedQty numeric(38,20),
	dblAvailableUnit numeric(38,20),
	ysnIsSubstitute bit,
	intParentItemId int,
	ysnHasSubstitute bit,
	intRecipeItemId int,
	intParentRecipeItemId int,
	strGroupName nvarchar(50),
	dblLowerToleranceQty numeric(38,20),
	dblUpperToleranceQty numeric(38,20),
	ysnMinorIngredient bit,
	ysnScaled bit,
	dblRecipeQty numeric(38,20),
	dblRecipeItemQty numeric(38,20),
	strRecipeItemUOM nvarchar(50),
	strConsumptionStorageLocation nvarchar(50),
	intConsumptionMethodId int

)

--Get the Comma Separated Work Order Ids into a table
SET @index = CharIndex(',',@strBlendRequirementIds)
WHILE @index > 0
BEGIN
        SET @id = SUBSTRING(@strBlendRequirementIds,1,@index-1)
        SET @strBlendRequirementIds = SUBSTRING(@strBlendRequirementIds,@index+1,LEN(@strBlendRequirementIds)-@index)

        INSERT INTO @tblBlendRequirement(intBlendRequirementId) values (@id)
        SET @index = CharIndex(',',@strBlendRequirementIds)
END
SET @id=@strBlendRequirementIds
INSERT INTO @tblBlendRequirement(intBlendRequirementId) values (@id)

Update tbr Set tbr.intItemId=br.intItemId,tbr.dblQuantity=br.dblQuantity
From @tblBlendRequirement tbr Join tblMFBlendRequirement br on tbr.intBlendRequirementId=br.intBlendRequirementId

Select @intMinDemand=Min(intRowNo) from @tblBlendRequirement

While(@intMinDemand is not null)
Begin
	Select @intItemId=intItemId,@dblQtyToProduce=dblQuantity From @tblBlendRequirement Where intRowNo=@intMinDemand

	Insert Into @tblItem
	Exec uspMFGetBlendSheetItems @intItemId,@intLocationId,@dblQtyToProduce,@dtmDueDate

	Select @intMinDemand=Min(intRowNo) from @tblBlendRequirement Where intRowNo>@intMinDemand
End

Select intItemId,strItemNo,strDescription,SUM(ISNULL(dblRequiredQty,0)) AS dblRequiredQty,MAX(ISNULL(dblPhysicalQty,0)) AS dblPhysicalQty,MAX(ISNULL(dblReservedQty,0)) AS dblReservedQty,
MAX(ISNULL(dblAvailableQty,0)) AS dblAvailableQty,0 AS intRecipeItemId
 From @tblItem
Group By intItemId,strItemNo,strDescription
