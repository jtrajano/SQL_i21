CREATE TABLE [dbo].[tblSMApproverConfigurationDetail]
(
	[intApproverConfigurationDetailId]		INT												NOT NULL PRIMARY KEY IDENTITY, 
    [intScreenId]							INT												NOT NULL, 
    [intValueId]							INT												NOT NULL, 
	[strValue]								NVARCHAR(250) COLLATE Latin1_General_CI_AS		NOT NULL,
	[intApproverConfigurationId]			INT												NOT NULL DEFAULT 0,
	[intApprovalForId]						INT												NOT NULL DEFAULT 0,
	[intSort]								INT												NOT NULL, 
    [intConcurrencyId]						INT												NOT NULL DEFAULT 1, 
    CONSTRAINT [FK_tblSMApproverConfigurationDetail_tblSMApproverConfigurationApprovalFor] FOREIGN KEY ([intApprovalForId]) REFERENCES tblSMApproverConfigurationApprovalFor([intApprovalForId]), 
    CONSTRAINT [AK_tblSMApproverConfigurationDetail] UNIQUE ([intApproverConfigurationId], [intScreenId], [intApprovalForId], [intValueId], [strValue])
)
