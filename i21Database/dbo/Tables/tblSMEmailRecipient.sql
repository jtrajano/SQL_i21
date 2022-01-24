CREATE TABLE [dbo].[tblSMEmailRecipient]
(
	[intEmailRecipientId] INT NOT NULL PRIMARY KEY IDENTITY, 
    [intEmailId] INT NOT NULL, 
    [intEntityContactId] INT NULL, 
    [strEmailAddress] NVARCHAR(150) COLLATE Latin1_General_CI_AS NOT NULL, 
    [strRecipientType] NVARCHAR(5) COLLATE Latin1_General_CI_AS NOT NULL, 
	[intConcurrencyId] INT NOT NULL DEFAULT 1	
)

GO

IF NOT EXISTS(SELECT top 1 1 FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS WHERE CONSTRAINT_NAME = 'FK_tblSMEmailRecipien_tblSMActivity')
BEGIN
ALTER TABLE [tblSMEmailRecipient]	WITH NOCHECK ADD CONSTRAINT [FK_tblSMEmailRecipien_tblSMActivity] FOREIGN KEY ([intEmailId]) REFERENCES [tblSMActivity]([intActivityId]) ON DELETE CASCADE
END

GO
