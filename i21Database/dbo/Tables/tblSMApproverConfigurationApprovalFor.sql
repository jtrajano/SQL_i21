CREATE TABLE [dbo].[tblSMApproverConfigurationApprovalFor]
(
	[intApprovalForId]		INT												NOT NULL	PRIMARY KEY IDENTITY, 
    [intScreenId]			INT												NOT NULL, 
	[strApprovalFor]		NVARCHAR(150) COLLATE Latin1_General_CI_AS		NOT NULL,
    [strNamespace]			NVARCHAR(250) COLLATE Latin1_General_CI_AS		NOT NULL,
	[strType]				NVARCHAR(50) COLLATE Latin1_General_CI_AS		NULL,
	[strDisplayField]		NVARCHAR(25) COLLATE Latin1_General_CI_AS		NULL,
	[strValueField]			NVARCHAR(25) COLLATE Latin1_General_CI_AS		NULL,
	[intConcurrencyId]		INT												NOT NULL	DEFAULT 1, 
    CONSTRAINT [FK_tblSMApproverConfigurationApprovalFor_tblSMScreen] FOREIGN KEY ([intScreenId]) REFERENCES [tblSMScreen]([intScreenId])
)
