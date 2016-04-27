CREATE FUNCTION [dbo].[fnCTGetCleanUncleanWeight]
(
	@intInventoryReceiptId	INT
)
RETURNS @returntable	TABLE
(
	dblUncleanWeight	NUMERIC(18,6),
	dblCleanWeight		NUMERIC(18,6)
)
AS
BEGIN

	DECLARE @intCleanCostUOMId	INT

	SELECT	@intCleanCostUOMId	= intCleanCostUOMId 
	FROM	tblCTCompanyPreference
	
	INSERT	@returntable
	(
			dblUncleanWeight, 
			dblCleanWeight
	)
	SELECT	SUM(dbo.fnCTConvertQuantityToTargetItemUOM(RI.intItemId,UM.intUnitMeasureId, @intCleanCostUOMId, RI.dblNet)) dblUncleanWeight,  
			SUM(dbo.fnCTConvertQuantityToTargetItemUOM(RI.intItemId,UM.intUnitMeasureId, @intCleanCostUOMId, ISNULL(IL.dblGrossWeight,0) - ISNULL(dblTareWeight,0))) dblCleanWeight  
	FROM	tblICInventoryReceiptItem		RI  
	JOIN	tblICInventoryReceiptItemLot	IL ON IL.intInventoryReceiptItemId	=	RI.intInventoryReceiptItemId
	JOIN	tblICItemUOM					UM ON UM.intItemUOMId				=	RI.intWeightUOMId  
	WHERE	RI.intInventoryReceiptId = @intInventoryReceiptId ;
		
	RETURN;
END
