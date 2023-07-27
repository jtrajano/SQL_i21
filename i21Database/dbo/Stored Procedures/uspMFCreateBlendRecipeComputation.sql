CREATE PROCEDURE [dbo].[uspMFCreateBlendRecipeComputation]
(
	@intWorkOrderId			INT
  , @intTypeId				INT
  , @strXml					NVARCHAR(MAX)
  , @ysnRemoveComputation	BIT = 0		 /* Set to 1/true to remove the computation if needed. */
)
AS

DECLARE @idoc			INT
	  , @intProductId	INT

EXEC sp_xml_preparedocument @idoc OUTPUT
						  , @strXml

--Add/Update Quality Parameters
DECLARE @tblRecipeComputation AS TABLE
(
	intRowNo			INT IDENTITY(1,1)
  , intTestId			INT
  , intPropertyId		INT
  , dblComputedValue	NUMERIC(18,6)
  , dblMinValue			NUMERIC(18,6)
  , dblMaxValue			NUMERIC(18,6)
  , intMethodId			INT
);

SELECT @intProductId=intItemId
FROM OPENXML(@idoc, 'root', 2)  WITH 
(
	intItemId INT
)

INSERT INTO @tblRecipeComputation
(
	intTestId
  , intPropertyId
  , dblComputedValue
  , dblMinValue
  , dblMaxValue
  , intMethodId
)
SELECT intTestId
	 , intPropertyId
	 , dblComputedValue
	 , dblMinValue
	 , dblMaxValue
	 , intMethodId
FROM OPENXML(@idoc, 'root/computation', 2)  
WITH 
( 
	intTestId			INT
  , intPropertyId		INT
  , dblComputedValue	NUMERIC(18, 6)
  , dblMinValue			NUMERIC(18, 6)
  , dblMaxValue			NUMERIC(18, 6)
  , intMethodId			INT
);

/* Remove Blend Quality Parameter if theres data/value sent. */
IF (SELECT COUNT(*) FROM @tblRecipeComputation) > 1 OR @ysnRemoveComputation = 1
	BEGIN
		DELETE 
		FROM tblMFWorkOrderRecipeComputation 
		WHERE intWorkOrderId = @intWorkOrderId AND intTypeId = @intTypeId
	END


INSERT INTO tblMFWorkOrderRecipeComputation
(
	intWorkOrderId
  , intTestId
  , intPropertyId
  , dblComputedValue
  , dblMinValue
  , dblMaxValue
  , intTypeId
  , intMethodId
)
SELECT @intWorkOrderId
	 , intTestId
	 , intPropertyId
	 , dblComputedValue
	 , dblMinValue
	 , dblMaxValue
	 , @intTypeId
	 , intMethodId 
FROM @tblRecipeComputation

IF @idoc <> 0 
	BEGIN
		EXEC sp_xml_removedocument @idoc		
	END
