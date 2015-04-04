CREATE TRIGGER [dbo].[trgAfterDeletetblGLAccountGroup] on [dbo].[tblGLAccountGroup]
   FOR DELETE
AS 
BEGIN
	SET NOCOUNT ON;
	INSERT INTO tblGLAccountAdjustmentLog (intPrimaryKey,strColumn,strAction,dtmAction,strOriginalValue,strNewValue,intEntityId,strTable)
	SELECT	d.intAccountGroupId
			,'Account Group'
			,'Delete'
			,getdate()
			,d.strAccountGroup 
			,'Deleted'
			,d.intEntityIdLastModified,'Account Group'
	FROM deleted d 
END
