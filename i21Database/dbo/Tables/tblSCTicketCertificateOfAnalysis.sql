CREATE TABLE [dbo].[tblSCTicketCertificateOfAnalysis]
(
	[intTicketCertificateOfAnalysisId] INT NOT NULL IDENTITY, 
    [intTicketId] INT NOT NULL, 
    [dblReading] DECIMAL(18, 6) NOT NULL, 
	[intCertificateOfAnalysisId] INT NOT NULL,
	[intEnteredByUserId] INT NOT NULL,
	[dtmDateEntered] DATETIME DEFAULT (getdate()) NOT NULL,
    [intConcurrencyId] INT NOT NULL DEFAULT 0, 

    CONSTRAINT [PK_tblSCTicketCertificateOfAnalysis_intTicketCertificateOfAnalysisId] PRIMARY KEY ([intTicketCertificateOfAnalysisId]) ,
	CONSTRAINT [FK_tblSCTicketCertificateOfAnalysis_tblSCTicket_intTicketId] FOREIGN KEY ([intTicketId]) REFERENCES [tblSCTicket]([intTicketId]),
	CONSTRAINT [FK_tblSCTicketCertificateOfAnalysis_tblGRStorageType_[intCertificateOfAnalysisId] FOREIGN KEY ([intCertificateOfAnalysisId]) REFERENCES [tblSCCertificateOfAnalysis]([intCertificateOfAnalysisId]),
	CONSTRAINT [FK_tblSCTicketCertificateOfAnalysis_tblEMEntity_intEnteredByUserId] FOREIGN KEY ([intEnteredByUserId]) REFERENCES [tblEMEntity]([intEntityId])
)

GO