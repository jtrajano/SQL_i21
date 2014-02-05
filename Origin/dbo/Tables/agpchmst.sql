CREATE TABLE [dbo].[agpchmst] (
    [agpch_itm_no]              CHAR (13)       NOT NULL,
    [agpch_itm_loc_no]          CHAR (3)        NOT NULL,
    [agpch_new_std_cost_rev_dt] INT             NULL,
    [agpch_prc_calc_ind]        CHAR (1)        NULL,
    [agpch_sell_chg_pct]        DECIMAL (5, 2)  NULL,
    [agpch_old_un_cost]         DECIMAL (11, 5) NULL,
    [agpch_old_un_prc1]         DECIMAL (11, 5) NULL,
    [agpch_old_un_prc2]         DECIMAL (11, 5) NULL,
    [agpch_old_un_prc3]         DECIMAL (11, 5) NULL,
    [agpch_old_un_prc4]         DECIMAL (11, 5) NULL,
    [agpch_old_un_prc5]         DECIMAL (11, 5) NULL,
    [agpch_old_un_prc6]         DECIMAL (11, 5) NULL,
    [agpch_old_un_prc7]         DECIMAL (11, 5) NULL,
    [agpch_old_un_prc8]         DECIMAL (11, 5) NULL,
    [agpch_old_un_prc9]         DECIMAL (11, 5) NULL,
    [agpch_old_prc1_calc]       DECIMAL (11, 5) NULL,
    [agpch_old_prc2_calc]       DECIMAL (11, 5) NULL,
    [agpch_old_prc3_calc]       DECIMAL (11, 5) NULL,
    [agpch_old_prc4_calc]       DECIMAL (11, 5) NULL,
    [agpch_old_prc5_calc]       DECIMAL (11, 5) NULL,
    [agpch_old_prc6_calc]       DECIMAL (11, 5) NULL,
    [agpch_old_prc7_calc]       DECIMAL (11, 5) NULL,
    [agpch_old_prc8_calc]       DECIMAL (11, 5) NULL,
    [agpch_old_prc9_calc]       DECIMAL (11, 5) NULL,
    [agpch_new_std_un_cost]     DECIMAL (11, 5) NULL,
    [agpch_new_un_prc1]         DECIMAL (11, 5) NULL,
    [agpch_new_un_prc2]         DECIMAL (11, 5) NULL,
    [agpch_new_un_prc3]         DECIMAL (11, 5) NULL,
    [agpch_new_un_prc4]         DECIMAL (11, 5) NULL,
    [agpch_new_un_prc5]         DECIMAL (11, 5) NULL,
    [agpch_new_un_prc6]         DECIMAL (11, 5) NULL,
    [agpch_new_un_prc7]         DECIMAL (11, 5) NULL,
    [agpch_new_un_prc8]         DECIMAL (11, 5) NULL,
    [agpch_new_un_prc9]         DECIMAL (11, 5) NULL,
    [agpch_new_prc1_calc]       DECIMAL (11, 5) NULL,
    [agpch_new_prc2_calc]       DECIMAL (11, 5) NULL,
    [agpch_new_prc3_calc]       DECIMAL (11, 5) NULL,
    [agpch_new_prc4_calc]       DECIMAL (11, 5) NULL,
    [agpch_new_prc5_calc]       DECIMAL (11, 5) NULL,
    [agpch_new_prc6_calc]       DECIMAL (11, 5) NULL,
    [agpch_new_prc7_calc]       DECIMAL (11, 5) NULL,
    [agpch_new_prc8_calc]       DECIMAL (11, 5) NULL,
    [agpch_new_prc9_calc]       DECIMAL (11, 5) NULL,
    [agpch_user_id]             CHAR (16)       NULL,
    [agpch_user_rev_dt]         INT             NULL,
    [A4GLIdentity]              NUMERIC (9)     IDENTITY (1, 1) NOT NULL,
    CONSTRAINT [k_agpchmst] PRIMARY KEY NONCLUSTERED ([agpch_itm_no] ASC, [agpch_itm_loc_no] ASC)
);


GO
CREATE UNIQUE CLUSTERED INDEX [Iagpchmst0]
    ON [dbo].[agpchmst]([agpch_itm_no] ASC, [agpch_itm_loc_no] ASC);


GO
GRANT DELETE
    ON OBJECT::[dbo].[agpchmst] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[agpchmst] TO PUBLIC
    AS [dbo];


GO
GRANT REFERENCES
    ON OBJECT::[dbo].[agpchmst] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[agpchmst] TO PUBLIC
    AS [dbo];


GO
GRANT UPDATE
    ON OBJECT::[dbo].[agpchmst] TO PUBLIC
    AS [dbo];

