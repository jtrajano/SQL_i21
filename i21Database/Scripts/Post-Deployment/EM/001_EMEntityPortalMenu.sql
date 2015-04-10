
IF NOT EXISTS( SELECT TOP 1 1 FROM tblEntityPortalMenu)
BEGIN
	print 'Creating Menus'
	EXEC(N'
	delete tblEntityPortalPermission
	delete tblEntityPortalMenu

	DBCC CHECKIDENT (''tblEntityPortalMenu'', RESEED, 1);
	insert into tblEntityPortalMenu(strPortalMenuName,intPortalParentMenuId,strType,strCommand)
	select ''Help Desk'',0,''Folder'',null

	insert into tblEntityPortalMenu(strPortalMenuName,intPortalParentMenuId,strType,strCommand)
	select ''Billing Account'',0,''Folder'',null
	insert into tblEntityPortalMenu(strPortalMenuName,intPortalParentMenuId,strType,strCommand)
	select ''Grain Account'',0,''Folder'',null
	insert into tblEntityPortalMenu(strPortalMenuName,intPortalParentMenuId,strType,strCommand)
	select ''Contact'',0,''Folder'',null

	insert into tblEntityPortalMenu(strPortalMenuName,intPortalParentMenuId,strType,strCommand)
	select ''Vendor'',0,''Folder'',null

	insert into tblEntityPortalMenu(strPortalMenuName,intPortalParentMenuId,strType,strCommand)
	select ''Payment Request'',0,''Folder'',null

	insert into tblEntityPortalMenu(strPortalMenuName,intPortalParentMenuId,strType,strCommand)
	select ''Approver'',0,''Folder'',null



	--Help Desk
	insert into tblEntityPortalMenu(strPortalMenuName,intPortalParentMenuId,strType,strCommand)
	select ''Create Ticket'',intEntityPortalMenuId,''Screen'',''HelpDesk.controller.CreateTicket'' from tblEntityPortalMenu where strPortalMenuName = ''Help Desk'' and intPortalParentMenuId = 0
	insert into tblEntityPortalMenu(strPortalMenuName,intPortalParentMenuId,strType,strCommand)
	select ''Tickets'',intEntityPortalMenuId,''Screen'',''HelpDesk.controller.CPTickets'' from tblEntityPortalMenu where strPortalMenuName = ''Help Desk'' and intPortalParentMenuId = 0
	insert into tblEntityPortalMenu(strPortalMenuName,intPortalParentMenuId,strType,strCommand)
	select ''Open Tickets'',intEntityPortalMenuId,''Screen'',''HelpDesk.controller.CPOpenTicket'' from tblEntityPortalMenu where strPortalMenuName = ''Help Desk'' and intPortalParentMenuId = 0
	insert into tblEntityPortalMenu(strPortalMenuName,intPortalParentMenuId,strType,strCommand)
	select ''Tickets Reported by Me'',intEntityPortalMenuId,''Screen'',''HelpDesk.controller.CPTicketsReported'' from tblEntityPortalMenu where strPortalMenuName = ''Help Desk'' and intPortalParentMenuId = 0

	--Billing
	insert into tblEntityPortalMenu(strPortalMenuName,intPortalParentMenuId,strType,strCommand)
	select ''Invoice Credits'',intEntityPortalMenuId,''Screen'',''CustomerPortal.controller.InvoicesCredits'' from tblEntityPortalMenu where strPortalMenuName = ''Billing Account'' and intPortalParentMenuId = 0
	insert into tblEntityPortalMenu(strPortalMenuName,intPortalParentMenuId,strType,strCommand)
	select ''Payments'',intEntityPortalMenuId,''Screen'',''CustomerPortal.controller.Payments'' from tblEntityPortalMenu where strPortalMenuName = ''Billing Account'' and intPortalParentMenuId = 0
	insert into tblEntityPortalMenu(strPortalMenuName,intPortalParentMenuId,strType,strCommand)
	select ''Purchases'',intEntityPortalMenuId,''Screen'',''CustomerPortal.controller.Purchases'' from tblEntityPortalMenu where strPortalMenuName = ''Billing Account'' and intPortalParentMenuId = 0
	insert into tblEntityPortalMenu(strPortalMenuName,intPortalParentMenuId,strType,strCommand)
	select ''Orders'',intEntityPortalMenuId,''Screen'',''CustomerPortal.controller.Orders'' from tblEntityPortalMenu where strPortalMenuName = ''Billing Account'' and intPortalParentMenuId = 0
	insert into tblEntityPortalMenu(strPortalMenuName,intPortalParentMenuId,strType,strCommand)
	select ''Contracts'',intEntityPortalMenuId,''Screen'',''CustomerPortal.controller.Contracts'' from tblEntityPortalMenu where strPortalMenuName = ''Billing Account'' and intPortalParentMenuId = 0
	insert into tblEntityPortalMenu(strPortalMenuName,intPortalParentMenuId,strType,strCommand)
	select ''Business Summary'',intEntityPortalMenuId,''Screen'',''CustomerPortal.controller.BusinessSummary'' from tblEntityPortalMenu where strPortalMenuName = ''Billing Account'' and intPortalParentMenuId = 0


	--Grain
	insert into tblEntityPortalMenu(strPortalMenuName,intPortalParentMenuId,strType,strCommand)
	select ''Settlements'',intEntityPortalMenuId,''Screen'',''CustomerPortal.controller.Settlements'' from tblEntityPortalMenu where strPortalMenuName =''Grain Account'' and intPortalParentMenuId = 0
	insert into tblEntityPortalMenu(strPortalMenuName,intPortalParentMenuId,strType,strCommand)
	select ''Storage'',intEntityPortalMenuId,''Screen'',''CustomerPortal.controller.Storage'' from tblEntityPortalMenu where strPortalMenuName = ''Grain Account'' and intPortalParentMenuId = 0
	insert into tblEntityPortalMenu(strPortalMenuName,intPortalParentMenuId,strType,strCommand)
	select ''Contracts'',intEntityPortalMenuId,''Screen'',''CustomerPortal.controller.GAContracts'' from tblEntityPortalMenu where strPortalMenuName = ''Grain Account'' and intPortalParentMenuId = 0
	insert into tblEntityPortalMenu(strPortalMenuName,intPortalParentMenuId,strType,strCommand)
	select ''Production History'',intEntityPortalMenuId,''Screen'',''CustomerPortal.controller.ProductionHistory'' from tblEntityPortalMenu where strPortalMenuName = ''Grain Account'' and intPortalParentMenuId = 0
	insert into tblEntityPortalMenu(strPortalMenuName,intPortalParentMenuId,strType,strCommand)
	select ''Options'',intEntityPortalMenuId,''Screen'',''CustomerPortal.controller.Options'' from tblEntityPortalMenu where strPortalMenuName = ''Grain Account'' and intPortalParentMenuId = 0
	insert into tblEntityPortalMenu(strPortalMenuName,intPortalParentMenuId,strType,strCommand)
	select ''Current Cash Bids'',intEntityPortalMenuId,''Screen'',''CustomerPortal.controller.CurrentCashBids'' from tblEntityPortalMenu where strPortalMenuName = ''Grain Account'' and intPortalParentMenuId = 0
	insert into tblEntityPortalMenu(strPortalMenuName,intPortalParentMenuId,strType,strCommand)
	select ''Business Summary'',intEntityPortalMenuId,''Screen'',''CustomerPortal.controller.GABusinessSummary'' from tblEntityPortalMenu where strPortalMenuName = ''Grain Account'' and intPortalParentMenuId = 0

	--Contact
	insert into tblEntityPortalMenu(strPortalMenuName,intPortalParentMenuId,strType,strCommand)
	select ''Customer Contact List'',intEntityPortalMenuId,''Screen'',''AccountsReceivable.controller.CustomerContactList'' from tblEntityPortalMenu where strPortalMenuName = ''Contact'' and intPortalParentMenuId = 0


	--Vendor

	insert into tblEntityPortalMenu(strPortalMenuName,intPortalParentMenuId,strType,strCommand)
	select ''Vendor'',intEntityPortalMenuId,''Screen'',''EntityManagement.view.Entity'' from tblEntityPortalMenu where strPortalMenuName = ''Vendor'' and intPortalParentMenuId = 0

	insert into tblEntityPortalMenu(strPortalMenuName,intPortalParentMenuId,strType,strCommand)
	select ''Bill'',intEntityPortalMenuId,''Screen'',''AccountsPayable.view.Bill'' from tblEntityPortalMenu where strPortalMenuName = ''Vendor'' and intPortalParentMenuId = 0

	--Newly created 
	--Help Desk

	insert into tblEntityPortalMenu(strPortalMenuName,intPortalParentMenuId,strType,strCommand)
	select ''Project Lists'',intEntityPortalMenuId,''Screen'',''HelpDesk.view.ProjectList'' from tblEntityPortalMenu where strPortalMenuName = ''Help Desk'' and intPortalParentMenuId = 0

	')	
	
	print 'Moved customer permission to entity permission'
	EXEC(N'insert into tblEntityPortalPermission
			select f.intEntityToContactId,e.intEntityPortalMenuId,1 from tblARCustomerPortalMenu a 
				join tblARCustomerPortalPermission b
					on a.intCustomerPortalMenuId = b.intCustomerPortalMenuId
				join tblARCustomerToContact c
					on b.intARCustomerToContactId = c.intARCustomerToContactId
				join tblEntityContact d
					on c.intEntityContactId = d.intEntityContactId
				join tblEntityPortalMenu e
					on e.strPortalMenuName  = a.strCustomerPortalMenuName 
						and e.strType = a.strType
				join tblEntityToContact f
					on f.intEntityContactId = c.intEntityContactId')
END 