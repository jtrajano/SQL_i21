CREATE PROCEDURE [dbo].[uspICUpdateBasisAndFutures]
(
	@intTransactionTypeId INT --1.intInventoryReceiptItemId, 2.intInventoryShipmentItemId
	,@dblBasis NUMERIC(38,20) = 0
	,@dblFutures NUMERIC(38,20) = 0
	,@intTransactionId INT	
)
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS ON

BEGIN
	IF @intTransactionTypeId = 1
	BEGIN
		UPDATE tblICInventoryReceiptItem SET dblBasis = @dblBasis, dblFutures = @dblFutures WHERE intInventoryReceiptItemId = @intTransactionId
	END
	ELSE
	BEGIN
		UPDATE tblICInventoryShipmentItem SET dblBasis = @dblBasis, dblFutures = @dblFutures WHERE intInventoryShipmentItemId = @intTransactionId
	END

END