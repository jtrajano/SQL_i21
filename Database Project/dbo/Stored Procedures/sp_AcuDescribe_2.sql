create procedure [dbo].[sp_AcuDescribe_2] 
@objid int 
as 
	select name, usertype, type, length, status from syscolumns where 
		id = @objid 
	return 0
