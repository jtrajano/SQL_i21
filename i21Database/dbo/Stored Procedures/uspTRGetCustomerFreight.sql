CREATE PROCEDURE [dbo].[uspTRGetCustomerFreight]
	 @intEntityCustomerId AS INT = NULL,
	 @intItemId AS INT,
	 @strZipCode NVARCHAR (MAX),
	 @intShipViaId as int,
	 @intShipToId as int = NULL,
	 @dblReceiptGallons as decimal(18,6),
	 @dblInvoiceGallons as decimal(18,6),
	 @dtmReceiptDate as DATETIME,
	 @dtmInvoiceDate as DATETIME, 
	 @ysnToBulkPlant as bit,
	 @dblInvoiceFreightRate decimal(18,6) OUTPUT,
	 @dblReceiptFreightRate decimal(18,6) OUTPUT,
	 @dblReceiptSurchargeRate decimal(18,6) OUTPUT,
	 @dblInvoiceSurchargeRate decimal(18,6) OUTPUT,
	 @ysnFreightInPrice bit OUTPUT,
	 @ysnFreightOnly bit OUTPUT,
	 @dblMinimumUnitsIn decimal(18,6) OUTPUT,
	 @dblMinimumUnitsOut decimal(18,6) OUTPUT
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
        @strFreightType nvarchar(50),
		@intEntityShipViaId int,
		@intMiles int,
		@intTariffType int,
		@dblFreightRateOut decimal(18,6),
		@dblFreightRateIn decimal(18,6),
		@dblSurchargeRateIn decimal(18,6),
		@dblSurchargeRateOut decimal(18,6),
		@dblMinimumUnits decimal(18,6),
		@dblCostRatePerUnit decimal(18,6),
		@dblInvoiceRatePerUnit decimal(18,6),
		@intFreightXRefId int = NULL;

BEGIN TRY
set @dblInvoiceFreightRate = 0;
set @dblReceiptFreightRate = 0;
set @dblReceiptSurchargeRate =0;
set @dblInvoiceSurchargeRate =0;

