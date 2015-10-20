CREATE PROCEDURE [dbo].[uspTRGenerateQuotes]
	 @intCustomerGroupId AS INT,
	 @intCustomerId AS INT,
	 @dtmQuoteDate AS DATETIME,
	 @dtmEffectiveDate AS DATETIME,
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
		  right join vyuTRQuoteSelection QS on QS.intEntityCustomerId = CD.intEntityId
		   where CD.ysnQuote = 1
		         and QS.ysnQuote = 1
		         and (isNull(@intCustomerId ,0 ) = 0 or isNull(@intCustomerId ,0 ) = QS.intEntityCustomerId) 
                                                              or  (isNull(@intCustomerGroupId ,0 ) = 0 or isNull(@intCustomerGroupId ,0 ) = CG.intCustomerGroupId) 
          group by QS.intEntityCustomerId


select @total = count(*) from @DataForQuote;
set @incval = 1 
WHILE @incval <=@total 
BEGIN
   
   EXEC dbo.uspSMGetStartingNumber 56, @QuoteNumber OUTPUT 

   update @DataForQuote 
       set strQuoteNumber = @QuoteNumber
         where @incval = intId 
   SET @incval = @incval + 1;

END;


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
           ,[dbo].[fnTRGetRackPrice]    --[dblRackPrice]
		          (
		          @dtmEffectiveDate
		          ,QD.intSupplyPointId
		          ,QD.intItemId
		          ) AS dblRackPrice
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
	 join vyuTRQuoteSelection QD on QD.intEntityCustomerId = QS.intCustomerId
	 join tblEntityLocation EL on QS.intCustomerId = EL.intEntityId
     where QD.ysnQuote = 1

INSERT INTO @DataForDetailQuote
select QH.intQuoteHeaderId,QD.intQuoteDetailId from @DataForQuote QT 
             JOIN tblTRQuoteHeader QH on QH.strQuoteNumber = QT.strQuoteNumber          
             JOIN tblTRQuoteDetail QD on QH.intQuoteHeaderId = QD.intQuoteHeaderId
             
DECLARE @detailId as int;
select @total = count(*) from @DataForQuote;
set @incval = 1 
WHILE @incval <=@total 
BEGIN
   select @QuoteHeader =intQuoteHeaderId from @DataForQuote QS
                                       join tblTRQuoteHeader QH on QS.strQuoteNumber = QH.strQuoteNumber
                                    where @incval = intId 
   
   while  (select top 1 intDetailId from @DataForDetailQuote where intQuoteHeaderId = @QuoteHeader) IS NOT NULL
   BEGIN
   select top 1 @detailId= intDetailId from @DataForDetailQuote where intQuoteHeaderId = @QuoteHeader
   

   update tblTRQuoteDetail 
   SET dblDeviationAmount = (select top 1 SP.dblDeviation from tblARCustomerSpecialPrice SP where SP.intSpecialPriceId = intSpecialPriceId)      
       where intQuoteDetailId = @detailId

   update tblTRQuoteDetail 
   SET dblQuotePrice = dblDeviationAmount + dblRackPrice,
       dblMargin = dblDeviationAmount
       where intQuoteDetailId = @detailId
    
   delete from @DataForDetailQuote where intDetailId = @detailId
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