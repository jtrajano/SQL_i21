CREATE PROCEDURE [dbo].[uspTRReceived]
	@ItemsFromInventoryReceipt ReceiptItemTableType READONLY 
	,@intUserId INT
AS
BEGIN

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

--EXEC dbo.uspCTReceived @ItemsFromInventoryReceipt,@intUserId

END 