SET @dblMinimumUnitsIn = 0
SET	@dblMinimumUnitsOut = 0

     select @intCategoryid = intCategoryId from tblICItem where intItemId = @intItemId
     IF @intCategoryid IS NULL 
     BEGIN
		RAISERROR('Category is not setup for Item', 16, 1);
	 END

	 IF @ysnToBulkPlant = 0
	 BEGIN
	    select top 1 @intFreightXRefId = CF.intFreightXRefId,
					@ysnFreightOnly = CF.ysnFreightOnly,
	                @strFreightType = CF.strFreightType,
	           		@intEntityShipViaId = CF.intShipViaId,
	           		@intMiles = convert(int,CF.dblFreightMiles),
					@dblFreightRateIn = ISNULL(CF.dblFreightRateIn, 0),
	           		@dblFreightRateOut = ISNULL(CF.dblFreightRate, 0),
	           		@ysnFreightInPrice = CF.ysnFreightInPrice, 
					@dblMinimumUnitsIn =  ISNULL(CF.dblMinimumUnitsIn, 0),
	           		@dblMinimumUnitsOut = ISNULL(CF.dblMinimumUnits, 0),
					@intTariffType  = CF.intEntityTariffTypeId,
					@dblSurchargeRateOut = ISNULL(CF.dblSurchargeOut, 0)
	    from tblARCustomerFreightXRef CF 
		join tblARCustomer AR on AR.intEntityId = CF.intEntityCustomerId
	    where CF.intEntityCustomerId = @intEntityCustomerId 
	      	and CF.strZipCode = @strZipCode
	        and CF.intCategoryId = @intCategoryid
            and CF.intEntityLocationId = @intShipToId	
			and CF.intShipViaId = @intShipViaId

		IF(@intFreightXRefId IS NULL)
		BEGIN
			select top 1 @intFreightXRefId = CF.intFreightXRefId,
					@ysnFreightOnly = CF.ysnFreightOnly,
	                @strFreightType = CF.strFreightType,
	           		@intEntityShipViaId = CF.intShipViaId,
	           		@intMiles = convert(int,CF.dblFreightMiles),
					@dblFreightRateIn = ISNULL(CF.dblFreightRateIn, 0),
	           		@dblFreightRateOut = ISNULL(CF.dblFreightRate, 0),
	           		@ysnFreightInPrice = CF.ysnFreightInPrice, 
					@dblMinimumUnitsIn =  ISNULL(CF.dblMinimumUnitsIn, 0),
	           		@dblMinimumUnitsOut = ISNULL(CF.dblMinimumUnits, 0),
					@intTariffType  = CF.intEntityTariffTypeId,
					@dblSurchargeRateOut = ISNULL(CF.dblSurchargeOut, 0)
	    	from tblARCustomerFreightXRef CF 
			join tblARCustomer AR on AR.intEntityId = CF.intEntityCustomerId
	        where CF.intEntityCustomerId = @intEntityCustomerId 
	      	   	and CF.strZipCode = @strZipCode
	           	and CF.intCategoryId = @intCategoryid
                and CF.intEntityLocationId = @intShipToId
				and CF.intShipViaId IS NULL
		END
    END
	 ELSE
	 BEGIN
	    select top 1 @ysnFreightOnly = convert(bit,0),
	                @strFreightType = BPF.strFreightType,
	           		@intEntityShipViaId = BPF.intShipViaId,
	           		@intMiles = convert(int,BPF.dblFreightMiles),
					@dblFreightRateIn = ISNULL(BPF.dblFreightRateIn, 0),
	           		@dblFreightRateOut = ISNULL(BPF.dblFreightRate, 0),
	           		@ysnFreightInPrice = convert(bit,0), 
					@dblMinimumUnitsIn = ISNULL(BPF.dblMinimumUnitsIn, 0),
	           		@dblMinimumUnitsOut = ISNULL(BPF.dblMinimumUnits, 0),
					@intTariffType   = BPF.intEntityTariffTypeId,
					@dblSurchargeRateOut = ISNULL(BPF.dblSurchargeOut, 0)
	    from tblTRBulkPlantFreight BPF 
	            where BPF.strZipCode = @strZipCode
	           			and BPF.intCategoryId = @intCategoryid
                        and BPF.intCompanyLocationId = @intShipToId

     END



    --  IF ((isNull(@dblMinimumUnits,0) > isNull(@dblInvoiceGallons,0)) or (isNull(@dblMinimumUnits,0) > isNull(@dblReceiptGallons,0)) )
    --  BEGIN
	--      RAISERROR('Gallons less than Minimum Freight Units' , 16, 1);
	--  END
	 
	 IF isNull(@strFreightType,0) = '0'
	 BEGIN
	     GOTO _Exit
     END


	 -- SURCHAREGE OF RATE
	 IF ISNULL(@strFreightType,0) = 'Rate'
	 BEGIN

		SET @dblInvoiceFreightRate = @dblFreightRateOut
		SET @dblReceiptFreightRate = @dblFreightRateIn
		
		 SELECT TOP 1 @dblSurchargeRateIn=ISNULL(FS.dblFuelSurcharge, 0) 
		 FROM [tblEMEntityTariff] TA INNER JOIN [tblEMEntityTariffCategory] TC on TA.intEntityTariffId = TC.intEntityTariffId
	  		LEFT JOIN [tblEMEntityTariffFuelSurcharge] FS ON FS.intEntityTariffId = TC.intEntityTariffId				   
	  	 WHERE TA.intEntityId = ISNULL(@intEntityShipViaId,@intShipViaId)
	  		AND TC.intCategoryId = @intCategoryid
			AND TA.dtmEffectiveDate <= @dtmReceiptDate
	  	    AND FS.dtmEffectiveDate <= @dtmReceiptDate
			AND TA.intEntityTariffTypeId = @intTariffType 
	  	 ORDER BY TA.dtmEffectiveDate DESC,FS.dtmEffectiveDate DESC

		SET @dblReceiptSurchargeRate = @dblSurchargeRateIn
	
		IF(@dblSurchargeRateOut != 0)
		BEGIN
			SET @dblInvoiceSurchargeRate = @dblSurchargeRateOut
		END
		ELSE 
		BEGIN
			SET @dblInvoiceSurchargeRate = @dblSurchargeRateIn
		END
	
	 END

     IF isNull(@strFreightType,0) = 'Miles'
	 BEGIN
	

		 IF @ysnToBulkPlant = 0
		    BEGIN
	 
	           select top 1 @dblInvoiceRatePerUnit = TM.dblInvoiceRatePerUnit from [tblEMEntityTariff] TA
	                       join [tblEMEntityTariffCategory] TC on TA.intEntityTariffId = TC.intEntityTariffId					   
	  	       		      left join [tblEMEntityTariffMileage] TM on TM.intEntityTariffId = TC.intEntityTariffId
	  	       		      where (@intMiles  >= TM.intFromMiles 
		       		        and @intMiles  <= TM.intToMiles)
	  	       		            and TA.intEntityId = isNull(@intEntityShipViaId,@intShipViaId)
	  	       				    and TC.intCategoryId = @intCategoryid
								and TA.dtmEffectiveDate <= @dtmInvoiceDate
								and TA.intEntityTariffTypeId = @intTariffType 
	 	                   order by TA.dtmEffectiveDate DESC
			   
			   select top 1 @dblCostRatePerUnit =TM.dblCostRatePerUnit from [tblEMEntityTariff] TA
	                       join [tblEMEntityTariffCategory] TC on TA.intEntityTariffId = TC.intEntityTariffId					   
	  	       		      left join [tblEMEntityTariffMileage] TM on TM.intEntityTariffId = TC.intEntityTariffId
	  	       		      where (@intMiles  >= TM.intFromMiles 
		       		        and @intMiles  <= TM.intToMiles)
	  	       		            and TA.intEntityId = isNull(@intEntityShipViaId,@intShipViaId)
	  	       				    and TC.intCategoryId = @intCategoryid
								and TA.dtmEffectiveDate <= @dtmReceiptDate
								and TA.intEntityTariffTypeId = @intTariffType 
	 	                   order by TA.dtmEffectiveDate DESC

	           select Top 1 @dblInvoiceSurchargeRate=FS.dblFuelSurcharge from [tblEMEntityTariff] TA
	                       join [tblEMEntityTariffCategory] TC on TA.intEntityTariffId = TC.intEntityTariffId
	  	       		      left join [tblEMEntityTariffFuelSurcharge] FS on FS.intEntityTariffId = TC.intEntityTariffId				   
	  	       		      where TA.intEntityId = isNull(@intEntityShipViaId,@intShipViaId)
	  	       			    	 and TC.intCategoryId = @intCategoryid
								 and TA.dtmEffectiveDate <= @dtmInvoiceDate
	  	       			    	 and FS.dtmEffectiveDate <= @dtmInvoiceDate
								 and TA.intEntityTariffTypeId = @intTariffType 
	  	       		      order by TA.dtmEffectiveDate DESC,FS.dtmEffectiveDate DESC	  
		       
		       select Top 1 @dblReceiptSurchargeRate=FS.dblFuelSurcharge from [tblEMEntityTariff] TA
	                       join [tblEMEntityTariffCategory] TC on TA.intEntityTariffId = TC.intEntityTariffId
	  	       		      left join [tblEMEntityTariffFuelSurcharge] FS on FS.intEntityTariffId = TC.intEntityTariffId				   
	  	       		      where TA.intEntityId = isNull(@intEntityShipViaId,@intShipViaId)
	  	       			    	 and TC.intCategoryId = @intCategoryid
								 and TA.dtmEffectiveDate <= @dtmReceiptDate
	  	       			    	 and FS.dtmEffectiveDate <= @dtmReceiptDate
								 and TA.intEntityTariffTypeId = @intTariffType 
	  	       		      order by TA.dtmEffectiveDate DESC,FS.dtmEffectiveDate DESC	
             END
		 ELSE
		     BEGIN
			      select top 1 @dblInvoiceRatePerUnit = TM.dblInvoiceRatePerUnit from [tblEMEntityTariff] TA
	                            join [tblEMEntityTariffCategory] TC on TA.intEntityTariffId = TC.intEntityTariffId					   
	  	            		      left join [tblEMEntityTariffMileage] TM on TM.intEntityTariffId = TC.intEntityTariffId
	  	            		      where (@intMiles  >= TM.intFromMiles 
		            		        and @intMiles  <= TM.intToMiles)
									and TA.dtmEffectiveDate <= @dtmInvoiceDate
	  	            		        and TA.intEntityId = isNull(@intEntityShipViaId,@intShipViaId)
	  	            				and TC.intCategoryId = @intCategoryid
									and TA.intEntityTariffTypeId = @intTariffType
                                   order by TA.dtmEffectiveDate DESC
				  
				   select top 1 @dblCostRatePerUnit =TM.dblCostRatePerUnit from [tblEMEntityTariff] TA
	                            join [tblEMEntityTariffCategory] TC on TA.intEntityTariffId = TC.intEntityTariffId					   
	  	            		      left join [tblEMEntityTariffMileage] TM on TM.intEntityTariffId = TC.intEntityTariffId
	  	            		      where (@intMiles  >= TM.intFromMiles 
		            		        and @intMiles  <= TM.intToMiles)
									and TA.dtmEffectiveDate <= @dtmReceiptDate
	  	            		        and TA.intEntityId = isNull(@intEntityShipViaId,@intShipViaId)
	  	            				and TC.intCategoryId = @intCategoryid
									and TA.intEntityTariffTypeId = @intTariffType
									order by TA.dtmEffectiveDate DESC
	 	            
	              select Top 1 @dblInvoiceSurchargeRate=FS.dblFuelSurcharge from [tblEMEntityTariff] TA
	                            join [tblEMEntityTariffCategory] TC on TA.intEntityTariffId = TC.intEntityTariffId
	  	            		      left join [tblEMEntityTariffFuelSurcharge] FS on FS.intEntityTariffId = TC.intEntityTariffId				   
	  	            		      where TA.intEntityId = isNull(@intEntityShipViaId,@intShipViaId)
	  	            			    	 and TC.intCategoryId = @intCategoryid
	  	            			    	 and FS.dtmEffectiveDate <= @dtmInvoiceDate
										 and TA.dtmEffectiveDate <= @dtmReceiptDate
										 and TA.intEntityTariffTypeId = @intTariffType
	  	            		      order by TA.dtmEffectiveDate DESC,FS.dtmEffectiveDate DESC	  
		            
		          select Top 1 @dblReceiptSurchargeRate=FS.dblFuelSurcharge from [tblEMEntityTariff] TA
	                            join [tblEMEntityTariffCategory] TC on TA.intEntityTariffId = TC.intEntityTariffId
	  	            		      left join [tblEMEntityTariffFuelSurcharge] FS on FS.intEntityTariffId = TC.intEntityTariffId				   
	  	            		      where TA.intEntityId = isNull(@intEntityShipViaId,@intShipViaId)
	  	            			    	 and TC.intCategoryId = @intCategoryid
	  	            			    	 and FS.dtmEffectiveDate <= @dtmReceiptDate
										 and TA.dtmEffectiveDate <= @dtmReceiptDate
										 and TA.intEntityTariffTypeId = @intTariffType
	  	            		      order by TA.dtmEffectiveDate DESC,FS.dtmEffectiveDate DESC	
			 END
	     set @dblInvoiceFreightRate = @dblInvoiceRatePerUnit;
		 set @dblReceiptFreightRate = @dblCostRatePerUnit;
	
	 END
     
_Exit:	   
--if @ysnFreightOnly = 1
--BEGIN
--    set @dblReceiptFreightRate = 0;
--	set @dblReceiptSurchargeRate = 0;
--END

if (@dblInvoiceFreightRate is null or @dblInvoiceFreightRate = 0)
BEGIN
    set @dblInvoiceFreightRate = 0;
	set @dblInvoiceSurchargeRate = 0;
END
if (@dblReceiptFreightRate is null or @dblReceiptFreightRate = 0)
BEGIN
    set @dblReceiptFreightRate = 0;
    set @dblReceiptSurchargeRate = 0;
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
    set @ysnFreightInPrice = convert(bit,0);
END

if (@ysnFreightOnly is null)
BEGIN
    set @ysnFreightOnly = convert(bit,0);
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