﻿CREATE TABLE [dbo].[tblARSalespersonFuelTerminal] (
    [intSalesoersonFuelTerminalId]		INT                 IDENTITY (1, 1) NOT NULL,
    [intEntitySalespersonId]            INT                 NOT NULL,
    [intFuelTerminalId]			        INT				    NULL,
    
    [intConcurrencyId]                  INT                 DEFAULT(1) NOT NULL,
    [guiApiUniqueId]                    UNIQUEIDENTIFIER    NULL,

    CONSTRAINT [PK_tblARSalespersonFuelTerminal] PRIMARY KEY CLUSTERED ([intSalesoersonFuelTerminalId] ASC),
	CONSTRAINT [FK_tblARSalespersonFuelTerminal_tblARSalesperson] FOREIGN KEY ([intEntitySalespersonId]) REFERENCES [tblARSalesperson]([intEntityId]),
	CONSTRAINT [FK_tblARSalespersonFuelTerminal_tblTRFuelTerminal] FOREIGN KEY ([intFuelTerminalId]) REFERENCES [tblTRFuelTerminal]([intFuelTerminalId]),
	
);


