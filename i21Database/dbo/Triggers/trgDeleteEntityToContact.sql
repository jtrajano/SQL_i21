CREATE TRIGGER [trgDeleteEntityToContact]
	 ON [dbo].[tblEMEntityToContact] 
FOR DELETE
AS
	DELETE FROM tblEMEntity WHERE intEntityId IN (SELECT intEntityContactId FROM deleted)