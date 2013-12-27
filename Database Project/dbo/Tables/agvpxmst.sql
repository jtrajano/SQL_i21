CREATE TABLE [dbo].[agvpxmst] (
    [agvpx_vnd_no]       CHAR (10)      NOT NULL,
    [agvpx_vnd_itm_no]   CHAR (15)      NOT NULL,
    [agvpx_vnd_itm_desc] CHAR (30)      NULL,
    [agvpx_ag_itm_no]    CHAR (13)      NOT NULL,
    [agvpx_cnv_factor]   DECIMAL (9, 4) NULL,
    [agvpx_aw_prc_lst_1] CHAR (8)       NULL,
    [agvpx_aw_prc_lst_2] CHAR (8)       NULL,
    [agvpx_aw_prc_lst_3] CHAR (8)       NULL,
    [agvpx_aw_prc_lst_4] CHAR (8)       NULL,
    [agvpx_aw_cost_1]    DECIMAL (9, 4) NULL,
    [agvpx_aw_cost_2]    DECIMAL (9, 4) NULL,
    [agvpx_aw_cost_3]    DECIMAL (9, 4) NULL,
    [agvpx_aw_cost_4]    DECIMAL (9, 4) NULL,
    [agvpx_aw_rev_dt_1]  INT            NULL,
    [agvpx_aw_rev_dt_2]  INT            NULL,
    [agvpx_aw_rev_dt_3]  INT            NULL,
    [agvpx_aw_rev_dt_4]  INT            NULL,
    [agvpx_user_id]      CHAR (16)      NULL,
    [agvpx_user_rev_dt]  INT            NULL,
    [A4GLIdentity]       NUMERIC (9)    IDENTITY (1, 1) NOT NULL,
    CONSTRAINT [k_agvpxmst] PRIMARY KEY NONCLUSTERED ([agvpx_vnd_no] ASC, [agvpx_vnd_itm_no] ASC)
);




GO
CREATE UNIQUE CLUSTERED INDEX [Iagvpxmst0]
    ON [dbo].[agvpxmst]([agvpx_vnd_no] ASC, [agvpx_vnd_itm_no] ASC);


GO
CREATE NONCLUSTERED INDEX [Iagvpxmst1]
    ON [dbo].[agvpxmst]([agvpx_ag_itm_no] ASC, [agvpx_vnd_no] ASC);


GO
GRANT UPDATE
    ON OBJECT::[dbo].[agvpxmst] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[agvpxmst] TO PUBLIC
    AS [dbo];


GO
GRANT REFERENCES
    ON OBJECT::[dbo].[agvpxmst] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[agvpxmst] TO PUBLIC
    AS [dbo];


GO
GRANT DELETE
    ON OBJECT::[dbo].[agvpxmst] TO PUBLIC
    AS [dbo];

