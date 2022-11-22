CREATE TABLE [dbo].[tblARCompanyReportHeader]
(	
	[intCompanyReportHeaderId]				INT	IDENTITY (1, 1) NOT NULL,
	[intCompanyLocationId]					INT	NOT NULL
    CONSTRAINT [PK_tblARCompanyReportHeader] PRIMARY KEY CLUSTERED ([intCompanyReportHeaderId] ASC),
	CONSTRAINT [FK_tblARCompanyReportHeader_tblSMCompanyLocation] FOREIGN KEY ([intCompanyLocationId]) REFERENCES [dbo].[tblSMCompanyLocation] ([intCompanyLocationId])
)