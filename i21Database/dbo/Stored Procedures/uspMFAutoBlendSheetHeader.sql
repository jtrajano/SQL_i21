CREATE PROCEDURE [dbo].[uspMFAutoBlendSheetHeader]
    @intLocationId INT,                            
    @intBlendRequirementId INT,    
    @dblQtyToProduce NUMERIC(18,6),
	@strXml NVARCHAR(MAX)=NULL  
AS
	SET QUOTED_IDENTIFIER OFF
	SET ANSI_NULLS ON
	SET NOCOUNT ON
	SET XACT_ABORT ON
	SET ANSI_WARNINGS OFF

	Declare @idoc int

	IF(SELECT ISNULL(COUNT(1),0) FROM tblMFBlendRequirementRule WHERE intBlendRequirementId=@intBlendRequirementId) = 0  
	RAISERROR('Unable to create auto blend sheet as business rules are not added to the blend requirement.',16,1)

	IF (ISNULL(@strXml,'') <> '')
	BEGIN
		EXEC sp_xml_preparedocument @idoc OUTPUT, @strXml

		DECLARE @tblRule AS TABLE
		(
		 intBlendRequirementRuleId INT
		,intBlendSheetRuleId INT
		,strValue NVARCHAR(50)
		,intSequenceNo INT
		)

		INSERT INTO @tblRule(
		 intBlendRequirementRuleId,intBlendSheetRuleId,strValue,intSequenceNo)
		 Select  intBlendRequirementRuleId,intBlendSheetRuleId,strValue,intSequenceNo
		 FROM OPENXML(@idoc, 'root/rule', 2)  
		 WITH (
		    intBlendRequirementRuleId int, 
			intBlendSheetRuleId int,
			strValue nVarchar(50),
			intSequenceNo int
		)

		Update a Set a.strValue=b.strValue,a.intSequenceNo=b.intSequenceNo 
		From tblMFBlendRequirementRule a Join @tblRule b on a.intBlendRequirementRuleId=b.intBlendRequirementRuleId 
		And a.intBlendSheetRuleId=b.intBlendSheetRuleId

		IF @idoc <> 0 EXEC sp_xml_removedocument @idoc  
	END

	SELECT 0 AS intWorkOrderId,'' AS strWorkOrderNo,i.intItemId,i.strItemNo,@dblQtyToProduce AS dblQuantity,@dblQtyToProduce AS dblPlannedQuantity,iu.intItemUOMId,
	um.strUnitMeasure AS strUOM,2 AS intStatusId,br.intManufacturingCellId,br.intMachineId,br.dtmDueDate AS dtmExpectedDate,
	br.dblBlenderSize AS dblBinSize,br.intBlendRequirementId,CAST(0 AS BIT) AS ysnUseTemplate,CAST(0 AS BIT) AS ysnKittingEnabled,br.strDemandNo AS strComment,
	br.intLocationId,Cast(0 AS decimal) AS dblBalancedQtyToProduce,ip.dblStandardCost,CAST(ISNULL(Ceiling(br.dblEstNoOfBlendSheet),1) AS decimal) AS dblEstNoOfBlendSheet,
	mc.strCellName,m.strName AS strMachineName
	FROM tblMFBlendRequirement br JOIN tblICItem i ON br.intItemId=i.intItemId 
	Join tblICItemUOM iu on i.intItemId=iu.intItemId and br.intUOMId=iu.intUnitMeasureId 
	Join tblICUnitMeasure um on iu.intUnitMeasureId=um.intUnitMeasureId
	Left Join tblICItemLocation il on i.intItemId=il.intItemId and il.intLocationId=@intLocationId
	Left Join tblICItemPricing ip on ip.intItemId=i.intItemId And ip.intItemLocationId=il.intItemLocationId
	Left Join tblMFManufacturingCell mc on br.intManufacturingCellId=mc.intManufacturingCellId
	Left Join tblMFMachine m on br.intMachineId=m.intMachineId
	WHERE br.intBlendRequirementId=@intBlendRequirementId