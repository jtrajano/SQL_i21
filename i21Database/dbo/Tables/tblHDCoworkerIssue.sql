CREATE TABLE [dbo].[tblHDCoworkerIssue]
(
	[intCoworkerIssueId]					INT IDENTITY(1,1) NOT NULL,
	[intUserId]								INT			   NOT NULL,
	[intTimeEntryPeriodDetailId]			INT			   NOT NULL,
	[intEntityId]							INT			   NOT NULL,
    [strAgentName]							NVARCHAR(250) COLLATE Latin1_General_CI_AS NOT NULL,
	[ysnActive]							    BIT	 NOT NULL	CONSTRAINT [DF_tblHDCoworkerIssue_ysnActive] DEFAULT ((0)),
	[strRemarks]							NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NOT NULL,
	[intConcurrencyId] [int]			    NOT NULL DEFAULT 1,

	CONSTRAINT [PK_tblHDCoworkerIssue_intCoworkerIssueId] PRIMARY KEY CLUSTERED ([intCoworkerIssueId] ASC),
	CONSTRAINT [FK_tblHDCoworkerIssue_tblEMEntity_intEntityId] FOREIGN KEY ([intEntityId]) REFERENCES [tblEMEntity]([intEntityId]),
	CONSTRAINT [FK_tblHDCoworkerIssue_tblEMEntity_intUserId] FOREIGN KEY ([intUserId]) REFERENCES [tblEMEntity]([intEntityId]),
	CONSTRAINT [FK_tblHDCoworkerIssue_tblHDTimeEntryPeriodDetail_intTimeEntryPeriodDetailId] FOREIGN KEY ([intTimeEntryPeriodDetailId]) REFERENCES [tblHDTimeEntryPeriodDetail]([intTimeEntryPeriodDetailId]),
)

GO