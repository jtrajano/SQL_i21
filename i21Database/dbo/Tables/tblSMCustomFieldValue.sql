CREATE TABLE [dbo].[tblSMCustomFieldValue] (
    [intCustomFieldValueId]  INT          IDENTITY (1, 1) NOT NULL,
    [intCustomFieldDetailId] INT          NULL,
    [strValue]               NVARCHAR (1) COLLATE Latin1_General_CI_AS NULL,
    [intSort]                INT          NULL,
    [intConcurrencyId]       INT          NOT NULL,
    CONSTRAINT [PK_tblSMCustomFieldValue] PRIMARY KEY CLUSTERED ([intCustomFieldValueId] ASC),
    CONSTRAINT [FK_tblSMCustomFieldValue_tblSMCustomFieldDetail] FOREIGN KEY ([intCustomFieldDetailId]) REFERENCES [dbo].[tblSMCustomFieldDetail] ([intCustomFieldDetailId]) ON DELETE CASCADE
);

