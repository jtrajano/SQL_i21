CREATE TABLE [dbo].[agbdgmst] (
    [agbdg_cus_no]        CHAR (10)      NOT NULL,
    [agbdg_budget_rev_dt] INT            NULL,
    [agbdg_budget_amt]    DECIMAL (9, 2) NULL,
    [agbdg_batch_no]      SMALLINT       NULL,
    [agbdg_comments]      CHAR (30)      NULL,
    [agbdg_user_id]       CHAR (16)      NULL,
    [agbdg_user_rev_dt]   INT            NULL,
    [A4GLIdentity]        NUMERIC (9)    IDENTITY (1, 1) NOT NULL,
    CONSTRAINT [k_agbdgmst] PRIMARY KEY NONCLUSTERED ([agbdg_cus_no] ASC)
);


GO
CREATE UNIQUE CLUSTERED INDEX [Iagbdgmst0]
    ON [dbo].[agbdgmst]([agbdg_cus_no] ASC);

