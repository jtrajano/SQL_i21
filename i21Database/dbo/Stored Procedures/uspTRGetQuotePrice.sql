CREATE PROCEDURE [dbo].[uspTRGetQuotePrice]
	 @intEntityCustomerId AS INT,
	 @intItemId AS INT,	 
	 @intShipToId as int,
	 @intSupplyPointId as int,	 
	 @dtmTransactionDate as DATETIME, 	 
	 @dblQuotePrice decimal(18,6) OUTPUT	
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
  
  if @intSupplyPointId != 0
  BEGIN 
       select top 1 @dblQuotePrice = QD.dblQuotePrice from dbo.tblTRQuoteHeader QH
	      join dbo.tblTRQuoteDetail QD on QD.intQuoteHeaderId = QH.intQuoteHeaderId
       where QH.intEntityCustomerId =@intEntityCustomerId
         and QD.intItemId = @intItemId
	     and QD.intShipToLocationId = @intShipToId
	     and QD.intSupplyPointId = @intSupplyPointId
	     and QH.dtmQuoteEffectiveDate <= @dtmTransactionDate
	     and QH.strQuoteStatus = 'Sent'
       order by QH.dtmQuoteEffectiveDate DESC
  END
  else
  BEGIN
     select top 1 @dblQuotePrice = QD.dblQuotePrice from dbo.tblTRQuoteHeader QH
	      join dbo.tblTRQuoteDetail QD on QD.intQuoteHeaderId = QH.intQuoteHeaderId
       where QH.intEntityCustomerId =@intEntityCustomerId
         and QD.intItemId = @intItemId
	     and QD.intShipToLocationId = @intShipToId
	     and QH.dtmQuoteEffectiveDate <= @dtmTransactionDate
	     and QH.strQuoteStatus = 'Sent'
       order by QH.dtmQuoteEffectiveDate DESC
  END
if @dblQuotePrice is null
    BEGIN
	   set @dblQuotePrice = 0;
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