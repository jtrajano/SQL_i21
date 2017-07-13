CREATE TABLE [dbo].[tblCRMLostRevenue]
(
	intLostRevenueId [int] IDENTITY(1,1) NOT NULL
	,intEntityCustomerId int not null
	,strName [nvarchar](100) COLLATE Latin1_General_CI_AS not NULL
	,intEntityContactId int null
	,strContact [nvarchar](100) COLLATE Latin1_General_CI_AS NULL
	,strCategory [nvarchar](100) COLLATE Latin1_General_CI_AS NULL
	,strItem [nvarchar](100) COLLATE Latin1_General_CI_AS NULL
	,dblThreeYearsAveSales [numeric](18, 6) NULL
	,dblThreeYearsAveSalesUnits [numeric](18, 6) NULL
	,dblSalesOrderTotal [numeric](18, 6) NULL
	,dblSalesOrderTotalUnits [numeric](18, 6) NULL
	,dblSalesOrderTotalShip [numeric](18, 6) NULL
	,dblSalesOrderTotalShipUnits [numeric](18, 6) NULL
	,dblSalesOrderTotalUnShip [numeric](18, 6) NULL
	,dblSalesOrderTotalUnShipUnits [numeric](18, 6) NULL
	,dblRemainingContractAmount [numeric](18, 6) NULL
	,dblRemainingContractAmountUnits [numeric](18, 6) NULL
	,dblTotalOrderAndContract [numeric](18, 6) NULL
	,dblTotalOrderAndContractUnits [numeric](18, 6) NULL
	,intUnitsDifference [numeric](18, 6) NULL
	,intUnitsPercentage [numeric](18, 6) NULL
	,intDifference [numeric](18, 6) NULL
	,intPercentage [numeric](18, 6) NULL
	,ysnLostSale bit null
	,ysnGenerateOpportunity bit null
	,ysnGenerateCampaign bit null
	,strGuid [nvarchar](36) COLLATE Latin1_General_CI_AS NULL
	,intCreatedDate int not null
	,intConcurrencyId [int] NOT NULL DEFAULT 1
)