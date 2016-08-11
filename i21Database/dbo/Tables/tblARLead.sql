CREATE TABLE [dbo].[tblARLead]
(
	[intEntityLeadId]	INT NOT NULL,
	[dtmDateAdded]		DATETIME NULL,
	[dtmLastModified]	DATETIME NULL,
	[ysnActive]			BIT DEFAULT(0) NOT NULL,
	[intConcurrencyId]	INT DEFAULT ((0)) NOT NULL,
	
	CONSTRAINT [PK_tblARLead] PRIMARY KEY CLUSTERED ([intEntityLeadId] ASC),	

)
