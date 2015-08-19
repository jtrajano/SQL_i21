CREATE TABLE [dbo].[tblTFConfigurationType] (
    [intConfigurationTypeId] INT           IDENTITY (1, 1) NOT NULL,
    [strType]                NVARCHAR (50) COLLATE Latin1_General_CI_AS NOT NULL,
    [intConcurrencyId]       INT           CONSTRAINT [DF_tblTFConfigurationType_intConcurrencyId] DEFAULT ((1)) NULL,
    CONSTRAINT [PK_tblTFConfigurationType] PRIMARY KEY CLUSTERED ([intConfigurationTypeId] ASC)
);

