CREATE TABLE [dbo].[tblTRFuelTerminal] (
    [intFuelTerminalId]			        INT            IDENTITY (1, 1) NOT NULL,
    
    [strFuelTerminalNo]				    NVARCHAR (50) COLLATE Latin1_General_CI_AS NOT NULL,
    [strFuelTerminalName]				NVARCHAR (100) COLLATE Latin1_General_CI_AS NOT NULL,

    [strAddress]					NVARCHAR (MAX) COLLATE Latin1_General_CI_AS NULL,
    [strCity]						NVARCHAR (MAX) COLLATE Latin1_General_CI_AS NULL,
    [strState]						NVARCHAR (MAX) COLLATE Latin1_General_CI_AS NULL,
    [strZipCode]					NVARCHAR (MAX) COLLATE Latin1_General_CI_AS NULL,    
    [dblLongitude]					NUMERIC (18, 6) DEFAULT ((0)) NULL,
    [dblLatitude]					NUMERIC (18, 6) DEFAULT ((0)) NULL,	
	
    [intAverageLoadTime]			INT            NULL,

	
    [guiApiUniqueId] UNIQUEIDENTIFIER NULL,
    [intConcurrencyId] 		        INT CONSTRAINT [DF_tblTRTransportTerminal_ConcurrencyId] DEFAULT ((0)) NOT NULL,	

    CONSTRAINT [PK_dbo.tblTRFuelTerminal] PRIMARY KEY CLUSTERED ([intFuelTerminalId] ASC),    
	CONSTRAINT [AK_tblTRFuelTerminal_Fuel_Terminal_No] UNIQUE ([strFuelTerminalNo]),
);

GO

