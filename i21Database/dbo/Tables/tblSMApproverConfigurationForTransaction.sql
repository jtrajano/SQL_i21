CREATE TABLE [dbo].[tblSMApproverConfigurationForTransaction]
(
	[intApprovalForTransactionId]		INT												NOT NULL PRIMARY KEY IDENTITY, 
    [strApproverConfiguration]			NVARCHAR(MAX) COLLATE Latin1_General_CI_AS		NOT NULL,
    [intTransactionId]					INT												NOT NULL, 
    [intConcurrencyId]					INT												NOT NULL DEFAULT 1, 
    CONSTRAINT [FK_tblSMApproverConfigurationForTransaction_tblSMTransaction] FOREIGN KEY ([intTransactionId]) REFERENCES tblSMTransaction([intTransactionId]),
)
