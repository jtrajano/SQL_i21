
CREATE PROCEDURE uspARGetReceiptNumber
	@strReceiptNumber NVARCHAR(25) = NULL OUTPUT
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

DECLARE @intStartingNumberId INT = 0
DECLARE @intStartingNumber INT = 0

SELECT TOP 1 @intStartingNumberId = intStartingNumberId, @intStartingNumber = intNumber  
	FROM tblSMStartingNumber 
	WHERE strTransactionType = 'Sales Receipt'

SELECT @strReceiptNumber = SN.strPrefix + CAST(SN.intNumber AS NVARCHAR) 
FROM tblARPOS POS
INNER JOIN tblSMStartingNumber SN 
ON POS.strReceiptNumber = SN.strPrefix + CAST(SN.intNumber-1 AS NVARCHAR)

IF((@intStartingNumberId <> 0 AND @strReceiptNumber IS NOT NULL) OR @intStartingNumber = 1)
	EXEC uspSMGetStartingNumber @intStartingNumberId, @strReceiptNumber OUT
ELSE 
	SELECT @strReceiptNumber = (SELECT strPrefix + CAST(intNumber-1 AS NVARCHAR) FROM tblSMStartingNumber WHERE strTransactionType = 'Sales Receipt')