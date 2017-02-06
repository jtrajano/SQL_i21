CREATE TABLE [dbo].[tblSMApproverConfigurationApprovalFor]
(
	[intApprovalForId]		INT												NOT NULL	PRIMARY KEY IDENTITY, 
    [strApprovalFor]		INT												NOT NULL, 
	[strNamespace]			NVARCHAR(250) COLLATE Latin1_General_CI_AS		NOT NULL,
	[strType]				NVARCHAR(50) COLLATE Latin1_General_CI_AS		NOT NULL,
    [intConcurrencyId]		INT												NOT NULL	DEFAULT 1, 
)
