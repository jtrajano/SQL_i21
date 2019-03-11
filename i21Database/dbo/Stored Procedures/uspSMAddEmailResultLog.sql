CREATE PROCEDURE uspSMAddEmailResultLog
	@ActivityId		int,
	@Result			nvarchar(4000),
	@UserId			int
AS
BEGIN

		if exists (select top 1 1 from tblSMActivity where intActivityId = @ActivityId)
			and isnull(@Result, '') <> ''
			and exists(select top 1 1 from tblEMEntity where intEntityId = @UserId)
		begin
			insert into tblSMActivityEmailResult( intActivityId, strResult, dtmTransactionDate, intEntityUserId)
			select  @ActivityId, @Result, getdate(), @UserId
		end
END