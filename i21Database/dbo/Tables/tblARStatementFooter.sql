CREATE TABLE [dbo].[tblARStatementFooter] (
    [intStatementFooterId]          INT             IDENTITY (1, 1) NOT NULL,
    [strStatementCode]              NVARCHAR (10)   COLLATE Latin1_General_CI_AS NOT NULL,
    [ysnResetDiscountsOnStatements] BIT             NOT NULL,
    [dtmDiscountDate]               DATETIME        NULL,
    [dblDiscountPercentage]         NUMERIC (18, 6) NULL,
    [dtmServiceChargeDate]          DATETIME        NULL,
    [strServiceChargePeriod]        NVARCHAR (50)   COLLATE Latin1_General_CI_AS NULL,
    [strDescription]                NVARCHAR (255)  COLLATE Latin1_General_CI_AS NULL,
    [strBudgetStatementDescription] NVARCHAR (255)  COLLATE Latin1_General_CI_AS NULL,
    [strComments]                   NVARCHAR (100)  COLLATE Latin1_General_CI_AS NULL,
    [intConcurrencyId]              INT             NOT NULL,
    CONSTRAINT [PK_tblARStatementFooter] PRIMARY KEY CLUSTERED ([intStatementFooterId] ASC),
	CONSTRAINT [UKstrStatementCode] UNIQUE NONCLUSTERED ([strStatementCode] ASC)
);

