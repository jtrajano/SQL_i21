CREATE TABLE [dbo].[tblGRGIIPhysicalInventory]
(
	intId INT PRIMARY KEY IDENTITY(1,1)
	,dtmReportDate DATETIME
	,strLicensed NVARCHAR(20) COLLATE Latin1_General_CI_AS
	,intCommodityId INT
	,strCommodityCode NVARCHAR(40) COLLATE Latin1_General_CI_AS
	,strCommodityDescription NVARCHAR(100) COLLATE Latin1_General_CI_AS
	,strLocationName NVARCHAR(200) COLLATE Latin1_General_CI_AS
	,dblBegInventory DECIMAL(18,6) DEFAULT 0
	,dblReceived DECIMAL(18,6) DEFAULT 0
	,dblShipped DECIMAL(18,6) DEFAULT 0
	,dblInternalTransfersReceived DECIMAL(18,6) DEFAULT 0
	,dblInternalTransfersShipped DECIMAL(18,6) DEFAULT 0
	,dblNetAdjustments DECIMAL(18,6) DEFAULT 0
	,dblEndInventory DECIMAL(18,6) DEFAULT 0
	,strUOM NVARCHAR(40) COLLATE Latin1_General_CI_AS
)
GO
CREATE NONCLUSTERED INDEX [IX_tblGRGIIPhysicalInventory_intCommodityId]
	ON [dbo].[tblGRGIIPhysicalInventory] ([intCommodityId])
	INCLUDE ([dtmReportDate],[strCommodityCode],[dblBegInventory],[dblShipped],[strUOM])
GO