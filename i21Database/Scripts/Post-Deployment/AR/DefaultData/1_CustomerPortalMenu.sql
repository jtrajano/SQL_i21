--GO
	--PRINT N'BEGIN TRUNCATE TABLE tblARCustomerPortalMenu'
	--TRUNCATE TABLE tblARCustomerPortalMenu
--GO
--	PRINT N'END TRUNCATE TABLE tblARCustomerPortalMenu'
GO
	PRINT N'BEGIN INSERT DEFAULT CUSTOMER PORTAL MENU'
GO
SET IDENTITY_INSERT [dbo].[tblARCustomerPortalMenu] ON

IF NOT EXISTS (SELECT TOP 1 1 FROM tblARCustomerPortalMenu WHERE intCustomerPortalMenuId = 1)
	INSERT [dbo].[tblARCustomerPortalMenu] ([intCustomerPortalMenuId], [strCustomerPortalMenuName], [intCustomerPortalParentMenuId], [strType], [strCommand]) VALUES (1, N'Help Desk', 0, N'Folder', NULL)
else
	Update [dbo].[tblARCustomerPortalMenu] set [strCustomerPortalMenuName] = N'Help Desk', [intCustomerPortalParentMenuId] = 0, [strType] = N'Folder', [strCommand] = null where intCustomerPortalMenuId = 1

IF NOT EXISTS (SELECT TOP 1 1 FROM tblARCustomerPortalMenu WHERE intCustomerPortalMenuId = 2)
	INSERT [dbo].[tblARCustomerPortalMenu] ([intCustomerPortalMenuId], [strCustomerPortalMenuName], [intCustomerPortalParentMenuId], [strType], [strCommand]) VALUES (2, N'Billing Account', 0, N'Folder', NULL)
else
	Update [dbo].[tblARCustomerPortalMenu] set [strCustomerPortalMenuName] = N'Billing Account', [intCustomerPortalParentMenuId] = 0, [strType] = N'Folder', [strCommand] = null where intCustomerPortalMenuId = 2

IF NOT EXISTS (SELECT TOP 1 1 FROM tblARCustomerPortalMenu WHERE intCustomerPortalMenuId = 3)
	INSERT [dbo].[tblARCustomerPortalMenu] ([intCustomerPortalMenuId], [strCustomerPortalMenuName], [intCustomerPortalParentMenuId], [strType], [strCommand]) VALUES (3, N'Grain Account', 0, N'Folder', NULL)
else
	Update [dbo].[tblARCustomerPortalMenu] set [strCustomerPortalMenuName] = N'Grain Account', [intCustomerPortalParentMenuId] = 0, [strType] = N'Folder', [strCommand] = null where intCustomerPortalMenuId = 3

IF NOT EXISTS (SELECT TOP 1 1 FROM tblARCustomerPortalMenu WHERE intCustomerPortalMenuId = 4)
	INSERT [dbo].[tblARCustomerPortalMenu] ([intCustomerPortalMenuId], [strCustomerPortalMenuName], [intCustomerPortalParentMenuId], [strType], [strCommand]) VALUES (4, N'Contact', 0, N'Folder', NULL)
else
	Update [dbo].[tblARCustomerPortalMenu] set [strCustomerPortalMenuName] = N'Contact', [intCustomerPortalParentMenuId] = 0, [strType] = N'Folder', [strCommand] = null where intCustomerPortalMenuId = 4

IF NOT EXISTS (SELECT TOP 1 1 FROM tblARCustomerPortalMenu WHERE intCustomerPortalMenuId = 5)
	INSERT [dbo].[tblARCustomerPortalMenu] ([intCustomerPortalMenuId], [strCustomerPortalMenuName], [intCustomerPortalParentMenuId], [strType], [strCommand]) VALUES (5, N'Create Ticket', 1, N'Screen', N'HelpDesk.controller.CreateTicket')
