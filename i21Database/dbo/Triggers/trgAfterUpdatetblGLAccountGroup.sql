CREATE TRIGGER [dbo].[trgAfterUpdatetblGLAccountGroup] on [dbo].[tblGLAccountGroup]
   FOR UPDATE
AS 
BEGIN
	SET NOCOUNT ON;
	INSERT INTO tblGLAccountAdjustmentLog (intPrimaryKey,strColumn,strAction,dtmAction,strOriginalValue,strNewValue,intEntityId,strTable)
	SELECT	d.intAccountGroupId
			,'Account Group'
			,'Rename'
			,getdate()
			,d.strAccountGroup 
			,i.strAccountGroup
			,i.[intEntityIdLastModified],'Account Group'
	FROM deleted d 
	JOIN inserted i ON i.intAccountGroupId = d.intAccountGroupId
	WHERE i.strAccountGroup != d.strAccountGroup

	INSERT INTO tblGLAccountAdjustmentLog (intPrimaryKey,strColumn,strAction,dtmAction,strOriginalValue,strNewValue,intEntityId,strTable)
	SELECT	d.intAccountGroupId
			,'Account Group'
			,'Move'
			,getdate()
			,d.intParentGroupId
			,i.intParentGroupId
			,i.[intEntityIdLastModified],'Parent Group'
	FROM deleted d 
	JOIN inserted i ON i.intAccountGroupId = d.intAccountGroupId
	WHERE i.intParentGroupId != d.intParentGroupId


END
