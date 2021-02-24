CREATE PROCEDURE [dbo].[uspCFSyncInvoiceFormat]
		@strInvoiceNumber NVARCHAR(MAX),
		@intCustomerId	  INT  
		AS 
BEGIN
	
	DECLARE @strInvoiceCycle					NVARCHAR(MAX)
	DECLARE @strPrimarySortOptions				NVARCHAR(MAX)
	DECLARE @strSecondarySortOptions			NVARCHAR(MAX)
	DECLARE @strPrintRemittancePage				NVARCHAR(MAX)
	DECLARE @strPrintPricePerGallon				NVARCHAR(MAX)
	DECLARE @strPrintSiteAddress				NVARCHAR(MAX)
	DECLARE @strDetailDisplay					NVARCHAR(MAX)
	DECLARE @ysnSummaryByCard					BIT
	DECLARE @ysnSummaryByDepartmentProduct		BIT
	DECLARE @ysnSummaryByProduct				BIT
	DECLARE @ysnSummaryByCardProd				BIT
	DECLARE @ysnSummaryByVehicle				BIT
	DECLARE @ysnSummaryByMiscellaneous			BIT
	DECLARE @ysnDepartmentGrouping				BIT
	DECLARE @ysnSummaryByDepartment				BIT
	DECLARE @ysnSummaryByDeptCardProd			BIT
	DECLARE @ysnSummaryByDeptVehicleProd		BIT
	DECLARE @ysnSummaryByDriverPin				BIT
	DECLARE @ysnPrintTimeOnInvoices				BIT
	DECLARE @ysnPrintTimeOnReports				BIT
	DECLARE @ysnPrintMiscellaneous				BIT
	DECLARE @ysnShowDriverPinDescriptionOnly	BIT
	DECLARE @ysnShowVehicleDescriptionOnly		BIT
	DECLARE @ysnPageBreakByPrimarySortOrder		BIT
	DECLARE @ysnSummaryByDeptDriverPinProd		BIT
	DECLARE @strDepartmentGrouping				NVARCHAR(MAX)
	
	


	--===GET LATEST ACCOUNT INVOICE FORMATTING===--
	SELECT TOP 1
	 @strInvoiceCycle					 =  (SELECT TOP 1 strInvoiceCycle FROM tblCFInvoiceCycle)			
	,@strPrimarySortOptions				 =  strPrimarySortOptions		
	,@strSecondarySortOptions			 =  strSecondarySortOptions	
	,@strPrintRemittancePage			 =  strPrintRemittancePage		
	,@strPrintPricePerGallon			 =  strPrintPricePerGallon		
	,@strPrintSiteAddress				 =  strPrintSiteAddress		
	,@ysnSummaryByCard					 =  ysnSummaryByCard			
	,@ysnSummaryByDepartmentProduct		 =  ysnSummaryByDepartmentProduct
	,@ysnSummaryByProduct				 =  ysnSummaryByProduct		
	,@ysnSummaryByCardProd				 =  ysnSummaryByCardProd		
	,@ysnSummaryByVehicle				 =  ysnSummaryByVehicle		
	,@ysnSummaryByMiscellaneous			 =  ysnSummaryByMiscellaneous	
	,@ysnDepartmentGrouping				 =  ysnDepartmentGrouping		
	,@ysnSummaryByDepartment			 =  ysnSummaryByDepartment		
	,@ysnSummaryByDeptCardProd			 =  ysnSummaryByDeptCardProd	
	,@ysnSummaryByDeptVehicleProd		 =  ysnSummaryByDeptVehicleProd
	,@ysnPrintTimeOnInvoices			 =  ysnPrintTimeOnInvoices		
	,@ysnPrintTimeOnReports				 =  ysnPrintTimeOnReports		
	,@ysnPrintMiscellaneous				 =  ysnPrintMiscellaneous
	,@ysnSummaryByDriverPin				 =  ysnSummaryByDriverPin
	,@strDetailDisplay					 =  strDetailDisplay
	,@ysnShowDriverPinDescriptionOnly	 =  ysnShowDriverPinDescriptionOnly
	,@ysnShowVehicleDescriptionOnly		 =  ysnShowVehicleDescriptionOnly
	,@ysnPageBreakByPrimarySortOrder	 =  ysnPageBreakByPrimarySortOrder
	,@ysnSummaryByDeptDriverPinProd		 =  ysnSummaryByDeptDriverPinProd
	,@strDepartmentGrouping	 			 =  strDepartmentGrouping
	
	
	FROM tblCFAccount
	WHERE intCustomerId = @intCustomerId
	
	--===UPDATE STAGING TABLE===--
	UPDATE tblCFInvoiceHistoryStagingTable  
	SET
	 strInvoiceCycle				  = 	 @strInvoiceCycle								 
	,strPrimarySortOptions			  = 	 @strPrimarySortOptions			
	,strSecondarySortOptions		  = 	 @strSecondarySortOptions		
	,strPrintRemittancePage			  = 	 @strPrintRemittancePage		
	,strPrintPricePerGallon			  = 	 @strPrintPricePerGallon		
	,strPrintSiteAddress			  = 	 @strPrintSiteAddress		
	,strDetailDisplay				  =		 @strDetailDisplay
	,ysnSummaryByCard				  = 	 @ysnSummaryByCard	
	,ysnSummaryByDepartmentProduct	  = 	 @ysnSummaryByDepartmentProduct	
	,ysnSummaryByProduct			  = 	 @ysnSummaryByProduct			
	,ysnSummaryByCardProd			  = 	 @ysnSummaryByCardProd			
	,ysnSummaryByVehicle			  = 	 @ysnSummaryByVehicle			
	,ysnSummaryByMiscellaneous		  = 	 @ysnSummaryByMiscellaneous		
	,ysnDepartmentGrouping			  = 	 @ysnDepartmentGrouping			
	,ysnSummaryByDepartment			  = 	 @ysnSummaryByDepartment		
	,ysnSummaryByDeptCardProd		  = 	 @ysnSummaryByDeptCardProd		
	,ysnSummaryByDeptVehicleProd	  = 	 @ysnSummaryByDeptVehicleProd	
	,ysnPrintTimeOnInvoices			  = 	 @ysnPrintTimeOnInvoices		
	,ysnPrintTimeOnReports			  = 	 @ysnPrintTimeOnReports			
	,ysnPrintMiscellaneous			  = 	 @ysnPrintMiscellaneous			
	,ysnShowDriverPinDescriptionOnly  =		 @ysnShowDriverPinDescriptionOnly
	,ysnShowVehicleDescriptionOnly	  =		 @ysnShowVehicleDescriptionOnly
	,ysnSummaryByDriverPin			  =		 @ysnSummaryByDriverPin
	,ysnPageBreakByPrimarySortOrder	  =		 @ysnPageBreakByPrimarySortOrder
	,ysnSummaryByDeptDriverPinProd    =		 @ysnSummaryByDeptDriverPinProd
	,strDepartmentGrouping	  		  = 	 @strDepartmentGrouping
	WHERE strInvoiceNumberHistory = @strInvoiceNumber

	UPDATE tblCFInvoiceHistoryStagingTable  
	SET
	strDetailDisplayValue			= CASE WHEN LOWER(strDetailDisplay) = 'card'
									THEN strCardNumber + ' - ' + strCardDescription

								  WHEN LOWER(strDetailDisplay) = 'vehicle'
									THEN (CASE	
											WHEN ISNULL(strVehicleNumber,'') != '' THEN 
												CASE WHEN ISNULL(ysnShowVehicleDescriptionOnly,0) = 0 THEN strVehicleNumber + ' - ' + strVehicleDescription ELSE strVehicleDescription END
											ELSE (CASE	
													WHEN LOWER(strPrimarySortOptions) = 'card' THEN 
														CASE WHEN ISNULL(ysnShowDriverPinDescriptionOnly,0) = 0 THEN strDriverPinNumber + ' - ' + strDriverDescription ELSE strDriverDescription END
													WHEN LOWER(strPrimarySortOptions) = 'driverpin' THEN strCardNumber + ' - ' + strCardDescription
													WHEN LOWER(strPrimarySortOptions) = 'driver pin' THEN strCardNumber + ' - ' + strCardDescription
													WHEN LOWER(strPrimarySortOptions) = 'miscellaneous' THEN 
														CASE WHEN ISNULL(ysnShowDriverPinDescriptionOnly,0) = 0 THEN strDriverPinNumber + ' - ' + strDriverDescription ELSE strDriverDescription END
												  END)
										  END)

								  WHEN LOWER(strDetailDisplay) = 'driverpin' OR LOWER(strDetailDisplay) = 'driver pin' 
									THEN (CASE
											WHEN ISNULL(strDriverPinNumber,'') != '' THEN
												CASE WHEN ISNULL(ysnShowDriverPinDescriptionOnly,0) = 0 THEN strDriverPinNumber + ' - ' + strDriverDescription ELSE strDriverDescription END
											ELSE (CASE 
													WHEN LOWER(strPrimarySortOptions) = 'card' THEN CASE WHEN ISNULL(ysnShowVehicleDescriptionOnly,0) = 0 THEN strVehicleNumber + ' - ' + strVehicleDescription ELSE strVehicleDescription END
													WHEN LOWER(strPrimarySortOptions) = 'vehicle' THEN strCardNumber + ' - ' + strCardDescription
													WHEN LOWER(strPrimarySortOptions) = 'miscellaneous' THEN CASE WHEN ISNULL(ysnShowVehicleDescriptionOnly,0) = 0 THEN strVehicleNumber + ' - ' + strVehicleDescription ELSE strVehicleDescription END
												  END)
											END)
							 END
	,strDetailDisplayLabel = CASE WHEN LOWER(strDetailDisplay) = 'card'
									THEN 'Card'

								  WHEN LOWER(strDetailDisplay) = 'vehicle'
									THEN 'Vehicle'

								  WHEN LOWER(strDetailDisplay) = 'driverpin' OR LOWER(strDetailDisplay) = 'driver pin' 
									THEN  'Driver Pin'
							 END
	WHERE strInvoiceNumberHistory = @strInvoiceNumber

	--SELECT @@ROWCOUNT
	
		
END