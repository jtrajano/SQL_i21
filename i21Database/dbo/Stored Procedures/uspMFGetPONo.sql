CREATE PROCEDURE uspMFGetPONo (
	@strPurchaseOrderNumber NVARCHAR(50)
	,@intLocationId INT
	)
AS
SELECT DISTINCT P.intPurchaseId
	,P.strPurchaseOrderNumber
FROM dbo.tblPOPurchase P
JOIN dbo.tblPOPurchaseDetail PD ON PD.intPurchaseId = P.intPurchaseId
WHERE P.strPurchaseOrderNumber = @strPurchaseOrderNumber
	AND P.intLocationId = @intLocationId
