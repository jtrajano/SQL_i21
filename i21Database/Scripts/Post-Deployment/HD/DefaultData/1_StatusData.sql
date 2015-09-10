/*
Post-Deployment Script Template							
--------------------------------------------------------------------------------------
 This file contains SQL statements that will be appended to the build script.		
 Use SQLCMD syntax to include a file in the post-deployment script.			
 Example:      :r .\myfile.sql								
 Use SQLCMD syntax to reference a variable in the post-deployment script.		
 Example:      :setvar TableName MyTable							
               SELECT * FROM [$(TableName)]					
--------------------------------------------------------------------------------------
*/

GO
	PRINT N'BEGIN INSERT DEFAULT HELP DESK STATUS'
GO

IF NOT EXISTS (SELECT TOP 1 1 FROM [tblHDTicketStatus] WHERE strStatus = 'Open') INSERT [dbo].[tblHDTicketStatus] ([strStatus], [strDescription], [strIcon], [strFontColor], [strBackColor], [intSort], [intConcurrencyId]) VALUES (N'Open', N'Open', NULL, NULL, NULL, 1, 1)
IF NOT EXISTS (SELECT TOP 1 1 FROM [tblHDTicketStatus] WHERE strStatus = 'Closed') INSERT [dbo].[tblHDTicketStatus] ([strStatus], [strDescription], [strIcon], [strFontColor], [strBackColor], [intSort], [intConcurrencyId]) VALUES (N'Closed', N'Closed', NULL, NULL, NULL, 2, 1)
IF NOT EXISTS (SELECT TOP 1 1 FROM [tblHDTicketStatus] WHERE strStatus = 'Reopen') INSERT [dbo].[tblHDTicketStatus] ([strStatus], [strDescription], [strIcon], [strFontColor], [strBackColor], [intSort], [intConcurrencyId]) VALUES (N'Reopen', N'Reopen', NULL, NULL, NULL, 3, 1)

GO
	PRINT N'END INSERT DEFAULT HELP DESK STATUS'
	PRINT N'BEGIN INSERT DEFAULT HELP DESK TICKET LINK TYPE'
GO

SET IDENTITY_INSERT [dbo].[tblHDTicketLinkType] ON
IF NOT EXISTS (SELECT TOP 1 1 FROM [tblHDTicketLinkType] WHERE strLinkType = 'relates to') INSERT [dbo].[tblHDTicketLinkType]
																							(
																								[intTicketLinkTypeId]
																								,[strLinkType]
																								,[intTicketLinkTypeCounterId]
																								,[intSort]
																								,[intConcurrencyId]
																							) VALUES (
																								1
																								,N'relates to'
																								,1
																								,1
																								,1
																							)

IF NOT EXISTS (SELECT TOP 1 1 FROM [tblHDTicketLinkType] WHERE strLinkType = 'is blocked by') INSERT [dbo].[tblHDTicketLinkType]
																							(
																								[intTicketLinkTypeId]
																								,[strLinkType]
																								,[intTicketLinkTypeCounterId]
																								,[intSort]
																								,[intConcurrencyId]
																							) VALUES (
																								2
																								,N'is blocked by'
																								,3
																								,2
																								,1
																							)

IF NOT EXISTS (SELECT TOP 1 1 FROM [tblHDTicketLinkType] WHERE strLinkType = 'blocks') INSERT [dbo].[tblHDTicketLinkType]
																							(
																								[intTicketLinkTypeId]
																								,[strLinkType]
																								,[intTicketLinkTypeCounterId]
																								,[intSort]
																								,[intConcurrencyId]
																							) VALUES (
																								3
																								,N'blocks'
																								,2
																								,3
																								,1
																							)

IF NOT EXISTS (SELECT TOP 1 1 FROM [tblHDTicketLinkType] WHERE strLinkType = 'is duplicated by') INSERT [dbo].[tblHDTicketLinkType]
																							(
																								[intTicketLinkTypeId]
																								,[strLinkType]
																								,[intTicketLinkTypeCounterId]
																								,[intSort]
																								,[intConcurrencyId]
																							) VALUES (
																								4
																								,N'is duplicated by'
																								,5
																								,4
																								,1
																							)

IF NOT EXISTS (SELECT TOP 1 1 FROM [tblHDTicketLinkType] WHERE strLinkType = 'duplicates') INSERT [dbo].[tblHDTicketLinkType]
																							(
																								[intTicketLinkTypeId]
																								,[strLinkType]
																								,[intTicketLinkTypeCounterId]
																								,[intSort]
																								,[intConcurrencyId]
																							) VALUES (
																								5
																								,N'duplicates'
																								,4
																								,5
																								,1
																							)

SET IDENTITY_INSERT [dbo].[tblHDTicketLinkType] OFF

GO
	PRINT N'END INSERT DEFAULT HELP DESK TICKET LINK TYPE'
GO