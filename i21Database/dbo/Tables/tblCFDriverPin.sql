
CREATE TABLE [dbo].[tblCFDriverPin](
	[intDriverPinId]			INT				IDENTITY(1,1)					NOT NULL,
	[intAccountId]				INT												NULL,
	[strDriverPinNumber]		NVARCHAR(250)	COLLATE Latin1_General_CI_AS	NULL,
	[strDriverDescription]		NVARCHAR(500)	COLLATE Latin1_General_CI_AS	NULL,
	[ysnActive]					BIT												NULL,
	[strComment]				NVARCHAR(MAX)	COLLATE Latin1_General_CI_AS	NULL,
	[intConcurrencyId]			INT             CONSTRAINT [DF_tblCFDriverPin_intConcurrencyId] DEFAULT ((1)) NULL,
	CONSTRAINT [PK_tblCFDriverPin] PRIMARY KEY CLUSTERED ([intDriverPinId] ASC),
) ON [PRIMARY]
GO


CREATE UNIQUE NONCLUSTERED INDEX [tblCFDriverPin_UniqueAccountDriverPinNumber]
    ON [dbo].[tblCFDriverPin]([intAccountId] ASC, [strDriverPinNumber] ASC) WITH (FILLFACTOR = 70);
GO

