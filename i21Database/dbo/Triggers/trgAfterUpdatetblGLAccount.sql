CREATE TRIGGER [dbo].[trgAfterUpdatetblGLAccount] on [dbo].[tblGLAccount]
	   FOR UPDATE
AS 
BEGIN
	
	INSERT INTO tblGLAccountAdjustmentLog(intPrimaryKey,strColumn,strAction,dtmAction,strOriginalValue,strNewValue,intEntityId,strTable,strName)
	SELECT 
		d.intAccountId
		,'Account Category'
		,'Move'
		,getdate()
		,CAST(d.intAccountCategoryId as nvarchar(10)) 
		,CAST(i.intAccountCategoryId AS nvarchar(10))
		,i.[intEntityIdLastModified],'Account',d.strAccountId
	FROM deleted d 
	JOIN inserted i ON i.intAccountId = d.intAccountId
	WHERE i.intAccountCategoryId != d.intAccountCategoryId
	
	INSERT INTO tblGLAccountAdjustmentLog(intPrimaryKey,strColumn,strAction,dtmAction,strOriginalValue,strNewValue,intEntityId,strTable,strName)
	SELECT 
		d.intAccountId
		,'Account Group'
		,'Move'
		,getdate()
		,CAST(d.intAccountGroupId as nvarchar(10)) 
		,CAST(i.intAccountGroupId AS nvarchar(10))
		,i.[intEntityIdLastModified],'Account',d.strAccountId
	FROM deleted d 
	JOIN inserted i ON i.intAccountId = d.intAccountId
	WHERE i.intAccountGroupId != d.intAccountGroupId
	
	INSERT INTO tblGLAccountAdjustmentLog (intPrimaryKey,strColumn,strAction,dtmAction,strOriginalValue,strNewValue,intEntityId,strTable,strName)
	SELECT 
		d.intAccountId
		,'Account ID'
		,'Rename'
		,getdate()
		,d.strAccountId
		,i.strAccountId
		,i.[intEntityIdLastModified],'Account',d.strAccountId
	FROM deleted d 
	JOIN inserted i ON i.intAccountId = d.intAccountId
	WHERE i.strAccountId != d.strAccountId

END
