CREATE PROCEDURE [dbo].[uspMFAutoBlendSheet]
    @intLocationId INT,                            
    @intBlendRequirementId INT,    
    @dblQtyToProduce NUMERIC(18,6),                                  
    @strXML NVARCHAR(MAX)=NULL  
AS
	SET QUOTED_IDENTIFIER OFF
	SET ANSI_NULLS ON
	SET NOCOUNT ON
	SET XACT_ABORT ON
	SET ANSI_WARNINGS OFF

IF(SELECT ISNULL(COUNT(1),0) FROM tblMFBlendRequirementRule WHERE intBlendRequirementId=@intBlendRequirementId) = 0  
	RAISERROR('Unable to create auto blend sheet as business rules are not added to the blend requirement.',16,1)

--Blend Sheet Header
--SELECT 0 AS intWorkOrderId,'' AS strWorkOrderNo,b.intItemId,b.strItemNo,@dblQtyToProduce AS dblQuantity,c.intItemUOMId,
--d.strUnitMeasure AS strUOM,2 AS intStatusId,a.intManufacturingCellId,a.intMachineId,a.dtmDueDate AS dtmExpectedDate,
--a.dblBlenderSize AS dblBinSize,a.intBlendRequirementId,CAST(0 AS BIT) AS ysnUseTemplate,CAST(0 AS BIT) AS ysnKittingEnabled,'' AS strComment,
--a.intLocationId,@dblQtyToProduce AS dblBalancedQtyToProduce
--FROM tblMFBlendRequirement a JOIN tblICItem b ON a.intItemId=b.intItemId 
--Join tblICItemUOM c on b.intItemId=c.intItemId and a.intUOMId=c.intUnitMeasureId 
--Join tblICUnitMeasure d on c.intUnitMeasureId=d.intUnitMeasureId
--WHERE a.intBlendRequirementId=@intBlendRequirementId

--Blend Sheet Input Lots
IF EXISTS(SELECT * FROM tblMFBlendRequirementRule a JOIN tblMFBlendSheetRule b ON a.intBlendSheetRuleId=b.intBlendSheetRuleId
WHERE b.strName='Is Quality Data Applicable?' AND a.strValue='No' and a.intBlendRequirementId=@intBlendRequirementId)
BEGIN
	EXEC [uspMFAutoBlendSheetFIFO] 
			@intLocationId=@intLocationId,
			@intBlendRequirementId=@intBlendRequirementId,
			@dblQtyToProduce=@dblQtyToProduce,
			@strXML=@strXML
END
