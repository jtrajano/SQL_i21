CREATE TABLE [dbo].[tblCTContractBasis](
	[intContractBasisId] [int] IDENTITY(1,1) NOT NULL,
	[strContractBasis] [nvarchar](100) COLLATE Latin1_General_CI_AS NOT NULL,
	[strDescription] [nvarchar](500) COLLATE Latin1_General_CI_AS NOT NULL,
	[ysnDefault] [bit] NULL,
	[intInsuranceById] [int] NULL,
	[intInvoiceTypeId] [int] NULL,
	[intPositionId] [int] NULL,
	[intConcurrencyId] INT NOT NULL, 
	[strINCOLocationType] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
    CONSTRAINT [PK_tblCTContractBasis_intContractBasisId] PRIMARY KEY CLUSTERED ([intContractBasisId] ASC),
	CONSTRAINT [UK_tblCTContractBasis_strContractBasis] UNIQUE ([strContractBasis]),
	CONSTRAINT [FK_tblCTContractBasis_tblCTInsuranceBy_intInsuranceById] FOREIGN KEY ([intInsuranceById]) REFERENCES [tblCTInsuranceBy]([intInsuranceById]),
	CONSTRAINT [FK_tblCTContractBasis_tblCTInvoiceType_intInvoiceTypeId] FOREIGN KEY ([intInvoiceTypeId]) REFERENCES [tblCTInvoiceType]([intInvoiceTypeId]),
	CONSTRAINT [FK_tblCTContractBasis_tblCTPosition_intPositionId] FOREIGN KEY ([intPositionId]) REFERENCES [tblCTPosition]([intPositionId])
)