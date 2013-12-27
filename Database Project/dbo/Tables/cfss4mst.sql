CREATE TABLE [dbo].[cfss4mst] (
    [cfss4_host_no]       CHAR (6)    NOT NULL,
    [cfss4_site_type]     CHAR (1)    NOT NULL,
    [cfss4_site_cd]       CHAR (15)   NOT NULL,
    [cfss4_site_addr]     CHAR (35)   NULL,
    [cfss4_site_city]     CHAR (20)   NULL,
    [cfss4_site_state]    CHAR (2)    NULL,
    [cfss4_loc_prc_yn]    CHAR (1)    NULL,
    [cfss4_loc_host_no]   CHAR (6)    NULL,
    [cfss4_loc_site_type] CHAR (1)    NULL,
    [cfss4_loc_site_cd]   CHAR (15)   NULL,
    [cfss4_user_id]       CHAR (16)   NULL,
    [cfss4_user_rev_dt]   INT         NULL,
    [A4GLIdentity]        NUMERIC (9) IDENTITY (1, 1) NOT NULL,
    CONSTRAINT [k_cfss4mst] PRIMARY KEY NONCLUSTERED ([cfss4_host_no] ASC, [cfss4_site_type] ASC, [cfss4_site_cd] ASC)
);




GO
CREATE UNIQUE CLUSTERED INDEX [Icfss4mst0]
    ON [dbo].[cfss4mst]([cfss4_host_no] ASC, [cfss4_site_type] ASC, [cfss4_site_cd] ASC);


GO
GRANT UPDATE
    ON OBJECT::[dbo].[cfss4mst] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[cfss4mst] TO PUBLIC
    AS [dbo];


GO
GRANT REFERENCES
    ON OBJECT::[dbo].[cfss4mst] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[cfss4mst] TO PUBLIC
    AS [dbo];


GO
GRANT DELETE
    ON OBJECT::[dbo].[cfss4mst] TO PUBLIC
    AS [dbo];

