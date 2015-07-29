CREATE TABLE [dbo].[tblCFDiscountScheduleSuccessImport] (
    [intDiscountScheduleSuccessImportId] INT            IDENTITY (1, 1) NOT NULL,
    [strDiscountScheduleId]              NVARCHAR (MAX) COLLATE Latin1_General_CI_AS NULL,
    CONSTRAINT [PK_tblCFDiscountScheduleSuccessImport] PRIMARY KEY CLUSTERED ([intDiscountScheduleSuccessImportId] ASC)
);

