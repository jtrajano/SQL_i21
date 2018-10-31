CREATE TYPE [dbo].[InvoiceReportTable] AS TABLE
(
	 [intInvoiceId]		INT	NULL
	,[intEntityUserId]	INT	NULL
	,[strRequestId]		NVARCHAR(MAX)	COLLATE Latin1_General_CI_AS	NULL
	,[strInvoiceFormat]	NVARCHAR(200)	COLLATE Latin1_General_CI_AS	NULL
	,[strType]			NVARCHAR(200)	COLLATE Latin1_General_CI_AS	NULL
)