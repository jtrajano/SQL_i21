CREATE TABLE [dbo].[tblSMTaxCode]
(
    [intTaxCodeId]			INT				NOT NULL PRIMARY KEY IDENTITY, 
    [strTaxCode]			NVARCHAR(50)    COLLATE Latin1_General_CI_AS NULL, 
    [intTaxClassId]         INT				NULL, 
    [strDescription]        NVARCHAR(100)	COLLATE Latin1_General_CI_AS NULL, 
    [strCalculationMethod]	NVARCHAR(15)	COLLATE Latin1_General_CI_AS NULL, 
    [numRate]				NUMERIC(18, 6)	NULL, 
    [strTaxAgency]			NVARCHAR(100)	COLLATE Latin1_General_CI_AS NULL, 
    [strAddress]            NVARCHAR(150)	COLLATE Latin1_General_CI_AS NULL, 
    [strZipCode]            NVARCHAR (12)	COLLATE Latin1_General_CI_AS NOT NULL,
    [strState]				NVARCHAR (50)	COLLATE Latin1_General_CI_AS NOT NULL,
    [strCity]				NVARCHAR (50)	COLLATE Latin1_General_CI_AS NOT NULL,
    [strCountry]			NVARCHAR (25)	COLLATE Latin1_General_CI_AS NOT NULL,
	[strCounty]				NVARCHAR (25)	COLLATE Latin1_General_CI_AS NULL,
	[intSalesTaxAccountId]		INT		NULL, 
    [intPurchaseTaxAccountId]	INT		NULL, 
    [strTaxableByOtherTaxes]	NVARCHAR (MAX)	COLLATE Latin1_General_CI_AS NULL,
	[ysnCheckoffTax]			BIT		NOT NULL	DEFAULT 0,
    [intConcurrencyId]			INT		NOT NULL	DEFAULT 1, 
    CONSTRAINT [FK_tblSMTaxCode_tblSMTaxClass] FOREIGN KEY ([intTaxClassId]) REFERENCES tblSMTaxClass(intTaxClassId),
    CONSTRAINT [FK_tblSMTaxCode_tblGLAccount_salesTax] FOREIGN KEY ([intSalesTaxAccountId]) REFERENCES tblGLAccount(intAccountId),
    CONSTRAINT [FK_tblSMTaxCode_tblGLAccount_purchaseTax] FOREIGN KEY ([intPurchaseTaxAccountId]) REFERENCES tblGLAccount(intAccountId) 
)