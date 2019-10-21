CREATE TABLE [dbo].[tblCTContractInvoice](
	[intContractInvoiceId]	INT IDENTITY(1,1) NOT NULL,
	[intContractDetailId]	INT NOT NULL,
	[strInvoiceNumber]		NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[dtmDate]				DATETIME NOT NULL,
	[strDescription]		NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[intCurrencyId]			INT NULL,
	[dblAmount]				NUMERIC(18, 6) NOT NULL,
	[strCounterParty]		NVARCHAR(10) COLLATE Latin1_General_CI_AS NULL,
	[strRemark]				NVARCHAR(150) COLLATE Latin1_General_CI_AS NULL,
	[intConcurrencyId]		INT NOT NULL DEFAULT 1,
	CONSTRAINT [PK_tblCTContractInvoice_intContractOptionId] PRIMARY KEY CLUSTERED ([intContractInvoiceId] ASC),
	CONSTRAINT [FK_tblCTContractInvoice_tblCTContractDetail_intContractDetailId] FOREIGN KEY ([intContractDetailId]) REFERENCES [tblCTContractDetail]([intContractDetailId]),
	CONSTRAINT [FK_tblCTContractInvoice_tblSMCurrency_intCurrencyId] FOREIGN KEY ([intCurrencyId]) REFERENCES [tblSMCurrency]([intCurrencyID])
)