CREATE TABLE [dbo].[tblCRMLostRevenueConfig]
(
	[intLostRevenueConfigId] [int] IDENTITY(1,1) NOT NULL,
	[intEntityId] [int] NOT NULL,
	[dtmRevenueFrom] [datetime] NOT NULL,
	[dtmRevenueTo] [datetime] NOT NULL,
	[dtmCompareToRevenueFrom] [datetime] NOT NULL,
	[dtmCompareToRevenueTo] [datetime] NOT NULL,
	[dtmOpportunityDate] [datetime] NULL,
	[dtmCreatedDate] [datetime] NULL,
	[dtmLastUpdatedDate] [datetime] NULL,
	[intConcurrencyId] [int] NOT NULL DEFAULT 1,
	CONSTRAINT [PK_tblCRMLostRevenueConfig_intLostRevenueConfigId] PRIMARY KEY CLUSTERED ([intLostRevenueConfigId] ASC),
	CONSTRAINT [FK_tblCRMLostRevenueConfig_tblEMEntity_intEntityId] FOREIGN KEY ([intEntityId]) REFERENCES [dbo].[tblEMEntity] ([intEntityId]),
	CONSTRAINT [UQ_tblCRMLostRevenueConfig_intEntityId] UNIQUE ([intEntityId])
)
