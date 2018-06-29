CREATE PROCEDURE uspMFGetActualItemByLot (
	@strLotNumber NVARCHAR(50)
	,@strItemNo NVARCHAR(50) = ''
	,@intActualItemId INT = 0
	)
AS
BEGIN
	DECLARE @intWorkOrderId INT

	SELECT @intWorkOrderId = intWorkOrderId
	FROM tblMFWorkOrderProducedLot WP
	WHERE intLotId IN (
			SELECT intLotId
			FROM tblICLot
			WHERE strLotNumber = @strLotNumber
			)

	SELECT I.intItemId
		,I.strItemNo
		,I.strDescription
	FROM dbo.tblMFWorkOrderRecipeItem RI
	LEFT JOIN dbo.tblMFWorkOrderRecipeSubstituteItem SI ON SI.intRecipeItemId = RI.intRecipeItemId
		AND SI.intWorkOrderId = RI.intWorkOrderId
	JOIN dbo.tblICItem I ON (
			I.intItemId = RI.intItemId
			OR I.intItemId = SI.intSubstituteItemId
			)
	WHERE RI.intRecipeItemTypeId = 2
		AND RI.intWorkOrderId = @intWorkOrderId
		AND (
			I.strItemNo LIKE '%' + @strItemNo + '%'
			OR I.strDescription LIKE '%' + @strItemNo + '%'
			)
		AND I.intItemId = (
			CASE 
				WHEN @intActualItemId > 0
					THEN @intActualItemId
				ELSE I.intItemId
				END
			)
	ORDER BY I.strItemNo
END
