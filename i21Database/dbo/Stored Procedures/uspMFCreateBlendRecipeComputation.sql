CREATE PROCEDURE [dbo].[uspMFCreateBlendRecipeComputation]
	@intWorkOrderId int,
	@intTypeId int,
	@strXml nVarchar(Max)
AS

Declare @idoc int,
		@intProductId Int

EXEC sp_xml_preparedocument @idoc OUTPUT, @strXml

--Add/Update Quality Parameters
	DECLARE @tblRecipeComputation AS TABLE
	   (
	     intRowNo int Identity(1,1)
	    ,intTestId INT
		,intPropertyId INT
		,dblComputedValue NUMERIC(18,6)
		,dblMinValue NUMERIC(18,6)
		,dblMaxValue NUMERIC(18,6)
		,intMethodId INT
	   )

Select @intProductId=intItemId
 FROM OPENXML(@idoc, 'root', 2)  
 WITH (
	intItemId int
	)

INSERT INTO @tblRecipeComputation(
 intTestId,intPropertyId,dblComputedValue,dblMinValue,dblMaxValue,intMethodId)
 Select intTestId,intPropertyId,dblComputedValue,dblMinValue,dblMaxValue,intMethodId
 FROM OPENXML(@idoc, 'root/computation', 2)  
 WITH ( 
	intTestId int,
	intPropertyId int,
	dblComputedValue numeric(18,6),
	dblMinValue numeric(18,6),
	dblMaxValue numeric(18,6),
	intMethodId int
	)

Delete From tblMFWorkOrderRecipeComputation Where intWorkOrderId=@intWorkOrderId

Insert Into tblMFWorkOrderRecipeComputation(intWorkOrderId,intTestId,intPropertyId,dblComputedValue,dblMinValue,dblMaxValue,intTypeId,intMethodId)
Select @intWorkOrderId,intTestId,intPropertyId,dblComputedValue,dblMinValue,dblMaxValue,@intTypeId,intMethodId From @tblRecipeComputation

IF @idoc <> 0 EXEC sp_xml_removedocument @idoc  