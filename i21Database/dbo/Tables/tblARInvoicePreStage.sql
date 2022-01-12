CREATE TABLE tblARInvoicePreStage
(
	intInvoicePreStageId				INT IDENTITY(1,1) PRIMARY KEY, 
	intInvoiceId						INT,
	strRowState						NVARCHAR(100) COLLATE Latin1_General_CI_AS,
	intUserId						INT,
	strFeedStatus					NVARCHAR(MAX) COLLATE Latin1_General_CI_AS,
	dtmFeedDate						DATETIME CONSTRAINT DF_tblARInvoicePreStage_dtmFeedDate DEFAULT GETDATE(),
	strMessage						NVARCHAR(MAX) COLLATE Latin1_General_CI_AS
)
CREATE NONCLUSTERED INDEX [IDX_tblARInvoicePreStage_intInvoiceId] 
	ON [dbo].[tblARInvoicePreStage] ([intInvoiceId])
GO
