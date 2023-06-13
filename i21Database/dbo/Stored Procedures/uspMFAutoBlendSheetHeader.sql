CREATE PROCEDURE [dbo].[uspMFAutoBlendSheetHeader]
	@intLocationId		   INT
  , @intBlendRequirementId INT
  , @dblQtyToProduce	   NUMERIC(18, 6)
  , @strXml				   NVARCHAR(MAX) = NULL  
  , @ysnUpdateRule		   BIT = 1
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

DECLARE @idoc INT
DECLARE @ysnRecipeHeaderValidation INT = 0

IF(SELECT ISNULL(COUNT(1), 0) FROM tblMFBlendRequirementRule WHERE intBlendRequirementId = @intBlendRequirementId) = 0
	BEGIN 
		RAISERROR('Unable to create auto blend sheet as business rules are not added to the blend requirement.',16,1)
	END

IF (ISNULL(@strXml, '') <> '')
	BEGIN
		EXEC sp_xml_preparedocument @idoc OUTPUT, @strXml

		DECLARE @tblRule AS TABLE (intBlendRequirementRuleId INT
								 , intBlendSheetRuleId		 INT
								 , strValue					 NVARCHAR(50)
								 , intSequenceNo			 INT)
		
		/* Get Blend Requirement Rule . */
		INSERT INTO @tblRule(intBlendRequirementRuleId
						   , intBlendSheetRuleId
						   , strValue
						   , intSequenceNo)
		SELECT intBlendRequirementRuleId
			 , intBlendSheetRuleId
			 , strValue
			 , intSequenceNo
		FROM OPENXML(@idoc, 'root/rule', 2) WITH (intBlendRequirementRuleId INT
												, intBlendSheetRuleId INT
												, strValue NVARCHAR(50)
												, intSequenceNo INT)

		/* Update Blend Requirement Rule. */
		IF (@ysnUpdateRule = 1)
			BEGIN
				UPDATE BlendRequirementRule 
				SET BlendRequirementRule.strValue		= DeclaredRule.strValue
				  , BlendRequirementRule.intSequenceNo	= DeclaredRule.intSequenceNo 
				FROM tblMFBlendRequirementRule AS BlendRequirementRule 
				JOIN @tblRule AS DeclaredRule ON BlendRequirementRule.intBlendRequirementRuleId = DeclaredRule.intBlendRequirementRuleId 
											 AND BlendRequirementRule.intBlendSheetRuleId = DeclaredRule.intBlendSheetRuleId;
			END
		/* End of Update Blend Requirement Rule. */
		

		IF @idoc <> 0 
			BEGIN
				EXEC sp_xml_removedocument @idoc  
			END
	END

/* Retrieve Recipe Header Validation */
SELECT @ysnRecipeHeaderValidation = ISNULL(ysnRecipeHeaderValidation, 0)
FROM tblMFCompanyPreference


/* Returned Data. */
SELECT 0								AS intWorkOrderId
	 , ''								AS strWorkOrderNo
	 , Item.intItemId
	 , Item.strItemNo
	 , @dblQtyToProduce					AS dblQuantity
	 , @dblQtyToProduce					AS dblPlannedQuantity
	 , ItemUOM.intItemUOMId
	 , UnitOfMeasure.strUnitMeasure		AS strUOM
	 , 2								AS intStatusId
	 , BlendRequirement.intManufacturingCellId
	 , BlendRequirement.intMachineId
	 , BlendRequirement.dtmDueDate		AS dtmExpectedDate
	 , BlendRequirement.dblBlenderSize	AS dblBinSize
	 , BlendRequirement.intBlendRequirementId
	 , CAST(0 AS BIT) AS ysnUseTemplate
	 , CAST(0 AS BIT) AS ysnKittingEnabled
	 , BlendRequirement.strDemandNo		AS strComment
	 , BlendRequirement.intLocationId
	 , CAST(0 AS DECIMAL)				AS dblBalancedQtyToProduce
	 , ItemPricing.dblStandardCost
	 , CAST(ISNULL(CEILING(BlendRequirement.dblEstNoOfBlendSheet), 1) AS DECIMAL) AS dblEstNoOfBlendSheet
	 , MachineCell.strCellName
	 , Machine.strName					AS strMachineName
	 , Recipe.intManufacturingProcessId
	 , Machine.intIssuedUOMTypeId
	 , MachineIssuedUOM.strName			AS strIssuedUOMType
	 , BlendRequirement.strReferenceNo
	 , 'Not Released'	AS strWorkOrderStatus
FROM tblMFBlendRequirement AS BlendRequirement 
JOIN tblICItem AS Item ON BlendRequirement.intItemId = Item.intItemId 
JOIN tblICItemUOM AS ItemUOM ON Item.intItemId = ItemUOM.intItemId AND BlendRequirement.intUOMId = ItemUOM.intUnitMeasureId 
JOIN tblICUnitMeasure AS UnitOfMeasure ON ItemUOM.intUnitMeasureId = UnitOfMeasure.intUnitMeasureId
LEFT JOIN tblICItemLocation AS ItemLocation ON Item.intItemId = ItemLocation.intItemId AND ItemLocation.intLocationId = @intLocationId
LEFT JOIN tblICItemPricing AS ItemPricing ON ItemPricing.intItemId = Item.intItemId AND ItemPricing.intItemLocationId = ItemLocation.intItemLocationId
LEFT JOIN tblMFManufacturingCell AS MachineCell ON BlendRequirement.intManufacturingCellId = MachineCell.intManufacturingCellId
LEFT JOIN tblMFMachine AS Machine ON BlendRequirement.intMachineId = Machine.intMachineId
LEFT JOIN tblMFMachineIssuedUOMType AS MachineIssuedUOM ON Machine.intIssuedUOMTypeId = MachineIssuedUOM.intIssuedUOMTypeId
LEFT JOIN tblMFRecipe AS Recipe ON BlendRequirement.intItemId = Recipe.intItemId AND BlendRequirement.intLocationId = Recipe.intLocationId AND Recipe.ysnActive = 1
							   		/* Filter recipe with Validity if Company Configuration Recipe Header Validation is set to true. */
							   AND (@ysnRecipeHeaderValidation = 1 AND GETDATE() BETWEEN Recipe.dtmValidFrom AND Recipe.dtmValidTo)
WHERE BlendRequirement.intBlendRequirementId = @intBlendRequirementId