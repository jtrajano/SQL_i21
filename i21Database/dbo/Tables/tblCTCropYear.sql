CREATE TABLE [dbo].[tblCTCropYear](
	[intCropYearId] [int] IDENTITY(1,1) NOT NULL,
	[intConcurrencyId] [int] NOT NULL,
	[intCommodityId] [int] NOT NULL,
	[strCropYear] [nvarchar](30) COLLATE Latin1_General_CI_AS NOT NULL,
	[dtmStartDate] [datetime] NOT NULL,
	[dtmEndDate] [datetime] NOT NULL,
	[ysnActive] [bit] NOT NULL,
 CONSTRAINT [PK_tblCMCropYear_intCropYearId] PRIMARY KEY CLUSTERED 
(
	[intCropYearId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

ALTER TABLE [dbo].[tblCTCropYear]  WITH CHECK ADD  CONSTRAINT [FK_tblCTCropYear_tblICCommodity_intCommodityId] FOREIGN KEY([intCommodityId])
REFERENCES [dbo].[tblICCommodity] ([intCommodityId])
GO

ALTER TABLE [dbo].[tblCTCropYear] CHECK CONSTRAINT [FK_tblCTCropYear_tblICCommodity_intCommodityId]
GO

