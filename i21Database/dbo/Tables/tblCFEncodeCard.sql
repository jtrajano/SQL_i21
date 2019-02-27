CREATE TABLE [dbo].[tblCFEncodeCard] (
    [intEncodeCardId]         INT            IDENTITY (1, 1) NOT NULL,
    [intAccountId]			  INT			 NULL,
    [intCardId]				  INT			 NULL,
	[intNetworkId]			  INT			 NULL,
	[strCardNumber]           NVARCHAR (MAX) COLLATE Latin1_General_CI_AS NULL,
    [strNetwork]			  NVARCHAR (MAX) COLLATE Latin1_General_CI_AS NULL,
	[intConcurrencyId]		  INT             NULL,
    CONSTRAINT [PK_tblCFEncodeCard] PRIMARY KEY CLUSTERED ([intEncodeCardId] ASC)
);