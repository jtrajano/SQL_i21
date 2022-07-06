CREATE PROCEDURE uspMFGetSONo (
	@strPickListNo NVARCHAR(50)
	,@intLocationId INT
	)
AS
SELECT DISTINCT S.intSalesOrderId
	,S.strSalesOrderNumber
FROM dbo.tblSOSalesOrder S
JOIN dbo.tblSOSalesOrderDetail SD ON SD.intSalesOrderId = S.intSalesOrderId
JOIN dbo.tblMFPickList P ON P.strWorkOrderNo = S.strSalesOrderNumber
JOIN dbo.tblMFPickListDetail PD ON PD.intPickListId = P.intPickListId
WHERE P.strPickListNo = @strPickListNo
	AND S.intCompanyLocationId = @intLocationId
