﻿
IF NOT EXISTS( SELECT TOP 1 1 FROM [tblEMEntityPortalMenu])
BEGIN
	print 'Creating Menus'
	EXEC(N'
	delete tblEMEntityPortalPermission
	delete tblEMEntityPortalMenu

	DBCC CHECKIDENT (''tblEMEntityPortalMenu'', RESEED, 1);
	insert into tblEMEntityPortalMenu(strPortalMenuName,intPortalParentMenuId,strType,strCommand)
	select ''Help Desk'',0,''Folder'',null

	insert into tblEMEntityPortalMenu(strPortalMenuName,intPortalParentMenuId,strType,strCommand)
	select ''Billing Account'',0,''Folder'',null
	insert into tblEMEntityPortalMenu(strPortalMenuName,intPortalParentMenuId,strType,strCommand)
	select ''Grain Account'',0,''Folder'',null
	insert into tblEMEntityPortalMenu(strPortalMenuName,intPortalParentMenuId,strType,strCommand)
	select ''Contact'',0,''Folder'',null

	insert into tblEMEntityPortalMenu(strPortalMenuName,intPortalParentMenuId,strType,strCommand)
	select ''Vendor'',0,''Folder'',null

	insert into tblEMEntityPortalMenu(strPortalMenuName,intPortalParentMenuId,strType,strCommand)
	select ''Payment Request'',0,''Folder'',null

	insert into tblEMEntityPortalMenu(strPortalMenuName,intPortalParentMenuId,strType,strCommand)
	select ''Approver'',0,''Folder'',null



	--Help Desk
	insert into tblEMEntityPortalMenu(strPortalMenuName,intPortalParentMenuId,strType,strCommand)
	select ''Create Ticket'',intEntityPortalMenuId,''Screen'',''HelpDesk.controller.CreateTicket'' from tblEMEntityPortalMenu where strPortalMenuName = ''Help Desk'' and intPortalParentMenuId = 0
	insert into tblEMEntityPortalMenu(strPortalMenuName,intPortalParentMenuId,strType,strCommand)
	select ''Tickets'',intEntityPortalMenuId,''Screen'',''HelpDesk.controller.CPTickets'' from tblEMEntityPortalMenu where strPortalMenuName = ''Help Desk'' and intPortalParentMenuId = 0
	insert into tblEMEntityPortalMenu(strPortalMenuName,intPortalParentMenuId,strType,strCommand)
	select ''Open Tickets'',intEntityPortalMenuId,''Screen'',''HelpDesk.controller.CPOpenTicket'' from tblEMEntityPortalMenu where strPortalMenuName = ''Help Desk'' and intPortalParentMenuId = 0
	insert into tblEMEntityPortalMenu(strPortalMenuName,intPortalParentMenuId,strType,strCommand)
	select ''Tickets Reported by Me'',intEntityPortalMenuId,''Screen'',''HelpDesk.controller.CPTicketsReported'' from tblEMEntityPortalMenu where strPortalMenuName = ''Help Desk'' and intPortalParentMenuId = 0

	--Billing
	insert into tblEMEntityPortalMenu(strPortalMenuName,intPortalParentMenuId,strType,strCommand)
	select ''Invoice Credits'',intEntityPortalMenuId,''Screen'',''CustomerPortal.controller.InvoicesCredits'' from tblEMEntityPortalMenu where strPortalMenuName = ''Billing Account'' and intPortalParentMenuId = 0
	insert into tblEMEntityPortalMenu(strPortalMenuName,intPortalParentMenuId,strType,strCommand)
	select ''Payments'',intEntityPortalMenuId,''Screen'',''CustomerPortal.controller.Payments'' from tblEMEntityPortalMenu where strPortalMenuName = ''Billing Account'' and intPortalParentMenuId = 0
	insert into tblEMEntityPortalMenu(strPortalMenuName,intPortalParentMenuId,strType,strCommand)
	select ''Purchases'',intEntityPortalMenuId,''Screen'',''CustomerPortal.controller.Purchases'' from tblEMEntityPortalMenu where strPortalMenuName = ''Billing Account'' and intPortalParentMenuId = 0
	insert into tblEMEntityPortalMenu(strPortalMenuName,intPortalParentMenuId,strType,strCommand)
	select ''Orders'',intEntityPortalMenuId,''Screen'',''CustomerPortal.controller.Orders'' from tblEMEntityPortalMenu where strPortalMenuName = ''Billing Account'' and intPortalParentMenuId = 0
	insert into tblEMEntityPortalMenu(strPortalMenuName,intPortalParentMenuId,strType,strCommand)
	select ''Contracts'',intEntityPortalMenuId,''Screen'',''CustomerPortal.controller.Contracts'' from tblEMEntityPortalMenu where strPortalMenuName = ''Billing Account'' and intPortalParentMenuId = 0
	insert into tblEMEntityPortalMenu(strPortalMenuName,intPortalParentMenuId,strType,strCommand)
	select ''Business Summary'',intEntityPortalMenuId,''Screen'',''CustomerPortal.controller.BusinessSummary'' from tblEMEntityPortalMenu where strPortalMenuName = ''Billing Account'' and intPortalParentMenuId = 0


	--Grain
	insert into tblEMEntityPortalMenu(strPortalMenuName,intPortalParentMenuId,strType,strCommand)
	select ''Settlements'',intEntityPortalMenuId,''Screen'',''CustomerPortal.controller.Settlements'' from tblEMEntityPortalMenu where strPortalMenuName =''Grain Account'' and intPortalParentMenuId = 0
	insert into tblEMEntityPortalMenu(strPortalMenuName,intPortalParentMenuId,strType,strCommand)
	select ''Storage'',intEntityPortalMenuId,''Screen'',''CustomerPortal.controller.Storage'' from tblEMEntityPortalMenu where strPortalMenuName = ''Grain Account'' and intPortalParentMenuId = 0
	insert into tblEMEntityPortalMenu(strPortalMenuName,intPortalParentMenuId,strType,strCommand)
	select ''Contracts'',intEntityPortalMenuId,''Screen'',''CustomerPortal.controller.GAContracts'' from tblEMEntityPortalMenu where strPortalMenuName = ''Grain Account'' and intPortalParentMenuId = 0
	insert into tblEMEntityPortalMenu(strPortalMenuName,intPortalParentMenuId,strType,strCommand)
	select ''Production History'',intEntityPortalMenuId,''Screen'',''CustomerPortal.controller.ProductionHistory'' from tblEMEntityPortalMenu where strPortalMenuName = ''Grain Account'' and intPortalParentMenuId = 0
	insert into tblEMEntityPortalMenu(strPortalMenuName,intPortalParentMenuId,strType,strCommand)
	select ''Options'',intEntityPortalMenuId,''Screen'',''CustomerPortal.controller.Options'' from tblEMEntityPortalMenu where strPortalMenuName = ''Grain Account'' and intPortalParentMenuId = 0
	insert into tblEMEntityPortalMenu(strPortalMenuName,intPortalParentMenuId,strType,strCommand)
	select ''Current Cash Bids'',intEntityPortalMenuId,''Screen'',''CustomerPortal.controller.CurrentCashBids'' from tblEMEntityPortalMenu where strPortalMenuName = ''Grain Account'' and intPortalParentMenuId = 0
	insert into tblEMEntityPortalMenu(strPortalMenuName,intPortalParentMenuId,strType,strCommand)
	select ''Business Summary'',intEntityPortalMenuId,''Screen'',''CustomerPortal.controller.GABusinessSummary'' from tblEMEntityPortalMenu where strPortalMenuName = ''Grain Account'' and intPortalParentMenuId = 0

	--Contact
	insert into tblEMEntityPortalMenu(strPortalMenuName,intPortalParentMenuId,strType,strCommand)
	select ''Customer Contact List'',intEntityPortalMenuId,''Screen'',''EntityManagement.controller.CustomerContactList'' from tblEMEntityPortalMenu where strPortalMenuName = ''Contact'' and intPortalParentMenuId = 0


	--Vendor

	insert into tblEMEntityPortalMenu(strPortalMenuName,intPortalParentMenuId,strType,strCommand)
	select ''Vendor'',intEntityPortalMenuId,''Screen'',''EntityManagement.view.Entity'' from tblEMEntityPortalMenu where strPortalMenuName = ''Vendor'' and intPortalParentMenuId = 0

	insert into tblEMEntityPortalMenu(strPortalMenuName,intPortalParentMenuId,strType,strCommand)
	select ''Bill'',intEntityPortalMenuId,''Screen'',''AccountsPayable.view.Bill'' from tblEMEntityPortalMenu where strPortalMenuName = ''Vendor'' and intPortalParentMenuId = 0

	--Newly created 
	--Help Desk

	insert into tblEMEntityPortalMenu(strPortalMenuName,intPortalParentMenuId,strType,strCommand)
	select ''Project Lists'',intEntityPortalMenuId,''Screen'',''HelpDesk.view.ProjectList'' from tblEMEntityPortalMenu where strPortalMenuName = ''Help Desk'' and intPortalParentMenuId = 0

	')	
	
	IF EXISTS(SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = 'tblARCustomerPortalPermission')
		AND EXISTS(SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = 'tblARCustomerToContact')
	BEGIN
		print 'Moved customer permission to entity permission'
		EXEC(N'insert into tblEMEntityPortalPermission
				select f.intEntityToContactId,e.intEntityPortalMenuId,1 from tblARCustomerPortalMenu a 
					join tblARCustomerPortalPermission b
						on a.intCustomerPortalMenuId = b.intCustomerPortalMenuId
					join tblARCustomerToContact c
						on b.intARCustomerToContactId = c.intARCustomerToContactId
					join tblEMEntityContact d
						on c.intEntityContactId = d.intEntityContactId
					join tblEMEntityPortalMenu e
						on e.strPortalMenuName  = a.strCustomerPortalMenuName 
							and e.strType = a.strType
					join tblEMEntityToContact f
						on f.intEntityContactId = c.intEntityContactId')
	END
END
ELSE
BEGIN
	EXEC(N'update tblEMEntityPortalMenu set strCommand = ''EntityManagement.controller.CustomerContactList'' where strPortalMenuName = ''Customer Contact List'' AND intPortalParentMenuId = 4')
END 




IF exists(select 1 from [tblEMEntityPortalMenu] where strPortalMenuName = 'Tickets' and strType = 'Screen' and strCommand = 'HelpDesk.controller.CPTickets')
BEGIN
	exec('update tblEMEntityPortalMenu set strCommand = ''HelpDesk.view.TicketList'' where strPortalMenuName = ''Tickets'' and strType = ''Screen'' and strCommand = ''HelpDesk.controller.CPTickets''')
END

IF exists(select 1 from [tblEMEntityPortalMenu] where strPortalMenuName = 'Open Tickets' and strType = 'Screen' and strCommand = 'HelpDesk.controller.CPOpenTicket')
BEGIN
	exec('update tblEMEntityPortalMenu set strCommand = ''HelpDesk.view.TicketList'' where strPortalMenuName = ''Open Tickets'' and strType = ''Screen'' and strCommand = ''HelpDesk.controller.CPOpenTicket''')
END

IF exists(select 1 from [tblEMEntityPortalMenu] where strPortalMenuName = 'Tickets Reported by Me' and strType = 'Screen' and strCommand = 'HelpDesk.controller.CPTicketsReported')
BEGIN
	exec('update tblEMEntityPortalMenu set strCommand = ''HelpDesk.view.TicketList'' where strPortalMenuName = ''Tickets Reported by Me'' and strType = ''Screen'' and strCommand = ''HelpDesk.controller.CPTicketsReported''')
END


IF EXISTS( select 1 from [tblEMEntityPortalMenu] where intEntityPortalMenuId = 29 AND strPortalMenuName <> 'Reminder Lists')
BEGIN
	EXEC('DELETE FROM tblEMEntityPortalMenu WHERE intEntityPortalMenuId = 29 ')
END
IF NOT EXISTS(select 1 from [tblEMEntityPortalMenu] where intEntityPortalMenuId = 29) 
	AND not exists(select 1 from [tblEMEntityPortalMenu] where strPortalMenuName = 'Reminder Lists' and strType = 'Screen' and strCommand = 'HelpDesk.view.ReminderList' and intEntityPortalMenuId = 29)
begin
	SET IDENTITY_INSERT [tblEMEntityPortalMenu] ON
	EXEC('
	
	insert into tblEMEntityPortalMenu(intEntityPortalMenuId,strPortalMenuName,intPortalParentMenuId,strType,strCommand,strEntityType)
	select 29,''Reminder Lists'',intEntityPortalMenuId,''Screen'',''HelpDesk.view.ReminderList'','''' from tblEMEntityPortalMenu where strPortalMenuName = ''Help Desk'' and intPortalParentMenuId = 0
	')
	SET IDENTITY_INSERT [tblEMEntityPortalMenu] OFF
end


IF exists(select 1 from [tblEMEntityPortalMenu] where strPortalMenuName = 'Tickets' and strType = 'Screen' and strCommand = 'HelpDesk.view.TicketList')
BEGIN
	EXEC( '
	UPDATE tblEMEntityPortalMenu 
		set strCommand = ''HelpDesk.view.Ticket:searchConfigAll'' 
	where strPortalMenuName = ''Tickets'' 
		and strType = ''Screen'' 
		and strCommand = ''HelpDesk.view.TicketList'' ')
END
--Last Count for automated is 28

IF EXISTS( select 1 from [tblEMEntityPortalMenu] where intEntityPortalMenuId = 30  AND strPortalMenuName <> 'Customer')
BEGIN
	EXEC('DELETE FROM tblEMEntityPortalMenu WHERE intEntityPortalMenuId = 30 ')
END
IF NOT EXISTS(select 1 from [tblEMEntityPortalMenu] where intEntityPortalMenuId = 30) 
	AND not exists(select 1 from [tblEMEntityPortalMenu] where strPortalMenuName = 'Customer' and intEntityPortalMenuId = 30)
begin
	SET IDENTITY_INSERT [tblEMEntityPortalMenu] ON
	EXEC('
	
	insert into tblEMEntityPortalMenu(intEntityPortalMenuId,strPortalMenuName,intPortalParentMenuId,strType,strCommand,strEntityType)
	select 30, ''Customer'', 0, ''Folder'', null, ''Customer''
	')
	SET IDENTITY_INSERT [tblEMEntityPortalMenu] OFF
end

IF EXISTS( select 1 from [tblEMEntityPortalMenu] where intEntityPortalMenuId = 31  AND strPortalMenuName <> 'Invoice')
BEGIN
	EXEC('DELETE FROM tblEMEntityPortalMenu WHERE intEntityPortalMenuId = 31 ')
END
IF NOT EXISTS(select 1 from [tblEMEntityPortalMenu] where intEntityPortalMenuId = 31) 
	AND not exists(select 1 from [tblEMEntityPortalMenu] where strPortalMenuName = 'Invoice' and intEntityPortalMenuId = 31)
begin
	SET IDENTITY_INSERT [tblEMEntityPortalMenu] ON
	EXEC('
	
	insert into tblEMEntityPortalMenu(intEntityPortalMenuId,strPortalMenuName,intPortalParentMenuId,strType,strCommand,strEntityType)
	select 31, ''Invoice'', 30, ''Screen'', ''AccountsReceivable.view.Invoice'', ''Customer''
	')
	SET IDENTITY_INSERT [tblEMEntityPortalMenu] OFF
end

IF EXISTS( select 1 from [tblEMEntityPortalMenu] where intEntityPortalMenuId = 32  AND strPortalMenuName <> 'Receive Payment Details')
BEGIN
	EXEC('DELETE FROM tblEMEntityPortalMenu WHERE intEntityPortalMenuId = 32 ')
END
IF NOT EXISTS(select 1 from [tblEMEntityPortalMenu] where intEntityPortalMenuId = 32) 
	AND not exists(select 1 from [tblEMEntityPortalMenu] where strPortalMenuName = 'Receive Payment Details' and  intEntityPortalMenuId = 32)
begin
	SET IDENTITY_INSERT [tblEMEntityPortalMenu] ON
	EXEC('
	
	insert into tblEMEntityPortalMenu(intEntityPortalMenuId,strPortalMenuName,intPortalParentMenuId,strType,strCommand,strEntityType)
	select 32, ''Receive Payment Details'', 30, ''Screen'', ''AccountsReceivable.view.ReceivePaymentsDetail'', ''Customer''
	')
	SET IDENTITY_INSERT [tblEMEntityPortalMenu] OFF
end

IF EXISTS( select 1 from [tblEMEntityPortalMenu] where intEntityPortalMenuId = 33   AND strPortalMenuName <> 'Customer')
BEGIN
	EXEC('DELETE FROM tblEMEntityPortalMenu WHERE intEntityPortalMenuId = 33 ')
END
IF NOT EXISTS(select 1 from [tblEMEntityPortalMenu] where intEntityPortalMenuId = 33) 
	AND not exists(select 1 from [tblEMEntityPortalMenu] where  strPortalMenuName = 'Customer' and intEntityPortalMenuId = 33)
begin
	SET IDENTITY_INSERT [tblEMEntityPortalMenu] ON
	EXEC('
	
	insert into tblEMEntityPortalMenu(intEntityPortalMenuId,strPortalMenuName,intPortalParentMenuId,strType,strCommand,strEntityType)
	select 33, ''Customer'', 30, ''Screen'', ''EntityManagement.view.Entity'', ''Customer''
	')
	SET IDENTITY_INSERT [tblEMEntityPortalMenu] OFF
end

--Vendor
IF exists(select 1 from [tblEMEntityPortalMenu] where strPortalMenuName = 'Bill' and strType = 'Screen' and strCommand = 'AccountsPayable.view.Bill')
BEGIN
	exec('update tblEMEntityPortalMenu set strCommand = ''AccountsPayable.view.Voucher'', strPortalMenuName=''Voucher'' where strPortalMenuName = ''Bill'' and strType = ''Screen'' and strCommand = ''AccountsPayable.view.Bill''')
END