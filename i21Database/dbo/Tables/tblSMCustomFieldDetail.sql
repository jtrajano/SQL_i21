CREATE TABLE [dbo].[tblSMCustomFieldDetail] (
    [intCustomFieldDetailId] INT           IDENTITY (1, 1) NOT NULL,
    [intCustomFieldId]       INT           NULL,
    [strFieldName]           NVARCHAR (50) COLLATE Latin1_General_CI_AS NULL,
    [strFieldType]           NVARCHAR (50) COLLATE Latin1_General_CI_AS NULL,
    [strFieldSize]           NVARCHAR (50) COLLATE Latin1_General_CI_AS NULL,
    [strControlType]         NVARCHAR (50) COLLATE Latin1_General_CI_AS NULL,
    [strLocation]            NVARCHAR (50) COLLATE Latin1_General_CI_AS NULL,
    [intSort]                INT           NULL,
    [intConcurrencyId]       INT           NOT NULL,
    CONSTRAINT [PK_tblSMCustomFieldDetail] PRIMARY KEY CLUSTERED ([intCustomFieldDetailId] ASC),
    CONSTRAINT [FK_tblSMCustomFieldDetail_tblSMCustomField] FOREIGN KEY ([intCustomFieldId]) REFERENCES [dbo].[tblSMCustomField] ([intCustomFieldId]) ON DELETE CASCADE
);

