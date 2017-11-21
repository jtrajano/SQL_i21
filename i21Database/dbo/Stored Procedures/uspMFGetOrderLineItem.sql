CREATE PROCEDURE uspMFGetOrderLineItem 
	(
	@intOrderHeaderId INT
	,@intItemId INT = 0
	,@strItemNo NVARCHAR(50) = '%'
	)
AS
SELECT I.intItemId
	,I.strItemNo
	,I.strDescription
FROM tblICItem I 
JOIN tblMFOrderDetail OD ON I.intItemId = OD.intItemId
	AND intOrderHeaderId = @intOrderHeaderId
WHERE I.intItemId = (
		CASE 
			WHEN @intItemId > 0
				THEN @intItemId
			ELSE I.intItemId
			END
		)
	AND I.strItemNo LIKE @strItemNo + '%'

