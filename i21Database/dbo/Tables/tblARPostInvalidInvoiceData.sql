CREATE TABLE tblARPostInvalidInvoiceData (
      [intInvoiceId]			INT				NOT NULL
	, [strInvoiceNumber]		NVARCHAR(25)	COLLATE Latin1_General_CI_AS	NULL
	, [strTransactionType]		NVARCHAR(25)	COLLATE Latin1_General_CI_AS	NULL
	, [intInvoiceDetailId]		INT				NULL
	, [intItemId]				INT				NULL
	, [strBatchId]				NVARCHAR(50)	COLLATE Latin1_General_CI_AS	NULL
	, [strPostingError]			NVARCHAR(MAX)	COLLATE Latin1_General_CI_AS	NULL
    , [strSessionId]            NVARCHAR(50)    COLLATE Latin1_General_CI_AS    NULL
);
GO
CREATE INDEX [idx_tblARPostInvalidInvoiceData_intInvoiceId] ON [dbo].[tblARPostInvalidInvoiceData] (intInvoiceId)
GO
CREATE INDEX [idx_tblARPostInvalidInvoiceData_strSessionId] ON [dbo].[tblARPostInvalidInvoiceData] (strSessionId)
GO