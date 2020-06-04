CREATE TABLE [dbo].[tblSMFreightTerms]
(
	[intFreightTermId]								INT				PRIMARY KEY IDENTITY(1,1)		NOT NULL, 
    [strFreightTerm]								NVARCHAR(100)		COLLATE Latin1_General_CI_AS	NOT NULL, 
    [strFobPoint]									NVARCHAR(100)		COLLATE Latin1_General_CI_AS	NOT NULL,
	[ysnActive]										BIT				DEFAULT (1)						NOT NULL,
	[ysnInsuranceCertificateNoRequired]				BIT				DEFAULT (0)						NOT NULL,

	--From Contract Basis
	[strContractBasis]								[nvarchar](100) COLLATE Latin1_General_CI_AS NOT NULL,
	[strDescription]								[nvarchar](500) COLLATE Latin1_General_CI_AS NOT NULL,
	[ysnDefault]									[bit] NULL,
	[intInsuranceById]								[int] NULL,
	[intInvoiceTypeId]								[int] NULL,
	[intPositionId]									[int] NULL,
	[strINCOLocationType]							NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 

	[strDescription]								[nvarchar](MAX) COLLATE Latin1_General_CI_AS NOT NULL,

	--From Contract Basis
	[intConcurrencyId]	 INT				DEFAULT (1)						NOT NULL,
	CONSTRAINT [AK_tblSMFreightTerms_strFreightTerm] UNIQUE NONCLUSTERED ([strFreightTerm] ASC),	
	CONSTRAINT [FK_tblSMFreightTerms_tblCTInsuranceBy_intInsuranceById] FOREIGN KEY ([intInsuranceById]) REFERENCES [tblCTInsuranceBy]([intInsuranceById]),
	CONSTRAINT [FK_tblSMFreightTerms_tblCTInvoiceType_intInvoiceTypeId] FOREIGN KEY ([intInvoiceTypeId]) REFERENCES [tblCTInvoiceType]([intInvoiceTypeId]),
	CONSTRAINT [FK_tblSMFreightTerms_tblCTPosition_intPositionId] FOREIGN KEY ([intPositionId]) REFERENCES [tblCTPosition]([intPositionId])
);
