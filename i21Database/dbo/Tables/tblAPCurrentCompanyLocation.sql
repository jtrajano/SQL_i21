CREATE TABLE [dbo].[tblAPCurrentCompanyLocation]
(
	[intId] INT IDENTITY (1, 1) NOT NULL PRIMARY KEY,
	[intCompanyLocationId] INT NOT NULL,
	CONSTRAINT [FK_dbo.tblAPCurrentCompanyLocation_dbo.tblSMCompanyLocation_intCompanyLocationId] FOREIGN KEY (intCompanyLocationId) REFERENCES tblSMCompanyLocation(intCompanyLocationId),
)
