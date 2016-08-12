CREATE TABLE [dbo].[tblARLead]
(
	[intEntityLeadId]	INT NOT NULL,
	[intLeadSourceId]	INT NULL,
	[dtmDateAdded]		DATETIME NULL,
	[dtmLastModified]	DATETIME NULL,
	[ysnActive]			BIT DEFAULT(0) NOT NULL,
	[intConcurrencyId]	INT DEFAULT ((0)) NOT NULL,
	
	CONSTRAINT [PK_tblARLead] PRIMARY KEY CLUSTERED ([intEntityLeadId] ASC),
	CONSTRAINT [FK_tblARLead_tblARLeadSourceList_intVendorDefaultId] FOREIGN KEY ([intLeadSourceId]) REFERENCES [dbo].[tblARLeadSourceList] ([intLeadSourceId]),	

)
