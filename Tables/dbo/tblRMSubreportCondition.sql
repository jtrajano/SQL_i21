CREATE TABLE [dbo].[tblRMSubreportCondition] (
    [intSubreportConditionId] INT            IDENTITY (1, 1) NOT NULL,
    [intSubreportSettingId]   INT            NULL,
    [strBeginGroup]           NVARCHAR (MAX) COLLATE Latin1_General_CI_AS NULL,
    [strEndGroup]             NVARCHAR (MAX) COLLATE Latin1_General_CI_AS NULL,
    [strJoin]                 NVARCHAR (MAX) COLLATE Latin1_General_CI_AS NULL,
    [strFieldName]            NVARCHAR (MAX) COLLATE Latin1_General_CI_AS NULL,
    [strFrom]                 NVARCHAR (MAX) COLLATE Latin1_General_CI_AS NULL,
    [strTo]                   NVARCHAR (MAX) COLLATE Latin1_General_CI_AS NULL,
    [strCondition]            NVARCHAR (MAX) COLLATE Latin1_General_CI_AS NULL,
    [strDataType]             NVARCHAR (MAX) COLLATE Latin1_General_CI_AS NULL,
    [intConcurrencyId]        INT            CONSTRAINT [DF_tblRMSubreportCondition_intConcurrencyId] DEFAULT ((1)) NOT NULL,
    CONSTRAINT [PK_tblRMSubreportCondition] PRIMARY KEY CLUSTERED ([intSubreportConditionId] ASC),
    CONSTRAINT [FK_tblRMSubreportCondition_tblRMSubreportSetting] FOREIGN KEY ([intSubreportSettingId]) REFERENCES [dbo].[tblRMSubreportSetting] ([intSubreportSettingId]) ON DELETE CASCADE
);

