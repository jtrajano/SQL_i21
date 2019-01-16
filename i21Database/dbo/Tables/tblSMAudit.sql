CREATE TABLE [dbo].[tblSMAudit] (
    [intAuditId]		 INT              IDENTITY (1, 1) NOT NULL,
	[intLogId]			 INT			   NULL,
	[intKeyValue]		 INT			  NULL,
	[strAction]		     NVARCHAR(100)    COLLATE Latin1_General_CI_AS NULL,
	[strChange]			 NVARCHAR(100)	  COLLATE Latin1_General_CI_AS NULL, 
	[strFrom]			 NVARCHAR(MAX)	  COLLATE Latin1_General_CI_AS NULL, 
	[strTo]				 NVARCHAR(MAX)	  COLLATE Latin1_General_CI_AS NULL, 
	[strAlias]			 NVARCHAR(255)	  COLLATE Latin1_General_CI_AS NULL, 
	[ysnField]			 BIT,
	[ysnHidden]			 BIT, 
	[intParentAuditId]	 INT			  NULL,
    [intConcurrencyId]   INT              NOT NULL,
	CONSTRAINT [FK_dbo.tblSMAudit_tblSMLog] FOREIGN KEY ([intLogId]) REFERENCES [tblSMLog]([intLogId]) ON DELETE CASCADE,
	CONSTRAINT [FK_dbo.tblSMAudit_tblSMAudit] FOREIGN KEY ([intParentAuditId]) REFERENCES [tblSMAudit]([intAuditId]),
    CONSTRAINT [PK_dbo.tblSMAudit] PRIMARY KEY CLUSTERED ([intAuditId] ASC)


	
);