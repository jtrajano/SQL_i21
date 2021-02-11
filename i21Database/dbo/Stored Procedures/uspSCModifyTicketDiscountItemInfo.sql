CREATE PROCEDURE [dbo].[uspSCModifyTicketDiscountItemInfo]
    @intTicketId int = null
	,@intDeliverySheetId int = null
	,@intStorageId int = null
AS
BEGIN

	SET QUOTED_IDENTIFIER OFF
	SET ANSI_NULLS ON
	SET NOCOUNT ON
	SET XACT_ABORT ON
	SET ANSI_WARNINGS OFF

	
	if (@intTicketId is not null)
	begin
		MERGE INTO tblQMTicketDiscountItemInfo AS destination
		USING
		(
			SELECT
				TicketDiscount.intTicketDiscountId
				,Item.ysnInventoryCost
				,Item.intItemId
			FROM tblQMTicketDiscount TicketDiscount
				JOIN tblGRDiscountScheduleCode DiscountSchedule
						ON DiscountSchedule.intDiscountScheduleCodeId = TicketDiscount.intDiscountScheduleCodeId 
				JOIN tblICItem Item
					on DiscountSchedule.intItemId = Item.intItemId
			where (TicketDiscount.intTicketId = @intTicketId)
				and TicketDiscount.strSourceType = 'Scale'
		)
		AS SourceData
		ON destination.intTicketDiscountId = SourceData.intTicketDiscountId
		WHEN NOT MATCHED THEN
		INSERT
		(
			intTicketDiscountId
			,ysnInventoryCost
			,[intItemId]
		)
		VALUES
		(
			SourceData.intTicketDiscountId
			,SourceData.ysnInventoryCost
			,SourceData.intItemId
		)
		when matched then
			update set
				ysnInventoryCost = SourceData.ysnInventoryCost
				,[intItemId] = SourceData.intItemId

		;
	end
	else if(@intDeliverySheetId is not null)
	begin
		MERGE INTO tblQMTicketDiscountItemInfo AS destination
		USING
		(
			SELECT
				TicketDiscount.intTicketDiscountId
				,Item.ysnInventoryCost
				,Item.intItemId
			FROM tblQMTicketDiscount TicketDiscount
				JOIN tblGRDiscountScheduleCode DiscountSchedule
					ON DiscountSchedule.intDiscountScheduleCodeId = TicketDiscount.intDiscountScheduleCodeId 
				JOIN tblICItem Item
					on DiscountSchedule.intItemId = Item.intItemId								
			where (TicketDiscount.intTicketFileId = @intDeliverySheetId)
				and TicketDiscount.strSourceType = 'Delivery Sheet'
		)
		AS SourceData
		ON destination.intTicketDiscountId = SourceData.intTicketDiscountId
		WHEN NOT MATCHED THEN
		INSERT
		(
			intTicketDiscountId
			,ysnInventoryCost
			,[intItemId]
		)
		VALUES
		(
			SourceData.intTicketDiscountId
			,SourceData.ysnInventoryCost
			,SourceData.intItemId
		)
		when matched then
			update set
				ysnInventoryCost = SourceData.ysnInventoryCost
				,[intItemId] = SourceData.intItemId

		;
	end
	else if(@intStorageId is not null)
	begin
		MERGE INTO tblQMTicketDiscountItemInfo AS destination
		USING
		(
			SELECT
				TicketDiscount.intTicketDiscountId
				,Item.ysnInventoryCost
				,Item.intItemId
			FROM tblQMTicketDiscount TicketDiscount
				JOIN tblGRDiscountScheduleCode DiscountSchedule
					ON DiscountSchedule.intDiscountScheduleCodeId = TicketDiscount.intDiscountScheduleCodeId 
				JOIN tblICItem Item
					on DiscountSchedule.intItemId = Item.intItemId								
			where (TicketDiscount.intTicketFileId = @intStorageId)
				and TicketDiscount.strSourceType = 'Storage'
		)
		AS SourceData
		ON destination.intTicketDiscountId = SourceData.intTicketDiscountId
		WHEN NOT MATCHED THEN
		INSERT
		(
			intTicketDiscountId
			,ysnInventoryCost
			,[intItemId]
		)
		VALUES
		(
			SourceData.intTicketDiscountId
			,SourceData.ysnInventoryCost
			,SourceData.intItemId
		)
		when matched then
			update set
				ysnInventoryCost = SourceData.ysnInventoryCost
				,[intItemId] = SourceData.intItemId

		;
	end
	
	
END
