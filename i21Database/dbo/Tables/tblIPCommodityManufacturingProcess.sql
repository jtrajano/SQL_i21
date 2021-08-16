CREATE TABLE [dbo].[tblIPCommodityManufacturingProcess](
	[intCommodityManufacturingProcessId] [int] IDENTITY(1,1) NOT NULL,
	[intCommodityId] [int] NULL,
	[intManufacturingProcessId] [int] NULL,
 CONSTRAINT [PK_tblIPCommodityManufacturingProcess] PRIMARY KEY CLUSTERED 
(
	[intCommodityManufacturingProcessId] ASC
))