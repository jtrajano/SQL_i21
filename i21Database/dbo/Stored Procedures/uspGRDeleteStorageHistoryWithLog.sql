CREATE PROCEDURE [dbo].[uspGRDeleteStorageHistoryWithLog]
	@intSettleStorageId int,
	@intEntityId int
AS
	
	declare @awesome_columns nvarchar(max)
	declare @awesome_values nvarchar(max)
	declare @cmd nvarchar(max)
	declare @output_from_cmd nvarchar(max)
	select @awesome_columns = '', @awesome_values = '', @cmd = ''

	
	if exists(select top 1 1 from tblGRStorageHistory where intSettleStorageId = @intSettleStorageId)
	begin 
		SELECT 
			@awesome_columns = @awesome_columns  + Cast((TABLE_NAME + '.' + COLUMN_NAME ) as nvarchar(max))  + ',', 
			@awesome_values = @awesome_values + 'isnull(cast(' + (TABLE_NAME + '.' + COLUMN_NAME) + ' as nvarchar(max)) , '''')+ '',''+'
				FROM INFORMATION_SCHEMA.COLUMNS 
					WHERE TABLE_NAME = N'tblGRStorageHistory'

		select @awesome_columns = substring(@awesome_columns, 1, len(@awesome_columns) - 1)
		select @awesome_values = substring(@awesome_values, 1, len(@awesome_values) - 1)

		set @cmd = 'select @output_from_cmd = ' + @awesome_values + ' + ''|+|'' from tblGRStorageHistory where intSettleStorageId = ' + cast(@intSettleStorageId as nvarchar(1000))



		EXEC sp_executesql @cmd, N'@output_from_cmd nvarchar(max) OUTPUT', @output_from_cmd OUTPUT	

		insert into [tblGRStorageHistoryDeleteHistory] (intSettleStorageId, intEntityId, dtmAction, strColumnRecord, strRowRecord)
		values(@intSettleStorageId, @intEntityId, getdate(), @awesome_columns, @output_from_cmd)

	end
	

	UPDATE tblGRStorageHistory 
		set intSettleStorageId  = null 
			where intSettleStorageId = @intSettleStorageId
	
	
	DELETE FROM tblGRSettleStorage WHERE intSettleStorageId = @intSettleStorageId	
	
	select @awesome_columns = null, @awesome_values = null, @cmd = null

RETURN 0
