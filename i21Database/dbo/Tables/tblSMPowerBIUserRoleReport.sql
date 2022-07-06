CREATE TABLE [dbo].[tblSMPowerBIUserRoleReport]
(
	[intPowerBIUserRoleReportId]	INT		NOT NULL	PRIMARY KEY IDENTITY, 
	[intUserRoleId]					INT		NOT NULL,
	[intPowerBIReportId]			INT		NOT NULL,
	[intConcurrencyId]				INT		NOT NULL	DEFAULT 1
)
