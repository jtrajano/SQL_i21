CREATE PROCEDURE [dbo].uspTMRecalculateCallEntryPrices
AS
BEGIN
	
	IF OBJECT_ID('tempdb..#tmpUpdateDispatch') IS NOT NULL DROP TABLE #tmpUpdateDispatch

	SELECT 
		Z.*
		,dblPrice = X.dblPrice
		,strPricing = X.strPricing
	INTO #tmpUpdateDispatch
	FROM( 
		SELECT 
			A.intSiteID 
			,D.intContractId
			,intItemId = ISNULL(D.intSubstituteProductID,D.intProductID)
			,dblQuantity = CASE WHEN ISNULL(D.dblMinimumQuantity,0) = 0 THEN D.dblQuantity ELSE D.dblMinimumQuantity END
			,intEntityCustomerId = C.intEntityId
			,A.intLocationId
			,D.dtmRequestedDate
			,intTaxGroupId = CASE WHEN A.ysnTaxable = 1 THEN A.intTaxStateID ELSE NULL END
			,dblPriceAdjustment = ISNULL(A.dblPriceAdjustment,0.0)
			,A.intCompanyLocationPricingLevelId
			,ysnTaxable = ISNULL(A.ysnTaxable,0)
		FROM tblTMSite A
		INNER JOIN tblTMCustomer B
			ON A.intCustomerID = B.intCustomerID
		INNER JOIN tblARCustomer C
			ON B.intCustomerNumber = C.intEntityId
		INNER JOIN tblTMDispatch D 
			ON A.intSiteID = D.intSiteID 
		INNER JOIN tblSMTerm E
			ON D.intDeliveryTermID = E.intTermID
				AND E.intBalanceDue <> 0
		WHERE D.ysnLockPrice = 0
	) Z
	CROSS APPLY 
	(
		SELECT strPricing,dblPrice
							FROM [dbo].[fnTMGetItemPricingDetails](
							 Z.intItemId
							,Z.intEntityCustomerId
							,Z.intLocationId
							,NULL /*--@ItemUOMId*/
							,NULL /*--@CurrencyId*/
							,Z.dtmRequestedDate
							,Z.dblQuantity
							,NULL
							,Z.intContractId
							,NULL
							,NULL
							,NULL
							,NULL
							,NULL
							,NULL
							,NULL /*--@ItemPricingOnly			BIT*/
							,0 /*--@ExcludeContractPricing*/
							,NULL
							,NULL
							,NULL
							,NULL
							,NULL
							,Z.intCompanyLocationPricingLevelId
							,NULL
							,NULL
							,NULL /*--TermId*/
							,NULL /*--@GetAllAvailablePricing*/
							)
	) X

	IF OBJECT_ID('tempdb..#tmpUpdateDispatch1') IS NOT NULL DROP TABLE #tmpUpdateDispatch1
	SELECT 
		*
		,dblTotalTax = dbo.[fnTMGetItemTotalTaxForCustomer](intItemId
															,intEntityCustomerId
															,dtmRequestedDate
															,dblPrice
															,dblQuantity
															,intTaxGroupId
															,intLocationId
															,NULL
															,1
															,ysnTaxable
															,intSiteID
															,NULL /*--@FreightTermId*/
															,NULL /*--@CardId*/
															,NULL /*---@VehicleId*/
															,0 /*-- @DisregardExemptionSetup*/
														   )
		,dblFinalPrice = CASE WHEN strPricing = 'Inventory - Standard Pricing' THEN dblPrice + ISNULL(dblPriceAdjustment,0) ELSE dblPrice END
	INTO #tmpUpdateDispatch1
	FROM #tmpUpdateDispatch


	UPDATE tblTMDispatch
	SET 
		dblPrice = dblFinalPrice
		,strPricingMethod = CASE WHEN A.strPricing = 'Inventory - Standard Pricing' THEN 'Regular' 
								 WHEN A.strPricing LIKE '%Contracts%' THEN 'Contract'
								 ELSE 'Special' END
		,dblTotal = (A.dblFinalPrice * A.dblQuantity) + ISNULL(A.dblTotalTax,0.0)
		,intConcurrencyId = ISNULL(intConcurrencyId,0) + 1
	FROM #tmpUpdateDispatch1 A
	WHERE tblTMDispatch.intSiteID = A.intSiteID
		AND DATEADD(DAY, DATEDIFF(DAY, 0, tblTMDispatch.dtmRequestedDate), 0)  >  DATEADD(DAY, DATEDIFF(DAY, 0, GETDATE()), 0) 


END