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
	


	--===GET LATEST ACCOUNT INVOICE FORMATTING===--
	SELECT TOP 1
	 @strInvoiceCycle					 =  (SELECT TOP 1 strInvoiceCycle FROM tblCFInvoiceCycle)			
	,@strPrimarySortOptions				 =  strPrimarySortOptions		
	,@strSecondarySortOptions			 =  strSecondarySortOptions	
	,@strPrintRemittancePage			 =  strPrintRemittancePage		
	,@strPrintPricePerGallon			 =  strPrintPricePerGallon		
	,@strPrintSiteAddress				 =  strPrintSiteAddress		
	,@ysnSummaryByCard					 =  ysnSummaryByCard			
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
	WHERE strInvoiceNumberHistory = @strInvoiceNumber

	--SELECT @@ROWCOUNT
	
		
END