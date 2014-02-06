create procedure [dbo].[sp_AcuGetUser_1] 
@objid int = NULL, 
@user varchar (30) output 
as 
	select @user = u.name from sysusers u, sysobjects o where 
		o.id = @objid and o.uid = u.uid