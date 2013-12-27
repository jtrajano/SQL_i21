CREATE TABLE [dbo].[ageommst] (
    [ageom_period]       INT             NOT NULL,
    [ageom_itm_no]       CHAR (13)       NOT NULL,
    [ageom_loc_no]       CHAR (3)        NOT NULL,
    [ageom_un]           DECIMAL (13, 4) NULL,
    [ageom_eom_un_cost]  DECIMAL (11, 5) NULL,
    [ageom_std_un_cost]  DECIMAL (11, 5) NULL,
    [ageom_avg_un_cost]  DECIMAL (11, 5) NULL,
    [ageom_last_un_cost] DECIMAL (11, 5) NULL,
    [ageom_ivc_un_cost]  DECIMAL (11, 5) NULL,
    [ageom_user_id]      CHAR (16)       NULL,
    [ageom_user_rev_dt]  INT             NULL,
    [A4GLIdentity]       NUMERIC (9)     IDENTITY (1, 1) NOT NULL,
    CONSTRAINT [k_ageommst] PRIMARY KEY NONCLUSTERED ([ageom_period] ASC, [ageom_itm_no] ASC, [ageom_loc_no] ASC)
);




GO
CREATE UNIQUE CLUSTERED INDEX [Iageommst0]
    ON [dbo].[ageommst]([ageom_period] ASC, [ageom_itm_no] ASC, [ageom_loc_no] ASC);


GO
CREATE UNIQUE NONCLUSTERED INDEX [Iageommst1]
    ON [dbo].[ageommst]([ageom_itm_no] ASC, [ageom_loc_no] ASC, [ageom_period] ASC);


GO
CREATE UNIQUE NONCLUSTERED INDEX [Iageommst2]
    ON [dbo].[ageommst]([ageom_loc_no] ASC, [ageom_itm_no] ASC, [ageom_period] ASC);


GO
GRANT UPDATE
    ON OBJECT::[dbo].[ageommst] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[ageommst] TO PUBLIC
    AS [dbo];


GO
GRANT REFERENCES
    ON OBJECT::[dbo].[ageommst] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[ageommst] TO PUBLIC
    AS [dbo];


GO
GRANT DELETE
    ON OBJECT::[dbo].[ageommst] TO PUBLIC
    AS [dbo];

