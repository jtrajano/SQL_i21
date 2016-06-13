CREATE PROCEDURE [dbo].[uspMFAutoBlendSheet]
    @intLocationId INT,                            
    @intBlendRequirementId INT,    
    @dblQtyToProduce NUMERIC(38,20),                                  
    @strXml NVARCHAR(MAX)=NULL  
AS
	SET QUOTED_IDENTIFIER OFF
	SET ANSI_NULLS ON
	SET NOCOUNT ON
	SET XACT_ABORT ON
	SET ANSI_WARNINGS OFF

Declare @intBlendItemId int

Select @intBlendItemId=intItemId From tblMFBlendRequirement Where intBlendRequirementId=@intBlendRequirementId

IF(SELECT ISNULL(COUNT(1),0) FROM tblMFBlendRequirementRule WHERE intBlendRequirementId=@intBlendRequirementId) = 0  
	RAISERROR('Unable to create auto blend sheet as business rules are not added to the blend requirement.',16,1)

IF EXISTS(SELECT * FROM tblMFBlendRequirementRule a JOIN tblMFBlendSheetRule b ON a.intBlendSheetRuleId=b.intBlendSheetRuleId
WHERE b.strName='Is Quality Data Applicable?' AND a.strValue='No' and a.intBlendRequirementId=@intBlendRequirementId)
BEGIN

Declare @tblPickedLots AS table
( 
	intWorkOrderInputLotId int,
	intLotId int,
	strLotNumber nvarchar(50),
	strItemNo nvarchar(50),
	strDescription nvarchar(200),
	dblQuantity numeric(38,20),
	intItemUOMId int,
	strUOM nvarchar(50),
	dblIssuedQuantity numeric(38,20),
	intItemIssuedUOMId int,
	strIssuedUOM nvarchar(50),
	intItemId int,
	intRecipeItemId int,
	dblUnitCost numeric(38,20),
	dblDensity numeric(38,20),
	dblRequiredQtyPerSheet numeric(38,20),
	dblWeightPerUnit numeric(38,20),
	dblRiskScore numeric(38,20),
	intStorageLocationId int,
	strStorageLocationName nvarchar(50),
	strLocationName nvarchar(50),
	intLocationId int,
	strSubLocationName nvarchar(50),
	intSubLocationId int,
	strLotAlias nvarchar(50),
	ysnParentLot bit,
	strRowState nvarchar(50)
)

	INSERT INTO @tblPickedLots
	EXEC [uspMFAutoBlendSheetFIFO] 
			@intLocationId=@intLocationId,
			@intBlendRequirementId=@intBlendRequirementId,
			@dblQtyToProduce=@dblQtyToProduce,
			@strXml=@strXml,
			@ysnFromPickList=0

--Delete items if consumption method is not By Lot
Delete tpl From @tblPickedLots tpl 
Join tblMFRecipeItem ri on tpl.intItemId=ri.intItemId 
Join tblMFRecipe r on ri.intRecipeId=r.intRecipeId 
Where r.intItemId=@intBlendItemId AND r.intLocationId=@intLocationId AND r.ysnActive=1 AND ri.intConsumptionMethodId <> 1 

--Sub Items
Delete tpl From @tblPickedLots tpl
Join tblMFRecipeSubstituteItem rs on tpl.intItemId=rs.intSubstituteItemId 
Join tblMFRecipeItem ri on ri.intItemId=rs.intItemId 
Join tblMFRecipe r on ri.intRecipeId=r.intRecipeId 
Where r.intItemId=@intBlendItemId AND r.intLocationId=@intLocationId AND r.ysnActive=1 AND ri.intConsumptionMethodId <> 1 

--Delete shortage of item records
Delete From @tblPickedLots Where ISNULL(intLotId,0)=0

--Sub Items
Delete tpl From @tblPickedLots tpl
Join tblMFRecipeSubstituteItem rs on tpl.intItemId=rs.intSubstituteItemId 
Join tblMFRecipeItem ri on ri.intItemId=rs.intItemId 
Join tblMFRecipe r on ri.intRecipeId=r.intRecipeId 
Where r.intItemId=@intBlendItemId AND r.intLocationId=@intLocationId AND r.ysnActive=1 AND ri.intConsumptionMethodId <> 1 

--Delete shortage of item records
Delete From @tblPickedLots Where ISNULL(intLotId,0)=0

Select * From @tblPickedLots

END

ELSE
BEGIN
	EXEC [uspMFAutoBlendSheetQuality] 
			@intLocationId=@intLocationId,
			@intBlendRequirementId=@intBlendRequirementId,
			@dblQtyToProduce=@dblQtyToProduce,
			@strXml=@strXml
END
