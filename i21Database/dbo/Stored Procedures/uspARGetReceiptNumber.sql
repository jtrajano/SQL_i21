
CREATE PROCEDURE uspARGetReceiptNumber
	@strReceiptNumber NVARCHAR(25) = NULL OUTPUT
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

DECLARE @intStartingNumberId INT = 0

SELECT TOP 1 @intStartingNumberId = intStartingNumberId 
	FROM tblSMStartingNumber 
	WHERE strTransactionType = 'Sales Receipt'

IF(@intStartingNumberId <> 0)
	EXEC uspSMGetStartingNumber @intStartingNumberId, @strReceiptNumber OUT