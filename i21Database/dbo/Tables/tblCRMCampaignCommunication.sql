CREATE TABLE [dbo].[tblCRMCampaignCommunication]
(
	[intCampaignCommunicationId] [int] IDENTITY(1,1) NOT NULL,
	[intCampaignId] [int] NOT NULL,
	[strContactDescription] [nvarchar](255) COLLATE Latin1_General_CI_AS NOT NULL,
	[strSenderAddress] [nvarchar](100) COLLATE Latin1_General_CI_AS NULL,
	[intLetterId] [int] NULL,
	[intTypeId] [int] NULL,
	[dtmDateScheduled] [datetime] NULL,
	[dtmDateSent] [datetime] NULL,
	[strSendTo] [nvarchar](50) COLLATE Latin1_General_CI_AS NULL,
	[intConcurrencyId] [int] NOT NULL DEFAULT 1,
	CONSTRAINT [PK_tblCRMCampaignCommunication_intCampaignCommunicationId] PRIMARY KEY CLUSTERED ([intCampaignCommunicationId] ASC),
	CONSTRAINT [FK_tblCRMCampaignCommunication_tblCRMCampaign_intCampaignId] FOREIGN KEY ([intCampaignId]) REFERENCES [dbo].[tblCRMCampaign] ([intCampaignId]),
	CONSTRAINT [FK_tblCRMCampaignCommunication_tblSMLetter_intLetterId] FOREIGN KEY ([intLetterId]) REFERENCES [dbo].[tblSMLetter] ([intLetterId]),
	CONSTRAINT [FK_tblCRMCampaignCommunication_tblCRMType_intTypeId] FOREIGN KEY ([intTypeId]) REFERENCES [dbo].[tblCRMType] ([intTypeId])
)
