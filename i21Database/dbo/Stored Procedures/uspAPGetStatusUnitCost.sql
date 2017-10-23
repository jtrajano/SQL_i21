CREATE PROCEDURE [dbo].[uspAPGetStatusUnitCost]
	@intRecordId INT,
	@strRecordType VARCHAR(20),
	@intRecordItemsStatusId INT OUTPUT
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
	IF @strRecordType = 'Receipt'
		BEGIN
			IF EXISTS (SELECT * FROM tblICInventoryReceiptItem WHERE intInventoryReceiptId = @intRecordId) 
				BEGIN
					SELECT @TotalCost = SUM(dblUnitCost) FROM tblICInventoryReceiptItem WHERE intInventoryReceiptId = @intRecordId
						IF @TotalCost = 0
							BEGIN
								SET @intRecordItemsStatusId = @Status_AllZeroCost
							END
						ELSE
							IF EXISTS(SELECT * FROM tblICInventoryReceiptItem WHERE intInventoryReceiptId = @intRecordId AND dblUnitCost = 0)
								BEGIN
									SET @intRecordItemsStatusId = @Status_SomeHaveZeroCost
								END
							ELSE
								BEGIN
									SET @intRecordItemsStatusId = @Status_NoZeroCost
								END
				END
			ELSE
				BEGIN 
					EXEC uspICRaiseError 80164; 
				END 
		END	
	IF @strRecordType = 'Shipment'
		BEGIN
			IF EXISTS (SELECT * FROM tblICInventoryShipmentItem WHERE intInventoryShipmentId = @intRecordId) 
				BEGIN
					SELECT @TotalCost = SUM(dblUnitPrice) FROM tblICInventoryShipmentItem WHERE intInventoryShipmentId = @intRecordId
						IF @TotalCost = 0
							BEGIN
								SET @intRecordItemsStatusId = @Status_AllZeroCost
							END
						ELSE
							IF EXISTS(SELECT * FROM tblICInventoryShipmentItem WHERE intInventoryShipmentId = @intRecordId AND dblUnitPrice = 0)
								BEGIN
									SET @intRecordItemsStatusId = @Status_SomeHaveZeroCost
								END
							ELSE
								BEGIN
									SET @intRecordItemsStatusId = @Status_NoZeroCost
								END
				END
			ELSE
				BEGIN 
					EXEC uspICRaiseError 80164; 
				END 
		END	
END
