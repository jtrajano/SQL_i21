CREATE PROCEDURE uspMFGetLoadNo (
	@intItemId INT
	,@strLoadNumber NVARCHAR(50) = '%'
	,@intLoadId INT = 0
	)
AS
BEGIN
	SELECT DISTINCT L.intLoadId
		,L.strLoadNumber
	FROM tblLGLoad L
	JOIN tblLGLoadDetail LD ON LD.intLoadId = L.intLoadId
		AND L.intPurchaseSale = 2 -- Outbound
		AND L.intShipmentStatus IN (
			1
			,7
			) -- Scheduled / Instruction created
		AND LD.intItemId = @intItemId
		AND L.strLoadNumber LIKE '%' + @strLoadNumber + '%'
		AND L.intLoadId = (
			CASE 
				WHEN @intLoadId > 0
					THEN @intLoadId
				ELSE L.intLoadId
				END
			)
	ORDER BY L.intLoadId
END
