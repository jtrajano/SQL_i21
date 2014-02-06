CREATE TABLE [dbo].[cfsp4mst] (
    [cfsp4_host_no]            CHAR (6)       NOT NULL,
    [cfsp4_site_type]          CHAR (1)       NOT NULL,
    [cfsp4_site_cd]            CHAR (15)      NOT NULL,
    [cfsp4_effective_yyyymmdd] INT            NOT NULL,
    [cfsp4_prod_no_1]          CHAR (4)       NULL,
    [cfsp4_prod_no_2]          CHAR (4)       NULL,
    [cfsp4_prod_no_3]          CHAR (4)       NULL,
    [cfsp4_prod_no_4]          CHAR (4)       NULL,
    [cfsp4_prod_no_5]          CHAR (4)       NULL,
    [cfsp4_prod_no_6]          CHAR (4)       NULL,
    [cfsp4_prod_no_7]          CHAR (4)       NULL,
    [cfsp4_prod_no_8]          CHAR (4)       NULL,
    [cfsp4_prod_no_9]          CHAR (4)       NULL,
    [cfsp4_prod_no_10]         CHAR (4)       NULL,
    [cfsp4_prod_no_11]         CHAR (4)       NULL,
    [cfsp4_prod_no_12]         CHAR (4)       NULL,
    [cfsp4_prod_no_13]         CHAR (4)       NULL,
    [cfsp4_prc_1]              DECIMAL (6, 5) NULL,
    [cfsp4_prc_2]              DECIMAL (6, 5) NULL,
    [cfsp4_prc_3]              DECIMAL (6, 5) NULL,
    [cfsp4_prc_4]              DECIMAL (6, 5) NULL,
    [cfsp4_prc_5]              DECIMAL (6, 5) NULL,
    [cfsp4_prc_6]              DECIMAL (6, 5) NULL,
    [cfsp4_prc_7]              DECIMAL (6, 5) NULL,
    [cfsp4_prc_8]              DECIMAL (6, 5) NULL,
    [cfsp4_prc_9]              DECIMAL (6, 5) NULL,
    [cfsp4_prc_10]             DECIMAL (6, 5) NULL,
    [cfsp4_prc_11]             DECIMAL (6, 5) NULL,
    [cfsp4_prc_12]             DECIMAL (6, 5) NULL,
    [cfsp4_prc_13]             DECIMAL (6, 5) NULL,
    [cfsp4_user_id]            CHAR (16)      NULL,
    [cfsp4_user_rev_dt]        INT            NULL,
    [A4GLIdentity]             NUMERIC (9)    IDENTITY (1, 1) NOT NULL,
    CONSTRAINT [k_cfsp4mst] PRIMARY KEY NONCLUSTERED ([cfsp4_host_no] ASC, [cfsp4_site_type] ASC, [cfsp4_site_cd] ASC, [cfsp4_effective_yyyymmdd] ASC)
);


GO
CREATE UNIQUE CLUSTERED INDEX [Icfsp4mst0]
    ON [dbo].[cfsp4mst]([cfsp4_host_no] ASC, [cfsp4_site_type] ASC, [cfsp4_site_cd] ASC, [cfsp4_effective_yyyymmdd] ASC);

