CREATE TABLE [dbo].[tblAPPreference] (
    [intPreferenceId]      INT             IDENTITY (1, 1) NOT NULL,
    [intDefaultAccountId]  INT             NULL,
    [intWithholdAccountId] INT             NULL,
    [intDiscountAccountId] INT             NULL,
    [dblWithholdPercent]   DECIMAL (18, 6) NULL,
    PRIMARY KEY CLUSTERED ([intPreferenceId] ASC)
);

