CREATE TABLE [dbo].[tblSMCustomField] (
    [intCustomFieldId] INT            IDENTITY (1, 1) NOT NULL,
    [strScreen]        NVARCHAR (50)  COLLATE Latin1_General_CI_AS NULL,
    [strModule]        NVARCHAR (50)  COLLATE Latin1_General_CI_AS NULL,
    [strLayout]        NVARCHAR (50)  COLLATE Latin1_General_CI_AS NULL,
    [strTabName]       NVARCHAR (50)  COLLATE Latin1_General_CI_AS NULL,
    [strDescription]   NVARCHAR (MAX) COLLATE Latin1_General_CI_AS NULL,
    [intConcurrencyId] INT            NOT NULL,
    CONSTRAINT [PK_tblSMCustomField] PRIMARY KEY CLUSTERED ([intCustomFieldId] ASC)
);

