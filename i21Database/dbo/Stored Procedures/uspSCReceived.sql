﻿CREATE PROCEDURE [dbo].[uspSCReceived]
	@ItemsFromInventoryReceipt ReceiptItemTableType READONLY 
	,@intUserId INT
AS
BEGIN

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS ON

--EXEC dbo.uspCTReceived @ItemsFromInventoryReceipt,@intUserId

END 