else
	Update [dbo].[tblARCustomerPortalMenu] set [strCustomerPortalMenuName] = N'Create Ticket', [intCustomerPortalParentMenuId] = 1, [strType] = N'Screen', [strCommand] = N'HelpDesk.controller.CreateTicket' where intCustomerPortalMenuId = 5

IF NOT EXISTS (SELECT TOP 1 1 FROM tblARCustomerPortalMenu WHERE intCustomerPortalMenuId = 6)
	INSERT [dbo].[tblARCustomerPortalMenu] ([intCustomerPortalMenuId], [strCustomerPortalMenuName], [intCustomerPortalParentMenuId], [strType], [strCommand]) VALUES (6, N'Tickets', 1, N'Screen', N'HelpDesk.controller.CPTickets')
else
	Update [dbo].[tblARCustomerPortalMenu] set [strCustomerPortalMenuName] = N'Tickets', [intCustomerPortalParentMenuId] = 1, [strType] = N'Screen', [strCommand] = N'HelpDesk.controller.CPTickets' where intCustomerPortalMenuId = 6

IF NOT EXISTS (SELECT TOP 1 1 FROM tblARCustomerPortalMenu WHERE intCustomerPortalMenuId = 7)
	INSERT [dbo].[tblARCustomerPortalMenu] ([intCustomerPortalMenuId], [strCustomerPortalMenuName], [intCustomerPortalParentMenuId], [strType], [strCommand]) VALUES (7, N'Open Tickets', 1, N'Screen', N'HelpDesk.controller.CPOpenTicket')
else
	Update [dbo].[tblARCustomerPortalMenu] set [strCustomerPortalMenuName] = N'Open Tickets', [intCustomerPortalParentMenuId] = 1, [strType] = N'Screen', [strCommand] = N'HelpDesk.controller.CPOpenTicket' where intCustomerPortalMenuId = 7

IF NOT EXISTS (SELECT TOP 1 1 FROM tblARCustomerPortalMenu WHERE intCustomerPortalMenuId = 8)
	INSERT [dbo].[tblARCustomerPortalMenu] ([intCustomerPortalMenuId], [strCustomerPortalMenuName], [intCustomerPortalParentMenuId], [strType], [strCommand]) VALUES (8, N'Tickets Reported by Me', 1, N'Screen', N'HelpDesk.controller.CPTicketsReported')
else
	Update [dbo].[tblARCustomerPortalMenu] set [strCustomerPortalMenuName] = N'Tickets Reported by Me', [intCustomerPortalParentMenuId] = 1, [strType] = N'Screen', [strCommand] = N'HelpDesk.controller.CPTicketsReported' where intCustomerPortalMenuId = 8

IF NOT EXISTS (SELECT TOP 1 1 FROM tblARCustomerPortalMenu WHERE intCustomerPortalMenuId = 9)
	INSERT [dbo].[tblARCustomerPortalMenu] ([intCustomerPortalMenuId], [strCustomerPortalMenuName], [intCustomerPortalParentMenuId], [strType], [strCommand]) VALUES (9, N'Billing Account', 2, N'Screen', N'CustomerPortal.controller.BillingAccount')
else
	Update [dbo].[tblARCustomerPortalMenu] set [strCustomerPortalMenuName] = N'Billing Account', [intCustomerPortalParentMenuId] = 2, [strType] = N'Screen', [strCommand] = N'CustomerPortal.controller.BillingAccount' where intCustomerPortalMenuId = 9

IF NOT EXISTS (SELECT TOP 1 1 FROM tblARCustomerPortalMenu WHERE intCustomerPortalMenuId = 10)
	INSERT [dbo].[tblARCustomerPortalMenu] ([intCustomerPortalMenuId], [strCustomerPortalMenuName], [intCustomerPortalParentMenuId], [strType], [strCommand]) VALUES (10, N'Invoice Credits', 2, N'Screen', N'CustomerPortal.controller.InvoicesCredits')
