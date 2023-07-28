--liquibase formatted sql

-- changeset Von:fnCTGetCleanUncleanWeight.sql.1 runOnChange:true splitStatements:false
-- comment: RK-1234

CREATE OR ALTER FUNCTION [dbo].[fnCTGetCleanUncleanWeight]
(
	@intLoadDetailId	INT
)
RETURNS @returntable	TABLE
(
	dblUncleanWeight	NUMERIC(18,6),
	dblCleanWeight		NUMERIC(18,6)
)
AS
BEGIN

	DECLARE @intCleanCostUOMId	INT,
			@dblUncleanWeight	NUMERIC(38,20), 
			@dblCleanWeight		NUMERIC(38,20)

	SELECT	@intCleanCostUOMId	= intCleanCostUOMId 
	FROM	tblCTCompanyPreference
	
	SELECT	@dblUncleanWeight = SUM(dbo.fnCTConvertQuantityToTargetItemUOM(RI.intItemId,UM.intUnitMeasureId, @intCleanCostUOMId, RI.dblNet))
			
	FROM	tblICInventoryReceiptItem		RI  
	JOIN	tblICItemUOM					UM ON UM.intItemUOMId				=	RI.intWeightUOMId  
	WHERE	RI.intSourceId = @intLoadDetailId

	SELECT	@dblCleanWeight = SUM(dbo.fnCTConvertQuantityToTargetItemUOM(RI.intItemId,UM.intUnitMeasureId, @intCleanCostUOMId, ISNULL(IL.dblGrossWeight,0) - ISNULL(dblTareWeight,0)))  
	
	FROM	tblICInventoryReceiptItem		RI  
	JOIN	tblICInventoryReceiptItemLot	IL ON IL.intInventoryReceiptItemId	=	RI.intInventoryReceiptItemId
	JOIN	tblICItemUOM					UM ON UM.intItemUOMId				=	RI.intWeightUOMId  
	WHERE	RI.intSourceId = @intLoadDetailId AND ISNULL(IL.strCondition,'') <> 'Damaged'

	INSERT	@returntable
	(
			dblUncleanWeight, 
			dblCleanWeight
	)
	SELECT 	@dblUncleanWeight, @dblCleanWeight

	RETURN;
END



