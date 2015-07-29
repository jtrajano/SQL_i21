CREATE PROCEDURE [dbo].[uspTRGetCustomerFreight]
	 @intEntityCustomerId AS INT,
	 @intItemId AS INT,
	 @intSupplyPointId AS INT,
	 @intShipViaId as int,
	 @intShipToId as int,
	 @dblGallons as float,
	 @dtmInvoiceDate as DATETIME, 
	 @dblInvocieFreightRate float OUTPUT,
	 @dblReceiptFreightRate float OUTPUT,
	 @dblSurchargeRate float OUTPUT
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

DECLARE @ErrorMessage NVARCHAR(4000);
DECLARE @ErrorSeverity INT;
DECLARE @ErrorState INT;
DECLARE @freight float,
        @intCategoryid int,
        @ysnFreightOnly bit,
        @strFreightType nvarchar(50),
		@intEntityShipViaId int,
		@intMiles int,
		@dblRate float,
		@ysnFreightInPrice bit,
		@dblMinimumUnits float,
		@dblCostRatePerUnit float,
		@dblInvoiceRatePerUnit float;

BEGIN TRY

     select @intCategoryid = intCategoryId from tblICItem where intItemId = @intItemId
     IF @intCategoryid IS NULL 
     BEGIN
		RAISERROR('Category is not setup for Item', 16, 1);
	 END
	 
	 select top 1 @ysnFreightOnly = CF.ysnFreightOnly,
	              @strFreightType = CF.strFreightType,
	  		       @intEntityShipViaId = CF.intShipViaId,
	  		       @intMiles = CF.dblFreightMiles,
	  		       @dblRate = CF.dblFreightRate,
	  		       @ysnFreightInPrice = CF.ysnFreightInPrice, 
	  		       @dblMinimumUnits = CF.dblMinimumUnits
	 from tblARCustomerFreightXRef CF 
	          where CF.intEntityCustomerId = @intEntityCustomerId 
	      	         and CF.intSupplyPointId = @intSupplyPointId
	  			     and CF.intCategoryId = @intCategoryid
                     and CF.intEntityLocationId = @intShipToId
     IF (isNull(@dblMinimumUnits,0) > isNull(@dblGallons,0) )
     BEGIN
	     RAISERROR('Gallons less than Minimum Freight Units' , 16, 1);
	 END
	 
	 IF isNull(@strFreightType,0) = 'Rate'
	 BEGIN
	     set @dblInvocieFreightRate = isNull(@dblRate,0)
		 set @dblCostRatePerUnit = isNull(@dblRate,0)
	     set @dblSurchargeRate = 0
	     return;
	 END
     IF isNull(@strFreightType,0) = 'Miles'
	 BEGIN
	     IF (isNull(@intEntityShipViaId,0) != @intShipViaId )
         BEGIN
	        RAISERROR('ShipVia is not found in Terminal To Customer Freight' , 16, 1);
	     END
	 
	     select @dblCostRatePerUnit =TM.dblCostRatePerUnit,@dblInvoiceRatePerUnit = TM.dblInvoiceRatePerUnit from tblEntityTariff TA
	                 join tblEntityTariffCategory TC on TA.intEntityTariffId = TC.intEntityTariffId					   
	  			      left join tblEntityTariffMileage TM on TM.intEntityTariffId = TC.intEntityTariffId
	  			      where TM.intFromMiles >= @intMiles 
				        and TM.intToMiles <= @intMiles
	  			            and TA.intEntityId = @intEntityShipViaId
	  					    and TC.intCategoryId = @intCategoryid
	 
	     select Top 1 @dblSurchargeRate=FS.dblFuelSurcharge from tblEntityTariff TA
	                 join tblEntityTariffCategory TC on TA.intEntityTariffId = TC.intEntityTariffId
	  			      left join tblEntityTariffFuelSurcharge FS on FS.intEntityTariffId = TC.intEntityTariffId				   
	  			      where TA.intEntityId = @intEntityShipViaId
	  				    	 and TC.intCategoryId = @intCategoryid
	  				    	 and FS.dtmEffectiveDate >= @dtmInvoiceDate
	  			      order by FS.dtmEffectiveDate DESC	  
	     set @dblInvocieFreightRate = @dblInvoiceRatePerUnit;
		 set @dblReceiptFreightRate = @dblCostRatePerUnit;
	   return;
	 END
       


END TRY
BEGIN CATCH
	SELECT 
		@ErrorMessage = ERROR_MESSAGE(),
		@ErrorSeverity = ERROR_SEVERITY(),
		@ErrorState = ERROR_STATE();

	-- Use RAISERROR inside the CATCH block to return error
	-- information about the original error that caused
	-- execution to jump to the CATCH block.
	RAISERROR (
		@ErrorMessage, -- Message text.
		@ErrorSeverity, -- Severity.
		@ErrorState -- State.
	);
END CATCH