CREATE TRIGGER [dbo].[trgAfterUpdatetblGLAccountSegment] ON [dbo].[tblGLAccountSegment] 
FOR UPDATE
AS
	INSERT INTO tblGLAccountAdjustmentLog (intPrimaryKey,strColumn,strAction,dtmAction,strOriginalValue,strNewValue,intEntityId,strTable,strName)
	SELECT 
		d.intAccountSegmentId
		,'intAccountCategoryId'
		,'Move'
		,getdate()
		,CAST(d.intAccountCategoryId as nvarchar(10)) 
		,CAST(i.intAccountCategoryId AS nvarchar(10))
		,i.intEntityIdLastModified,'tblGLAccountSegment',d.strCode
	FROM deleted d 
	JOIN inserted i ON i.intAccountSegmentId = d.intAccountSegmentId
	WHERE  i.intAccountCategoryId != d.intAccountCategoryId
	