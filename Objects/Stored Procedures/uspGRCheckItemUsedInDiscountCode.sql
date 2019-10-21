CREATE PROCEDURE [dbo].[uspGRCheckItemUsedInDiscountCode]
	 @intItemId INT
	,@ItemUsedInDiscountCode INT OUTPUT
AS
BEGIN TRY
	SET NOCOUNT ON
	DECLARE @ErrMsg NVARCHAR(MAX)
	
	
	IF EXISTS( SELECT 1 FROM tblGRDiscountId a 
			   JOIN tblGRDiscountCrossReference b ON b.intDiscountId=a.intDiscountId
			   JOIN tblGRDiscountScheduleCode c ON c.intDiscountScheduleId=b.intDiscountScheduleId
			   WHERE a.ysnDiscountIdActive=1 AND c.intItemId=@intItemId
			 )
		BEGIN
			SET @ItemUsedInDiscountCode = 1
		END
	ELSE
		BEGIN
			SET @ItemUsedInDiscountCode = 0
		END
		
END TRY

BEGIN CATCH
	SET @ErrMsg = ERROR_MESSAGE()
	SET @ErrMsg = 'uspGRCheckItemUsedInDiscountCode: ' + @ErrMsg
	RAISERROR (@ErrMsg,16,1,'WITH NOWAIT')	
END CATCH