CREATE PROCEDURE [dbo].[uspTRGenerateQuotes]
	 @intCustomerGroupId AS INT,
	 @intCustomerId AS INT,
	 @dtmQuoteDate AS DATETIME,
	 @dtmEffectiveDate AS DATETIME,
	 @ysnConfirm as bit,
	 @ysnVoid as bit,
	 @intBegQuoteId int OUTPUT,
	 @intEndQuoteId int OUTPUT
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

DECLARE @ErrorMessage NVARCHAR(4000);
DECLARE @ErrorSeverity INT;
DECLARE @ErrorState INT;

BEGIN TRY

DECLARE @DataForQuote TABLE(
	intId INT IDENTITY PRIMARY KEY CLUSTERED
    ,intCustomerId INT
	,strQuoteNumber nvarchar(50) COLLATE Latin1_General_CI_AS NULL
    
)

DECLARE @DataForDetailQuote TABLE(
	intDetailId INT IDENTITY PRIMARY KEY CLUSTERED
    ,intQuoteDetailId INT
	,intQuoteHeaderId INT
    
)

DECLARE @total int,
        @QuoteHeader int,
		@strMinQuote nvarchar(50),
		@strMaxQuote nvarchar(50),
        @QuoteNumber nvarchar(50),
        @incval int;

INSERT INTO @DataForQuote
            (intCustomerId
			,strQuoteNumber)
select intEntityCustomerId,NULL from tblARCustomerGroup CG
          join tblARCustomerGroupDetail CD on CG.intCustomerGroupId = CD.intCustomerGroupId
		  join tblEntityLocation EL on CD.intEntityId = EL.intEntityId
		  right join vyuTRQuoteSelection QS on QS.intEntityCustomerId = CD.intEntityId and QS.intEntityCustomerLocationId = EL.intEntityLocationId
		  
		   where CD.ysnQuote = 1
		         and QS.ysnQuote = 1
		         and (CG.intCustomerGroupId = @intCustomerGroupId or isNull(@intCustomerGroupId,0) = 0)
                 and (isNull(@intCustomerId ,0 ) = 0 or @intCustomerId = QS.intEntityCustomerId)
          group by QS.intEntityCustomerId




select @total = count(*) from @DataForQuote;
set @incval = 1 
WHILE @incval <=@total 
BEGIN
   
   if @ysnConfirm = 1
      BEGIN
         update tblTRQuoteHeader
	     set strQuoteStatus = 'Confirmed'
	     where intEntityCustomerId = (select top 1 intCustomerId from @DataForQuote where intId = @incval) and strQuoteStatus = 'UnConfirmed'      
      END
   else
       BEGIN
            if @ysnVoid = 1
               BEGIN
                  update tblTRQuoteHeader
                 set strQuoteStatus = 'Void'
                 where intEntityCustomerId = (select top 1 intCustomerId from @DataForQuote where intId = @incval) and strQuoteStatus = 'Confirmed'      
               END
            else
                BEGIN
                    EXEC dbo.uspSMGetStartingNumber 56, @QuoteNumber OUTPUT 
                     update @DataForQuote 
                     set strQuoteNumber = @QuoteNumber
                       where @incval = intId 
               END
	   END
   SET @incval = @incval + 1;

END;

if @ysnConfirm = 1 or @ysnVoid = 1
   BEGIN
       set @intBegQuoteId = 0;
       set @intEndQuoteId = 0;
       RETURN;
   END

INSERT INTO [dbo].[tblTRQuoteHeader]
           ([strQuoteNumber]
           ,[strQuoteStatus]
           ,[dtmQuoteDate]
           ,[dtmQuoteEffectiveDate]
           ,[intEntityCustomerId]         
           ,[strQuoteComments]
           ,[strCustomerComments]
           ,[intConcurrencyId])
select
      QS.strQuoteNumber  --[strQuoteNumber]
	 ,'UnConfirmed'	--[strQuoteStatus]
	 ,@dtmQuoteDate	--[dtmQuoteDate]
	 ,@dtmEffectiveDate	--[dtmQuoteEffectiveDate]
	 ,QS.intCustomerId	--[intEntityCustomerId]
	 ,NULL	--[strQuoteComments]
	 ,NULL	--[strCustomerComments]
	 ,1   	--[intConcurrencyId]
	 from @DataForQuote QS

