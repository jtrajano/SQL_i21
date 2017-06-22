CREATE PROCEDURE [dbo].[uspCRMCreateLostRevenue]
	@revenueFromDate INT,
	@revenueToDate INT,
	@compareToRevenueFromDate INT,
	@compareToRevenueToDate INT,
	@generatedGuid nvarchar(36),
	@guid nvarchar(36) OUTPUT
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

BEGIN TRY

	DECLARE @threeYearsBefore INT;
	DECLARE @current INT;
	DECLARE @createdDate INT;

	BEGIN TRANSACTION

		set @threeYearsBefore = convert(int,convert(nvarchar(8),dateadd(year,-3,getdate()),112));
		set @current = convert(int,convert(nvarchar(8),dateadd(day,-1,getdate()),112));
		set @createdDate = convert(int,convert(nvarchar(8),getdate(),112));

		delete from tblCRMLostRevenue where intCreatedDate < @createdDate;

		insert into tblCRMLostRevenue
		(
			intEntityCustomerId
			,strName
			,intEntityContactId
			,strContact
			,strCategory
			,strItem
			,dblThreeYearsAveSales
			,dblThreeYearsAveSalesUnits
			,dblSalesOrderTotal
			,dblSalesOrderTotalUnits
			,dblSalesOrderTotalShip
			,dblSalesOrderTotalShipUnits
			,dblSalesOrderTotalUnShip
			,dblSalesOrderTotalUnShipUnits
			,dblRemainingContractAmount
			,dblRemainingContractAmountUnits
			,dblTotalOrderAndContract
			,dblTotalOrderAndContractUnits
			,intUnitsDifference
			,intUnitsPercentage
			,intDifference
			,intPercentage
			,ysnLostSale
			,ysnGenerateOpportunity
			,ysnGenerateCampaign
			,strGuid
			,intCreatedDate
			,intConcurrencyId
		)
		select
			intEntityCustomerId
			,strName
			,intEntityContactId
			,strContact = ltrim(rtrim(strContact))
			,strCategory
			,strItem
			,dblThreeYearsAveSales = isnull(dblAveSalesOrderTotalInThreeYears,0)
			,dblThreeYearsAveSalesUnits = isnull(dblAveSalesOrderTotalInThreeYearsUnits,0)
			,dblSalesOrderTotal = isnull(dblSalesOrderTotal,0)
			,dblSalesOrderTotalUnits = isnull(dblSalesOrderTotalUnits,0)
			,dblSalesOrderTotalShip = isnull(dblSalesOrderTotalShip,0)
			,dblSalesOrderTotalShipUnits = isnull(dblSalesOrderTotalShipUnits,0)
			,dblSalesOrderTotalUnShip = isnull(dblSalesOrderTotalUnShip,0)
			,dblSalesOrderTotalUnShipUnits = isnull(dblSalesOrderTotalUnShipUnits,0)
			,dblRemainingContractAmount = isnull(dblRemainingContractAmount,0)
			,dblRemainingContractAmountUnits = isnull(dblRemainingContractAmountUnits,0)
			,dblTotalOrderAndContract = isnull(dblTotalOrderAndContract,0)
			,dblTotalOrderAndContractUnits = isnull(dblTotalOrderAndContractUnits,0)
			,intUnitsDifference = (isnull(dblTotalOrderAndContractUnits,0) - isnull(dblSalesOrderTotalUnits,0))
			,intUnitsPercentage = (case when (isnull(dblTotalOrderAndContractUnits,0) - isnull(dblSalesOrderTotalUnits,0)) < 0 then -100 when (isnull(dblTotalOrderAndContractUnits,0) - isnull(dblSalesOrderTotalUnits,0)) = 0 then 0 else 1000 end)
			,intDifference = (isnull(dblTotalOrderAndContract,0) - isnull(dblSalesOrderTotal,0))
			,intPercentage = (case when (isnull(dblTotalOrderAndContract,0) - isnull(dblSalesOrderTotal,0)) < 0 then -100 when (isnull(dblTotalOrderAndContract,0) - isnull(dblSalesOrderTotal,0)) = 0 then 0 else 1000 end)
			,ysnLostSale = (case when (isnull(dblTotalOrderAndContract,0) - isnull(dblSalesOrderTotal,0)) < 0 then convert(bit,1) else convert(bit,0) end)
			,ysnGenerateOpportunity = convert(bit,0)
			,ysnGenerateCampaign = convert(bit,0)
			,strGuid = @generatedGuid
			,intCreatedDate = @createdDate
			,intConcurrencyId = 1
		from
		(
		select distinct
			a.intEntityCustomerId
			,a.strName
			,a.intEntityContactId
			,a.strContact
			,a.strCategory
			,a.strItem
			,dblAveSalesOrderTotalInThreeYears = sum(b.dblSalesOrderTotal) / 3
			,dblAveSalesOrderTotalInThreeYearsUnits = sum(b.dblSalesOrderTotalUnits) / 3
			,dblSalesOrderTotal = sum(c.dblSalesOrderTotal)
			,dblSalesOrderTotalUnits = sum(c.dblSalesOrderTotalUnits)
			,dblSalesOrderTotalShip = sum(d.dblSalesOrderTotalShip)
			,dblSalesOrderTotalShipUnits = sum(d.dblSalesOrderTotalShipUnits)
			,dblSalesOrderTotalUnShip = sum(d.dblSalesOrderTotalUnShip)
			,dblSalesOrderTotalUnShipUnits = sum(d.dblSalesOrderTotalUnShipUnits)
			,dblRemainingContractAmount = sum(d.dblRemainingContractAmount)
			,dblRemainingContractAmountUnits = sum(d.dblRemainingContractAmountUnits)
			,dblTotalOrderAndContract = sum(d.dblTotalOrderAndContract)
			,dblTotalOrderAndContractUnits = sum(d.dblTotalOrderAndContractUnits)
		from
			vyuCRMLostRevenue a
			left join vyuCRMLostRevenue b on b.intEntityCustomerId = a.intEntityCustomerId and b.strCategory = a.strCategory and b.strItem = a.strItem and b.intDate between @threeYearsBefore and @current
			left join vyuCRMLostRevenue c on c.intEntityCustomerId = a.intEntityCustomerId and c.strCategory = a.strCategory and c.strItem = a.strItem and c.intDate between @revenueFromDate and @revenueToDate
			left join vyuCRMLostRevenue d on d.intEntityCustomerId = a.intEntityCustomerId and d.strCategory = a.strCategory and d.strItem = a.strItem and d.intDate between @compareToRevenueFromDate and @compareToRevenueToDate
		where
			a.intDate between @threeYearsBefore and @compareToRevenueToDate
		group by
			a.intEntityCustomerId
			,a.strName
			,a.intEntityContactId
			,a.strContact
			,a.strCategory
			,a.strItem
		) as total

		set @guid = @generatedGuid;

	COMMIT TRANSACTION;

END TRY
BEGIN CATCH
	ROLLBACK TRANSACTION;
END CATCH