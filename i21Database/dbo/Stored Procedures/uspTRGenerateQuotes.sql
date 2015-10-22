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

DECLARE @DataForReceiptHeader TABLE(
	intId INT IDENTITY PRIMARY KEY CLUSTERED
    ,intCustomerId INT
	,strQuoteNumber nvarchar(50) COLLATE Latin1_General_CI_AS NULL
    
)

INSERT INTO @DataForReceiptHeader
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
   
   if @ysnConfirm = 1
      BEGIN
         update tblTRQuoteHeader
	     set strQuoteStatus = 'Confirmed'
	     where intEntityCustomerId = (select top 1 intEntityCustomerId from @DataForQuote where intId = @incval) and strQuoteStatus = 'UnConfirmed'      
      END
   else
       BEGIN
            if @ysnVoid = 1
               BEGIN
                  update tblTRQuoteHeader
                 set strQuoteStatus = 'Void'
                 where intEntityCustomerId = (select top 1 intEntityCustomerId from @DataForQuote where intId = @incval) and strQuoteStatus = 'Confirmed'      
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
      NULL  --[strQuoteNumber]
	 ,'UnConfirmed'	--[strQuoteStatus]
	 ,@dtmQuoteDate	--[dtmQuoteDate]
	 ,@dtmEffectiveDate	--[dtmQuoteEffectiveDate]
	 ,NULL	--[intEntityCustomerId]
	 ,NULL	--[strQuoteComments]
	 ,NULL	--[strCustomerComments]
	 ,1   	--[intConcurrencyId]

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
           ,[intConcurrencyId])
 select
           NULL --[intQuoteHeaderId]
           ,NULL --[intItemId]
           ,NULL --[intTerminalId]
           ,NULL --[intSupplyPointId]
           ,NULL --[dblRackPrice]
           ,NULL --[dblDeviationAmount]
           ,NULL --[dblTempAdjustment]
           ,NULL --[dblFreightRate]
           ,NULL --[dblQuotePrice]
           ,NULL --[dblMargin]
           ,NULL --[dblQtyOrdered]
           ,NULL --[dblExtProfit]
           ,NULL --[dblTax]
           ,NULL --[intShipToLocationId]
           ,1 --[intConcurrencyId]


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