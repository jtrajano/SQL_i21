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
	DECLARE @ysnSummaryByCard					BIT
	DECLARE @ysnSummaryByProduct				BIT
	DECLARE @ysnSummaryByCardProd				BIT
	DECLARE @ysnSummaryByVehicle				BIT
	DECLARE @ysnSummaryByMiscellaneous			BIT
	DECLARE @ysnDepartmentGrouping				BIT
	DECLARE @ysnSummaryByDepartment				BIT
	DECLARE @ysnSummaryByDeptCardProd			BIT
	DECLARE @ysnSummaryByDeptVehicleProd		BIT
	DECLARE @ysnPrintTimeOnInvoices				BIT
	DECLARE @ysnPrintTimeOnReports				BIT
	DECLARE @ysnPrintMiscellaneous				BIT

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
	WHERE strInvoiceNumberHistory = @strInvoiceNumber

	--SELECT @@ROWCOUNT
	
		
END