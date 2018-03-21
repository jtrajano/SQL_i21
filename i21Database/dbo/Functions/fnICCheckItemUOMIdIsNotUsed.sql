
-- Used in tblICItemUOM > CK_ItemUOMId_IS_NOT_USED CONSTRAINT. 
-- It will check if the intItemUOMId already has a transaction. 
CREATE FUNCTION fnICCheckItemUOMIdIsNotUsed (
	@intItemId AS INT 
	,@intItemUOMId AS INT 
	,@intUnitMeasureId AS INT 
	,@dblUnitQty AS NUMERIC(38, 20)
)
RETURNS BIT
AS
BEGIN
	IF (
		@intItemUOMId IS NOT NULL 
		AND (
			EXISTS (SELECT TOP 1 1 FROM tblICInventoryTransaction t WHERE t.intItemUOMId = @intItemUOMId AND t.intItemId = @intItemId) 
			OR EXISTS (
				SELECT	TOP 1 1 
				FROM	tblICLot l 
				WHERE	l.dblQty <> 0
						AND l.intItemId = @intItemId
						AND (
							l.intItemUOMId = @intItemUOMId 
							OR l.intWeightUOMId = @intItemUOMId
						)
			)
		)
	)
	BEGIN 
		RETURN 0
	END 

	RETURN 1
END