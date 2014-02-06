CREATE TABLE [dbo].[tblCPUserConfiguration] (
    [intUserConfigId]   INT           IDENTITY (1, 1) NOT NULL,
    [intUserSecurityId] INT           NOT NULL,
    [strCustomerNo]     NVARCHAR (10) COLLATE Latin1_General_CI_AS NOT NULL,
    PRIMARY KEY CLUSTERED ([intUserConfigId] ASC),
    CONSTRAINT [FK_tblCPUserConfiguration_tblSMUserSecurity] FOREIGN KEY ([intUserSecurityId]) REFERENCES [dbo].[tblSMUserSecurity] ([intUserSecurityID])
);

