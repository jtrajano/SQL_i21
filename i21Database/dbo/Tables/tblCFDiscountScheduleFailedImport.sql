CREATE TABLE [dbo].[tblCFDiscountScheduleFailedImport] (
    [intDiscountScheduleFailedImportId] INT            IDENTITY (1, 1) NOT NULL,
    [strDiscountScheduleId]             NVARCHAR (MAX) COLLATE Latin1_General_CI_AS NOT NULL,
    [strReason]                         NVARCHAR (MAX) COLLATE Latin1_General_CI_AS NULL,
    CONSTRAINT [PK_tblCFDiscountScheduleFailedImport] PRIMARY KEY CLUSTERED ([intDiscountScheduleFailedImportId] ASC)
);

