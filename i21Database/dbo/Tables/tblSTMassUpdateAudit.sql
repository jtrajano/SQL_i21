CREATE TABLE [dbo].[tblSTMassUpdateAudit] (
    [intMassUpdateId]     INT            IDENTITY (1, 1) NOT NULL,
    [strScreenName] NVARCHAR (MAX) COLLATE Latin1_General_CI_AS NULL,
    [strXML]   NVARCHAR (MAX) COLLATE Latin1_General_CI_AS NULL,
	[strStatus]   NVARCHAR (MAX) COLLATE Latin1_General_CI_AS NULL,
	[dtmDateGenerated]   DATETIME  NULL,
	[intCurrentUserId]   INT  NULL,
    [intConcurrencyId] INT            CONSTRAINT [DF_tblSTMassUpdateAudit_intConcurrencyId] DEFAULT ((1)) NULL,
    CONSTRAINT [PK_tblSTMassUpdateAudit] PRIMARY KEY CLUSTERED ([intMassUpdateId] ASC)
);