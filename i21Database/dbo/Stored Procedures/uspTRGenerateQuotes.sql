CREATE PROCEDURE [dbo].[uspTRGenerateQuotes]
	 @intCustomerGroupId AS INT,
	 @intCustomerId AS INT,
	 @dtmQuoteDate AS DATETIME,
	 @dtmEffectiveDate AS DATETIME
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
select intEntityCustomerId,NULL from vyuTRQuoteSelection where (isNull(@intCustomerId ,0 ) = 0 or isNull(@intCustomerId ,0 ) = intEntityCustomerId) 
                                                              or  (isNull(@intCustomerGroupId ,0 ) = 0 or isNull(@intCustomerGroupId ,0 ) = intEntityCustomerId) 

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