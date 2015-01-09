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
GO
