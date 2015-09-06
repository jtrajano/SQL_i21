GO
	PRINT N'REMOVE DUPLICATE COGS AND SALES ACCOUNT GROUP'
	DECLARE @intAccountGroupId int
	DECLARE @intAccountGroupId1 int
	IF (SELECT COUNT( 1) FROM tblGLAccountGroup WHERE strAccountGroup = 'Cost of Goods Sold') = 2
	BEGIN
		SELECT @intAccountGroupId = intAccountGroupId FROM tblGLAccountGroup WHERE intParentGroupId = 0 and  strAccountGroup = 'Cost of Goods Sold'
		SELECT @intAccountGroupId1 = intAccountGroupId FROM tblGLAccountGroup WHERE intParentGroupId > 0 and strAccountGroup = 'Cost of Goods Sold'
		IF @intAccountGroupId1 IS NOT NULL AND @intAccountGroupId IS NOT NULL
		BEGIN
			UPDATE tblGLAccount SET intAccountGroupId = @intAccountGroupId1 WHERE intAccountGroupId = @intAccountGroupId
			UPDATE tblGLAccountSegment SET intAccountGroupId = @intAccountGroupId1 WHERE intAccountGroupId = @intAccountGroupId
			UPDATE tblGLCOAAdjustmentDetail SET intAccountGroupId = @intAccountGroupId1 WHERE intAccountGroupId = @intAccountGroupId
			UPDATE tblGLAccountGroup SET intParentGroupId = (SELECT top 1 intAccountGroupId from tblGLAccountGroup WHERE strAccountGroup in ('Expense','Expenses') and intParentGroupId = 0)
			WHERE intAccountGroupId = @intAccountGroupId1 
			DELETE from tblGLAccountGroup where intAccountGroupId = @intAccountGroupId
		END
	END
	IF (SELECT COUNT( 1) FROM tblGLAccountGroup WHERE strAccountGroup = 'Sales') = 2
	BEGIN
		SELECT @intAccountGroupId = intAccountGroupId FROM tblGLAccountGroup WHERE intParentGroupId = 0 and strAccountGroup = 'Sales'
		SELECT @intAccountGroupId1 = intAccountGroupId FROM tblGLAccountGroup WHERE intParentGroupId > 0 and strAccountGroup = 'Sales'
		IF @intAccountGroupId1 IS NOT NULL AND @intAccountGroupId IS NOT NULL
		BEGIN
			UPDATE tblGLAccount SET intAccountGroupId = @intAccountGroupId1 WHERE intAccountGroupId = @intAccountGroupId
			UPDATE tblGLAccountSegment SET intAccountGroupId = @intAccountGroupId1 WHERE intAccountGroupId = @intAccountGroupId
			UPDATE tblGLCOAAdjustmentDetail SET intAccountGroupId = @intAccountGroupId1 WHERE intAccountGroupId = @intAccountGroupId
			UPDATE tblGLAccountGroup SET intParentGroupId = (SELECT top 1 intAccountGroupId from tblGLAccountGroup WHERE strAccountGroup in ('Revenue') and intParentGroupId = 0)
			WHERE intAccountGroupId = @intAccountGroupId1 
			DELETE from tblGLAccountGroup WHERE intAccountGroupId = @intAccountGroupId
		END
	END
GO