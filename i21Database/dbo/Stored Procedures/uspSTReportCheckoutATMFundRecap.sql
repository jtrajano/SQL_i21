CREATE PROCEDURE [dbo].[uspSTReportCheckoutATMFundRecap]
	@intCheckoutId INT 
AS
BEGIN TRY
	
	DECLARE @ErrMsg NVARCHAR(MAX)

	SELECT 
		atm.intCheckoutId,
		REPLACE(atm.strType, 'ATM ', '') AS strType,
		atm.intItemId,
		atm.dblItemAmount,
		item.strItemNo,
		atm.intSequence,
		SUM(atm.dblItemAmount) OVER() AS dblTotalAmount 
	FROM vyuSTCheckoutATMFund atm
	LEFT JOIN tblICItem item
		ON atm.intItemId = item.intItemId
	WHERE intCheckoutId = @intCheckoutId
	GROUP BY
		atm.intCheckoutId,
		atm.strType,
		atm.intItemId,
		atm.dblItemAmount,
		item.strItemNo,
		atm.intSequence
	ORDER BY atm.intSequence   

END TRY
BEGIN CATCH
	SET @ErrMsg = ERROR_MESSAGE()  
	RAISERROR (@ErrMsg,18,1,'WITH NOWAIT')
END CATCH