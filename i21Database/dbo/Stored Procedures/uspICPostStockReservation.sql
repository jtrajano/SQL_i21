CREATE PROCEDURE [dbo].[uspICPostStockReservation]
	@intTransactionId AS INT
	,@intTransactionTypeId AS INT
	,@ysnPosted AS BIT
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

UPDATE	dbo.tblICStockReservation
SET		ysnPosted = @ysnPosted
WHERE	intTransactionId = @intTransactionId
		AND intInventoryTransactionType = @intTransactionTypeId