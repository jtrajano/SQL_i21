CREATE PROCEDURE [dbo].[uspICTradeFinanceBeforeSave]
	@intTransactionId AS INT
	,@intEntityUserSecurityId AS INT 
AS

DECLARE @TRFTradeFinance AS TRFTradeFinance
		,@TRFLog AS TRFLog
		
DECLARE 
	@dtmDate AS DATETIME 
	,@strAction AS NVARCHAR(50) 
	,@intTradeFinanceId AS INT 

-- Update the lot TF, Warrant No, and Warrant Status back to the original data stored in tblICInventoryTradeFinanceLot 
BEGIN 
	UPDATE lot
	SET
		lot.intTradeFinanceId = itfLot.intTradeFinanceId
		,lot.intWarrantStatus = itfLot.intWarrantStatus
		,lot.strWarrantNo = itfLot.strWarrantNo
	FROM 
		tblICInventoryTradeFinance itf
		
		LEFT JOIN tblTRFTradeFinance tf
			ON itf.strTradeFinanceNumber = tf.strTradeFinanceNumber

		LEFT JOIN (
			tblICInventoryTradeFinanceLot itfLot INNER JOIN tblICLot lot
				ON itfLot.intLotId = lot.intLotId
		)
			ON itfLot.intInventoryTradeFinanceId = itf.intInventoryTradeFinanceId			
	WHERE
		itf.intInventoryTradeFinanceId = @intTransactionId
END
RETURN 0
