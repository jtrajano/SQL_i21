CREATE PROCEDURE [dbo].[uspTRGetCustomerFreight]
	 @intEntityCustomerId AS INT,
	 @intItemId AS INT,
	 @intSupplyPointId AS INT,
	 @intShipViaId as int,
	 @intShipToId as int,
	 @dblReceiptGallons as decimal(18,6),
	 @dblInvoiceGallons as decimal(18,6),
	 @dtmReceiptDate as DATETIME,
	 @dtmInvoiceDate as DATETIME, 
	 @dblInvoiceFreightRate decimal(18,6) OUTPUT,
	 @dblReceiptFreightRate decimal(18,6) OUTPUT,
	 @dblReceiptSurchargeRate decimal(18,6) OUTPUT,
	 @dblInvoiceSurchargeRate decimal(18,6) OUTPUT,
	 @ysnFreightInPrice bit OUTPUT
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

DECLARE @ErrorMessage NVARCHAR(4000);
DECLARE @ErrorSeverity INT;
DECLARE @ErrorState INT;
DECLARE @freight decimal(18,6),
        @intCategoryid int,
        @ysnFreightOnly bit,
        @strFreightType nvarchar(50),
		@intEntityShipViaId int,
		@intMiles int,
		@dblRate decimal(18,6),
		@dblMinimumUnits decimal(18,6),
		@dblCostRatePerUnit decimal(18,6),
		@dblInvoiceRatePerUnit decimal(18,6);

BEGIN TRY
set @dblInvoiceFreightRate = 0;
set @dblReceiptFreightRate = 0;
set @dblReceiptSurchargeRate =0;
set @dblInvoiceSurchargeRate =0;


     select @intCategoryid = intCategoryId from tblICItem where intItemId = @intItemId
     IF @intCategoryid IS NULL 
     BEGIN
		RAISERROR('Category is not setup for Item', 16, 1);
	 END
	 
	 select top 1 @ysnFreightOnly = CF.ysnFreightOnly,
	              @strFreightType = CF.strFreightType,
	  		       @intEntityShipViaId = CF.intShipViaId,
	  		       @intMiles = convert(int,CF.dblFreightMiles),
	  		       @dblRate = CF.dblFreightRate,
	  		       @ysnFreightInPrice = CF.ysnFreightInPrice, 
	  		       @dblMinimumUnits = CF.dblMinimumUnits
	 from tblARCustomerFreightXRef CF 
	          where CF.intEntityCustomerId = @intEntityCustomerId 
	      	         and CF.intSupplyPointId = @intSupplyPointId
	  			     and CF.intCategoryId = @intCategoryid
                     and CF.intEntityLocationId = @intShipToId
     IF ((isNull(@dblMinimumUnits,0) > isNull(@dblInvoiceGallons,0)) or (isNull(@dblMinimumUnits,0) > isNull(@dblReceiptGallons,0)) )
     BEGIN
	     RAISERROR('Gallons less than Minimum Freight Units' , 16, 1);
	 END
	 
	 IF isNull(@strFreightType,0) = 'Rate'
	 BEGIN
	     set @dblInvoiceFreightRate = isNull(@dblRate,0)
		 set @dblReceiptFreightRate = isNull(@dblRate,0)
	     set @dblReceiptSurchargeRate = 0
		 set @dblInvoiceSurchargeRate = 0
	     return;
	 END
     IF isNull(@strFreightType,0) = 'Miles'
	 BEGIN
	     IF (isNull(@intEntityShipViaId,0) != @intShipViaId )
         BEGIN
	        RAISERROR('ShipVia is not found in Terminal To Customer Freight' , 16, 1);
	     END
	 
	     select top 1 @dblCostRatePerUnit =TM.dblCostRatePerUnit,@dblInvoiceRatePerUnit = TM.dblInvoiceRatePerUnit from tblEntityTariff TA
	                 join tblEntityTariffCategory TC on TA.intEntityTariffId = TC.intEntityTariffId					   
	  			      left join tblEntityTariffMileage TM on TM.intEntityTariffId = TC.intEntityTariffId
	  			      where (TM.intFromMiles >= @intMiles 
				        or TM.intToMiles <= @intMiles)
	  			            and TA.intEntityId = @intEntityShipViaId
	  					    and TC.intCategoryId = @intCategoryid
	 
	     select Top 1 @dblInvoiceSurchargeRate=FS.dblFuelSurcharge from tblEntityTariff TA
	                 join tblEntityTariffCategory TC on TA.intEntityTariffId = TC.intEntityTariffId
	  			      left join tblEntityTariffFuelSurcharge FS on FS.intEntityTariffId = TC.intEntityTariffId				   
	  			      where TA.intEntityId = @intEntityShipViaId
	  				    	 and TC.intCategoryId = @intCategoryid
	  				    	 and FS.dtmEffectiveDate <= @dtmInvoiceDate
	  			      order by FS.dtmEffectiveDate DESC	  

		  select Top 1 @dblReceiptSurchargeRate=FS.dblFuelSurcharge from tblEntityTariff TA
	                 join tblEntityTariffCategory TC on TA.intEntityTariffId = TC.intEntityTariffId
	  			      left join tblEntityTariffFuelSurcharge FS on FS.intEntityTariffId = TC.intEntityTariffId				   
	  			      where TA.intEntityId = @intEntityShipViaId
	  				    	 and TC.intCategoryId = @intCategoryid
	  				    	 and FS.dtmEffectiveDate <= @dtmReceiptDate
	  			      order by FS.dtmEffectiveDate DESC	

	     set @dblInvoiceFreightRate = @dblInvoiceRatePerUnit;
		 set @dblReceiptFreightRate = @dblCostRatePerUnit;
	   return;
	 END
       
if (@dblInvoiceFreightRate is null)
BEGIN
    set @dblInvoiceFreightRate = 0;
END
if (@dblReceiptFreightRate is null)
BEGIN
    set @dblReceiptFreightRate = 0;
END
if (@dblReceiptSurchargeRate is null)
BEGIN
    set @dblReceiptSurchargeRate = 0;
END
if (@dblInvoiceSurchargeRate is null)
BEGIN
    set @dblInvoiceSurchargeRate = 0;
END


if (@ysnFreightInPrice is null)
BEGIN
    set @ysnFreightInPrice = 0;
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