CREATE TABLE [dbo].[tblARLeadSourceList]
(
	[intLeadSourceId] INT NOT NULL IDENTITY(1,1),
	[strValue]			NVARCHAR(200),
	[intConcurrencyId]	INT DEFAULT ((0)) NOT NULL,	
	
	CONSTRAINT [PK_tblARLeadSourceList] PRIMARY KEY CLUSTERED ([intLeadSourceId] ASC),
	CONSTRAINT [UQ_tblARLeadSourceList_strValue] UNIQUE NONCLUSTERED ([strValue] ASC)

)
