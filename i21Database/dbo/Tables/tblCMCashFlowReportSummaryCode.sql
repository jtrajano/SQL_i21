CREATE TABLE [dbo].[tblCMCashFlowReportSummaryCode]
(
    [intCashFlowReportSummaryCodeId]    INT IDENTITY(1, 1) NOT NULL,
    [strCashFlowReportSummaryCode]      NVARCHAR(20)  COLLATE Latin1_General_CI_AS NOT NULL,
    [strReport]                         NVARCHAR(100) COLLATE Latin1_General_CI_AS NOT NULL,
    [strReportDescription]              NVARCHAR(255) COLLATE Latin1_General_CI_AS NULL,
    [intReportSort]                     INT NOT NULL, 
    [strOperation]                      NVARCHAR(20)  COLLATE Latin1_General_CI_AS NULL,
    [intCashFlowReportSummaryGroupId]   INT NOT NULL,
    [intConcurrencyId]                  INT NOT NULL DEFAULT (1),

    CONSTRAINT [PK_tblCMCashFlowReportSummaryCode] PRIMARY KEY CLUSTERED ([intCashFlowReportSummaryCodeId] ASC),
    CONSTRAINT [FK_tblCMCashFlowReportSummaryCode_tblCMCashFlowReportSummaryGroup] FOREIGN KEY ([intCashFlowReportSummaryGroupId]) REFERENCES [dbo].[tblCMCashFlowReportSummaryGroup]([intCashFlowReportSummaryGroupId])

)
