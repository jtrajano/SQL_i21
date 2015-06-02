CREATE TABLE [dbo].[tblCTContractCertification]
(
	[intContractCertificationId] INT IDENTITY(1,1) NOT NULL, 
    [intContractDetailId] INT NOT NULL, 
    [intCertificationId] INT NOT NULL, 
    [intConcurrencyId] INT NOT NULL,
	CONSTRAINT [PK_tblCTContractCertification_intContractCertificationId] PRIMARY KEY CLUSTERED ([intContractCertificationId] ASC),
	CONSTRAINT [FK_tblCTContractCertification_tblCTContractDetail_intContractDetailId] FOREIGN KEY ([intContractDetailId]) REFERENCES [tblCTContractDetail]([intContractDetailId]) ON DELETE CASCADE,
	CONSTRAINT [FK_tblCTContractCertification_tblICCertification_intCertificationId] FOREIGN KEY ([intCertificationId]) REFERENCES [tblICCertification]([intCertificationId]) 
)