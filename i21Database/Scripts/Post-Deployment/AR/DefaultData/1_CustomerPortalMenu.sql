GO
	PRINT N'BEGIN TRUNCATE TABLE tblARCustomerPortalMenu'
	TRUNCATE TABLE tblARCustomerPortalMenu
GO
	PRINT N'END TRUNCATE TABLE tblARCustomerPortalMenu'
GO
	PRINT N'BEGIN INSERT DEFAULT CUSTOMER PORTAL MENU'
GO
SET IDENTITY_INSERT [dbo].[tblARCustomerPortalMenu] ON
INSERT [dbo].[tblARCustomerPortalMenu] ([intCustomerPortalMenuId], [strCustomerPortalMenuName], [intCustomerPortalParentMenuId], [strType], [strCommand]) VALUES (1, N'Help Desk', 0, N'Folder', NULL)
INSERT [dbo].[tblARCustomerPortalMenu] ([intCustomerPortalMenuId], [strCustomerPortalMenuName], [intCustomerPortalParentMenuId], [strType], [strCommand]) VALUES (2, N'Billing Account', 0, N'Folder', NULL)
INSERT [dbo].[tblARCustomerPortalMenu] ([intCustomerPortalMenuId], [strCustomerPortalMenuName], [intCustomerPortalParentMenuId], [strType], [strCommand]) VALUES (3, N'Grain Account', 0, N'Folder', NULL)
INSERT [dbo].[tblARCustomerPortalMenu] ([intCustomerPortalMenuId], [strCustomerPortalMenuName], [intCustomerPortalParentMenuId], [strType], [strCommand]) VALUES (4, N'Contact', 0, N'Folder', NULL)
INSERT [dbo].[tblARCustomerPortalMenu] ([intCustomerPortalMenuId], [strCustomerPortalMenuName], [intCustomerPortalParentMenuId], [strType], [strCommand]) VALUES (5, N'Tickets', 1, N'Screen', N'HelpDesk.controller.CPTickets')
INSERT [dbo].[tblARCustomerPortalMenu] ([intCustomerPortalMenuId], [strCustomerPortalMenuName], [intCustomerPortalParentMenuId], [strType], [strCommand]) VALUES (6, N'Open Tickets', 1, N'Screen', N'HelpDesk.controller.CPOpenTicket')
INSERT [dbo].[tblARCustomerPortalMenu] ([intCustomerPortalMenuId], [strCustomerPortalMenuName], [intCustomerPortalParentMenuId], [strType], [strCommand]) VALUES (7, N'Tickets Assigned to Me', 1, N'Screen', N'HelpDesk.controller.CPTicketAssigned')
INSERT [dbo].[tblARCustomerPortalMenu] ([intCustomerPortalMenuId], [strCustomerPortalMenuName], [intCustomerPortalParentMenuId], [strType], [strCommand]) VALUES (8, N'Create Ticket', 1, N'Screen', N'HelpDesk.controller.CreateTicket')
INSERT [dbo].[tblARCustomerPortalMenu] ([intCustomerPortalMenuId], [strCustomerPortalMenuName], [intCustomerPortalParentMenuId], [strType], [strCommand]) VALUES (9, N'Billing Account', 2, N'Screen', N'CustomerPortal.controller.BillingAccount')
INSERT [dbo].[tblARCustomerPortalMenu] ([intCustomerPortalMenuId], [strCustomerPortalMenuName], [intCustomerPortalParentMenuId], [strType], [strCommand]) VALUES (10, N'Invoice Credits', 2, N'Screen', N'CustomerPortal.controller.InvoicesCredits')
INSERT [dbo].[tblARCustomerPortalMenu] ([intCustomerPortalMenuId], [strCustomerPortalMenuName], [intCustomerPortalParentMenuId], [strType], [strCommand]) VALUES (11, N'Payments', 2, N'Screen', N'CustomerPortal.controller.Payments')
INSERT [dbo].[tblARCustomerPortalMenu] ([intCustomerPortalMenuId], [strCustomerPortalMenuName], [intCustomerPortalParentMenuId], [strType], [strCommand]) VALUES (12, N'Purchase', 2, N'Screen', N'CustomerPortal.controller.Purchases')
INSERT [dbo].[tblARCustomerPortalMenu] ([intCustomerPortalMenuId], [strCustomerPortalMenuName], [intCustomerPortalParentMenuId], [strType], [strCommand]) VALUES (13, N'Orders', 2, N'Screen', N'CustomerPortal.controller.Orders')
INSERT [dbo].[tblARCustomerPortalMenu] ([intCustomerPortalMenuId], [strCustomerPortalMenuName], [intCustomerPortalParentMenuId], [strType], [strCommand]) VALUES (14, N'Contracts', 2, N'Screen', N'CustomerPortal.controller.Contracts')
INSERT [dbo].[tblARCustomerPortalMenu] ([intCustomerPortalMenuId], [strCustomerPortalMenuName], [intCustomerPortalParentMenuId], [strType], [strCommand]) VALUES (15, N'Business Summary', 2, N'Screen', N'CustomerPortal.controller.BusinessSummary')
INSERT [dbo].[tblARCustomerPortalMenu] ([intCustomerPortalMenuId], [strCustomerPortalMenuName], [intCustomerPortalParentMenuId], [strType], [strCommand]) VALUES (16, N'Grain Account', 3, N'Screen', N'CustomerPortal.controller.GrainAccount')
INSERT [dbo].[tblARCustomerPortalMenu] ([intCustomerPortalMenuId], [strCustomerPortalMenuName], [intCustomerPortalParentMenuId], [strType], [strCommand]) VALUES (17, N'Settlements', 3, N'Screen', N'CustomerPortal.controller.Settlements')
INSERT [dbo].[tblARCustomerPortalMenu] ([intCustomerPortalMenuId], [strCustomerPortalMenuName], [intCustomerPortalParentMenuId], [strType], [strCommand]) VALUES (18, N'Storage', 3, N'Screen', N'CustomerPortal.controller.Storage')
INSERT [dbo].[tblARCustomerPortalMenu] ([intCustomerPortalMenuId], [strCustomerPortalMenuName], [intCustomerPortalParentMenuId], [strType], [strCommand]) VALUES (19, N'Contracts', 3, N'Screen', N'CustomerPortal.controller.GAContracts')
INSERT [dbo].[tblARCustomerPortalMenu] ([intCustomerPortalMenuId], [strCustomerPortalMenuName], [intCustomerPortalParentMenuId], [strType], [strCommand]) VALUES (20, N'Production History', 3, N'Screen', N'CustomerPortal.controller.ProductionHistory')
INSERT [dbo].[tblARCustomerPortalMenu] ([intCustomerPortalMenuId], [strCustomerPortalMenuName], [intCustomerPortalParentMenuId], [strType], [strCommand]) VALUES (21, N'Options', 3, N'Screen', N'CustomerPortal.controller.Options')
INSERT [dbo].[tblARCustomerPortalMenu] ([intCustomerPortalMenuId], [strCustomerPortalMenuName], [intCustomerPortalParentMenuId], [strType], [strCommand]) VALUES (22, N'Current Cash Bids', 3, N'Screen', N'CustomerPortal.controller.CurrentCashBids')
INSERT [dbo].[tblARCustomerPortalMenu] ([intCustomerPortalMenuId], [strCustomerPortalMenuName], [intCustomerPortalParentMenuId], [strType], [strCommand]) VALUES (23, N'Business Summary', 3, N'Screen', N'CustomerPortal.controller.GABusinessSummary')
INSERT [dbo].[tblARCustomerPortalMenu] ([intCustomerPortalMenuId], [strCustomerPortalMenuName], [intCustomerPortalParentMenuId], [strType], [strCommand]) VALUES (24, N'Customer Contact List', 4, N'Screen', N'AccountsReceivable.controller.CustomerContactList')
--INSERT [dbo].[tblARCustomerPortalMenu] ([intCustomerPortalMenuId], [strCustomerPortalMenuName], [intCustomerPortalParentMenuId], [strType], [strCommand]) VALUES (25, N'Export Hours Worked', 1, N'Screen', N'HelpDesk.controller.ExportHoursWorked')
SET IDENTITY_INSERT [dbo].[tblARCustomerPortalMenu] OFF

GO
	PRINT N'END INSERT DEFAULT CUSTOMER PORTAL MENU'
GO
