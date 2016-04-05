CREATE PROC [dbo].[uspRKDPRDailyPositionByCommodity]
AS
DECLARE @tblFinalDetail TABLE (
	intRowNum int,
	strLocationName NVARCHAR(500) COLLATE Latin1_General_CI_AS,
	intLocationId int
	,intCommodityId INT
	,strCommodityCode NVARCHAR(50) COLLATE Latin1_General_CI_AS
	,strUnitMeasure NVARCHAR(50) COLLATE Latin1_General_CI_AS	
	,OpenPurchasesQty decimal(24,10)
	,OpenSalesQty  decimal(24,10)	
	,dblCompanyTitled decimal(24,10)
	,dblCaseExposure decimal(24,10)
	,OpenSalQty decimal(24,10)
	,dblAvailForSale decimal(24,10)
	,dblInHouse decimal(24,10)
	,dblBasisExposure decimal(24,10)
	)

DECLARE @strCommodity Nvarchar(MAX)
SET @strCommodity = ''
SELECT @strCommodity =CASE 
       WHEN @strCommodity = '' THEN LTRIM(intCommodityId)
          ELSE @strCommodity + ',' + LTRIM(intCommodityId)
          END         
FROM tblICCommodity

if isnull(@strCommodity,'')=''  return	

INSERT INTO @tblFinalDetail
EXEC uspRKDPRDailyPositionByCommodityLocation @intCommodityId =  @strCommodity

select intCommodityId,strCommodityCode,strUnitMeasure
	,sum(isnull(OpenPurchasesQty,0))  OpenPurchasesQty
	,sum(isnull(OpenSalesQty,0))  	 OpenSalesQty
	,sum(isnull(dblCompanyTitled,0)) dblCompanyTitled
	,sum(isnull(dblCaseExposure,0)) dblCaseExposure
	,sum(isnull(OpenSalQty,0)) OpenSalQty
	,sum(isnull(dblAvailForSale,0)) dblAvailForSale
	,sum(isnull(dblInHouse,0)) dblInHouse
	,sum(isnull(dblBasisExposure,0)) dblBasisExposure from @tblFinalDetail
GROUP BY intCommodityId,strCommodityCode,strUnitMeasure