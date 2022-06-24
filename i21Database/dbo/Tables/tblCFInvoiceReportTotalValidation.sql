


CREATE TABLE [dbo].[tblCFInvoiceReportTotalValidation] (
	 intInvoiceReportTotalValidationId INT  IDENTITY (1, 1) NOT NULL
	,intTransactionId			     INT  NULL
	,intInvoiceId					 INT  NULL
	,strTransactionId				 NVARCHAR (100)  COLLATE Latin1_General_CI_AS NULL
	,strTransactionType				 NVARCHAR (100)  COLLATE Latin1_General_CI_AS NULL
	,dblQuantity					 NUMERIC (18, 6) NULL
	,dblCFTotal						 NUMERIC (18, 6) NULL
	,dblARTotal						 NUMERIC (18, 6) NULL
	,dblDiff						 NUMERIC (18, 6) NULL
	,dtmTransactionDate				 DATETIME  NULL
	,dtmInvoiceDate					 DATETIME  NULL
	,dtmPostedDate					 DATETIME  NULL
	,strUserId						 NVARCHAR (100)  COLLATE Latin1_General_CI_AS NULL
	,strStatementType				 NVARCHAR (100)  COLLATE Latin1_General_CI_AS NULL
	,strErrorType					 NVARCHAR (100)  COLLATE Latin1_General_CI_AS NULL
	,intEntityCustomerId			 INT  NULL
	,strCustomerNumber				 NVARCHAR (100)  COLLATE Latin1_General_CI_AS NULL
	,strCustomerName				 NVARCHAR (100)  COLLATE Latin1_General_CI_AS NULL
	,intConcurrencyId                INT             CONSTRAINT [DF_tblCFInvoiceReportTotalValidation_intConcurrencyId] DEFAULT ((1)) NULL,
);

