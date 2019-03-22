CREATE FUNCTION [dbo].[fnLGGetDefaultWeightItemUOM]()
RETURNS INT
AS 
BEGIN 
	DECLARE	@result INT

	DECLARE @intItemUOMIdTo AS INT

	SELECT Top (1) @intItemUOMIdTo = IU.intItemUOMId FROM tblICItemUOM IU 
		JOIN tblICUnitMeasure UOM ON UOM.intUnitMeasureId = IU.intUnitMeasureId
		JOIN tblLGCompanyPreference C On C.intWeightUOMId = UOM.intUnitMeasureId

	IF @intItemUOMIdTo IS NULL 
	BEGIN 
		RETURN NULL; 
	END 
	SET @result = @intItemUOMIdTo

	RETURN @result;	
END
GO
