CREATE TABLE [dbo].[tblSMTaxCode]
(
    [intTaxCodeId]			INT				NOT NULL PRIMARY KEY IDENTITY, 
    [strTaxCode]			NVARCHAR(50)    COLLATE Latin1_General_CI_AS NULL, 
    --[strType]                NVARCHAR(50)    COLLATE Latin1_General_CI_AS NULL, 
    [strDescription]        NVARCHAR(100)	COLLATE Latin1_General_CI_AS NULL, 
    [strCalculationMethod]	NVARCHAR(15)	COLLATE Latin1_General_CI_AS NULL, 
    [numRate]				NUMERIC(18, 6)	NULL, 
    [strTaxAgency]			NVARCHAR(100)	COLLATE Latin1_General_CI_AS NULL, 
    [strAddress]            NVARCHAR(150)	COLLATE Latin1_General_CI_AS NULL, 
    [strZipCode]            NVARCHAR (12)	COLLATE Latin1_General_CI_AS NOT NULL,
    [strState]				NVARCHAR (50)	COLLATE Latin1_General_CI_AS NOT NULL,
    [strCity]				NVARCHAR (50)	COLLATE Latin1_General_CI_AS NOT NULL,
    [strCountry]			NVARCHAR (25)	COLLATE Latin1_General_CI_AS NOT NULL,
    [intSalesAccountId]		INT				NULL, 
    [intPurchasingAccountId] INT			NULL, 
    [ysnTaxable]			BIT				NOT NULL	DEFAULT 0, 
    [ysnSeparateOnInvoice]	BIT				NOT NULL	DEFAULT 0, 
    [intConcurrencyId]		INT				NOT NULL DEFAULT 1, 
    CONSTRAINT [FK_tblSMTaxCode_tblGLAccount_sales] FOREIGN KEY (intSalesAccountId) REFERENCES tblGLAccount(intAccountId),
    CONSTRAINT [FK_tblSMTaxCode_tblGLAccount_purchasing] FOREIGN KEY (intPurchasingAccountId) REFERENCES tblGLAccount(intAccountId)
)