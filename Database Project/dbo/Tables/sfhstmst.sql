CREATE TABLE [dbo].[sfhstmst] (
    [sfhst_cus_no]      CHAR (10)       NOT NULL,
    [sfhst_grp_id]      CHAR (14)       NOT NULL,
    [sfhst_ivc_no]      CHAR (8)        NOT NULL,
    [sfhst_loc_no]      CHAR (3)        NOT NULL,
    [sfhst_line_no]     SMALLINT        NOT NULL,
    [sfhst_stg_id]      CHAR (10)       NOT NULL,
    [sfhst_stg_seq_no]  TINYINT         NOT NULL,
    [sfhst_itm_no]      CHAR (13)       NOT NULL,
    [sfhst_lbs]         DECIMAL (11, 4) NULL,
    [sfhst_sls]         DECIMAL (11, 2) NULL,
    [sfhst_ship_rev_dt] INT             NULL,
    [sfhst_user_id]     CHAR (16)       NULL,
    [sfhst_user_rev_dt] INT             NULL,
    [A4GLIdentity]      NUMERIC (9)     IDENTITY (1, 1) NOT NULL,
    CONSTRAINT [k_sfhstmst] PRIMARY KEY NONCLUSTERED ([sfhst_cus_no] ASC, [sfhst_grp_id] ASC, [sfhst_ivc_no] ASC, [sfhst_loc_no] ASC, [sfhst_line_no] ASC)
);




GO
CREATE UNIQUE CLUSTERED INDEX [Isfhstmst0]
    ON [dbo].[sfhstmst]([sfhst_cus_no] ASC, [sfhst_grp_id] ASC, [sfhst_ivc_no] ASC, [sfhst_loc_no] ASC, [sfhst_line_no] ASC);


GO
CREATE NONCLUSTERED INDEX [Isfhstmst1]
    ON [dbo].[sfhstmst]([sfhst_cus_no] ASC, [sfhst_grp_id] ASC, [sfhst_itm_no] ASC);


GO
CREATE NONCLUSTERED INDEX [Isfhstmst2]
    ON [dbo].[sfhstmst]([sfhst_cus_no] ASC, [sfhst_grp_id] ASC, [sfhst_stg_id] ASC, [sfhst_stg_seq_no] ASC);


GO
GRANT UPDATE
    ON OBJECT::[dbo].[sfhstmst] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[sfhstmst] TO PUBLIC
    AS [dbo];


GO
GRANT REFERENCES
    ON OBJECT::[dbo].[sfhstmst] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[sfhstmst] TO PUBLIC
    AS [dbo];


GO
GRANT DELETE
    ON OBJECT::[dbo].[sfhstmst] TO PUBLIC
    AS [dbo];

