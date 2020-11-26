

CREATE TABLE [dbo].[tblCFInvoiceReportBalanceValidation] (
	 intInvoiceReportBalanceValidationId INT  IDENTITY (1, 1) NOT NULL
	,intEntityCustomerId				 INT  NULL
	,strCustomerNumber					 NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL
	,strCustomerName					 NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL
	,dblRunningBalance					 NUMERIC (18, 6) NULL
	,dblAREndingBalance				     NUMERIC (18, 6) NULL
	,dblDiff							 NUMERIC (18, 6) NULL
	,dtmDate							 DATETIME  NULL
	,strUserId							 NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL
	,strStatementType					 NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL
	,intConcurrencyId					 INT             CONSTRAINT [DF_tblCFInvoiceReportBalanceValidation_intConcurrencyId] DEFAULT ((1)) NULL,
);
