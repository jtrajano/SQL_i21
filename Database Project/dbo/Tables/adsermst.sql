CREATE TABLE [dbo].[adsermst] (
    [adser_serial_no]      CHAR (10)      NOT NULL,
    [adser_tie_breaker]    TINYINT        NOT NULL,
    [adser_desc]           CHAR (30)      NULL,
    [adser_capacity]       INT            NULL,
    [adser_type_au]        CHAR (1)       NULL,
    [adser_manufacturer]   CHAR (10)      NULL,
    [adser_year]           SMALLINT       NULL,
    [adser_purch_prc]      DECIMAL (9, 2) NULL,
    [adser_lro]            CHAR (1)       NULL,
    [adser_lof]            CHAR (1)       NULL,
    [adser_lease_start_dt] INT            NULL,
    [adser_lease_rate]     DECIMAL (7, 2) NULL,
    [adser_lease_min_use]  INT            NULL,
    [adser_install_rev_dt] INT            NULL,
    [adser_misc1_rev_dt]   INT            NULL,
    [adser_misc2_rev_dt]   INT            NULL,
    [adser_misc3_rev_dt]   INT            NULL,
    [adser_misc4_rev_dt]   INT            NULL,
    [adser_misc5_rev_dt]   INT            NULL,
    [adser_misc6_rev_dt]   INT            NULL,
    [adser_misc7_rev_dt]   INT            NULL,
    [adser_misc1_model]    CHAR (15)      NULL,
    [adser_misc2_model]    CHAR (15)      NULL,
    [adser_misc3_model]    CHAR (15)      NULL,
    [adser_misc4_model]    CHAR (15)      NULL,
    [adser_misc5_model]    CHAR (15)      NULL,
    [adser_misc6_model]    CHAR (15)      NULL,
    [adser_misc7_model]    CHAR (15)      NULL,
    [adser_cus_no]         CHAR (10)      NOT NULL,
    [adser_itm_no]         CHAR (13)      NOT NULL,
    [adser_tank_no]        CHAR (4)       NOT NULL,
    [adser_last_cus_no]    CHAR (10)      NULL,
    [adser_last_itm_no]    CHAR (13)      NULL,
    [adser_last_tank_no]   CHAR (4)       NULL,
    [adser_last_rev_dt]    INT            NULL,
    [adser_div]            CHAR (2)       NULL,
    [adser_dept]           CHAR (3)       NULL,
    [adser_class]          CHAR (2)       NULL,
    [adser_id_no]          CHAR (6)       NULL,
    [adser_user_id]        CHAR (16)      NULL,
    [adser_user_rev_dt]    INT            NULL,
    [A4GLIdentity]         NUMERIC (9)    IDENTITY (1, 1) NOT NULL,
    CONSTRAINT [k_adsermst] PRIMARY KEY NONCLUSTERED ([adser_serial_no] ASC, [adser_tie_breaker] ASC)
);




GO
CREATE UNIQUE CLUSTERED INDEX [Iadsermst0]
    ON [dbo].[adsermst]([adser_serial_no] ASC, [adser_tie_breaker] ASC);


GO
CREATE NONCLUSTERED INDEX [Iadsermst1]
    ON [dbo].[adsermst]([adser_cus_no] ASC, [adser_itm_no] ASC, [adser_tank_no] ASC);


GO
GRANT UPDATE
    ON OBJECT::[dbo].[adsermst] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[adsermst] TO PUBLIC
    AS [dbo];


GO
GRANT REFERENCES
    ON OBJECT::[dbo].[adsermst] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[adsermst] TO PUBLIC
    AS [dbo];


GO
GRANT DELETE
    ON OBJECT::[dbo].[adsermst] TO PUBLIC
    AS [dbo];

