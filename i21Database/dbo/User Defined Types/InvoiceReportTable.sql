CREATE TYPE [dbo].[InvoiceReportTable] AS TABLE
(
	 [intInvoiceId]		INT	NULL
	,[intEntityUserId]	INT	NULL
	,[strInvoiceFormat]	NVARCHAR(200)	COLLATE Latin1_General_CI_AS	NULL
	,[strType]			NVARCHAR(200)	COLLATE Latin1_General_CI_AS	NULL
)