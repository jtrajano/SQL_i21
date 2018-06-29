CREATE PROC [dbo].[uspRKDPRDailyPositionByCommodityChart] 
	 @intCommodityId int 
	,@intVendorId int = null
AS

DECLARE @tblFinalDetail TABLE (
	intRowNum int,
	strLocationName NVARCHAR(500) COLLATE Latin1_General_CI_AS,
	intLocationId int
	,intCommodityId INT
	,strCommodityCode NVARCHAR(50) COLLATE Latin1_General_CI_AS
	,UOM NVARCHAR(50) COLLATE Latin1_General_CI_AS	
	,[Open Purchase] decimal(24,10)
	,[Open Sale]  decimal(24,10)	
	,[Company Titled] decimal(24,10)
	,[Price Risk] decimal(24,10)
	,[Open Sales] decimal(24,10)
	,[Avail For Sale] decimal(24,10)
	,[In House] decimal(24,10)
	,[Basis Risk] decimal(24,10)
	)


INSERT INTO @tblFinalDetail
EXEC uspRKDPRDailyPositionByCommodityLocation @intCommodityId =  @intCommodityId,@intVendorId=@intVendorId

SELECT strTransactionType,UOM
 ,sum(dblTransactionQuantity) dblTransactionQuantity
FROM @tblFinalDetail 
UNPIVOT(dblTransactionQuantity FOR strTransactionType IN (
	 [Company Titled]
	,[Price Risk]
	,[Basis Risk] 
	,[Avail For Sale] 	
	,[In House]
   )) AS UnPvt group by strTransactionType,UOM 