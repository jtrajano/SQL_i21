CREATE TABLE [dbo].[tblHDRoughCountCapacity]
(
	[intRoughCountCapacityId] [int] IDENTITY(1,1) NOT NULL,
	[intSourceEntityId] [int] NOT NULL,
	[strSourceName] [nvarchar](100) COLLATE Latin1_General_CI_AS NOT NULL,
	[intTicketId] [int] NOT NULL,
	[strTicketNumber] [nvarchar](20) COLLATE Latin1_General_CI_AS NOT NULL,
	[intCustomerEntityId] [int] NOT NULL,
	[strCustomerName] [nvarchar](100) COLLATE Latin1_General_CI_AS NOT NULL,
	[dblFirstWeek] [numeric](18, 6) NULL,
	[dblSecondWeek] [numeric](18, 6) NULL,
	[dblThirdWeek] [numeric](18, 6) NULL,
	[dblForthWeek] [numeric](18, 6) NULL,
	[dblFifthWeek] [numeric](18, 6) NULL,
	[dblSixthWeek] [numeric](18, 6) NULL,
	[dblSeventhWeek] [numeric](18, 6) NULL,
	[dtmPlanDate] [datetime] NULL,
	[strFilterKey] [nvarchar](36) COLLATE Latin1_General_CI_AS NULL,
	[intConcurrencyId] [int] NOT NULL DEFAULT 1,
	CONSTRAINT [PK_tblHDRoughCountCapacity_intRoughCountCapacityId] PRIMARY KEY CLUSTERED ([intRoughCountCapacityId] ASC),
	CONSTRAINT [FK_tblHDRoughCountCapacity_tblEMENtity_intSourceEntityId] FOREIGN KEY ([intSourceEntityId]) REFERENCES [dbo].[tblEMEntity] ([intEntityId]),
    CONSTRAINT [FK_tblHDRoughCountCapacity_tblHDTicket_intTicketId] FOREIGN KEY ([intTicketId]) REFERENCES [dbo].[tblHDTicket] ([intTicketId]),
    CONSTRAINT [FK_tblHDRoughCountCapacity_tblEMENtity_intCustomerEntityId] FOREIGN KEY ([intCustomerEntityId]) REFERENCES [dbo].[tblEMEntity] ([intEntityId])
)
