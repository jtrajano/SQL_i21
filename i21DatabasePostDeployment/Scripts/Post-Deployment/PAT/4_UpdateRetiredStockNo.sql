PRINT N'*** BEGIN - UPDATE RETIRE STOCK NO. IN PATRONAGE ***'
GO
	IF EXISTS (SELECT 1 FROM [dbo].[tblPATRetireStock] WHERE ([strRetireNo] IS NULL OR [strRetireNo] = ''))
	BEGIN
		DECLARE @strRetireNo NVARCHAR(40) = NULL;
		DECLARE @intRetireStockId INT = NULL;
		WHILE EXISTS(SELECT 1 FROM [dbo].[tblPATRetireStock] WHERE [strRetireNo] IS NULL OR [strRetireNo] = '')
		BEGIN
			SELECT TOP 1 @intRetireStockId = intRetireStockId FROM [dbo].[tblPATRetireStock] WHERE [strRetireNo] IS NULL OR [strRetireNo] = ''
			EXEC [dbo].[uspSMGetStartingNumber] 127, @strRetireNo out;

			UPDATE [dbo].[tblPATRetireStock] SET [strRetireNo] = @strRetireNo 
			WHERE intRetireStockId = @intRetireStockId; 
			SET @strRetireNo = NULL; SET @intRetireStockId = NULL;
		END
	END
	
GO
PRINT N'*** END - UPDATE RETIRE STOCK NO. IN PATRONAGE ***'