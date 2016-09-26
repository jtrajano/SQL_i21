CREATE TABLE [dbo].[tblHDOpportunityCampaignCommunication]
(
	[intOpportunityCampaignCommunicationId] [int] IDENTITY(1,1) NOT NULL,
	[intOpportunityCampaignId] [int] NOT NULL,
	[strContactDescription] [nvarchar](255) COLLATE Latin1_General_CI_AS NOT NULL,
	[strSenderAddress] [nvarchar](100) COLLATE Latin1_General_CI_AS NULL,
	[intLetterId] [int] NULL,
	[intTicketTypeId] [int] NULL,
	[dtmDateScheduled] [datetime] NULL,
	[dtmDateSent] [datetime] NULL,
	[strSendTo] [nvarchar](50) COLLATE Latin1_General_CI_AS NULL,
	[intConcurrencyId] [int] NOT NULL DEFAULT 1,
	CONSTRAINT [PK_tblHDOpportunityCampaignCommunication] PRIMARY KEY CLUSTERED ([intOpportunityCampaignCommunicationId] ASC),
	CONSTRAINT [FK_tblHDOpportunityCampaignCommunication_tblHDOpportunityCampaign] FOREIGN KEY ([intOpportunityCampaignId]) REFERENCES [dbo].[tblCRMCampaign] ([intCampaignId]),
	CONSTRAINT [FK_tblHDOpportunityCampaignCommunication_tblSMLetter] FOREIGN KEY ([intLetterId]) REFERENCES [dbo].[tblSMLetter] ([intLetterId]),
	CONSTRAINT [FK_tblHDOpportunityCampaignCommunication_tblHDTicketType] FOREIGN KEY ([intTicketTypeId]) REFERENCES [dbo].[tblHDTicketType] ([intTicketTypeId])
)
