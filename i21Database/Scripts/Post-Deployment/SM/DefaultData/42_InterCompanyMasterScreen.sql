GO
	PRINT N'BEGIN INSERT DEFAULT SCREEN FOR INTER-COMPANY MAPPING'
GO
	DECLARE @intScreenId INT

	SELECT @intScreenId = intScreenId FROM tblSMScreen WHERE strNamespace = 'ContractManagement.view.Contract'
	IF ISNULL(@intScreenId, 0) <> 0 AND NOT EXISTS (SELECT TOP 1 1 FROM tblSMInterCompanyMasterScreen WHERE intScreenId = @intScreenId)
	BEGIN
		INSERT [dbo].[tblSMInterCompanyMasterScreen] ([intScreenId]) VALUES (@intScreenId)
	END
GO
	PRINT N'END INSERT DEFAULT SCREEN FOR INTER-COMPANY MAPPING'
GO