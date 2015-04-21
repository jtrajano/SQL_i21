CREATE TRIGGER [dbo].[trgAfterUpdatetblGLAccountGroup] on [dbo].[tblGLAccountGroup]
   FOR UPDATE
AS 
BEGIN
	SET NOCOUNT ON;
	INSERT INTO tblGLAccountAdjustmentLog (intPrimaryKey,strColumn,strAction,dtmAction,strOriginalValue,strNewValue,intEntityId,strTable,strName)
	SELECT	d.intAccountGroupId
			,'strAccountGroup'
			,'Rename'
			,getdate()
			,d.strAccountGroup 
			,i.strAccountGroup
			,i.[intEntityIdLastModified],'tblGLAccountGroup',d.strAccountGroup
	FROM deleted d 
	JOIN inserted i ON i.intAccountGroupId = d.intAccountGroupId
	WHERE i.strAccountGroup != d.strAccountGroup

	INSERT INTO tblGLAccountAdjustmentLog (intPrimaryKey,strColumn,strAction,dtmAction,strOriginalValue,strNewValue,intEntityId,strTable,strName)
	SELECT	d.intAccountGroupId
			,'intParentGroupId'
			,'Move'
			,getdate()
			,d.intParentGroupId
			,i.intParentGroupId
			,i.[intEntityIdLastModified],'tblGLAccountGroup',d.strAccountGroup
	FROM deleted d 
	JOIN inserted i ON i.intAccountGroupId = d.intAccountGroupId
	WHERE i.intParentGroupId != d.intParentGroupId


END
