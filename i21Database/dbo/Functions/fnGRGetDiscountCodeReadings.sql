CREATE FUNCTION [dbo].[fnGRGetDiscountCodeReadings]
(
	 @intTicketd INT
	,@strSourceType NVARCHAR(30)
)
RETURNS NVARCHAR(MAX)
AS
BEGIN
	DECLARE @strDiscountCodeReadings AS NVARCHAR(MAX)

	IF @strSourceType = 'Scale'
	BEGIN
		SELECT @strDiscountCodeReadings = STUFF((
													SELECT DISTINCT ', ' + LTRIM(RTRIM(Item.strItemNo)) + ' : ' + [dbo].[fnRemoveTrailingZeroes](QM.dblGradeReading)
													FROM tblQMTicketDiscount QM
													JOIN tblGRDiscountScheduleCode DCode ON DCode.intDiscountScheduleCodeId = QM.intDiscountScheduleCodeId
													JOIN tblICItem Item ON Item.intItemId = DCode.intItemId
													WHERE QM.strSourceType = 'Scale' AND QM.intTicketId = @intTicketd
													FOR XML PATH('')
												 ), 1, 2, '')
	END
	ELSE IF @strSourceType = 'Storage'
	BEGIN
		SELECT @strDiscountCodeReadings = STUFF((
													SELECT DISTINCT ', ' + LTRIM(RTRIM(Item.strItemNo)) + ' : ' + [dbo].[fnRemoveTrailingZeroes](QM.dblGradeReading)
													FROM tblQMTicketDiscount QM
													JOIN tblGRDiscountScheduleCode DCode ON DCode.intDiscountScheduleCodeId = QM.intDiscountScheduleCodeId
													JOIN tblICItem Item ON Item.intItemId = DCode.intItemId
													WHERE QM.strSourceType = 'Storage' AND QM.intTicketFileId = @intTicketd
													FOR XML PATH('')
													), 1, 2, '')
	END

	RETURN ISNULL(@strDiscountCodeReadings, '');
END
