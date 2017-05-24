CREATE TABLE [dbo].[tblTFTaxAuthority] (
    [intTaxAuthorityId]             INT            IDENTITY (1, 1) NOT NULL,
    [strTaxAuthorityCode]           VARCHAR (2)    COLLATE Latin1_General_CI_AS NOT NULL,
    [strDescription]                NVARCHAR (100) COLLATE Latin1_General_CI_AS NULL,
    [ysnPaperVersionAvailable]      BIT            NULL,
    [ysnFilingForThisTA]            BIT            NULL,
    [ysnElectronicVersionAvailable] BIT            NULL,
	[intMasterId] INT NULL,
    [intConcurrencyId]              INT            CONSTRAINT [DF_tblTFTaxAuthority_intConcurrencyId] DEFAULT ((1)) NULL,
    CONSTRAINT [PK_tblTFTaxAuthority] PRIMARY KEY CLUSTERED ([intTaxAuthorityId] ASC)
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_tblTFTaxAuthority]
    ON [dbo].[tblTFTaxAuthority]([strTaxAuthorityCode] ASC);

