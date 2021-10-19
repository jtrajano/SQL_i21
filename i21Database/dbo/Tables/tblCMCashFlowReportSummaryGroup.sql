CREATE TABLE [dbo].[tblCMCashFlowReportSummaryGroup]
(
    [intCashFlowReportSummaryGroupId]   INT IDENTITY(1,1) NOT NULL,
    [strCashFlowReportSummaryGroup]     NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL,
    [intGroupSort]                      INT NULL,
    [intConcurrencyId]                  INT NOT NULL DEFAULT(1),

    CONSTRAINT [PK_tblCMCashFlowReportSummaryGroup] PRIMARY KEY CLUSTERED ([intCashFlowReportSummaryGroupId] ASC)
)
