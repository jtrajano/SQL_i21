CREATE TABLE [dbo].[tblSMEmailRecipient]
(
	[intEmailRecipientId] INT NOT NULL PRIMARY KEY IDENTITY, 
    [intEmailId] INT NOT NULL, 
    [intEntityId] INT NOT NULL, 
    [strEmailAddress] NVARCHAR(150) COLLATE Latin1_General_CI_AS NOT NULL, 
    [strRecipientType] NVARCHAR(5) COLLATE Latin1_General_CI_AS NOT NULL, 
	[intConcurrencyId] INT NOT NULL DEFAULT 1
)
