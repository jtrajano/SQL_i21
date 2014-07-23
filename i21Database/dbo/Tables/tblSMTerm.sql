CREATE TABLE [dbo].[tblSMTerm] (
    [intTermID]        INT             IDENTITY (1, 1) NOT NULL,
    [strTerm]          NVARCHAR (100)  COLLATE Latin1_General_CI_AS NOT NULL,
    [strType]          NVARCHAR (100)  COLLATE Latin1_General_CI_AS NOT NULL,
    [dblDiscountEP]    NUMERIC (18, 6) NULL,
    [intBalanceDue]    INT             NULL,
    [intDiscountDay]   INT             NULL,
    [dblAPR]           NUMERIC (18, 6) NULL,
    [strTermCode]      NVARCHAR (100)  COLLATE Latin1_General_CI_AS NOT NULL,
    [ysnAllowEFT]      BIT             DEFAULT ((1)) NOT NULL,
    [intDayofMonthDue] INT             NULL,
    [intDueNextMonth]  INT             NULL,
	[dtmDiscountDate] DATETIME             NULL,
    [dtmDueDate]	DATETIME             NULL,
    [ysnActive]        BIT             DEFAULT ((1)) NOT NULL,
    [intSort]          INT             NULL,
    [intConcurrencyId] INT NOT NULL DEFAULT (1), 
    CONSTRAINT [PK_tblSMTerm] PRIMARY KEY CLUSTERED ([intTermID] ASC), 
    CONSTRAINT [AK_tblSMTerm_strTerm] UNIQUE ([strTerm]), 
    CONSTRAINT [AK_tblSMTerm_strTermCode] UNIQUE ([strTermCode])
);

