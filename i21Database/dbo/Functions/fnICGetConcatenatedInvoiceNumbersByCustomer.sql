CREATE FUNCTION dbo.fnICGetConcatenatedInvoiceNumbersByCustomer
(
	@intCustomerId INT,
	@intShipmentId INT
)
RETURNS NVARCHAR(MAX) 
AS 
BEGIN

DECLARE @listStr VARCHAR(MAX)
SELECT TOP 100 @listStr = COALESCE(@listStr + ', ' , '') + i.strInvoiceNumber
FROM tblARInvoice i
LEFT JOIN tblARInvoiceDetail d ON d.intInvoiceId = i.intInvoiceId
LEFT JOIN tblICInventoryShipmentItem si ON si.intInventoryShipmentItemId = d.intInventoryShipmentItemId
	AND d.intInventoryShipmentChargeId IS NULL
WHERE i.intEntityCustomerId = @intCustomerId
	AND i.ysnPosted = 1

RETURN @listStr
END