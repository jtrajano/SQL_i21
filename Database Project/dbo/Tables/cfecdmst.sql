CREATE TABLE [dbo].[cfecdmst] (
    [cfecd_ar_cus_no]    CHAR (10)   NOT NULL,
    [cfecd_card_no]      CHAR (16)   NOT NULL,
    [cfecd_cus_name]     CHAR (50)   NULL,
    [cfecd_pin_no]       CHAR (4)    NULL,
    [cfecd_exp_yymm]     SMALLINT    NULL,
    [cfecd_valid_vnid]   CHAR (1)    NULL,
    [cfecd_no_cards]     TINYINT     NULL,
    [cfecd_limited_code] TINYINT     NULL,
    [cfecd_fuel_code]    TINYINT     NULL,
    [cfecd_tier_code]    CHAR (1)    NULL,
    [cfecd_odom_code]    CHAR (1)    NULL,
    [cfecd_wc_code]      CHAR (1)    NULL,
    [cfecd_card_desc]    CHAR (30)   NULL,
    [A4GLIdentity]       NUMERIC (9) IDENTITY (1, 1) NOT NULL,
    CONSTRAINT [k_cfecdmst] PRIMARY KEY NONCLUSTERED ([cfecd_ar_cus_no] ASC, [cfecd_card_no] ASC)
);


GO
CREATE UNIQUE CLUSTERED INDEX [Icfecdmst0]
    ON [dbo].[cfecdmst]([cfecd_ar_cus_no] ASC, [cfecd_card_no] ASC);

