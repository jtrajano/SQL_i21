CREATE TABLE [dbo].[tblTFTaxAuthorityConfiguration] (
    [intTaxAuthorityConfigurationId] INT            IDENTITY (1, 1) NOT NULL,
    [intTaxAuthorityId]              INT            NOT NULL,
    [strConfigurationName]           NVARCHAR (250) COLLATE Latin1_General_CI_AS NOT NULL,
    [intConfigurationTypeId]         INT            NOT NULL,
    [strValue]                       NVARCHAR (MAX) COLLATE Latin1_General_CI_AS NOT NULL,
    [intConcurrencyId]               INT            CONSTRAINT [DF_tblTFTaxAuthorityConfiguration_intConcurrencyId] DEFAULT ((1)) NULL,
    CONSTRAINT [PK_tblTFTaxAuthorityConfiguration] PRIMARY KEY CLUSTERED ([intTaxAuthorityConfigurationId] ASC),
    CONSTRAINT [FK_tblTFTaxAuthorityConfiguration_tblTFConfigurationType] FOREIGN KEY ([intConfigurationTypeId]) REFERENCES [dbo].[tblTFConfigurationType] ([intConfigurationTypeId]),
    CONSTRAINT [FK_tblTFTaxAuthorityConfiguration_tblTFTaxAuthority] FOREIGN KEY ([intTaxAuthorityId]) REFERENCES [dbo].[tblTFTaxAuthority] ([intTaxAuthorityId]) ON DELETE CASCADE
);