else
	Update [dbo].[tblARCustomerPortalMenu] set [strCustomerPortalMenuName] = N'Invoice Credits', [intCustomerPortalParentMenuId] = 2, [strType] = N'Screen', [strCommand] = N'CustomerPortal.controller.InvoicesCredits' where intCustomerPortalMenuId = 10

IF NOT EXISTS (SELECT TOP 1 1 FROM tblARCustomerPortalMenu WHERE intCustomerPortalMenuId = 11)
	INSERT [dbo].[tblARCustomerPortalMenu] ([intCustomerPortalMenuId], [strCustomerPortalMenuName], [intCustomerPortalParentMenuId], [strType], [strCommand]) VALUES (11, N'Payments', 2, N'Screen', N'CustomerPortal.controller.Payments')
else
	Update [dbo].[tblARCustomerPortalMenu] set [strCustomerPortalMenuName] = N'Payments', [intCustomerPortalParentMenuId] = 2, [strType] = N'Screen', [strCommand] = N'CustomerPortal.controller.Payments' where intCustomerPortalMenuId = 11

IF NOT EXISTS (SELECT TOP 1 1 FROM tblARCustomerPortalMenu WHERE intCustomerPortalMenuId = 12)
	INSERT [dbo].[tblARCustomerPortalMenu] ([intCustomerPortalMenuId], [strCustomerPortalMenuName], [intCustomerPortalParentMenuId], [strType], [strCommand]) VALUES (12, N'Purchases', 2, N'Screen', N'CustomerPortal.controller.Purchases')
else
	Update [dbo].[tblARCustomerPortalMenu] set [strCustomerPortalMenuName] = N'Purchases', [intCustomerPortalParentMenuId] = 2, [strType] = N'Screen', [strCommand] = N'CustomerPortal.controller.Purchases' where intCustomerPortalMenuId = 12

IF NOT EXISTS (SELECT TOP 1 1 FROM tblARCustomerPortalMenu WHERE intCustomerPortalMenuId = 13)
	INSERT [dbo].[tblARCustomerPortalMenu] ([intCustomerPortalMenuId], [strCustomerPortalMenuName], [intCustomerPortalParentMenuId], [strType], [strCommand]) VALUES (13, N'Orders', 2, N'Screen', N'CustomerPortal.controller.Orders')
else
	Update [dbo].[tblARCustomerPortalMenu] set [strCustomerPortalMenuName] = N'Orders', [intCustomerPortalParentMenuId] = 2, [strType] = N'Screen', [strCommand] = N'CustomerPortal.controller.Orders' where intCustomerPortalMenuId = 13

IF NOT EXISTS (SELECT TOP 1 1 FROM tblARCustomerPortalMenu WHERE intCustomerPortalMenuId = 14)
	INSERT [dbo].[tblARCustomerPortalMenu] ([intCustomerPortalMenuId], [strCustomerPortalMenuName], [intCustomerPortalParentMenuId], [strType], [strCommand]) VALUES (14, N'Contracts', 2, N'Screen', N'CustomerPortal.controller.Contracts')
else
	Update [dbo].[tblARCustomerPortalMenu] set [strCustomerPortalMenuName] = N'Contracts', [intCustomerPortalParentMenuId] = 2, [strType] = N'Screen', [strCommand] = N'CustomerPortal.controller.Contracts' where intCustomerPortalMenuId = 14

IF NOT EXISTS (SELECT TOP 1 1 FROM tblARCustomerPortalMenu WHERE intCustomerPortalMenuId = 15)
	INSERT [dbo].[tblARCustomerPortalMenu] ([intCustomerPortalMenuId], [strCustomerPortalMenuName], [intCustomerPortalParentMenuId], [strType], [strCommand]) VALUES (15, N'Business Summary', 2, N'Screen', N'CustomerPortal.controller.BusinessSummary')
