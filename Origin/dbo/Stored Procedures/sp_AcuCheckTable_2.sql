CREATE procedure [dbo].[sp_AcuCheckTable_2]   
@db varchar(128) = NULL,   
@user varchar(128) = NULL,   
@tab varchar(128) = NULL,   
@objid int output   
as   
 declare @type int   
 if (@tab is NULL)   
 begin   
  raiserror 22001 'No table name given'   
  return 1   
 end   
 if (@db is not NULL and @db != db_name ())   
 begin   
  raiserror 22002 'Table must be in current database'   
  return 1   
 end   
 if (@user = NULL or @user = '')   
  select @objid = id, @type = (sysstat & 7) from   
    sysobjects where name = @tab and   
    type in ('S', 'U', 'V')   
 else   
  select @objid = o.id, @type = (o.sysstat & 7) from   
    sysobjects o, sysusers u where   
   o.name = @tab and o.uid = u.uid and   
   u.name = @user and o.type in ('S', 'U', 'V')   
 if (@objid = NULL or @objid = 0 or @type not in (1, 2, 3))   
 begin   
  raiserror 22003 'Table does not exist'   
  return 1   
 end   
 return 0