CREATE PROCEDURE [dbo].[uspICGetStatusUnitCost]
	@intReceiptId INT,
	@intReceiptItemsStatusId INT OUTPUT
AS
SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

DECLARE @TotalCost AS NUMERIC(38,20),
		@Status_AllZeroCost AS INT = 1,
		@Status_SomeHaveZeroCost AS INT = 2,
		@Status_NoZeroCost AS INT = 3

BEGIN
	IF EXISTS (SELECT * FROM tblICInventoryReceiptItem WHERE intInventoryReceiptId = @intReceiptId) 
	BEGIN
		SELECT @TotalCost = SUM(dblUnitCost) FROM tblICInventoryReceiptItem WHERE intInventoryReceiptId = @intReceiptId
			IF @TotalCost = 0
				BEGIN
					SET @intReceiptItemsStatusId = @Status_AllZeroCost
				END
			ELSE
				IF EXISTS(SELECT * FROM tblICInventoryReceiptItem WHERE intInventoryReceiptId = @intReceiptId AND dblUnitCost = 0)
					BEGIN
						SET @intReceiptItemsStatusId = @Status_SomeHaveZeroCost
					END
				ELSE
					BEGIN
						SET @intReceiptItemsStatusId = @Status_NoZeroCost
					END
	END
	ELSE
	BEGIN 
		EXEC uspICRaiseError 80164; 
	END 
END