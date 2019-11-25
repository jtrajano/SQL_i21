CREATE TABLE [dbo].[tblSCCertificateOfAnalysis]
(
	[intCertificateOfAnalysisId] INT NOT NULL IDENTITY, 
    [strCertificate] NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL,
    [intConcurrencyId] INT NOT NULL DEFAULT 0, 
    CONSTRAINT [PK_tblSCCertificateOfAnalysis_intCertificateOfAnalysisId] PRIMARY KEY ([intCertificateOfAnalysisId]) ,
)

GO
