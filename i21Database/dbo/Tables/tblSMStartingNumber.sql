CREATE TABLE [dbo].[tblSMStartingNumber] (
    [intStartingNumberId]                INT            IDENTITY (1, 1) NOT NULL,
    [strTransactionType]   NVARCHAR (100) COLLATE Latin1_General_CI_AS NOT NULL,
    [strPrefix]            NVARCHAR (50)  COLLATE Latin1_General_CI_AS NOT NULL,
    [intNumber]            INT            NOT NULL,
	[intDigits]            INT            NULL,
    [strModule]            NVARCHAR (50)  COLLATE Latin1_General_CI_AS NOT NULL,
    [ysnUseLocation]       BIT            NOT NULL DEFAULT 0,
    [ysnEnable]            BIT            NOT NULL DEFAULT 0,
    [intConcurrencyId]     INT            DEFAULT 1 NOT NULL, 
    CONSTRAINT [PK_tblSMStartingNumber] PRIMARY KEY ([intStartingNumberId] ASC) ,
	CONSTRAINT [AK_tblSMStartingNumber_strTransactionType] UNIQUE NONCLUSTERED ([strTransactionType] ASC)

);


GO
