--This will disallow deletion in tblICCommodityAttribute via uspRKSyncCommodityMarketAttribute
CREATE TABLE [dbo].[tblRKCommodityMarketMappingAttribute](
	[intCommodityMarketMappingAttributeId] [int] IDENTITY(1,1) NOT NULL,
	[intCommodityAttributeId] [int] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[intCommodityMarketMappingAttributeId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[tblRKCommodityMarketMappingAttribute]  WITH CHECK ADD  CONSTRAINT [FK_tblRKCommodityMarketMappingAttribute_tblICCommodityAttribute] FOREIGN KEY([intCommodityAttributeId])
REFERENCES [dbo].[tblICCommodityAttribute] ([intCommodityAttributeId])
GO

ALTER TABLE [dbo].[tblRKCommodityMarketMappingAttribute] CHECK CONSTRAINT [FK_tblRKCommodityMarketMappingAttribute_tblICCommodityAttribute]
GO

