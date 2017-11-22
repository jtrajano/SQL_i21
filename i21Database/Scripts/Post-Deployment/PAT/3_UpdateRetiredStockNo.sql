PRINT N'*** BEGIN - UPDATE RETIRE STOCK NO. IN PATRONAGE ***'
GO
	IF EXISTS (SELECT 1 FROM [dbo].[tblPATCustomerStock] WHERE [strActivityStatus] = 'Retired' AND ([strRetireNo] IS NULL OR [strRetireNo] = ''))
	BEGIN
		DECLARE @strRetireNo NVARCHAR(40) = NULL;
		DECLARE @intCustomerStockId INT = NULL;
		WHILE EXISTS(SELECT 1 FROM [dbo].[tblPATCustomerStock] WHERE [strActivityStatus] = 'Retired' AND ([strRetireNo] IS NULL OR [strRetireNo] = ''))
		BEGIN
			SELECT TOP 1 @intCustomerStockId = intCustomerStockId FROM [dbo].[tblPATCustomerStock] 
			WHERE [strActivityStatus] = 'Retired' AND ([strRetireNo] IS NULL OR [strRetireNo] = '')
			
			EXEC [dbo].[uspSMGetStartingNumber] 127, @strRetireNo out;

			UPDATE [dbo].[tblPATCustomerStock] SET [strRetireNo] = @strRetireNo 
			WHERE intCustomerStockId = @intCustomerStockId; 
			SET @strRetireNo = NULL; SET @intCustomerStockId = NULL;
		END
	END
	
GO
PRINT N'*** END - UPDATE RETIRE STOCK NO. IN PATRONAGE ***'