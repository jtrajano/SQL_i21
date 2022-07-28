CREATE TABLE [dbo].[tblRKPaymentCondition]
(
	[intPaymentConditionId] INT IDENTITY(1,1) NOT NULL,
    [intCreditLineId] INT NOT NULL,
    [intTermID] INT NOT NULL,
    [strTerm] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
    [dblRemainingRisk] NUMERIC(18, 6) NULL, 
    [strRemarks] NVARCHAR(MAX) NULL,
    [intConcurrencyId] INT NOT NULL DEFAULT 1,
    CONSTRAINT [PK_tblRKPaymentCondition_intPaymentConditionId] PRIMARY KEY ([intPaymentConditionId]),
	CONSTRAINT [FK_tblRKPaymentCondition_tblRKCreditLine_intCreditLineId] FOREIGN KEY (intCreditLineId) REFERENCES tblRKCreditLine([intCreditLineId]),
    CONSTRAINT [FK_tblRKAcceptableCurrency_tblSMTerm_intTermID] FOREIGN KEY (intTermID) REFERENCES tblSMTerm([intTermID])
)