else
	Update [dbo].[tblARCustomerPortalMenu] set [strCustomerPortalMenuName] = N'Business Summary', [intCustomerPortalParentMenuId] = 2, [strType] = N'Screen', [strCommand] = N'CustomerPortal.controller.BusinessSummary' where intCustomerPortalMenuId = 15

IF NOT EXISTS (SELECT TOP 1 1 FROM tblARCustomerPortalMenu WHERE intCustomerPortalMenuId = 16)
	INSERT [dbo].[tblARCustomerPortalMenu] ([intCustomerPortalMenuId], [strCustomerPortalMenuName], [intCustomerPortalParentMenuId], [strType], [strCommand]) VALUES (16, N'Grain Account', 3, N'Screen', N'CustomerPortal.controller.GrainAccount')
else
	Update [dbo].[tblARCustomerPortalMenu] set [strCustomerPortalMenuName] = N'Grain Account', [intCustomerPortalParentMenuId] = 3, [strType] = N'Screen', [strCommand] = N'CustomerPortal.controller.GrainAccount' where intCustomerPortalMenuId = 16

IF NOT EXISTS (SELECT TOP 1 1 FROM tblARCustomerPortalMenu WHERE intCustomerPortalMenuId = 17)
	INSERT [dbo].[tblARCustomerPortalMenu] ([intCustomerPortalMenuId], [strCustomerPortalMenuName], [intCustomerPortalParentMenuId], [strType], [strCommand]) VALUES (17, N'Settlements', 3, N'Screen', N'CustomerPortal.controller.Settlements')
else
	Update [dbo].[tblARCustomerPortalMenu] set [strCustomerPortalMenuName] = N'Settlements', [intCustomerPortalParentMenuId] = 3, [strType] = N'Screen', [strCommand] = N'CustomerPortal.controller.Settlements' where intCustomerPortalMenuId = 17

IF NOT EXISTS (SELECT TOP 1 1 FROM tblARCustomerPortalMenu WHERE intCustomerPortalMenuId = 18)
	INSERT [dbo].[tblARCustomerPortalMenu] ([intCustomerPortalMenuId], [strCustomerPortalMenuName], [intCustomerPortalParentMenuId], [strType], [strCommand]) VALUES (18, N'Storage', 3, N'Screen', N'CustomerPortal.controller.Storage')
else
	Update [dbo].[tblARCustomerPortalMenu] set [strCustomerPortalMenuName] = N'Storage', [intCustomerPortalParentMenuId] = 3, [strType] = N'Screen', [strCommand] = N'CustomerPortal.controller.Storage' where intCustomerPortalMenuId = 18

IF NOT EXISTS (SELECT TOP 1 1 FROM tblARCustomerPortalMenu WHERE intCustomerPortalMenuId = 19)
	INSERT [dbo].[tblARCustomerPortalMenu] ([intCustomerPortalMenuId], [strCustomerPortalMenuName], [intCustomerPortalParentMenuId], [strType], [strCommand]) VALUES (19, N'Contracts', 3, N'Screen', N'CustomerPortal.controller.GAContracts')
else
	Update [dbo].[tblARCustomerPortalMenu] set [strCustomerPortalMenuName] = N'Contracts', [intCustomerPortalParentMenuId] = 3, [strType] = N'Screen', [strCommand] = N'CustomerPortal.controller.GAContracts' where intCustomerPortalMenuId = 19

IF NOT EXISTS (SELECT TOP 1 1 FROM tblARCustomerPortalMenu WHERE intCustomerPortalMenuId = 20)
	INSERT [dbo].[tblARCustomerPortalMenu] ([intCustomerPortalMenuId], [strCustomerPortalMenuName], [intCustomerPortalParentMenuId], [strType], [strCommand]) VALUES (20, N'Production History', 3, N'Screen', N'CustomerPortal.controller.ProductionHistory')
