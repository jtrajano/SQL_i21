CREATE TABLE tblARPostInvalidInvoiceData (
	  [intId]                   INT 			IDENTITY (1, 1) NOT NULL
    , [intInvoiceId]			INT				NOT NULL
	, [strInvoiceNumber]		NVARCHAR(25)	COLLATE Latin1_General_CI_AS	NULL
	, [strTransactionType]		NVARCHAR(25)	COLLATE Latin1_General_CI_AS	NULL
	, [intInvoiceDetailId]		INT				NULL
	, [intItemId]				INT				NULL
	, [strBatchId]				NVARCHAR(50)	COLLATE Latin1_General_CI_AS	NULL
	, [strPostingError]			NVARCHAR(MAX)	COLLATE Latin1_General_CI_AS	NULL
    , [strSessionId]            NVARCHAR(50)    COLLATE Latin1_General_CI_AS    NULL
	, CONSTRAINT [PK_tblARPostInvalidInvoiceData_intId] PRIMARY KEY CLUSTERED ([intId] ASC)
);
GO
CREATE INDEX [idx_tblARPostInvalidInvoiceData_intInvoiceId] ON [dbo].[tblARPostInvalidInvoiceData] (intInvoiceId)
GO
CREATE INDEX [idx_tblARPostInvalidInvoiceData_strSessionId] ON [dbo].[tblARPostInvalidInvoiceData] (strSessionId)
GO
CREATE INDEX [idx_tblARPostInvalidInvoiceData_strBatchId_strSessionId] ON [dbo].[tblARPostInvalidInvoiceData] (strSessionId) INCLUDE (strBatchId)
GO
CREATE INDEX [idx_tblARPostInvalidInvoiceData_strSessionId_intInvoiceId] ON [dbo].[tblARPostInvalidInvoiceData] (strSessionId) INCLUDE (intInvoiceId)
GO