create procedure [dbo].[sp_AcuFindUnique_3]  
@tablename char(128) = NULL,  
@objid int  
as  
	declare @tab varchar(128) 
	if (@tablename = NULL) 
	begin 
		declare @user varchar(128) 
		declare @obj varchar(128) 
		select @user = u.name, @obj = o.name from 
			sysusers u, sysobjects o where 
			o.id = @objid and u.uid = o.uid 
		select @tab = rtrim(@user) + '.' + rtrim(@obj) 
	end 
	else 
	begin 
		select @tab = @tablename 
	end 
	select name, indid, status,  
		index_col (@tab, indid, 1), index_col (@tab, indid, 2),  
		index_col (@tab, indid, 3), index_col (@tab, indid, 4),  
		index_col (@tab, indid, 5), index_col (@tab, indid, 6),  
		index_col (@tab, indid, 7), index_col (@tab, indid, 8),  
		index_col (@tab, indid, 9), index_col (@tab, indid, 10),  
		index_col (@tab, indid, 11), index_col (@tab, indid, 12),  
		index_col (@tab, indid, 13), index_col (@tab, indid, 14),  
		index_col (@tab, indid, 15), index_col (@tab, indid, 16)  
			from sysindexes where id = @objid  
	return 0