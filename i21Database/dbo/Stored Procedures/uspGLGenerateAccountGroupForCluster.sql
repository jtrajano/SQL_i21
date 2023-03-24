CREATE PROCEDURE uspGLGenerateAccountGroupForCluster
@intAccountGroupClusterId INT
AS
IF NOT EXISTS(SELECT 1 FROM tblGLAccountGroup WHERE intAccountGroupClusterId = @intAccountGroupClusterId)
BEGIN
    INSERT [dbo].[tblGLAccountGroup] ([strAccountGroup], [strAccountType], [intParentGroupId], [intGroup], [intSort], [intConcurrencyId], [intAccountBegin], [intAccountEnd], [strAccountGroupNamespace], intAccountGroupClusterId) 
    SELECT N'Asset', N'Asset', 0, 1, 100000, 1, 0, 0, N'System',@intAccountGroupClusterId UNION
    SELECT N'Liability', N'Liability', 0, 1, 200000, 1, 0, 0, N'System',@intAccountGroupClusterId UNION
    SELECT N'Equity', N'Equity', 0, 1, 300000, 1, 0, 0, N'System',@intAccountGroupClusterId UNION
    SELECT N'Revenue', N'Revenue', 0, 1, 400000, 1, 0, 0, N'System',@intAccountGroupClusterId UNION
    SELECT N'Expense', N'Expense', 0, 1, 500000, 1, 0, 0, N'System',@intAccountGroupClusterId
END