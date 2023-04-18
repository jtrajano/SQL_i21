CREATE TABLE [dbo].[tblGRGIICustomerStorage]
(	
	intId INT PRIMARY KEY IDENTITY(1,1)
	,dtmReportDate DATETIME
	,intCommodityId INT
	,strCommodityCode NVARCHAR(40) COLLATE Latin1_General_CI_AS
	,intStorageTypeId INT
	,strStorageTypeDescription NVARCHAR(40) COLLATE Latin1_General_CI_AS
	,dblBeginningBalance DECIMAL(18,6) DEFAULT 0
	,dblIncrease DECIMAL(18,6) DEFAULT 0
	,dblDecrease DECIMAL(18,6) DEFAULT 0
	,dblEndingBalance DECIMAL(18,6) DEFAULT 0
	,strUOM NVARCHAR(40) COLLATE Latin1_General_CI_AS
)
GO
CREATE NONCLUSTERED INDEX [IX_tblGRGIICustomerStorage_intCommodityId]
	ON [dbo].[tblGRGIICustomerStorage] ([intCommodityId])
	INCLUDE ([dtmReportDate],[strCommodityCode],[dblBeginningBalance],[dblIncrease],[dblDecrease],[dblEndingBalance],[strUOM])
GO