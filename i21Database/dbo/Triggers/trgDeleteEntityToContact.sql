CREATE TRIGGER [trgDeleteEntityToContact]
	 ON [dbo].[tblEMEntityToContact] 
FOR DELETE
AS
	delete from tblEMEntity where intEntityId in (Select intEntityContactId from deleted)