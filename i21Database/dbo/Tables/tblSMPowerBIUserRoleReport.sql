CREATE TABLE [dbo].[tblSMPowerBIUserRoleReport]
(
	[intPowerBIUserRoleReportId]	INT IDENTITY (1, 1) NOT NULL,
	[intUserRoleId]					INT		NOT NULL,
	[intPowerBIReportId]			INT		NOT NULL,
	[strPermission]					NVARCHAR(100),
	[intConcurrencyId]				INT		NOT NULL	DEFAULT 1,

	CONSTRAINT [PK_tblSMPowerBIUserRoleReport] PRIMARY KEY CLUSTERED ([intPowerBIUserRoleReportId] ASC),
	CONSTRAINT [FK_dbo.tblSMPowerBIReport_tblSMPowerBIUserRoleReport] FOREIGN KEY ([intPowerBIReportId]) REFERENCES [tblSMPowerBIReport]([intPowerBIReportId]) ON DELETE CASCADE,
)
