CREATE TABLE [dbo].[tblARCustomerDocument]
(
	[intCustomerDocumentId]		INT             NOT NULL IDENTITY,
	[intEntityCustomerId]	    INT             NOT NULL,	
	[strFileType]		        NVARCHAR(100)   COLLATE Latin1_General_CI_AS NULL,
    [strFileName]		        NVARCHAR(500)   COLLATE Latin1_General_CI_AS NULL,
    [strDocumentType]		    NVARCHAR(100)   COLLATE Latin1_General_CI_AS NULL,
    [dtmDateCreated]            DATETIME        NOT NULL,
    [intSize]                   INT             NULL,
    [intEntityId]               INT             NULL,
	[intConcurrencyId]			INT             NOT NULL DEFAULT ((0)),
    CONSTRAINT [PK_tblARCustomerDocument_intCustomerDocumentId] PRIMARY KEY CLUSTERED ([intCustomerDocumentId] ASC),
	CONSTRAINT [FK_tblARCustomerDocument_tblARCustomer_intEntityCustomerId] FOREIGN KEY ([intEntityCustomerId]) REFERENCES [tblARCustomer]([intEntityId])
);