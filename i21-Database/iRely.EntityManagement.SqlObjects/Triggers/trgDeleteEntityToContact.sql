CREATE TRIGGER [dbo].[trgDeleteEntityToContact]
	 ON [dbo].[tblEMEntityToContact] 
FOR DELETE
AS
IF NOT EXISTS(SELECT TOP 1 1 FROM tblEMEntityToContact WHERE intEntityContactId IN (SELECT intEntityContactId FROM deleted))
BEGIN
	DELETE FROM tblEMEntity WHERE intEntityId IN (SELECT intEntityContactId FROM deleted)
END