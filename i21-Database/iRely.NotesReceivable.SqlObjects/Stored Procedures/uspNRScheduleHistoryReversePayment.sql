CREATE PROCEDURE [dbo].[uspNRScheduleHistoryReversePayment]
@intScheduleTransId Int
AS
BEGIN
	
	Update dbo.tblNRScheduleTransaction 
	SET dtmPaidOn=NULL, dblPayAmt=0, dblLateFeePayAmt = 0, dtmLateFeePaidOn=NULL  
	Where intScheduleTransId = @intScheduleTransId
	
END
