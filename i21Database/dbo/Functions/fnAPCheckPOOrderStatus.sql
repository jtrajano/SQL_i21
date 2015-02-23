CREATE FUNCTION [dbo].[fnAPCheckPOOrderStatus]
(
	@orderStatus int,
	@poId INT
)
RETURNS BIT
AS
BEGIN

	DECLARE @success AS BIT = 0;

	SET @success = 
	(
		CASE 
			WHEN @orderStatus = 1 AND EXISTS
			(
				SELECT 1 FROM tblICInventoryReceiptItem 
				WHERE intSourceId = @poId
			)
			THEN 0
			WHEN @orderStatus = 7 AND NOT EXISTS
			(
				SELECT 1 FROM tblICInventoryReceiptItem 
				WHERE intSourceId = @poId
			)
			THEN 0
		ELSE 1 END
	)

	RETURN(@success)
END
