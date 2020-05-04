CREATE PROCEDURE [dbo].[uspSTReportCheckoutChangeFundRecap]
	@intCheckoutId INT 
AS
BEGIN TRY
	
	DECLARE @ErrMsg NVARCHAR(MAX)

	SELECT 
		cf.intCheckoutId,
		REPLACE(cf.strType, 'Change Fund ', '') AS strType,
		cf.intItemId,
		cf.dblItemAmount,
		item.strItemNo,
		cf.intSequence,
		SUM(cf.dblItemAmount) OVER() AS dblTotalAmount 
	FROM vyuSTCheckoutChangeFund cf
	LEFT JOIN tblICItem item
		ON cf.intItemId = item.intItemId
	WHERE intCheckoutId = @intCheckoutId
	GROUP BY
		cf.intCheckoutId,
		cf.strType,
		cf.intItemId,
		cf.dblItemAmount,
		item.strItemNo,
		cf.intSequence
	ORDER BY cf.intSequence

END TRY
BEGIN CATCH
	SET @ErrMsg = ERROR_MESSAGE()  
	RAISERROR (@ErrMsg,18,1,'WITH NOWAIT')
END CATCH