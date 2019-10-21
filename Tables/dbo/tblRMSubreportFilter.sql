CREATE TABLE [dbo].[tblRMSubreportFilter] (
    [intSubreportFilterId]  INT            IDENTITY (1, 1) NOT NULL,
    [intSubreportSettingId] INT            NULL,
    [intType]               INT            NOT NULL,
    [strParentField]        NVARCHAR (MAX) COLLATE Latin1_General_CI_AS NULL,
    [strParentDataType]     NVARCHAR (MAX) COLLATE Latin1_General_CI_AS NULL,
    [strChildField]         NVARCHAR (MAX) COLLATE Latin1_General_CI_AS NULL,
    [strChildDataType]      NVARCHAR (MAX) COLLATE Latin1_General_CI_AS NULL,
    [intConcurrencyId]      INT            CONSTRAINT [DF_tblRMSubreportFilter_intConcurrencyId] DEFAULT ((1)) NOT NULL,
    CONSTRAINT [PK_tblRMSubreportFilter] PRIMARY KEY CLUSTERED ([intSubreportFilterId] ASC),
    CONSTRAINT [FK_tblRMSubreportFilter_tblRMSubreportSetting] FOREIGN KEY ([intSubreportSettingId]) REFERENCES [dbo].[tblRMSubreportSetting] ([intSubreportSettingId]) ON DELETE CASCADE
);

