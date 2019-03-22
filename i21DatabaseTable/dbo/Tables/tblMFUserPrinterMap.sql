CREATE TABLE [dbo].[tblMFUserPrinterMap]
(
	[intUserPrinterMapId] INT NOT NULL IDENTITY(1,1),
	[intEntityUserSecurityId] INT NOT NULL,
	[strLabelPrinterName] NVARCHAR(512)  COLLATE Latin1_General_CI_AS NULL, 
    [intConcurrencyId] INT NULL, 

    CONSTRAINT [FK_tblMFUserPrinterMap_tblSMUserSecurity_intEntityUserSecurityId] FOREIGN KEY ([intEntityUserSecurityId]) REFERENCES [tblSMUserSecurity]([intEntityId]), 
    CONSTRAINT [PK_tblMFUserPrinterMap] PRIMARY KEY ([intUserPrinterMapId]), 
)

