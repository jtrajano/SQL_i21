CREATE TABLE [dbo].[tblMFUserPrinterMap]
(
	[intEntityUserSecurityId] INT NOT NULL,
	[intCompanyLocationId] INT,
	[strLabelPrinterName] NVARCHAR(512)  COLLATE Latin1_General_CI_AS NULL, 

	CONSTRAINT [FK_tblMFUserPrinterMap_tblSMUserSecurity_intEntityUserSecurityId] FOREIGN KEY ([intEntityUserSecurityId]) REFERENCES [tblSMUserSecurity]([intEntityUserSecurityId]), 
)

