CREATE PROCEDURE [dbo].[uspLGPostOtherCharges]
	@intLoadId AS INT
	,@strBatchId AS NVARCHAR(40)
	,@intEntityUserSecurityId AS INT
	,@intTransactionTypeId AS INT
	,@ysnPost AS BIT = 1
AS
/** This SP is just to avoid confusion of the original SP name that
has been reused for both inbound and outbound postings for other charges **/
EXEC dbo.uspLGPostInventoryShipmentOtherCharges 
		@intLoadId
		,@strBatchId
		,@intEntityUserSecurityId
		,@intTransactionTypeId
		,@ysnPost