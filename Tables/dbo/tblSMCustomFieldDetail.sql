CREATE TABLE [dbo].[tblSMCustomFieldDetail] (
    [intCustomFieldDetailId] INT           IDENTITY (1, 1) NOT NULL,
    [intCustomFieldId]       INT           NOT NULL,
    [strLabelName]           NVARCHAR (50) COLLATE Latin1_General_CI_AS NOT NULL,
    [strFieldName]           NVARCHAR (50) COLLATE Latin1_General_CI_AS NOT NULL,
    [strFieldType]           NVARCHAR (50) COLLATE Latin1_General_CI_AS NOT NULL,
    [strFieldSize]           NVARCHAR (50) COLLATE Latin1_General_CI_AS NOT NULL,
    [strControlType]         NVARCHAR (50) COLLATE Latin1_General_CI_AS NOT NULL,
    [strLocation]            NVARCHAR (50) COLLATE Latin1_General_CI_AS NOT NULL,
    [ysnBuild]               BIT           NOT NULL,
    [ysnModified]            BIT           NOT NULL,
    [intSort]                INT           NOT NULL,
    [intConcurrencyId]       INT           NOT NULL,
    CONSTRAINT [PK_tblSMCustomFieldDetail] PRIMARY KEY CLUSTERED ([intCustomFieldDetailId] ASC),
    CONSTRAINT [FK_tblSMCustomFieldDetail_tblSMCustomField] FOREIGN KEY ([intCustomFieldId]) REFERENCES [dbo].[tblSMCustomField] ([intCustomFieldId]) ON DELETE CASCADE
);