INSERT INTO [dbo].[tblTRQuoteDetail]
           ([intQuoteHeaderId]
           ,[intItemId]
           ,[intTerminalId]
           ,[intSupplyPointId]
           ,[dblRackPrice]
           ,[dblDeviationAmount]
           ,[dblTempAdjustment]
           ,[dblFreightRate]
           ,[dblQuotePrice]
           ,[dblMargin]
           ,[dblQtyOrdered]
           ,[dblExtProfit]
           ,[dblTax]
           ,[intShipToLocationId]
		   ,[intSpecialPriceId]
           ,[intConcurrencyId])
 select
           QH.intQuoteHeaderId --[intQuoteHeaderId]
           ,QD.intItemId --[intItemId]
           ,(select SP.intEntityVendorId from vyuTRSupplyPointView SP where QD.intSupplyPointId = SP.intSupplyPointId) --[intTerminalId]
           ,QD.intSupplyPointId --[intSupplyPointId]
		   ,NULL --[dblRackPrice]
		   ,NULL  --[dblDeveationAmount]    
           ,NULL --[dblTempAdjustment]
           ,NULL --[dblFreightRate]
           ,NULL --[dblQuotePrice]
           ,NULL --[dblMargin]
           ,1 --[dblQtyOrdered]
           ,NULL --[dblExtProfit]
           ,NULL --[dblTax]
           ,EL.intEntityLocationId --[intShipToLocationId]
		   ,[dbo].[fnARGetCustomerItemSpecialPriceId]  --[dblDeviationAmount]
                (
                   QD.intItemId			--@ItemId
                  ,QS.intCustomerId 	--@CustomerId
                  ,NULL --@LocationId
                  ,(SELECT	TOP 1 
				  		IU.intItemUOMId											
				  		FROM dbo.tblICItemUOM IU 
				  		WHERE	IU.intItemId = QD.intItemId and IU.ysnStockUnit = 1				  
				  )		--@ItemUOMId
                  ,@dtmEffectiveDate				--@TransactionDate
                  ,1            		--@Quantity                                    
                  ,(select SP.intEntityVendorId from vyuTRSupplyPointView SP where QD.intSupplyPointId = SP.intSupplyPointId)					--@VendorId
                  ,QD.intSupplyPointId	--@SupplyPointId
                  ,NULL					--@LastCost
                  ,EL.intEntityLocationId 	--@ShipToLocationId
                  ,NULL					--@VendorLocationId
                  ) as intSpecialPriceId
           ,1 --[intConcurrencyId]
from @DataForQuote QS
     join tblTRQuoteHeader QH on QS.strQuoteNumber = QH.strQuoteNumber
	 join tblEntityLocation EL on QS.intCustomerId = EL.intEntityId
	 join vyuTRQuoteSelection QD on QD.intEntityCustomerId = QS.intCustomerId and QD.intEntityCustomerLocationId = EL.intEntityLocationId 
     where QD.ysnQuote = 1

INSERT INTO @DataForDetailQuote
select QD.intQuoteDetailId,QH.intQuoteHeaderId from @DataForQuote QT 
             JOIN tblTRQuoteHeader QH on QH.strQuoteNumber = QT.strQuoteNumber          
             JOIN tblTRQuoteDetail QD on QH.intQuoteHeaderId = QD.intQuoteHeaderId
             
DECLARE @detailId as int,
        @intSpecialPriceId as int,
        @dblRackPrice DECIMAL(18, 6),
		@dblDeviationAmount DECIMAL(18, 6);
select @total = count(*) from @DataForQuote;
set @incval = 1 
WHILE @incval <=@total 
BEGIN
   select @QuoteHeader =intQuoteHeaderId from @DataForQuote QS
                                       join tblTRQuoteHeader QH on QS.strQuoteNumber = QH.strQuoteNumber
                                    where @incval = intId 
   
   while  (select top 1 intQuoteDetailId from @DataForDetailQuote where intQuoteHeaderId = @QuoteHeader) IS NOT NULL
   BEGIN
        select top 1 @detailId= intQuoteDetailId from @DataForDetailQuote where intQuoteHeaderId = @QuoteHeader
        
        select @intSpecialPriceId = intSpecialPriceId from tblTRQuoteDetail where intQuoteDetailId = @detailId

		update tblTRQuoteDetail 
        SET dblRackPrice  = (select rackID = CASE	WHEN SP.strPriceBasis = 'R' THEN [dbo].[fnTRGetRackPrice]    --[dblRackPrice]
		                                                       (
		                                                       @dtmEffectiveDate
		                                                       ,(select top 1 intSupplyPointId from vyuTRSupplyPointView where intEntityVendorId = SP.intRackVendorId)
		                                                       ,SP.intRackItemId
		                                                       ) 
						                            WHEN SP.strPriceBasis = 'O' THEN [dbo].[fnTRGetRackPrice]    --[dblRackPrice]
		                                                       (
		                                                       @dtmEffectiveDate
		                                                       ,(select top 1 intSupplyPointId from vyuTRSupplyPointView where intEntityVendorId = SP.intEntityVendorId)
		                                                       ,SP.intItemId
		                                                       ) 

			                                    	END
		                       from tblARCustomerSpecialPrice SP  where SP.intSpecialPriceId = @intSpecialPriceId)		     
            where intQuoteDetailId = @detailId

        update tblTRQuoteDetail 
        SET dblDeviationAmount = (select top 1 SP.dblDeviation from tblARCustomerSpecialPrice SP where SP.intSpecialPriceId = @intSpecialPriceId)      
            where intQuoteDetailId = @detailId
        
        select @dblDeviationAmount=dblDeviationAmount,@dblRackPrice=dblRackPrice from tblTRQuoteDetail where intQuoteDetailId = @detailId
        
        update tblTRQuoteDetail 
        SET dblQuotePrice = @dblDeviationAmount + @dblRackPrice,
            dblMargin = @dblDeviationAmount
            where intQuoteDetailId = @detailId
         
        delete from @DataForDetailQuote where intQuoteDetailId = @detailId
   END     
   SET @incval = @incval + 1;


END;


select @strMinQuote = min(strQuoteNumber) ,@strMaxQuote = max(strQuoteNumber) from @DataForQuote

select @intBegQuoteId = intQuoteHeaderId from tblTRQuoteHeader where @strMinQuote = strQuoteNumber
select @intEndQuoteId = intQuoteHeaderId from tblTRQuoteHeader where @strMaxQuote = strQuoteNumber;

if @intBegQuoteId IS NULL
   BEGIN
    SET @intBegQuoteId = 0
   END
if @intEndQuoteId IS NULL
   BEGIN
    SET @intEndQuoteId = 0
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