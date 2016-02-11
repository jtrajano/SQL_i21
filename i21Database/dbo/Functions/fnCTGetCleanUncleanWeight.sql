CREATE FUNCTION [dbo].[fnCTGetCleanUncleanWeight]
(
	@intInventoryReceiptId	INT
)
RETURNS @returntable	TABLE
(
	dblUncleanWeight	INT,
	dblGrossWeight		INT
)
AS
BEGIN

	DECLARE @intCleanCostUOMId	INT

	SELECT	@intCleanCostUOMId	= intCleanCostUOMId 
	FROM	tblCTCompanyPreference
	
	INSERT	@returntable
	(
			dblUncleanWeight, 
			dblGrossWeight
	)
	SELECT	SUM(dbo.fnCTConvertQuantityToTargetItemUOM(RI.intItemId,UM.intUnitMeasureId, @intCleanCostUOMId, RI.dblNet)) dblUncleanWeight,  
			SUM(dbo.fnCTConvertQuantityToTargetItemUOM(RI.intItemId,UM.intUnitMeasureId, @intCleanCostUOMId, ISNULL(IL.dblGrossWeight,0) - ISNULL(dblTareWeight,0))) dblCleanWeight  
	FROM	tblICInventoryReceiptItem		RI  
	JOIN	tblICInventoryReceiptItemLot	IL ON IL.intInventoryReceiptItemId	=	RI.intInventoryReceiptItemId
	JOIN	tblICItemUOM					UM ON UM.intItemUOMId				=	RI.intWeightUOMId  
	WHERE	RI.intInventoryReceiptId = @intInventoryReceiptId ;
		
	RETURN;
END
