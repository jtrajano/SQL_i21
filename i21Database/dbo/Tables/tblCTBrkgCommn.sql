CREATE TABLE [dbo].[tblCTBrkgCommn]
(
	intBrkgCommnId		   INT NOT NULL    IDENTITY, 
	strBatchNumber		   NVARCHAR(50)    COLLATE Latin1_General_CI_AS NOT NULL, 
	dtmBatchDate		   DATETIME	       NOT NULL,
	dtmPaymentDate		   DATETIME,
	intCreatedById		   INT,
	dtmCreated			   DATETIME,
	intConcurrencyId	   INT			   NOT NULL,
	strComments			   NVARCHAR(MAX)   COLLATE Latin1_General_CI_AS NOT NULL, 
	intVoucherId		   INT,
	intInvoiceId	       INT,
	strType				   NVARCHAR(200)   COLLATE Latin1_General_CI_AS NULL, 
	strEntityType		   NVARCHAR(200)   COLLATE Latin1_General_CI_AS NULL, 
	strEntityName		   NVARCHAR(200)   COLLATE Latin1_General_CI_AS NULL, 
	strStatus			   NVARCHAR(200)   COLLATE Latin1_General_CI_AS NULL, 
	strContractNumber	   NVARCHAR(200)   COLLATE Latin1_General_CI_AS NULL, 

	CONSTRAINT [PK_tblCTBrkgCommn_intBrkgCommnId] PRIMARY KEY CLUSTERED (intBrkgCommnId ASC),
	CONSTRAINT [UQ_tblCTBrkgCommn_strBatchNumber] UNIQUE (strBatchNumber)
)
