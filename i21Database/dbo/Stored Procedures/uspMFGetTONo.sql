CREATE PROCEDURE uspMFGetTONo (
	@strTransferNo NVARCHAR(50)
	,@intLocationId INT
	)
AS
SELECT DISTINCT T.intInventoryTransferId
	,T.strTransferNo
FROM dbo.tblICInventoryTransfer T
JOIN dbo.tblICInventoryTransferDetail TD ON TD.intInventoryTransferId = T.intInventoryTransferId
WHERE T.strTransferNo = @strTransferNo
	AND T.intFromLocationId = @intLocationId
