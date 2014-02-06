create procedure [dbo].[sp_AcuCountTables_1] 
@objid int = NULL 
as 
	declare @uid int 
	declare @name char(30) 
	declare @likename char(35) 
	if (@objid = NULL) 
	begin 
		raiserror 22001 'No table id given' 
		return 1 
	end 
	select @uid = uid, @name = name from sysobjects where id = @objid 
	if (@uid = NULL) 
	begin 
		raiserror 22001 'Bad object id given' 
		return 1 
	end 
	select @likename = rtrim(@name) + 'A' 
	if (select count(*) from sysobjects where 
		name like rtrim(@likename) and uid = @uid) = 0 
		select 0 
	else 
	begin 
		select @likename = rtrim(@name) + '[A-Z]' 
		select count(*) from sysobjects where 
			name like rtrim(@likename) and uid = @uid 
	end