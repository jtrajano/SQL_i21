PRINT N'*** BEGIN - UPDATE ISSUE STOCK NO. IN PATRONAGE ***'
GO
	IF EXISTS (SELECT 1 FROM [dbo].[tblPATCustomerStock] WHERE [strIssueNo] IS NULL OR [strIssueNo] = '')
	BEGIN
		DECLARE @strIssueNo NVARCHAR(40) = NULL;
		DECLARE @intCustomerStockId INT = NULL;
		WHILE EXISTS(SELECT 1 FROM [dbo].[tblPATCustomerStock] WHERE [strIssueNo] IS NULL OR [strIssueNo] = '')
		BEGIN
			SELECT TOP 1 @intCustomerStockId = intCustomerStockId FROM [dbo].[tblPATCustomerStock] WHERE [strIssueNo] IS NULL OR [strIssueNo] = '';
			EXEC [dbo].[uspSMGetStartingNumber] 126, @strIssueNo out;

			UPDATE [dbo].[tblPATCustomerStock] SET strIssueNo = @strIssueNo 
			WHERE intCustomerStockId = @intCustomerStockId; 
			SET @strIssueNo = NULL; SET @intCustomerStockId = NULL;
		END
	END
	
GO
PRINT N'*** END - UPDATE ISSUE STOCK NO. IN PATRONAGE ***'