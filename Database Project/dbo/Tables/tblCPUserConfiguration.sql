CREATE TABLE [dbo].[tblCPUserConfiguration]
(
	[intUserConfigId] INT NOT NULL PRIMARY KEY IDENTITY, 
    [intUserSecurityId] INT NOT NULL, 
    [strCustomerNo] NVARCHAR(10) NOT NULL, 
    CONSTRAINT [FK_tblCPUserConfiguration_tblSMUserSecurity] FOREIGN KEY ([intUserSecurityId]) REFERENCES [tblSMUserSecurity]([intUserSecurityID]) 
)
