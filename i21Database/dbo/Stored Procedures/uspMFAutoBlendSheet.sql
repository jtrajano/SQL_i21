-- =============================================
-- Date Modified: June 06, 2022
-- Description:	  Returns BlendSheet Input Lots (Selected Lot)
-- =============================================

CREATE PROCEDURE [dbo].[uspMFAutoBlendSheet]
    @intLocationId			INT
  , @intBlendRequirementId	INT
  , @dblQtyToProduce		NUMERIC(38,20)
  , @strXml					NVARCHAR(MAX) = NULL  
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

DECLARE @intBlendItemId INT

SELECT @intBlendItemId = intItemId 
FROM tblMFBlendRequirement 
WHERE intBlendRequirementId=@intBlendRequirementId

/* Check if there's business rules from the selected Blend. */
IF (SELECT ISNULL(COUNT(1), 0) FROM tblMFBlendRequirementRule WHERE intBlendRequirementId = @intBlendRequirementId) = 0
	BEGIN
		RAISERROR('Unable to create auto blend sheet as business rules are not added to the blend requirement.', 16, 1);
	END

IF EXISTS(SELECT * 
		  FROM tblMFBlendRequirementRule a JOIN tblMFBlendSheetRule b ON a.intBlendSheetRuleId=b.intBlendSheetRuleId
		  WHERE b.strName='Is Quality Data Applicable?' AND a.strValue='No' and a.intBlendRequirementId=@intBlendRequirementId)
	BEGIN
		DECLARE @tblPickedLots AS TABLE
		(	
			intWorkOrderInputLotId	INT
		  , intLotId				INT
		  , strLotNumber			NVARCHAR(50)
		  , strItemNo				NVARCHAR(50)
		  , strDescription			NVARCHAR(200)
		  , dblQuantity				NUMERIC(38, 20)
		  , intItemUOMId			INT
		  , strUOM					NVARCHAR(50)
		  , dblIssuedQuantity		NUMERIC(38, 20)
		  , intItemIssuedUOMId		INT
		  , strIssuedUOM			NVARCHAR(50)
		  , intItemId				INT
		  , intRecipeItemId			INT
		  , dblUnitCost				NUMERIC(38, 20)
		  , dblDensity				NUMERIC(38, 20)
		  , dblRequiredQtyPerSheet	NUMERIC(38, 20)
		  , dblWeightPerUnit		NUMERIC(38, 20)
		  , dblRiskScore			NUMERIC(38, 20)
		  , intStorageLocationId	INT
		  , strStorageLocationName	NVARCHAR(50)
		  , strLocationName			NVARCHAR(50)
		  , intLocationId			INT
		  , strSubLocationName		NVARCHAR(50)
		  , intSubLocationId		INT
		  , strLotAlias				NVARCHAR(50)
		  , ysnParentLot			BIT
		  , strRowState				NVARCHAR(50)
		  , strSecondaryStatus		NVARCHAR(50)
		  , dblNoOfPallet			NUMERIC(18, 0)
		  ,strFW					NVARCHAR(3)
		    ,strProductType					NVARCHAR(100)
			  ,strBrandCode					NVARCHAR(100)
		)

		INSERT INTO @tblPickedLots EXEC uspMFAutoBlendSheetFIFO @intLocationId         = @intLocationId
															  , @intBlendRequirementId = @intBlendRequirementId
															  , @dblQtyToProduce	   = @dblQtyToProduce
															  , @strXml				   = @strXml
															  , @ysnFromPickList	   = 0

		--Delete items if consumption method is not By Lot
		DELETE tpl 
		FROM @tblPickedLots tpl 
		JOIN tblMFRecipeItem ri ON tpl.intItemId=ri.intItemId 
		JOIN tblMFRecipe r ON ri.intRecipeId=r.intRecipeId 
		WHERE r.intItemId=@intBlendItemId AND r.intLocationId = @intLocationId AND r.ysnActive = 1 AND ri.intConsumptionMethodId <> 1 

		--Sub Items
		DELETE tpl 
		FROM @tblPickedLots tpl
		JOIN tblMFRecipeSubstituteItem rs ON tpl.intItemId=rs.intSubstituteItemId 
		JOIN tblMFRecipeItem ri ON ri.intItemId=rs.intItemId 
		JOIN tblMFRecipe r ON ri.intRecipeId=r.intRecipeId 
		WHERE r.intItemId = @intBlendItemId AND r.intLocationId = @intLocationId AND r.ysnActive = 1 AND ri.intConsumptionMethodId <> 1 

		--Delete shortage of item records
		DELETE FROM @tblPickedLots WHERE ISNULL(intLotId, 0) = 0

		--Sub Items
		DELETE tpl 
		FROM @tblPickedLots tpl
		JOIN tblMFRecipeSubstituteItem rs ON tpl.intItemId=rs.intSubstituteItemId 
		JOIN tblMFRecipeItem ri ON ri.intItemId=rs.intItemId 
		JOIN tblMFRecipe r ON ri.intRecipeId=r.intRecipeId 
		WHERE r.intItemId = @intBlendItemId AND r.intLocationId = @intLocationId AND r.ysnActive = 1 AND ri.intConsumptionMethodId <> 1 

		--Delete shortage of item records
		DELETE FROM @tblPickedLots WHERE ISNULL(intLotId, 0) = 0

		/* RETURNED DATA. */
		SELECT p.*
			 , i.intCategoryId 
		FROM @tblPickedLots p 
		JOIN tblICItem i ON p.intItemId = i.intItemId

	END
ELSE
	BEGIN
		EXEC [uspMFAutoBlendSheetQuality] @intLocationId		 = @intLocationId
										, @intBlendRequirementId = @intBlendRequirementId
										, @dblQtyToProduce		 = @dblQtyToProduce
										, @strXml				 = @strXml
	END