CREATE TABLE [dbo].[tblSMTerm] (
    [intTermID]        INT             IDENTITY (1, 1) NOT NULL,
    [strTerm]          NVARCHAR (100)  NOT NULL,
    [strType]          NVARCHAR (100)  NOT NULL,
    [dblDiscountEP]    NUMERIC (18, 6) NULL,
    [intBalanceDue]    INT             NULL,
    [intDiscountDay]   INT             NULL,
    [dblAPR]           NUMERIC (18, 6) NULL,
    [strTermCode]      NVARCHAR (100)  NOT NULL,
    [ysnAllowEFT]      BIT             DEFAULT ((1)) NOT NULL,
    [intDayofMonthDue] INT             NULL,
    [intDueNextMonth]  INT             NULL,
    [ysnActive]        BIT             DEFAULT ((1)) NOT NULL,
    [intSort]          INT             NULL,
    [intConcurrencyId] INT NOT NULL DEFAULT (1), 
    CONSTRAINT [PK_tblSMTerm] PRIMARY KEY CLUSTERED ([intTermID] ASC)
);

