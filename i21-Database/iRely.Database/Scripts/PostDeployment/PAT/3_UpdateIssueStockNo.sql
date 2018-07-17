PRINT N'*** BEGIN - UPDATE ISSUE STOCK NO. IN PATRONAGE ***'
GO
	IF EXISTS (SELECT 1 FROM [dbo].[tblPATIssueStock] WHERE [strIssueNo] IS NULL OR [strIssueNo] = '')
	BEGIN
		DECLARE @strIssueNo NVARCHAR(40) = NULL;
		DECLARE @intIssueStockId INT = NULL;
		WHILE EXISTS(SELECT 1 FROM [dbo].[tblPATIssueStock] WHERE [strIssueNo] IS NULL OR [strIssueNo] = '')
		BEGIN
			SELECT TOP 1 @intIssueStockId = intIssueStockId FROM [dbo].[tblPATIssueStock] WHERE [strIssueNo] IS NULL OR [strIssueNo] = '';
			EXEC [dbo].[uspSMGetStartingNumber] 126, @strIssueNo out;

			UPDATE [dbo].[tblPATIssueStock] SET strIssueNo = @strIssueNo 
			WHERE intIssueStockId = @intIssueStockId; 
			SET @strIssueNo = NULL; SET @intIssueStockId = NULL;
		END
	END
	
GO
PRINT N'*** END - UPDATE ISSUE STOCK NO. IN PATRONAGE ***'