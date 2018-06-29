CREATE PROCEDURE [dbo].[uspPATUpdateRefundCategory]
	 @intFiscalYearId INT = NULL

AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

BEGIN
	UPDATE RCat
	SET RCat.intPatronageCategoryId = CVol.intPatronageCategoryId,
	RCat.dblVolume = CVol.dblVolume,
	RCat.dblRefundRate = CVol.dblRate
	FROM tblPATRefundCategory RCat
	INNER JOIN 
	(
		select
			Cus.intCustomerId,
			dblVolume = Cus.dblPurchaseVolume + Cus.dblSaleVolume,
			Cus.dblRate,
			Cus.intPatronageCategoryId,
			Cus.intRefundCategoryId,
			Cus.intRefundCustomerId
		from tblPATRefundCustomer RCus
		inner join
		(
			select distinct CVol.intCustomerPatronId AS intCustomerId,
							intRefundCategoryId = (CASE WHEN RCat.intRefundCustomerId = (CASE WHEN RCus.intRefundTypeId = RRD.intRefundTypeId THEN RCus.intRefundCustomerId ELSE null END) THEN RCat.intRefundCategoryId ELSE null END),
							intRefundCustomerId = (CASE WHEN RCus.intRefundTypeId = RRD.intRefundTypeId THEN RCus.intRefundCustomerId ELSE null END),
							PCat.intPatronageCategoryId,
							dblRate = SUM(RRD.dblRate),
							dblPurchaseVolume = (CASE WHEN PCat.strPurchaseSale = 'Purchase' THEN CVol.dblVolume ELSE 0 END),
							dblSaleVolume = (CASE WHEN PCat.strPurchaseSale = 'Sale' THEN CVol.dblVolume ELSE 0 END)
			from tblPATCustomerVolume CVol
			inner join tblPATPatronageCategory PCat
			on CVol.intPatronageCategoryId = PCat.intPatronageCategoryId
			inner join tblPATRefundRateDetail RRD
			on PCat.intPatronageCategoryId = RRD.intPatronageCategoryId
			inner join tblPATRefundCustomer RCus
			on RCus.intCustomerId = CVol.intCustomerPatronId
			inner join tblPATRefundCategory RCat
			on RCus.intRefundCustomerId = RCat.intRefundCustomerId
			where intRefundCategoryId is not null AND intFiscalYear = @intFiscalYearId
			GROUP BY	CVol.intCustomerPatronId, 
						PCat.strPurchaseSale,
						RCat.dblRefundAmount,
						CVol.dblVolume,
						RCus.intRefundCustomerId,RCus.intRefundTypeId,RRD.intRefundTypeId,RCat.intRefundCategoryId,RCat.intRefundCustomerId,PCat.intPatronageCategoryId
		) Cus
		on RCus.intRefundCustomerId = Cus.intRefundCustomerId AND Cus.intRefundCustomerId is not null
	) CVol
	ON RCat.intRefundCategoryId = CVol.intRefundCategoryId
END
GO
