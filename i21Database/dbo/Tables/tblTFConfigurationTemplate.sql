CREATE TABLE [dbo].[tblTFConfigurationTemplate] (
    [intConfigurationTemplateId] INT            IDENTITY (1, 1) NOT NULL,
    [strConfigurationName]       NVARCHAR (250) COLLATE Latin1_General_CI_AS NOT NULL,
    [intConfigurationTypeId]     INT            NOT NULL,
    [strValue]                   NVARCHAR (MAX) COLLATE Latin1_General_CI_AS NOT NULL,
    [intConcurrencyId]           INT            CONSTRAINT [DF_tblTFTaxAuthorityConfigurationTemplate_intConcurrencyId] DEFAULT ((1)) NULL,
    CONSTRAINT [PK_tblTFTaxAuthorityConfigurationTemplate] PRIMARY KEY CLUSTERED ([intConfigurationTemplateId] ASC),
    CONSTRAINT [FK_tblTFConfigurationTemplate_tblTFConfigurationType] FOREIGN KEY ([intConfigurationTypeId]) REFERENCES [dbo].[tblTFConfigurationType] ([intConfigurationTypeId])
);