else
	Update [dbo].[tblARCustomerPortalMenu] set [strCustomerPortalMenuName] = N'Production History', [intCustomerPortalParentMenuId] = 3, [strType] = N'Screen', [strCommand] = N'CustomerPortal.controller.ProductionHistory' where intCustomerPortalMenuId = 20

IF NOT EXISTS (SELECT TOP 1 1 FROM tblARCustomerPortalMenu WHERE intCustomerPortalMenuId = 21)
	INSERT [dbo].[tblARCustomerPortalMenu] ([intCustomerPortalMenuId], [strCustomerPortalMenuName], [intCustomerPortalParentMenuId], [strType], [strCommand]) VALUES (21, N'Options', 3, N'Screen', N'CustomerPortal.controller.Options')
else
	Update [dbo].[tblARCustomerPortalMenu] set [strCustomerPortalMenuName] = N'Options', [intCustomerPortalParentMenuId] = 3, [strType] = N'Screen', [strCommand] = N'CustomerPortal.controller.Options' where intCustomerPortalMenuId = 21

IF NOT EXISTS (SELECT TOP 1 1 FROM tblARCustomerPortalMenu WHERE intCustomerPortalMenuId = 22)
	INSERT [dbo].[tblARCustomerPortalMenu] ([intCustomerPortalMenuId], [strCustomerPortalMenuName], [intCustomerPortalParentMenuId], [strType], [strCommand]) VALUES (22, N'Current Cash Bids', 3, N'Screen', N'CustomerPortal.controller.CurrentCashBids')
else
	Update [dbo].[tblARCustomerPortalMenu] set [strCustomerPortalMenuName] = N'Current Cash Bids', [intCustomerPortalParentMenuId] = 3, [strType] = N'Screen', [strCommand] = N'CustomerPortal.controller.CurrentCashBids' where intCustomerPortalMenuId = 22

IF NOT EXISTS (SELECT TOP 1 1 FROM tblARCustomerPortalMenu WHERE intCustomerPortalMenuId = 23)
	INSERT [dbo].[tblARCustomerPortalMenu] ([intCustomerPortalMenuId], [strCustomerPortalMenuName], [intCustomerPortalParentMenuId], [strType], [strCommand]) VALUES (23, N'Business Summary', 3, N'Screen', N'CustomerPortal.controller.GABusinessSummary')
else
	Update [dbo].[tblARCustomerPortalMenu] set [strCustomerPortalMenuName] = N'Business Summary', [intCustomerPortalParentMenuId] = 3, [strType] = N'Screen', [strCommand] = N'CustomerPortal.controller.GABusinessSummary' where intCustomerPortalMenuId = 23

IF NOT EXISTS (SELECT TOP 1 1 FROM tblARCustomerPortalMenu WHERE intCustomerPortalMenuId = 24)
	INSERT [dbo].[tblARCustomerPortalMenu] ([intCustomerPortalMenuId], [strCustomerPortalMenuName], [intCustomerPortalParentMenuId], [strType], [strCommand]) VALUES (24, N'Customer Contact List', 4, N'Screen', N'AccountsReceivable.view.CustomerContactList')
else
	Update [dbo].[tblARCustomerPortalMenu] set [strCustomerPortalMenuName] = N'Customer Contact List', [intCustomerPortalParentMenuId] = 4, [strType] = N'Screen', [strCommand] = N'AccountsReceivable.view.CustomerContactList' where intCustomerPortalMenuId = 24
--INSERT [dbo].[tblARCustomerPortalMenu] ([intCustomerPortalMenuId], [strCustomerPortalMenuName], [intCustomerPortalParentMenuId], [strType], [strCommand]) VALUES (25, N'Export Hours Worked', 1, N'Screen', N'HelpDesk.controller.ExportHoursWorked')
SET IDENTITY_INSERT [dbo].[tblARCustomerPortalMenu] OFF

GO
	PRINT N'END INSERT DEFAULT CUSTOMER PORTAL MENU'
GO
