CREATE TABLE [dbo].[cfss6mst] (
    [cfss6_host_no]       CHAR (6)    NOT NULL,
    [cfss6_site_type]     CHAR (1)    NOT NULL,
    [cfss6_site_cd]       CHAR (15)   NOT NULL,
    [cfss6_site_addr]     CHAR (35)   NULL,
    [cfss6_site_city]     CHAR (20)   NULL,
    [cfss6_site_state]    CHAR (2)    NULL,
    [cfss6_loc_prc_yn]    CHAR (1)    NULL,
    [cfss6_loc_host_no]   CHAR (6)    NULL,
    [cfss6_loc_site_type] CHAR (1)    NULL,
    [cfss6_loc_site_cd]   CHAR (15)   NULL,
    [cfss6_user_id]       CHAR (16)   NULL,
    [cfss6_user_rev_dt]   INT         NULL,
    [A4GLIdentity]        NUMERIC (9) IDENTITY (1, 1) NOT NULL,
    CONSTRAINT [k_cfss6mst] PRIMARY KEY NONCLUSTERED ([cfss6_host_no] ASC, [cfss6_site_type] ASC, [cfss6_site_cd] ASC)
);




GO
CREATE UNIQUE CLUSTERED INDEX [Icfss6mst0]
    ON [dbo].[cfss6mst]([cfss6_host_no] ASC, [cfss6_site_type] ASC, [cfss6_site_cd] ASC);


GO
GRANT UPDATE
    ON OBJECT::[dbo].[cfss6mst] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[cfss6mst] TO PUBLIC
    AS [dbo];


GO
GRANT REFERENCES
    ON OBJECT::[dbo].[cfss6mst] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[cfss6mst] TO PUBLIC
    AS [dbo];


GO
GRANT DELETE
    ON OBJECT::[dbo].[cfss6mst] TO PUBLIC
    AS [dbo];

