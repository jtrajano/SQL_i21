/* used by Import Budget CSV as temporary table*/
CREATE TABLE [dbo].[tblFRImportLog]
(
	[intId] [int] IDENTITY(1,1) NOT NULL,
	[guidSessionId] [uniqueidentifier] NOT NULL,
	[strTitle] [nvarchar](500) COLLATE Latin1_General_CI_AS NULL,
	[strDescription] [varchar](500) COLLATE Latin1_General_CI_AS NULL,
	[dtmAdded] [datetime] NULL,
	[intConcurrencyId] [int] DEFAULT 1 NULL
) 