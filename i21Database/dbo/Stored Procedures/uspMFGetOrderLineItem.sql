CREATE PROCEDURE uspMFGetOrderLineItem (
	@intOrderHeaderId INT
	,@intItemId INT = 0
	,@strItemNo NVARCHAR(50) = '%'
	)
AS
SELECT
	OD.intOrderDetailId 
	,I.intItemId
	,I.strItemNo
	,I.strDescription
	,OD.intLineNo 
	,OD.dblQty 
	,IU.intItemUOMId
	,UM.intUnitMeasureId
	,UM.strUnitMeasure 
FROM tblICItem I
JOIN tblMFOrderDetail OD ON I.intItemId = OD.intItemId
	AND intOrderHeaderId = @intOrderHeaderId
JOIN tblICItemUOM IU on IU.intItemUOMId =OD.intItemUOMId 
JOIN tblICUnitMeasure UM on UM.intUnitMeasureId =IU.intUnitMeasureId 
WHERE I.intItemId = (
		CASE 
			WHEN @intItemId > 0
				THEN @intItemId
			ELSE I.intItemId
			END
		)
	AND I.strItemNo LIKE '%' + @strItemNo + '%'

