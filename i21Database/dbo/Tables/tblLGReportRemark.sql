CREATE TABLE [dbo].[tblLGReportRemark]
(
	intReportRemarkId INT IDENTITY NOT NULL,
	strType NVARCHAR(50) NOT NULL,
	intValueId INT NOT NULL,
	intLocationId INT NULL,
	strRemarks NVARCHAR(MAX) NULL,
	intConcurrencyId INT NULL DEFAULT((0)), 
    CONSTRAINT [PK_tblLGReportRemark] PRIMARY KEY ([intReportRemarkId]), 
    CONSTRAINT [AK_tblLGReportRemark] UNIQUE (strType, intValueId, intLocationId)

)
