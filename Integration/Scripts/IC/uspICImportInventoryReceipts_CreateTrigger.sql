IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[trgReceiptNumber]') AND [type] = N'TR')
	DROP TRIGGER trgReceiptNumber;
GO 

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[uspICImportInventoryReceipts_CreateTrigger]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [uspICImportInventoryReceipts_CreateTrigger]; 
GO 

CREATE PROCEDURE uspICImportInventoryReceipts_CreateTrigger 
AS 

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[trgReceiptNumber]') AND [type] = N'TR')
	DROP TRIGGER trgReceiptNumber;

EXEC ('
	CREATE TRIGGER [trgReceiptNumber] ON [tblICInventoryReceipt]
	FOR INSERT
	AS

	DECLARE @inserted TABLE(intInventoryReceiptId INT)
	DECLARE @count INT = 0
	DECLARE @intInventoryReceiptId INT
	DECLARE @ReceiptNumber NVARCHAR(50)
	DECLARE @intMaxCount INT = 0
	DECLARE @intStartingNumberId INT = 0
	DECLARE @intLocationId INT 

	INSERT INTO @inserted
	SELECT intInventoryReceiptId FROM INSERTED ORDER BY intInventoryReceiptId
	WHILE((SELECT TOP 1 1 FROM @inserted) IS NOT NULL)
	BEGIN
		SET @intStartingNumberId = 23	
		SELECT TOP 1 @intInventoryReceiptId = intInventoryReceiptId, @intLocationId = intLocationId  FROM @inserted
		SELECT TOP 1 @intStartingNumberId = intStartingNumberId 
		FROM tblSMStartingNumber 
		WHERE strTransactionType = ''Inventory Receipt''
		
		EXEC uspSMGetStartingNumber @intStartingNumberId, @ReceiptNumber OUT, @intLocationId
	
		IF(@ReceiptNumber IS NOT NULL)
		BEGIN
			IF EXISTS (SELECT TOP 1 1 FROM tblICInventoryReceipt WHERE strReceiptNumber = @ReceiptNumber)
			BEGIN
				SET @ReceiptNumber = NULL
				DECLARE @intStartIndex INT = 4
									
				SELECT	@intMaxCount = MAX(CONVERT(INT, SUBSTRING(strReceiptNumber, @intStartIndex, 10))) 
				FROM	tblICInventoryReceipt 
				WHERE	strReceiptType <> ''Inventory Return''

				UPDATE	tblSMStartingNumber 
				SET		intNumber = @intMaxCount + 1 
				WHERE	intStartingNumberId = @intStartingNumberId

				EXEC uspSMGetStartingNumber @intStartingNumberId, @ReceiptNumber OUT, @intLocationId				
			END

			UPDATE	tblICInventoryReceipt
			SET		tblICInventoryReceipt.strReceiptNumber = @ReceiptNumber
			FROM	tblICInventoryReceipt A
			WHERE	A.intInventoryReceiptId = @intInventoryReceiptId
		END
		DELETE FROM @inserted
		WHERE intInventoryReceiptId = @intInventoryReceiptId
	END
')