CREATE TABLE [dbo].[tblSMCustomField] (
    [intCustomFieldId] INT            IDENTITY (1, 1) NOT NULL,
    [strScreen]        NVARCHAR (50)  COLLATE Latin1_General_CI_AS NOT NULL,
    [strModule]        NVARCHAR (50)  COLLATE Latin1_General_CI_AS NOT NULL,
    [strLayout]        NVARCHAR (50)  COLLATE Latin1_General_CI_AS NOT NULL,
    [strTabName]       NVARCHAR (50)  COLLATE Latin1_General_CI_AS NOT NULL,
    [strDescription]   NVARCHAR (MAX) COLLATE Latin1_General_CI_AS NULL,
    [ysnBuild]         BIT            NOT NULL,
    [intConcurrencyId] INT            NOT NULL,
    CONSTRAINT [PK_tblSMCustomField] PRIMARY KEY CLUSTERED ([intCustomFieldId] ASC)
);



