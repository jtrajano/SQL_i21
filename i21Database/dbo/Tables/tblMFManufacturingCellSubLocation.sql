/*
 * Created By: Jonathan Valenzuela
 * Date Created: 11/29/2022
 * Purpose: Storage/Sub Location of Manufacturing that will be used for Auto Blending
 * JIRA: http://jira.irelyserver.com/browse/MFG-4575
*/

CREATE TABLE [dbo].[tblMFManufacturingCellSubLocation]
(
	[intManufacturingCellSubLocationId] [int] IDENTITY(1,1) NOT NULL,
	[intManufacturingCellId] [int] NOT NULL,
	[intCompanyLocationSubLocationId] [int] NOT NULL,
	[intCreatedUserId] [int] NULL,
	[dtmCreated] [datetime] NULL,
	[intLastModifiedUserId] [int] NULL,
	[dtmLastModified] [datetime] NULL,
	[intConcurrencyId] [int] NULL,

	CONSTRAINT [PK_tblMFManufacturingCellSubLocation] PRIMARY KEY ([intManufacturingCellSubLocationId])
)